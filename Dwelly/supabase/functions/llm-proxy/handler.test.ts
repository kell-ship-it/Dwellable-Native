// T-310: real, executed tests for the T-302/T-303 safety-layer orchestration logic in
// handler.ts. These ARE run (not just hand-reviewed) via a locally installed Deno:
//
//   /tmp/deno-local/bin/deno test --no-npm supabase/functions/llm-proxy/handler.test.ts
//
// No network access, no real OpenAI/Groq/Supabase calls, no secrets -- every dependency
// `handleProxyRequest` needs is a plain in-memory fake built below, so this exercises the
// actual branching logic (classifier failure, moderation failure, output-check failure,
// the action->response mapping, usage logging for the safety calls themselves) rather
// than describing expected behavior in prose.

import { assertEquals, assertExists } from "jsr:@std/assert"
import {
  handleProxyRequest,
  FIXED_SAFETY_TEXT,
  FALLBACK_TEXT,
  INPUT_CLASSIFIER_PROMPT,
  buildInputClassifierMessages,
  ZERO_USAGE,
  type ChatMessage,
  type LLMProxyRequest,
  type ModerationResult,
  type ProxyDependencies,
  type SafetyAction,
  type TokenUsage,
  ONBOARDING_FINAL_CLOSER,
} from "./handler.ts"

function usage(total: number): TokenUsage {
  return { promptTokens: total - 10, completionTokens: 10, totalTokens: total }
}

interface Calls {
  moderation: string[]
  classify: { messages: ChatMessage[]; moderationHint: string }[]
  checkOutput: string[]
  groq: ChatMessage[][]
  openai: ChatMessage[][]
  usageLogged: { feature: string; provider: string; model: string; usage: TokenUsage }[]
  diagnostics: { stage: "input" | "output"; failureType: string; feature: string }[]
  aggregateBumps: string[]
}

/// Builds a fully-wired fake `ProxyDependencies` with sane defaults (moderation clean,
/// classifier says "normal", output check says safe, Groq succeeds) and a `calls`
/// tracker so each test can assert exactly what ran. Individual fields are overridden
/// per test via the `overrides` param.
function makeFakeDeps(overrides: Partial<ProxyDependencies> = {}): { deps: ProxyDependencies; calls: Calls } {
  const calls: Calls = {
    moderation: [],
    classify: [],
    checkOutput: [],
    groq: [],
    openai: [],
    usageLogged: [],
    diagnostics: [],
    aggregateBumps: [],
  }

  const deps: ProxyDependencies = {
    async callModeration(text: string): Promise<ModerationResult> {
      calls.moderation.push(text)
      return { flagged: false, summary: "none" }
    },
    async classifyInput(messages, moderationHint) {
      calls.classify.push({ messages, moderationHint })
      return { classification: { action: "normal" as SafetyAction, clarifyQuestion: null }, usage: usage(50) }
    },
    async checkOutput(draftReply: string) {
      calls.checkOutput.push(draftReply)
      return { safe: true, usage: usage(15) }
    },
    async callGroq(messages) {
      calls.groq.push(messages)
      return { content: "a real groq reply", usage: usage(200) }
    },
    async callOpenAI(messages) {
      calls.openai.push(messages)
      return { content: "a real openai reply", usage: usage(200) }
    },
    async logUsage(entry) {
      calls.usageLogged.push(entry)
    },
    async logSafetyDiagnostic(stage, failureType, feature) {
      calls.diagnostics.push({ stage, failureType, feature })
    },
    async bumpSafetyAggregate(category) {
      calls.aggregateBumps.push(category)
    },
    ...overrides,
  }

  return { deps, calls }
}

function capturePayload(lastUserMessage: string, priorTurns: ChatMessage[] = []): LLMProxyRequest {
  return {
    feature: "capture_conversation",
    messages: [
      { role: "system", content: "persona prompt" },
      ...priorTurns,
      { role: "user", content: lastUserMessage },
    ],
  }
}

// ---------------------------------------------------------------------------
// 1. Classifier failure (malformed JSON / timeout -- both surface as a thrown error
//    from `classifyInput`) must fail CLOSED to the fallback, never silently proceed.
// ---------------------------------------------------------------------------
Deno.test("classifier failure (malformed JSON) -> fallback, never 'normal'", async () => {
  const { deps, calls } = makeFakeDeps({
    async classifyInput() {
      throw new Error("Safety classifier returned an invalid action: {\"action\":\"banana\"}")
    },
  })
  const result = await handleProxyRequest(capturePayload("anything"), deps)
  assertEquals(result.status, 200)
  assertEquals(result.body.content, FALLBACK_TEXT)
  assertEquals(result.body.safetyTier, "fallback")
  assertEquals(calls.diagnostics, [{ stage: "input", failureType: "classifier_error", feature: "capture_conversation" }])
  assertEquals(calls.groq.length, 0, "must never reach the real model call after a classifier failure")
})

Deno.test("classifier failure (timeout) -> same fallback behavior as malformed JSON", async () => {
  const { deps, calls } = makeFakeDeps({
    async classifyInput() {
      throw new DOMException("The signal has been aborted", "AbortError")
    },
  })
  const result = await handleProxyRequest(capturePayload("anything"), deps)
  assertEquals(result.body.safetyTier, "fallback")
  assertEquals(calls.diagnostics[0]?.failureType, "classifier_error")
})

// ---------------------------------------------------------------------------
// 2. Moderation failing must NOT block the input stage -- the classifier runs
//    independently and, if IT succeeds, the conversation proceeds normally.
// ---------------------------------------------------------------------------
Deno.test("moderation failure does not block the independently-operating classifier", async () => {
  const { deps, calls } = makeFakeDeps({
    async callModeration() {
      throw new Error("OpenAI moderation endpoint 500")
    },
  })
  const result = await handleProxyRequest(capturePayload("I had a quiet, peaceful day"), deps)
  assertEquals(calls.diagnostics, [{ stage: "input", failureType: "moderation_error", feature: "capture_conversation" }])
  // Classifier still ran and said "normal" (the fake default) -> real model call happens.
  assertEquals(calls.groq.length, 1)
  assertEquals(result.body.safetyTier, "normal")
  assertEquals(result.body.content, "a real groq reply")
})

// ---------------------------------------------------------------------------
// 3. Output check: an unsafe verdict OR a thrown error must both result in the
//    fallback being returned -- the raw generated reply must never leak through.
// ---------------------------------------------------------------------------
Deno.test("output check returning unsafe -> fallback, not the generated reply", async () => {
  const { deps, calls } = makeFakeDeps({
    async checkOutput(draft) {
      return { safe: false, usage: usage(12) }
    },
  })
  const result = await handleProxyRequest(capturePayload("something that produced a bad draft"), deps)
  assertEquals(result.body.content, FALLBACK_TEXT)
  assertEquals(result.body.safetyTier, "fallback")
  assertEquals(calls.aggregateBumps, ["output_blocked"])
  // The output-check call itself still gets logged for cost tracking even though it
  // flagged the reply -- real spend happened either way.
  assertEquals(calls.usageLogged.some((u) => u.feature === "capture_conversation_safety_output_check"), true)
  // The billed-but-rejected main reply IS now recorded, under a safety-named feature so it
  // stays out of the daily cap; it is never logged as a normal "capture_conversation" row.
  assertEquals(calls.usageLogged.some((u) => u.feature === "capture_conversation"), false)
  assertEquals(calls.usageLogged.some((u) => u.feature === "capture_conversation_safety_rejected_reply"), true)
})

Deno.test("output check timeout/error -> fallback, diagnostic logged, raw reply never returned", async () => {
  const { deps, calls } = makeFakeDeps({
    async checkOutput() {
      throw new Error("output check timed out")
    },
  })
  const result = await handleProxyRequest(capturePayload("anything"), deps)
  assertEquals(result.body.content, FALLBACK_TEXT)
  assertEquals(result.body.safetyTier, "fallback")
  assertEquals(calls.diagnostics, [{ stage: "output", failureType: "output_check_error", feature: "capture_conversation" }])
  assertEquals(result.body.content !== "a real groq reply", true, "the unchecked generated reply must never be the body content")
})

// ---------------------------------------------------------------------------
// 4. Third-party vs. first-person risk, and vulnerability vs. an actual request for
//    harmful assistance -- the action->response mapping must be exact, not conflated.
// ---------------------------------------------------------------------------
Deno.test("crisis_self and crisis_other map to DIFFERENT fixed responses (first-person vs. third-party)", async () => {
  const selfDeps = makeFakeDeps({
    async classifyInput() {
      return { classification: { action: "crisis_self", clarifyQuestion: null }, usage: usage(40) }
    },
  })
  const otherDeps = makeFakeDeps({
    async classifyInput() {
      return { classification: { action: "crisis_other", clarifyQuestion: null }, usage: usage(40) }
    },
  })
  const selfResult = await handleProxyRequest(capturePayload("I want to end my life tonight"), selfDeps.deps)
  const otherResult = await handleProxyRequest(capturePayload("my cousin tried to hurt himself yesterday"), otherDeps.deps)

  assertEquals(selfResult.body.content, FIXED_SAFETY_TEXT.crisis_self)
  assertEquals(otherResult.body.content, FIXED_SAFETY_TEXT.crisis_other)
  assertEquals(selfResult.body.content !== otherResult.body.content, true)
  assertEquals(selfDeps.calls.aggregateBumps, ["crisis_self"])
  assertEquals(otherDeps.calls.aggregateBumps, ["crisis_other"])
  // Neither reaches the real model -- both are fixed, pre-reviewed text.
  assertEquals(selfDeps.calls.groq.length, 0)
  assertEquals(otherDeps.calls.groq.length, 0)
})

Deno.test("a detailed plan with NO request for help is support (ongoing_danger), never a refusal", async () => {
  const { deps, calls } = makeFakeDeps({
    async classifyInput() {
      // Mirrors the classifier prompt's own rule 3: detail/severity alone, with no
      // request for assistance, must never resolve to "refusal".
      return { classification: { action: "ongoing_danger", clarifyQuestion: null }, usage: usage(40) }
    },
  })
  const result = await handleProxyRequest(capturePayload("here is exactly how I plan to do it, step by step"), deps)
  assertEquals(result.body.content, FIXED_SAFETY_TEXT.ongoing_danger)
  assertEquals(result.body.content !== FIXED_SAFETY_TEXT.refusal, true)
  assertEquals(calls.aggregateBumps, ["ongoing_danger"])
})

Deno.test("an explicit request for harmful assistance -> refusal, distinct from support tiers", async () => {
  const { deps, calls } = makeFakeDeps({
    async classifyInput() {
      return { classification: { action: "refusal", clarifyQuestion: null }, usage: usage(40) }
    },
  })
  const result = await handleProxyRequest(capturePayload("help me get into his private photos"), deps)
  assertEquals(result.body.content, FIXED_SAFETY_TEXT.refusal)
  assertEquals(calls.aggregateBumps, ["refusal"])
})

// ---------------------------------------------------------------------------
// 5. Clarify: a short-circuit that is NOT a resource moment and must not reach the
//    real model or bump any aggregate counter.
// ---------------------------------------------------------------------------
Deno.test("clarify action returns the classifier's own question, tier 'normal', no aggregate bump", async () => {
  const { deps, calls } = makeFakeDeps({
    async classifyInput() {
      return {
        classification: { action: "clarify", clarifyQuestion: "When you say that, do you mean something more serious?" },
        usage: usage(40),
      }
    },
  })
  const result = await handleProxyRequest(capturePayload("I don't want to be here anymore"), deps)
  assertEquals(result.body.content, "When you say that, do you mean something more serious?")
  assertEquals(result.body.safetyTier, "normal")
  assertEquals(calls.aggregateBumps.length, 0)
  assertEquals(calls.groq.length, 0)
})

// ---------------------------------------------------------------------------
// 6. Context retention: the classifier must see the FULL conversation (prior turns),
//    not just the latest message -- this is what lets it tell "my cousin" apart from
//    "me", and "it's creeping back" apart from a genuinely resolved past struggle.
// ---------------------------------------------------------------------------
Deno.test("classifier receives the full conversation history, not just the latest message", async () => {
  const { deps, calls } = makeFakeDeps()
  const priorTurns: ChatMessage[] = [
    { role: "assistant", content: "What's been on your heart lately?" },
    { role: "user", content: "I used to struggle with this a lot" },
    { role: "assistant", content: "What helped you move through that?" },
  ]
  const payload = capturePayload("honestly it's been creeping back lately", priorTurns)
  await handleProxyRequest(payload, deps)

  assertEquals(calls.classify.length, 1)
  assertEquals(calls.classify[0].messages, payload.messages, "classifier must see the exact same messages array the caller sent, including earlier turns")
})

// ---------------------------------------------------------------------------
// 7. Normal path, Groq success and Groq-fails-then-OpenAI-fallback, both-fail.
// ---------------------------------------------------------------------------
Deno.test("normal action falls through to Groq, logs classifier + main usage", async () => {
  const { deps, calls } = makeFakeDeps()
  const result = await handleProxyRequest(capturePayload("I felt God's peace today"), deps)
  assertEquals(result.body.provider, "groq")
  assertEquals(result.body.safetyTier, "normal")
  assertEquals(calls.usageLogged.map((u) => u.feature), [
    "capture_conversation_safety_classifier",
    "capture_conversation_safety_output_check",
    "capture_conversation",
  ])
})

Deno.test("Groq failure falls back to OpenAI for the main reply (pre-existing behavior preserved)", async () => {
  const { deps } = makeFakeDeps({
    async callGroq() {
      throw new Error("Groq 503")
    },
  })
  const result = await handleProxyRequest(capturePayload("a normal reflection"), deps)
  assertEquals(result.body.provider, "openai")
  assertEquals(result.body.content, "a real openai reply")
})

Deno.test("both providers failing returns a 502 with no safety fallback masking it", async () => {
  const { deps } = makeFakeDeps({
    async callGroq() {
      throw new Error("Groq down")
    },
    async callOpenAI() {
      throw new Error("OpenAI down")
    },
  })
  const result = await handleProxyRequest(capturePayload("a normal reflection"), deps)
  assertEquals(result.status, 502)
  assertExists(result.body.error)
})

// ---------------------------------------------------------------------------
// 8. Out-of-scope features (prayer_generation, journal_synthesis) must skip the
//    entire safety layer -- confirmed by asserting none of its deps were called.
// ---------------------------------------------------------------------------
Deno.test("non-capture_conversation features skip the safety layer entirely", async () => {
  const { deps, calls } = makeFakeDeps()
  const payload: LLMProxyRequest = {
    feature: "prayer_generation",
    messages: [{ role: "user", content: "anything at all" }],
  }
  const result = await handleProxyRequest(payload, deps)
  assertEquals(calls.moderation.length, 0)
  assertEquals(calls.classify.length, 0)
  assertEquals(calls.checkOutput.length, 0)
  assertEquals(calls.groq.length, 1)
  assertEquals(result.body.safetyTier, undefined)
})

// Sanity check that ZERO_USAGE is a usable, well-formed TokenUsage for callers that
// don't have real numbers (e.g. a future dependency that can't report token counts).
Deno.test("ZERO_USAGE has all-null fields, not zeros that could be mistaken for a real zero-token call", () => {
  assertEquals(ZERO_USAGE.promptTokens, null)
  assertEquals(ZERO_USAGE.completionTokens, null)
  assertEquals(ZERO_USAGE.totalTokens, null)
})

// Kell, Nov 19 2026: every AI call tries Groq first, OpenAI only as the fallback -- the
// safety checks included. The proxy's real provider choice lives in index.ts; what this
// file can prove is that usage logging records WHICH provider actually answered, so the
// usage dashboard and the daily cap see the truth instead of an assumed "openai".
Deno.test("safety-call usage is logged under the provider that actually answered (Groq)", async () => {
  const { deps, calls } = makeFakeDeps({
    async classifyInput() {
      return { classification: { action: "normal" as SafetyAction, clarifyQuestion: null }, usage: usage(50), provider: "groq" as const, model: "openai/gpt-oss-120b" }
    },
    async checkOutput() {
      return { safe: true, usage: usage(15), provider: "groq" as const, model: "openai/gpt-oss-120b" }
    },
  })
  await handleProxyRequest(capturePayload("Grateful for a quiet morning."), deps)
  const classifier = calls.usageLogged.find((u) => u.feature === "capture_conversation_safety_classifier")
  const outputCheck = calls.usageLogged.find((u) => u.feature === "capture_conversation_safety_output_check")
  assertEquals(classifier?.provider, "groq")
  assertEquals(classifier?.model, "openai/gpt-oss-120b")
  assertEquals(outputCheck?.provider, "groq")
  assertEquals(calls.usageLogged.some((u) => u.provider === "openai"), false)
})

Deno.test("safety-call usage is logged as OpenAI when OpenAI is what answered (the fallback)", async () => {
  const { deps, calls } = makeFakeDeps({
    async classifyInput() {
      return { classification: { action: "normal" as SafetyAction, clarifyQuestion: null }, usage: usage(50), provider: "openai" as const, model: "gpt-4o-mini" }
    },
  })
  await handleProxyRequest(capturePayload("Grateful for a quiet morning."), deps)
  const classifier = calls.usageLogged.find((u) => u.feature === "capture_conversation_safety_classifier")
  assertEquals(classifier?.provider, "openai")
  assertEquals(classifier?.model, "gpt-4o-mini")
})

// The classifier prompt is model input, so these only guard that the wording this
// behaviour depends on is still present -- they say nothing about how a model follows it.
Deno.test("classifier prompt asks a DIRECT question for self-harm ambiguity and does not latch on an idiom alone", () => {
  assertEquals(INPUT_CLASSIFIER_PROMPT.includes("ask DIRECTLY and gently whether they are having thoughts of hurting themselves or ending their life"), true)
  assertEquals(INPUT_CLASSIFIER_PROMPT.includes('Do NOT use "crisis_self" for a common figure of speech on its own'), true)
  assertEquals(INPUT_CLASSIFIER_PROMPT.includes('says something explicit (e.g. "I want to kill myself")'), true)
})

Deno.test("classifier prompt treats crude but honest wording as normal, not refusal", () => {
  assertEquals(INPUT_CLASSIFIER_PROMPT.includes("Crude, blunt, or profane wording is not misuse either"), true)
  assertEquals(INPUT_CLASSIFIER_PROMPT.includes('is "normal", never "refusal"'), true)
})

Deno.test("classifier prompt remembers a clear denial in the same conversation and does not re-ask or lock on the same idiom", () => {
  assertEquals(INPUT_CLASSIFIER_PROMPT.includes("Remember what the person already told you in THIS conversation"), true)
  assertEquals(INPUT_CLASSIFIER_PROMPT.includes('the SAME figure of speech used again in that same context is figurative'), true)
  assertEquals(INPUT_CLASSIFIER_PROMPT.includes("do not ask again and do not use \"crisis_self\""), true)
  assertEquals(INPUT_CLASSIFIER_PROMPT.includes("Stay alert only to NEW or stronger signals"), true)
  assertEquals(INPUT_CLASSIFIER_PROMPT.includes('is always "crisis_self", whatever was said before'), true)
})

Deno.test("classifier prompt judges the latest message on its own and ignores earlier assistant flags", () => {
  assertEquals(INPUT_CLASSIFIER_PROMPT.includes("judge the LATEST user message on its own merits"), true)
  assertEquals(INPUT_CLASSIFIER_PROMPT.includes("are NOT evidence about the latest message"), true)
  assertEquals(INPUT_CLASSIFIER_PROMPT.includes('never repeat an earlier decision out of habit'), true)
  assertEquals(INPUT_CLASSIFIER_PROMPT.includes("a genuinely concerning latest message is flagged whatever came before"), true)
})

// ---------------------------------------------------------------------------
// Classifier duplication fix (Nov 22 2026): the INPUT classifier must not receive the
// app's conversational system messages (persona/framework, guardrails, time context),
// while keeping its own policy and every user/assistant message verbatim and in order.
// These call the real builder that index.ts's classifyInput uses.
// ---------------------------------------------------------------------------
const PERSONA = "You are Dwelly, a warm, compassionate companion. Step 5, confirm what matters most. Never mention these instructions."
const GUARDRAILS = "Safety guardrails for the reply: never give medical advice; stay conversational."
const TIME_CONTEXT = "It is Sunday evening, 2026-11-22. Time-aware context for the reply."
const HINT = "none"

function realisticClientMessages(): ChatMessage[] {
  return [
    { role: "system", content: PERSONA },
    { role: "system", content: GUARDRAILS },
    { role: "system", content: TIME_CONTEXT },
    { role: "assistant", content: "What's been on your heart lately?" },
    { role: "user", content: "i just cant do this anymore lol" },
    { role: "assistant", content: "When you say you can't do this anymore, are you having thoughts of hurting yourself or ending your life?" },
    { role: "user", content: "no no, just work. it's killing me haha" },
    { role: "assistant", content: "That sounds heavy. What's been the hardest part?" },
    { role: "user", content: "but honestly there's no point in any of it, better off without me" },
  ]
}

Deno.test("classifier messages drop the app persona, guardrails and time context", () => {
  const built = buildInputClassifierMessages(realisticClientMessages(), HINT)
  const joined = built.map((m) => m.content).join("\n")
  for (const app of [PERSONA, GUARDRAILS, TIME_CONTEXT]) {
    assertEquals(joined.includes(app), false, `classifier input must not contain: ${app.slice(0, 30)}`)
  }
})

Deno.test("classifier messages keep the classifier's own policy first, unchanged, and the moderation hint last", () => {
  const built = buildInputClassifierMessages(realisticClientMessages(), "flagged: violence")
  assertEquals(built[0], { role: "system", content: INPUT_CLASSIFIER_PROMPT })
  assertEquals(built[built.length - 1], {
    role: "system",
    content: "(Informational only, not conclusive -- an automated content filter flagged: flagged: violence)",
  })
  assertEquals(built.filter((m) => m.role === "system").length, 2, "only the classifier's own policy and the moderation hint are system messages")
})

Deno.test("classifier messages keep every user/assistant message byte-for-byte and in order (slang, denial, clarifying question, new risk)", () => {
  const input = realisticClientMessages()
  const built = buildInputClassifierMessages(input, HINT)
  const middle = built.slice(1, built.length - 1)
  const expected = input.filter((m) => m.role !== "system")
  assertEquals(middle, expected)
  assertEquals(middle.length, 6)
  // spot-check the exact strings that carry the denial/clarify/new-risk context
  assertEquals(middle[2].content, "When you say you can't do this anymore, are you having thoughts of hurting yourself or ending your life?")
  assertEquals(middle[3].content, "no no, just work. it's killing me haha")
  assertEquals(middle[5].content, "but honestly there's no point in any of it, better off without me")
})

Deno.test("classifier message builder does not mutate its input", () => {
  const input = realisticClientMessages()
  const snapshot = JSON.stringify(input)
  const built = buildInputClassifierMessages(input, HINT)
  assertEquals(JSON.stringify(input), snapshot)
  assertEquals(input.length, 9)
  assertEquals(built === input, false)
})

Deno.test("classifier builder keeps an assistant-only opening prompt and handles a payload with no system messages", () => {
  const input: ChatMessage[] = [
    { role: "assistant", content: "What's stirring in you today?" },
    { role: "user", content: "yes" },
  ]
  const built = buildInputClassifierMessages(input, HINT)
  assertEquals(built.slice(1, 3), input)
})

Deno.test("the main reply payload still carries the full client system messages unchanged", async () => {
  const { deps, calls } = makeFakeDeps()
  const payload: LLMProxyRequest = { feature: "capture_conversation", messages: realisticClientMessages() }
  const before = JSON.stringify(payload.messages)
  await handleProxyRequest(payload, deps)
  assertEquals(calls.groq.length, 1)
  assertEquals(JSON.stringify(calls.groq[0]), before, "main call must receive the exact client messages, persona included")
  assertEquals(JSON.stringify(payload.messages), before)
})

Deno.test("groqEnabled=false: main reply goes straight to OpenAI, Groq never called", async () => {
  const { deps, calls } = makeFakeDeps({ groqEnabled: false })
  const result = await handleProxyRequest(capturePayload("I felt God's peace today"), deps)
  assertEquals(result.status, 200)
  assertEquals(result.body.provider, "openai")
  assertEquals(calls.groq.length, 0)
  assertEquals(calls.openai.length, 1)
  assertEquals(result.body.safetyTier, "normal")
})

Deno.test("groqEnabled=false: OpenAI failure returns 502 and still never touches Groq", async () => {
  const { deps, calls } = makeFakeDeps({
    groqEnabled: false,
    async callOpenAI() {
      throw new Error("OpenAI 500")
    },
  })
  const result = await handleProxyRequest(capturePayload("a normal reflection"), deps)
  assertEquals(result.status, 502)
  assertEquals(calls.groq.length, 0)
})

Deno.test("a hung OpenAI provider aborts at the deadline and the proxy still fails closed (502, no Groq)", async () => {
  const { withTimeout } = await import("./fetch_timeout.ts")
  let aborted = false
  const { deps, calls } = makeFakeDeps({
    groqEnabled: false,
    // Same wrapper callOpenAI uses; the "provider" never answers until aborted.
    callOpenAI: () =>
      withTimeout(30, (signal) =>
        new Promise((_, reject) => signal.addEventListener("abort", () => { aborted = true; reject(new Error("aborted")) }))),
  })
  const result = await handleProxyRequest(capturePayload("a normal reflection"), deps)
  assertEquals(aborted, true)
  assertEquals(result.status, 502)
  assertEquals(calls.groq.length, 0)
})

Deno.test("closer=onboarding_final: moderation+classifier run, NO generation, server constant returned after output check", async () => {
  const { deps, calls } = makeFakeDeps()
  const p = { ...capturePayload("I'm ready"), closer: "onboarding_final" as const }
  const r = await handleProxyRequest(p, deps)
  assertEquals(r.body.content, ONBOARDING_FINAL_CLOSER)
  assertEquals(r.body.safetyTier, "normal")
  assertEquals(calls.moderation.length, 1)
  assertEquals(calls.classify.length, 1)
  assertEquals(calls.openai.length + calls.groq.length, 0)
  assertEquals(calls.checkOutput, [ONBOARDING_FINAL_CLOSER]) // the constant, checked
})

Deno.test("closer: a non-normal classification still returns the safety tier, never the closer", async () => {
  const { deps, calls } = makeFakeDeps({
    async classifyInput() {
      return { classification: { action: "crisis_self" as SafetyAction, clarifyQuestion: null }, usage: usage(50) }
    },
  })
  const r = await handleProxyRequest({ ...capturePayload("x"), closer: "onboarding_final" }, deps)
  assertEquals(r.body.safetyTier, "crisis_self")
  assertEquals(r.body.content !== ONBOARDING_FINAL_CLOSER, true)
  assertEquals(calls.checkOutput.length, 0)
})

Deno.test("closer: classifier failure fails closed (fallback), closer check failure/unsafe also fails closed", async () => {
  const a = makeFakeDeps({ async classifyInput() { throw new Error("down") } })
  const ra = await handleProxyRequest({ ...capturePayload("x"), closer: "onboarding_final" }, a.deps)
  assertEquals(ra.body.safetyTier, "fallback")
  const b = makeFakeDeps({ async checkOutput() { throw new Error("down") } })
  const rb = await handleProxyRequest({ ...capturePayload("x"), closer: "onboarding_final" }, b.deps)
  assertEquals(rb.body.safetyTier, "fallback")
  const c = makeFakeDeps({ async checkOutput() { return { safe: false, usage: usage(1) } } })
  const rc = await handleProxyRequest({ ...capturePayload("x"), closer: "onboarding_final" }, c.deps)
  assertEquals(rc.body.safetyTier, "fallback")
})

Deno.test("closer: unknown value or non-capture feature is rejected (400); client cannot supply text", async () => {
  const { deps, calls } = makeFakeDeps()
  const r1 = await handleProxyRequest({ ...capturePayload("x"), closer: "anything" as never }, deps)
  assertEquals(r1.status, 400)
  const r2 = await handleProxyRequest({ feature: "journal_synthesis", messages: [{ role: "user", content: "x" }], closer: "onboarding_final" }, deps)
  assertEquals(r2.status, 400)
  assertEquals(calls.openai.length + calls.groq.length + calls.classify.length, 0)
})

Deno.test("closer on final turn: classifier CLARIFY returns the server's clarifying question (tier normal) with NO closer marker", async () => {
  const { deps, calls } = makeFakeDeps({
    async classifyInput() {
      return { classification: { action: "clarify" as SafetyAction, clarifyQuestion: "Can you say more about what you mean?" }, usage: usage(50) }
    },
  })
  const r = await handleProxyRequest({ ...capturePayload("hmm"), closer: "onboarding_final" }, deps)
  assertEquals(r.body.safetyTier, "normal")
  assertEquals(r.body.content, "Can you say more about what you mean?")
  assertEquals(r.body.closer, undefined) // the ONLY signal the client may use to show the fixed hand-off
  assertEquals(calls.openai.length + calls.groq.length, 0)
})

Deno.test("closer marker appears ONLY when the closer was actually applied (not crisis/refusal/fallback/clarify)", async () => {
  for (const action of ["crisis_self", "crisis_other", "ongoing_danger", "refusal"] as SafetyAction[]) {
    const { deps } = makeFakeDeps({ async classifyInput() { return { classification: { action, clarifyQuestion: null }, usage: usage(1) } } })
    const r = await handleProxyRequest({ ...capturePayload("x"), closer: "onboarding_final" }, deps)
    assertEquals(r.body.closer, undefined, action)
  }
  const f = makeFakeDeps({ async classifyInput() { throw new Error("down") } })
  assertEquals((await handleProxyRequest({ ...capturePayload("x"), closer: "onboarding_final" }, f.deps)).body.closer, undefined)
  const ok = makeFakeDeps()
  assertEquals((await handleProxyRequest({ ...capturePayload("x"), closer: "onboarding_final" }, ok.deps)).body.closer, "onboarding_final")
})

Deno.test("pipelineTokens sums classifier + main + output check; flags unknown usage", async () => {
  const { deps } = makeFakeDeps({
    classifyInput: async () => ({ classification: { action: "normal" as SafetyAction, clarifyQuestion: null }, usage: usage(100) }),
    checkOutput: async () => ({ safe: true, usage: usage(10) }),
    callGroq: async () => ({ content: "hi", usage: usage(1000) }),
    callOpenAI: async () => ({ content: "hi", usage: usage(1000) }),
  })
  const r = await handleProxyRequest(capturePayload("hello"), deps)
  assertEquals((r.body as Record<string, unknown>).pipelineTokens, 1110)
  assertEquals((r.body as Record<string, unknown>).pipelineTokensComplete, true)

  const unknown = { promptTokens: null, completionTokens: null, totalTokens: null }
  const { deps: d2 } = makeFakeDeps({
    classifyInput: async () => ({ classification: { action: "normal" as SafetyAction, clarifyQuestion: null }, usage: unknown }),
  })
  const r2 = await handleProxyRequest(capturePayload("hello"), d2)
  assertEquals((r2.body as Record<string, unknown>).pipelineTokensComplete, false)
})

Deno.test("failed paths still report spend: classifier throw and main-call failure are unknown, never zero", async () => {
  const { deps } = makeFakeDeps({ classifyInput: async () => { throw new Error("boom") } })
  const r = await handleProxyRequest(capturePayload("hello"), deps)
  const b = r.body as Record<string, unknown>
  assertEquals(b.pipelineTokensComplete, false)
  assertEquals(b.pipelineUnknownCalls, 1)

  const { deps: d2 } = makeFakeDeps({
    callGroq: async () => { throw new Error("down") },
    callOpenAI: async () => { throw new Error("down") },
  })
  const r2 = await handleProxyRequest(capturePayload("hello"), d2)
  const b2 = r2.body as Record<string, unknown>
  assertEquals(r2.status, 502)
  assertEquals(b2.pipelineTokens, 50) // billed classifier counted
  assertEquals(b2.pipelineTokensComplete, false) // failed main call(s) unknown
  assertEquals(typeof b2.pipelineUnknownCalls, "number")
})

Deno.test("output-check failure after a billed main call: spend counted, completeness false", async () => {
  const { deps } = makeFakeDeps({ checkOutput: async () => { throw new Error("timeout") } })
  const r = await handleProxyRequest(capturePayload("hello"), deps)
  const b = r.body as Record<string, unknown>
  assertEquals(b.safetyTier, "fallback")
  assertEquals(b.pipelineTokens, 250) // classifier 50 + main 200
  assertEquals(b.pipelineTokensComplete, false)
})

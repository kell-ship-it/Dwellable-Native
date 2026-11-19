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
  ZERO_USAGE,
  type ChatMessage,
  type LLMProxyRequest,
  type ModerationResult,
  type ProxyDependencies,
  type SafetyAction,
  type TokenUsage,
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
  // The main reply's own usage must NOT be logged -- it was never shown.
  assertEquals(calls.usageLogged.some((u) => u.feature === "capture_conversation"), false)
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

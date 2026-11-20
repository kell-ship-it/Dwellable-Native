// T-302/T-303 (+ T-310's testability requirement): the pure, network-free orchestration
// logic for the crisis/misuse safety layer, extracted out of index.ts specifically so it
// can be unit-tested with mocked dependencies -- no live OpenAI/Groq/Supabase calls, no
// `Deno.serve` side effect (which made this untestable when it lived in index.ts: simply
// importing index.ts tried to bind a real network listener and crashed the test runner).
//
// index.ts is now a thin HTTP/auth wrapper: it handles CORS, method checking, JWT
// verification, and the daily-call-limit check, then builds a real `ProxyDependencies`
// (actual fetch calls, actual Supabase clients) and calls `handleProxyRequest` here.
// handler.test.ts builds a FAKE `ProxyDependencies` instead and exercises every branch
// below directly -- see that file for the actual test run, not just typechecked.

export type ChatMessage = { role: "system" | "user" | "assistant"; content: string }

export interface LLMProxyRequest {
  messages: ChatMessage[]
  feature: string
  max_tokens?: number
  temperature?: number
}

export interface TokenUsage {
  promptTokens: number | null
  completionTokens: number | null
  totalTokens: number | null
}

export const ZERO_USAGE: TokenUsage = { promptTokens: null, completionTokens: null, totalTokens: null }

export interface ModerationResult {
  flagged: boolean
  summary: string
}

export type SafetyAction = "normal" | "clarify" | "crisis_self" | "crisis_other" | "ongoing_danger" | "refusal"

export interface InputClassification {
  action: SafetyAction
  clarifyQuestion: string | null
}

// Which provider/model actually answered a safety call. Groq first, OpenAI only as the
// fallback (Kell, Nov 19 2026) -- so usage logging must record what really ran, not
// assume OpenAI. Optional so callers/fakes that don't care keep working.
export interface SafetyCallMeta {
  provider?: "groq" | "openai"
  model?: string
}

export interface ProxyResult {
  status: number
  body: Record<string, unknown>
}

// ---------------------------------------------------------------------------
// T-302/T-303: Crisis/misuse safety layer (ticket T-125's locked design).
//
// Two independent axes, not one flat "flagged/not flagged" boolean:
//   Axis A (risk tier): A0 none / A1 vulnerable-honest-disclosure-no-danger /
//     A2 ambiguous / A3 credible present-or-future risk to self or another person.
//   Axis B (orientation): B1 honest expression / B2 ambiguous / B3 an explicit
//     request for harmful assistance.
// Adult sexual desire/temptation, quoted hateful language directed AT the user,
// past-and-genuinely-resolved struggles, intrusive thoughts without stated intent,
// and a disclosed abuse history (including as a minor at the time) are all A0-A1/B1
// -- normal reflection, never flagged, never refused. A detailed/credible plan
// disclosed with NO request for help is A3/B1 (support + resources, not refused) --
// B3 requires an ACTUAL request for harmful assistance, not just severity or detail.
//
// Raw OpenAI moderation category flags are never treated as proof of anything by
// themselves -- moderation runs as a supplementary signal only; the contextual
// classifier below (which sees real recent conversation, not one message in
// isolation) is what actually decides the tier. If moderation itself fails, the
// contextual step still runs independently (its result alone is trusted). If the
// contextual classifier itself fails, that IS fatal to the input stage -- without it
// we can't safely tell A1 from A3, so this fails toward the neutral fallback, never
// toward silently proceeding as "normal".
// ---------------------------------------------------------------------------

export const INPUT_CLASSIFIER_PROMPT = `You are a careful safety classifier for a Christian reflection/journaling app. Read the conversation and decide what should happen with the user's latest message. You are NOT the one replying to the user -- you only output a JSON decision.

Two independent axes to reason about internally:
- Risk tier: none / vulnerable-but-no-danger / ambiguous / credible risk to self or another person (present, ongoing, or a real future threat).
- Orientation: honest expression or disclosure / ambiguous / an EXPLICIT request for help carrying out harm to someone.

Critical rules, in order of importance:
1. Honest disclosure is never misuse. Adult sexual desire or temptation, grief, doubt, past resolved struggles, intrusive unwanted thoughts the person doesn't want to act on, quoted hateful language said TO the user by someone else, a disclosure of being abused (at any age, including as a current minor) -- all of these are "normal". Never refuse or redirect these. Crude, blunt, or profane wording is not misuse either: people speak honestly the way they would to a trusted friend, pastor, or mentor, so judge the meaning, not the vocabulary. A vulgar or sexually explicit statement of an honest desire, frustration, or loneliness is "normal", never "refusal".
2. A third party being at risk (e.g. "my cousin tried to hurt himself") is not automatically low-risk just because it isn't the user -- if the person described sounds like they may still be in danger, use "crisis_other"; if it reads as resolved/past/no ongoing danger, "normal" is fine, but judge this from the actual content, not just tense.
3. A DETAILED OR SPECIFIC plan to harm someone, described with NO request for help from you, is still just a disclosure -- use "crisis_other" or "ongoing_danger" (risk + support), NOT "refusal". Only use "refusal" when the person is explicitly asking YOU to help them do something harmful (instructions, drafting harassment, planning an attack, anything involving a minor sexually).
4. Vague statements ("I don't want to be here anymore", "I could kill him") are judged by actual context, never auto-dismissed as venting and never auto-escalated -- if genuinely ambiguous, use "clarify" with ONE short, natural, non-alarming clarifying question. When the ambiguity is about whether the person might hurt or end their own life (e.g. "I can't do this anymore", "it's killing me", "I can't take it"), the clarifying question must ask DIRECTLY and gently whether they are having thoughts of hurting themselves or ending their life -- not only invite them to say more. Do NOT use "crisis_self" for a common figure of speech on its own. Use "crisis_self" when the person states or confirms thoughts of suicide or self-harm, says something explicit (e.g. "I want to kill myself"), or has already been asked directly and gives a deflecting answer that keeps expressing being unable to go on. Remember what the person already told you in THIS conversation: if they were asked directly and clearly said it is not about hurting themselves (for example they explained they are lonely or struggling with something specific), then the SAME figure of speech used again in that same context is figurative -- use "normal" and do not ask again and do not use "crisis_self". Stay alert only to NEW or stronger signals (hopelessness, "no point", "better off without me", "can't go on", a stated plan or wish to die): if one appears after such a denial, use "clarify" once more with a direct question in different words, and use "crisis_self" if they confirm, deflect, or say something explicit. An explicit statement such as "I want to kill myself" is always "crisis_self", whatever was said before.
5. Past-tense phrasing is only "resolved" if the context actually supports that (explicit "I'm in a different place now", no sign it's recurring) -- "it's creeping back lately" is NOT resolved even though it's phrased with "used to."
6. If someone is currently in an ongoing dangerous situation themselves (e.g. active abuse from another person), use "ongoing_danger", not "crisis_self" (which is for self-harm/suicide risk) and not "refusal".

Consistency: judge the LATEST user message on its own merits, in light of what the person has said. Earlier assistant replies in this conversation (a support message, resource lines, a refusal, a clarifying question) are NOT evidence about the latest message and must not push you toward flagging it -- never repeat an earlier decision out of habit. A harmless or merely crude latest message is "normal" even right after a flagged one. The reverse also holds: a genuinely concerning latest message is flagged whatever came before.

Respond with ONLY this JSON shape, no other text:
{"action": "normal" | "clarify" | "crisis_self" | "crisis_other" | "ongoing_danger" | "refusal", "clarifyQuestion": string or null}

"clarifyQuestion" is required (a short, warm, natural-sounding question) only when action is "clarify"; null otherwise.`

export const OUTPUT_CHECK_PROMPT = `You are checking a drafted reply from a compassionate Christian reflection app before it's shown to a user. Answer whether it is safe to show. It is UNSAFE if it: gives harmful instructions of any kind; pressures the user to forgive, reconcile with, or stay close to someone who has hurt them; offers prayer or scripture as a substitute for a real safety action when danger was described; or shames/moralizes at an honest disclosure (e.g. about sexual feelings, doubt, or past wrongdoing). Respond with ONLY this JSON: {"safe": true or false}`

// Pulled out as a pure function (no network call) so it's unit-testable directly.
export function parseClassificationJSON(raw: string): InputClassification {
  const parsed = JSON.parse(raw) as Partial<InputClassification>
  const validActions: SafetyAction[] = ["normal", "clarify", "crisis_self", "crisis_other", "ongoing_danger", "refusal"]
  if (!parsed.action || !validActions.includes(parsed.action)) {
    throw new Error(`Safety classifier returned an invalid action: ${JSON.stringify(parsed)}`)
  }
  return { action: parsed.action, clarifyQuestion: parsed.clarifyQuestion ?? null }
}

// Fixed, pre-written sentences for crisis/refusal/fallback -- never model-generated,
// same reasoning as the client's own `closingMessage` pattern: a reply whose only job
// is to be reliable in a sensitive moment shouldn't depend on a model improvising it
// correctly every time. SafetyResourceCenter.swift (client-side) owns the actual phone
// numbers/links and appends them after this sentence -- kept there, not here, so
// resource copy stays in exactly one place and can be localized without touching this.
export const FIXED_SAFETY_TEXT: Record<Exclude<SafetyAction, "normal" | "clarify">, string> = {
  crisis_self:
    "Thank you for trusting me with that. What you're feeling matters, and I don't want you to carry it alone.",
  crisis_other:
    "That sounds like a lot to carry for someone you care about. I'm glad you're not keeping it to yourself.",
  ongoing_danger:
    "I'm really glad you told me. You deserve to be safe, and this isn't something you have to figure out by yourself.",
  refusal:
    "I won't help with that specific thing — but I don't want to just leave it there. What's actually going on for you right now?",
}

export const FALLBACK_TEXT =
  "I want to make sure I respond carefully here, and I wasn't able to a moment ago. I don't want to guess, so let's slow down for a second."

/// T-304's real injectable surface -- every piece of I/O `handleProxyRequest` needs,
/// abstracted so tests can supply deterministic fakes. Each real implementation lives
/// in index.ts; see handler.test.ts for the fake ones used in tests.
export interface ProxyDependencies {
  callModeration(text: string): Promise<ModerationResult>
  classifyInput(messages: ChatMessage[], moderationHint: string): Promise<{ classification: InputClassification; usage: TokenUsage } & SafetyCallMeta>
  checkOutput(draftReply: string): Promise<{ safe: boolean; usage: TokenUsage } & SafetyCallMeta>
  callGroq(messages: ChatMessage[], maxTokens: number, temperature: number): Promise<{ content: string; usage: TokenUsage }>
  callOpenAI(messages: ChatMessage[], maxTokens: number, temperature: number): Promise<{ content: string; usage: TokenUsage }>
  // T-304 point 4: EVERY real spend -- the main conversational call AND the safety
  // classifier/output-check calls -- gets logged through this one function, tagged
  // by `feature`, so the existing daily-call-limit check (which counts rows in this
  // same table) actually sees the safety-layer's own token spend too. Without this,
  // a user could trigger unlimited classifier/output-check calls (real OpenAI spend)
  // without ever counting against their daily cap, which only counted the main reply.
  logUsage(entry: { feature: string; provider: string; model: string; usage: TokenUsage }): Promise<void>
  // T-307: diagnostics are gated by a retention policy the CALLER (index.ts) decides --
  // this interface doesn't assume one exists. If no policy is approved yet, index.ts's
  // real implementation is a no-op (see SAFETY_DIAGNOSTICS_ENABLED in index.ts) rather
  // than silently writing indefinite-retention rows.
  logSafetyDiagnostic(stage: "input" | "output", failureType: string, feature: string): Promise<void>
  bumpSafetyAggregate(category: string): Promise<void>
}

const GROQ_MODEL = "openai/gpt-oss-120b"
const OPENAI_MODEL = "gpt-4o-mini"
const SAFETY_MODEL = "gpt-4o-mini"
const DEFAULT_MAX_TOKENS = 1000
const DEFAULT_TEMPERATURE = 0.8

/// The actual decision + model-call orchestration, fully independent of HTTP/auth/CORS
/// and of any specific provider's fetch call -- everything provider-specific is behind
/// `deps`. Returns a plain {status, body} the caller turns into a Response.
export async function handleProxyRequest(payload: LLMProxyRequest, deps: ProxyDependencies): Promise<ProxyResult> {
  const maxTokens = payload.max_tokens ?? DEFAULT_MAX_TOKENS
  const temperature = payload.temperature ?? DEFAULT_TEMPERATURE

  // T-302/T-303: the safety layer only runs for capture_conversation -- free-form user
  // text is the one place it enters this app. Prayer generation and journal synthesis
  // operate on content the user already reviewed/sent through capture, not a fresh
  // free-form turn, so they're explicitly out of this ticket's scope -- see
  // handler.test.ts's "other features skip the safety layer entirely" test.
  const isCaptureConversation = payload.feature === "capture_conversation"

  let safetyTier: string | undefined
  let shortCircuitContent: string | undefined

  if (isCaptureConversation) {
    const latestUserMessage = [...payload.messages].reverse().find((m) => m.role === "user")?.content ?? ""

    let moderationHint = "unavailable (check failed, ignored -- see note below)"
    try {
      const moderation = await deps.callModeration(latestUserMessage)
      moderationHint = moderation.flagged ? moderation.summary : "none"
    } catch (moderationError) {
      // Per T-302's locked design: moderation failing does NOT block the input stage --
      // the contextual classifier below runs independently and its result alone is
      // trusted. Only logged so Kell can see how often this happens.
      console.error("llm-proxy: moderation check failed (non-fatal, continuing) --", moderationError)
      await deps.logSafetyDiagnostic("input", "moderation_error", payload.feature)
    }

    let classification: InputClassification
    try {
      const classified = await deps.classifyInput(payload.messages, moderationHint)
      classification = classified.classification
      await deps.logUsage({ feature: `${payload.feature}_safety_classifier`, provider: classified.provider ?? "openai", model: classified.model ?? SAFETY_MODEL, usage: classified.usage })
    } catch (classifierError) {
      // The contextual classifier failing IS fatal to the input stage -- without it we
      // can't safely distinguish A1 from A3, so this fails toward the neutral fallback
      // + help entry point, never toward silently proceeding as "normal".
      console.error(`llm-proxy [${payload.feature}]: input safety classifier failed --`, classifierError)
      await deps.logSafetyDiagnostic("input", "classifier_error", payload.feature)
      return { status: 200, body: { content: FALLBACK_TEXT, model: "safety-fallback", provider: "openai", safetyTier: "fallback" } }
    }

    const action = classification.action
    if (action === "clarify") {
      safetyTier = "normal" // a natural clarifying question, not a resource moment
      shortCircuitContent = classification.clarifyQuestion ?? "Can you tell me a little more about what you mean?"
    } else if (action !== "normal") {
      safetyTier = action
      shortCircuitContent = FIXED_SAFETY_TEXT[action]
      await deps.bumpSafetyAggregate(action)
    }
    // action === "normal" falls through to the real model call below.
  }

  if (shortCircuitContent !== undefined) {
    return { status: 200, body: { content: shortCircuitContent, model: "safety-fixed", provider: "openai", safetyTier } }
  }

  let result: { content: string; model: string; provider: "groq" | "openai" }
  let usage: TokenUsage
  try {
    const groqResult = await deps.callGroq(payload.messages, maxTokens, temperature)
    result = { content: groqResult.content, model: GROQ_MODEL, provider: "groq" }
    usage = groqResult.usage
  } catch (groqError) {
    console.error(`llm-proxy [${payload.feature}]: Groq failed, falling back to OpenAI --`, groqError)
    try {
      const openaiResult = await deps.callOpenAI(payload.messages, maxTokens, temperature)
      result = { content: openaiResult.content, model: OPENAI_MODEL, provider: "openai" }
      usage = openaiResult.usage
    } catch (openaiError) {
      console.error(`llm-proxy [${payload.feature}]: OpenAI fallback also failed --`, openaiError)
      return { status: 502, body: { error: "Both LLM providers failed", groq: String(groqError), openai: String(openaiError) } }
    }
  }

  // T-303: output check, capture_conversation only. On failure OR an unsafe verdict,
  // the generated reply is NEVER shown -- this is the whole point of this ticket's
  // amendment over an earlier draft that would have fail-opened to the unchecked reply.
  // Prayer/journal synthesis responses skip this (out of scope, see above).
  if (isCaptureConversation) {
    try {
      const outputCheck = await deps.checkOutput(result.content)
      const { safe, usage: outputCheckUsage } = outputCheck
      await deps.logUsage({ feature: `${payload.feature}_safety_output_check`, provider: outputCheck.provider ?? "openai", model: outputCheck.model ?? SAFETY_MODEL, usage: outputCheckUsage })
      if (!safe) {
        await deps.bumpSafetyAggregate("output_blocked")
        return { status: 200, body: { content: FALLBACK_TEXT, model: "safety-fallback", provider: "openai", safetyTier: "fallback" } }
      }
    } catch (outputCheckError) {
      console.error(`llm-proxy [${payload.feature}]: output check failed --`, outputCheckError)
      await deps.logSafetyDiagnostic("output", "output_check_error", payload.feature)
      return { status: 200, body: { content: FALLBACK_TEXT, model: "safety-fallback", provider: "openai", safetyTier: "fallback" } }
    }
  }

  console.log(`llm-proxy [${payload.feature}]: served by ${result.provider}/${result.model}, ${usage.totalTokens ?? "?"} tokens`)

  // Log after a successful call, not before -- a failed call never happened and
  // shouldn't count against the daily cap or show up in Kell's provider-split check.
  await deps.logUsage({ feature: payload.feature, provider: result.provider, model: result.model, usage })

  return { status: 200, body: { ...result, safetyTier: isCaptureConversation ? "normal" : undefined } }
}

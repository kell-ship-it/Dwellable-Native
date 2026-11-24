// T-168: Shared LLM Proxy Service
//
// The one place in this entire app that calls an LLM. Every feature that needs one
// (P1 Capture's "Dwelly Responds" conversation, P3 Prayer generation, P4 Journal
// synthesis, eventually P6 Formation Intelligence) calls THIS endpoint instead of
// talking to a provider directly -- so the API keys live in exactly one place, the
// provider/fallback logic is written exactly once, and swapping or adding a provider
// later touches one file, not every feature that uses an LLM.
//
// Locked provider decision (docs/FORMATION_INTELLIGENCE_STRATEGY.md): Groq Llama 3 70B
// is primary (free tier, superior for the poetic/narrative tone this product wants),
// OpenAI GPT-4o mini is the fallback if Groq errors or times out. This supersedes the
// older docs/LLM_RESEARCH.md Gemini recommendation (May 2026, written under the old
// client-side-E2E architecture that's since been superseded -- see
// docs/PILLAR_2_SECURITY_STRATEGY.md's "Model Change" section).
//
// `feature` is required and logged, not just decoration -- it's what lets later usage
// analysis answer "how much is Capture's conversation costing us vs. Prayer generation"
// without having to reverse-engineer it from raw request bodies.
//
// Cost control (added Nov 2026, Kell's explicit ask before real testing): every call is
// logged to public.llm_usage (user_id, feature, provider, model, created_at) -- both so
// a per-user daily cap can actually be enforced, and so Kell can see the real
// Groq-vs-OpenAI split to empirically verify the free-tier loop estimate in
// docs/LLM_COST_CAPACITY_EXPLAINER.html rather than just trust it. DAILY_CALL_LIMIT is a
// call-count cap (not a "loop" in that doc's sense -- one Capture conversation turn here
// is one call), set generously (200/day/user as of Nov 21 2026) so it bounds runaway/bug cost without
// getting in the way of Kell's own multi-day manual testing.
//
// T-302/T-303 (Nov 19 2026): this file is now a thin HTTP/auth wrapper. All of the
// crisis/misuse safety-layer DECISION logic (and the main model-call orchestration it
// wraps) lives in handler.ts as `handleProxyRequest`, specifically so it's unit-testable
// with mocked dependencies -- see handler.test.ts, which actually runs (via a locally
// installed Deno, `deno test`), not just a hand-reviewed checklist. This file's own job
// is just: CORS, method/payload checks, JWT verification, the daily-call-limit read, and
// wiring real fetch/Supabase calls into the `ProxyDependencies` handler.ts asks for.

import { withTimeout } from "./fetch_timeout.ts"
import { extractUsage } from "./usage.ts"
import { createClient } from "jsr:@supabase/supabase-js"
import {
  handleProxyRequest,
  parseClassificationJSON,
  buildInputClassifierMessages,
  OUTPUT_CHECK_PROMPT,
  type ChatMessage,
  type LLMProxyRequest,
  type ModerationResult,
  type ProxyDependencies,
  type TokenUsage,
} from "./handler.ts"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, apikey",
}

// llama3-70b-8192, then llama-3.3-70b-versatile, were both retired by Groq -- every
// call was silently falling back to OpenAI (Kell caught this Nov 9/10 2026 from the
// usage dashboard still showing 100% OpenAI after the first fix). Confirmed via
// GET https://api.groq.com/openai/v1/models with this account's own GROQ_API_KEY
// (Nov 10 2026): Groq's lineup has moved away from Llama chat models entirely --
// the only text models available now are meta-llama/llama-prompt-guard-2-* (a
// moderation classifier, not a chat model), qwen/qwen3.8-27b, allam-2-7b, and the
// openai/gpt-oss-* family. openai/gpt-oss-120b is the largest general-purpose one
// (131K context), so it's the new primary.
const GROQ_MODEL = "openai/gpt-oss-120b"
// Nov 23 2026 (Kell): Groq is SHELVED -- gpt-4o-mini handles every call (main reply,
// classifier, output check) directly. Flip to true to restore Groq-first with OpenAI fallback.
const GROQ_ENABLED = false
const OPENAI_MODEL = "gpt-4o-mini"
// T-302/T-303: the crisis/misuse safety layer, scoped only to "capture_conversation" --
// free-form text is the one place it enters this app (see T-125's own notes). Kell's rule
// (Nov 19 2026): EVERY AI call tries Groq first and only falls back to OpenAI when Groq
// fails (including hitting its daily limit) -- the safety checks included. An earlier pass
// ran the classifier and output check on OpenAI only; that spent OpenAI tokens while Groq
// was still available. If BOTH providers fail, the check throws and the proxy fails
// closed exactly as before (neutral fallback reply, unverified turn, nothing saved).
// The OpenAI moderation endpoint is the one exception: it is a separate free service
// with no Groq equivalent, supplementary only, and non-fatal if it fails.
const SAFETY_MODEL = "gpt-4o-mini"
const LLM_USAGE_CACHED_COLUMN_READY = false

// Per-capture token budget (draft migrations_draft/DRAFT_20261123130000_capture_budget.sql).
// OFF until that migration is applied AND the client sends capture_id/request_id/capture_kind.
// While false, no RPC is ever called and requests behave exactly as before.
const CAPTURE_BUDGET_LEDGER_READY = true
// ON Nov 23 2026 (Kell: all beta testers are on the newest build).
const CAPTURE_BUDGET_ENFORCE = true
const SAFETY_TIMEOUT_MS = 8_000
// Main OpenAI call previously had NO abort guard (every other outbound call did), so a
// hung request could hold the proxy open until the platform killed it.
const OPENAI_MAIN_TIMEOUT_MS = 25_000
const SAFETY_GROQ_TIMEOUT_MS = 12_000
// Raised from 500 (Nov 11 2026): gpt-oss-120b is a reasoning model -- it spends
// tokens on hidden "thinking" before its visible answer, and at 500 it sometimes
// burned the whole budget on that and returned an empty choices[0].message.content,
// which this proxy correctly treated as a Groq failure and fell back to OpenAI for
// (confirmed via function_logs: "Groq response missing choices[0].message.content",
// not a free-tier/rate-limit error -- Kell asked why OpenAI was being called at all
// when the Groq free tier hadn't been exceeded). Paired with reasoning_effort: "low"
// below, which cuts down how much of the budget reasoning eats in the first place.
const DEFAULT_MAX_TOKENS = 1000
const DEFAULT_TEMPERATURE = 0.8
const GROQ_TIMEOUT_MS = 10_000
// Nov 21 2026 (Kell): raised from 60 to 200 while the app is still in testing, and the
// safety classifier/output-check rows no longer count toward it (only the user-facing
// calls do). Still a per-user, per-UTC-day cap -- to be revisited before TestFlight/live.
const DAILY_CALL_LIMIT = 200

// T-307 (revised Nov 19 2026 per Kell/Codex's correction): short-lived, non-user-linked
// diagnostic rows (a safety check FAILING, not what it found) are NOT written by default
// -- an earlier draft of this ticket wrote them unconditionally with no retention policy
// decided, which is exactly the "sensitive indefinite diagnostics" this flag exists to
// prevent. The `safety_diagnostics` table/migration still exists (schema only) so this
// can be turned on the moment Kell approves a real retention/purge policy -- flip this to
// true ONLY once that decision is made, not before. The coarse, non-identifiable
// `safety_event_aggregate` counter is NOT gated by this flag -- Kell/Codex's review
// explicitly said aggregate counts are fine to keep by default; only the more detailed
// failure-diagnostic log needed a retention decision first.
const SAFETY_DIAGNOSTICS_ENABLED = false

async function callGroq(messages: ChatMessage[], maxTokens: number, temperature: number): Promise<{ content: string; usage: TokenUsage }> {
  const apiKey = Deno.env.get("GROQ_API_KEY")
  if (!apiKey) throw new Error("GROQ_API_KEY not set")

  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), GROQ_TIMEOUT_MS)

  try {
    const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: GROQ_MODEL,
        messages,
        max_tokens: maxTokens,
        temperature,
        // gpt-oss-120b-specific (Groq API): keeps its hidden reasoning pass short
        // so more of max_tokens is left for the actual visible answer -- none of
        // this app's features need deep multi-step reasoning out of this model.
        reasoning_effort: "low",
      }),
      signal: controller.signal,
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(`Groq API error ${response.status}: ${errorText}`)
    }

    const data = await response.json()
    const content = data.choices?.[0]?.message?.content
    if (!content) throw new Error("Groq response missing choices[0].message.content")
    return { content, usage: extractUsage(data) }
  } finally {
    clearTimeout(timeout)
  }
}

async function callOpenAI(messages: ChatMessage[], maxTokens: number, temperature: number): Promise<{ content: string; usage: TokenUsage }> {
  const apiKey = Deno.env.get("OPENAI_API_KEY")
  if (!apiKey) throw new Error("OPENAI_API_KEY not set")

  return await withTimeout(OPENAI_MAIN_TIMEOUT_MS, async (signal) => {
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      signal,
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: OPENAI_MODEL,
        messages,
        max_tokens: maxTokens,
        temperature,
      }),
    })

    if (!response.ok) {
      const errorText = await response.text()
      throw new Error(`OpenAI API error ${response.status}: ${errorText}`)
    }

    const data = await response.json() // body read is also covered by the deadline
    const content = data.choices?.[0]?.message?.content
    if (!content) throw new Error("OpenAI response missing choices[0].message.content")
    return { content, usage: extractUsage(data) }
  })
}

async function callModeration(text: string): Promise<ModerationResult> {
  const apiKey = Deno.env.get("OPENAI_API_KEY")
  if (!apiKey) throw new Error("OPENAI_API_KEY not set")

  // Moderation has no timeout guard in the original version of this function --
  // added one here for consistency with every other outbound call in this file, so a
  // hung moderation request can't hang the whole proxy request behind it.
  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), SAFETY_TIMEOUT_MS)
  try {
    const response = await fetch("https://api.openai.com/v1/moderations", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ model: "omni-moderation-latest", input: text }),
      signal: controller.signal,
    })
    if (!response.ok) {
      throw new Error(`Moderation API error ${response.status}: ${await response.text()}`)
    }
    const data = await response.json()
    const result = data.results?.[0]
    if (!result) throw new Error("Moderation response missing results[0]")

    const flaggedCategories = Object.entries(result.categories ?? {})
      .filter(([, isFlagged]) => isFlagged === true)
      .map(([category]) => category)

    return {
      flagged: Boolean(result.flagged),
      summary: flaggedCategories.length > 0 ? flaggedCategories.join(", ") : "none",
    }
  } finally {
    clearTimeout(timeout)
  }
}

type SafetyChatResult<T> = { value: T; usage: TokenUsage; provider: "groq" | "openai"; model: string }

// Pulls the JSON object out of a model reply even if it wrapped it in prose or a code
// fence (a reasoning model on Groq can, since Groq is called without json_object mode).
function extractJSONObject(raw: string): string {
  const start = raw.indexOf("{")
  const end = raw.lastIndexOf("}")
  if (start === -1 || end <= start) throw new Error(`Safety model returned no JSON object: ${raw.slice(0, 200)}`)
  return raw.slice(start, end + 1)
}

// One safety-model call: Groq first, OpenAI only if Groq fails for ANY reason (error,
// timeout, empty reply, an unparseable reply, or its daily limit). `parse` turns the raw
// reply into the typed result and throws if it can't, which counts as a failure of THAT
// provider. Both failing throws, which the caller's existing fail-closed handling turns
// into the neutral fallback.
async function safetyChat<T>(
  messages: ChatMessage[],
  groqMaxTokens: number,
  openaiMaxTokens: number,
  parse: (content: string) => T
): Promise<SafetyChatResult<T>> {
  if (GROQ_ENABLED) try {
    const groqKey = Deno.env.get("GROQ_API_KEY")
    if (!groqKey) throw new Error("GROQ_API_KEY not set")
    const controller = new AbortController()
    const timeout = setTimeout(() => controller.abort(), SAFETY_GROQ_TIMEOUT_MS)
    try {
      const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
        method: "POST",
        headers: { Authorization: `Bearer ${groqKey}`, "Content-Type": "application/json" },
        body: JSON.stringify({
          model: GROQ_MODEL,
          messages,
          // gpt-oss-120b is a reasoning model: it spends hidden tokens before its visible
          // answer, so this budget is much larger than the OpenAI one (only used tokens
          // are billed/counted). Low effort keeps that reasoning short.
          max_tokens: groqMaxTokens,
          temperature: 0,
          reasoning_effort: "low",
        }),
        signal: controller.signal,
      })
      if (!response.ok) throw new Error(`Groq safety call error ${response.status}: ${await response.text()}`)
      const data = await response.json()
      const content = data.choices?.[0]?.message?.content
      if (!content) throw new Error("Groq safety call returned no content")
      return { value: parse(content), usage: extractUsage(data), provider: "groq", model: GROQ_MODEL }
    } finally {
      clearTimeout(timeout)
    }
  } catch (groqError) {
    console.error("llm-proxy: Groq safety call failed, falling back to OpenAI --", groqError)
  }

  const apiKey = Deno.env.get("OPENAI_API_KEY")
  if (!apiKey) throw new Error("OPENAI_API_KEY not set")
  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), SAFETY_TIMEOUT_MS)
  try {
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" },
      body: JSON.stringify({
        model: SAFETY_MODEL,
        messages,
        max_tokens: openaiMaxTokens,
        temperature: 0,
        response_format: { type: "json_object" },
      }),
      signal: controller.signal,
    })
    if (!response.ok) throw new Error(`OpenAI safety call error ${response.status}: ${await response.text()}`)
    const data = await response.json()
    const content = data.choices?.[0]?.message?.content
    if (!content) throw new Error("OpenAI safety call returned no content")
    return { value: parse(content), usage: extractUsage(data), provider: "openai", model: SAFETY_MODEL }
  } finally {
    clearTimeout(timeout)
  }
}

async function classifyInput(
  messages: ChatMessage[],
  moderationHint: string
): Promise<{ classification: ReturnType<typeof parseClassificationJSON>; usage: TokenUsage; provider: "groq" | "openai"; model: string }> {
  const result = await safetyChat(
    buildInputClassifierMessages(messages, moderationHint),
    1000,
    200,
    (content) => parseClassificationJSON(extractJSONObject(content))
  )
  return { classification: result.value, usage: result.usage, provider: result.provider, model: result.model }
}

async function checkOutput(draftReply: string): Promise<{ safe: boolean; usage: TokenUsage; provider: "groq" | "openai"; model: string }> {
  const result = await safetyChat(
    [
      { role: "system", content: OUTPUT_CHECK_PROMPT },
      { role: "user", content: draftReply },
    ],
    600,
    20,
    (content) => {
      const parsed = JSON.parse(extractJSONObject(content)) as { safe?: boolean }
      if (typeof parsed.safe !== "boolean") throw new Error(`Output check returned no boolean safe field: ${content.slice(0, 200)}`)
      return parsed.safe
    }
  )
  return { safe: result.value, usage: result.usage, provider: result.provider, model: result.model }
}

// deno-lint-ignore no-explicit-any -- `createClient()` with no generics (same as every
// other call site in this file) infers a schema-less client whose `.from()`/`.rpc()`
// types collapse to `never` once passed through a reusable function signature
// (confirmed via `deno check`, not assumed) -- typed `any` deliberately here rather
// than fighting Supabase's generic inference for two tiny logging helpers.
type ServiceClient = any

async function logSafetyDiagnostic(serviceClient: ServiceClient, stage: "input" | "output", failureType: string, feature: string): Promise<void> {
  if (!SAFETY_DIAGNOSTICS_ENABLED) {
    // T-307: no retention policy has been approved yet -- console-only, no DB write,
    // until that's decided. See the constant's own comment above.
    console.error(`llm-proxy: safety diagnostic suppressed (SAFETY_DIAGNOSTICS_ENABLED=false) -- stage=${stage} failureType=${failureType} feature=${feature}`)
    return
  }
  try {
    await serviceClient.from("safety_diagnostics").insert({ stage, failure_type: failureType, feature })
  } catch (err) {
    console.error("llm-proxy: failed to log safety diagnostic (non-fatal):", err)
  }
}

async function bumpSafetyAggregate(serviceClient: ServiceClient, category: string): Promise<void> {
  try {
    const today = new Date().toISOString().slice(0, 10)
    await serviceClient.rpc("increment_safety_event", { p_date: today, p_category: category })
  } catch (err) {
    console.error("llm-proxy: failed to bump safety aggregate (non-fatal):", err)
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders })
  }
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!

    // Every call must come from an authenticated Dwelly user -- this proxy is not a
    // general-purpose open LLM endpoint, it's scoped to this app's own features.
    const authHeader = req.headers.get("Authorization")
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing Authorization header" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }
    const jwt = authHeader.replace("Bearer ", "")
    const authClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    })
    const { data: userData, error: userError } = await authClient.auth.getUser(jwt)
    if (userError || !userData?.user) {
      return new Response(JSON.stringify({ error: "Invalid or expired token" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }
    const userId = userData.user.id

    // Cost control: hard daily cap per user, checked before spending anything. T-304
    // point 4: this counts EVERY row logged via `deps.logUsage` below, which now
    // includes the safety classifier and output-check calls, not just the main
    // conversational reply -- so those real OpenAI calls count against this same cap
    // instead of being invisible to it.
    const todayStart = new Date()
    todayStart.setUTCHours(0, 0, 0, 0)
    const { count: todaysCallCount, error: countError } = await authClient
      .from("llm_usage")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .gte("created_at", todayStart.toISOString())
      // Safety-layer rows (classifier / output check) are logged for cost visibility but
      // are not counted toward the user's daily cap (Kell, Nov 21 2026).
      .not("feature", "like", "%safety%")

    if (countError) {
      console.error("llm-proxy: usage count check failed:", countError)
      // Fail open on a usage-table read error, not closed -- a logging problem
      // shouldn't take down the whole feature.
    } else if ((todaysCallCount ?? 0) >= DAILY_CALL_LIMIT) {
      return new Response(
        JSON.stringify({ error: `Daily limit reached (${DAILY_CALL_LIMIT} calls/day). Try again tomorrow.` }),
        { status: 429, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    const payload = (await req.json()) as LLMProxyRequest
    if (!payload.messages || !Array.isArray(payload.messages) || payload.messages.length === 0) {
      return new Response(JSON.stringify({ error: "messages (non-empty array) is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }
    if (!payload.feature) {
      return new Response(JSON.stringify({ error: "feature is required (e.g. 'capture_conversation')" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    const serviceClient = createClient(supabaseUrl, serviceRoleKey)

    const deps: ProxyDependencies = {
      callModeration,
      classifyInput,
      checkOutput,
      groqEnabled: GROQ_ENABLED,
      callGroq,
      callOpenAI,
      async logUsage({ feature, provider, model, usage }) {
        const { error: logError } = await authClient.from("llm_usage").insert({
          user_id: userId,
          feature,
          provider,
          model,
          prompt_tokens: usage.promptTokens,
          completion_tokens: usage.completionTokens,
          total_tokens: usage.totalTokens,
          // Written only after the additive migration adding llm_usage.cached_tokens is
          // applied (draft: migrations/20261123120000_*). Inserting an unknown column would
          // fail every usage insert, so this stays off until then.
          ...(LLM_USAGE_CACHED_COLUMN_READY ? { cached_tokens: usage.cachedTokens ?? null } : {}),
        })
        if (logError) console.error("llm-proxy: failed to log usage (non-fatal):", logError)
      },
      logSafetyDiagnostic: (stage, failureType, feature) => logSafetyDiagnostic(serviceClient, stage, failureType, feature),
      bumpSafetyAggregate: (category) => bumpSafetyAggregate(serviceClient, category),
      budgetEnforce: CAPTURE_BUDGET_ENFORCE,
      // Service-role RPCs bound to the AUTHENTICATED user id, so a capture_id can never
      // reach another user's ledger row.
      budget: CAPTURE_BUDGET_LEDGER_READY ? {
        async reserve(captureId, requestId, kind, amount) {
          const { data, error } = await serviceClient.rpc("reserve_capture_tokens", {
            p_user: userId, p_capture: captureId, p_request: requestId, p_kind: kind, p_amount: amount,
          })
          if (error) throw error
          const row = Array.isArray(data) ? data[0] : data
          return row.r_ok ? { ok: true as const, reserved: Number(row.r_reserved) } : { ok: false as const, spent: Number(row.r_spent), limit: Number(row.r_limit) }
        },
        async settle(captureId, requestId, actual) {
          const { error } = await serviceClient.rpc("settle_capture_tokens", {
            p_user: userId, p_capture: captureId, p_request: requestId, p_actual: actual,
          })
          if (error) throw error
        },
      } : undefined,
    }

    const result = await handleProxyRequest(payload, deps)
    return new Response(JSON.stringify(result.body), {
      status: result.status,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  } catch (error) {
    console.error("llm-proxy error:", error)
    const message = error instanceof Error ? error.message : String(error)
    return new Response(JSON.stringify({ error: "Internal server error", details: message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }
})

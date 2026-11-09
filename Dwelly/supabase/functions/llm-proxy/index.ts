// T-168: Shared LLM Proxy Service
//
// The one place in this entire app that calls an LLM. Every feature that needs one
// (P1 Capture's "Dwelly Responds" conversation, P3 Prayer generation, P4 Journal
// synthesis, eventually P6 Formation Intelligence) calls THIS endpoint instead of
// talking to a provider directly — so the API keys live in exactly one place, the
// provider/fallback logic is written exactly once, and swapping or adding a provider
// later touches one file, not every feature that uses an LLM.
//
// Locked provider decision (docs/FORMATION_INTELLIGENCE_STRATEGY.md): Groq Llama 3 70B
// is primary (free tier, superior for the poetic/narrative tone this product wants),
// OpenAI GPT-4o mini is the fallback if Groq errors or times out. This supersedes the
// older docs/LLM_RESEARCH.md Gemini recommendation (May 2026, written under the old
// client-side-E2E architecture that's since been superseded — see
// docs/PILLAR_2_SECURITY_STRATEGY.md's "Model Change" section).
//
// `feature` is required and logged, not just decoration — it's what lets later usage
// analysis answer "how much is Capture's conversation costing us vs. Prayer generation"
// without having to reverse-engineer it from raw request bodies.

import { createClient } from "jsr:@supabase/supabase-js"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, apikey",
}

type ChatMessage = { role: "system" | "user" | "assistant"; content: string }

interface LLMProxyRequest {
  messages: ChatMessage[]
  feature: string // e.g. "capture_conversation", "prayer_generation", "journal_synthesis"
  max_tokens?: number
  temperature?: number
}

interface LLMProxyResponse {
  content: string
  model: string
  provider: "groq" | "openai"
}

const GROQ_MODEL = "llama3-70b-8192"
const OPENAI_MODEL = "gpt-4o-mini"
const DEFAULT_MAX_TOKENS = 500
const DEFAULT_TEMPERATURE = 0.8
const GROQ_TIMEOUT_MS = 10_000

async function callGroq(messages: ChatMessage[], maxTokens: number, temperature: number): Promise<string> {
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
    return content
  } finally {
    clearTimeout(timeout)
  }
}

async function callOpenAI(messages: ChatMessage[], maxTokens: number, temperature: number): Promise<string> {
  const apiKey = Deno.env.get("OPENAI_API_KEY")
  if (!apiKey) throw new Error("OPENAI_API_KEY not set")

  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
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

  const data = await response.json()
  const content = data.choices?.[0]?.message?.content
  if (!content) throw new Error("OpenAI response missing choices[0].message.content")
  return content
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

    // Every call must come from an authenticated Dwelly user — this proxy is not a
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

    const maxTokens = payload.max_tokens ?? DEFAULT_MAX_TOKENS
    const temperature = payload.temperature ?? DEFAULT_TEMPERATURE

    let result: LLMProxyResponse
    try {
      const content = await callGroq(payload.messages, maxTokens, temperature)
      result = { content, model: GROQ_MODEL, provider: "groq" }
    } catch (groqError) {
      console.error(`llm-proxy [${payload.feature}]: Groq failed, falling back to OpenAI —`, groqError)
      try {
        const content = await callOpenAI(payload.messages, maxTokens, temperature)
        result = { content, model: OPENAI_MODEL, provider: "openai" }
      } catch (openaiError) {
        console.error(`llm-proxy [${payload.feature}]: OpenAI fallback also failed —`, openaiError)
        return new Response(
          JSON.stringify({ error: "Both LLM providers failed", groq: String(groqError), openai: String(openaiError) }),
          { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        )
      }
    }

    console.log(`llm-proxy [${payload.feature}]: served by ${result.provider}/${result.model}`)

    return new Response(JSON.stringify(result), {
      status: 200,
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

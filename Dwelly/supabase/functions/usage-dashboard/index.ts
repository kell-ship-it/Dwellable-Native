// T-168 follow-up: live token-usage dashboard (Kell's explicit ask, Nov 9 2026) --
// "I want to be able to see a live count of how many tokens I'm using in total between
// Grok (app-wide) and OpenAI." A plain HTML page, no app build needed to check it,
// auto-refreshing every 10s. Reads straight from public.llm_usage (now with real
// prompt/completion/total token counts from each provider's own `usage` block --
// see llm-proxy/index.ts) using the service role key, since this is Kell checking his
// own project's spend, not a per-user authenticated feature.

import { createClient } from "jsr:@supabase/supabase-js"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
}

interface ProviderTotals {
  calls: number
  promptTokens: number
  completionTokens: number
  totalTokens: number
}

function emptyTotals(): ProviderTotals {
  return { calls: 0, promptTokens: 0, completionTokens: 0, totalTokens: 0 }
}

// Kell's ask (Nov 10 2026): "a countdown to signal at one point I have to pay." Groq's
// free tier for openai/gpt-oss-120b (the current primary model, see llm-proxy) is
// published by Groq as 200,000 tokens/day, resetting daily -- confirmed via several
// third-party trackers citing Groq's own console limits page as of Nov 2026, not
// something the API itself exposes, so if Groq changes this, update the constant here
// (and check console.groq.com's own limits page, which is authoritative). OpenAI has
// no free tier at all -- every OpenAI call (the fallback whenever Groq errors, or once
// this budget is exhausted) bills immediately at $0.15/$0.60 per million tokens.
const GROQ_FREE_DAILY_TOKEN_BUDGET = 200_000

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    const client = createClient(supabaseUrl, serviceRoleKey)

    const { data, error } = await client
      .from("llm_usage")
      .select("provider, prompt_tokens, completion_tokens, total_tokens, created_at")
      .order("created_at", { ascending: false })
      .limit(5000)

    if (error) throw error

    const todayStart = new Date()
    todayStart.setUTCHours(0, 0, 0, 0)

    const totals: Record<string, ProviderTotals> = { groq: emptyTotals(), openai: emptyTotals() }
    const today: Record<string, ProviderTotals> = { groq: emptyTotals(), openai: emptyTotals() }

    for (const row of data ?? []) {
      const bucket = totals[row.provider] ?? (totals[row.provider] = emptyTotals())
      bucket.calls += 1
      bucket.promptTokens += row.prompt_tokens ?? 0
      bucket.completionTokens += row.completion_tokens ?? 0
      bucket.totalTokens += row.total_tokens ?? 0

      if (new Date(row.created_at) >= todayStart) {
        const todayBucket = today[row.provider] ?? (today[row.provider] = emptyTotals())
        todayBucket.calls += 1
        todayBucket.promptTokens += row.prompt_tokens ?? 0
        todayBucket.completionTokens += row.completion_tokens ?? 0
        todayBucket.totalTokens += row.total_tokens ?? 0
      }
    }

    const grandTotalTokens = Object.values(totals).reduce((sum, t) => sum + t.totalTokens, 0)
    const grandTotalCalls = Object.values(totals).reduce((sum, t) => sum + t.calls, 0)

    const groqTokensToday = today.groq?.totalTokens ?? 0
    const groqTokensRemaining = Math.max(0, GROQ_FREE_DAILY_TOKEN_BUDGET - groqTokensToday)
    const tomorrowUTC = new Date(Date.UTC(
      new Date().getUTCFullYear(), new Date().getUTCMonth(), new Date().getUTCDate() + 1
    ))
    const freeTierBudget = {
      dailyBudget: GROQ_FREE_DAILY_TOKEN_BUDGET,
      usedToday: groqTokensToday,
      remainingToday: groqTokensRemaining,
      percentUsed: Math.min(100, Math.round((groqTokensToday / GROQ_FREE_DAILY_TOKEN_BUDGET) * 100)),
      resetsAt: tomorrowUTC.toISOString(),
      resetsInSeconds: Math.max(0, Math.round((tomorrowUTC.getTime() - Date.now()) / 1000)),
    }

    const url = new URL(req.url)
    if (url.searchParams.get("format") === "json") {
      return new Response(JSON.stringify({ totals, today, grandTotalTokens, grandTotalCalls, freeTierBudget }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    const fmt = (n: number) => n.toLocaleString("en-US")
    const providerCard = (name: string, label: string, color: string, t: ProviderTotals, todayT: ProviderTotals) => `
      <div class="card">
        <div class="card-header"><span class="dot" style="background:${color}"></span>${label}</div>
        <div class="big">${fmt(t.totalTokens)}</div>
        <div class="sub">total tokens - ${fmt(t.calls)} calls</div>
        <div class="row"><span>Today</span><span>${fmt(todayT.totalTokens)} tok / ${fmt(todayT.calls)} calls</span></div>
        <div class="row"><span>Prompt tokens</span><span>${fmt(t.promptTokens)}</span></div>
        <div class="row"><span>Completion tokens</span><span>${fmt(t.completionTokens)}</span></div>
      </div>`

    const html = `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="refresh" content="10">
  <title>Dwelly LLM Usage</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, 'SF Pro Text', sans-serif; background: #0b0a08; color: #f5f5f7; padding: 24px; }
    h1 { font-size: 20px; font-weight: 600; margin-bottom: 4px; }
    .subtitle { color: #857d69; font-size: 13px; margin-bottom: 24px; }
    .grand { display: flex; gap: 24px; margin-bottom: 24px; }
    .grand .stat { background: #161618; border: 1px solid #2c2c2e; border-radius: 14px; padding: 16px 20px; flex: 1; }
    .grand .stat .label { color: #857d69; font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; }
    .grand .stat .value { font-size: 28px; font-weight: 700; margin-top: 4px; color: #aa925c; }
    .cards { display: flex; gap: 16px; flex-wrap: wrap; }
    .card { background: #161618; border: 1px solid #2c2c2e; border-radius: 14px; padding: 20px; min-width: 260px; flex: 1; }
    .card-header { display: flex; align-items: center; gap: 8px; font-size: 13px; font-weight: 600; margin-bottom: 12px; }
    .dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; }
    .big { font-size: 32px; font-weight: 700; }
    .sub { color: #857d69; font-size: 12px; margin-bottom: 16px; }
    .row { display: flex; justify-content: space-between; font-size: 12px; color: #b4ac9b; padding: 4px 0; border-top: 1px solid #2c2c2e; }
    .refresh-note { color: #555; font-size: 11px; margin-top: 24px; }
    .budget { background: #161618; border: 1px solid #2c2c2e; border-radius: 14px; padding: 20px; margin-bottom: 16px; }
    .budget-header { display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 10px; }
    .budget-header .title { font-size: 13px; font-weight: 600; }
    .budget-header .resets { font-size: 11px; color: #857d69; }
    .bar-track { height: 10px; background: #2c2c2e; border-radius: 5px; overflow: hidden; }
    .bar-fill { height: 100%; background: linear-gradient(90deg, #4ec9b0, #aa925c); }
    .budget-foot { display: flex; justify-content: space-between; font-size: 12px; color: #b4ac9b; margin-top: 8px; }
  </style>
</head>
<body>
  <h1>Dwelly LLM Usage</h1>
  <div class="subtitle">Live token counts from public.llm_usage -- auto-refreshes every 10s</div>
  <div class="budget">
    <div class="budget-header">
      <span class="title">Groq free tier -- resets daily</span>
      <span class="resets">resets in ${Math.floor(freeTierBudget.resetsInSeconds / 3600)}h ${Math.floor((freeTierBudget.resetsInSeconds % 3600) / 60)}m</span>
    </div>
    <div class="bar-track"><div class="bar-fill" style="width:${freeTierBudget.percentUsed}%"></div></div>
    <div class="budget-foot">
      <span>${fmt(freeTierBudget.usedToday)} / ${fmt(freeTierBudget.dailyBudget)} tokens used today</span>
      <span>${fmt(freeTierBudget.remainingToday)} left before OpenAI billing kicks in</span>
    </div>
  </div>
  <div class="grand">
    <div class="stat"><div class="label">Total tokens (all time)</div><div class="value">${fmt(grandTotalTokens)}</div></div>
    <div class="stat"><div class="label">Total calls (all time)</div><div class="value">${fmt(grandTotalCalls)}</div></div>
  </div>
  <div class="cards">
    ${providerCard("groq", "Groq (gpt-oss-120b)", "#4ec9b0", totals.groq ?? emptyTotals(), today.groq ?? emptyTotals())}
    ${providerCard("openai", "OpenAI (GPT-4o mini)", "#aa925c", totals.openai ?? emptyTotals(), today.openai ?? emptyTotals())}
  </div>
  <div class="refresh-note">Last loaded: ${new Date().toLocaleString()}</div>
</body>
</html>`

    return new Response(html, { headers: { ...corsHeaders, "Content-Type": "text/html; charset=utf-8" } })
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error)
    return new Response(`<pre>usage-dashboard error: ${message}</pre>`, {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "text/html; charset=utf-8" },
    })
  }
})

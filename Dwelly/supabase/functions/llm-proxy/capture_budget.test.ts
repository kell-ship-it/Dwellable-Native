// Run: /tmp/deno-local/bin/deno test --no-npm capture_budget.test.ts
// The in-memory ledger below mirrors the SQL functions' semantics (draft migration);
// it proves the handler's contract, NOT the SQL itself (no Postgres available locally).
import { assertEquals } from "jsr:@std/assert"
import { handleProxyRequest, type LLMProxyRequest, type ProxyDependencies } from "./handler.ts"
import { type BudgetLedger, type CaptureKind, limitFor, reserveEstimate, type ReserveResult } from "./budget.ts"
import { INPUT_CLASSIFIER_PROMPT, OUTPUT_CHECK_PROMPT } from "./handler.ts"

type Row = { kind: CaptureKind; limit: number; spent: number; reserved: number; reqs: Map<string, { state: "reserved" | "settled"; amount: number }> }

class MemLedger implements BudgetLedger {
  caps = new Map<string, Row>()
  failReserve = false
  async reserve(c: string, r: string, kind: CaptureKind, amount: number): Promise<ReserveResult> {
    if (this.failReserve) throw new Error("db down")
    let row = this.caps.get(c)
    if (!row) { row = { kind, limit: limitFor(kind), spent: 0, reserved: 0, reqs: new Map() }; this.caps.set(c, row) }
    const ex = row.reqs.get(r)
    if (ex && ex.state === "reserved") return { ok: true, reserved: ex.amount } // same reservation, no double count
    if (row.spent + row.reserved + amount > row.limit) return { ok: false, spent: row.spent + row.reserved, limit: row.limit }
    row.reserved += amount
    row.reqs.set(r, { state: "reserved", amount })
    return { ok: true, reserved: amount }
  }
  async settle(c: string, r: string, actual: number): Promise<void> {
    const row = this.caps.get(c)
    const ex = row?.reqs.get(r)
    if (!row || !ex || ex.state !== "reserved") return // idempotent
    row.reserved -= ex.amount
    row.spent += actual
    ex.state = "settled"
  }
}

const u = (n: number | null) => ({ promptTokens: null, completionTokens: null, totalTokens: n })
function deps(ledger: MemLedger | undefined, enforce: boolean, over: Partial<ProxyDependencies> = {}): { d: ProxyDependencies; calls: { main: number } } {
  const calls = { main: 0 }
  const d: ProxyDependencies = {
    callModeration: async () => ({ flagged: false, summary: "none" }),
    classifyInput: async () => ({ classification: { action: "normal", clarifyQuestion: null }, usage: u(100) }),
    checkOutput: async () => ({ safe: true, usage: u(10) }),
    callGroq: async () => ({ content: "x", usage: u(500) }),
    callOpenAI: async () => { calls.main++; return { content: "reply", usage: u(500) } },
    logUsage: async () => {},
    logSafetyDiagnostic: async () => {},
    bumpSafetyAggregate: async () => {},
    groqEnabled: false,
    budget: ledger,
    budgetEnforce: enforce,
    ...over,
  }
  return { d, calls }
}
const req = (extra: Partial<LLMProxyRequest> = {}): LLMProxyRequest => ({
  feature: "capture_conversation",
  messages: [{ role: "system", content: "persona" }, { role: "user", content: "hello there" }],
  capture_id: "cap-12345678", request_id: "req-12345678", capture_kind: "regular", ...extra,
})

Deno.test("reserve then settle to the provider-reported spend (610), reservation released", async () => {
  const l = new MemLedger(); const { d } = deps(l, true)
  const r = await handleProxyRequest(req(), d)
  assertEquals(r.status, 200)
  const row = l.caps.get("cap-12345678")!
  assertEquals(row.spent, 610); assertEquals(row.reserved, 0)
})

Deno.test("over-budget capture is refused (429) BEFORE any paid call", async () => {
  const l = new MemLedger(); const { d, calls } = deps(l, true)
  l.caps.set("cap-12345678", { kind: "onboarding", limit: 30_000, spent: 29_990, reserved: 0, reqs: new Map() })
  const r = await handleProxyRequest(req({ capture_kind: "regular" }), d)
  assertEquals(r.status, 429)
  assertEquals(calls.main, 0)
})

Deno.test("limit is fixed at first reservation: a later 'regular' kind cannot raise an onboarding capture", async () => {
  const l = new MemLedger(); const { d } = deps(l, true)
  await handleProxyRequest(req({ capture_kind: "onboarding", request_id: "req-00000001" }), d)
  await handleProxyRequest(req({ capture_kind: "regular", request_id: "req-00000002" }), d)
  assertEquals(l.caps.get("cap-12345678")!.limit, 30_000)
})

Deno.test("restart/reinstall cannot reset the allowance: same capture_id keeps its spend", async () => {
  const l = new MemLedger(); const { d } = deps(l, true)
  await handleProxyRequest(req({ request_id: "req-00000001" }), d)
  await handleProxyRequest(req({ request_id: "req-00000002" }), d) // 'restarted' client, same capture
  assertEquals(l.caps.get("cap-12345678")!.spent, 1220)
})

Deno.test("concurrent sends cannot both pass the last sliver of budget", async () => {
  const l = new MemLedger(); const { d, calls } = deps(l, true)
  l.caps.set("cap-12345678", { kind: "onboarding", limit: 30_000, spent: 0, reserved: 0, reqs: new Map() })
  // Room for exactly one reservation: measure it via the estimator the handler uses.
  const need = reserveEstimate({ messagesText: ["persona", "hello there"], maxTokens: 1000, isCaptureConversation: true, classifierPrompt: INPUT_CLASSIFIER_PROMPT, outputCheckPrompt: OUTPUT_CHECK_PROMPT })
  l.caps.get("cap-12345678")!.spent = 30_000 - Math.ceil(need * 1.5)
  const [a, b] = await Promise.all([
    handleProxyRequest(req({ request_id: "req-conc0001" }), d),
    handleProxyRequest(req({ request_id: "req-conc0002" }), d),
  ])
  assertEquals([a.status, b.status].sort(), [200, 429])
  assertEquals(calls.main, 1)
})

Deno.test("same request_id while still reserved is the SAME reservation (no double count)", async () => {
  const l = new MemLedger()
  const first = await l.reserve("cap-12345678", "req-12345678", "regular", 3000)
  const second = await l.reserve("cap-12345678", "req-12345678", "regular", 3000)
  assertEquals(first.ok && second.ok, true)
  assertEquals(l.caps.get("cap-12345678")!.reserved, 3000)
})

Deno.test("unknown calls: settle never goes BELOW the reservation (unknown != zero)", async () => {
  const l = new MemLedger()
  const { d } = deps(l, true, { classifyInput: async () => { throw new Error("timeout") } })
  const r = await handleProxyRequest(req(), d)
  assertEquals(r.status, 200) // fail-closed fallback tier, still a response
  const row = l.caps.get("cap-12345678")!
  assertEquals(row.reserved, 0)
  assertEquals(row.spent > 600, true) // charged the reservation, not just the 0 reported
})

Deno.test("invalid, missing-part, or absent ids are rejected when enforcing; never silently dropped", async () => {
  const l = new MemLedger(); const { d } = deps(l, true)
  assertEquals((await handleProxyRequest(req({ capture_id: "short" }), d)).status, 400)
  assertEquals((await handleProxyRequest(req({ request_id: "bad id with spaces" }), d)).status, 400)
  assertEquals((await handleProxyRequest(req({ capture_kind: "huge" as CaptureKind }), d)).status, 400)
  const noIds: LLMProxyRequest = { feature: "capture_conversation", messages: [{ role: "user", content: "hi" }] }
  assertEquals((await handleProxyRequest(noIds, d)).status, 400) // enforcing: capture_conversation needs ids
})

Deno.test("not enforcing: old clients without ids pass through unchanged; no ledger writes", async () => {
  const l = new MemLedger(); const { d } = deps(l, false)
  const noIds: LLMProxyRequest = { feature: "capture_conversation", messages: [{ role: "user", content: "hi" }] }
  assertEquals((await handleProxyRequest(noIds, d)).status, 200)
  assertEquals(l.caps.size, 0)
})

Deno.test("ledger outage fails CLOSED (503) with no paid call", async () => {
  const l = new MemLedger(); l.failReserve = true
  const { d, calls } = deps(l, true)
  assertEquals((await handleProxyRequest(req(), d)).status, 503)
  assertEquals(calls.main, 0)
})

Deno.test("non-capture features with ids (synthesis/profile) reserve and settle on the same capture", async () => {
  const l = new MemLedger(); const { d } = deps(l, true)
  const r = await handleProxyRequest({ feature: "journal_synthesis", max_tokens: 1500, messages: [{ role: "user", content: "convo" }], capture_id: "cap-12345678", request_id: "req-synth0001", capture_kind: "regular" }, d)
  assertEquals(r.status, 200)
  assertEquals(l.caps.get("cap-12345678")!.spent, 500)
})

Deno.test("no ledger configured (migration not applied): ids are ignored, nothing breaks", async () => {
  const { d } = deps(undefined, true)
  assertEquals((await handleProxyRequest(req(), d)).status, 200)
})

Deno.test("client-shaped ids (cap-UUID, req-UUID, cap-UUID-synthesis/-profile) are valid", async () => {
  const { isValidId } = await import("./budget.ts")
  const cap = "cap-" + crypto.randomUUID().toUpperCase()
  for (const id of [cap, "req-" + crypto.randomUUID().toUpperCase(), `${cap}-synthesis`, `${cap}-profile`]) assertEquals(isValidId(id), true)
  assertEquals(isValidId(""), false)
  assertEquals(isValidId("a".repeat(101)), false)
})

Deno.test("REGRESSION (seen live): a realistic first turn reserves close to its real cost, never near the onboarding limit", async () => {
  // Real turn: ~11.5k-char persona + guardrails + one short user message + time note. Measured actual: 4,270 tokens.
  const sys = "x".repeat(11_500), guard = "y".repeat(800), time = "z".repeat(200)
  const need = reserveEstimate({
    messagesText: [sys, guard, "A short first message", time],
    conversationText: ["A short first message"],
    maxTokens: 1000, isCaptureConversation: true,
    classifierPrompt: INPUT_CLASSIFIER_PROMPT, outputCheckPrompt: OUTPUT_CHECK_PROMPT,
  })
  assertEquals(need > 4_270, true, "must not under-reserve the real cost")
  assertEquals(need < 12_000, true, `reserved ${need}; the old estimator reserved 34,062`)
  // and several turns still fit an onboarding capture
  assertEquals(need * 3 < 30_000, true)
})

Deno.test("estimator: English ~3 chars/token, non-ASCII counted at 2/char (CJK, emoji)", async () => {
  const { estimateTokens } = await import("./budget.ts")
  assertEquals(estimateTokens("abc"), 1)
  assertEquals(estimateTokens("a".repeat(3000)), 1000)
  assertEquals(estimateTokens("我今天很累"), 10)
  assertEquals(estimateTokens("😂"), 2)
})

Deno.test("server input cap: a user message over 2,000 characters is rejected (413) BEFORE any call or reservation", async () => {
  const { handleProxyRequest: h, MAX_USER_MESSAGE_CHARS } = await import("./handler.ts")
  const l = new MemLedger(); const { d, calls } = deps(l, true)
  const big = (n: number) => ({ feature: "capture_conversation", messages: [{ role: "system" as const, content: "p" }, { role: "user" as const, content: "a".repeat(n) }], capture_id: "cap-12345678", request_id: "req-12345678", capture_kind: "regular" as const })
  const over = await h(big(MAX_USER_MESSAGE_CHARS + 1), d)
  assertEquals(over.status, 413)
  assertEquals(calls.main, 0)
  assertEquals(l.caps.size, 0) // nothing reserved either
  assertEquals((await h(big(MAX_USER_MESSAGE_CHARS), d)).status, 200) // exactly 2,000 passes
})

Deno.test("server input cap counts user-perceived characters, like the app: 2,000 emoji pass, 2,001 fail; system text is not capped; other features unaffected", async () => {
  const { handleProxyRequest: h } = await import("./handler.ts")
  const { d } = deps(undefined, false)
  const mk = (content: string, role: "user" | "system" = "user", feature = "capture_conversation") =>
    ({ feature, messages: [{ role, content }] })
  const family = "👨‍👩‍👧" // 1 grapheme, 8 UTF-16 units
  assertEquals((await h(mk(family.repeat(2000)), d)).status, 200)
  assertEquals((await h(mk(family.repeat(2001)), d)).status, 413)
  assertEquals((await h(mk("x".repeat(12_000), "system"), d)).status, 200) // 11.5k-char persona prompt is fine
  assertEquals((await h(mk("x".repeat(5000), "user", "journal_synthesis"), d)).status, 200) // synthesis transcript is not a typed message
})

Deno.test("COPY PARITY: the server's fixed onboarding hand-off equals the app's closingMessage, character for character", async () => {
  const { ONBOARDING_FINAL_CLOSER } = await import("./handler.ts")
  const swift = await Deno.readTextFile(new URL("../../../Dwelly/Views/CaptureConversationView.swift", import.meta.url))
  const m = swift.match(/private let closingMessage = "((?:[^"\\]|\\.)*)"/)
  assertEquals(m !== null, true, "closingMessage constant not found in the Swift view")
  assertEquals(m![1], ONBOARDING_FINAL_CLOSER)
})

Deno.test("finishing calls (journal synthesis, profile) are NEVER refused by the cap; ordinary turns still are", async () => {
  const mkFinish = (feature: string, id: string) => ({ feature, max_tokens: 1500, messages: [{ role: "user" as const, content: "convo" }], capture_id: "cap-12345678", request_id: id, capture_kind: "regular" as const })
  const l = new MemLedger(); const { d, calls } = deps(l, true)
  l.caps.set("cap-12345678", { kind: "regular", limit: 100_000, spent: 99_900, reserved: 0, reqs: new Map() })
  // an ordinary turn would be refused here
  assertEquals((await handleProxyRequest(req({ request_id: "req-turn00001" }), d)).status, 429)
  // but synthesis and profile go through. The first one's real spend (500) is recorded and pushes the capture
  // OVER its limit; the second then runs untracked (known small gap: finishing is never blocked, so it is not
  // always counted once the capture is already over).
  const synth = await handleProxyRequest(mkFinish("journal_synthesis", "req-synth0001"), d)
  const prof = await handleProxyRequest(mkFinish("dweller_profile_summary", "req-prof00001"), d)
  assertEquals([synth.status, prof.status], [200, 200])
  assertEquals(l.caps.get("cap-12345678")!.spent, 99_900 + 500)
  assertEquals(calls.main, 2)
  // already OVER the limit: finishing still works (untracked), an ordinary turn is still refused
  l.caps.get("cap-12345678")!.spent = 100_500
  assertEquals((await handleProxyRequest(mkFinish("journal_synthesis", "req-synth0002"), d)).status, 200)
  assertEquals((await handleProxyRequest(req({ request_id: "req-turn00002" }), d)).status, 429)
})

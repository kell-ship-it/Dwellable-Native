// Run: /tmp/deno-local/bin/deno test --no-npm supabase/functions/usage-dashboard/capture.test.ts
import { assertEquals } from "jsr:@std/assert"
import { summarizeLastCapture, type UsageRow } from "./capture.ts"

const row = (feature: string, created_at: string, p: number, c: number, provider = "openai"): UsageRow => ({
  provider, feature, prompt_tokens: p, completion_tokens: c, total_tokens: p + c, created_at,
})
const CL = "capture_conversation_safety_classifier"
const OC = "capture_conversation_safety_output_check"
const MR = "capture_conversation"

// Real rows from the 9:32 am (CST) Nov 23 capture, oldest -> newest.
const real: UsageRow[] = [
  row(CL, "2026-11-23T15:32:25Z", 1133, 13), row(OC, "2026-11-23T15:32:27Z", 150, 5), row(MR, "2026-11-23T15:32:27Z", 2736, 25),
  row(CL, "2026-11-23T15:32:41Z", 1175, 13), row(OC, "2026-11-23T15:32:43Z", 156, 5), row(MR, "2026-11-23T15:32:44Z", 2778, 31),
  row(CL, "2026-11-23T15:33:00Z", 1226, 13), row(OC, "2026-11-23T15:33:02Z", 159, 5), row(MR, "2026-11-23T15:33:02Z", 2829, 34),
  row("journal_synthesis", "2026-11-23T15:33:15Z", 855, 91), row("dweller_profile_summary", "2026-11-23T15:33:17Z", 305, 65),
]
const desc = (rs: UsageRow[]) => [...rs].reverse()

Deno.test("real saved 3-send capture: 11 calls, 13,802 tokens, stage split matches the ledger", () => {
  const c = summarizeLastCapture(desc(real))!
  assertEquals(c.totals.calls, 11)
  assertEquals(c.totals.promptTokens, 13502)
  assertEquals(c.totals.completionTokens, 300)
  assertEquals(c.totals.totalTokens, 13802)
  assertEquals(c.turns, 3)
  assertEquals(c.saved, true)
  assertEquals(c.stages.classifier!.totalTokens, 3573)
  assertEquals(c.stages.mainReply!.totalTokens, 8433)
  assertEquals(c.stages.outputCheck!.totalTokens, 480)
  assertEquals(c.stages.journalSynthesis!.totalTokens, 946)
  assertEquals(c.stages.profileSummary!.totalTokens, 370)
  assertEquals(c.startedAt, "2026-11-23T15:32:25.000Z")
  assertEquals(c.endedAt, "2026-11-23T15:33:17.000Z")
})

Deno.test("an earlier saved capture is not merged in (previous save row is the boundary)", () => {
  const earlier: UsageRow[] = [
    row(CL, "2026-11-23T15:29:01Z", 1126, 13), row(OC, "2026-11-23T15:29:03Z", 132, 5), row(MR, "2026-11-23T15:29:03Z", 2729, 7),
    row("journal_synthesis", "2026-11-23T15:29:43Z", 804, 75), row("dweller_profile_summary", "2026-11-23T15:29:46Z", 291, 64),
  ]
  const c = summarizeLastCapture(desc([...earlier, ...real]))!
  assertEquals(c.totals.calls, 11)
  assertEquals(c.turns, 3)
})

Deno.test("unsaved capture in progress: only Sends, saved=false", () => {
  const c = summarizeLastCapture(desc(real.slice(0, 6)))!
  assertEquals(c.totals.calls, 6)
  assertEquals(c.turns, 2)
  assertEquals(c.saved, false)
})

Deno.test("a long pause (>30 min) between Sends splits captures", () => {
  const old = [row(CL, "2026-11-23T10:00:00Z", 1000, 13), row(MR, "2026-11-23T10:00:03Z", 2500, 20)]
  const c = summarizeLastCapture(desc([...old, ...real.slice(0, 3)]))!
  assertEquals(c.totals.calls, 3)
})

Deno.test("a long gap between the last Send and the save is still one capture", () => {
  const rows = [...real.slice(0, 3),
    row("journal_synthesis", "2026-11-23T16:28:00Z", 855, 91), row("dweller_profile_summary", "2026-11-23T16:28:03Z", 305, 65)]
  const c = summarizeLastCapture(desc(rows))!
  assertEquals(c.totals.calls, 5)
  assertEquals(c.saved, true)
})

Deno.test("no capture rows -> null; unrelated features are ignored", () => {
  assertEquals(summarizeLastCapture([]), null)
  assertEquals(summarizeLastCapture([row("prayer_generation", "2026-11-23T15:00:00Z", 100, 10)]), null)
})

import { assert, assertEquals, assertNotEquals } from "jsr:@std/assert"
import { buildJournalRow, toClientJournalRow, toClientProfileRow, encryptToJson } from "./journal_codec.ts"

Deno.env.set("MOMENT_ENCRYPTION_KEY", btoa(String.fromCharCode(...new Uint8Array(32).fill(7))))

const base = { id: "e1", moment_id: "m1", status: "approved", created_at: "2026-11-23T00:00:00Z" }

Deno.test("buildJournalRow encrypts body, never writes plaintext, uses JWT user", async () => {
  const row = await buildJournalRow({ ...base, body: "secret words", title: "T", moods: ["a"] }, "user-from-jwt")
  assertEquals(row.user_id, "user-from-jwt")
  assert(!("body" in row))
  assert(!JSON.stringify(row).includes("secret words"))
  assertEquals(row.title, "T")
})

Deno.test("round trip restores body and strips ciphertext + join extras", async () => {
  const row = await buildJournalRow({ ...base, body: "héllo ✝️ world" }, "u")
  const client = await toClientJournalRow({ ...row, moments: { deleted_at: null } })
  assertEquals(client.body, "héllo ✝️ world")
  assert(!("body_encrypted" in client))
  assert(!("moments" in client))
})

Deno.test("empty body clears plaintext and ciphertext", async () => {
  const row = await buildJournalRow({ ...base, body: null }, "u")
  assertEquals(row.body, null)
  assertEquals(row.body_encrypted, null)
})

Deno.test("legacy plaintext row still readable before backfill", async () => {
  const client = await toClientJournalRow({ id: "x", body: "old", body_encrypted: null })
  assertEquals(client.body, "old")
})

Deno.test("profile round trip + profile_excluded only when true", async () => {
  const p = await encryptToJson("summary text")
  const c = await toClientProfileRow({ user_id: "u", running_summary: null, running_summary_encrypted: p })
  assertEquals(c.running_summary, "summary text")
  const r1 = await buildJournalRow({ ...base, profile_excluded: false }, "u")
  assert(!("profile_excluded" in r1))
  const r2 = await buildJournalRow({ ...base, profile_excluded: true }, "u")
  assertEquals(r2.profile_excluded, true)
})

Deno.test("ciphertext differs per call (unique IV)", async () => {
  const a = await encryptToJson("same")
  const b = await encryptToJson("same")
  assertNotEquals(a.encryptionIv, b.encryptionIv)
})

Deno.test("extracted_facts encrypted, never plaintext, round trips; empty clears both", async () => {
  const row = await buildJournalRow({ ...base, body: "b", extracted_facts: "likes quiet mornings" }, "u")
  assert(!("extracted_facts" in row))
  assert(!JSON.stringify(row).includes("quiet mornings"))
  const client = await toClientJournalRow(row)
  assertEquals(client.extracted_facts, "likes quiet mornings")
  assert(!("extracted_facts_encrypted" in client))
  const empty = await buildJournalRow({ ...base, extracted_facts: null }, "u")
  assertEquals(empty.extracted_facts, null)
  assertEquals(empty.extracted_facts_encrypted, null)
  const legacy = await toClientJournalRow({ id: "x", body: null, extracted_facts: "old facts" })
  assertEquals(legacy.extracted_facts, "old facts")
})

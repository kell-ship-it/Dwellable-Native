// Replaces direct POST /rest/v1/journal_entries. Encrypts `body` server-side
// (AES-256-GCM, same key as save-moment); user_id comes from the verified JWT.
// Returns the saved row in the shape the app already decodes (plaintext body).
import { authenticate, corsHeaders, json, serviceClient } from "../_shared/auth.ts"
import { buildJournalRow, type JournalWriteInput, toClientJournalRow } from "../_shared/journal_codec.ts"

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: corsHeaders })
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405)
  try {
    const auth = await authenticate(req)
    if ("error" in auth) return auth.error
    const input = (await req.json()) as JournalWriteInput
    if (!input.id || !input.moment_id || !input.status || !input.created_at) {
      return json({ error: "Missing required fields: id, moment_id, status, created_at" }, 400)
    }
    const row = await buildJournalRow(input, auth.userId)
    const { data, error } = await serviceClient()
      .from("journal_entries")
      .upsert(row, { onConflict: "moment_id" })
      .select("*")
    if (error || !data?.[0]) {
      console.error("save-journal-entry DB error:", error)
      return json({ error: "Failed to save journal entry" }, 500)
    }
    return json(await toClientJournalRow(data[0]))
  } catch (e) {
    console.error("save-journal-entry error:", e)
    return json({ error: "Internal server error" }, 500)
  }
})

// Replaces direct GET /rest/v1/journal_entries. Decrypts body server-side.
//   ?moment_id=<id>      -> array with that moment's entry
//   ?status=pending      -> user's pending entries
//   ?status=approved     -> user's approved entries whose moment is not soft-deleted
import { authenticate, corsHeaders, json, serviceClient } from "../_shared/auth.ts"
import { toClientJournalRow } from "../_shared/journal_codec.ts"

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: corsHeaders })
  if (req.method !== "GET") return json({ error: "Method not allowed" }, 405)
  try {
    const auth = await authenticate(req)
    if ("error" in auth) return auth.error
    const url = new URL(req.url)
    const momentId = url.searchParams.get("moment_id")
    const status = url.searchParams.get("status")

    let query
    if (momentId) {
      query = serviceClient().from("journal_entries").select("*").eq("user_id", auth.userId).eq("moment_id", momentId)
    } else if (status === "pending") {
      query = serviceClient().from("journal_entries").select("*").eq("user_id", auth.userId).eq("status", "pending")
    } else if (status === "approved") {
      query = serviceClient()
        .from("journal_entries")
        .select("*, moments!inner(deleted_at)")
        .eq("user_id", auth.userId)
        .eq("status", "approved")
        .is("moments.deleted_at", null)
    } else {
      return json({ error: "Provide moment_id or status=pending|approved" }, 400)
    }
    const { data, error } = await query
    if (error) {
      console.error("fetch-journal-entries DB error:", error)
      return json({ error: "Failed to fetch journal entries" }, 500)
    }
    return json(await Promise.all((data ?? []).map(toClientJournalRow)))
  } catch (e) {
    console.error("fetch-journal-entries error:", e)
    return json({ error: "Internal server error" }, 500)
  }
})

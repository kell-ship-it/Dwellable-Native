// Replaces direct /rest/v1/dweller_profiles access. Summary is encrypted at rest.
//   GET   -> the caller's profile as a one-element array (or [])
//   POST  -> {running_summary, updated_at} upsert, returns the profile object
//   PATCH -> stamps confirmed_at, returns the profile object
import { authenticate, corsHeaders, json, serviceClient } from "../_shared/auth.ts"
import { encryptToJson, toClientProfileRow } from "../_shared/journal_codec.ts"

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: corsHeaders })
  try {
    const auth = await authenticate(req)
    if ("error" in auth) return auth.error
    const db = serviceClient()

    if (req.method === "GET") {
      const { data, error } = await db.from("dweller_profiles").select("*").eq("user_id", auth.userId)
      if (error) return json({ error: "Failed to fetch profile" }, 500)
      return json(await Promise.all((data ?? []).map(toClientProfileRow)))
    }
    if (req.method === "POST") {
      const input = (await req.json()) as { running_summary?: string | null; updated_at?: string }
      const row: Record<string, unknown> = {
        user_id: auth.userId,
        updated_at: input.updated_at ?? new Date().toISOString(),
      }
      if (input.running_summary) {
        row.running_summary_encrypted = await encryptToJson(input.running_summary)
      } else {
        row.running_summary_encrypted = null
        row.running_summary = null
      }
      const { data, error } = await db.from("dweller_profiles").upsert(row, { onConflict: "user_id" }).select("*")
      if (error || !data?.[0]) {
        console.error("dweller-profile save error:", error)
        return json({ error: "Failed to save profile" }, 500)
      }
      return json(await toClientProfileRow(data[0]))
    }
    if (req.method === "PATCH") {
      const { data, error } = await db
        .from("dweller_profiles")
        .update({ confirmed_at: new Date().toISOString() })
        .eq("user_id", auth.userId)
        .select("*")
      if (error || !data?.[0]) return json({ error: "Profile not found" }, 404)
      return json(await toClientProfileRow(data[0]))
    }
    return json({ error: "Method not allowed" }, 405)
  } catch (e) {
    console.error("dweller-profile error:", e)
    return json({ error: "Internal server error" }, 500)
  }
})

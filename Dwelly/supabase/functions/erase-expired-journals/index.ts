// Nov 27 2026 (Kell): erase journals 60 days after they were deleted, INCLUDING
// their journal photo. Called nightly by pg_cron via
// pg_net. Not a user-facing endpoint: the caller must send the secret kept in
// private.cron_secrets, which only the service role can read.
import { createClient } from "jsr:@supabase/supabase-js"

Deno.serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  )

  const { data: secret, error: secretErr } = await supabase
    .rpc("cron_secret", { p_name: "erase-expired-journals" })
  const sent = req.headers.get("x-cron-secret") ?? ""
  if (secretErr || typeof secret !== "string" || sent.length === 0 || sent !== secret) {
    return new Response("forbidden", { status: 403 })
  }

  const cutoff = new Date(Date.now() - 60 * 24 * 60 * 60 * 1000).toISOString()
  const { data: due, error: dueErr } = await supabase
    .from("moments").select("id, user_id")
    .not("deleted_at", "is", null).lt("deleted_at", cutoff).limit(500)
  if (dueErr) return Response.json({ error: dueErr.message }, { status: 500 })
  if (!due || due.length === 0) return Response.json({ erased: 0 })

  const ids = due.map((m) => m.id)

  // Journal photos: stored path on journal_entries.photo_path.
  const { data: entries } = await supabase
    .from("journal_entries").select("photo_path").in("moment_id", ids)
  const photos = (entries ?? []).map((e) => e.photo_path).filter((p): p is string => !!p)

  // Voice recordings are no longer uploaded (none since Nov 11 2026) and the old
  // ones use random file names not tied to a moment, so there is nothing to map.

  // Remove photos first. If storage fails, keep the rows so tomorrow retries
  // instead of leaving files nobody can find.
  if (photos.length) {
    const { error } = await supabase.storage.from("journal-photos").remove(photos)
    if (error) return Response.json({ error: `photos: ${error.message}` }, { status: 500 })
  }

  // Erasing a moment cascades to its journal_entries row.
  const { error: delErr, count } = await supabase
    .from("moments").delete({ count: "exact" }).in("id", ids)
  if (delErr) return Response.json({ error: delErr.message }, { status: 500 })

  return Response.json({ erased: count ?? ids.length, photos: photos.length })
})

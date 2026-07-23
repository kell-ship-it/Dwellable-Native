// T-062: fetch-moments Edge Function
//
// Replaces direct client reads of GET /rest/v1/moments. Verifies the caller's
// JWT, fetches that user's rows with the service_role client, decrypts
// encrypted_content transiently, and returns plaintext -- decrypted server-side,
// sent once over HTTPS to the authenticated device, never persisted as plaintext
// on the server. Response shape matches the existing Moment[] REST shape.

import { createClient } from "jsr:@supabase/supabase-js"
import { decryptText } from "../_shared/encryption.ts"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, apikey",
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders })
  }
  if (req.method !== "GET") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!

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

    // Optional ?id=<moment_id> to fetch a single moment (mirrors the old
    // fetchMoment(id:) call site) -- otherwise returns all of this user's moments.
    const url = new URL(req.url)
    const singleId = url.searchParams.get("id")

    const serviceClient = createClient(supabaseUrl, serviceRoleKey)
    let query = serviceClient
      .from("moments")
      .select("id, user_id, encrypted_content, encryption_iv, created_at, updated_at, audio_url")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })

    if (singleId) {
      query = query.eq("id", singleId)
    }

    const { data: rows, error: dbError } = await query
    if (dbError) {
      console.error("fetch-moments DB error:", dbError)
      return new Response(JSON.stringify({ error: "Failed to fetch moments" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    const decrypted = await Promise.all(
      (rows ?? []).map(async (row) => {
        let body = ""
        let senseOfLord: string | null = null
        if (row.encrypted_content && row.encryption_iv) {
          try {
            const plaintext = await decryptText({
              encryptedContent: row.encrypted_content,
              encryptionIv: row.encryption_iv,
            })
            const parsed = JSON.parse(plaintext) as { body: string; sense_of_lord: string | null }
            body = parsed.body
            senseOfLord = parsed.sense_of_lord
          } catch (decryptError) {
            console.error(`Decryption failed for moment ${row.id}:`, decryptError)
            body = "[Unable to decrypt this moment]"
          }
        }
        return {
          id: row.id,
          user_id: row.user_id,
          body,
          sense_of_lord: senseOfLord,
          created_at: row.created_at,
          audio_url: row.audio_url,
        }
      })
    )

    return new Response(JSON.stringify(decrypted), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  } catch (error) {
    console.error("fetch-moments error:", error)
    const message = error instanceof Error ? error.message : String(error)
    return new Response(JSON.stringify({ error: "Internal server error", details: message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }
})

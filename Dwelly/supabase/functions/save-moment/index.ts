// T-062: save-moment Edge Function
//
// Replaces direct client writes to POST /rest/v1/moments for moment content.
// The client sends plaintext body/sense_of_lord over HTTPS (same as today);
// this function verifies the caller's JWT, encrypts the sensitive fields with
// AES-256-GCM using the server-managed key, and writes the row using the
// service_role key -- so the encryption key and the write path never touch
// the client, and RLS is intentionally bypassed here because user_id is taken
// from the *verified* JWT, not from the request body (a client can't spoof
// which user_id it writes as).
//
// Response shape matches the existing `moments` REST response shape exactly,
// so SupabaseAPIClient.saveMoment's return type doesn't need to change.

import { createClient } from "jsr:@supabase/supabase-js"
import { encryptText } from "../_shared/encryption.ts"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, apikey",
}

interface SaveMomentBody {
  id: string
  body: string
  sense_of_lord?: string | null
  created_at: string
  audio_url?: string | null
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
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!

    // Verify the caller's JWT using an anon-key client -- this is what proves
    // who's actually asking, before we ever touch the service-role client.
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

    const payload = (await req.json()) as SaveMomentBody
    if (!payload.id || !payload.body || !payload.created_at) {
      return new Response(JSON.stringify({ error: "Missing required fields: id, body, created_at" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    // Encrypt transiently -- plaintext only exists in memory for this request.
    const { encryptedContent, encryptionIv } = await encryptText(payload.body)

    // sense_of_lord is optional and equally sensitive; encrypt it into the same
    // blob rather than adding a second IV/column pair, keeping the schema simple.
    const combinedPlaintext = JSON.stringify({
      body: payload.body,
      sense_of_lord: payload.sense_of_lord ?? null,
    })
    const combined = await encryptText(combinedPlaintext)

    const serviceClient = createClient(supabaseUrl, serviceRoleKey)
    const { error: dbError } = await serviceClient
      .from("moments")
      .upsert(
        {
          id: payload.id,
          user_id: userId,
          encrypted_content: combined.encryptedContent,
          encryption_iv: combined.encryptionIv,
          created_at: payload.created_at,
          updated_at: new Date().toISOString(),
          audio_url: payload.audio_url ?? null,
        },
        { onConflict: "id" }
      )

    if (dbError) {
      console.error("save-moment DB error:", dbError)
      return new Response(JSON.stringify({ error: "Failed to save moment" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    // Return the same shape the client already expects from the old direct-REST
    // path -- plaintext body, because the client just wrote it and already has it.
    return new Response(
      JSON.stringify({
        id: payload.id,
        user_id: userId,
        body: payload.body,
        sense_of_lord: payload.sense_of_lord ?? null,
        created_at: payload.created_at,
        audio_url: payload.audio_url ?? null,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    )
  } catch (error) {
    console.error("save-moment error:", error)
    const message = error instanceof Error ? error.message : String(error)
    return new Response(JSON.stringify({ error: "Internal server error", details: message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }
})

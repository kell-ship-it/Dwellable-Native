// Verifies the caller's JWT and returns the user id (never trust a client-supplied id).
import { createClient } from "jsr:@supabase/supabase-js"

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PATCH, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, apikey",
}

export function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  })
}

export async function authenticate(req: Request): Promise<{ userId: string } | { error: Response }> {
  const authHeader = req.headers.get("Authorization")
  if (!authHeader) return { error: json({ error: "Missing Authorization header" }, 401) }
  const jwt = authHeader.replace("Bearer ", "")
  const authClient = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: authHeader } },
  })
  const { data, error } = await authClient.auth.getUser(jwt)
  if (error || !data?.user) return { error: json({ error: "Invalid or expired token" }, 401) }
  return { userId: data.user.id }
}

export function serviceClient() {
  return createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!)
}

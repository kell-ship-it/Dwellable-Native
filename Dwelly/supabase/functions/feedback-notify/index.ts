// T-133: feedback-notify Edge Function
//
// Called (best-effort, fire-and-forget -- see SupabaseAPIClient.submitFeedback) right
// after a Support & Feedback submission has already been written to
// public.feedback_submissions. This function's job is the two things that ticket asks
// for beyond the table itself:
//   1. A Resend email alert to the team when feedback comes in.
//   2. A mirror of the submission into a Notion database.
//
// STATUS AS OF THIS COMMIT: both are stubbed, not wired to a real account. This session
// has no real Resend API key or Notion integration token/database id -- inventing either
// would mean pretending this works when it doesn't. Instead:
//   - The JWT verification, request validation, and control flow below are real and
//     exercised (this function actually runs and returns 200 today).
//   - sendResendAlert() and mirrorToNotion() each check for their required env var,
//     and skip with a console.log (not an error) when it's missing -- which is the
//     case right now, so every call today just verifies and logs, then returns ok.
//   - Once ops provisions real credentials, set RESEND_API_KEY (and optionally
//     FEEDBACK_ALERT_TO_EMAIL, default below) and NOTION_API_KEY + NOTION_DATABASE_ID
//     as Edge Function secrets (`supabase secrets set ...`) -- no code change needed,
//     both functions already do the real HTTP call once their env var is present.
//
// A submission already succeeded by the time this runs, so a failure here (missing
// creds, Resend/Notion being down, etc.) is logged and swallowed, never surfaced to the
// user or retried -- this function always returns 200 unless the request itself is
// malformed or unauthenticated.

import { createClient } from "jsr:@supabase/supabase-js"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, apikey",
}

interface FeedbackNotifyBody {
  submission_id: string
  feedback_type: "feedback" | "bug"
  message: string
  user_id: string
}

async function sendResendAlert(body: FeedbackNotifyBody, userEmail: string | null): Promise<void> {
  const apiKey = Deno.env.get("RESEND_API_KEY")
  if (!apiKey) {
    console.log("feedback-notify: RESEND_API_KEY not set -- skipping Resend alert (stubbed, see this function's header comment)")
    return
  }

  const toEmail = Deno.env.get("FEEDBACK_ALERT_TO_EMAIL") ?? "kells@kellgolden.com"
  const subject = body.feedback_type === "bug" ? "Dwelly bug report" : "Dwelly feedback"

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      // $0 MVP tier per the ticket -- Resend's sandbox/onboarding sender domain, not a
      // custom domain (that's a separate ops/DNS task, not this function's job).
      from: "Dwelly <onboarding@resend.dev>",
      to: toEmail,
      subject,
      text: `${subject}\n\nFrom: ${userEmail ?? body.user_id}\nSubmission: ${body.submission_id}\n\n${body.message}`,
    }),
  })

  if (!res.ok) {
    console.error("feedback-notify: Resend call failed", res.status, await res.text())
  }
}

async function mirrorToNotion(body: FeedbackNotifyBody, userEmail: string | null): Promise<void> {
  const apiKey = Deno.env.get("NOTION_API_KEY")
  const databaseId = Deno.env.get("NOTION_DATABASE_ID")
  if (!apiKey || !databaseId) {
    console.log("feedback-notify: NOTION_API_KEY/NOTION_DATABASE_ID not set -- skipping Notion mirror (stubbed, see this function's header comment)")
    return
  }

  const res = await fetch("https://api.notion.com/v1/pages", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      "Notion-Version": "2022-06-28",
    },
    body: JSON.stringify({
      parent: { database_id: databaseId },
      properties: {
        // NOTE: these property names assume a database with "Name" (title), "Type"
        // (select: Feedback/Bug), and "User" (rich_text) columns -- ops creating the
        // real database should match these, or this call needs updating to match it.
        Name: { title: [{ text: { content: body.message.slice(0, 80) } }] },
        Type: { select: { name: body.feedback_type === "bug" ? "Bug" : "Feedback" } },
        User: { rich_text: [{ text: { content: userEmail ?? body.user_id } }] },
      },
      children: [
        {
          object: "block",
          type: "paragraph",
          paragraph: { rich_text: [{ text: { content: body.message } }] },
        },
      ],
    }),
  })

  if (!res.ok) {
    console.error("feedback-notify: Notion call failed", res.status, await res.text())
  }
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

    const body = (await req.json()) as FeedbackNotifyBody
    if (!body.submission_id || !body.feedback_type || !body.message || !body.user_id) {
      return new Response(JSON.stringify({ error: "Missing required fields: submission_id, feedback_type, message, user_id" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }
    // The caller's own JWT must belong to the user_id it's notifying about -- this
    // function only ever notifies on behalf of the person who's actually signed in.
    if (userData.user.id !== body.user_id) {
      return new Response(JSON.stringify({ error: "user_id does not match authenticated caller" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    const userEmail = userData.user.email ?? null

    // Both are best-effort: a thrown error here is logged, never surfaced to the
    // client, since the submission itself already succeeded before this ran.
    try {
      await sendResendAlert(body, userEmail)
    } catch (error) {
      console.error("feedback-notify: sendResendAlert threw", error)
    }
    try {
      await mirrorToNotion(body, userEmail)
    } catch (error) {
      console.error("feedback-notify: mirrorToNotion threw", error)
    }

    return new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  } catch (error) {
    console.error("feedback-notify error:", error)
    const message = error instanceof Error ? error.message : String(error)
    return new Response(JSON.stringify({ error: "Internal server error", details: message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }
})

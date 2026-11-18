// T-133 (Kell's approved direction, Nov 18 2026): the one real endpoint behind the
// in-app Support & Feedback form. Supersedes the earlier client-REST-insert +
// fire-and-forget feedback-notify split -- this does validation, the insert, and the
// Resend delivery attempt in one authenticated round trip, so the client's
// success/failure state reflects one real outcome instead of an optimistic insert that
// might outlive a notify failure it never saw.
//
// The approved requirement is EMAIL DELIVERY to hello@dwelly.one, not just a saved row
// -- a submission whose email didn't go out is NOT "done" from the client's point of
// view, even though it's safely saved. See `emailed` below.
//
// Initial submit -- Request: { category: "problem"|"idea"|"other", message: string,
//   app_version?: string, screenshot_path?: string } with Authorization: Bearer <user JWT>.
//   Inserts a new row.
// Retry -- Request: { retry_submission_id: string } with the same auth. Re-attempts the
//   Resend send for an EXISTING submission (ownership-checked) -- idempotent: never
//   inserts a second row, so retrying can't duplicate the submission. It CAN send a
//   second email if called again after a send that already succeeded; the client only
//   exposes Retry while `emailed` is still false, so that path doesn't happen in normal
//   use, but this function doesn't rely on the client for that -- see the note at the
//   call site below if that needs hardening later (e.g. tracking emailed_at).
//
// Response (both forms): { ok: true, id, created_at, emailed: boolean,
//   resend_configured: boolean } -- the row is saved whenever ok:true, regardless of
//   `emailed`. { ok: false, error } means nothing was saved/changed.
//
// Email delivery status as of this commit: RESEND_API_KEY is NOT set as a secret on
// this project. sendResendAlert() returns false BEFORE making any network call when the
// key is absent -- Resend's API has never been contacted, not once, by this function.
// resend_configured and emailed are therefore always false today. The submission still
// saves for real (feedback_submissions is the system of record) -- only the "also email
// hello@dwelly.one" step is inert until ops sets a real key. See the bottom of this file
// for exactly what to provision. Notion mirroring is intentionally out of scope for this
// change (not touched by the retry path).

import { createClient } from "jsr:@supabase/supabase-js"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, apikey",
}

const ALLOWED_CATEGORIES = ["problem", "idea", "other"] as const
type Category = (typeof ALLOWED_CATEGORIES)[number]
const MAX_MESSAGE_LENGTH = 4000

interface SubmitFeedbackBody {
  category?: Category
  message?: string
  app_version?: string | null
  screenshot_path?: string | null
  // Present only on a retry call -- re-attempts Resend for this existing submission
  // instead of inserting a new one.
  retry_submission_id?: string
}

async function sendResendAlert(userId: string, userEmail: string | null, category: Category, message: string, submissionId: string): Promise<boolean> {
  const apiKey = Deno.env.get("RESEND_API_KEY")
  if (!apiKey) {
    console.log("submit-feedback: RESEND_API_KEY not set -- skipping Resend alert (see this function's header comment)")
    return false
  }

  // Addresses hello@dwelly.one, not Kell's personal inbox directly -- inbound delivery
  // for that alias (-> kells@kellgolden.com) is already confirmed working, and it's the
  // stable support identity rather than a personal address baked into app behavior.
  const toEmail = Deno.env.get("FEEDBACK_ALERT_TO_EMAIL") ?? "hello@dwelly.one"
  const subjectByCategory: Record<Category, string> = {
    problem: "Dwelly: problem reported",
    idea: "Dwelly: idea suggested",
    other: "Dwelly feedback",
  }
  const subject = subjectByCategory[category]

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
      text: `${subject}\n\nFrom: ${userEmail ?? userId}\nSubmission: ${submissionId}\n\n${message}`,
    }),
  })

  if (!res.ok) {
    console.error("submit-feedback: Resend call failed", res.status, await res.text())
    return false
  }
  return true
}

async function mirrorToNotion(userId: string, userEmail: string | null, category: Category, message: string): Promise<void> {
  const apiKey = Deno.env.get("NOTION_API_KEY")
  const databaseId = Deno.env.get("NOTION_DATABASE_ID")
  if (!apiKey || !databaseId) {
    console.log("submit-feedback: NOTION_API_KEY/NOTION_DATABASE_ID not set -- skipping Notion mirror")
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
        // NOTE: assumes a database with "Name" (title), "Type" (select), "User"
        // (rich_text) columns -- update this call if ops' real database differs.
        Name: { title: [{ text: { content: message.slice(0, 80) } }] },
        Type: { select: { name: category } },
        User: { rich_text: [{ text: { content: userEmail ?? userId } }] },
      },
      children: [{ object: "block", type: "paragraph", paragraph: { rich_text: [{ text: { content: message } }] } }],
    }),
  })

  if (!res.ok) {
    console.error("submit-feedback: Notion call failed", res.status, await res.text())
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders })
  }
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ ok: false, error: "Method not allowed" }), {
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
      return new Response(JSON.stringify({ ok: false, error: "Missing Authorization header" }), {
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
      return new Response(JSON.stringify({ ok: false, error: "Invalid or expired token" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }
    const userId = userData.user.id
    const userEmail = userData.user.email ?? null

    const body = (await req.json()) as SubmitFeedbackBody
    const serviceClient = createClient(supabaseUrl, serviceRoleKey)

    // Retry path: re-attempt the email for an EXISTING submission. Never inserts --
    // this is what makes a retry idempotent with respect to the saved row (you cannot
    // get two rows out of retrying once).
    if (body.retry_submission_id) {
      const { data: existing, error: fetchError } = await serviceClient
        .from("feedback_submissions")
        .select("id, created_at, feedback_type, message")
        .eq("id", body.retry_submission_id)
        .eq("user_id", userId)
        .single()

      if (fetchError || !existing) {
        return new Response(JSON.stringify({ ok: false, error: "Submission not found" }), {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        })
      }

      let retryEmailed = false
      try {
        retryEmailed = await sendResendAlert(userId, userEmail, existing.feedback_type as Category, existing.message, existing.id)
      } catch (error) {
        console.error("submit-feedback (retry): sendResendAlert threw", error)
      }

      return new Response(
        JSON.stringify({
          ok: true,
          id: existing.id,
          created_at: existing.created_at,
          emailed: retryEmailed,
          resend_configured: Deno.env.get("RESEND_API_KEY") !== undefined,
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    if (!body.category || !ALLOWED_CATEGORIES.includes(body.category)) {
      return new Response(JSON.stringify({ ok: false, error: `category must be one of ${ALLOWED_CATEGORIES.join(", ")}` }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }
    const message = (body.message ?? "").trim()
    if (!message) {
      return new Response(JSON.stringify({ ok: false, error: "message is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }
    if (message.length > MAX_MESSAGE_LENGTH) {
      return new Response(JSON.stringify({ ok: false, error: `message must be ${MAX_MESSAGE_LENGTH} characters or fewer` }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    // A screenshot path, if present, must live under this user's own folder in the
    // feedback-screenshots bucket -- storage RLS already enforces this for reads/writes,
    // but this endpoint uses the service role for the insert, so it re-checks here
    // rather than trusting whatever path the client happens to send.
    let screenshotPath: string | null = null
    if (body.screenshot_path) {
      if (!body.screenshot_path.startsWith(`${userId}/`)) {
        return new Response(JSON.stringify({ ok: false, error: "screenshot_path does not belong to the authenticated user" }), {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        })
      }
      screenshotPath = body.screenshot_path
    }

    const { data: inserted, error: dbError } = await serviceClient
      .from("feedback_submissions")
      .insert({
        user_id: userId,
        feedback_type: body.category,
        message,
        app_version: body.app_version ?? null,
        platform: "ios",
        screenshot_url: screenshotPath,
      })
      .select()
      .single()

    if (dbError || !inserted) {
      console.error("submit-feedback: DB insert failed", dbError)
      return new Response(JSON.stringify({ ok: false, error: "Could not save your submission. Please try again." }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    // The submission is saved for real at this point -- everything below is best-effort
    // notify. A failure here is logged but never turns this response into a failure;
    // the client already has a real, durable submission.
    let emailed = false
    try {
      emailed = await sendResendAlert(userId, userEmail, body.category, message, inserted.id)
    } catch (error) {
      console.error("submit-feedback: sendResendAlert threw", error)
    }
    try {
      await mirrorToNotion(userId, userEmail, body.category, message)
    } catch (error) {
      console.error("submit-feedback: mirrorToNotion threw", error)
    }

    return new Response(
      JSON.stringify({
        ok: true,
        id: inserted.id,
        created_at: inserted.created_at,
        emailed,
        resend_configured: Deno.env.get("RESEND_API_KEY") !== undefined,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    )
  } catch (error) {
    console.error("submit-feedback error:", error)
    const message = error instanceof Error ? error.message : String(error)
    return new Response(JSON.stringify({ ok: false, error: "Internal server error", details: message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }
})

// --- OPS SETUP NEEDED (no secret values below, just what to provision) ---
// To make "emailed" turn true and real alerts actually reach hello@dwelly.one (which
// forwards to kells@kellgolden.com -- inbound confirmed already working):
//   1. Create a Resend account (resend.com), generate an API key.
//   2. `supabase secrets set RESEND_API_KEY=<the key>` for this project (or via the
//      Supabase dashboard: Edge Functions -> Secrets). Never put it in client code or
//      in this repo.
//   3. Sender address: this function currently sends `from: Dwelly <onboarding@resend.dev>`,
//      Resend's own shared sandbox sender -- works with zero DNS setup, no domain
//      verification needed, but mail from it is more likely to land in spam and can't
//      be branded as @dwelly.one. If a real "from" address is wanted later, that needs
//      its own domain verification (SPF/DKIM) in Resend -- separate, optional, not
//      required to get emailed:true.
//   4. Optional: set FEEDBACK_ALERT_TO_EMAIL to override the hello@dwelly.one default.
//   5. Redeploy this function (no code change needed -- it already checks for the key
//      at request time).
// Notion mirror: out of scope for this change -- NOTION_API_KEY/NOTION_DATABASE_ID stay
// unset and mirrorToNotion() stays a no-op; nothing to provision for it right now.

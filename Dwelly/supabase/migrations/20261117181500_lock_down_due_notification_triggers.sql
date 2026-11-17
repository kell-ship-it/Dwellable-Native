-- Security advisor caught this live: due_notification_triggers() is SECURITY DEFINER
-- and lives in the public schema, which PostgREST auto-exposes as an RPC endpoint --
-- meaning ANY signed-in (or even anonymous) client could call
-- /rest/v1/rpc/due_notification_triggers and get back every user's dormancy/notification
-- data, not just their own. This must only ever be called server-side (the future T-084
-- scheduler, using the service_role key), never from the app.
revoke execute on function public.due_notification_triggers() from anon, authenticated;

-- Also fixes the paired "mutable search_path" warning: without a pinned search_path, a
-- SECURITY DEFINER function resolves unqualified names against whatever search_path the
-- calling session happens to have, which is the classic privilege-escalation vector for
-- this exact function type (a malicious search_path could shadow `public.users` with an
-- attacker-controlled table of the same unqualified name). Explicit already-qualified
-- table references throughout the function body are the real protection; pinning
-- search_path is the defense-in-depth Postgres itself recommends for every
-- SECURITY DEFINER function regardless.
alter function public.due_notification_triggers() set search_path = public;

-- The revoke above targeted anon/authenticated directly, but Postgres grants EXECUTE
-- on every new function to the PUBLIC pseudo-role by default, and anon/authenticated
-- inherit through that -- revoking from the specific roles without also revoking from
-- PUBLIC left the real grant in place (confirmed still flagged by a second advisor run
-- after the fix above). This is the actual fix.
revoke execute on function public.due_notification_triggers() from public;

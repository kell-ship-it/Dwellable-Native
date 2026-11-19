-- T-307: privacy-minimal safety logging for the T-125 crisis/misuse layer (T-302/T-303).
--
-- Deliberately NOT user-linked by default. Two tables, two different jobs:
--
-- 1. safety_diagnostics: short-lived, operational-only -- schema only for now. Records
--    that a check FAILED (moderation call errored/timed out, the contextual classifier
--    errored, or the output check couldn't complete), no user_id, no message content,
--    no classification result -- just that a failure of a given kind happened, for a
--    given feature, at a given time. Retention is intentionally NOT set to a specific
--    number here (an earlier draft proposed 30 days without real approval). REVISED
--    Nov 19 2026 per Kell/Codex's further correction: "short-lived" with no actual
--    expiry/purge job is not a real retention policy -- so `llm-proxy/index.ts` does
--    NOT write to this table by default (`SAFETY_DIAGNOSTICS_ENABLED = false`; see that
--    constant's own comment). This table exists so it's ready the moment Kell approves
--    a real retention/purge policy -- until then, failures are console-logged only
--    (visible in Supabase function logs, which have their own platform-level retention,
--    not this app's to invent) and nothing is written here.
--
-- 2. safety_event_aggregate: non-identifiable rollup. One row per (day, category),
--    incremented every time that category's response pattern fires (crisis_self,
--    crisis_other, ongoing_danger, refusal). No user_id ever -- this is a running
--    count only, which is what any future reporting need (e.g. "how many times did
--    this come up last year") actually requires, not a year of per-user labels.

create table public.safety_diagnostics (
    id uuid primary key default gen_random_uuid(),
    created_at timestamptz not null default now(),
    stage text not null check (stage in ('input', 'output')),
    failure_type text not null,
    feature text not null
);

comment on table public.safety_diagnostics is
  'T-307: short-lived, non-user-linked record of a safety-check failure (not a flagged result -- a technical failure to complete the check). No retention period is enforced yet; decide and implement a purge job before relying on this long-term.';

alter table public.safety_diagnostics enable row level security;
-- No select/insert policy for anon/authenticated -- this table is written only by
-- llm-proxy via the service-role key, which bypasses RLS by design (same pattern as
-- save-moment/fetch-moments). Enabling RLS with zero policies means a client holding
-- only the anon/authenticated key can't read or write this table at all.

create table public.safety_event_aggregate (
    event_date date not null,
    category text not null,
    count integer not null default 0,
    primary key (event_date, category)
);

comment on table public.safety_event_aggregate is
  'T-307: non-identifiable daily count per safety response category (crisis_self, crisis_other, ongoing_danger, refusal). No user_id -- this is the aggregate counter referenced in T-125''s design, not a per-user safety label.';

alter table public.safety_event_aggregate enable row level security;
-- Same reasoning as above: written only by llm-proxy's service-role client.

-- Atomic increment, called via supabase-js's .rpc() from llm-proxy -- a plain
-- upsert can't do `count = count + 1` server-side, and two concurrent requests
-- doing a read-then-write from the Edge Function itself would race.
create or replace function public.increment_safety_event(p_date date, p_category text)
returns void
language sql
security definer
set search_path = public
as $$
  insert into public.safety_event_aggregate (event_date, category, count)
  values (p_date, p_category, 1)
  on conflict (event_date, category)
  do update set count = safety_event_aggregate.count + 1;
$$;

comment on function public.increment_safety_event is
  'T-307: atomic daily counter bump for a safety response category. security definer so the service-role Edge Function caller does not need table-level grants beyond calling this function.';

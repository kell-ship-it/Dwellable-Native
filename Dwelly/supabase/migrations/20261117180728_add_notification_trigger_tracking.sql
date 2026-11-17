-- T-251: status-based checks + sync-based dormancy clock.
--
-- (1) last_synced_at is the single source of truth for "how long has this user been
-- quiet." It is NOT a cached duration -- it's just updated to now() every time
-- SyncManager completes a successful sync pass (see touchLastSynced in
-- SupabaseAPIClient.swift). Because every dormancy check below recomputes elapsed
-- time from this one column, a sync automatically resets the clock to zero -- that
-- *is* the "any sync event cancels a pending dormancy notification" rule from the
-- ticket, with no separate cancel-flag bookkeeping needed.
alter table public.users
  add column last_synced_at timestamptz;

-- Seed existing users so dormancy math has a starting point instead of NULL (which
-- would read as "infinitely dormant" and fire immediately once a scheduler exists).
update public.users set last_synced_at = now() where last_synced_at is null;

-- (2) History of which dormancy-cycle stages have actually fired, per user. The
-- locked design is exactly two cycles ever, lifetime: 3A/3B at day 14, then — only if
-- the user is STILL silent — 4A/4B at day 30, then permanent stop. Counting rows here
-- (grouped by stage prefix '3'/'4') is how "has this user already had their 2 cycles"
-- gets answered without a separate counter column to keep in sync.
create table public.notification_dormancy_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  stage text not null check (stage in ('3A', '3B', '4A', '4B')),
  fired_at timestamptz not null default now()
);

create index notification_dormancy_log_user_id_idx on public.notification_dormancy_log(user_id);

alter table public.notification_dormancy_log enable row level security;

-- Server-side only (service role, via a future Edge Function scheduler per T-084) --
-- a user has no legitimate reason to read or write their own notification firing
-- history directly, same posture as login_attempts/abuse_incidents.
create policy "service role only" on public.notification_dormancy_log
  for all using (false);

comment on table public.notification_dormancy_log is
  'T-251: fired-notification history for the dormancy pair (3A/3B day-14, 4A/4B day-30). Two cycles lifetime, then permanent stop -- see due_notification_triggers().';

-- The actual decision function. Returns every (user_id, trigger) pair that is due
-- to fire right now. T-084's future scheduling engine calls this and hands the
-- result to whatever actually sends (APNs, once T-083 lands) -- this function only
-- ever decides WHETHER something is due, never sends anything itself.
create or replace function public.due_notification_triggers()
returns table (user_id uuid, trigger text) as $$
begin
  return query
  -- Stage 2 / 3B / 4B ("journal ready"): fires once a JournalEntry row exists for a
  -- moment that hasn't been notified about yet. Per the ticket, "exists" is the whole
  -- check -- a fallback-synthesis journal (raw transcript, no real LLM synthesis)
  -- still counts, so this deliberately does not look at journal_entries.status or
  -- whether body is null. No separate "already notified" column exists yet for this
  -- specific stage -- left for T-084 to pair with its own send-log when it actually
  -- wires delivery, since this function's job here is strictly the existence check
  -- the ticket calls out, not de-duplication bookkeeping that belongs to the sender.
  select m.user_id, 'stage_2_journal_ready'::text
  from public.moments m
  join public.journal_entries je on je.moment_id = m.id
  where m.deleted_at is null

  union all

  -- Day-14 dormancy, first nudge of the pair (capture-focused). Due when the user's
  -- last confirmed server sync is >= 14 days old AND they have never run a dormancy
  -- cycle before (lifetime cap enforced by checking notification_dormancy_log is
  -- empty for this user, not just "no 3A yet").
  select u.id, 'stage_3a_dormancy_capture'::text
  from public.users u
  where u.last_synced_at <= now() - interval '14 days'
    and u.notification_mode != 'off'
    and not exists (
      select 1 from public.notification_dormancy_log d where d.user_id = u.id
    )

  union all

  -- Day-30 dormancy, second (and per the locked design, final) cycle. Due only if
  -- 3A already fired, the user is STILL silent (last_synced_at hasn't moved since --
  -- any sync would have pushed last_synced_at forward past the 30-day threshold
  -- entirely, so this condition alone is the "still silent" check), and exactly one
  -- cycle has run so far (never a 4A already, enforcing the lifetime cap of two).
  select u.id, 'stage_4a_dormancy_capture'::text
  from public.users u
  where u.last_synced_at <= now() - interval '30 days'
    and u.notification_mode != 'off'
    and exists (select 1 from public.notification_dormancy_log d where d.user_id = u.id and d.stage = '3A')
    and not exists (select 1 from public.notification_dormancy_log d where d.user_id = u.id and d.stage = '4A');
end;
$$ language plpgsql security definer stable;

comment on function public.due_notification_triggers() is
  'T-251: decides which notification triggers are due right now. 3B/4B (the journal-nudge half of each dormancy pair, sent only if the user actually captured something after 3A/4A fired) are intentionally not computed here yet -- they depend on T-084''s scheduler recording exactly when 3A/4A were delivered, which this function has no visibility into until that sender exists.';

-- T-152: the real JournalEntry persistence the Journal Detail screen (T-155) and its
-- mood editor (T-153) have been missing -- title/moods/scripture were previously
-- generated once at capture time and never saved anywhere, so reopening a saved
-- moment showed none of them. One entry per moment (1:1), not its own encrypted
-- blob: body itself stays on moments.encrypted_content (no duplicate copy here) --
-- this table only owns the synthesis metadata layered on top of a moment.
create table public.journal_entries (
    id uuid primary key default gen_random_uuid(),
    moment_id uuid not null unique references public.moments(id) on delete cascade,
    user_id uuid not null references public.users(id),
    status text not null default 'approved' check (status in ('pending', 'approved')),
    title text,
    moods text[] not null default '{}',
    scripture_quote text,
    scripture_reference text,
    starred boolean not null default false,
    edited boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

comment on table public.journal_entries is 'T-152: synthesis metadata (title/moods/scripture/starred) for a moment, 1:1 via moment_id. Unencrypted -- title is spec''d as unencrypted in MVP (docs/PILLAR_4_JOURNAL_CREATION_STRATEGY.md), and moods/scripture/starred are no more sensitive than that. The actual journal body stays on moments.encrypted_content; this table does not duplicate it.';

alter table public.journal_entries enable row level security;

create policy "Users can read their own journal entries"
  on public.journal_entries for select
  using (user_id = (select auth.uid()));

create policy "Users can insert their own journal entries"
  on public.journal_entries for insert
  with check (user_id = (select auth.uid()));

create policy "Users can update their own journal entries"
  on public.journal_entries for update
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

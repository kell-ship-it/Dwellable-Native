-- T-163: real confirm/correct loop for "Your Narrative." Confirming a narrative needs
-- to persist (not just a session flag) so it survives app restarts and is tied to the
-- specific narrative version it confirmed; feedback from "Not quite" needs a real place
-- to land even though nothing processes it yet (T-164's job, separately not started).

alter table public.dweller_profiles add column confirmed_at timestamptz;
comment on column public.dweller_profiles.confirmed_at is 'T-163: when the user tapped "Yes, that''s me" on the narrative currently in running_summary. Compared against updated_at client-side -- a narrative regenerated after this timestamp is treated as unconfirmed again.';

create table public.narrative_feedback (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    feedback_text text not null,
    created_at timestamptz not null default now()
);
comment on table public.narrative_feedback is 'T-163/T-164: free-text feedback from "Not quite" on Your Narrative -- what feels off or missing. Captured for real; nothing reads it back into the narrative yet (T-164, the internal reassessment engine, is not started).';

alter table public.narrative_feedback enable row level security;

create policy "Users can insert their own narrative feedback"
  on public.narrative_feedback for insert
  with check (user_id = (select auth.uid()));

create policy "Users can read their own narrative feedback"
  on public.narrative_feedback for select
  using (user_id = (select auth.uid()));

-- T-294: a user's own mood vocabulary, shared across every journal entry. Previously a
-- custom word typed into the Mood Sheet only ever lived inside that one entry's
-- journal_entries.moods array, so the next entry had no way to offer it back.

create table public.custom_moods (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    word text not null,
    created_at timestamptz not null default now(),
    unique (user_id, word)
);

comment on table public.custom_moods is 'T-294: a user''s own custom mood words (distinct from the 8 hardcoded presetMoods), reusable across every journal entry. Capped client-side at 10 distinct words per user.';

alter table public.custom_moods enable row level security;

create policy "Users can read their own custom moods"
  on public.custom_moods for select
  using (user_id = (select auth.uid()));

create policy "Users can insert their own custom moods"
  on public.custom_moods for insert
  with check (user_id = (select auth.uid()));

create policy "Users can delete their own custom moods"
  on public.custom_moods for delete
  using (user_id = (select auth.uid()));

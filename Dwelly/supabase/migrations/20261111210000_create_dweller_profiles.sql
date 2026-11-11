-- T-274: the "doctor's notes" MVP -- a short, plain-text running summary of a user's
-- journal entries over time. Store-and-show only: nothing reads this back into a
-- capture conversation yet, it only powers DwellerProfileView. One row per user.
create table public.dweller_profiles (
    user_id uuid primary key references public.users(id),
    running_summary text,
    updated_at timestamptz not null default now()
);

comment on table public.dweller_profiles is 'T-274: store-and-show-only running summary of a user''s journal entries, kept current by DwellerProfileManager after every successfully synthesized entry. Unencrypted -- summarizes journal_entries.body, which is itself already unencrypted. Not yet read back into any capture conversation.';

alter table public.dweller_profiles enable row level security;

create policy "Users can read their own dweller profile"
  on public.dweller_profiles for select
  using (user_id = (select auth.uid()));

create policy "Users can insert their own dweller profile"
  on public.dweller_profiles for insert
  with check (user_id = (select auth.uid()));

create policy "Users can update their own dweller profile"
  on public.dweller_profiles for update
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- T-116: pre-signup funnel events (Welcome, Account Creation) have no real user_id yet.
alter table usage_events
  alter column user_id drop not null,
  add column anonymous_id uuid;

alter table usage_events
  add constraint usage_events_user_or_anonymous_chk
  check (user_id is not null or anonymous_id is not null);

drop policy if exists "Allow authenticated insert" on usage_events;
create policy "Allow authenticated or anonymous insert" on usage_events
  for insert
  with check (
    (auth.uid() is not null and user_id = auth.uid())
    or (anonymous_id is not null and user_id is null)
  );

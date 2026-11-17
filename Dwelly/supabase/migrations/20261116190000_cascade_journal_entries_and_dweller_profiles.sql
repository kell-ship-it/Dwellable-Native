-- T-095 (in-app account deletion) needs a full cascade from auth.users all the
-- way down. journal_entries and dweller_profiles were created without an
-- explicit ON DELETE clause on their user_id FK, which defaults to NO ACTION
-- (restrict) -- that would block deleting auth.users for any user who has a
-- journal entry or a dweller profile.

alter table journal_entries
  drop constraint journal_entries_user_id_fkey,
  add constraint journal_entries_user_id_fkey
    foreign key (user_id) references public.users(id) on delete cascade;

alter table dweller_profiles
  drop constraint dweller_profiles_user_id_fkey,
  add constraint dweller_profiles_user_id_fkey
    foreign key (user_id) references public.users(id) on delete cascade;

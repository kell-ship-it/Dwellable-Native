-- Applied directly via Supabase MCP on Nov 16 2026 -- recorded here so the repo's
-- migration history matches what's actually live.
--
-- Root cause (found investigating Kell's "entries aren't populating" report):
-- `public.users.id` never referenced `auth.users.id` at all. Deleting an auth
-- account (via the Supabase dashboard, or the future T-095 in-app delete) left its
-- `public.users` row permanently orphaned -- and since `users.email` is UNIQUE, any
-- future signup reusing that email could create a new auth.users row but could
-- never insert its own `public.users` row (silent 409 on the email constraint).
-- Every subsequent capture then failed the `moments_user_id_fkey` (and
-- `journal_entries_user_id_fkey`) constraint, silently, while the UI still showed a
-- deceptively successful journal card.

-- Clean up orphaned public.users rows (no matching auth.users row) before adding
-- the FK, since the FK validation would otherwise fail against them. The two
-- NO ACTION (restrict) child tables need their own rows cleared first; the rest
-- (moments/usage_events/login_attempts/abuse_incidents) already cascade via their
-- own existing ON DELETE CASCADE constraints to public.users.
delete from journal_entries where user_id in (
  select u.id from public.users u left join auth.users a on u.id = a.id where a.id is null
);
delete from dweller_profiles where user_id in (
  select u.id from public.users u left join auth.users a on u.id = a.id where a.id is null
);
delete from public.users where id in (
  select u.id from public.users u left join auth.users a on u.id = a.id where a.id is null
);

-- The real fix: a deleted auth user now cascades all the way through.
alter table public.users
  add constraint users_id_fkey foreign key (id) references auth.users(id) on delete cascade;

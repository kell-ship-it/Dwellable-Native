-- Nov 27 2026 (Kell): the nightly 30-day erase now also removes journal photos.
-- Photos can only be removed through the Storage API, so the job calls the
-- erase-expired-journals edge function instead of deleting rows in SQL.
create extension if not exists pg_net with schema extensions;

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to service_role;

create table if not exists private.cron_secrets (
  name text primary key,
  secret text not null
);
revoke all on private.cron_secrets from public, anon, authenticated;
grant select on private.cron_secrets to service_role;

insert into private.cron_secrets (name, secret)
values ('erase-expired-journals', encode(extensions.gen_random_bytes(32), 'hex'))
on conflict (name) do nothing;

-- Only the service role (the edge function) may read a cron secret.
create or replace function public.cron_secret(p_name text)
returns text
language sql
security definer
set search_path = private
as $$ select secret from private.cron_secrets where name = p_name $$;
revoke all on function public.cron_secret(text) from public, anon, authenticated;
grant execute on function public.cron_secret(text) to service_role;

select cron.unschedule('erase-expired-deleted-journals')
where exists (select 1 from cron.job where jobname = 'erase-expired-deleted-journals');

select cron.schedule(
  'erase-expired-deleted-journals',
  '0 8 * * *',
  $$
  select net.http_post(
    url := 'https://lhcjobrtmbawlhjyodxz.supabase.co/functions/v1/erase-expired-journals',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-cron-secret', (select secret from private.cron_secrets where name = 'erase-expired-journals')
    ),
    body := '{}'::jsonb,
    timeout_milliseconds := 60000
  );
  $$
);

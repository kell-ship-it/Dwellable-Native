-- Nov 27 2026 (Kell): journals in Recently Deleted are erased for good 30 days
-- after deletion. Erasing a moment cascades to its journal_entries row
-- (journal_entries_moment_id_fkey ON DELETE CASCADE). Usage/spend rows are not
-- tied to moments and are untouched.
create extension if not exists pg_cron with schema pg_catalog;

create or replace function public.erase_expired_deleted_moments()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  erased integer;
begin
  delete from public.moments
  where deleted_at is not null
    and deleted_at < now() - interval '30 days';
  get diagnostics erased = row_count;
  return erased;
end;
$$;

revoke all on function public.erase_expired_deleted_moments() from public, anon, authenticated;

-- Every night at 08:00 UTC (2-3am US Central).
select cron.schedule(
  'erase-expired-deleted-journals',
  '0 8 * * *',
  $$select public.erase_expired_deleted_moments();$$
);

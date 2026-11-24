-- Verification script for 20261123130000_capture_budget_ledger.sql (applied). NOT YET RUN.
-- Run ONLY on a scratch/branch database after applying the draft migration there.
-- Everything happens in one transaction that ROLLS BACK, so it leaves no rows behind.
-- Needs at least one row in auth.users (uses the first one). Any failed check raises.
begin;
do $$
declare
  u uuid := (select id from auth.users limit 1);
  r record;
  cap record;
begin
  if u is null then raise exception 'need an auth.users row'; end if;

  -- 1. first reserve creates the capture with the server-fixed limit; client kind sets it once
  select * into r from public.reserve_capture_tokens(u, 'cap-verify-0001', 'req-verify-0001', 'onboarding', 5000);
  assert r.r_ok and r.r_reserved = 5000 and r.r_limit = 30000, 'first reserve';

  -- 2. a later call claiming "regular" cannot raise the limit
  select * into r from public.reserve_capture_tokens(u, 'cap-verify-0001', 'req-verify-0002', 'regular', 1000);
  assert r.r_ok and r.r_limit = 30000, 'limit fixed at creation';

  -- 3. same request id while still reserved = same reservation, no double count
  select * into r from public.reserve_capture_tokens(u, 'cap-verify-0001', 'req-verify-0001', 'onboarding', 5000);
  assert r.r_ok and r.r_reserved = 5000, 'duplicate reservation reuses';
  select * into cap from public.capture_budgets where user_id = u and capture_id = 'cap-verify-0001';
  assert cap.reserved = 6000 and cap.spent = 0, 'reserved is 6000 (5000+1000), not 11000';

  -- 4. settle replaces the reservation with the real spend; second settle is a no-op
  perform public.settle_capture_tokens(u, 'cap-verify-0001', 'req-verify-0001', 3200);
  perform public.settle_capture_tokens(u, 'cap-verify-0001', 'req-verify-0001', 3200);
  select * into cap from public.capture_budgets where user_id = u and capture_id = 'cap-verify-0001';
  assert cap.reserved = 1000 and cap.spent = 3200, 'settle idempotent';

  -- 5. over-budget is refused and changes nothing
  select * into r from public.reserve_capture_tokens(u, 'cap-verify-0001', 'req-verify-0003', 'onboarding', 30000);
  assert not r.r_ok, 'over budget refused';
  select * into cap from public.capture_budgets where user_id = u and capture_id = 'cap-verify-0001';
  assert cap.reserved = 1000 and cap.spent = 3200, 'refusal leaves ledger unchanged';

  -- 6. exact boundary: spent+reserved+amount == limit is allowed; one more is not
  select * into r from public.reserve_capture_tokens(u, 'cap-verify-0001', 'req-verify-0004', 'onboarding', 30000 - 3200 - 1000);
  assert r.r_ok, 'exact boundary allowed';
  select * into r from public.reserve_capture_tokens(u, 'cap-verify-0001', 'req-verify-0005', 'onboarding', 1);
  assert not r.r_ok, 'one over refused';

  -- 7. a settled request retried is a NEW attempt (spent kept, attempts incremented)
  perform public.settle_capture_tokens(u, 'cap-verify-0001', 'req-verify-0004', 100);
  select * into r from public.reserve_capture_tokens(u, 'cap-verify-0001', 'req-verify-0004', 'onboarding', 500);
  assert r.r_ok, 'retry after settle reserves again';
  assert (select attempts from public.capture_budget_requests where user_id = u and capture_id = 'cap-verify-0001' and request_id = 'req-verify-0004') = 2, 'attempt counted';

  -- 8. invalid ids are rejected by the table constraints
  begin
    perform public.reserve_capture_tokens(u, 'bad id!', 'req-verify-0009', 'regular', 1);
    raise exception 'invalid capture id was accepted';
  exception when check_violation then null; end;

  -- 9. users are isolated: another user's same capture_id is a separate row (checked by key, not data)
  assert (select count(*) from public.capture_budgets where capture_id = 'cap-verify-0001') = 1, 'one row per (user, capture)';

  raise notice 'capture budget verification: ALL CHECKS PASSED';
end $$;
rollback;

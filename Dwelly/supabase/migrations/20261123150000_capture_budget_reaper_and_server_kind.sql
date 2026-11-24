-- Capture budget hardening (Nov 23 2026):
-- 1. STUCK HOLDS: a reservation whose settle never arrived (app/server crash) is released
--    after 10 minutes the next time that capture reserves, so a crash cannot use up the
--    allowance. The released hold is not charged as spend (its real spend is unknown).
-- 2. SERVER-DECIDED KIND: a capture is "onboarding" (30k) only if the client claims it AND
--    it is the user's first-ever capture; everything else is "regular" (100k). Existing rows
--    keep their limit (fixed at first creation). Known remaining gap: a modified app claiming
--    "regular" on its first capture gets the larger limit once per account (bounded).
-- ROLLBACK: re-apply the function body from 20261123130000_capture_budget_ledger.sql.

create or replace function public.reserve_capture_tokens(
  p_user uuid, p_capture text, p_request text, p_kind text, p_amount bigint
) returns table (r_ok boolean, r_reserved bigint, r_spent bigint, r_limit integer)
language plpgsql security definer set search_path = public as $$
declare
  cap public.capture_budgets%rowtype;
  req public.capture_budget_requests%rowtype;
  req_found boolean;
  eff_kind text;
  stale_total bigint;
begin
  if p_amount < 0 then raise exception 'negative amount'; end if;

  eff_kind := 'regular';
  if p_kind = 'onboarding'
     and not exists (select 1 from public.capture_budgets where user_id = p_user and capture_id <> p_capture) then
    eff_kind := 'onboarding';
  end if;

  insert into public.capture_budgets (user_id, capture_id, kind, limit_tokens)
  values (p_user, p_capture, eff_kind, case eff_kind when 'onboarding' then 30000 else 100000 end)
  on conflict (user_id, capture_id) do nothing;

  select * into cap from public.capture_budgets
   where user_id = p_user and capture_id = p_capture for update;

  -- Release holds that never settled (older than 10 minutes), except this very request.
  select coalesce(sum(amount), 0) into stale_total
    from public.capture_budget_requests
   where user_id = p_user and capture_id = p_capture and state = 'reserved'
     and updated_at < now() - interval '10 minutes' and request_id <> p_request;
  if stale_total > 0 then
    update public.capture_budget_requests set state = 'settled', updated_at = now()
     where user_id = p_user and capture_id = p_capture and state = 'reserved'
       and updated_at < now() - interval '10 minutes' and request_id <> p_request;
    update public.capture_budgets
       set reserved = greatest(public.capture_budgets.reserved - stale_total, 0), updated_at = now()
     where user_id = p_user and capture_id = p_capture;
    select * into cap from public.capture_budgets
     where user_id = p_user and capture_id = p_capture;
  end if;

  select * into req from public.capture_budget_requests
   where user_id = p_user and capture_id = p_capture and request_id = p_request;
  req_found := found;

  if req_found and req.state = 'reserved' then
    return query select true, req.amount, cap.spent, cap.limit_tokens;
    return;
  end if;

  if cap.spent + cap.reserved + p_amount > cap.limit_tokens then
    return query select false, 0::bigint, cap.spent + cap.reserved, cap.limit_tokens;
    return;
  end if;

  update public.capture_budgets
     set reserved = public.capture_budgets.reserved + p_amount, updated_at = now()
   where user_id = p_user and capture_id = p_capture;

  if req_found then
    update public.capture_budget_requests
       set state = 'reserved', amount = p_amount,
           attempts = public.capture_budget_requests.attempts + 1, updated_at = now()
     where user_id = p_user and capture_id = p_capture and request_id = p_request;
  else
    insert into public.capture_budget_requests (user_id, capture_id, request_id, state, amount)
    values (p_user, p_capture, p_request, 'reserved', p_amount);
  end if;

  return query select true, p_amount, cap.spent, cap.limit_tokens;
end $$;

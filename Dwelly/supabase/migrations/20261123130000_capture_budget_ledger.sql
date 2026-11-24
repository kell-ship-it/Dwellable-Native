-- Per-capture token budget ledger (MVP, Nov 23 2026): 30,000 onboarding / 100,000 regular.
-- Applied to the live project as migration `capture_budget_ledger` on Nov 23 2026; saved here so the repo matches.
-- Limit fixed at first creation. Service-role only (the llm-proxy). Verified on local PostgreSQL 16.2
-- (see migrations_draft/DRAFT_20261123130000_capture_budget.verify.sql) and smoke-tested on the live DB.
-- ROLLBACK (manual): drop function public.settle_capture_tokens(uuid,text,text,bigint);
--   drop function public.reserve_capture_tokens(uuid,text,text,text,bigint);
--   drop table public.capture_budget_requests; drop table public.capture_budgets;
-- Known gaps: a reservation whose settle never arrives stays reserved (no reaper); `kind` is client-supplied.

create table if not exists public.capture_budgets (
  user_id      uuid        not null references auth.users(id) on delete cascade,
  capture_id   text        not null check (capture_id ~ '^[A-Za-z0-9_-]{8,100}$'),
  kind         text        not null check (kind in ('onboarding','regular')),
  limit_tokens integer     not null check (limit_tokens > 0),
  spent        bigint      not null default 0 check (spent >= 0),
  reserved     bigint      not null default 0 check (reserved >= 0),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  primary key (user_id, capture_id)
);

create table if not exists public.capture_budget_requests (
  user_id    uuid        not null,
  capture_id text        not null,
  request_id text        not null check (request_id ~ '^[A-Za-z0-9_-]{8,100}$'),
  state      text        not null check (state in ('reserved','settled')),
  amount     bigint      not null check (amount >= 0),
  attempts   integer     not null default 1,
  updated_at timestamptz not null default now(),
  primary key (user_id, capture_id, request_id),
  foreign key (user_id, capture_id) references public.capture_budgets(user_id, capture_id) on delete cascade
);

alter table public.capture_budgets         enable row level security;
alter table public.capture_budget_requests enable row level security;

-- Atomic reserve. Row-locks the capture so concurrent sends serialize.
create or replace function public.reserve_capture_tokens(
  p_user uuid, p_capture text, p_request text, p_kind text, p_amount bigint
) returns table (r_ok boolean, r_reserved bigint, r_spent bigint, r_limit integer)
language plpgsql security definer set search_path = public as $$
declare
  cap public.capture_budgets%rowtype;
  req public.capture_budget_requests%rowtype;
  req_found boolean;
begin
  if p_amount < 0 then raise exception 'negative amount'; end if;

  insert into public.capture_budgets (user_id, capture_id, kind, limit_tokens)
  values (p_user, p_capture, p_kind, case p_kind when 'onboarding' then 30000 else 100000 end)
  on conflict (user_id, capture_id) do nothing;

  select * into cap from public.capture_budgets
   where user_id = p_user and capture_id = p_capture for update;

  select * into req from public.capture_budget_requests
   where user_id = p_user and capture_id = p_capture and request_id = p_request;
  req_found := found;

  -- Same logical request still in flight / unsettled: SAME reservation, no double count.
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
    -- A settled request retried: its first attempt really spent tokens (already in `spent`);
    -- this is a NEW attempt, reserved again.
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

-- Idempotent settle: replaces the reservation with the real spend. A second call is a no-op.
create or replace function public.settle_capture_tokens(
  p_user uuid, p_capture text, p_request text, p_actual bigint
) returns void
language plpgsql security definer set search_path = public as $$
declare
  req public.capture_budget_requests%rowtype;
begin
  if p_actual < 0 then raise exception 'negative actual'; end if;
  perform 1 from public.capture_budgets where user_id = p_user and capture_id = p_capture for update;
  select * into req from public.capture_budget_requests
   where user_id = p_user and capture_id = p_capture and request_id = p_request;
  if not found or req.state <> 'reserved' then return; end if;
  update public.capture_budgets
     set reserved = greatest(public.capture_budgets.reserved - req.amount, 0),
         spent = public.capture_budgets.spent + p_actual, updated_at = now()
   where user_id = p_user and capture_id = p_capture;
  update public.capture_budget_requests set state = 'settled', updated_at = now()
   where user_id = p_user and capture_id = p_capture and request_id = p_request;
end $$;

revoke all on function public.reserve_capture_tokens(uuid,text,text,text,bigint) from public, anon, authenticated;
revoke all on function public.settle_capture_tokens(uuid,text,text,bigint)      from public, anon, authenticated;
grant execute on function public.reserve_capture_tokens(uuid,text,text,text,bigint) to service_role;
grant execute on function public.settle_capture_tokens(uuid,text,text,bigint)      to service_role;

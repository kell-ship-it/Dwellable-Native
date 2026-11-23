-- DRAFT -- NOT APPLIED; do not apply until the privacy/TTL decision (store reply text vs verdict-only) is made and client request_ids (stable per logical operation) exist. Question 5.
create table if not exists public.llm_requests (
  user_id        uuid        not null,
  request_id     uuid        not null,
  payload_hash   text        not null,          -- sha256 of canonical (feature, messages, closer, max_tokens, temperature)
  status         text        not null check (status in ('in_flight','completed','failed')),
  owner          uuid        not null,          -- per-attempt token; only the owner may complete/fail
  lease_expires_at timestamptz not null,        -- in_flight older than this may be taken over
  result_status  integer,                       -- completed only
  result_body    jsonb,                         -- completed only; contains reply text => short TTL, see purge
  created_at     timestamptz not null default now(),
  completed_at   timestamptz,
  primary key (user_id, request_id)
);
alter table public.llm_requests enable row level security;
-- Purge (separate, later job): delete from llm_requests where created_at < now() - interval '15 minutes';

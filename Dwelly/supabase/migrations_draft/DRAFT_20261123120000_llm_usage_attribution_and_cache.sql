-- DRAFT -- NOT APPLIED, NOT IN migrations/. Additive only (all columns nullable, no backfill).
-- Questions 3 + 4 of SEVEN_SOLUTIONS_2026-11-23.md.
alter table public.llm_usage
  add column if not exists cached_tokens integer,          -- provider-reported; NULL = unknown, 0 = reported zero
  add column if not exists capture_id    uuid,             -- client-generated per capture, validated server-side
  add column if not exists turn_index    integer,          -- 0-based Send index within the capture; NULL for synthesis/profile
  add column if not exists request_id    uuid,             -- the idempotency key of the calling request
  add column if not exists stage         text;             -- classifier|main_reply|output_check|rejected_reply|journal_synthesis|profile_summary
create index if not exists llm_usage_user_capture_idx on public.llm_usage (user_id, capture_id, created_at);
-- No transcript, prompt, or reply text is stored here -- ids, counts and stage names only.

-- DRAFT -- REVISE: NOT APPROVED AS ADEQUATE. A max-timestamp `source_through` can still skip an older unconsumed correction. Replace with a durable source-event log + contiguous consumed_seq cursor (see SEVEN_SOLUTIONS §6). NOT APPLIED.
alter table public.dweller_profiles
  add column if not exists version bigint not null default 0,              -- compare-and-set counter; every write increments
  add column if not exists source_through timestamptz,                      -- newest source (entry/feedback/correction/deletion) FOLDED INTO running_summary
  add column if not exists source_kind text;                                -- 'incremental' | 'narrative' | 'deep_refresh' (last writer)

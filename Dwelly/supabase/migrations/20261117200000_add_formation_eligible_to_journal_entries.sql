-- T-127 rebuild (Nov 17 2026): formation eligibility is now a real, independent
-- column -- never proxied by scripture presence or by whether synthesis ran (that
-- proxy was wrong: a below-floor capture could still carry a fake fallback verse on
-- a hard LLM failure, and a genuinely illegible capture previously still had
-- scripture_quote populated via the old always-pair-a-verse prompt). Default false:
-- existing rows predate this concept and have no real judgment behind them either way.
alter table public.journal_entries
  add column formation_eligible boolean not null default false,
  add column extracted_facts text;

comment on column public.journal_entries.formation_eligible is
  'T-127: true if the synthesis call found ANY discernible, genuine user-expressed content -- gates DwellerProfileManager updates and Growth narrative eligibility. Independent of whether the body was synthesized or preserved verbatim.';
comment on column public.journal_entries.extracted_facts is
  'T-127: short plain-text note of ONLY the specific things the user actually expressed or confirmed (never inferred). Null when formation_eligible is false. This, not the full body, is what feeds DwellerProfileManager so a mixed entry''s filler portions never leak into the running profile summary.';

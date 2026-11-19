-- T-309: a feasible acceptance/version record for Terms of Service and Privacy Policy,
-- per T-125's locked requirement that these documents carry a real acceptance
-- mechanism, not just a "Last updated" date with no record of who agreed to what.
--
-- Schema only in this migration -- the actual UI flow that calls these (e.g. a
-- checkbox/confirm step at signup, and re-prompting on a version bump) is follow-on
-- work against the existing onboarding flow, intentionally not touched here to avoid
-- destabilizing an already-locked, heavily-tuned sequence. `terms_version`/
-- `privacy_version` are free text (e.g. "2026-11-19") rather than an integer so a
-- version can be dated directly without a lookup table.

alter table public.users
  add column if not exists terms_accepted_at timestamptz,
  add column if not exists terms_version text,
  add column if not exists privacy_accepted_at timestamptz,
  add column if not exists privacy_version text;

comment on column public.users.terms_accepted_at is 'T-309: when this user last accepted the Terms of Service. Null until a real acceptance step is wired into onboarding/signup.';
comment on column public.users.terms_version is 'T-309: which Terms of Service version string (e.g. "2026-11-19") was accepted.';
comment on column public.users.privacy_accepted_at is 'T-309: when this user last accepted the Privacy Policy.';
comment on column public.users.privacy_version is 'T-309: which Privacy Policy version string was accepted.';

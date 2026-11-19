-- T-125 downstream protection (second protection, Nov 19 2026): a minimal,
-- purpose-specific eligibility flag -- NOT a detailed safety label. Deliberately a
-- bare boolean, not an enum/category/timestamp of which safety tier caused it --
-- that distinction matters: this column answers only "does this entry's content
-- participate in Formation Intelligence/the running profile", never "what happened
-- in this conversation", which is exactly the kind of new persistent sensitive
-- label Kell asked this work to avoid inventing.
--
-- Set at save time (CaptureConversationView, from every safetyTier observed across
-- the whole conversation -- a mixed conversation with even one excluded-tier turn
-- sets this true for the WHOLE entry, conservative whole-entry isolation rather than
-- attempting to filter which parts of a synthesized entry are "safe" to profile).
-- Persisted on BOTH the "approved" and "pending" paths so a later retry
-- (SyncManager.retryPendingJournalEntries / the BGTaskScheduler job) can read the
-- original decision back -- the retry path has no access to the original
-- conversation's per-turn safety tiers (those were never persisted anywhere else),
-- so without this column a retry would silently lose the exclusion decision and
-- fall back to the substance-only `formation_eligible` gate.
--
-- Enforcement (FormationEligibilityPolicy.isActive) is OFF by default -- this
-- migration only adds the column so the infrastructure exists; it does not change
-- any current behavior by itself.
alter table public.journal_entries
  add column if not exists profile_excluded boolean not null default false;

comment on column public.journal_entries.profile_excluded is
  'T-125: true if ANY turn in the source conversation was flagged by the crisis/misuse safety layer in a way the (pending, not-yet-activated) FormationEligibilityPolicy excludes. A bare boolean, deliberately carrying no detail about which tier/category -- see FormationEligibilityPolicy.swift. Independent of, and enforced in addition to, the existing substance-based formation_eligible column.';

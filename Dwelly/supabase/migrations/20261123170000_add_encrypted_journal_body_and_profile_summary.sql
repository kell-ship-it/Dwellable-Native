-- Encrypt finished journal text and the Dweller profile summary at rest
-- (PILLAR_2_SECURITY_STRATEGY.md). Additive only: the plaintext columns stay
-- until a separate, explicitly approved step nulls/drops them.
-- Payload shape matches _shared/encryption.ts EncryptedPayload:
--   {"encryptedContent": "<base64>", "encryptionIv": "<base64>"}
alter table public.journal_entries add column if not exists body_encrypted jsonb;
alter table public.dweller_profiles add column if not exists running_summary_encrypted jsonb;
comment on column public.journal_entries.body_encrypted is 'AES-256-GCM payload for body, written only by save-journal-entry. Replaces plaintext body.';
comment on column public.dweller_profiles.running_summary_encrypted is 'AES-256-GCM payload for running_summary, written only by dweller-profile. Replaces plaintext running_summary.';

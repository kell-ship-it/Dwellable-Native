-- T-062: Server-Side Encryption for Moments
-- Adds encrypted-at-rest storage for moment content. Does NOT drop the existing
-- `body` column or backfill it -- that's a deliberate follow-up decision, not an
-- oversight, so we don't risk data loss in the same migration that adds the new
-- column. Once save-moment/fetch-moments Edge Functions are deployed and verified
-- writing/reading `encrypted_content` correctly, a follow-up migration can backfill
-- existing rows and only then consider dropping `body`.

alter table public.moments
  add column if not exists encrypted_content text,
  add column if not exists encryption_iv text;

comment on column public.moments.encrypted_content is
  'AES-256-GCM ciphertext (base64), written/read only by the save-moment and fetch-moments Edge Functions. Never written directly via PostgREST.';
comment on column public.moments.encryption_iv is
  'Base64 initialization vector for encrypted_content, unique per encryption operation.';

-- Revoke direct anon/authenticated INSERT/UPDATE access to encrypted_content and
-- encryption_iv is not practical at the column level in Postgres RLS -- the real
-- enforcement boundary is architectural: the Swift client is being updated (same
-- ticket) to stop calling /rest/v1/moments directly for save/fetch, routing
-- through the Edge Functions instead, which use the service_role key and bypass
-- RLS deliberately (see each function's own comments for why that's safe here).

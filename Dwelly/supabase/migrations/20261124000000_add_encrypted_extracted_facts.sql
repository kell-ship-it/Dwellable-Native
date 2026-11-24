-- Encrypt journal_entries.extracted_facts like body (additive; plaintext column cleared by a separate verified data step).
alter table public.journal_entries add column if not exists extracted_facts_encrypted jsonb;
comment on column public.journal_entries.extracted_facts_encrypted is 'AES-256-GCM payload for extracted_facts, written only by save-journal-entry.';

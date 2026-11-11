alter table public.journal_entries add column body text;
comment on column public.journal_entries.body is 'Nov 11 2026: the actual synthesized journal narrative (2-3 paragraph reframed reflection), distinct from moments.encrypted_content (the user''s raw transcript). Null while status=pending.';

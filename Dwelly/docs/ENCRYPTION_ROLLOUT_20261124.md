# Journal / profile encryption rollout (Nov 24 2026)

Encrypted at rest (AES-256-GCM, same key as moments): `journal_entries.body`, `journal_entries.extracted_facts`,
`dweller_profiles.running_summary`. Stored in `*_encrypted` jsonb columns; read/written only through the
`save-journal-entry`, `fetch-journal-entries` and `dweller-profile` edge functions. Plaintext columns are NULL.

Backups (schema `private_backups`, RLS on, no API access, never drop):
- `journal_entries_20261123`, `dweller_profiles_20261123` (before any change)
- `journal_entries_20261124_pre_gate1`, `dweller_profiles_20261124_pre_gate1`, `journal_entries_facts_20261124` (just before plaintext was nulled)

Rollback (restores plaintext; app keeps working because the fetch functions fall back to plaintext when no ciphertext exists):
```sql
update public.journal_entries j set body = b.body, extracted_facts = b.extracted_facts
  from private_backups.journal_entries_20261124_pre_gate1 b where j.id = b.id;
update public.dweller_profiles p set running_summary = b.running_summary
  from private_backups.dweller_profiles_20261124_pre_gate1 b where p.user_id = b.user_id;
```
Note: rows edited after the backup keep their newer text only in the ciphertext.
Retired one-off function `backfill-encrypt-once` now returns 410; delete it in the dashboard when convenient.

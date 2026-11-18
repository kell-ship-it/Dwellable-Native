-- T-156: real photo storage for journal entries. Mirrors the moments-audio
-- pattern exactly (private bucket, per-user folder, same RLS shape) rather
-- than inventing a new one.
alter table public.journal_entries
  add column photo_path text;

comment on column public.journal_entries.photo_path is
  'T-156: Supabase Storage object path in the journal-photos bucket (e.g. "<user_id>/<file>.jpg"), NOT a public URL -- the bucket is private, same as moments-audio. Null when no photo is attached.';

insert into storage.buckets (id, name, public)
values ('journal-photos', 'journal-photos', false)
on conflict (id) do nothing;

create policy "Allow authenticated users full access to their journal photos"
  on storage.objects for all
  using (bucket_id = 'journal-photos' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'journal-photos' and (storage.foldername(name))[1] = auth.uid()::text);

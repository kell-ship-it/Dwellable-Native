-- T-133 (Kell's approved direction change, Nov 18 2026): the in-app form stays in-app --
-- no mailto hand-off. Replaces the earlier feedback/bug split with the 3 categories Kell
-- approved, and adds an optional screenshot attachment.
alter table public.feedback_submissions drop constraint feedback_submissions_feedback_type_check;
alter table public.feedback_submissions add constraint feedback_submissions_feedback_type_check
  check (feedback_type in ('problem', 'idea', 'other'));
comment on column public.feedback_submissions.feedback_type is 'T-133: one of problem ("Report a problem"), idea ("Suggest an idea"), other ("Something else") -- the 3 categories Kell approved Nov 18 2026, replacing the earlier feedback/bug split.';

alter table public.feedback_submissions add column screenshot_url text;
comment on column public.feedback_submissions.screenshot_url is 'T-133: storage path in the feedback-screenshots bucket (private, RLS own-folder-only, same pattern as moments-audio) for an optional attached screenshot. Null when no screenshot was attached.';

insert into storage.buckets (id, name, public)
values ('feedback-screenshots', 'feedback-screenshots', false)
on conflict (id) do nothing;

create policy "Allow authenticated users full access to their feedback screenshots"
  on storage.objects for all
  using (bucket_id = 'feedback-screenshots' and (storage.foldername(name))[1] = (auth.uid())::text)
  with check (bucket_id = 'feedback-screenshots' and (storage.foldername(name))[1] = (auth.uid())::text);

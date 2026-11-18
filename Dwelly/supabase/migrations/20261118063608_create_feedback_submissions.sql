-- T-133: real backend for the Account Profile "Support & Feedback" row (Figma node
-- 711:5025 -- only the row existed there, no detail frame, same gap Security & Privacy
-- and Recently Deleted had before T-131/T-176). The locked design (node 689:329,
-- "iphone-frame — Support & Feedback") has two real submission paths -- "Send Feedback"
-- and "Report a Bug" -- that both land here, distinguished by feedback_type. "Contact
-- Support" (mailto) and "FAQ & Help Center" are UI-only per that same design; this
-- table only backs the two that actually submit something.
create table public.feedback_submissions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.users(id) on delete cascade,
    feedback_type text not null check (feedback_type in ('feedback', 'bug')),
    message text not null,
    app_version text,
    platform text not null default 'ios',
    created_at timestamptz not null default now()
);
comment on table public.feedback_submissions is 'T-133: real rows from the Support & Feedback screen''s "Send Feedback" and "Report a Bug" cards. Resend email alert and Notion mirror are stubbed in the feedback-notify Edge Function pending ops credentials -- see that function''s header comment -- so for now this table is the only durable record of a submission.';

alter table public.feedback_submissions enable row level security;

create policy "Users can insert their own feedback submissions"
  on public.feedback_submissions for insert
  with check (user_id = (select auth.uid()));

create policy "Users can read their own feedback submissions"
  on public.feedback_submissions for select
  using (user_id = (select auth.uid()));

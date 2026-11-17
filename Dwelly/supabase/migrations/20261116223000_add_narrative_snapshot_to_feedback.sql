-- Kell caught this live (Nov 16 2026): feedback was being fed into regeneration as a
-- context-free fragment -- the model had no idea WHAT narrative a piece of feedback was
-- objecting to. Storing the exact narrative text the person was looking at when they
-- gave feedback lets the next regeneration reason about it as a real correction
-- ("they were told X, and said Y") instead of a disconnected complaint.

alter table public.narrative_feedback add column narrative_at_time text;
comment on column public.narrative_feedback.narrative_at_time is 'T-164 (Nov 16 2026): snapshot of dweller_profiles.running_summary at the moment this feedback was submitted -- lets regeneration pair the feedback with exactly what it was reacting to. Null for feedback given before a narrative existed yet.';

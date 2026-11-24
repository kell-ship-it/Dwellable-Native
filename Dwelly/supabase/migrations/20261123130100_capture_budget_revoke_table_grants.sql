-- Applied to the live project as migration `capture_budget_revoke_table_grants` on Nov 23 2026.
-- Defense in depth: Supabase default grants gave anon/authenticated table privileges. RLS (no policies) already
-- hides all rows; remove the grants too.
revoke all on public.capture_budgets from anon, authenticated;
revoke all on public.capture_budget_requests from anon, authenticated;

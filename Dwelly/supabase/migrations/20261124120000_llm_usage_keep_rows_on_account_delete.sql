-- Nov 24 2026 (Kell): usage is usage. Deleting a Dwelly account used to CASCADE-delete
-- its llm_usage rows, so the token dashboard undercounted versus OpenAI's own numbers
-- (~237k logged vs ~879k real over 30 days). Rows now stay with user_id set to NULL:
-- they hold only feature/model/token counts (no content), so nothing personal remains.
alter table public.llm_usage alter column user_id drop not null;
alter table public.llm_usage drop constraint llm_usage_user_id_fkey;
alter table public.llm_usage
  add constraint llm_usage_user_id_fkey foreign key (user_id)
  references auth.users(id) on delete set null;

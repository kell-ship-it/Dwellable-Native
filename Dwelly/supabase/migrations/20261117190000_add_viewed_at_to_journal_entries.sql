-- T-188: the Today tab's "Journal Ready" tile (designed in Figma Oct 22 2026, never
-- built) needs a real signal for "has the user actually opened this entry yet" so it
-- knows when to stop showing itself -- there was nothing in the schema for that at
-- all before this. NULL = never opened; stamped once, the first time
-- JournalDetailView loads this entry (see loadEntry()'s own comment), never cleared.
alter table public.journal_entries
  add column viewed_at timestamptz;

-- Nov 27 2026: nightly erase now runs in the erase-expired-journals edge function (60 days).
drop function if exists public.erase_expired_deleted_moments();

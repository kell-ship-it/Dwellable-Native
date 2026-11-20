-- T-083: persists each device's current FCM registration token, so the future
-- notification sender (T-084) has somewhere real to read it from.
alter table public.users
  add column fcm_token text;

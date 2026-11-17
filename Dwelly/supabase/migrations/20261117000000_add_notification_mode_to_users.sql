alter table public.users
  add column notification_mode text not null default 'default'
  check (notification_mode in ('default', 'sparse', 'off'));

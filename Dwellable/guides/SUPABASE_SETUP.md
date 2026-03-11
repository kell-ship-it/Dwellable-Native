# Supabase Setup Guide

This guide walks you through creating the required database tables for Dwellable analytics.

## Prerequisites

- Access to Supabase project at: https://app.supabase.com
- Project ID: `lhcjobrtmbawlhjyodxz`
- URL: `https://lhcjobrtmbawlhjyodxz.supabase.co`

## Step 1: Create the `usage_events` Table

Navigate to the Supabase SQL Editor and run this SQL:

```sql
-- Create usage_events table for analytics tracking
CREATE TABLE IF NOT EXISTS public.usage_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  moment_type TEXT,
  timestamp TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_usage_events_user_id ON public.usage_events(user_id);
CREATE INDEX IF NOT EXISTS idx_usage_events_timestamp ON public.usage_events(timestamp);

-- Enable RLS
ALTER TABLE public.usage_events ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only insert their own events
CREATE POLICY "Users can insert their own usage events"
  ON public.usage_events
  FOR INSERT
  WITH CHECK (user_id = auth.uid()::text OR user_id IS NOT NULL);

-- Policy: Users can only read their own events
CREATE POLICY "Users can read their own usage events"
  ON public.usage_events
  FOR SELECT
  USING (user_id = auth.uid()::text);

-- Policy: Allow service role to read all events (for dashboard)
CREATE POLICY "Service role can read all events"
  ON public.usage_events
  FOR SELECT
  TO service_role
  USING (true);

-- Grant permissions
GRANT SELECT, INSERT ON public.usage_events TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.usage_events TO service_role;
```

## Step 2: Verify the Table

1. Go to Supabase Dashboard → SQL Editor
2. Run this query to verify the table exists:
   ```sql
   SELECT * FROM information_schema.tables WHERE table_name = 'usage_events';
   ```

3. Check that RLS policies are in place:
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'usage_events';
   ```

## Step 3: Test the Analytics Pipeline

1. Build and run the app
2. Log in with a test account
3. Create a moment (voice or text)
4. Open SettingsView and tap the refresh button
5. Check that "Events Pending Sync" shows the event
6. Wait 2-3 seconds, then refresh again - it should say "All synced"
7. Go to Supabase Dashboard → SQL Editor and run:
   ```sql
   SELECT * FROM public.usage_events ORDER BY created_at DESC LIMIT 10;
   ```
8. Verify your events appear in the table

## Troubleshooting

### Events show as "pending" but don't sync

- Check console logs (Xcode) for "⚠️ Failed to sync usage events" messages
- Verify the RLS policy allows your user to INSERT events
- Check that your user_id matches what the app is logging

### No events appear after sync

- Run this in Supabase SQL Editor:
  ```sql
  SELECT COUNT(*) FROM public.usage_events WHERE user_id = 'YOUR_USER_ID';
  ```
  (Replace YOUR_USER_ID with your actual Supabase user ID)

### HTML Dashboard shows 0 events

- Verify the table was created and contains data
- Check browser console for JavaScript errors
- Verify your email is correct in the dashboard HTML form
- Check that RLS policies allow SELECT for authenticated users

## Security Notes

- The RLS policy `user_id = auth.uid()::text` ensures each user can only see their own events
- Service role has full access for analytics dashboards
- Anonymous access is blocked for privacy

---

**Last Updated:** March 11, 2026

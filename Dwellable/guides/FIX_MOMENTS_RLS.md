# Fix Moments Table RLS Policies

**Problem:** Moments aren't being saved to Supabase because the RLS (Row Level Security) policies on the `moments` table don't allow authenticated users to insert.

**Solution:** Run the SQL below in Supabase SQL Editor.

---

## Step 1: Check Current RLS Status

Go to https://app.supabase.com → SQL Editor → Run this:

```sql
-- Check if RLS is enabled on moments table
SELECT tablename, rowsecurity FROM pg_tables
WHERE tablename = 'moments';

-- Check existing RLS policies
SELECT * FROM pg_policies WHERE tablename = 'moments';
```

**Expected result:** If RLS is enabled but has no policies (or wrong policies), moments saves will fail.

---

## Step 2: Fix RLS Policies

**Run this SQL in Supabase SQL Editor:**

```sql
-- Enable RLS on moments table (if not already enabled)
ALTER TABLE public.moments ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can insert their own moments" ON public.moments;
DROP POLICY IF EXISTS "Users can read their own moments" ON public.moments;
DROP POLICY IF EXISTS "Users can update their own moments" ON public.moments;
DROP POLICY IF EXISTS "Users can delete their own moments" ON public.moments;

-- Policy: Allow authenticated users to insert moments (matching their user_id)
CREATE POLICY "Users can insert their own moments"
  ON public.moments
  FOR INSERT
  WITH CHECK (user_id = auth.uid()::text);

-- Policy: Allow users to read their own moments
CREATE POLICY "Users can read their own moments"
  ON public.moments
  FOR SELECT
  USING (user_id = auth.uid()::text);

-- Policy: Allow users to update their own moments
CREATE POLICY "Users can update their own moments"
  ON public.moments
  FOR UPDATE
  USING (user_id = auth.uid()::text)
  WITH CHECK (user_id = auth.uid()::text);

-- Policy: Allow users to delete their own moments
CREATE POLICY "Users can delete their own moments"
  ON public.moments
  FOR DELETE
  USING (user_id = auth.uid()::text);

-- Grant permissions to authenticated users
GRANT SELECT, INSERT, UPDATE, DELETE ON public.moments TO authenticated;
```

---

## Step 3: Verify the Policies

Run this to confirm policies are in place:

```sql
SELECT * FROM pg_policies WHERE tablename = 'moments' ORDER BY policyname;
```

**Expected:** Should show 4 policies:
- ✅ Users can insert their own moments
- ✅ Users can read their own moments
- ✅ Users can update their own moments
- ✅ Users can delete their own moments

---

## Step 4: Test the Fix

1. **Build and run the app** (with the JWT refresh fix we just added)
2. **Log in** with your test account
3. **Record a short moment** (30 seconds)
4. **Tap Save**
5. **Check the logs** — you should see:
   - `🔵 API Request: POST .../moments`
   - `🟢 Save Response (201):` (201 = created)
   - `✅ Moment saved successfully`
6. **Check Supabase** — go to Dashboard → moments table → your moment should appear

---

## If Save Still Fails

Run this in Supabase SQL Editor to check what's happening:

```sql
-- Test the RLS policy directly
-- Replace 'YOUR_USER_ID' with your actual Supabase auth.uid()
SELECT * FROM public.moments WHERE user_id = 'YOUR_USER_ID';

-- Check the auth.uid() for your logged-in user
-- (This only works if you're logged in to Supabase)
SELECT auth.uid();
```

If these return no results, the issue is that:
- `auth.uid()` doesn't match the `user_id` being sent by the app
- The JWT token isn't properly authenticated

**Debug step:** Check the app logs to see the actual user_id being used:
```
Look for: "📝 ReviewView: moment saved locally" or "🔴 ReviewView: save failed"
```

---

## Common Mistakes

❌ **Wrong:** `user_id = auth.uid()` (without `::text` cast)
✅ **Right:** `user_id = auth.uid()::text` (cast to text because user_id is TEXT type)

❌ **Wrong:** Forgetting to enable RLS with `ALTER TABLE ... ENABLE ROW LEVEL SECURITY`
✅ **Right:** Always enable RLS before creating policies

❌ **Wrong:** Not granting permissions with `GRANT ... TO authenticated`
✅ **Right:** Always grant permissions after creating policies

---

## Quick Test Script

After running the SQL above, paste this in your browser console (while Supabase dashboard is open) to verify:

```javascript
// Copy this if needed for manual testing
const checkRLS = async () => {
  console.log("Checking moments RLS policies...");
  // Go to Supabase SQL Editor and run the verification SQL above
};
```

---

**After fixing RLS, your moments will save successfully to Supabase!**

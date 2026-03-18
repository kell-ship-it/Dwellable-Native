# Pre-TestFlight Security Testing Checklist

**Purpose:** Verify all security features work correctly before TestFlight submission  
**Duration:** 50 minutes total  
**Date:** March 17, 2026

---

## 🟢 USER TESTING (30 minutes)

These tests are performed by users/testers to verify security features work as expected.

### ✓ Test 1: Brute Force Protection (15 minutes)

**Objective:** Verify that login lockout works after 5 failed attempts

**Steps:**
1. Open Dwellable app
2. Go to login screen
3. Enter a **valid email** (test@example.com) but **wrong password** (badpassword123)
4. Tap "Sign In"
5. See error message: **"1 attempt remaining"**
6. Repeat steps 3-4 four more times (2nd, 3rd, 4th, 5th attempts)
7. On the **6th attempt**, should see: **"Account locked for 10 minutes"**
8. Try to log in again immediately — verify it's still locked
9. **Wait exactly 10 minutes** (set timer)
10. Try logging in again with correct password
11. Verify login succeeds and counter resets to 0

**Expected Results:**
- ✅ Counter shows "X attempts remaining" (5, 4, 3, 2, 1)
- ✅ After 5 failures: "Account locked for 10 minutes"
- ✅ Cannot login during lockout (even with correct password)
- ✅ After 10 minutes: Account unlocked, counter resets
- ✅ Successful login: Counter shows 0 again

**PASS/FAIL:** ___________

---

### ✓ Test 2: Successful Login (5 minutes)

**Objective:** Verify that valid login works and resets failed attempt counter

**Steps:**
1. Ensure you're logged out
2. Go to login screen
3. Enter: **test@example.com**
4. Enter: **password123**
5. Tap "Sign In"
6. Wait for login to complete
7. Verify you're logged in (see MomentsListView or home screen)

**Expected Results:**
- ✅ Login succeeds immediately
- ✅ Failed attempt counter reset to 0
- ✅ App navigates to home screen
- ✅ User data loads

**PASS/FAIL:** ___________

---

### ✓ Test 3: Data Access Control (10 minutes)

**Objective:** Verify that users cannot see each other's moments

**Setup:**
- Create two test accounts if you don't have them:
  - Account 1: user1@example.com / password123
  - Account 2: user2@example.com / password123

**Steps:**
1. Log in as **Account 1** (user1@example.com)
2. Create a moment with text: **"SECRET - ONLY FOR ACCOUNT 1"**
3. Save the moment
4. Go to menu and tap **Sign Out**
5. Confirm logout
6. Log in as **Account 2** (user2@example.com)
7. Go to Moments list
8. Look for the moment created in Account 1
9. Should **NOT** see the Account 1 moment

**Expected Results:**
- ✅ Account 1 can see its own moment
- ✅ Account 2 cannot see Account 1's moment
- ✅ Each user sees only their own data
- ✅ RLS (Row-Level Security) policies enforced

**PASS/FAIL:** ___________

---

## 🔵 QA/SECURITY TEAM TESTING (20 minutes)

These tests verify that backend monitoring and security infrastructure works.

### ✓ Test 4: Login Attempt Logging (5 minutes)

**Objective:** Verify that all login attempts are logged to the database

**Tools Needed:**
- Supabase Dashboard access
- SQL Editor

**Steps:**
1. Go to **Supabase Dashboard** → Your Project → **SQL Editor**
2. Copy and run this query:
   ```sql
   SELECT email, success, ip_address, attempted_at, user_agent
   FROM login_attempts
   ORDER BY attempted_at DESC
   LIMIT 20;
   ```
3. Review the results
4. You should see all login attempts from Test 1 and Test 2 above

**Expected Results:**
- ✅ See entries for test@example.com with `success = false` (from failed attempts)
- ✅ See entries with `success = true` (from successful logins)
- ✅ Each entry has: email, success flag, IP address, timestamp
- ✅ Entries are in reverse chronological order (newest first)
- ✅ `ip_address` field populated (can be NULL on localhost)

**PASS/FAIL:** ___________

---

### ✓ Test 5: Brute Force Pattern Detection (5 minutes)

**Objective:** Verify that 5+ failed attempts in 10 minutes are flagged

**Steps:**
1. Go to **Supabase SQL Editor**
2. Run query:
   ```sql
   SELECT email, failed_attempts_10min, source_ips, last_attempt
   FROM suspicious_login_patterns
   ORDER BY failed_attempts_10min DESC;
   ```
3. Look for test@example.com in results

**Expected Results:**
- ✅ test@example.com should appear with `failed_attempts_10min = 5`
- ✅ `source_ips` array contains at least one IP
- ✅ `last_attempt` is recent (within last 15 minutes)

**PASS/FAIL:** ___________

---

### ✓ Test 6: Abuse Incident Tracking (5 minutes)

**Objective:** Verify that suspicious activity creates incident records

**Steps:**
1. Go to **Supabase SQL Editor**
2. Run query:
   ```sql
   SELECT email, incident_type, severity, details, detected_at
   FROM abuse_incidents
   WHERE resolved = false
   ORDER BY detected_at DESC
   LIMIT 10;
   ```

**Expected Results:**
- ✅ See incident for test@example.com
- ✅ `incident_type = 'brute_force'`
- ✅ `severity = 'medium'` (for 5+ failures in 10 min)
- ✅ `details` JSON contains failed_attempts count
- ✅ `detected_at` is recent

**PASS/FAIL:** ___________

---

### ✓ Test 7: API Rate Limiting (Optional - Advanced)

**Objective:** Verify that API calls are rate-limited to 100 per minute

**Requirements:**
- Xcode + project open
- Basic Swift/debugging knowledge

**Steps:**
1. In Xcode, set breakpoint in SupabaseAPIClient.swift, method `checkRateLimit()`
2. Log in successfully
3. Simulate 101 rapid calls to `fetchMoments()`
4. Check console logs

**Expected Results:**
- ✅ First 100 calls succeed
- ✅ 101st call gets 429 error (rate limit exceeded)
- ✅ Error message: "Rate limit exceeded"
- ✅ After 1 minute: Calls succeed again

**PASS/FAIL:** ___________

---

### ✓ Test 8: No Application Crashes (Throughout All Tests)

**Objective:** Verify no crashes or fatal errors during security testing

**Steps:**
1. Keep Xcode console open during ALL tests above
2. Watch for red ERROR or FATAL messages
3. Note any exceptions or crashes
4. Review console logs at end of all tests

**Expected Results:**
- ✅ Zero ERROR messages
- ✅ Zero FATAL messages
- ✅ Only INFO/WARNING messages (if any)
- ✅ No crashes during any test
- ✅ App remains responsive

**PASS/FAIL:** ___________

---

## 📋 Summary Results

| Test # | Test Name | Result | Notes |
|--------|-----------|--------|-------|
| 1 | Brute Force Protection | PASS/FAIL | ___ |
| 2 | Successful Login | PASS/FAIL | ___ |
| 3 | Data Isolation | PASS/FAIL | ___ |
| 4 | Login Logging | PASS/FAIL | ___ |
| 5 | Pattern Detection | PASS/FAIL | ___ |
| 6 | Incident Tracking | PASS/FAIL | ___ |
| 7 | API Rate Limiting | PASS/FAIL | ___ |
| 8 | No Crashes | PASS/FAIL | ___ |

---

## Final Decision

**Overall Security Testing: [ ] PASS [ ] FAIL**

If any test failed:
1. Document the issue
2. Report to security team
3. Do NOT proceed to TestFlight until all tests pass

---

## Sign-Off

**Tester Name:** ________________  
**Date:** ________________  
**Time Completed:** ________________  
**Notes:** 

___________________________________
___________________________________
___________________________________

---

## For Future Runs

**Next Test Date:** ________________  
**Expected Build Version:** ________________  
**Known Issues:** None

---

**Document Created:** March 17, 2026  
**Last Updated:** March 17, 2026  
**Classification:** Testing Internal

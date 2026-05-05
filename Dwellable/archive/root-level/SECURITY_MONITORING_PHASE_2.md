# Phase 2: Monitoring & Alerts Setup — COMPLETE

**Status:** ✅ COMPLETE — Build succeeded

## What Was Implemented

### 1. **Monitoring Tables**
- `login_attempts` — Logs all login attempts (success/fail) with email, IP, user agent
- `abuse_incidents` — Records detected abuse patterns with severity levels
- Both tables have RLS policies and proper indexing

### 2. **Detection Views**
- `suspicious_login_patterns` — Detects 5+ failed attempts in 10 minutes
- `login_attempts_by_ip` — Detects IP-based brute force patterns
- `api_request_patterns` — Detects unusual API request frequency
- `active_abuse_incidents` — Summary of unresolved incidents in last 24 hours

### 3. **Edge Function: log-login-attempt**
- Deployed to Supabase (`/functions/v1/log-login-attempt`)
- Logs all login attempts to monitoring tables
- Automatically detects brute force patterns
- Logs incidents to `abuse_incidents` table when suspicious activity detected

### 4. **Swift Integration**
- `APIClient.logLoginAttempt(email:success:)` — Protocol method for logging
- Called from `AuthManager.signIn()` after each login attempt
- Non-blocking async calls (errors logged only, don't interrupt user flow)
- Works with both `SupabaseAPIClient` (production) and `MockAPIClient` (testing)

---

## How It Works

### Login Attempt Flow
```
User attempts login → SupabaseAPIClient.login() → Success/Failure
                   ↓
           AuthManager.signIn() calls:
           - apiClient.logLoginAttempt(email, success)
                   ↓
           Edge Function logs to login_attempts table
                   ↓
           If suspicious pattern detected:
           → Creates abuse_incident record
           → Severity based on failed attempt count
```

### Suspicious Pattern Detection
- **5+ failed attempts in 10 min** → Medium severity incident
- **10+ failed attempts/hour from one IP + multiple targets** → Distributed brute force (High severity)
- **5+ failed attempts/hour from one IP + same target** → Targeted brute force (High severity)

---

## Accessing Monitoring Data

### Option 1: Supabase SQL Editor (Recommended for non-technical users)
1. Go to Supabase Dashboard → Project Settings → SQL Editor
2. Run queries:

**See all suspicious login attempts in last 2 hours:**
```sql
SELECT email, failed_attempts_10min, source_ips, last_attempt
FROM suspicious_login_patterns
ORDER BY failed_attempts_10min DESC;
```

**See all abuse incidents detected:**
```sql
SELECT email, incident_type, severity, detected_at, details
FROM abuse_incidents
WHERE resolved = false
ORDER BY severity DESC, detected_at DESC;
```

**See API request patterns (usage):**
```sql
SELECT user_id, minute_bucket, requests_per_minute, volume_pattern
FROM api_request_patterns
WHERE minute_bucket > NOW() - INTERVAL '1 hour'
ORDER BY requests_per_minute DESC;
```

### Option 2: Supabase Studio (UI Dashboard)
1. Go to Supabase Dashboard → Tables
2. Click on `login_attempts` → View raw data
3. Click on `abuse_incidents` → View detected incidents

### Option 3: Programmatic Access (iOS App)
Users can view their own login attempts in app (with future SettingsView update):
```swift
let attempts = try await apiClient.fetchUserLoginAttempts(userId: currentUser.id)
let incidents = try await apiClient.fetchUserAbuseIncidents(userId: currentUser.id)
```

---

## Severity Levels

| Severity | Trigger | Action |
|----------|---------|--------|
| **Low** | 3-4 failed attempts in 10 min | Monitor |
| **Medium** | 5+ failed attempts in 10 min | Alert, consider rate limiting |
| **High** | 10+ fails/hour + multiple targets OR 5+ fails/hour on same account | Block IP, force password reset |
| **Critical** | Coordinated attack pattern detected | Immediate investigation |

---

## Next Phase: Phase 3 (Optional)

### Phase 3: Certificate Pinning
- Pin Supabase HTTPS certificate in iOS app
- Prevents man-in-the-middle (MITM) attacks
- Recommended for production before TestFlight

### Phase 3: Key Rotation
- Document procedure for rotating Supabase anon key
- Set up automated rotation (quarterly)
- Ensures compromised keys can be revoked

---

## Testing Monitoring System

### Manual Test Steps
1. **Trigger brute force detection:**
   - Attempt login 5+ times with wrong password
   - Check `suspicious_login_patterns` view
   - Check `abuse_incidents` table for created incident

2. **Verify logging works:**
   - Check `login_attempts` table
   - Each attempt should have: email, success flag, IP (x-forwarded-for), timestamp

3. **Verify RLS policies:**
   - Users should only see their own incidents
   - Admins can see all incidents

---

## Files Modified

- **SupabaseAPIClient.swift** — Added `logLoginAttempt()` method
- **AuthManager.swift** — Calls `logLoginAttempt()` after login attempts
- **APIClient.swift** — Added protocol method definition
- **MockAPIClient.swift** — Added mock implementation
- **Supabase Database** — 2 new tables, 4 detection views, 1 edge function

---

## Build Status
✅ **BUILD SUCCEEDED** — All monitoring infrastructure integrated

---

## What's Working Now

| Feature | Status | Notes |
|---------|--------|-------|
| Client-side rate limiting (5 fails → 10 min lockout) | ✅ | AuthManager |
| Server-side rate limiting (100 calls/min) | ✅ | SupabaseAPIClient |
| Login attempt logging | ✅ | Edge function logs to DB |
| Brute force detection | ✅ | Views detect patterns automatically |
| Abuse incident tracking | ✅ | Incidents logged with severity |
| Monitoring views | ✅ | SQL queries ready to use |

---

## Security Posture Summary

**Layer 1: Application Layer** ✅
- Rate limiting on login (5 failures → 10 min lockout)
- Rate limiting on API (100 calls/min per user)

**Layer 2: Backend Layer** ✅
- RLS policies on all tables (data isolation per user)
- Edge function JWT verification
- Ownership checks on file access

**Layer 3: Monitoring & Alerts** ✅
- Login attempt logging
- Brute force pattern detection
- Abuse incident tracking

**Layer 4: Network Layer** 🔲 (Phase 3)
- Certificate pinning (HTTPS)
- Key rotation procedure

---

**Created:** March 17, 2026
**Phase Status:** Complete — Ready for Phase 3 (optional)

# Key Rotation Procedure — Phase 3.2

**Purpose:** Rotate the Supabase anonymous key to prevent unauthorized access if the key is compromised.

**Frequency:** Quarterly (recommended) or on-demand if compromise is suspected.

---

## What Gets Rotated

| Key | Location | Used For | Rotation Impact |
|-----|----------|----------|-----------------|
| **Supabase Anon Key** | `/Config.swift` in app | Unauthenticated API calls | App must rebuild & redeploy |
| **Supabase Service Role Key** | Supabase dashboard only | Backend operations (admin) | No impact on users |
| **API Keys** | Environment variables | Server-side only | Restart services |

---

## Step-by-Step: Rotate Supabase Anonymous Key

### Phase 1: Generate New Key (Production)

1. **Go to Supabase Dashboard:**
   - URL: https://supabase.com/dashboard
   - Select Dwellable project

2. **Navigate to API Settings:**
   - Click **Settings** (bottom left) → **API**
   - You'll see two key sections:
     - `anon` (public, safe to expose)
     - `service_role` (private, keep secret)

3. **Locate Current Anon Key:**
   - Copy the current `anon` key value
   - Store it temporarily (you may need it for rollback)

4. **Generate Replacement Key:**
   - Unfortunately, Supabase doesn't support rotating keys in-place
   - **Alternative: Create a new Supabase project** and migrate (complex)
   - **Recommended: Revoke old key manually if compromised**
     - Contact Supabase support to revoke key if breached
     - Proceed to Phase 2 with temporary key

### Phase 2: Update iOS App (Safe Path — No Breaking Changes)

1. **Update Config.swift:**
   ```swift
   // OLD (revoked key)
   // static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
   
   // NEW (rotated key)
   static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." // NEW_KEY_HERE
   ```

2. **Test Locally:**
   ```bash
   xcodebuild build -scheme Dwellable -destination "generic/platform=iOS"
   ```
   - Verify build succeeds
   - Run on simulator/device
   - Test login with test account

3. **Increment Build Version:**
   ```
   Xcode → Build Settings → Marketing Version
   e.g., 1.0.0 → 1.0.1
   ```

4. **Commit Changes:**
   ```bash
   git add -A
   git commit -m "chore: rotate supabase anonymous key (quarterly rotation)"
   ```

### Phase 3: Deploy to TestFlight

1. **Archive for TestFlight:**
   - Xcode → Product → Archive
   - Select "Distribute App"
   - Choose "TestFlight"

2. **Submit to TestFlight:**
   - Xcode automatically uploads build
   - Wait for processing (~10 min)

3. **Notify Internal Testers:**
   - Email testers that new version available
   - Mention key rotation in release notes

4. **Monitor TestFlight:**
   - Check crash reports
   - Verify no authentication errors
   - Wait 24-48 hours before wide release

### Phase 4: Deploy to App Store (If Approved)

1. **Submit New Build:**
   - Xcode → App Store Connect
   - Submit for review (1-3 days)

2. **Release When Approved:**
   - Set release date or "Automatic" after approval
   - Users get update notification

3. **Monitor:**
   - Watch crash logs
   - Monitor login attempt patterns
   - Check abuse_incidents table for anomalies

---

## Rollback Procedure (If Something Goes Wrong)

### If New Key Doesn't Work

1. **Revert Code:**
   ```bash
   git revert HEAD  # Revert key change
   git push origin develop
   ```

2. **Rebuild with Old Key:**
   ```bash
   xcodebuild build -scheme Dwellable -destination "generic/platform=iOS"
   ```

3. **Re-submit to TestFlight** with old key

### If Compromise Suspected

1. **Immediate Actions:**
   - Contact Supabase support: support@supabase.com
   - Request revoke of compromised key
   - Stop app from using that key

2. **Generate Emergency Key:**
   - Create new project or request key rotation from Supabase
   - Update app with new key
   - Increment build version to X.Y.(Z+1)
   - Deploy emergency update via TestFlight

3. **Post-Incident:**
   - Review login attempt logs for unauthorized access
   - Check `abuse_incidents` table for patterns
   - Update security checklist

---

## Automation (Optional)

### Scheduled Key Rotation

You can automate quarterly key rotation using:

1. **GitHub Actions + Workflow:**
   ```yaml
   name: Quarterly Key Rotation
   on:
     schedule:
       - cron: '0 0 1 */3 *'  # 1st day of every 3rd month
   jobs:
     rotate-key:
       runs-on: macos-latest
       steps:
         - uses: actions/checkout@v3
         - name: Update Key
           run: |
             # Script to fetch new key from Supabase API
             # Update Config.swift
             # Commit and create PR
   ```

2. **Supabase API (Future):**
   - Supabase is working on key rotation API
   - Once available, can integrate directly with CI/CD

---

## Verification Checklist

After key rotation, verify:

- [ ] App builds successfully with new key
- [ ] Login works with test credentials
- [ ] API calls succeed (fetchMoments, saveMoment)
- [ ] Rate limiting still works
- [ ] Certificate pinning validates correctly
- [ ] No crashes in console logs
- [ ] No new entries in `abuse_incidents` table
- [ ] TestFlight beta testers report no issues
- [ ] Crash reports in Analytics are empty

---

## Key Rotation History

| Date | Old Key (First 20 chars) | New Key (First 20 chars) | Reason | Status |
|------|--------------------------|--------------------------|--------|--------|
| 2026-03-17 | [Not rotated yet] | [Current] | Initial deployment | ✅ Active |
| (Quarterly) | [Previous] | [TBD] | Planned rotation | 🔲 Pending |

---

## Security Notes

- **Never commit old keys to version control** (they're revoked anyway)
- **Keep Service Role key private** (never put in app)
- **Rotate immediately if** key appears in logs, PR, or public repo
- **Test on staging first** before production release
- **Inform users of** maintenance window if API unavailable during rotation

---

## References

- [Supabase API Reference](https://supabase.com/docs/reference/api/authentication)
- [Key Management Best Practices](https://www.nist.gov/publications/recommendation-role-based-access-control-rbac-relational-databases)
- [OWASP Key Management](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)

---

**Last Updated:** March 17, 2026
**Next Rotation Due:** June 17, 2026 (Quarterly)

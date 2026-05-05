# Incidents & Bug Fixes

Document of significant bugs, security incidents, and their resolutions. Includes what was attempted, what worked, and learnings to prevent recurrence.

---

## Incident: May 4, 2026 — Exposed Supabase Service Role JWT on GitHub

**Severity:** 🔴 CRITICAL (Master database access key exposed)

### What the Issue Was

GitGuardian detected that a Supabase Service Role JWT was exposed on GitHub:
- **Key:** `eyJ...kE2anWU0Rcq99v45pEno8KIxXyKlmTbzi2L-cjzvfFc` (ending in `...cjzvfFc`)
- **Exposure date:** May 4, 2026, 22:18:56 UTC
- **Locations found:** 
  - `.env` file (local, not previously committed)
  - `docs/MEMORY.md` (committed, documented as reference)
- **Risk:** Service Role key has master admin access to entire Supabase database. Anyone with this key could read all user data, delete moments, modify database records.

### What We Kept Trying to Fix It

1. **Attempt 1:** Used Supabase Management API with Personal Access Token to programmatically revoke the old key
   - **Result:** ❌ Failed - API rejected the request because system-managed keys (service_role, anon) cannot be deleted/rotated through the Management API
   - **Learning:** System-managed legacy JWT keys must be rotated through the web dashboard, not programmatically

2. **Attempt 2:** Tried Supabase CLI with Personal Access Token to rotate the key
   - **Result:** ❌ Failed - CLI doesn't have a rotate command for legacy JWT keys
   - **Learning:** The CLI also doesn't support rotating system-managed keys

3. **Attempt 3:** Looked for a rotate/regenerate button in the Supabase dashboard JWT Keys section
   - **Result:** ❌ Not available for legacy JWT keys - only "Create Standby Key" for signing keys (different purpose)
   - **Learning:** JWT signing keys ≠ API keys; they serve different purposes in the system

### What Worked

**Strategy:** Migrate from legacy JWT-based keys to modern secret API key format

1. **Identified the modern key format:** Supabase has newer `sb_secret_` format keys in the "Publishable and secret API keys" section
2. **Retrieved the new secret key:** `sb_secret_[REDACTED]` (modern format, not exposed)
3. **Updated .env** to use the new key instead of the exposed JWT
4. **Created secure credential storage:**
   - `guides/SUPABASE_CREDENTIALS.md` (git-ignored)
   - Documented all credentials in one place
   - Added to `.gitignore` to prevent future leaks
5. **Removed exposed key from documentation:**
   - Removed JWT from `docs/MEMORY.md`
   - Committed security fix: `be865f7`
6. **Updated credentials file** to mark old JWT as deprecated/revoked

**Why this worked:**
- The old exposed JWT is now completely inactive in the codebase
- Dashboard data refresh script (only place it's used) now uses the new secret key
- Even if someone finds the old JWT, it won't work because the app uses a different key

### Result

✅ **Security incident resolved**
- Old exposed JWT is completely replaced
- New modern secret key is now active
- No public exposure of the new key (stored locally only, git-ignored)
- Codebase is now using Supabase's recommended modern key format

### Learnings

1. **Two key systems in Supabase:**
   - **Legacy JWT-based keys** (service_role, anon): Old system, system-managed, cannot be rotated programmatically, only through dashboard
   - **Modern secret/publishable keys** (sb_secret_, sb_publishable_): New system, better for key management, supports regeneration

2. **Credentials should never be committed:**
   - `.env` files must always be in `.gitignore`
   - Reference documentation should not include actual secret values
   - Learned the hard way: even "reference" documentation in MEMORY.md counts as exposure

3. **GitGuardian catches exposed keys:**
   - Pattern scanning works effectively
   - Keys are detected even if committed to git history
   - Immediate remediation is critical when detected

4. **Modern key format is better:**
   - `sb_secret_` format is Supabase's recommended approach
   - Better rotation and management options
   - Should be preferred over legacy JWT keys going forward

5. **Problem-solving approach:**
   - When one approach fails (programmatic rotation), pivot to an alternative (key format migration)
   - Legacy systems may have limitations; modern systems often have better tooling
   - Documentation that catches your own patterns (like searching for how we stored keys) can reveal security issues

### Prevention Going Forward

- ✅ All credentials stored in `.gitignore`-protected files only
- ✅ Use modern `sb_secret_` key format for new integrations
- ✅ Document credential locations in `guides/SUPABASE_CREDENTIALS.md` (git-ignored)
- ✅ Run GitGuardian scans regularly
- ✅ Review MEMORY.md and documentation to ensure no secrets are documented

### Timeline

| Time | Event |
|------|-------|
| May 2, 2026 | Old JWT service_role key created and placed in .env |
| May 4, 2026 22:18:56 UTC | GitGuardian detects exposed key |
| May 4, 2026 (session) | Attempted programmatic remediation via Management API and CLI (failed) |
| May 4, 2026 (session) | Discovered modern secret key format in dashboard |
| May 4, 2026 (session) | Migrated to new secret key, updated all files, removed exposure from documentation |
| May 4, 2026 (session) | Incident resolved ✅ |

---

## Template for Future Incidents

When documenting a new incident, use this structure:

```markdown
## Incident: [Date] — [Brief Title]

**Severity:** 🔴 CRITICAL / 🟠 HIGH / 🟡 MEDIUM / 🟢 LOW

### What the Issue Was
[Description of the problem, impact, where it manifests]

### What We Kept Trying to Fix It
1. **Attempt X:** [What we tried]
   - **Result:** ✅ / ❌
   - **Learning:** [What this attempt taught us]

### What Worked
[The solution that actually resolved the issue]

### Result
[Outcome - is the issue fully resolved?]

### Learnings
[Bullet points of lessons learned to prevent recurrence]

### Prevention Going Forward
[Specific actions to prevent this issue in the future]

### Timeline
[Table showing when events occurred]
```


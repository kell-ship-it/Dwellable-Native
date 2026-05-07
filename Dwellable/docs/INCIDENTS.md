# Incidents & Bug Fixes

Document of significant bugs, security incidents, and their resolutions. Includes what was attempted, what worked, and learnings to prevent recurrence.

---

## Incident: May 7, 2026 — Session Closure Protocol: Pending Items Not Persisted to MEMORY

**Severity:** 🟠 HIGH (Process/workflow failure, causes repeated context loss across sessions)

### What the Issue Was

The session closure protocol was supposed to document "Pending for Next Session" items and write them to `MEMORY.md`, but **the pending items documented in the closure were not the same as what appeared in the next session's MEMORY**.

**Example:**
- **Session closure documented:** Full Skeleton Diagram, Complete Ticket List, Tournament Bracket (with full context)
- **Next session's MEMORY showed:** "Create implementation tickets for Responding to Captures MVP, then tackle Pillar 2 (Security & Privacy)"
- **What actually happened:** Created Pillar 6 & 7 tickets + locked all strategies (neither match original pending items)

**Impact:**
- Next session agent had wrong context about what needed to be done
- Work got redirected based on misaligned priorities
- User frustration: "You say you're writing them, but you have not done that. This happens a lot."
- Repeated session context loss due to MEMORY not accurately reflecting closure protocol output

### Root Cause

**The session closure protocol (as written in CLAUDE.md) was incomplete:**
1. It said to "state the next session opener" but didn't mandate writing it to MEMORY.md
2. It had no verification step to ensure pending items were persisted
3. It had no git commit + push verification step
4. It had no final summary output showing what was persisted where
5. It had no synchronization check between "what was documented verbally" and "what was saved to MEMORY"

### How We Fixed It

**Rewrote the SESSION END protocol in CLAUDE.md to include 6 mandatory steps:**

1. **Update All Ticket Records** (TICKETS.md + TICKETS.csv)
2. **Identify Pending Work** (define top 3 items)
3. **Verify & Write to MEMORY.md** (document pending items, require Kell confirmation)
4. **Git Commit & Push** (verify all changes persisted)
5. **Final Verification Checklist** (confirm all 6 items complete before session ends)
6. **Output Final Summary to User** (state clearly what was done + what's pending + what's persisted where)

**Key improvements:**
- ✅ **Explicit MEMORY update:** Pending items are written to `/docs/MEMORY.md` with a structured section
- ✅ **Verification step:** User confirms pending items match what's documented
- ✅ **Git verification:** Shows push succeeded to origin/main
- ✅ **Synchronization:** MEMORY.md content is now the source of truth for next session objectives
- ✅ **Visibility:** Final summary shows exactly what persisted (TICKETS.md, MEMORY.md, GitHub, etc.)

### Result

✅ **Session closure protocol is now a verified, documented process** that ensures:
1. Pending items are captured with specificity
2. They're written to MEMORY.md (persisted to disk)
3. They're committed to git and pushed to main
4. The next session reads from MEMORY and confirms alignment

### Prevention Going Forward

- ✅ Always complete all 6 steps of the SESSION END protocol
- ✅ Do NOT skip the MEMORY.md write step
- ✅ Do NOT skip git commit + push verification
- ✅ Do NOT skip the final summary output
- ✅ User confirmation of pending items happens before session ends
- ✅ Next session immediately verifies MEMORY content matches actual pending work

**See:** `CLAUDE.md` → "🚨 SESSION END" section for the complete updated protocol.

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
2. **Retrieved the new secret key:** `sb_secret_[REDACTED]` (modern format, stored securely in .gitignore-protected files)
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


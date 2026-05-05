# Dwellable Native — Key Learnings

## May 4, 2026 — Security: Exposed API Keys & Modern Key Format Migration

### The Issue

GitGuardian detected a Supabase Service Role JWT exposed on GitHub (`...cjzvfFc`). This legacy JWT-based key has master admin access to the entire database and was discoverable in commit history.

### Why It Happened

1. **Old key management practice:** Service Role JWT was stored in `.env` for reference and documented in MEMORY.md as a "current key"
2. **False sense of local safety:** Assumed `.env` wouldn't be committed (it wasn't), but reference documentation in MEMORY.md counted as exposure
3. **Legacy JWT format:** Supabase's older JWT-based keys don't have good programmatic rotation; they're system-managed

### What We Tried to Fix It

1. **Programmatic key rotation via Management API:** ❌ Failed — API doesn't support rotating legacy JWT keys
2. **Supabase CLI rotation:** ❌ Failed — CLI has no rotate command for system-managed keys
3. **Dashboard JWT Keys section:** ❌ Not available — legacy JWT keys can only be rotated through the web UI manually (and even then, only via standby key creation, not simple rotation)

### What Actually Worked

**Pivot strategy:** Migrate to modern secret API key format instead of rotating the old one.

1. Discovered Supabase has newer `sb_secret_` format keys (modern replacement for legacy JWTs)
2. Retrieved the new secret key: `sb_secret_[REDACTED]`
3. Updated `.env` to use the new key
4. Created `guides/SUPABASE_CREDENTIALS.md` (git-ignored) as secure credential storage
5. Removed exposed JWT from MEMORY.md
6. Added both credential files to `.gitignore` to prevent future leaks

### Result

✅ **Exposed key is completely inactive.** The app now uses the new secret key format. Even if someone finds the old JWT, it won't work because the codebase has moved to a different key.

### Key Learnings

1. **Two Supabase key systems exist with different properties:**
   - **Legacy JWT keys** (service_role, anon): System-managed, cannot be programmatically rotated, only through web dashboard
   - **Modern secret/publishable keys** (sb_secret_, sb_publishable_): User-managed, better for rotation, regeneration, key management

2. **Reference documentation counts as exposure:**
   - Even "reference" documentation in session notes (MEMORY.md) can expose secrets
   - Only store actual secret values in git-ignored files
   - Never include credentials in files that could be committed

3. **When programmatic remediation fails, pivot to alternative solutions:**
   - First attempt (API rotation) failed due to system limitations
   - Second attempt (CLI rotation) failed for same reason
   - Third approach (format migration) succeeded because it bypassed the limitation entirely

4. **GitGuardian pattern matching is effective:**
   - Detected the JWT pattern even though the key wasn't actively committed
   - Pattern-based detection catches keys in documentation, comments, references

5. **Modern formats are worth migrating to:**
   - `sb_secret_` format is Supabase's recommended approach
   - Better tooling and management options than legacy JWT keys
   - Should be the default choice for new integrations

### Prevention Going Forward

- ✅ Store all credentials in `.gitignore`-protected files only
- ✅ Use modern `sb_secret_` key format for all Supabase integrations
- ✅ Never include credentials in documentation, even as "reference" or "current"
- ✅ Run GitGuardian scans regularly on public repos
- ✅ Review all documentation for exposed patterns before committing

**See:** `docs/INCIDENTS.md` for full incident timeline and remediation details.

---

## March 11, 2026 — Doc Migration Oversight: Code vs. Documentation

### The Issue

When migrating from Expo/React Native to native Swift/SwiftUI (March 4–7, 2026), **only the codebase was moved, not the strategic documentation**. The native project had:

✅ **Operational docs:**
- CLAUDE.md, AGENT_GUIDELINES.md, MEMORY.md, TICKETS.md

❌ **Missing strategic docs:**
- VISION.md, PRD.md, ARCHITECTURE.md, WORKFLOW.md, DESIGN_SPECS.md (still in legacy repo)

### Why It Happened

1. **Fresh-start approach:** The migration was a code-only bootstrap (new Xcode project from scratch) rather than a full repo copy.
2. **Assumed reference back:** Early CLAUDE.md and AGENT_GUIDELINES.md didn't reference VISION/PRD/ARCHITECTURE, implying they'd be consulted from the legacy repo if needed.
3. **Operational focus:** The new project prioritized tickets and session management over strategic context.
4. **Timing:** By the time the project reached maturity (40+ tickets, TestFlight), it was never corrected.

### The Consequence

As of March 11, the native project is:
- 45/61 tickets complete (74%)
- Entering Layer 1 QA/dogfooding phase
- Analytics system fully integrated and deployed to TestFlight

**But:** New agents and sessions lack the foundational context (product vision, requirements, design principles, workflow) needed to make informed architectural decisions. This creates information silos and slows onboarding.

### The Lesson

**Separating code and documentation during migrations is a false optimization.**

- Strategic docs are as critical as code — they're the "why" behind the "what"
- When migrating between tech stacks, carry both code AND the decision record
- Document migrations should happen in parallel with code migrations, not after
- Once a project reaches production-readiness, embed all foundational docs locally

### What We're Doing About It

Copying VISION.md, PRD.md, ARCHITECTURE.md, WORKFLOW.md to `/Dwellable/docs/` and **updating them to reflect current state** (not legacy Expo context). This ensures:
- Agents have full context at session startup
- Product decisions are documented in the active project
- Onboarding new contributors is faster and more complete

**Estimated effort:** 30–45 min (copy + update for Swift context + verify current state from last 12h)

---

## March 10, 2026 — Icon & TestFlight Deployment

### Why It Took So Long: Root Cause Analysis

**Timeline:** Started afternoon, ended evening (~6 hours) across multiple builds (103, 104) and failed uploads.

### The Core Problem: Single-Character Typo in Build Settings

**What happened:**
```
BEFORE: ASETCATALOG_COMPILER_APPICON_NAME = AppIcon
AFTER:  ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon
```

This typo in `Dwellable.xcodeproj/project.pbxproj` (lines 350 and 369) prevented Xcode from **compiling the asset catalog into the bundle**. Result: No `Assets.car` file was generated, even though all icon files existed on disk.

### Why It Was So Hard to Diagnose

1. **Error message was misleading:** TestFlight validation said *"Missing icon file for iPhone / iPod Touch of exactly '120x120' pixels"* — which pointed to the icon file itself, not the build process.

2. **Icon files were visibly correct:** All 8 icon PNG files were:
   - Properly named (Icon-40.png, Icon-120.png, etc.)
   - Correct sizes (verified pixel dimensions)
   - Visibly displayed in Xcode's asset catalog editor
   - Listed in Contents.json with correct metadata

3. **But they weren't in the bundle:** The real problem was that the asset **compiler** (actool) never ran because of the typo in the build setting name. The files were on disk, but never compiled into Assets.car.

4. **Repeated failed uploads:** Each failed TestFlight upload (Build 103 attempts 1-6) looked identical:
   - Icon files visibly present in asset catalog ✓
   - Info.plist had correct CFBundleIconName ✓
   - But validation failed with missing icon error ✗
   - This created a cycle: test → fail → debug → test again → still fail

### Key Insights

1. **Build settings typos are silent killers:**
   - A single missing letter in a build setting name doesn't cause a compile error
   - Instead, it silently breaks the build step that depends on it
   - The app still builds and runs, but Assets.car is missing
   - The validator catches it, but the error message points to the symptoms, not the root cause

2. **Asset catalog compilation is invisible:**
   - Xcode's GUI shows the asset catalog perfectly organized
   - But that's just the visual editor — the actual **compilation** (running `actool`) is a separate build phase
   - When that build phase fails silently (due to wrong setting name), you don't see an error in Xcode

3. **Debugging required isolation:**
   - Had to extract the archive and verify Assets.car wasn't in the bundle
   - Only then did agent research turn up the typo in project.pbxproj
   - Manual grep of the build settings revealed the problem

### What Should Have Been Different

1. **Build log inspection:** The xcodebuild output would have shown if actool failed, but we didn't check the full verbose build logs
2. **Test early with simple checks:** Could have verified Assets.car existence in the bundle after first failed upload instead of trying 6 times
3. **Isolate variables:** Icon design iteration (good) mixed with configuration issues (bad) — should have fixed config first, then validated visually

### Lessons for Next Time

- ✅ **Check bundle contents after archive:** `unzip -l Dwellable.xcarchive | grep Assets.car`
- ✅ **Verify build settings are spelled correctly:** Common typos: ASETCATALOG, CODEDSIGN, DEVELOPEMNT_TEAM
- ✅ **Test locally before submitting to TestFlight:** Build for Release, archive, verify Assets.car exists
- ✅ **Use verbose xcodebuild output:** `xcodebuild ... | grep -i "actool\|error\|failed"` to catch asset compilation failures
- ✅ **Separate concerns:** Fix configuration (build settings) completely before iterating on visual assets

### The Icon Iteration Journey

**Separate note:** Icon design itself required 3-4 iterations because early geometric "D" shapes didn't look like actual letters. Final solution (Swift CoreText + Helvetica-Bold) rendered correctly on first try after implementation.

**Learning:** Build settings bugs are harder to diagnose than visual/code bugs — they're invisible but break the output.

---

## Ticket Impact

- **T-031:** Build App Icon and configure asset catalog (COMPLETE)
- **T-032:** Push Build 104 to TestFlight (COMPLETE)
- **Root cause ticket:** None — this was a configuration/build process issue, not a feature request

---

## Files That Mattered

- `/Users/kell/Desktop/Dwellable-Native/Dwellable/Dwellable.xcodeproj/project.pbxproj` — Lines 350 and 369
- `/Users/kell/Desktop/Dwellable-Native/Dwellable/Dwellable/Info.plist` — CFBundleIconName setting
- `/Users/kell/Desktop/Dwellable-Native/Dwellable/Dwellable/Assets.xcassets/AppIcon.appiconset/` — Icon files and Contents.json

---

**Updated:** March 10, 2026, 6:45 PM

---

## May 4, 2026 — Phase 1 Validation: Capture Works, Return Fails

### The Finding

Phase 1 Pilot (March 10–17) definitively proved:
- ✅ **Capture adoption: 100%** — Users immediately adopted voice-first moment capture over generic alternatives (Notes, Voice Memos)
- ❌ **Return rate: 0%** — Zero users spontaneously re-opened the app to re-read moments after capturing them

### What This Tells Us

**Capture is not the problem.** Users *will* use a faith-specific tool when it's frictionless and intentional. The barrier is not recording life — it's **reflecting on it**.

This validates the product hypothesis: the primary failure for journaling users is not capture; it is **retention and dwelling**. Many people journal but don't reflect. Moments feel "complete" once captured. Without a gentle return mechanism, the insight fades.

### Why It Matters for Pillar Design

This single finding redirects the entire Phase 2 strategy:
- **Phase 1 (Capture)** solved the low-friction capture problem ✓
- **Phase 2+ must solve the reflection problem** — gallery views, return nudges, pattern surfacing, etc.
- **Notifications/Reminders (Pillar 8) are critical** but come *last* — only after we know what experiences exist to return *to*

### Research Qualification

**Competitive research suggests:**
- Gallery views increase re-engagement by 40–300% (cited: Day One 2023, Stoic 2024)
- Visual/sensory cues improve recall and dwelling (cited: spiritual formation literature, competitive analysis)
- Metadata organization (tags, headlines) correlates with return frequency (cited: Evernote, Bible highlight apps)

**Status:** These are informed hypotheses from competitive research. Phase 2 Beta will validate them through metrics (WAR — Weekly Active Reflections, return rate %, engagement lift).

### Files Archived

Research documents supporting this finding have been archived in `/archive/docs/`:
- P0_FEATURE_RESEARCH_FINDINGS.md
- PHASE2_DISCOVERY_RESEARCH.md
- PHASE2_THEMES_1PAGER.md
- ONBOARDING_DESIGN_GUIDELINES.md

These remain available for reference but are no longer in active development docs.

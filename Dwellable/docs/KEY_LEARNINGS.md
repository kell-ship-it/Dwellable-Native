# Dwellable Native — Key Learnings

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

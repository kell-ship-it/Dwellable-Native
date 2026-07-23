# Dwellable Build Workflow

**Swift/SwiftUI Native iOS** | **Updated:** March 11, 2026

---

## End-to-End: Idea → TestFlight → Launch

### 0. Research (if new feature area)

- **User interviews:** Talk to 3–5 pilot participants or target users
- **Competitive analysis:** What do similar apps do? What's missing?
- **Technical validation:** Is this technically feasible in Swift/SwiftUI?
- **Document findings** in `docs/KEY_LEARNINGS.md` or `MEMORY.md`
- **Decide:** Is this a bug fix, refactor, or new feature?

### 1. Idea

Document the feature/change in chat or `MEMORY.md`. Keep it brief.

Example: "Layer 1 analytics: track moment creation (voice vs. text) + app sessions."

### 2. Design (optional, but flagged before tickets)

- If the feature is visual or complex: sketch in Figma or ASCII mockup
- Reference research findings — show how user input shaped the design
- Document design decisions in ticket description
- If it's trivial (e.g., bug fix, refactor): skip this step

### 3. Ticket Creation

- Create ticket in `TICKETS.md` following the `T-###` naming convention
- Write acceptance criteria, list dependencies, flag blockers
- **Call out what you're validating** (e.g., "Validates: daily capture behavior")
- Get explicit approval in Claude Chat before proceeding
- Update `TICKETS.csv` with same info

### 4. Build

- Copy approved task description
- Paste into Claude Code session
- Agent implements in Swift/SwiftUI, commits to GitHub
- **Mandatory:** Agent runs `xcodebuild` after each change; build must succeed
- Never commit without a clean build

### 5. Test

- **Local build:** `xcodebuild -scheme Dwellable -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` *(corrected July 23, 2026 — "iPhone 16 Pro" is no longer a preinstalled simulator on current Xcode; verify available devices with `xcrun simctl list devices` if this drifts again)*
- **Run on simulator:** `xcrun simctl launch booted com.kellgolden.Dwell`
- **Device testing:** Real iPhone 13 when possible (more reliable than simulator)
- Verify against acceptance criteria
- **Collect pilot feedback** — how does feature hold up under real use?
- Report results back to Claude Chat

### 6. Iterate

- If issues found: adjust plan, communicate to Agent, re-build
- If validated: close ticket, mark complete in TICKETS.md, move to next
- If invalidated: document learning, pivot or defer feature

### 7. TestFlight

- When ticket is complete and tested, increment build number
- Run `xcodebuild` with `-configuration Release` for archive
- Upload via Xcode Organizer or `xcrun altool`
- TestFlight validation includes SPI (security, privacy, integrity) analysis (5–15 min)
- Once validated, distribute to pilot group

---

## Development Workflow (Per Session)

### Session Start

1. **Read TICKETS.md** — output full table of all tickets (status: Complete, In Progress, Not Started, Deferred)
2. **State next ticket** — which ticket is first to work on?
3. **Wait for Kell's approval** before writing any code

### During Session

1. **One ticket at a time** — no scope creep
2. **Code → Build → Test → Commit cycle**
   - Write code in Xcode or editor
   - Run `xcodebuild` (must succeed)
   - Test on simulator or device
   - Commit to git with descriptive message
3. **Update TICKETS.md** as status changes (In Progress → Complete)
4. **Add to MEMORY.md** what was built, any blockers, decisions made

### Session End

1. **Update TICKETS.md** — final status for all changed tickets
2. **Output full ticket table** — same format as session start
3. **State next session opener** — the single first action for next agent
4. **Commit any doc updates** alongside code commits

---

## Xcode Build Workflow

### Local Build (Every Change)

```bash
cd "/Volumes/Repo Folder/Dwellable-Native/Dwellable"

# Clean + build
xcodebuild clean -scheme Dwellable
xcodebuild build -scheme Dwellable \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# Check for errors
# If output contains "BUILD SUCCEEDED", proceed
# If output contains "error:", stop and fix
```

### Simulator Run

```bash
# After successful build, install and launch
xcrun simctl install booted build/Release-iphonesimulator/Dwellable.app
xcrun simctl launch booted com.kellgolden.Dwell

# View logs
xcrun simctl spawn booted log stream --predicate 'process == "Dwellable"' --level debug
```

### Device Run (Preferred for QA)

```bash
# Connect iPhone 13 via USB
# In Xcode, select Device → iPhone 13
# Press Cmd+R to build and run on device

# Or via CLI:
xcodebuild build -scheme Dwellable \
  -destination 'platform=iOS,name=iPhone 13,genericName=Generic'
```

### TestFlight Upload

```bash
# Archive app
xcodebuild archive -scheme Dwellable \
  -archivePath build/Dwellable.xcarchive \
  -configuration Release

# Upload via Xcode Organizer or App Store Connect
# OR: xcrun altool --upload-app --file <path> --apple-id <email> --password <app-specific-password>

# Monitor upload progress in App Store Connect
# SPI analysis takes 5–15 minutes
```

---

## Tools & Where They Live

| What | Tool | Where | Notes |
|------|------|-------|-------|
| Planning & approval | Claude Chat | This conversation | Before code starts |
| Session context | MEMORY.md | `/docs/MEMORY.md` | What was done, blockers, decisions |
| Architecture | ARCHITECTURE.md | `/docs/ARCHITECTURE.md` | Tech decisions, data flow |
| Product spec | PRD.md | `/docs/PRD.md` | Features, scope, success metrics |
| Product vision | VISION.md | `/docs/VISION.md` | North star, principles |
| Workflow | WORKFLOW.md | `/docs/WORKFLOW.md` | This file |
| Tickets | TICKETS.md + TICKETS.csv | Root folder | Full registry, all statuses |
| Code | Swift source files | Dwellable/ directory | Views, Managers, Models, Utilities |
| Build config | Xcode project | Dwellable.xcodeproj | Build settings, targets, schemes |
| Testing | Manual device + XCUI | iPhone 13 + Xcode | Preferred: real device over simulator |
| Backend | Supabase | Cloud | Database, auth, RLS policies |
| Distribution | TestFlight | App Store Connect | Pilot builds and feedback |

---

## Code Review & Commit Guidelines

### Before Committing

1. **Xcode build succeeds** (no warnings, no errors)
2. **Device testing passed** (manual verification on iPhone 13)
3. **TICKETS.md updated** (ticket status changed)
4. **Git commit message is clear:**
   - Format: `[TICKET] Brief description`
   - Example: `[T-018] Fix: Eliminate analytics sync race conditions`
   - Include context if complex (see MEMORY.md for details)

### Git Workflow

```bash
# Check status
git status

# Stage changes (NOT all; specific files)
git add Dwellable/Views/CaptureView.swift
git add Managers/SyncManager.swift
git add docs/MEMORY.md

# Commit with message
git commit -m "[T-018] Fix: Double-sync race condition in DwellableApp"

# Verify commit
git log --oneline -5

# Push (optional, after local verification)
# git push origin main
```

---

## Layer Structure & Ticket Numbering

Each Layer has 5–8 tickets. Layers stack: Layer 1 must ship before Layer 2 starts.

### Layer 1 (Current: Capture + Review + Analytics)

- **T-001 through T-040+:** Core features (auth, capture, review, sync, analytics)
- **Status (March 11, 2026):** 45/61 complete (74%)
- **Current phase:** Personal dogfooding + QA testing

### Layer 2 (Planned: Return + Gallery)

- Gallery view of moments
- Visual themes and patterns
- AI-generated imagery
- Reflection nudges

### Layer 3+ (Formation Intelligence)

- Pattern surfacing
- Semantic search
- Optional biblical anchoring

---

## Debugging & Troubleshooting

### Build Fails

**Error: "cannot find 'SomeClass' in scope"**
- Likely cause: New Swift file not registered in Xcode project
- Fix: In Xcode, File → Add Files → select .swift file, check "Copy items if needed"
- Verify in Build Phases → Compile Sources that file is listed

**Error: "Use of unresolved identifier"**
- Check import statements (e.g., `import Foundation`, `import Supabase`)
- Check that type is public (not private to another module)

**Build hangs or takes >5 min**
- Run `xcodebuild clean` to clear build cache
- Restart Xcode
- Check disk space (Dwellable needs ~5GB free)

### Runtime Crashes

**Crash on app launch**
- Check console logs: `xcrun simctl spawn booted log stream`
- Common: Missing permissions in Info.plist (microphone, speech recognition)
- Add to Info.plist if needed: `NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`

**Crash on voice recording**
- Speech Framework requires actual device (not simulator with speech permission)
- Or: use `AVAudioEngine` mock for simulator testing

**Crash on Supabase call**
- Check API URL and key in Config.swift
- Verify JWT token is present (AuthManager should provide)
- Check Supabase RLS policies allow the operation

### Network Issues

**Moment won't sync**
- Check `SyncManager.isOnline` state
- Verify Supabase is reachable: `curl https://[project].supabase.co/rest/v1/moments`
- Check for 409 conflicts in logs (duplicate UUID)

**Auth fails with "Invalid credentials"**
- Verify email exists in Supabase auth.users table
- Check password is correct (pre-provisioned account)
- Try signing out and back in to refresh tokens

---

## Performance Tips

- **Profile with Xcode Instruments:** Time Profiler, Memory, Core Data
- **Reduce main thread work:** Move sync to background queue (async/await)
- **Cache smartly:** Moments list cached in UserDefaults, synced in background
- **Minimize file I/O:** Voice recordings deleted after transcription

---

## Quality Gates

### Before Shipping to TestFlight

- [ ] All acceptance criteria met (per ticket)
- [ ] Device testing passed (real iPhone 13)
- [ ] No console errors or warnings
- [ ] TICKETS.md and MEMORY.md updated
- [ ] Commits are atomic and descriptive
- [ ] No hardcoded secrets in code

### Before Launching to App Store

- [ ] Layer 1 pilot complete (10+ users, 7+ days)
- [ ] Success metrics met (capture frequency, engagement)
- [ ] No critical bugs reported
- [ ] Privacy policy written and reviewed
- [ ] App Store listing screenshots prepared
- [ ] Legal review complete (if needed)

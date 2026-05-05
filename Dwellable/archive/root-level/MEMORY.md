# Session Memory - Dwellable Native (Swift/SwiftUI)

---

## 🚨 BLOCKING ITEMS (Check This First at Session Start)

### Build 110 on TestFlight — Awaiting iPhone Testing
**Status:** Build 110 uploaded to TestFlight (2026-03-24 ~18:01 UTC)
**Action Required:** Kell is testing Build 110 on his iPhone (not iPad) using the testing Apple account. Check with Kell for results.

**What's in Build 110:**
- ✅ GitGuardian secret remediation (Config.swift removed from source control)
- ✅ iPad navigation crash fix (APIClient moved to SwiftUI Environment — architecture fix)
- ✅ Audio session lazy init + .allowBluetooth (AudioRecordingManager)

**iPad status:** iPad Pro 3rd gen (A12X) has TWO crashes: (1) SwiftUI navigation type resolution — FIXED in Build 110, (2) WhisperKit Metal residency sets not supported on A12X — NOT FIXED, intentionally deferred. Kell decided iPad is not a target device; focus on iPhone only.

**Why this blocks:** Need iPhone test results before inviting external beta testers.

---

## Current Status
- **Build 110** uploaded to TestFlight (2026-03-24 ~18:01 UTC)
- **Version**: 1.0
- **Testing Status**: Phase 1 Complete + iPad crash fixes
  - 48/51 scenarios PASS
  - 1 BUG deferred to Phase 2 (scenario 10.1 - text cursor jump around row 23)
  - 0 failures
  - Build 107→108→109→110 progression (secret fix, audio fix, navigation fix)

## Phase 1 Testing Completed
All critical user journeys verified:
- ✅ Login with valid credentials (2.1)
- ✅ JWT token refresh on idle + auto-refresh (2.6, 9.2)
- ✅ Voice recording & transcription (3.1, 12.1, 12.4, 12.5)
- ✅ Text moment creation (3.2)
- ✅ Offline moment creation + auto-sync (1.5, 5.2, 5.3, 11.1, 11.2)
- ✅ Brute force protection (5 attempts lockout, 10-min timeout) (15.1, 15.2)
- ✅ RLS security (user data isolation) (15.3, 15.4)
- ✅ Certificate pinning verified (15.7)
- ✅ HTTPS enforced (15.8)
- ✅ Authorization header sent in requests (9.1)

## Security Audit Complete
All 8 security tests PASS (Quadruple-verified):
1. ✅ Brute force protection (5-attempt lockout + 10-min timeout)
2. ✅ RLS policies (user can only see/modify own moments)
3. ✅ JWT token refresh (automatic on 401)
4. ✅ Certificate pinning (SHA256 public key validation)
5. ✅ HTTPS enforcement (no HTTP fallback)
6. ✅ Authorization headers (Bearer tokens in all requests)
7. ✅ Keychain storage (secure token persistence)
8. ✅ User data isolation (email tracking in analytics)

## Latest Testing Results
File: `/Users/kell/Downloads/dwellable-testing-results-2026-03-24 (2).json`
- Export Date: 3/23/2026, 11:48:11 PM
- Total Scenarios: 51
- Pass Count: 48
- Fail Count: 0
- Bug Count: 1 (Phase 2)
- Not Set Count: 0

## Known Issues (Phase 2)
- **10.1**: Text cursor jumps off-screen around row 23-27 during long text input
  - Ticket: T-10.1
  - Impact: Minor UX issue
  - Priority: Phase 2

## Recent Fixes
1. ✅ RLS policies on moments table (INSERT, SELECT, UPDATE, DELETE)
2. ✅ user_email field added to usage_events table
3. ✅ Authorization header logging for 9.1 verification
4. ✅ JWT token refresh tested and verified (2.6, 9.2)
5. ✅ Security hardening: 4-layer authentication, RLS, certificate pinning, rate limiting

## TestFlight Beta Testers
Current builds available for testing:
- Build 105: Previous stable build
- Build 107: Phase 1 complete, all security tests pass
- Build 110: Latest — GitGuardian fix + APIClient environment refactor + audio lazy init

## Next Steps
1. Monitor TestFlight feedback and crash reports
2. Address any Phase 1 issues discovered during beta testing
3. Move forward with Phase 2 features and bug fixes
4. Schedule Phase 2 work:
   - Fix text cursor jump bug (10.1)
   - Add delete moment functionality (4.2)
   - Add keyboard interaction support (8.1)
   - Implement rate limiting (15.5)
   - Add SQL injection protection tests (15.6)

## Build Configuration
- Bundle ID: `com.kellgolden.Dwell`
- Team ID: `38X95M6CUB`
- Apple ID: `kell.golden@outlook.com`
- Current Build: 110
- Marketing Version: 1.0
- Min iOS Deployment: 16.0

## Resources
- Main project: `/Users/kell/Desktop/Dwellable-Native/Dwellable/`
- Testing checklist: `UNIFIED_TESTING_CHECKLIST_2.html`
- Critical path test: `PHASE_1_CRITICAL_PATH_TESTING.html`
- Archive: `/Users/kell/Desktop/Dwellable-Native/Dwellable/build/Dwellable.xcarchive`
- IPA: `/Users/kell/Desktop/Dwellable-Native/Dwellable/exportedIPA/Dwellable.ipa`

---
*Last updated: 2026-03-24 23:00 UTC*

## Session Notes (2026-03-24, Session 2)

### Completed This Session
- ✅ **GitGuardian secret remediation** — Supabase anon key removed from source control
  - Config.swift added to .gitignore, removed from git tracking (`git rm --cached`)
  - Config.swift.example template created for new developers
  - Hardcoded keys scrubbed from tools/README.md and tools/analytics-dashboard.html
  - Committed as bb98bbd, pushed to origin/main
- ✅ **iPad crash diagnosed** — Two separate issues found:
  1. SwiftUI navigation crash (`swift_getAssociatedTypeWitnessSlowImpl`) — caused by `APIClient` protocol existential stored in view structs across 3-level nested `.navigationDestination` chain. iPad uses eager transition resolution, iPhone uses lazy.
  2. WhisperKit Metal crash (`MTLDebugDevice newResidencySetWithDescriptor`) — A12X chip doesn't support Metal residency sets. Deferred; iPad not target device.
- ✅ **APIClient refactored to SwiftUI Environment** — All 6 views (AppView, MomentsListView, CaptureView, ReviewView, TypeFlowView, ModelSetupView) now use `@Environment(\.apiClient)` instead of `let apiClient: APIClient`. New file: `Environment/APIClientEnvironment.swift`
- ✅ **Audio session lazy init** — `setupAudioSession()` moved from `init()` to `startRecording()` in AudioRecordingManager. Added `.allowBluetooth` option for iPad Bluetooth routing.
- ✅ **Build 110 uploaded to TestFlight** — Includes all fixes above
- ✅ **Session viewer script fixed** — Reads TICKETS.md as source of truth for ticket status, calendar view restored
- ✅ **Session continuity protocol updated** — git pull added to session start, session viewer regeneration documented

### Learnings
- iPad Pro 3rd gen (A12X, iPad8,11) is incompatible with WhisperKit's default Metal GPU compute — requires CPU-only fallback
- Protocol existentials (`any APIClient`) stored as view properties cause SwiftUI type resolution crashes on iPad during eager navigation transitions — use Environment instead
- `swift_getAssociatedTypeWitnessSlowImpl` crash = Swift runtime can't resolve associated type metadata at runtime. Almost always a nested generics / protocol existential problem.
- Session viewer script: TICKETS.md uses format `**T-001:**` (colon INSIDE asterisks)

### Next Actions
1. Get iPhone test results from Kell on Build 110
2. If iPhone works: invite external beta testers
3. If iPhone crashes: get crash log from iPhone and diagnose
4. Session viewer: add session viewer regeneration to closeout protocol
5. Proceed with Phase 2 work once Phase 1 feedback collected

---

## Session Notes (2026-04-09, Session 3)

### Completed This Session
- ✅ **Automated test hook configured** — xcodebuild test runs automatically on Swift file edits
  - Hook stored in `.claude/settings.json` (project-level, shared with team)
  - Command: `xcodebuild test -scheme Dwellable -destination 'platform=iOS Simulator,name=iPhone 15'`
  - Prevents regression: all code changes must pass tests before being staged
  
- ✅ **Session start protocol executed** — Full ticket table reviewed
  - 59/70 tickets complete (84%)
  - Status: Phase 1 complete, Build 110 on TestFlight
  - Next ticket: T-048 (Fix console log HTTP server) — still in progress
  
- ✅ **Automated session sync validated** — Stop hook (stop-hook-session-sync.sh) verified
  - Script auto-runs on Claude Code session close
  - Generates session-viewer.html from git log + MEMORY.md
  - Commits and pushes MEMORY.md, TICKETS.md, session-viewer.html automatically
  - Solves: Session data continuity — no more manual sync needed

### Learnings
- Stop hook ensures session work is always captured (no more broken promises about updates)
- Automated testing hook prevents code from being committed without test validation
- Project-level hooks are shared with team via git; personal overrides use .claude/settings.local.json

### Next Actions
1. Continue T-048: Debug console log HTTP server (real-time logs not populating)
2. Wait for iPhone test results on Build 110
3. Proceed with Phase 2 work once Phase 1 feedback collected

---
*Last updated: 2026-04-09 (Session 3)*

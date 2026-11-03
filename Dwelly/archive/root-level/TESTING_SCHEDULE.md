# Testing Schedule — March 17 Onwards

**Plan for validating fixes and shipping to TestFlight**

---

## Proposed Testing Schedule

### Phase 1: Quick Validation (TODAY — ~40 min)
**8 Critical Path Tests** — Regression prevention after bug fixes + edge cases

**Purpose:** Verify recent bug fixes didn't break core flows AND test edge cases

**Tests to run:**
1. ✓ Capture → Review → Save → View
2. ✓ Offline Capture → Sync
3. ✓ 10-Minute Recording
4. ✓ Transcription Error → Retry
5. ✓ App Backgrounding
6. ✓ Sync Queue Recovery (force-quit)
7. ✓ Text Entry
8. ✓ Phone Call Interruption During Recording

**Result:** All 8 pass? → Proceed to Phase 2

**Devices:** iPhone 16 Pro (iOS 18+)

---

### Phase 2: Real-World Usage (Days 2-4 — 2-3 hours per day)
**Live journaling** — Use the app for actual moment capture

**Purpose:** Find edge cases, UX issues, battery drain, performance problems

**What to do:**
- Create 15-20 actual moments (not test moments)
- Record various durations: 30 sec, 2 min, 5 min, 10 min
- Use in different environments: office, car, outside, quiet, noisy
- Test with different network states: WiFi, cellular, airplane mode, offline
- Monitor: Battery drain, app stability, audio quality
- Document: Any crashes, hangs, unexpected behavior

**Expected discovery:** Edge cases that automated tests miss

**Example findings:**
- "App crashes when I switch to airplane mode mid-recording"
- "Battery drains 10% per 10-minute recording"
- "Transcript sometimes shows 1 second late"
- "Can't edit moment if I create 3 in quick succession"

**Result:** Document any issues, fix critical ones before Phase 3

---

### Phase 3: Comprehensive Testing (Day 5-6 — 4-5 hours)
**57 Interactive Scenarios** — Full feature validation

**Purpose:** Comprehensive validation before TestFlight release

**What to do:**
1. Open `testing/TESTING_CHECKLIST_MASTER.html`
2. Run through all 57 scenarios in order
3. Document results (PASS/FAIL/NOTES) in the HTML form
4. Focus on scenarios you haven't tested yet

**Scenario categories:**
- Auth & Login (6)
- Navigation (5)
- Recording (8)
- Review & Save (7)
- Listing & Viewing (6)
- Text Entry (5)
- Offline & Sync (6)
- Audio Playback (5)
- 10-Minute Recordings (8)
- Network Variations (6)
- Audio Outputs & Inputs (8)
- Data Persistence (5)

**Result:** All 57 pass? → Ready for TestFlight

---

## Timeline

```
TODAY (March 17)
  └─ Phase 1: 8 Critical Path Tests (40 min)
     Status: ☐ PASS → Proceed | ☐ FAIL → Fix & retry

TOMORROW-THURSDAY (March 18-20)
  └─ Phase 2: Real-world usage (2-3 hours/day)
     Document findings, fix critical issues
     Status: ☐ Issues found → Fix | ☐ No issues → Proceed

FRIDAY-SATURDAY (March 21-22)
  └─ Phase 3: 57 comprehensive scenarios (4-5 hours)
     Status: ☐ All pass → Ready for TestFlight
```

---

## Why This Schedule Works

**Phase 1 (7 tests, 30 min):**
- Fast validation that recent fixes work
- Confirms regression prevention
- Takes only 30 minutes
- If fails, you know something is broken

**Phase 2 (real-world, 2-3 days):**
- **Most valuable testing** — You discover what automated tests can't
- Find battery issues, edge cases, UX friction
- Real usage patterns reveal problems
- Time to fix critical issues before comprehensive testing

**Phase 3 (57 scenarios, 4-5 hours):**
- Comprehensive validation
- Covers all features, environments, edge cases
- Final sign-off before TestFlight
- If all pass, ship with confidence

---

## Success Criteria

**Phase 1 ✅**
- All 8 Critical Path Tests PASS (including phone call interruption)
- No regressions from bug fixes
- Edge cases validated

**Phase 2 ✅**
- Used app for 2-3 days with real moments
- Documented any crashes/hangs
- Fixed any critical issues
- Battery/performance acceptable

**Phase 3 ✅**
- All 57 scenarios documented in HTML
- Major findings documented
- Ready for TestFlight

---

## What to Document

**During Phase 2 (real-world usage):**
```
Issue Found: [Brief description]
Frequency: [One-time | reproducible]
Device state: [WiFi/cellular/offline, battery %, background/foreground]
Steps: [How to reproduce]
Expected: [What should happen]
Actual: [What actually happens]
Severity: [Critical | High | Medium | Low]
```

**During Phase 3 (57 scenarios):**
```
Scenario #: [X]
Status: ☐ PASS ☐ FAIL
Notes: [Any observations]
Screenshots: [If needed]
```

---

## If Issues Found

**Critical (blocks TestFlight):**
- App crashes
- Data loss
- Audio not recording
- Moments not saving
→ Fix immediately, re-run Phase 1

**High (should fix before TestFlight):**
- Transcription hangs > 30 seconds
- Battery drain excessive
- UI inconsistency
→ Fix before Phase 3

**Medium (nice to fix before TestFlight):**
- Minor UI issues
- Edge case behaviors
→ Fix if time, otherwise log for v1.1

**Low (can ship with):**
- Typos
- Minor animation timing
→ Log for v1.1

---

## TestFlight After Phase 3

Once all 57 scenarios pass:
1. Build for release (not debug)
2. Submit to TestFlight via Xcode/App Store Connect
3. Add first internal tester (you)
4. Test for 1-2 days on TestFlight build
5. If all good → Release to external testers

---

## TL;DR

**Today:** 8 Critical Path Tests (40 min) — Confirm recent fixes work + test phone call interruption edge case
**Days 2-4:** Real-world usage (journal with app, find edge cases)
**Days 5-6:** 57 comprehensive scenarios (4-5 hours)
**Result:** Ship to TestFlight with confidence

This is **permanence testing**, not perfection testing. You'll find real issues that matter.

---

## Journey 8: Phone Call Interruption — Why It Matters

**Scenario:** User starts recording a moment, phone call comes in mid-recording

**What can go wrong:**
- Recording stops abruptly (data loss)
- Recording continues in background (unexpected battery drain)
- Audio is corrupted/incomplete (unusable transcript)
- App crashes or hangs
- User confusion about what happened to their moment
- Sync issues if recording was partially saved

**Why we test it:**
- Real-world interruption (happens to everyone)
- Tests app's resilience to iOS system events
- Validates graceful degradation
- Catches audio lifecycle bugs
- Ensures data integrity under system pressure

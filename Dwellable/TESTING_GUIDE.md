# Dwellable Native — Complete Testing Guide

**Overview:** This guide ties together all testing activities, from manual device testing to automated XCUI tests.

---

## 🎯 Testing Strategy

| Testing Type | Device | Coverage | Time | Start |
|---|---|---|---|---|
| **Manual Testing** | Physical iPhone | Voice recording, offline sync, auth flow | 2–3 hours | USER_ACTIVITIES.md → MANUAL_TESTING_CHECKLIST.md |
| **Physical Device Build** | Physical iPhone | Deployment, permissions, real device behavior | 15 min | PHYSICAL_DEVICE_BUILD.md |
| **XCUI Automated Tests** | Simulator + Physical | UI flows, text moments, error handling | Ongoing | XCUI_TESTS.md |
| **Simulator Testing** | Simulator | Everything except voice | 1 hour | Use Xcode simulator |

---

## 📋 Testing Workflow

### Phase 1: Set Up Physical Device (Today)
**Goal:** Get app running on real iPhone

**Steps:**
1. Read: **PHYSICAL_DEVICE_BUILD.md** (10 min read)
2. Do: Follow steps 1–5 to build to device (15 min)
3. Verify: App launches, LoginView displays
4. Test: Log in with test@example.com / password123
5. Record: One test moment with voice

**Deliverable:** App running on physical iPhone, voice recording works

### Phase 2: Manual Testing (U-001, U-002)
**Goal:** Test all 40+ scenarios, find any bugs

**Steps:**
1. Read: **MANUAL_TESTING_CHECKLIST.md** (15 min)
2. Do: Work through 40+ scenarios in 8 phases
3. Document: Pass/fail for each scenario
4. Report: Update USER_ACTIVITIES.md with results

**Scenarios to test:**
- Phase 1: Offline support (5 scenarios)
- Phase 2: Authentication (6 scenarios)
- Phase 3: Moment CRUD (5 scenarios)
- Phase 4: Network state changes (6 scenarios)
- Phase 5: Data persistence (6 scenarios)
- Phase 6: Error handling (4 scenarios)
- Phase 7: Performance (3 scenarios)
- Phase 8: UI/UX (5 scenarios)

**Time:** 2–3 hours for full test
**Or Quick Path:** 30 min for high-priority scenarios

**Deliverable:** Test report with pass/fail results

### Phase 3: XCUI Test Setup (T-020, U-003)
**Goal:** Automate key UI tests so they run every build

**Steps:**
1. Read: **XCUI_TESTS.md** (20 min)
2. Do: Follow "Setup Steps" section in Xcode
3. Add accessibility IDs to key UI elements
4. Copy test code from this guide into DwellableUITests.swift
5. Run tests on simulator and physical device

**Test cases to implement:**
- Valid login
- Empty fields validation
- Create text moment
- Offline moment creation & sync
- Fetch moments list
- Session persistence after restart
- Network error handling

**Time:** 1 hour for setup, 5 min per test run

**Deliverable:** Working XCUI test target with 7+ passing tests

---

## 🗂️ Document Reference

### For Users (Kell)
- **USER_ACTIVITIES.md** — Track your testing work (U-001, U-002, U-003)
- **MANUAL_TESTING_CHECKLIST.md** — 40+ test scenarios to run on physical device
- **PHYSICAL_DEVICE_BUILD.md** — Step-by-step: how to build app to iPhone
- **TESTING_GUIDE.md** — This file, overview of all testing

### For Development (Assistant)
- **XCUI_TESTS.md** — XCUI test setup guide + example test code
- **TICKETS.md** — Track T-020 (XCUI setup), other dev tickets
- **AGENT_GUIDELINES.md** — Session rules for next developer

### Supporting Files
- **Config.swift** — Supabase credentials (don't commit to public repo)
- **DwellableApp.swift** — App entry point, uses SupabaseAPIClient
- **SupabaseAPIClient.swift** — Real API client for Supabase

---

## 🔄 Dependencies & Order

```
PHYSICAL_DEVICE_BUILD ✅ (Do this first)
         ↓
MANUAL_TESTING_CHECKLIST (Can start immediately after build)
         ↓
XCUI_TESTS (Can start once manual testing is in progress)
```

**You don't need to complete Phase 2 before starting Phase 3.** XCUI tests and manual tests can run in parallel.

---

## 📊 Test Matrix: What Can Be Tested Where

| Feature | Physical Device | Simulator | XCUI |
|---|---|---|---|
| Voice recording | ✅ | ❌ | ❌ |
| Offline sync | ✅ | ✅ | ⚠️ (manual WiFi toggle) |
| Authentication | ✅ | ✅ | ✅ |
| Moment CRUD | ✅ | ✅ | ✅ (text only) |
| Error handling | ✅ | ✅ | ✅ |
| Data persistence | ✅ | ✅ | ✅ |
| Network failures | ✅ | ⚠️ | ⚠️ |
| Performance | ✅ | ✅ | ✅ |

**Legend:**
- ✅ = Fully testable
- ❌ = Not possible
- ⚠️ = Possible but requires workaround

---

## 🐛 Bug Reporting Format

If you find a bug during manual testing, create a ticket:

```
Title: BUG-XXX: [Brief description]
Category: Bug
Priority: [CRITICAL / HIGH / MEDIUM / LOW]
Device: iPhone 16 Pro, iOS 18.2
Network: [WiFi / Cellular / Offline]
Steps to reproduce:
  1. [First step]
  2. [Second step]
  3. [Third step]
Actual behavior:
  [What actually happened]
Expected behavior:
  [What should have happened]
Screenshot:
  [If applicable]
```

Example:
```
BUG-001: App crashes when saving offline moment
Device: iPhone 16 Pro
Steps:
  1. Disable WiFi
  2. Record moment
  3. Tap Save
Crash log: Error in SyncManager.swift line 42
```

---

## ✅ Acceptance Criteria

### Phase 1 Complete When:
- [ ] App builds and runs on physical iPhone
- [ ] Voice recording works
- [ ] Login flow successful
- [ ] Can create at least one moment

### Phase 2 Complete When:
- [ ] Run all 40 scenarios
- [ ] Document pass/fail for each
- [ ] File any bugs found
- [ ] Tested both quick path (30 min) and full path (2–3 hours)

### Phase 3 Complete When:
- [ ] XCUI test target created in Xcode
- [ ] At least 5 test cases written and passing
- [ ] Tests pass on both simulator and physical device
- [ ] Accessibility IDs added to UI elements
- [ ] T-020 marked complete in TICKETS.md

---

## 🎬 Quick Reference: Commands

### Build to Physical Device
```bash
cd /Users/kell/Projects/Dwellable-Native/Dwellable
open Dwellable.xcodeproj
# Then in Xcode: Select iPhone → Product → Run
```

### Build and Run on Simulator
```bash
xcodebuild -scheme Dwellable \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  build

# Or in Xcode: Cmd+R
```

### Run XCUI Tests
```bash
xcodebuild test \
  -scheme Dwellable \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Or in Xcode: Cmd+U
```

### View App Logs
```bash
# In Xcode: View → Debug Area → Show Debug Area (Cmd+Shift+Y)
```

---

## 📞 Common Questions

### Q: Can I test voice on simulator?
**A:** No. Voice input requires real microphone hardware. Use physical iPhone for voice testing.

### Q: Can I test offline on simulator?
**A:** Yes, partially. In Xcode, you can simulate network conditions, but it's harder than toggling WiFi on real device.

### Q: How long does testing take?
**A:**
- Quick path (priority scenarios): 30 min
- Full manual test suite: 2–3 hours
- XCUI setup: 1 hour
- Full cycle: 4–5 hours spread over multiple sessions

### Q: What if a test fails?
**A:** Document the failure, create a BUG ticket, and report in session summary. Don't block other tests.

### Q: Should I test on simulator or device first?
**A:** Start with physical device (Phase 1). Simulator testing can happen in parallel for non-voice features.

---

## 🚀 Next Steps

**Start here:**
1. Read PHYSICAL_DEVICE_BUILD.md (10 min)
2. Build app to iPhone (15 min)
3. Test voice recording (5 min)
4. Then choose:
   - **Option A:** Jump to manual testing (MANUAL_TESTING_CHECKLIST.md)
   - **Option B:** Start XCUI setup in parallel (XCUI_TESTS.md)

---

## 📝 Progress Tracking

Update USER_ACTIVITIES.md as you progress:
- U-001: Physical device build ← **Start here**
- U-002: Manual testing scenarios ← Can do in parallel with XCUI
- U-003: XCUI test setup ← Can do in parallel with manual

---

## 💾 File Location

All files in: `/Users/kell/Projects/Dwellable-Native/Dwellable/`

```
Dwellable/
  TESTING_GUIDE.md (this file)
  PHYSICAL_DEVICE_BUILD.md
  MANUAL_TESTING_CHECKLIST.md
  XCUI_TESTS.md
  USER_ACTIVITIES.md
  TICKETS.md
  Dwellable.xcodeproj
```

---

**Last Updated:** March 7, 2026
**Status:** Ready for Phase 1 (Physical Device Build)

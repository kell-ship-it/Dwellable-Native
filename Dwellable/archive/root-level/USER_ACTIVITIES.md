# Dwellable Native — User Testing & QA Activities

**Last Updated:** March 7, 2026
**Purpose:** Track testing scenarios and QA work that the user (Kell) will execute on physical devices and simulator.

---

## 📋 Activity Table

| # | ID | Title | Category | Priority | Status | Notes |
|---|---|---|---|---|---|---|
| 1 | U-001 | Manual Testing on Physical iPhone | Testing | BLOCKING | 🔲 Not Started | Build to physical device + test voice recording, offline sync, auth flow |
| 2 | U-002 | Manual Testing Scenarios Checklist | Testing | BLOCKING | 🔲 Not Started | Run through 40+ test cases covering offline, auth, CRUD, network, persistence |
| 3 | U-003 | XCUI Test Setup & Offline Sync Tests | Testing + Automation | HIGH | 🔲 Not Started | Collaborate with assistant on XCTest automation for UI testing; test offline sync, auth, moment creation |
| 4 | U-004 | Generate 10 Test Participant Accounts | Setup | MEDIUM | 🔲 Not Started | Create 10 test accounts in Supabase for participant testing; use bash script provided |

---

## 🔲 Not Started

### U-001: Manual Testing on Physical iPhone
**Priority:** BLOCKING
**Category:** Testing — Device-specific features
**Acceptance Criteria:**
- [ ] App successfully builds and deploys to physical iPhone 16 (or similar)
- [ ] Login flow works with Supabase authentication
- [ ] Voice recording works (microphone access tested)
- [ ] Offline moment creation works (save without network)
- [ ] Sync queue executes when network restored
- [ ] Moment list displays correctly with fetched data
- [ ] No crashes on navigation or data operations

**What to test:**
- Voice capture + transcription (only testable on physical device)
- Offline behavior (disable WiFi/cellular, create moment, re-enable, verify sync)
- Keychain auth persistence (kill app, relaunch, verify still logged in)
- Network error handling (toggle airplane mode during save)

---

### U-002: Manual Testing Scenarios Checklist
**Priority:** BLOCKING
**Category:** Testing — QA checklist
**What you'll do:**
You will work through the 40+ test scenarios covering:
1. **Offline Support** — 5 scenarios
2. **Authentication** — 6 scenarios
3. **Moment CRUD** — 5 scenarios
4. **Network State Changes** — 6 scenarios
5. **Data Persistence** — 6 scenarios
6. **Error Handling** — 4 scenarios
7. **Performance** — 3 scenarios
8. **UI/UX** — 5 scenarios

See **MANUAL_TESTING_CHECKLIST.md** for the detailed checklist.

**Acceptance Criteria:**
- [ ] Complete all 40+ scenarios
- [ ] Document any failures or unexpected behavior
- [ ] Record findings in session notes

---

### U-003: XCUI Test Setup & Offline Sync Tests
**Priority:** HIGH
**Category:** Testing — Automated UI testing
**What you'll do:**
- [ ] Review XCUI test setup guide (provided by assistant)
- [ ] Collaborate on building out XCTest automation
- [ ] Run XCUI tests on simulator and physical device
- [ ] Verify automated tests pass for key workflows

**What we (assistant) will do:**
- [ ] Create XCUITest target in Xcode
- [ ] Write initial test cases for:
  - Offline moment creation + sync
  - Login flow
  - Moment list display
  - Error handling UI

**Acceptance Criteria:**
- [ ] XCUI test target compiles without errors
- [ ] At least 5 test cases written and passing
- [ ] Tests can run on both simulator and device
- [ ] Tests verify offline → online sync behavior

---

### U-004: Generate 10 Test Participant Accounts
**Priority:** MEDIUM
**Category:** Setup — Test data
**What you'll do:**
- [ ] Get Supabase service role key from dashboard
- [ ] Run the bash script provided (generates 10 test accounts)
- [ ] Verify accounts created in Supabase dashboard
- [ ] Share account list with participants

**Accounts generated:**
- `participant1@dwellable.test` through `participant10@dwellable.test`
- Password: `ParticipantTest123` (same for all)
- All accounts auto-confirmed (no email verification needed)

**Acceptance Criteria:**
- [ ] All 10 accounts exist in Supabase users table
- [ ] All accounts can log in successfully
- [ ] Ready to distribute to participants

---

## 📝 Notes

**Device Testing:**
- Physical iPhone required for voice recording testing
- Simulator can test everything except voice input/output
- Use Xcode's device management to deploy to physical phone

**Timeline:**
1. U-001 (physical device build) — do this first
2. U-002 (manual testing checklist) — run in parallel or after physical device setup
3. U-003 (XCUI tests) — can start once U-001 passes

**Failures to document:**
If you find any bugs or unexpected behavior during U-001 and U-002, create a new ticket in TICKETS.md (format: `BUG-XXX`) and note it here.

# 📁 Dwellable-Native Folder Structure

## Root Level
Core project files and tracking:
- `CLAUDE.md` — Agent instructions for Claude Code
- `MEMORY.md` — Session memory and notes
- `TICKETS.md` — Full ticket registry (single source of truth)
- `TICKETS.csv` — Spreadsheet version of tickets
- `AGENT_GUIDELINES.md` — Rules and boundaries for Claude
- `KUDOS.md` — Credits and acknowledgments
- `USER_ACTIVITIES.md` — User activity tracking

## Directories

### `/Dwellable`
The actual iOS app source code (Swift/SwiftUI):
- `Views/` — SwiftUI screen components
- `Managers/` — Core managers (Auth, API, Sync, etc.)
- `Models/` — Data models
- `Assets.xcassets/` — Images, colors, icons
- `Info.plist` — App configuration

### `/Dwellable.xcodeproj`
Xcode project configuration

### `/docs`
Project documentation:
- `KEY_LEARNINGS.md` — Important insights from development
- Architecture decisions
- Design patterns

### `/guides`
Setup and how-to documentation:
- `SETUP.md` — Quick start guide
- `PHYSICAL_DEVICE_BUILD.md` — Deploy to real iPhone
- `TESTING_GUIDE.md` — How to test the app
- `TEST_ACCOUNT_SETUP.md` — Create test accounts

### `/testing`
All testing-related files:
- **Checklists:**
  - `TESTING_CHECKLIST_MASTER.html` — Main testing checklist
  - `LAYER_1_ACTIVITIES_CHECKLIST.html` — Layer 1 pilot tests
  - `MANUAL_TESTING_CHECKLIST.html` — Manual QA checklist

- **Guides:**
  - `TESTING_GUIDE_FOR_USERS.md/html` — User-facing test guide
  - `TESTING_CLARIFICATIONS.md` — Answers to test questions
  - `ERROR_MESSAGE_TESTING_GUIDE.md` — Error message specs

- **Infrastructure:**
  - `XCUI_TESTS.md` — Automated test documentation
  - `XCODE_BUILD_CHECKLIST.md` — Build verification steps
  - `T-020_SETUP_STATUS.md` — XCUI test setup status
  - `LAYER_1_USER_ACTIVITIES.md` — Layer 1 activity checklist

### `/tools`
Utilities and helper scripts:
- `analytics-dashboard.html` — Real-time analytics viewer
- `DwellableProjectGenerator.py` — Project generation script
- `generate-test-accounts.sh` — Create Supabase test accounts

### `/sessions`
Session logs and summaries:
- `SESSION_SUMMARY_MARCH10.md` — Session 1 notes
- `SESSION_FINAL_SUMMARY_MARCH10.md` — Session 1 final summary
- `BUG_B-002_FIX_GUIDE.md` — Bug fix documentation
- `READY_FOR_TESTING.md` — Build readiness checklist

### `/build`
Xcode build artifacts (git-ignored)

### `/docs` (in root)
Framework documentation and architecture

---

## Quick Navigation

**Starting a session:**
1. Read `CLAUDE.md` — Agent instructions
2. Read `MEMORY.md` — What happened last time
3. Check `TICKETS.md` — What needs to be done

**Running tests:**
1. See `testing/` folder
2. Use `TESTING_CHECKLIST_MASTER.html` for full test matrix
3. See `guides/TESTING_GUIDE.md` for how-to

**Building on device:**
1. See `guides/PHYSICAL_DEVICE_BUILD.md`
2. Check `guides/SETUP.md` for prerequisites

**Understanding the project:**
1. See `docs/KEY_LEARNINGS.md`
2. See `CLAUDE.md` → Architecture section
3. Check `TICKETS.md` → Progress summary

**Real-time analytics:**
1. Use `tools/analytics-dashboard.html`
2. Open in any browser
3. Enter your email to see tracked events

---

**Last Updated:** March 11, 2026

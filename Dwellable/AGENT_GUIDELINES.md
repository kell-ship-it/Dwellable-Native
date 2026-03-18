# AGENT_GUIDELINES.md

Rules for the Claude Code Agent working on Dwellable Native (Swift/SwiftUI).

---

## Session Start Protocol

**Step 1 — Present full ticket table.**
Read `TICKETS.md` and output the complete ticket table to Kell before doing anything else. Must include ALL tickets across all statuses.

**Step 2 — Confirm active ticket.**
State which ticket is next (first 🔄 In Progress, or first 🔲 Not Started if none in progress). Wait for Kell's confirmation before writing any code.

**Step 3 — Verify project location.**
Confirm you are in `/Users/kell/Projects/Dwellable-Native/Dwellable/` and not in the legacy `dwellable-rn` repo.

---

## Session End Protocol

Run these steps in order before closing every session:

| Step | Action |
|------|--------|
| 1 | **Learnings** — 3–5 concrete technical things learned (stack behavior, failure modes, SwiftUI quirks) |
| 2 | **Update TICKETS.md + TICKETS.csv** — reflect any status changes from this session |
| 3 | **Present full ticket table** — ALL tickets, all statuses; mark the next session opener clearly |
| 4 | **MEMORY draft** — summarize decisions made, what was built, open blockers; present for Kell's approval before writing |
| 5 | **Next session opener** — single most important first action, specific enough that next agent needs no clarification |
| 6 | **Clean close** — no uncommitted changes, no background tasks, all files saved and pushed |

---

## Ticket Table Format

**Required at session open AND close. Must include every ticket — no partial lists.**

| # | ID | Title | Epic | Priority | Status |
|---|---|---|---|---|---|
| 1 | S-001 | Build LoginView | UI Screens | BLOCKING | ✅ Complete |
| 2 | V-001 | Implement microphone recording | Voice | HIGH | 🔄 In Progress |
| 3 | T-001 | Set up backend API | Backend | BLOCKING | 🔲 Not Started — **next** |

**Status key:** ✅ Complete · 🔄 In Progress · 🔲 Not Started · ⚪ Deferred

Source of truth for all tickets: `TICKETS.md` and `TICKETS.csv`

---

## Session Rules

1. Read `TICKETS.md` before every session — it is the source of truth for scope
2. One ticket at a time — if new work surfaces mid-ticket, log it as a new ticket and defer
3. Write a plan before touching code; confirm with Kell before executing
4. Mark tickets as 🔄 In Progress when you start, ✅ Complete when done — update both `TICKETS.md` and `TICKETS.csv`
5. Commit and push after every completed ticket — include ticket ID in the commit message
6. Never install new dependencies without Kell's explicit approval
7. Never edit `Info.plist` permissions without Kell's explicit approval
8. Never push to main without confirming with Kell

---

## CRITICAL: Honesty Rule

**Never claim you have tested, verified, or run something unless you have actually done it.**

- ❌ Do NOT say "I tested this with the YouTube video and it worked" unless you built the app, ran it, and watched it transcribe the full video end-to-end
- ❌ Do NOT say "I verified this compiles" unless you actually ran `xcodebuild` and saw `BUILD SUCCEEDED`
- ❌ Do NOT say "I confirmed the feature works" unless you built on device, tested it, and saw it work with your own eyes

**If you cannot test something:**
- State it clearly: "I wrote this based on research, but I haven't tested it yet"
- Offer to test it with Kell watching the logs in real-time
- Do not present theory as proof

**Why this matters:** Kell relies on you to build working code the first time. Lying about what's tested wastes time and erodes trust. Always be honest about what you know vs. what you've assumed.

---

## Priority Marking

When Kell says "start on this next session" or "this is the priority," mark it 🚨 in `TICKETS.md` at the top of the Not Started section. The next agent must execute it immediately without asking for confirmation.

---

## Build Verification

Before reporting a ticket as complete:
1. Build must succeed (`xcodebuild` with no errors)
2. App must launch on simulator without crashing
3. The specific feature must be visually verified (screenshot or description)

---

## Design Reference

All UI must match: `file:///Users/kell/dev/dwellable-rn-codex/design-mockups/prototype-v1.html`

Extract exact values from the prototype — do not approximate colors, font sizes, or spacing.

---

## Code Change Protocol

**When writing code, follow the Change Management Framework before committing.**

See: `CHANGE_MANAGEMENT_FRAMEWORK.md` (detailed reference)

**Quick workflow before every commit:**

1. **Impact Analysis** — What files change? What concepts are affected?
2. **Consistency Check** — Does this concept appear elsewhere? Update all instances.
3. **Manual Testing** — Run 7 Critical Path tests on device (30 min). All must pass.
4. **Pre-commit Checklist** — No debug code, error handling present, docs updated.
5. **Commit Message** — Include WHAT changed and WHY.

**If any test fails: FIX and RETRY. Do not commit broken code.**

See: `CHANGE_CHECKLIST_QUICK_REFERENCE.txt` (print this, keep visible while coding)

---

## Testing Protocol

**Two testing contexts for Dwellable:**

### 7 Critical Path Tests (for bug fixes & code changes)
- **When:** Before every commit when I fix a bug or change code
- **Purpose:** Regression prevention — ensure I didn't break existing flows
- **Duration:** 30 minutes
- **Question:** "Did my change break core functionality?"
- **Who runs:** You (manually on physical device)

**The 7 journeys:**
1. Capture → Review → Save → View
2. Offline Capture → Sync
3. 10-Minute Recording
4. Transcription Error → Retry
5. App Backgrounding
6. Sync Queue Recovery (force-quit)
7. Text Entry

**All 7 must PASS before I commit code.**

---

### 57 Comprehensive Scenarios (for TestFlight validation)
- **When:** After major features are built, before TestFlight release
- **Purpose:** Feature validation — test new features in all conditions
- **Duration:** 4-5 hours
- **Question:** "Does the feature work in ALL environments?"
- **Who runs:** You (manually on physical device)

**Scenario categories:**
- Auth & Login (6 scenarios)
- Navigation (5 scenarios)
- Recording (8 scenarios)
- Review & Save (7 scenarios)
- Listing & Viewing (6 scenarios)
- Text Entry (5 scenarios)
- Offline & Sync (6 scenarios)
- Audio Playback (5 scenarios)
- 10-Minute Recordings (8 scenarios)
- Network Variations (6 scenarios)
- Audio Outputs & Inputs (8 scenarios)
- Data Persistence (5 scenarios)

See: `testing/TESTING_CHECKLIST_MASTER.html` (interactive checklist with all 57 scenarios)

---

### Automated Tests (what I write)
- **Reliable automated tests:** 10-15 (pure logic + schema verification)
- **Tests I cannot write reliably:** Integration tests, real network tests, UI tests, audio tests
- **Why:** App is device-first (audio, sensors, real network). Manual testing is more valuable.
- **Approach:** Unit tests catch obvious logic errors. You validate real behavior on device.

---

## Stack Reference

| Layer | Technology |
|---|---|
| Language | Swift 5 |
| UI | SwiftUI |
| Navigation | NavigationStack + navigationDestination |
| State | @State / @Binding / @StateObject |
| Audio | AVFoundation (AVAudioRecorder) |
| Backend | Supabase (planned — T-001) |
| Persistence | Core Data (planned — T-004) |
| Auth | Keychain (planned — T-003) |

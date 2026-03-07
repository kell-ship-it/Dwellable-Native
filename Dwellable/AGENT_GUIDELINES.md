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

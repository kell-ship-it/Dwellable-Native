# CLAUDE.md

---

## 🚨 SESSION START — DO THIS FIRST. NO EXCEPTIONS.

**Before reading anything else, before asking any questions, before touching any code:**

### Step 1: Read Strategic Context (In Order)
1. **`docs/VISION.md`** — Product north star, principles, target users
2. **`docs/PRD.md`** — Requirements, scope, success metrics, current phase status
3. **`docs/ARCHITECTURE.md`** — Tech stack, data flow, key decisions
4. **`docs/WORKFLOW.md`** — Development process, build commands, testing strategy

### Step 2: Read Current State
5. **`docs/MEMORY.md`** — Last session notes, blockers, what was done
6. **`docs/KEY_LEARNINGS.md`** — Critical lessons (build issues, race conditions, etc.)

### Step 3: Read Tickets & Get Approval
7. **`TICKETS.md`** — Output the full ticket table to Kell **right now**.

   The table must include EVERY ticket — ✅ Complete, 🔄 In Progress, 🔲 Not Started, and ⚪ Deferred. No partial lists. Use this format:

   | # | ID | Title | Epic | Priority | Status |
   |---|---|---|---|---|---|
   | 1 | S-001 | Build LoginView | UI Screens | BLOCKING | ✅ Complete |
   | ... | | | | | |

8. **State which ticket is next** (first 🔄 In Progress, or first 🔲 Not Started).

9. **Wait for Kell's confirmation before writing any code.**

**DO NOT skip any of this. DO NOT ask if you should do it. Just do it in order.**

---

## 🚨 SESSION END — DO THIS LAST. NO EXCEPTIONS.

**Before closing the session:**

**1. Update `TICKETS.md` and `TICKETS.csv`** to reflect any status changes.

**2. Output the full ticket table again** — same format as session open, all tickets, all statuses.

**3. State the next session opener** — the single first action for the next agent, specific enough to execute without clarification.

---

This file provides guidance to Claude when working in this repository.

## Project

Dwellable — Native iOS app built with Swift and SwiftUI.

## Tech Stack

- **Swift 5.9** / **SwiftUI** (native iOS, iOS 15+)
- **Xcode** (native project — no Expo, no React Native, no npm)
- **AVFoundation** — microphone recording
- **Speech Framework** — on-device voice-to-text (offline-capable)
- **Supabase** — PostgreSQL backend + JWT auth + RLS
- **Keychain + UserDefaults** — local storage (offline-first architecture)
- **UsageTracker** — analytics event logging (live in Build 105)

## Commands

```bash
# Build and run on simulator
xcodebuild -scheme Dwellable -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Install to booted simulator
xcrun simctl install booted <path-to-app>
xcrun simctl launch booted com.kellgolden.Dwell

# Check simulator logs
xcrun simctl spawn booted log show --predicate 'process == "Dwellable"' --last 10s

# Open in Xcode
open Dwellable.xcodeproj
```

## Project Structure

```
Dwellable/
├── Dwellable/
│   ├── Views/               # SwiftUI screen files (LoginView, CaptureView, etc.)
│   ├── Managers/            # Business logic (AuthManager, SyncManager, APIClient)
│   ├── Models/              # Data structures (Moment, User, UsageEvent, etc.)
│   ├── Utilities/           # Helpers (Theme.swift, Extensions, Constants)
│   ├── Assets.xcassets/     # Colors, images, app icon
│   └── Info.plist           # App permissions and config
├── docs/
│   ├── VISION.md            # Product north star
│   ├── PRD.md               # Product specification
│   ├── ARCHITECTURE.md      # System design & tech decisions
│   ├── WORKFLOW.md          # Development workflow
│   ├── MEMORY.md            # Session logs
│   └── KEY_LEARNINGS.md     # Critical lessons
├── TICKETS.md               # Full ticket registry (all tickets, all statuses)
├── TICKETS.csv              # Spreadsheet version
├── CLAUDE.md                # This file
├── AGENT_GUIDELINES.md      # Session protocol rules
└── MEMORY.md                # Global project memory
```

## Key Project Info

- **Bundle ID:** `com.kellgolden.Dwell`
- **Team ID:** `38X95M6CUB`
- **Apple ID:** `kell.golden@outlook.com`
- **Design prototype:** `file:///Users/kell/dev/dwellable-rn-codex/design-mockups/prototype-v1.html`

## Core Features (✅ Complete)

### Views
- `LoginView.swift` — Email/password login (Supabase JWT auth)
- `MomentsListView.swift` — Home screen with moment list, sorting, empty state
- `CaptureView.swift` — Voice-first capture with rotating prompts
- `ReviewView.swift` — Voice review (with Re-record) + text review + save
- `TypeFlowView.swift` — Text-only moment entry (alternative to voice)
- `TranscribingView.swift` — Loading state during Speech Framework transcription
- `MomentDetailView.swift` — Full moment reader with metadata
- `SettingsView.swift` — User profile, app info, sign-out
- `Theme.swift` — Centralized colors, fonts, spacing

### Managers
- `AuthManager.swift` — Session state + Supabase JWT auth + Keychain storage
- `SyncManager.swift` — Offline-first sync + network monitoring + retry logic
- `SupabaseAPIClient.swift` — HTTP + Supabase REST API + RLS
- `LocalStorageManager.swift` — Keychain + UserDefaults operations
- `UsageTracker.swift` — Analytics event logging (moments created, app sessions)

### Current Status
- **Build 105** live on TestFlight with full analytics
- **46/61 tickets complete** (75%)
- **Phase 1 dogfooding** in progress (Mar 10–17)

## Conventions

- **File naming:** PascalCase for all Swift files (`LoginView.swift`)
- **Styling:** Use `Theme.swift` constants — avoid hardcoded colors or font sizes
- **State:** `@State` for local, `@Binding` for passed-down, `@StateObject` for shared models
- **Embeds:** TypeFlowView and MomentDetailView currently embedded in parent files (refactor tracked in T-007)

## Session Protocol

**At session START and session END, always present the full ticket table from TICKETS.md.**
The table must include ALL tickets — ✅ Complete, 🔄 In Progress, and 🔲 Not Started.

See `AGENT_GUIDELINES.md` for full session rules.

## Execution Rules

- Before major changes, summarize in 3 bullets what you're about to do and why
- One ticket at a time — no scope creep
- Always ask before adding new dependencies or editing Info.plist permissions
- Never commit without running a build first
- Treat `TICKETS.md` as the source of truth for project scope

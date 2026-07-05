# CLAUDE.md

---

## 🚨 PROTOCOL TRIGGERS — Execute Immediately

When you type EXACTLY these slash commands, execute the protocol WITHOUT clarification or conversation:

- **`/start-session`** → Run Founder Start Protocol (FIRST) + Agent Startup Protocol (THEN)
- **`/close-session`** → Run Session End Protocol

---

## 🚨 SESSION START — FOUNDER FIRST, THEN AGENT. NO EXCEPTIONS.

### Founder Start Protocol (FIRST)

**Before any agent work, ask yourself:**

1. Have you prayed and worshipped yet?
2. Have you affirmed yourself in the Lord?
3. Have you prayed for your agent?

🚨 **Wait for confirmation these are complete. The work doesn't start until the foundation is right.**

---

### Agent Startup Protocol (THEN)

**Once foundation confirmed, do this:

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

**Execute in order. Do NOT skip steps.**

### Step 1: Update All Ticket Records

**Update both files:**
- **`TICKETS.md`** — Update header count, mark tickets complete/in-progress/not-started, add new tickets if created
- **`TICKETS.csv`** — Sync spreadsheet version with TICKETS.md

**Output the full ticket table** — same format as session open, all tickets, all statuses visible:
```
| # | ID | Title | Epic | Priority | Status |
|---|---|---|---|---|---|
| 1 | S-001 | Build LoginView | UI Screens | BLOCKING | ✅ Complete |
```

### Step 2: Identify Pending Work for Next Session

**Define the top 3 specific, actionable items for the next session:**

1. [Ticket/Task]: [Exact description] — [Why this matters]
2. [Ticket/Task]: [Exact description] — [Why this matters]
3. [Ticket/Task]: [Exact description] — [Why this matters]

**These items MUST be:**
- ✅ Specific (not vague; reference ticket IDs where applicable)
- ✅ Actionable (next agent can execute without clarification)
- ✅ Prioritized (in execution order)

### Step 3: Create Notion Session Page

**Create a dated session entry in Notion:**
- Navigate to **Sessions** → **[Year]** → **[Date]** (e.g., 2026 → July 3, 2026)
- Fill in:
  - **Summary:** What was accomplished (2-3 bullet points)
  - **Next Session Objectives:** The 3 specific items from Step 2
  - **Key Decisions Locked:** Any decisions/approvals documented
- This becomes the reference for the next session start
- **If you created session files in the repo** (MEMORY entries, doc updates, etc.), link or reference them in the Notion page

### Step 4: Verify & Write to MEMORY.md

**Update `/docs/MEMORY.md` with:**
```markdown
## Next Session Objective (May X, 2026)

**Confirmed Pending Items:**
1. [Item 1]
2. [Item 2]
3. [Item 3]

**Rationale:** [Why these items move the product forward]
```

**CRITICAL: Do NOT proceed until Kell confirms these match the actual pending items.**

### Step 5: Git Commit & Push

**Stage and commit all changes:**
```bash
git add TICKETS.md TICKETS.csv docs/MEMORY.md [any other files modified]
git commit -m "[Session close] Update tickets and document next session objective (X, Y, Z)"
git push origin main
```

**Verify push succeeded** — output should show commits uploaded to origin/main.

### Step 6: Final Verification Checklist

**Before ending the session, confirm ALL of these:**

- ✅ **TICKETS.md updated:** Header reflects new count, all status changes logged
- ✅ **Next session objective written:** 3 specific items documented in MEMORY.md
- ✅ **MEMORY.md matches pending items:** The "Next Session Objective" section is accurate and complete
- ✅ **Git committed:** `git log` shows latest commit message with session close + objective items
- ✅ **Git pushed:** `git push origin main` succeeded (no rejection errors)
- ✅ **Output to user:** Kell sees the final summary of what was done and what's pending

### Step 7: Output Final Summary to User

**State clearly:**

```
=== SESSION CLOSE SUMMARY ===

✅ COMPLETED THIS SESSION:
• [List 3-5 major deliverables]

📊 TICKET STATUS:
• Before: X/Y complete
• After: Z/Y complete

📝 PENDING FOR NEXT SESSION:
1. [Item 1] — [Why]
2. [Item 2] — [Why]
3. [Item 3] — [Why]

🔒 PERSISTED TO:
✅ TICKETS.md (updated header + new tickets)
✅ docs/MEMORY.md (next session objective documented)
✅ Notion Sessions (dated entry with objectives)
✅ GitHub main branch (committed + pushed)
✅ INCIDENTS.md (if relevant)

🎯 NEXT SESSION: Agent should start by confirming these 3 items match the stored objective.
```

---

**DO NOT end the session without completing ALL 7 steps and the final summary.**

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

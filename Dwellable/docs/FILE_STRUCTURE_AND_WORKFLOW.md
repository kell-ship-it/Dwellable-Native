# Dwellable File Structure & Workflow

**Visual guide to folder organization, file purpose, and when/how we interact with each during development.**

---

## Directory Tree with Interaction Timeline

```
Dwellable-Native/
├── README.md                          [Reference: Project overview]
├── SETUP.md                           [Reference: Initial setup]
│
└── Dwellable/
    ├── Dwellable/                     [SOURCE CODE — Active during dev/testing]
    │   ├── Views/                     [UI Screens]
    │   ├── Managers/                  [Business logic]
    │   ├── Models/                    [Data structures]
    │   ├── Utilities/                 [Helpers, extensions]
    │   ├── Assets.xcassets/           [Images, colors, icons]
    │   └── Info.plist                 [App permissions, config]
    │
    ├── docs/                          [STRATEGIC DOCUMENTATION — Read at session start]
    │   ├── VISION.md                  ✅ MASTER REFERENCE (North Star, Principles)
    │   │                                 - Read at session start (Agent Startup Protocol)
    │   │                                 - Update when product principles change
    │   │                                 - Reference for all feature decisions
    │   │
    │   ├── PRD.md                     ✅ MASTER REFERENCE (Requirements + Pillars)
    │   │                                 - Read at session start
    │   │                                 - Update as pillars move through design → implementation
    │   │                                 - Add per-pillar tickets once design is locked
    │   │                                 - Maps what we're building and why
    │   │
    │   ├── ARCHITECTURE.md            ✅ REFERENCE (Technical design)
    │   │                                 - Read at session start
    │   │                                 - Update when technical decisions change
    │   │                                 - Reference for implementation
    │   │
    │   ├── WORKFLOW.md                ✅ REFERENCE (Development process)
    │   │                                 - Read once (rarely changes)
    │   │                                 - Defines build commands, testing strategy
    │   │
    │   ├── KEY_LEARNINGS.md           ✅ REFERENCE (Critical lessons)
    │   │                                 - Read at session start
    │   │                                 - Update at session close with new learnings
    │   │                                 - Prevents repeating past mistakes
    │   │
    │   ├── MEMORY.md                  ✅ SESSION LOG (What happened this session)
    │   │                                 - Read at session start (finds "Next Session Objective")
    │   │                                 - Update at session close
    │   │                                 - Entry per session with work summary
    │   │
    │   ├── NOTIFICATIONS_PILLAR.md    📌 PILLAR REFERENCE (Pillar 8 details)
    │   │                                 - Reference for Pillar 8 design
    │   │
    │   ├── ONBOARDING_DESIGN_GUIDELINES.md
    │   │                                 📌 PILLAR REFERENCE (Phase 2 onboarding)
    │   │                                 - Reference for Pillar 7 design work
    │   │
    │   └── FILE_ORGANIZATION_SUMMARY.md
    │                                      📋 REFERENCE (Cleanup audit trail)
    │                                      - Documents what was archived and why
    │
    ├── guides/                        [OPERATIONAL REFERENCES]
    │   ├── SUPABASE_SETUP.md          - Setup for developers joining project
    │   ├── TEST_ACCOUNT_SETUP.md      - How to create test accounts
    │   ├── TESTING_GUIDE.md           - How to test on devices
    │   └── PHYSICAL_DEVICE_BUILD.md   - How to build to real iPhone
    │
    ├── CLAUDE.md                      ✅ MASTER REFERENCE (Session protocols + tech stack)
    │                                      - Read at session start
    │                                      - Defines /start-session and /close-session flows
    │                                      - Project conventions, tech stack, bundle ID
    │                                      - Rarely changes
    │
    ├── AGENT_GUIDELINES.md            ✅ REFERENCE (Session rules)
    │                                      - Rarely read directly (referenced in CLAUDE.md)
    │                                      - Defines session protocol rules
    │
    ├── TICKETS.md                     ✅ ACTIVE (Ticket registry)
    │                                      - Read at session start + session end
    │                                      - Update status for completed work
    │                                      - Source of truth for all tickets
    │                                      - T-XXX format links to PRD pillars
    │
    ├── TICKETS.csv                    📊 SPREADSHEET (Ticket data export)
    │                                      - Keep in sync with TICKETS.md
    │                                      - For sharing / tracking outside Claude
    │
    ├── KUDOS.md                       📝 MORALE LOG (Session wins)
    │                                      - Update at session close
    │                                      - Optional, for team morale
    │
    ├── FILE_ORGANIZATION_SUMMARY.md   📋 REFERENCE (Cleanup details)
    │                                      - What was archived, why, where
    │                                      - One-time reference
    │
    ├── archive/                       [ARCHIVED — Reference only]
    │   ├── docs/                      - Old research, design docs, session artifacts
    │   ├── root-level/                - Old protocols, security docs, experimental files
    │   ├── sessions-testing/          - Old session summaries, testing checklists
    │   ├── historical/                - Pre-migration documents
    │   └── [52 archived files]
    │
    ├── .git/                          [GIT HISTORY]
    │                                      - Commits document what changed and why
    │                                      - Preserve commit history (never force-push)
    │
    └── Dwellable.xcodeproj            [XCODE PROJECT]
                                          - Build configuration
                                          - Build phases, signing, capabilities
                                          - Modified only when adding dependencies or capabilities
```

---

## File Interaction Timeline

### 🟢 Session Start (Founder Start Protocol + Agent Startup Protocol)

**Read in this order:**

1. **VISION.md** (5 min) — Understand product north star, principles, target users
2. **PRD.md** (10 min) — Understand what we're building (pillars, phases, technical architecture)
3. **ARCHITECTURE.md** (5 min) — Understand technical system design
4. **WORKFLOW.md** (2 min) — Understand development process and build commands
5. **docs/MEMORY.md** (5 min) — Read "Next Session Objective" from previous session
6. **KEY_LEARNINGS.md** (3 min) — Understand critical lessons to avoid repeating mistakes
7. **CLAUDE.md** (reference) — Already familiar with tech stack and conventions
8. **TICKETS.md** (10 min) — Output full table, identify which ticket is next

---

### 🟡 During Work Session

**Read/Update frequently:**

- **TICKETS.md** — Check ticket details, update status as work progresses
- **PRD.md (Pillar section)** — Reference pillar requirements while implementing
- **ARCHITECTURE.md** — Reference for technical decisions
- **KEY_LEARNINGS.md** — Check if similar problem was solved before

**Write/Modify:**

- **Code** (Dwellable/Views/, Dwellable/Managers/, etc.) — Main work
- **Xcode project** — Only if adding dependencies or changing capabilities
- **TICKETS.md** — Update ticket status (✅ Complete, 🔄 In Progress, etc.)

---

### 🟠 Design Sessions (Pillar Design Work)

**For each pillar design (Pillars 2-8):**

1. **Read PRD.md** — See pillar skeleton and open questions
2. **Read relevant research** (in /archive/docs if needed for context)
3. **Conduct 4-step design:**
   - Step 1: Success criteria
   - Step 2: Competitive research
   - Step 3: Pattern extraction
   - Step 4: Skeleton design
4. **Update PRD.md** — Lock the skeleton, document decisions, open questions, exclusions, risks
5. **DO NOT create tickets yet** — Wait until all pillars designed, then batch create

---

### 🔵 Session Close (Session End Protocol)

**At session end:**

1. **Update TICKETS.md & TICKETS.csv** — Reflect all status changes
2. **Output full TICKETS table** — Same format as session start
3. **Update docs/MEMORY.md** — Add session log entry:
   - Session date
   - Work completed (ticket numbers)
   - Blockers discovered
   - **Next Session Objective** (specific, actionable first step)
4. **Commit changes** — `git add -A && git commit -m "Session close: [summary]"`
5. **Update KEY_LEARNINGS.md** — Add any new learnings from this session
6. **Review PRD.md** — If pillars were designed, ensure skeleton is locked

---

## Interaction Frequency Matrix

| File | Session Start | During Work | Design Phase | Session Close | Update Frequency |
|------|---|---|---|---|---|
| VISION.md | Read ✓ | Reference | Reference | Rarely | Policy changes only |
| PRD.md | Read ✓ | Reference ✓ | Update ✓ | Review | Per pillar design |
| ARCHITECTURE.md | Read ✓ | Reference ✓ | - | Rarely | Tech decisions |
| WORKFLOW.md | Read (once) | Reference | - | Rarely | Process changes |
| KEY_LEARNINGS.md | Read ✓ | Reference | - | Update | Per session |
| MEMORY.md | Read ✓ (find objective) | - | - | Update ✓ | Per session |
| TICKETS.md | Read ✓ (full table) | Update ✓ | - | Update ✓ | Continuous |
| CLAUDE.md | Reference | Reference | - | Rarely | Protocol changes |
| CODE | - | Write ✓ | - | Commit | Active work |
| GIT | - | - | - | Commit ✓ | Per feature/fix |

---

## Key Interaction Patterns

### 🎯 Finding Information

**"What are we building?"** → PRD.md (Pillar sections)  
**"Why are we building it?"** → VISION.md (Problem, Principles)  
**"How do we build it?"** → ARCHITECTURE.md (Technical design)  
**"What's the next ticket?"** → TICKETS.md (status: 🔲 Not Started)  
**"What did we learn?"** → KEY_LEARNINGS.md (past mistakes, validated approaches)  
**"What happened last session?"** → docs/MEMORY.md (session log)  

### 📝 Making Changes

**Implementing a feature:** Modify CODE → Update TICKETS.md status → Commit to git  
**Designing a pillar:** Update PRD.md (Status, Locked, Open, Exclusions, Risks) → Add to KEY_LEARNINGS if insight  
**Session ends:** Update MEMORY.md entry + commit everything  
**Pillar designed:** Lock skeleton in PRD.md → Next session: Create tickets for that pillar  

### 🔄 Feedback Loops

**Code → Tests → Build → Deploy → Usage → Learnings → KEY_LEARNINGS.md**  
**Design → Review → Lock → Tickets → Implementation → Validation → PRD.md**  
**Session → Work → Blockers → KEY_LEARNINGS.md → Next session informed by past**

---

## Archive Structure (Reference Only)

Files archived to `/archive/` are preserved but not active:

- `/archive/docs/` — Old research, competitive analysis, session-specific design docs
- `/archive/root-level/` — Old protocols, security docs, experimental frameworks
- `/archive/sessions-testing/` — Old session summaries, testing checklists (March 2026)
- `/archive/historical/` — Pre-migration documents (Expo era)

**When to reference archives:**
- Researching past decisions or competitive analysis
- Understanding context for Phase 1 findings
- Reviewing how past sessions were structured

**Never modify archives** — they're historical record only.

---

## Summary: The Core Interaction Loop

```
SESSION START
    ↓
[Read: VISION, PRD, ARCHITECTURE, WORKFLOW, MEMORY, KEY_LEARNINGS]
    ↓
GET NEXT TICKET
    ↓
WORK (Code + TICKETS.md updates)
    ↓
Session Close or Continue
    ↓
SESSION END
    ↓
[Update: MEMORY.md, KEY_LEARNINGS.md, TICKETS.md, git commit]
    ↓
NEXT SESSION STARTS ↻
```

**Everything flows through PRD.md and TICKETS.md as the source of truth.**  
**Everything is documented in git history.**  
**Every session learns from KEY_LEARNINGS.md.**

---

**Updated:** May 4, 2026  
**Last modified:** After PRD restructuring and file organization cleanup

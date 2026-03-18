# File Usage Diagram

**Visual timeline: When each file is read during agent session lifecycle**

---

## Session Timeline Overview

```
SESSION START (42 min)
        ↓
    [Read files in sequence]
        ↓
CODING PHASE (hours/days)
        ↓
    [Reference files, follow framework]
        ↓
BEFORE EVERY COMMIT
        ↓
    [Check framework, run tests]
        ↓
SESSION END
        ↓
    [Update memory, close cleanly]
```

---

## Phase 1: SESSION START (42 minutes)

```
⏱️ START
  │
  ├─ READ: AGENT_SESSION_STARTUP_SEQUENCE.md (1 min)
  │  "Follow this 11-step sequence"
  │
  ├─ READ: SESSION_START_CHECKLIST.md (2 min)
  │  "I will read 9 files in order"
  │
  ├─ READ: AGENT_GUIDELINES.md (5 min)
  │  Rules: Testing protocol, code change framework, session end
  │
  ├─ READ: FOUNDER_GUIDELINES.md (5 min)
  │  Rules: Autonomy, testing standards, design consistency
  │
  ├─ READ: docs/VISION.md (5 min)
  │  "Why we're building Dwellable"
  │
  ├─ READ: docs/PRD.md (10 min)
  │  "What features we're building"
  │
  ├─ READ: docs/ARCHITECTURE.md (5 min)
  │  "How it's architected"
  │
  ├─ READ: docs/MEMORY.md (5 min)
  │  "What happened recently, what's blocked"
  │
  ├─ READ: TICKETS.md (3 min)
  │  "All work items, identify active ticket"
  │
  ├─ CONFIRM: With Kell (1 min)
  │  "Which ticket should I start?"
  │
  └─ ✅ SESSION START COMPLETE
     Ready to code
```

**Files read in this phase:**
1. AGENT_SESSION_STARTUP_SEQUENCE.md (navigation)
2. SESSION_START_CHECKLIST.md (protocol)
3. AGENT_GUIDELINES.md (rules)
4. FOUNDER_GUIDELINES.md (preferences)
5. docs/VISION.md (product vision)
6. docs/PRD.md (features)
7. docs/ARCHITECTURE.md (design)
8. docs/MEMORY.md (recent context)
9. TICKETS.md (work items)

**Files NOT read yet:** TESTING_CHECKLIST_MASTER.html, CHANGE_MANAGEMENT_FRAMEWORK.md (will be used later)

---

## Phase 2: CODING

```
⏱️ CODING PHASE (varies)
  │
  ├─ REFERENCE (while coding):
  │  ├─ AGENT_GUIDELINES.md (if question: "Can I do X?")
  │  ├─ docs/ARCHITECTURE.md (if question: "Where does this go?")
  │  ├─ docs/PRD.md (if question: "What's the spec?")
  │  └─ TICKETS.md (if question: "What's my ticket?")
  │
  ├─ KEEP VISIBLE ON DESK:
  │  └─ CHANGE_CHECKLIST_QUICK_REFERENCE.txt
  │     (Before every commit)
  │
  └─ (No files read, just kept as reference)
```

**Files referenced during coding:**
- AGENT_GUIDELINES.md (behavior rules)
- docs/ARCHITECTURE.md (design questions)
- docs/PRD.md (feature spec)
- TICKETS.md (ticket details)

**Files kept visible:**
- CHANGE_CHECKLIST_QUICK_REFERENCE.txt (on desk)

---

## Phase 3: BEFORE EVERY COMMIT

```
⏱️ BEFORE COMMIT (5-10 min per commit)
  │
  ├─ CHECK: CHANGE_CHECKLIST_QUICK_REFERENCE.txt
  │  "Impact analysis complete?"
  │  "Consistency check complete?"
  │  "7 tests pass?"
  │  "Pre-commit checklist complete?"
  │
  ├─ REFERENCE: CHANGE_MANAGEMENT_FRAMEWORK.md
  │  "What testing do I need to run?"
  │  "What's my workflow?"
  │
  ├─ RUN: 7 Critical Path Tests (30 min)
  │  See: CHANGE_MANAGEMENT_FRAMEWORK.md § Critical Path Test Suite
  │
  ├─ RUN: Automated tests (10-15 unit tests)
  │  See: CHANGE_MANAGEMENT_FRAMEWORK.md § Automated Test Gate
  │
  └─ COMMIT
     "Only after all checks pass"
```

**Files read before commit:**
- CHANGE_CHECKLIST_QUICK_REFERENCE.txt (main reference)
- CHANGE_MANAGEMENT_FRAMEWORK.md (detailed reference)

---

## Phase 4: USER TESTING (Your Phase 2-3)

```
⏱️ PHASE 1: QUICK VALIDATION (TODAY - 30 min)
  │
  └─ RUN: 7 Critical Path Tests
     See: CHANGE_MANAGEMENT_FRAMEWORK.md § Critical Path Test Suite
     Or: TESTING_SCHEDULE.md § Phase 1

⏱️ PHASE 2: REAL-WORLD USAGE (Days 2-4 - 2-3 hours/day)
  │
  └─ USE: App naturally
     Document findings in notes

⏱️ PHASE 3: COMPREHENSIVE TESTING (Days 5-6 - 4-5 hours)
  │
  ├─ OPEN: testing/TESTING_CHECKLIST_MASTER.html
  │  "Run through all 57 scenarios"
  │
  └─ DOCUMENT: Results in HTML form
     "PASS/FAIL/NOTES for each scenario"

⏱️ SHIP TO TESTFLIGHT
  │
  └─ READY
```

**Files read during testing:**
- TESTING_SCHEDULE.md (timeline)
- CHANGE_MANAGEMENT_FRAMEWORK.md (Phase 1 tests definition)
- TESTING_CHECKLIST_MASTER.html (Phase 3 scenarios)

---

## Phase 5: SESSION END

```
⏱️ SESSION END (15 min)
  │
  ├─ LEARNINGS: Summarize what happened
  │
  ├─ UPDATE: TICKETS.md
  │  "Mark tickets as ✅ Complete, 🔄 In Progress, 🔲 Not Started"
  │  "Present full table"
  │
  ├─ UPDATE: docs/MEMORY.md
  │  "Document decisions, blockers, next steps"
  │  "Add TL;DR"
  │
  └─ CLOSE: Ready for next session
     AGENT_SESSION_STARTUP_SEQUENCE.md will start next session
```

**Files updated at session end:**
- TICKETS.md (update status)
- docs/MEMORY.md (document learnings)

---

## File Cross-Reference Map

**File → When it's used:**

| File | Start | Coding | Commit | Testing | Close |
|------|-------|--------|--------|---------|-------|
| AGENT_SESSION_STARTUP_SEQUENCE.md | ✅ (1) | — | — | — | — |
| SESSION_START_CHECKLIST.md | ✅ (2) | — | — | — | — |
| AGENT_GUIDELINES.md | ✅ (3) | Ref | — | — | ✅ |
| FOUNDER_GUIDELINES.md | ✅ (4) | — | — | — | — |
| docs/VISION.md | ✅ (5) | Ref | — | — | — |
| docs/PRD.md | ✅ (6) | Ref | — | — | — |
| docs/ARCHITECTURE.md | ✅ (7) | Ref | — | — | — |
| docs/MEMORY.md | ✅ (8) | Ref | — | — | ✅ Update |
| TICKETS.md | ✅ (9) | Ref | — | — | ✅ Update |
| CHANGE_CHECKLIST_QUICK_REFERENCE.txt | — | Keep on desk | ✅ | — | — |
| CHANGE_MANAGEMENT_FRAMEWORK.md | — | — | ✅ | ✅ Ref | — |
| TESTING_SCHEDULE.md | — | — | — | ✅ (timeline) | — |
| TESTING_CHECKLIST_MASTER.html | — | — | — | ✅ (Phase 3) | — |
| DOCUMENTATION_INDEX.md | — | Lookup | Lookup | — | — |
| XCODE_BUILD_CHECKLIST.md | — | — | ✅ Before build | — | — |
| CONSOLE_LOGS_DASHBOARD.md | — | — | — | Lookup | — |
| ERROR_MESSAGE_TESTING_GUIDE.md | — | — | — | ✅ (Phase 3) | — |
| XCUI_TESTS.md | — | — | — | Ref | — |

**Legend:**
- ✅ = File is read
- Ref = Referenced as lookup
- Update = File is updated
- Keep on desk = File should be visible while working
- — = File not used in this phase

---

## Quick Summary: File Access Pattern

```
SESSION START
    ↓
    Read 9 files (42 min)
    Understand: Rules, Vision, PRD, Architecture, Current State
    ↓
CODING
    ↓
    Keep on desk: CHANGE_CHECKLIST_QUICK_REFERENCE.txt
    Reference if needed: AGENT_GUIDELINES.md, docs/*
    ↓
BEFORE EVERY COMMIT
    ↓
    Check: CHANGE_CHECKLIST_QUICK_REFERENCE.txt
    Reference: CHANGE_MANAGEMENT_FRAMEWORK.md
    Run: 7 Critical Path Tests
    ↓
USER TESTING (Your responsibility)
    ↓
    Phase 1: Run 7 tests (30 min)
    Phase 2: Use app naturally (2-3 days)
    Phase 3: Run 57 scenarios (4-5 hours)
    ↓
SESSION END
    ↓
    Update: TICKETS.md, docs/MEMORY.md
    Close cleanly
```

---

## Files Organized by Purpose

### Startup Files (Read at session start)
- AGENT_SESSION_STARTUP_SEQUENCE.md
- SESSION_START_CHECKLIST.md
- AGENT_GUIDELINES.md
- FOUNDER_GUIDELINES.md
- docs/VISION.md
- docs/PRD.md
- docs/ARCHITECTURE.md
- docs/MEMORY.md
- TICKETS.md

### Working Files (Kept visible, referenced often)
- CHANGE_CHECKLIST_QUICK_REFERENCE.txt (on desk during coding)
- AGENT_GUIDELINES.md (rules reference)
- docs/PRD.md (feature spec)
- TICKETS.md (ticket details)

### Commit Files (Before every commit)
- CHANGE_CHECKLIST_QUICK_REFERENCE.txt (main checklist)
- CHANGE_MANAGEMENT_FRAMEWORK.md (detailed framework)

### Testing Files (During user testing)
- TESTING_SCHEDULE.md (timeline)
- TESTING_CHECKLIST_MASTER.html (57 scenarios)
- CHANGE_MANAGEMENT_FRAMEWORK.md (7 critical tests definition)

### Build Files (Before building on device)
- XCODE_BUILD_CHECKLIST.md

### Debug/Reference Files (As needed)
- DOCUMENTATION_INDEX.md (find anything)
- CONSOLE_LOGS_DASHBOARD.md (debug logs)
- ERROR_MESSAGE_TESTING_GUIDE.md (error testing)
- XCUI_TESTS.md (UI testing)

### Update Files (At session end)
- TICKETS.md (update status)
- docs/MEMORY.md (document learnings)

---

## TL;DR

**File usage flows:**

1. **Session start:** Read 9 files (42 min) to understand rules, vision, scope, current state
2. **During coding:** Keep CHANGE_CHECKLIST_QUICK_REFERENCE.txt on desk, reference docs as needed
3. **Before commit:** Check framework, run tests, commit
4. **During testing:** Follow TESTING_SCHEDULE.md, use TESTING_CHECKLIST_MASTER.html for Phase 3
5. **Session end:** Update TICKETS.md and docs/MEMORY.md

No need to read all files every time. Just follow the sequence.

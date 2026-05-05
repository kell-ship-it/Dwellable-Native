# File Organization Plan

**Archiving outdated files while preserving critical context**

---

## Archive Strategy

**Create:** `archive/historical/` folder

**Move 13 files there** (see below), **Keep all others in active folders**

---

## File Cleanup Manifest

### ROOT FOLDER

#### Keep ✅
| File | Purpose | When Read |
|------|---------|-----------|
| **CLAUDE.md** | Legacy repo notice + workstation instructions | Session start (confirms project is native Swift) |
| **SESSION_START_CHECKLIST.md** | 5-step startup protocol | Session start (Step 1) |
| **AGENT_GUIDELINES.md** | Rules for agent behavior | Session start (Step 3) |
| **FOUNDER_GUIDELINES.md** | User preferences (autonomy, testing, design) | Session start (Step 4) |
| **AGENT_SESSION_STARTUP_SEQUENCE.md** | 11-step agent startup (NEW) | Session start (reference) |
| **CHANGE_MANAGEMENT_FRAMEWORK.md** | Framework for safe code changes (NEW) | Before every commit |
| **CHANGE_CHECKLIST_QUICK_REFERENCE.txt** | Quick visual checklist (NEW) | Keep on desk while coding |
| **DOCUMENTATION_INDEX.md** | Directory of all docs | Lookup reference |
| **MEMORY.md** | Global project memory | Session start (Step 8) |
| **TICKETS.md** | All work items (current status) | Session start (Step 9) |
| **USER_ACTIVITIES.md** | Session notes | Working reference |
| **KUDOS.md** | Nice-to-have context | Optional |
| **HTML_LOGS_QUICK_START.md** | Debugging guide | Lookup when debugging |

#### Archive → `archive/historical/` ❌
| File | Why | Context Preserved By |
|------|-----|----------------------|
| **FRAMEWORK_IMPLEMENTATION_SUMMARY.md** | Info now in docs/ | docs/MEMORY.md § Previous State |
| **FOLDER_STRUCTURE.md** | Outdated structure | DOCUMENTATION_INDEX.md |

---

### TESTING FOLDER

#### Keep ✅
| File | Purpose | When Read |
|------|---------|-----------|
| **TESTING_CHECKLIST_MASTER.html** | Interactive 57-scenario checklist | Phase 3 (comprehensive testing) |
| **XCODE_BUILD_CHECKLIST.md** | Build verification steps | Before building on device |
| **XCUI_TESTS.md** | XCUI testing reference | Lookup when writing UI tests |
| **CONSOLE_LOGS_DASHBOARD.md** | Debug log interpretation | Lookup when debugging |
| **ERROR_MESSAGE_TESTING_GUIDE.md** | Error message validation | Phase 3 testing |

#### Archive → `archive/historical/` ❌
| File | Why | Context Preserved By |
|------|-----|----------------------|
| **LAYER_1_IMPLEMENTATION_SUMMARY.md** | March 2026, historical | docs/MEMORY.md § March 13 Session |
| **LAYER_1_READY_FOR_TESTING.md** | March 2026, historical | docs/MEMORY.md § March 13 Session |
| **LAYER_1_USER_ACTIVITIES.md** | March 2026, historical | docs/MEMORY.md § March 13 Session |
| **MANUAL_TESTING_CHECKLIST.md** | Superseded by HTML master | TESTING_CHECKLIST_MASTER.html |
| **PHASE_13_TESTING_GUIDE.md** | Phase 13 details in HTML | TESTING_CHECKLIST_MASTER.html (Phase 13 tab) |
| **T-020_SETUP_STATUS.md** | Ticket-specific, completed | TICKETS.md (T-020 marked ✅) |
| **QUICK_START_TESTING.md** | Marked archived, outdated | TESTING_SCHEDULE.md (new) |
| **TESTING_GUIDE_FOR_USERS.md** | Marked archived, outdated | TESTING_SCHEDULE.md (new) |
| **TESTING_CLARIFICATIONS.md** | Clarifications now in docs/ | docs/MEMORY.md (current context) |
| **TESTING_STRATEGY.md** | Strategy now in framework | CHANGE_MANAGEMENT_FRAMEWORK.md |
| **PHASE_13_TESTING_GUIDE.md** | Details in TESTING_CHECKLIST_MASTER.html | TESTING_CHECKLIST_MASTER.html (Phase 13 tab) |

---

## Archive Folder Structure

```
/archive/historical/
├── LAYER_1_IMPLEMENTATION_SUMMARY.md
├── LAYER_1_READY_FOR_TESTING.md
├── LAYER_1_USER_ACTIVITIES.md
├── MANUAL_TESTING_CHECKLIST.md
├── PHASE_13_TESTING_GUIDE.md
├── T-020_SETUP_STATUS.md
├── QUICK_START_TESTING.md
├── TESTING_GUIDE_FOR_USERS.md
├── TESTING_CLARIFICATIONS.md
├── TESTING_STRATEGY.md
├── FRAMEWORK_IMPLEMENTATION_SUMMARY.md
├── FOLDER_STRUCTURE.md
└── README.txt
    "These files are archived historical references from March 2026.
     Current documentation is in the root and docs/ folders.
     See DOCUMENTATION_INDEX.md for current docs."
```

---

## Context Preservation Map

**If you need info from archived files, here's where to find it:**

| Archived File | Information Type | Now Found In | Where |
|---------------|-----------------|--------------|-------|
| LAYER_1_* files | March implementation details | docs/MEMORY.md | § Previous State (March 13) |
| MANUAL_TESTING_CHECKLIST.md | Testing scenarios | TESTING_CHECKLIST_MASTER.html | All 57 scenarios |
| PHASE_13_TESTING_GUIDE.md | Phase 13 details | TESTING_CHECKLIST_MASTER.html | Phase 13 tab |
| T-020_SETUP_STATUS.md | Ticket status | TICKETS.md | T-020 row (✅ Complete) |
| QUICK_START_TESTING.md | Quick test path | TESTING_CHECKLIST_MASTER.html | Quick Test tab |
| TESTING_GUIDE_FOR_USERS.md | Testing instructions | TESTING_SCHEDULE.md | All phases |
| TESTING_CLARIFICATIONS.md | Clarifications | docs/MEMORY.md | Current context |
| TESTING_STRATEGY.md | Testing approach | CHANGE_MANAGEMENT_FRAMEWORK.md | Full framework |
| FRAMEWORK_IMPLEMENTATION_SUMMARY.md | Framework details | CHANGE_MANAGEMENT_FRAMEWORK.md | Full framework |
| FOLDER_STRUCTURE.md | Folder structure | DOCUMENTATION_INDEX.md | § File Locations |

---

## Before Archiving

These files are being kept **specifically to preserve the context** of archived files:

- **docs/MEMORY.md** — Stores historical session notes, decisions, learnings
- **TICKETS.md** — Shows what was completed (T-020 marked ✅)
- **TESTING_CHECKLIST_MASTER.html** — Consolidated all 57 scenarios (supersedes manual checklist)
- **CHANGE_MANAGEMENT_FRAMEWORK.md** — New framework supersedes old testing strategy
- **TESTING_SCHEDULE.md** — New schedule supersedes quick-start guides
- **DOCUMENTATION_INDEX.md** — Links to all active documentation

**Nothing is truly "lost"** — context is preserved in newer, consolidated files.

---

## Why This Cleanup Matters

**Before:**
- 13 redundant/historical files mixed with active docs
- Hard to know which testing guide is current
- Framework scattered across multiple files
- 40 total markdown files in root + testing/

**After:**
- 13 historical files neatly archived (still accessible)
- Clear: TESTING_CHECKLIST_MASTER.html is the source of truth
- Clear: CHANGE_MANAGEMENT_FRAMEWORK.md is the process
- Clear: TESTING_SCHEDULE.md is the timeline
- ~25 active markdown files (cleaner, faster to navigate)

---

## Ready to Archive?

**Action:** Create `archive/historical/` folder and move 13 files

Should I proceed?

✅ YES — Archive these files now
⏸️ WAIT — Review the list first

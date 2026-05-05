# Dwellable Documentation Index

**Complete map of all project documentation and where to find things.**

---

## 🎯 Start Here (First 30 Minutes)

If this is your first session or you're coming back after a break:

| File | Time | Purpose |
|------|------|---------|
| `SESSION_START_CHECKLIST.md` | 2 min | Steps to start a session |
| `AGENT_GUIDELINES.md` | 5 min | Rules for me (Claude Code Agent) |
| `FOUNDER_GUIDELINES.md` | 5 min | Rules for you (Kell) |
| `docs/VISION.md` | 5 min | Product vision |
| `docs/PRD.md` | 10 min | Features & scope |
| `docs/MEMORY.md` | 5 min | Recent decisions & blockers |

**After reading: You should be ready to confirm the active ticket and start building.**

---

## 📋 Active Work

**Current Project State:**

| Document | Purpose |
|----------|---------|
| `TICKETS.md` | Source of truth for all work items (must be presented at session open & close) |
| `TICKETS.csv` | Spreadsheet version of tickets |
| `docs/MEMORY.md` | Session notes, blockers, decisions, next steps |

---

## 🔧 Building Code

**When writing and committing code:**

| Document | Purpose | Context |
|----------|---------|---------|
| `CHANGE_MANAGEMENT_FRAMEWORK.md` | Full reference for code change protocol | Detailed, 10 sections |
| `CHANGE_CHECKLIST_QUICK_REFERENCE.txt` | Quick checklist for desk | Print this, keep visible |
| `AGENT_GUIDELINES.md` § Code Change Protocol | Summary of key rules | 2 sections |

**Workflow:**
1. Write code
2. Impact analysis (what files, what concepts)
3. Consistency check (are all instances updated)
4. Manual test (7 Critical Path tests, 30 min)
5. Commit with explanation

---

## 🧪 Testing

**Two testing contexts:**

### For Bug Fixes & Code Changes
**Before every commit to main:**
- Run: 7 Critical Path Tests (30 minutes)
- Reference: `AGENT_GUIDELINES.md` § Testing Protocol
- Purpose: Regression prevention ("Did I break anything?")

**The 7 Critical Journeys:**
1. Capture → Review → Save → View
2. Offline Capture → Sync
3. 10-Minute Recording
4. Transcription Error → Retry
5. App Backgrounding
6. Sync Queue Recovery (force-quit)
7. Text Entry

### For TestFlight Release
**Before shipping to TestFlight:**
- Run: 57 Comprehensive Scenarios (4-5 hours)
- Reference: `testing/TESTING_CHECKLIST_MASTER.html` (interactive)
- Purpose: Feature validation ("Does it work in all conditions?")

**Scenario Categories:**
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

---

## 🏗️ Architecture & Design

**Understanding the system:**

| Document | Purpose |
|----------|---------|
| `docs/ARCHITECTURE.md` | Technical architecture, design decisions |
| `docs/VISION.md` | Long-term product north star |
| `docs/PRD.md` | Features, scope, constraints |
| `CLAUDE.md` | Project commands, conventions, stack reference |

**Design Reference:**
- Prototype: `file:///Users/kell/dev/dwellable-rn-codex/design-mockups/prototype-v1.html`
- All UI must match exactly (colors, fonts, sizes, spacing)

---

## 📚 Setup Guides

**Onboarding and troubleshooting:**

| Document | Purpose |
|----------|---------|
| `guides/PHYSICAL_DEVICE_BUILD.md` | Building and installing on iPhone |
| `guides/TEST_ACCOUNT_SETUP.md` | Creating test accounts for testing |
| `guides/SUPABASE_SETUP.md` | Supabase database setup and RLS policies |
| `testing/XCODE_BUILD_CHECKLIST.md` | Xcode build verification steps |

---

## 📖 Historical Reference

**Previous session notes and decisions:**

| Document | Purpose |
|----------|---------|
| `docs/KEY_LEARNINGS.md` | Technical learnings from previous sessions |
| `docs/SESSION_CLOSING_MARCH_8.md` | Session summary from March 8 |
| `docs/WORKFLOW.md` | Git workflow and branch strategy |
| `sessions/` | Folder of historical session summaries |
| `testing/TESTING_CLARIFICATIONS.md` | March 10 testing clarifications (archived) |

**Archived Testing Guides** (superseded by TESTING_CHECKLIST_MASTER.html):
- `testing/QUICK_START_TESTING.md` — Layer 1 quick start (historical)
- `testing/TESTING_GUIDE_FOR_USERS.md` — Plain English phases (historical)

---

## 🔑 Key Files at a Glance

**The ones you reference most:**

```
├── SESSION_START_CHECKLIST.md ................. Start every session here
├── AGENT_GUIDELINES.md ........................ Rules for me (you read this)
├── FOUNDER_GUIDELINES.md ....................... Your operating rules
├── CHANGE_MANAGEMENT_FRAMEWORK.md ........... Full code change protocol
├── CHANGE_CHECKLIST_QUICK_REFERENCE.txt .... Print this for desk
│
├── TICKETS.md ................................ Source of truth (show at session open/close)
├── docs/MEMORY.md ............................. What you decide & blockers
│
├── testing/TESTING_CHECKLIST_MASTER.html .. 57 interactive test scenarios
├── docs/ARCHITECTURE.md ....................... How the system works
├── docs/PRD.md ................................ What we're building
└── docs/VISION.md ............................. Why we're building it
```

---

## ✅ Before Every Session

1. **Read SESSION_START_CHECKLIST.md** (2 min)
2. **Read guidelines** (30 min)
   - AGENT_GUIDELINES.md
   - FOUNDER_GUIDELINES.md
   - docs/VISION.md
   - docs/PRD.md
   - docs/MEMORY.md
3. **Present full ticket table** from TICKETS.md
4. **Confirm active ticket** with Kell
5. **Keep visible while coding:**
   - CHANGE_CHECKLIST_QUICK_REFERENCE.txt

---

## ✅ Before Every Commit

1. **Impact analysis** — What files, concepts affected?
2. **Consistency check** — Are all instances updated?
3. **Manual test** — 7 Critical Path tests pass?
4. **Pre-commit checklist** — No debug code, error handling, docs updated?
5. **Commit message** — Include WHAT + WHY

(See: CHANGE_MANAGEMENT_FRAMEWORK.md)

---

## ✅ At Session End

1. **Learnings** — 3-5 technical things learned
2. **Update TICKETS.md** — Mark status changes
3. **Present ticket table** — Full table, all statuses
4. **Write TL;DR summary** — For docs/MEMORY.md
5. **Document next steps** — Single most important first action
6. **Clean close** — No uncommitted changes, push to branch

---

## 🔗 Quick Links

**By Role:**

| I need to... | Read this |
|---|---|
| Start a session | SESSION_START_CHECKLIST.md |
| Understand rules | AGENT_GUIDELINES.md + FOUNDER_GUIDELINES.md |
| Fix a bug | CHANGE_MANAGEMENT_FRAMEWORK.md + 7 Critical Path Tests |
| Add a feature | docs/PRD.md + CHANGE_MANAGEMENT_FRAMEWORK.md |
| Release to TestFlight | testing/TESTING_CHECKLIST_MASTER.html (57 scenarios) |
| Understand architecture | docs/ARCHITECTURE.md + docs/VISION.md |
| Find something | This file (DOCUMENTATION_INDEX.md) |

---

## 📞 Questions?

- **What should I build next?** → TICKETS.md (see active ticket)
- **How do I build it?** → docs/PRD.md (feature description) + docs/ARCHITECTURE.md (how it fits)
- **How do I test it?** → AGENT_GUIDELINES.md § Testing Protocol
- **How do I commit it?** → CHANGE_MANAGEMENT_FRAMEWORK.md
- **What are the rules?** → AGENT_GUIDELINES.md + FOUNDER_GUIDELINES.md
- **What happened before?** → docs/MEMORY.md

---

**Last updated:** March 17, 2026

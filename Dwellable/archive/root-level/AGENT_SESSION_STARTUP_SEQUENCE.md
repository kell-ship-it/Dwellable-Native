# Agent Session Startup Sequence

**The exact order I (Claude Code Agent) read files at session start.**

This ensures I understand: (1) Who I am, (2) What the rules are, (3) What we're building, (4) What's happening now, (5) What to do next.

---

## Sequence (11 Steps)

| Step | File | Time | Purpose | What I Learn |
|------|------|------|---------|--------------|
| 1 | This file (you are here) | 1 min | Navigation | The sequence itself |
| 2 | `SESSION_START_CHECKLIST.md` | 2 min | Confirm protocol | What steps I must take |
| 3 | `AGENT_GUIDELINES.md` | 5 min | Understand rules | Rules for me, testing protocols |
| 4 | `FOUNDER_GUIDELINES.md` | 5 min | Understand preferences | Autonomy, testing standards, design rules |
| 5 | `docs/VISION.md` | 5 min | Understand WHY | Long-term product direction |
| 6 | `docs/PRD.md` | 10 min | Understand WHAT | Features, scope, constraints |
| 7 | `docs/ARCHITECTURE.md` | 5 min | Understand HOW | System design, tech stack |
| 8 | `docs/MEMORY.md` | 5 min | Understand NOW | Recent decisions, blockers, context |
| 9 | `TICKETS.md` | 3 min | Understand WORK | Read full table, identify active ticket |
| 10 | Confirm with Kell | 1 min | Get approval | Which ticket to start? |
| 11 | Start coding | — | Execute | Follow CHANGE_MANAGEMENT_FRAMEWORK.md |

**Total startup time: ~42 minutes**

---

## The Flow (Mental Model)

```
WHO AM I? (Steps 2-4)
  ↓ Read SESSION_START_CHECKLIST, AGENT_GUIDELINES, FOUNDER_GUIDELINES

WHAT ARE WE BUILDING? (Steps 5-7)
  ↓ Read VISION, PRD, ARCHITECTURE

WHAT'S HAPPENING NOW? (Steps 8-10)
  ↓ Read MEMORY, TICKETS, Confirm with Kell

WHAT DO I DO FIRST? (Step 11)
  ↓ Start building, follow framework, run tests, commit
```

---

## Why This Order Matters

**Step 2 first** (SESSION_START_CHECKLIST)
- Sets expectations: I will read 9 files in order
- Confirms the protocol

**Steps 3-4 second** (AGENT_GUIDELINES, FOUNDER_GUIDELINES)
- Establishes rules: How to work, how to test, what matters
- Without these, I'd make wrong assumptions

**Steps 5-7 third** (VISION, PRD, ARCHITECTURE)
- Context: Why the product exists, what features matter, how it's built
- Without this, I'd miss constraints or misunderstand requirements

**Steps 8-10 fourth** (MEMORY, TICKETS, Confirm)
- Current state: What was decided, what's in progress, what's next
- This activates the plan

**Step 11 last** (Start coding)
- Only after understanding all context, rules, vision, current state

---

## Files I Reference While Coding

**Before committing:**
- `CHANGE_CHECKLIST_QUICK_REFERENCE.txt` (keep on desk)
- `CHANGE_MANAGEMENT_FRAMEWORK.md` (detailed reference)
- `AGENT_GUIDELINES.md` § Code Change Protocol

**Before merging to main:**
- `AGENT_GUIDELINES.md` § Session End Protocol
- `TICKETS.md` (update status)
- `docs/MEMORY.md` (document decisions)

---

## Quick Lookup Table

**If I need to answer a question, I check:**

| Question | File | Section |
|----------|------|---------|
| What are the rules for me? | AGENT_GUIDELINES.md | All sections |
| What are your rules? | FOUNDER_GUIDELINES.md | All sections |
| What are we building? | docs/PRD.md | Feature list |
| Why are we building it? | docs/VISION.md | Vision statement |
| How is it built? | docs/ARCHITECTURE.md | Architecture sections |
| What should I build next? | TICKETS.md | First 🔄 or 🔲 ticket |
| What happened recently? | docs/MEMORY.md | Current state section |
| How do I commit code? | CHANGE_MANAGEMENT_FRAMEWORK.md | Workflow + checklist |
| What do I test before commit? | AGENT_GUIDELINES.md | Testing Protocol |
| Where do I find X? | DOCUMENTATION_INDEX.md | Quick links section |

---

## The 11-Step Sequence Visually

```
Session Start
    │
    ├─ Step 1: This file (AGENT_SESSION_STARTUP_SEQUENCE.md)
    │         "OK, I'll follow this sequence"
    │
    ├─ Step 2: SESSION_START_CHECKLIST.md
    │         "I must read 9 files in order"
    │
    ├─ Step 3: AGENT_GUIDELINES.md
    │         "I must follow these rules"
    │
    ├─ Step 4: FOUNDER_GUIDELINES.md
    │         "Kell wants autonomy, testing, consistency"
    │
    ├─ Step 5: docs/VISION.md
    │         "This is why we're building Dwellable"
    │
    ├─ Step 6: docs/PRD.md
    │         "These are the features we're building"
    │
    ├─ Step 7: docs/ARCHITECTURE.md
    │         "This is how it's architected"
    │
    ├─ Step 8: docs/MEMORY.md
    │         "These are recent decisions and blockers"
    │
    ├─ Step 9: TICKETS.md
    │         "Here's all the work, active ticket is [X]"
    │
    ├─ Step 10: Confirm with Kell
    │          "Which ticket should I start?"
    │
    └─ Step 11: Start Coding
               └─ Follow CHANGE_MANAGEMENT_FRAMEWORK.md
               └─ Run tests before committing
               └─ Document decisions
```

---

## Before Every Commit

I check my desk:
- `CHANGE_CHECKLIST_QUICK_REFERENCE.txt`

I reference:
- Impact analysis ✓
- Consistency check ✓
- 7 Critical Path tests ✓
- Pre-commit checklist ✓
- Commit message (WHAT + WHY) ✓

Only then do I commit.

---

## Before Session End

I follow:
- Step 1: Learnings
- Step 2: Update TICKETS.md
- Step 3: Present full table
- Step 4: MEMORY draft
- Step 5: Next session opener
- Step 6: Clean close

(See: AGENT_GUIDELINES.md § Session End Protocol)

---

## TL;DR

**Sequence of 11 steps:**
1. This file (orientation)
2. SESSION_START_CHECKLIST.md (protocol)
3-4. Guidelines (AGENT_GUIDELINES, FOUNDER_GUIDELINES)
5-7. Context (VISION, PRD, ARCHITECTURE)
8-10. Current state (MEMORY, TICKETS, confirm)
11. Start coding (following framework)

**Total: 42 minutes** to understand everything needed to start coding safely.

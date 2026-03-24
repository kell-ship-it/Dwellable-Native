# Session Start Checklist — Dwellable Native

**Run these steps in order at the start of every session before writing code.**

---

## Step 1: Verify Location ✅

Confirm you are in the correct directory:

```bash
pwd
# Should show: /Users/kell/Desktop/Dwellable-Native/Dwellable
```

❌ If in `/Users/kell/Projects/dwellable-rn` → **STOP. This is legacy. Use the Native project instead.**

---

## Step 2: Fetch Latest & Check Blocking Items 🚨

**CRITICAL: Do this FIRST — before reading anything else.**

### 2A: Fetch Latest from Main
```bash
git pull origin main
```
**Why:** Ensures you have the latest files from the main branch. Previous session may have updated MEMORY.md, TICKETS.md, or protocols. Always get fresh data.

### 2B: Check Blocking Items
Read top of `MEMORY.md` (🚨 **Blocking Items** section) and act on any blocking items:
- If a 🚨 **blocking item** exists → resolve it IMMEDIATELY before proceeding
- If no blocking items → proceed to Step 3

**Why:** Blocking items are external dependencies (Build approvals, waiting for user feedback, etc.) that gate all other work. Starting work on regular tickets while a blocker exists wastes time.

---

## Step 3: Read Project Guidelines 📖

Read these files **in this order** to understand the current state:

| # | File | Purpose | Time |
|---|---|---|---|
| 1 | `AGENT_GUIDELINES.md` | Rules for me (Claude Code Agent) | 5 min |
| 2 | `FOUNDER_GUIDELINES.md` | Rules for you (Kell) | 5 min |
| 3 | `docs/VISION.md` | Product vision & goals | 5 min |
| 4 | `docs/PRD.md` | Features & scope | 10 min |
| 5 | `docs/MEMORY.md` | Session decisions & blockers | 5 min |

**Total: 30 minutes**

After reading, you should be able to answer:
- What is the active feature/bug being worked on?
- What testing is already done?
- What blockers exist?

---

## Step 4: Present Ticket Table 📋

Read `TICKETS.md` and present the full ticket table to you before doing anything else.

**Table must include:**
- ✅ ALL completed tickets
- 🔄 ALL in-progress tickets
- 🔲 ALL not-started tickets
- ⚪ ANY deferred tickets

**No partial lists. Every ticket visible.**

---

## Step 5: Review Testing Protocols 🧪

Understand the two testing contexts:

**For bug fixes & code changes:**
- `CHANGE_MANAGEMENT_FRAMEWORK.md` — Full reference
- `CHANGE_CHECKLIST_QUICK_REFERENCE.txt` — Print & display while coding
- **Key rule:** Run 7 Critical Path tests before committing (30 min)

**For TestFlight validation:**
- `testing/TESTING_CHECKLIST_MASTER.html` — Interactive 57-scenario checklist
- **Key rule:** Run full testing suite after features are built (4-5 hours)

---

## Step 6: Confirm Active Ticket 🎯

State which ticket is next:
- If any ticket is 🔄 In Progress → confirm continuing it
- If none in progress → point to first 🔲 Not Started as recommendation
- Wait for your confirmation before writing code

---

## Step 7: Ready to Code ✍️

Once all above steps complete, I'm ready to:
1. Write code
2. Follow Change Management Framework
3. Run tests before committing
4. Keep you updated on progress

---

## Session End Checklist 🏁

At the end of session, before closing:

| Step | Action |
|------|--------|
| 1 | **Learnings** — 3–5 concrete technical things learned |
| 2 | **Update TICKETS.md** — Mark any status changes |
| 3 | **Present ticket table** — Full table showing current state |
| 4 | **MEMORY draft** — Summarize what was built, blockers, decisions |
| 5 | **Next session opener** — Single most important first action |
| 6 | **Clean close** — No uncommitted changes, push to branch |

---

## Quick Links

| Document | Purpose |
|----------|---------|
| `AGENT_GUIDELINES.md` | Agent rules + testing protocols |
| `CHANGE_MANAGEMENT_FRAMEWORK.md` | Full code change protocol |
| `CHANGE_CHECKLIST_QUICK_REFERENCE.txt` | Print this for desk |
| `testing/TESTING_CHECKLIST_MASTER.html` | 57 test scenarios |
| `TICKETS.md` | Source of truth for work items |
| `docs/MEMORY.md` | Session decisions & context |

---

## Remember

✅ Read guidelines first (30 min) — it answers most questions
✅ Present ticket table before code
✅ Confirm active ticket with Kell
✅ Follow Change Framework before every commit
✅ Document learnings & decisions at session end

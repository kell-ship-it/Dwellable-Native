# How to Use: Framework + Testing Plan Together

**Understanding the relationship between the Change Management Framework and Your Testing Plan**

---

## The Two Different Purposes

### 🔧 CHANGE_MANAGEMENT_FRAMEWORK.html
**Purpose:** Guide for HOW to make code changes safely
**Used by:** Me (Claude Code Agent) before EVERY commit
**Focus:** Code quality, testing protocol, consistency checking
**Contains:** 7 Critical Path test definitions, checklists, patterns

### 📋 YOUR_TESTING_PLAN.md
**Purpose:** Guide for WHAT you should test and WHEN
**Used by:** You (Kell) during manual testing phases
**Focus:** Your testing timeline and activities
**Contains:** 3 phases over 6 days, success criteria, what to document

---

## Visual: How They Work Together

```
I (Agent) WRITE CODE
        ↓
        ├─ Read: CHANGE_MANAGEMENT_FRAMEWORK.html
        ├─ Impact Analysis (from Framework)
        ├─ Consistency Check (from Framework)
        ├─ Run 7 Critical Path tests (defined in Framework)
        ├─ Verify all checks pass (from Framework)
        └─ COMMIT CODE

                    ↓

YOU (Kell) TEST CODE
        ↓
        ├─ Read: YOUR_TESTING_PLAN.md
        ├─ Phase 1: Run 7 Critical Path tests (referenced from Framework)
        ├─ Phase 2: Use app naturally (real-world testing)
        ├─ Phase 3: Run 57 comprehensive scenarios (from TESTING_CHECKLIST_MASTER.html)
        └─ Document findings
```

---

## Side-by-Side Comparison

| Aspect | Change Management Framework | Your Testing Plan |
|--------|---------------------------|-------------------|
| **Purpose** | How to code safely | What to test & when |
| **Audience** | Me (Claude Agent) | You (Kell) |
| **When used** | Before EVERY commit | Once per 6-day cycle |
| **Duration** | ~45 min per commit | 6 days total |
| **Contains** | Process, checklists, rules | Timeline, phases, success criteria |
| **Key output** | Safe commits, no regressions | Testing results, app validation |

---

## The 7 Critical Path Tests: Used in Both

### In CHANGE_MANAGEMENT_FRAMEWORK.html:
- **Defined:** Tab "Workflow" section
- **How:** Detailed steps for each journey
- **When I use it:** Before every commit, to verify my code change doesn't break core flows
- **Purpose:** Regression prevention (catch bugs before they reach you)

### In YOUR_TESTING_PLAN.md:
- **Summarized:** Phase 1 section
- **How:** Quick checklist of what to verify
- **When you use it:** TODAY (March 17) for 30 minutes
- **Purpose:** Verify recent bug fixes work correctly

**The 7 tests are EXACTLY THE SAME in both files** — the Framework defines HOW I test them, Your Plan defines WHEN you test them.

---

## Timeline: How They Sequence

```
NOW (March 17)
  ├─ You: Run Phase 1 (7 Critical Path tests from YOUR_TESTING_PLAN)
  └─ Time: 30 minutes

DAYS 2-4 (March 18-20)
  ├─ You: Use app naturally (Phase 2 from YOUR_TESTING_PLAN)
  └─ Time: 2-3 hours per day

DAYS 5-6 (March 21-22)
  ├─ You: Run Phase 3 (57 comprehensive scenarios from YOUR_TESTING_PLAN)
  ├─ Reference: TESTING_CHECKLIST_MASTER.html
  └─ Time: 4-5 hours

AFTER PHASE 3 COMPLETE
  ├─ You: Ship to TestFlight

THROUGHOUT ALL PHASES
  └─ If I fix bugs while you're testing:
      ├─ I: Use CHANGE_MANAGEMENT_FRAMEWORK to make safe changes
      ├─ You: Re-run Phase 1 (7 tests) to verify fix works
      └─ I: Reference FRAMEWORK to ensure consistency
```

---

## When YOU Use Each File

### 📋 YOUR_TESTING_PLAN.md — Read This First

**When:** TODAY (March 17)
**Why:** Understand your overall testing timeline
**What to do:**
1. Open YOUR_TESTING_PLAN.md
2. Read the 6-day timeline
3. Understand the 3 phases
4. Start Phase 1 (7 Critical Path tests)

### 🔧 CHANGE_MANAGEMENT_FRAMEWORK.html — Reference During Phase 1

**When:** TODAY, during Phase 1 testing
**Why:** Get the detailed steps for the 7 Critical Path tests
**What to do:**
1. Open CHANGE_MANAGEMENT_FRAMEWORK.html in browser
2. Go to "Workflow" tab
3. Expand each of the 7 journeys
4. Follow the detailed steps
5. Document results (PASS/FAIL)

### 📊 TESTING_CHECKLIST_MASTER.html — Use During Phase 3

**When:** March 21-22 (Phase 3)
**Why:** Run through all 57 comprehensive scenarios
**What to do:**
1. Open TESTING_CHECKLIST_MASTER.html in browser
2. Run each scenario
3. Fill in Status/Notes for each
4. Submit results

---

## How I Use These Files

### Before EVERY Commit:

**Step 1: Open CHANGE_MANAGEMENT_FRAMEWORK.html**
```
Tab: "Overview" → Understand 4-step safety system
Tab: "Impact" → Document what files I'm changing
Tab: "Consistency" → Check if this pattern appears elsewhere
Tab: "Workflow" → Run 7 Critical Path tests
Tab: "Checklist" → Walk through pre-commit checklist
```

**Step 2: Run 7 Critical Path Tests**
- From "Workflow" tab in CHANGE_MANAGEMENT_FRAMEWORK.html
- Build on device
- Test each journey
- Document: ✅ PASS or 🔴 FAIL

**Step 3: Commit Only if All Pass**
- From "Checklist" tab: Walk through checklist
- Write good commit message
- Push to branch

---

## Example: If I Fix a Bug

### Scenario: You report "App crashes when saving in offline mode"

**I do:**
1. Open CHANGE_MANAGEMENT_FRAMEWORK.html
2. Go to "Impact" tab
3. Create impact map:
   ```
   Files affected: SyncManager.swift, APIClient.swift, ReviewView.swift
   Concepts: Offline-first pattern (appears in 3 places)
   User flows: Offline save → Sync
   ```
4. Go to "Consistency" tab
5. Verify I update all 3 files using the Offline-first pattern
6. Go to "Workflow" tab
7. Run 7 Critical Path tests
   - Especially Journey 2 (Offline Capture → Sync)
8. If all pass: Commit
9. Tell you: "Fixed offline crash. Run Phase 1 tests to verify."

**You do:**
1. Open YOUR_TESTING_PLAN.md
2. Re-read Phase 1
3. Open CHANGE_MANAGEMENT_FRAMEWORK.html
4. Go to "Workflow" tab → Journey 2 (Offline Capture → Sync)
5. Run the test manually on your iPhone
6. Verify: ✅ PASS
7. Tell me: "Phase 1 test 2 passes — crash is fixed"

---

## Quick Lookup Guide

**Question:** How do I run the 7 Critical Path tests?
**Answer:** Open YOUR_TESTING_PLAN.md → Phase 1 section (quick summary)
**Detailed steps:** Open CHANGE_MANAGEMENT_FRAMEWORK.html → Workflow tab

---

**Question:** What should I test on March 21?
**Answer:** Open YOUR_TESTING_PLAN.md → Phase 3 section
**Detailed scenarios:** Open TESTING_CHECKLIST_MASTER.html

---

**Question:** How should I document my testing results?
**Answer:** Open YOUR_TESTING_PLAN.md → "What to Document" section

---

**Question:** What if a test fails?
**Answer:** Open CHANGE_MANAGEMENT_FRAMEWORK.html → Reference tab → Emergency Decision Tree

---

## TL;DR

**CHANGE_MANAGEMENT_FRAMEWORK.html:**
- I use before every commit
- You reference during Phase 1 testing
- Contains detailed procedures and safety checks
- Prevents regressions

**YOUR_TESTING_PLAN.md:**
- You use to understand timeline
- 3 phases over 6 days
- Tells you WHAT to do and WHEN
- Contains success criteria

**Together they ensure:**
- ✅ Code changes are safe (Framework)
- ✅ You test thoroughly (Plan)
- ✅ Bugs are caught before shipping (Both)
- ✅ App is validated before TestFlight (Both)

---

## Files to Keep Visible

**Right now (March 17):**
- 📋 YOUR_TESTING_PLAN.md (read first)
- 🔧 CHANGE_MANAGEMENT_FRAMEWORK.html (reference during Phase 1)
- ✅ CHANGE_CHECKLIST_QUICK_REFERENCE.txt (for me, before commits)

**During Phase 3 (March 21-22):**
- 📊 TESTING_CHECKLIST_MASTER.html (main testing guide)
- 📋 YOUR_TESTING_PLAN.md (timeline reference)

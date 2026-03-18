# Dwellable Change Management Framework

**Purpose:** Ensure every code change is safe, consistent, and doesn't break existing flows.

**When to use:** Before committing ANY feature, bug fix, or refactor.

---

## 1. CHANGE IMPACT ANALYSIS

Before writing code, answer these questions:

### What files will this change touch?
```
Example: Fixing [BLANK_AUDIO] stripping
Files affected:
- TranscriptionManager.swift (core change)
- ReviewView.swift (uses transcript)
- XCUI tests for transcription (test file)
```

### What concepts/patterns appear in multiple places?
```
Example: The concept of "transcript validation" appears in:
1. TranscriptionManager.transcribeAudio() — strips [BLANK_AUDIO]
2. ReviewView — shows loading spinner while momentBody empty
3. APIClient.saveMoment() — validates non-empty body before API call

If you change #1, you must verify #2 and #3 still work correctly.
```

### What other screens depend on this data?
```
Example: If you change how audio is stored:
- ReviewView displays audio (don't break)
- MomentDetailView plays audio (don't break)
- MomentsListView shows audio indicators (don't break)
- SyncManager queues audio uploads (don't break)

Each must be tested.
```

### Create an Impact Map
Before starting:
```markdown
## Change: [Describe the change]

**Files modified:**
- [ ] File A (line X-Y)
- [ ] File B (line X-Y)

**Concepts affected:**
- [ ] Concept 1 (appears in: Screen A, Manager B, API C)
- [ ] Concept 2 (appears in: Screen D, Test E)

**User flows impacted:**
- [ ] Capture + Review + Save
- [ ] Offline save + Sync + List
- [ ] View moment + Edit + Save
- [ ] (others)

**Tests that MUST pass:**
- [ ] Critical Path tests (see section 4)
- [ ] Tests for affected concepts
```

---

## 2. CONSISTENCY CHECKLIST

When a concept appears in multiple places, ensure all instances are updated:

### Example: Recording Duration Limits

**Pattern:** "10-minute recording with 9-minute warning"

**Where this appears:**
1. ✅ CaptureView — shows 9:00 warning (gold message)
2. ✅ AudioRecordingManager — auto-stops at 10:00
3. ✅ Timer logic — calculates remaining time
4. ✅ Tests — verify warning + auto-stop
5. ✅ Docs — documented in CLAUDE.md
6. ✅ UI text — consistent phrasing ("60 seconds left")

**If you change #1 (warning text), verify:**
- [ ] All 6 instances still work together
- [ ] Tests still pass
- [ ] User sees consistent UX across all screens

### Consistency Checklist Template
```markdown
## Consistency: [Pattern name]

**Appears in:**
- [ ] CaptureView (verify behavior)
- [ ] ReviewView (verify behavior)
- [ ] MomentDetailView (verify behavior)
- [ ] Tests (verify coverage)
- [ ] Docs (verify updated)

**If any file changes:**
- [ ] All instances still work together
- [ ] User sees consistent UX
- [ ] Behavior documented
```

---

## 3. CRITICAL PATH TEST SUITE

**Minimum tests that MUST PASS before any commit.**

### The 7 Critical User Journeys
Every change must pass these end-to-end flows:

```
JOURNEY 1: Capture + Save + View
1. Open app → Login
2. Tap record button
3. Speak for 5 seconds
4. Review transcript (verify no blank state)
5. Tap Save
6. Moment appears in list
7. Tap moment → view detail
✅ If any step fails: DO NOT COMMIT

JOURNEY 2: Offline Capture + Sync
1. Disable WiFi/Cellular (Airplane mode)
2. Record 5 seconds
3. Save moment
4. Verify moment in list (offline)
5. Enable network
6. Verify moment syncs (check list updates)
✅ If any step fails: DO NOT COMMIT

JOURNEY 3: 10-Minute Recording
1. Start recording (tap record)
2. Record continuously for 10 minutes
3. Verify warning appears at 9:00 ("60 seconds left")
4. Verify recording auto-stops at 10:00
5. Review transcript
6. Save moment
✅ If any step fails: DO NOT COMMIT

JOURNEY 4: Transcription Error + Retry
1. Record 2 seconds of silence
2. Verify error message (not blank moment)
3. Tap "Retry Transcription"
4. Record valid audio
5. Verify transcription completes
6. Save moment
✅ If any step fails: DO NOT COMMIT

JOURNEY 5: App Backgrounding
1. Start recording
2. Record 3 seconds
3. Background app (home button)
4. Verify recording stopped
5. Reopen app
6. Verify you're back at home screen (not ReviewView)
✅ If any step fails: DO NOT COMMIT

JOURNEY 6: Sync Queue Recovery
1. Save moment while offline
2. Force-quit app (swipe from recents)
3. Reopen app
4. Verify moment still there
5. Enable network
6. Verify moment syncs
✅ If any step fails: DO NOT COMMIT

JOURNEY 7: Text Entry
1. Tap "Type" tab in Capture
2. Enter 200+ words
3. Save moment
4. Verify appears in list
5. Tap moment → view detail
6. Verify full text displays
✅ If any step fails: DO NOT COMMIT
```

### How to Run Critical Path Tests
```bash
# Before committing ANY change:
1. Build app (Xcode)
2. Install on physical device (iPhone 13+)
3. Run Journey 1 (2-3 min)
4. Run Journey 2 (3-4 min)
5. Run Journey 3 (10+ min)
6. Run Journey 4 (2 min)
7. Run Journey 5 (2 min)
8. Run Journey 6 (2 min)
9. Run Journey 7 (2 min)

Total: ~30 minutes per commit

Document results:
✅ PASS or 🚫 FAIL + details
```

---

## 4. AUTOMATED TEST SCOPE (Honest Assessment)

### What I CAN Test Reliably (10-15 tests)

**Pure Logic Unit Tests (5-8 tests):**
- String cleaning (`[BLANK_AUDIO]` stripping)
- Transcript validation (empty detection, edge cases)
- Text normalization (UTF-8, emoji preservation)
- Timestamp calculations (timer logic)
- Data transformation (model mapping)

**Schema Verification Tests (3-5 tests):**
- Tables exist in database
- Columns correct type/nullable
- RLS policies in place
- Indexes created
- Foreign keys defined

**API Contract Tests (2-3 tests):**
- Request format correct (mocked)
- Response parsing works
- Error handling (mocked failures)

**Total reliable tests: ~10-15**

All must PASS before code is merged.

---

### What I CANNOT Test (without major issues)

**❌ Integration Tests** — Would pollute your production database
- Real API calls create test data
- Side effects can't be cleaned up
- Risk data contamination

**❌ Real Network Tests** — Would waste storage & create orphaned data
- Audio upload tests create files in your Storage
- Sync tests create moments you can't delete
- Network timeout tests are unreliable

**❌ Audio/Transcription Tests** — No hardware access
- Can't access device microphone
- Can't run WhisperKit ML model
- Can't measure transcription accuracy
- Can't generate test audio programmatically

**❌ UI/XCUI Tests** — Flaky and unreliable on simulator
- Simulator crashes after 60 seconds (you verified this earlier)
- Tests are slow and timing-dependent
- Visual regression can't be tested programmatically
- SwiftUI preview testing is very limited

**❌ Device-Specific Tests** — Can't control iOS lifecycle
- Can't toggle airplane mode
- Can't trigger low battery
- Can't measure real battery drain
- Can't test force-quit recovery
- Can't control network conditions (WiFi vs cellular)

---

### The Real Testing Split

**What I write (automated):**
- ~15 unit tests (pure logic, no side effects)
- Catches: obvious bugs, edge cases, data transformation errors

**What you write (manual):**
- 7 Critical Path tests (regression prevention, 30 min)
- 57 Comprehensive scenarios (feature validation, 4-5 hours)
- Catches: UX issues, device-specific bugs, real-world edge cases, performance problems

**Why this ratio:** The app's value is in audio, transcription, sync, and UX. These require real device interaction and human validation. Unit tests are supporting roles, not the main story.

---

## 5. CODE REVIEW CHECKLIST

**Before submitting a PR, walk through this:**

### Pre-Submission Checklist
```markdown
## PR: [Title]

### Scope
- [ ] What exactly did you change? (1-2 sentences)
- [ ] Why? (what problem does this solve?)
- [ ] Impact map completed (see section 1)
- [ ] Consistency checklist completed (see section 2)

### Testing
- [ ] Critical Path tests run (all 7 journeys pass)
- [ ] Automated tests written (or updated)
- [ ] No new warnings/errors in Xcode
- [ ] Manually tested on device (not simulator only)
- [ ] Tested with different network conditions (WiFi, cellular, offline)

### Code Quality
- [ ] Code follows existing patterns
- [ ] No commented-out code
- [ ] No debug print statements (remove before submit)
- [ ] No force-unwrapping (use guard/if-let)
- [ ] Error handling included
- [ ] No hardcoded strings (use constants)

### Consistency
- [ ] If updating UI, checked all screens using same component
- [ ] If updating logic, verified all call sites still work
- [ ] If adding field, updated database schema + API
- [ ] If changing API, updated APIClient in all places
- [ ] Docs updated (CLAUDE.md, comments, etc)

### Commit Message
- [ ] Message describes WHAT changed
- [ ] Message describes WHY it changed
- [ ] References ticket/issue if applicable
- [ ] Example: "Fix: Strip [BLANK_AUDIO] marker from transcripts — prevents garbled moments from being saved"
```

---

## 6. CHANGE CATEGORIES & TESTING REQUIREMENTS

Different types of changes require different testing rigor:

### CATEGORY A: Bug Fixes
**Examples:** Fix [BLANK_AUDIO] stripping, fix transcription timeout

**Testing required:**
- ✅ Reproduce the bug manually
- ✅ Verify fix works manually
- ✅ Run Critical Path tests (all 7 journeys)
- ✅ Run automated tests (all 40 if they exist)
- ✅ No new bugs introduced

**Commit time:** 30-45 min

### CATEGORY B: Small Features
**Examples:** Add "edit moment" button, change warning text color

**Testing required:**
- ✅ Feature works as designed
- ✅ Run Critical Path tests (focus on affected journeys)
- ✅ Run automated tests
- ✅ Consistency check (does this pattern appear elsewhere?)
- ✅ UI looks good across screen sizes

**Commit time:** 1-2 hours

### CATEGORY C: Medium Features
**Examples:** Add audio playback, add type flow

**Testing required:**
- ✅ All small feature tests
- ✅ Run ALL Critical Path tests (7 journeys)
- ✅ Test edge cases (empty input, long input, special chars)
- ✅ Test with different device states (low battery, background, offline)
- ✅ Performance check (no memory leak, no CPU spike)

**Commit time:** 3-5 hours

### CATEGORY D: Large Features / Architectural Changes
**Examples:** Refactor sync logic, change data model, rewrite authentication

**Testing required:**
- ✅ All medium feature tests
- ✅ Create new automated tests
- ✅ Test backward compatibility
- ✅ Test with real data (not just empty app)
- ✅ Load test (100+ moments, rapid syncs, etc)
- ✅ Code review from another person
- ✅ Consider creating a dev branch / staging

**Commit time:** 5+ hours

---

## 7. CONSISTENCY PATTERNS IN DWELLABLE

### Pattern 1: Recording State Machine
**Where it appears:**
- CaptureView (shows UI state)
- AudioRecordingManager (manages recording)
- ReviewView (handles transcription state)

**Consistency rule:** If you change recording state flow, update ALL three.

### Pattern 2: Moment Validation
**Where it appears:**
- ReviewView (client-side validation)
- TranscriptionManager (reject silence)
- APIClient.saveMoment() (server-side validation)

**Consistency rule:** If you change what's valid, update ALL three.

### Pattern 3: Offline-First Pattern
**Where it appears:**
- SyncManager (queue logic)
- APIClient (retry logic)
- MomentsListView (show pending indicator)

**Consistency rule:** If you change sync logic, update ALL three.

### Pattern 4: Error Messages
**Where it appears:**
- TranscriptionManager (transcription errors)
- AudioRecordingManager (recording errors)
- APIClient (network errors)

**Consistency rule:** All errors should use similar language/style.

---

## 8. WORKFLOW: BEFORE YOU COMMIT

```
Step 1: Write code
  → Make your change
  → Compile (Xcode)
  → No warnings/errors?

Step 2: Impact analysis
  → What files changed?
  → What concepts affected?
  → What flows impacted?
  → Create impact map

Step 3: Consistency check
  → Does this pattern appear elsewhere?
  → Are all instances updated?
  → Complete consistency checklist

Step 4: Manual testing (30 min)
  → Build on device
  → Run Critical Path tests (all 7 journeys)
  → All pass?

Step 5: Automated tests
  → Run existing tests (10-15 unit + schema tests if written)
  → All pass?
  → Write new unit tests if needed for pure logic

Step 6: Code review checklist
  → Walk through pre-submission checklist
  → Everything checked?

Step 7: Commit
  → Good commit message (WHAT + WHY)
  → Push to branch
  → Create PR if needed

Step 8: Merge
  → All tests pass
  → Code review complete
  → No outstanding issues
  → Merge to main
```

---

## 9. DOCUMENTATION & TRACKING

### Every Commit Should Answer
```
WHAT changed?
- List files modified
- One sentence summary

WHY changed?
- What problem does this solve?
- What user need does this address?

HOW was it tested?
- Critical Path tests: ✅ PASS
- Automated tests: ✅ PASS (or list which ones)
- Manual testing: ✅ Device tested

CONSISTENCY check?
- Patterns updated: yes/no
- Docs updated: yes/no

Example commit message:
---
Fix: Strip [BLANK_AUDIO] marker from transcripts

Prevents garbled [BLANK_AUDIO] text from being saved as moments.
Updates TranscriptionManager to remove marker from any position.

Testing: Critical Path tests 1-7 pass. Verified silence still rejected.
Consistency: ReviewView loading state verified. No other affected.
Docs: Updated CLAUDE.md with known limitation about silence detection.
```
```

---

## 10. QUICK REFERENCE: CHANGE CHECKLIST

**Print this and use before every commit:**

```
📋 BEFORE COMMITTING

□ Built successfully (no warnings/errors)
□ Impact map completed
□ Consistency checklist completed
□ Critical Path tests: ALL PASS (7 journeys, 30 min)
□ Automated tests: ALL PASS (or new ones written)
□ Code review checklist completed
□ Commit message includes WHAT + WHY
□ Docs updated (if needed)
□ No debug code / console logs remaining
□ Error handling present

If ANY are unchecked: DO NOT COMMIT
If ALL are checked: Safe to merge
```

---

## Why This Framework

✅ **Prevents regressions** — Critical Path tests catch breaks before they reach main branch
✅ **Ensures consistency** — Consistency checklist finds places where the same concept appears
✅ **Scales safely** — As codebase grows, framework keeps it maintainable
✅ **Documents intent** — Every change has clear "why" for future you
✅ **Enables confidence** — You know changes are safe before shipping to TestFlight

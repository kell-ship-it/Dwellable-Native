# MEMORY — Session Log

---

## Session: March 10, 2026 — Testing Results Analysis & Enhancements

**TL;DR:**
- ✅ **Fixed text input placeholder** — Added "Begin here..." to TypeFlowView's moment body field (issue from testing session)
- ✅ **Created 2 new tickets** from testing feedback (T-029: offline sign-in, T-030: app reinstall recovery)
- ✅ **Documented test clarifications** in TESTING_CLARIFICATIONS.md for MAYBE tests
- Testing checklist improvements from previous session working perfectly — 10/10 tests passed, general issues with image support exported successfully
- 42 total tickets now (was 40), 27 complete (65%), 15 not started

**What was fixed/built:**
1. **TypeFlowView placeholder text enhancement**
   - Issue: Users didn't realize they could type into the moment body field
   - Solution: Added "Begin here..." placeholder using ZStack overlay
   - Commit: d518184
   - Status: ✅ Complete

2. **Ticket creation from testing results**
   - T-029: Support offline sign-in or clarify requirements
   - T-030: Handle app reinstall with offline moments gracefully
   - Both tickets created in TICKETS.md with full context
   - Commit: a864d35

3. **Testing clarification documentation**
   - Created TESTING_CLARIFICATIONS.md to answer MAYBE test questions
   - Test 1.5: Explained expected behavior (data loss on reinstall is intentional)
   - Test 2.5: Confirmed sign-out flow is working correctly
   - Test 1.1: Documented offline sign-in requirements (see T-029)
   - Commit: a864d35

**Test Results Context:**
- Source: Dwellable_Testing_Results_2026-03-10.txt exported from testing checklist
- Device: iPhone 13
- Results: 10 tests PASS, 1 MAYBE (Test 1.5), 0 FAIL
- Key finding: General issues section with multi-image support worked perfectly
- User feedback captured: 2 screenshots of text input placeholder issue

**Decisions made:**
- Keep offline moment behavior as-is for v1.0 (local-only, lost on reinstall)
- Document options for cloud sync in v1.1 (T-030)
- Treat offline sign-in as design decision (waiting on Kell's input for T-029)
- Mark Test 2.5 as PASS with no changes needed

**What's working:**
- Testing checklist with multi-image support ✅
- General issues export with images ✅
- Text input placeholder discovery ✅
- Issue capture and ticketing workflow ✅

**Next session priorities:**
- Get Kell's decision on T-029 (offline sign-in) and T-030 (cloud sync)
- Continue with remaining sub-screens (T-010: SettingsView, etc.)
- Consider T-009 style refinements if needed

---

## Session: March 7, 2026, ~7:00–8:15 PM

**What was built/fixed:**
- Fixed JSON decoding: Added CodingKeys to Moment model (snake_case ↔ camelCase) and custom ISO 8601 date decoder with fractional seconds
- Fixed save functionality: Rewrote `saveMoment()` to bypass response decoding (Supabase returns empty body or array); added 15s timeout
- Fixed `Prefer: return=representation` header for POST/PATCH/PUT
- Added `MainActor.run` wrapping for all UI state updates in async save paths
- Cleaned duplicate moments from database (63 → 13 unique)
- Added auto-create user on login (ensureUserExists) to fix foreign key constraint

**Open blockers:**
- **B-001:** Post-save navigation broken — after saving a moment, user bounces through CaptureView instead of going directly to MomentsListView. Two approaches tried: (1) dismiss() in child views conflicts with isPresented binding, causing re-push loop; (2) callback-only approach (onMomentSaved → onChange in CaptureView) doesn't reliably fire. Next: add debug prints to verify onChange fires, or switch to NavigationPath-based programmatic navigation.

**Decisions made:**
- saveMoment() bypasses all response decoding — just checks for 2xx status and returns local moment
- CaptureView is sole navigation owner (no dismiss() in ReviewView/TypeFlowView)
- Database columns: moments table has only id, user_id, body, created_at, updated_at (no sense_of_lord or synced_at)

**What's working on device:**
- Login ✅, moments list loading ✅, voice recording ✅, transcription ✅, save to Supabase ✅
- Navigation after save ❌ (B-001)

**Next session opener:**
- **B-001: Fix post-save navigation.** Add `print("🟡 CaptureView: onChange fired, momentWasSaved=\(saved)")` to CaptureView's onChange handler and rebuild. If it doesn't fire, the onMomentSaved callback isn't setting momentWasSaved — switch to a NavigationPath on MomentsListView for programmatic pop-to-root.

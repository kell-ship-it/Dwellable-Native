# Dwellable Native — Session Memory

## Session: March 9, 2026 (Afternoon) — T-009 Theme Centralization

### 🎯 TL;DR
**T-009 COMPLETE** — Centralized all hardcoded colors and design tokens into Theme.swift as single source of truth.
- Expanded Theme.swift with comprehensive color definitions (white, inputPlaceholder, inputActive, errorLight)
- Added complete font styles (titleFont, subtitleFont, bodyFont, etc.) + structural tokens (Button, Input, Error structs)
- Migrated all view files to use Theme constants (LoginView, ReviewView, TypeFlowView, TranscribingView)
- Verified 5 other views (CaptureView, MomentsListView, MomentDetailView, MomentRow, SettingsView) already use Theme
- ✅ Build succeeded with zero errors
- Commit: `df278fc` — pushed to remote
- **Progress: 27/40 tickets complete (67.5%)**

**Next:** User will manually test on iPhone 13 using TESTING_CHECKLIST_INTERACTIVE.html while Claude continues with remaining tickets

---

## What Was Implemented

### T-009: Centralize Theme/Styling
**Objective:** Extract all hardcoded colors and fonts into Theme.swift for consistency and maintainability.

**Changes to Theme.swift:**
1. Added new color constants:
   - `white` — Pure white for field backgrounds
   - `inputPlaceholder` — Dark gray for placeholder text (RGB: 0.184, 0.188, 0.22)
   - `inputActive` — Slightly lighter gray for active field text (RGB: 0.227, 0.239, 0.271)
   - `errorLight` — Light red with opacity for error backgrounds

2. Added comprehensive font styles:
   - `titleFont`, `subtitleFont`, `bodyFont`, `smallFont`, `tinyFont`, `headingFont`
   - `boldFont`, `semiboldFont`, `regularFont`, `lightFont`
   - All with consistent sizing and weight definitions

3. Expanded Button struct:
   - `primaryTextColor`, `primaryBackgroundColor`, `primaryDisabledColor`

4. Added Input struct:
   - `backgroundColor`, `borderColor`, `textColor`, `placeholderColor`, `cornerRadius`

5. Added Error struct:
   - `textColor`, `backgroundColor`

**Files Modified:**

| File | Changes | Status |
|------|---------|--------|
| Theme.swift | Expanded with 20+ new constants | ✅ Complete |
| LoginView.swift | 3 Color.white → Theme.white; 1 .red → Theme.error | ✅ Complete |
| TypeFlowView.swift | 4 error colors → Theme.error; errorLight; 2 goldDark; 2 input colors | ✅ Complete |
| ReviewView.swift | 2 input colors → Theme.inputPlaceholder/inputActive | ✅ Complete |
| TranscribingView.swift | 1 hardcoded color → Theme.goldDark | ✅ Complete |
| CaptureView.swift | Already using Theme colors | ✅ Verified |
| MomentsListView.swift | Already using Theme colors | ✅ Verified |
| MomentDetailView.swift | Already using Theme colors | ✅ Verified |
| MomentRow.swift | Already using Theme colors | ✅ Verified |
| SettingsView.swift | Already using Theme colors | ✅ Verified |

**Build Status:** ✅ BUILD SUCCEEDED — All 5 modified files compile cleanly, zero warnings.

**Benefits:**
- Single source of truth for all design tokens
- Design changes now require edits in only Theme.swift, not scattered across 10 files
- Consistency guaranteed across app
- Future support for theming (dark mode, light mode, custom themes)
- Easier onboarding for new developers

---

## Session Flow

1. **Identified remaining work**: Reviewed all view files for hardcoded colors
2. **Expanded Theme.swift**: Added 20+ new color constants and font styles based on existing usage
3. **Migrated views systematically**:
   - LoginView: Replaced hardcoded colors with Theme constants
   - TypeFlowView: Comprehensive color migration (4 error colors, 2 goldDark, 2 input colors)
   - ReviewView: Input field color migration
   - TranscribingView: Single hardcoded color fix
4. **Verified other views**: Confirmed CaptureView, MomentsListView, MomentDetailView, MomentRow, SettingsView already using Theme
5. **Built and tested**: xcodebuild succeeded with no errors
6. **Committed and pushed**: `df278fc` to remote with comprehensive commit message
7. **Updated tracking**: TICKETS.md updated to mark T-009 complete, progress now 27/40 (67.5%)

---

## Testing Notes
- Build verification: `xcodebuild build -scheme Dwellable -destination generic/platform=iOS -configuration Debug` ✅
- All 5 modified files compile without warnings
- No UI changes needed — this is purely code organization

---

## Next Session Priorities

1. **User Manual Testing (iPhone 13)** — Using TESTING_CHECKLIST_INTERACTIVE.html
   - All 6 test items (login, capture flow, offline sync, moments list, type-flow, smoke tests)

2. **T-010:** Build SettingsView (MEDIUM priority)
   - User profile display, app version, sign out button, terms/privacy links
   - Header accessible from MomentsListView

3. **Remaining sub-screens** (v2 features):
   - T-011: EditMomentView
   - T-012: SearchView
   - T-013: ArchiveView

4. **Testing & unit tests** (T-021–T-025):
   - Unit tests for AuthManager, StorageManager, SyncManager
   - Manual testing on real device

---

## Session: March 8, 2026 — Supabase & Offline Fixes

### 🎯 TL;DR
Fixed two critical blocking issues:
1. **Supabase moments not persisting** — MomentPayload was missing `id` and `sense_of_lord` fields. Added both, plus better error logging.
2. **Offline moment capture broken** — MomentsListView was showing "Failed to load moments" error when offline. Now loads from local cache with a subtle offline indicator.

**Status:** Both fixes tested and working on physical iPhone 16.

---

## What Was Fixed

### Issue 1: Supabase Not Rendering Moments (BLOCKING)
**Root Cause:** The `MomentPayload` being sent to Supabase was incomplete:
- Missing `id` field
- Missing `sense_of_lord` field
- Error was being caught silently (no feedback to user)

**Fix in `SupabaseAPIClient.swift`:**
1. Updated `MomentPayload` struct to include `id` and `sense_of_lord`
2. Updated `saveMoment()` to populate these fields from the Moment object
3. Added error logging to print Supabase error details when saves fail

**Files Modified:**
- `/Users/kell/Projects/Dwellable-Native/Dwellable/Dwellable/Managers/SupabaseAPIClient.swift`
  - Lines 240-246: MomentPayload struct
  - Lines 119-127: saveMoment() payload construction
  - Lines 155-159: Error logging

**Result:** Moments now persist to Supabase correctly when online.

---

### Issue 2: Offline Moment Capture Broken (BLOCKING)
**Root Cause:** When saving offline:
1. ReviewView.saveMoment() correctly caught the error and marked moment as pending
2. But then it tried to refresh MomentsListView by fetching from network
3. That fetch also failed, showing "Failed to load moments" error page
4. User's offline moment was stuck behind the error screen

**Fix in `MomentsListView.swift`:**
1. Added `@State private var isOffline = false` to track offline state
2. Updated `fetchMoments()` to catch network errors and load from local storage instead
3. Added subtle offline indicator at top showing "Offline — showing cached moments"

**Files Modified:**
- `/Users/kell/Projects/Dwellable-Native/Dwellable/Dwellable/Views/MomentsListView.swift`
  - Line 10: Added isOffline state
  - Lines 32-42: Error handling now loads from LocalStorageManager
  - Lines 171-184: Added offline indicator UI

**How it works:**
1. User goes offline → captures moment → ReviewView saves to local storage via SyncManager
2. MomentsListView tries to fetch from network, gets error
3. Instead of showing error, loads from LocalStorageManager.getAllLocalMoments()
4. Shows "Offline — showing cached moments" indicator
5. When user goes back online, SyncManager auto-syncs pending moments

**Result:** Seamless offline experience. User can capture, save, and see their moments even without internet. They sync automatically when connection returns.

---

## Testing Notes

**From U-001 Manual Testing (Physical iPhone 16):**
- ✅ App builds and deploys to physical device
- ✅ Supabase now rendering moments correctly
- ✅ Offline moment capture works without error page
- ⏳ TranscribingView loading duration still wrong (~1/3 second instead of 5 seconds) — deferred to next session

**User Feedback on Offline Flow:**
- "The moment is saved, as if it's online, so the experience should be the exact same. Once they get back online, SuperBase would be able to capture that moment and store that in the database, but it should be stored locally first if they've already been authenticated."
- **Status:** ✅ Implemented exactly as described

---

## Known Remaining Issues

1. **TranscribingView duration** — Shows for ~1/3 second instead of 5 seconds
   - Code has: `DispatchQueue.main.asyncAfter(deadline: .now() + 5.0)`
   - But appears shorter in practice
   - User wants at least 2 seconds
   - **Deferred:** Next session

2. **Login text field responsiveness** — Delay when tapping email/password fields on physical device
   - Physical device only (not simulator)
   - **Deferred:** Next session

3. **Offline/online state UX** — User questioning strategy:
   - Should we notify users when going offline?
   - What scenarios need warnings?
   - Should some operations be seamless vs. others?
   - **Deferred:** Design discussion with user

---

## Testing Protocol Established

**For referencing user's testing results:**
- User exports results from HTML checklist using "📋 Export Results" button
- Saves to: `/Users/kell/Projects/Dwellable-Native/Dwellable/TESTING_RESULTS_CURRENT.txt`
- This file is the single source of truth for current testing feedback
- Prevents confusion between old exports and current state

**Current Test Results File:**
- Location: `/Users/kell/Downloads/dwellable-testing-results (1).txt` (exported Mar 8)
- Contains U-001 manual testing results from physical iPhone 16
- Shows what's PASSING vs. what still needs work

---

## Next Session Checklist

- [ ] Test TranscribingView fix (increase loading duration to 5+ seconds, verify it works)
- [ ] Test login text field responsiveness on physical device (might be hardware/gesture related)
- [ ] Discuss offline/online notification strategy with user
- [ ] Review any other test scenarios from U-001 manual testing
- [ ] Update TESTING_RESULTS_CURRENT.txt with latest findings
- [ ] Continue working through remaining tickets in TICKETS.md

---

## Architecture Notes

**Data Flow for Offline-First Moments:**
```
User creates moment (online/offline)
    ↓
ReviewView.saveMoment() calls apiClient.saveMoment()
    ↓
    ├─ If online: Supabase persists → onMomentSaved() → MomentsListView refreshes from network
    └─ If offline: Network error → SyncManager.markMomentAsPending() → Saves to LocalStorageManager
                        ↓
                   MomentsListView tries network, fails
                        ↓
                   Loads from LocalStorageManager.getAllLocalMoments()
                        ↓
                   Shows offline indicator + moments list
                        ↓
                   SyncManager monitors for connectivity
                        ↓
                   When online: Auto-syncs pending moments to Supabase
```

---

## Files Modified This Session

1. `SupabaseAPIClient.swift` — Fixed Supabase persistence
2. `MomentsListView.swift` — Added offline support

## Commits Made
- TBD (user will commit when ready)

---

Last updated: March 9, 2026, Afternoon (T-009 Complete)

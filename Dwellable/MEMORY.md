# MEMORY — Session Log

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

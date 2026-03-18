# Dwellable Native — Manual Testing Checklist

**Test on:** Physical iPhone + Simulator
**Duration:** ~2–3 hours to complete all scenarios
**Device:** iPhone 16 Pro (or similar) running iOS 18+
**Date tested:** _______________

---

## How to use this file

1. Test each scenario and mark the **Status** column: `Pass`, `Fail`, or `Bug`
2. Use the **Notes / Questions** column freely — questions, concerns, ideas, anything
3. When done, share this file back. I'll read every note and respond to all questions at once.

---

## Phase 1 — Offline Support (5 scenarios)

> **Goal:** Verify moments save locally when network is unavailable

| # | Scenario | Steps | Expected | Status | Notes / Questions |
|---|---|---|---|---|---|
| 1.1 | Create moment offline (voice) | 1. Disable WiFi & cellular 2. Open app 3. Tap mic, record "Test moment" 4. Tap Save | Moment saved, "pending sync" message appears, dismisses after 1.5s | ☐ | |
| 1.2 | Create moment offline (text) | 1. Disable WiFi & cellular 2. Open app 3. Tap "Type instead" 4. Enter text, Save | Moment saved locally, "pending sync" message appears | ☐ | |
| 1.3 | Sync queue waits for network | 1. Create moment while offline 2. Wait 30 seconds 3. Enable WiFi | Moment syncs automatically, appears in list (no manual refresh needed) | ☐ | |
| 1.4 | Multiple offline moments sync | 1. Disable WiFi 2. Create 3 moments (mix voice/text) 3. Enable WiFi 4. Wait 10s | All 3 moments appear in list, none duplicated | ☐ | |
| 1.5 | Offline moment persists after restart | 1. Disable WiFi 2. Create moment 3. Force-quit app 4. Relaunch 5. Enable WiFi | Moment still in app, syncs on network restore | ☐ | |

---

## Phase 2 — Authentication (6 scenarios)

> **Goal:** Verify login, logout, and session persistence work correctly

| # | Scenario | Steps | Expected | Status | Notes / Questions |
|---|---|---|---|---|---|
| 2.1 | Valid login | 1. Open LoginView 2. Enter: `test@example.com` / `password123` 3. Tap Login | App shows MomentsListView, displays user's moments | ☐ | |
| 2.2 | Invalid email | 1. LoginView 2. Enter: `invalid` / `password123` 3. Tap Login | Error message: "Invalid request" displayed, still on LoginView | ☐ | |
| 2.3 | Invalid password | 1. LoginView 2. Enter: `test@example.com` / `wrongpassword` 3. Tap Login | Error message displayed (from Supabase), still on LoginView | ☐ | |
| 2.4 | Session persists on restart | 1. Log in 2. Go to MomentsListView 3. Kill app 4. Relaunch | Still logged in, MomentsListView displays (no LoginView) | ☐ | |
| 2.5 | Logout clears session | 1. Log in 2. Tap sign out button 3. Confirm logout | LoginView appears, token removed from Keychain | ☐ | |
| 2.6 | Empty fields validation | 1. LoginView 2. Leave email/password empty 3. Tap Login | Error message, login rejected | ☐ | |

---

## Phase 3 — Moment CRUD Operations (5 scenarios)

> **Goal:** Verify create, read, update (implicit), delete operations

| # | Scenario | Steps | Expected | Status | Notes / Questions |
|---|---|---|---|---|---|
| 3.1 | Create moment with voice | 1. MomentsListView 2. Tap mic 3. Record voice 4. Review & Save | Moment appears at top of list with transcript + timestamp | ☐ | |
| 3.2 | Create moment with text | 1. MomentsListView 2. Tap "Type instead" 3. Enter text 4. Save | Moment appears at top of list with text + timestamp | ☐ | |
| 3.3 | Add "Sense of Lord" field | 1. Create moment 2. On ReviewView, tap "Add where you sensed..." 3. Enter text 4. Save | Moment saved with senseOfLord field visible in detail view | ☐ | |
| 3.4 | Fetch moments list | 1. Log in 2. MomentsListView displays 3. Scroll through list | All moments load, sorted by date (newest first) | ☐ | |
| 3.5 | View moment detail | 1. MomentsListView 2. Tap any moment 3. See detail view | Full body text displayed, date + senseOfLord (if present) visible | ☐ | |

---

## Phase 4 — Network State Changes (6 scenarios)

> **Goal:** Verify app behaves correctly when network changes mid-operation

| # | Scenario | Steps | Expected | Status | Notes / Questions |
|---|---|---|---|---|---|
| 4.1 | Network fails during save | 1. Start typing moment 2. Disable WiFi/cellular mid-typing 3. Tap Save | Error shown, moment saved locally, "pending sync" message | ☐ | |
| 4.2 | Network restored during sync | 1. Create moment offline 2. Enable WiFi 3. Watch sync status | Moment syncs automatically, no manual action needed | ☐ | |
| 4.3 | Toggle airplane mode | 1. Create moment 2. Enable airplane mode 3. Disable 4. Wait 10s | Moment stays in app, syncs when plane mode off | ☐ | |
| 4.4 | Fetch fails, shows cached data | 1. Log in 2. Create + save moment 3. Disable WiFi 4. Restart app | App shows previously cached moments (no error) | ☐ | |
| 4.5 | Retry on network restore | 1. Create moment while offline 2. Network unavailable 10+ seconds 3. Enable WiFi | Auto-retry fires, moment syncs (no manual button needed) | ☐ | |
| 4.6 | Error state shows retry button | 1. Create moment during network failure 2. See error state on ReviewView | "Retry" button visible and functional | ☐ | |

---

## Phase 5 — Data Persistence (6 scenarios)

> **Goal:** Verify data persists correctly across sessions and network states

| # | Scenario | Steps | Expected | Status | Notes / Questions |
|---|---|---|---|---|---|
| 5.1 | Moments persist after crash | 1. Create 2 moments 2. Force-quit app 3. Relaunch | Both moments still visible, no data loss | ☐ | |
| 5.2 | Pending sync queue survives restart | 1. Create moment offline 2. Kill app (before sync) 3. Relaunch 4. Enable WiFi | Moment still marked pending, syncs on restart | ☐ | |
| 5.3 | Keychain stores auth token | 1. Log in 2. Check system Keychain (Settings > Passwords) | Token entry visible in Keychain | ☐ | |
| 5.4 | Logout removes Keychain token | 1. Log in 2. Logout 3. Check Keychain | Token no longer present in Keychain | ☐ | |
| 5.5 | UserDefaults stores pending moments | 1. Disable WiFi 2. Create moment 3. Check UserDefaults data | Moment JSON stored in `pending_moments` key | ☐ | |
| 5.6 | Synced moments stored locally | 1. Create moment online 2. Fetch moments 3. Go offline | Previously fetched moments still visible (cached) | ☐ | |

---

## Phase 6 — Error Handling (4 scenarios)

> **Goal:** Verify app handles errors gracefully without crashing

| # | Scenario | Steps | Expected | Status | Notes / Questions |
|---|---|---|---|---|---|
| 6.1 | Invalid JSON response | (Simulator only) Set MockAPIClient to return bad JSON | Caught as APIError, user sees friendly message | ☐ | |
| 6.2 | Server error (500) | (Test against real Supabase 500) | Error message shown, retry button available | ☐ | |
| 6.3 | Not found error (404) | Try to fetch non-existent moment | Handled gracefully, empty state or error message | ☐ | |
| 6.4 | No microphone permission | 1. Deny microphone access in settings 2. Tap mic button | Error message: "Microphone access required" | ☐ | |

---

## Phase 7 — Performance (3 scenarios)

> **Goal:** Verify app performance remains acceptable under load

| # | Scenario | Steps | Expected | Status | Notes / Questions |
|---|---|---|---|---|---|
| 7.1 | List scrolls smoothly with 50+ moments | 1. Create or fetch 50+ moments 2. Scroll list quickly | No stuttering, 60fps maintained | ☐ | |
| 7.2 | Memory usage stable after long session | 1. Create 10 moments 2. Fetch 100 times 3. Monitor memory | No memory leaks, usage stable < 150MB | ☐ | |
| 7.3 | Sync queue handles rapid offline saves | 1. Disable WiFi 2. Quickly tap save 5 times 3. Enable WiFi | All 5 moments queue and sync without duplication | ☐ | |

---

## Phase 8 — UI/UX (5 scenarios)

> **Goal:** Verify interface is responsive and intuitive

| # | Scenario | Steps | Expected | Status | Notes / Questions |
|---|---|---|---|---|---|
| 8.1 | Loading spinner appears during fetch | 1. On MomentsListView, pull-to-refresh (if implemented) | Spinner visible, disappears when done | ☐ | |
| 8.2 | Buttons disabled during save | 1. ReviewView 2. Tap Save 3. While saving, try tapping again | Button disabled, no double-submit | ☐ | |
| 8.3 | Error messages dismiss automatically | 1. Trigger error on LoginView 2. Wait 5s | Error message disappears or requires manual dismiss | ☐ | |
| 8.4 | Keyboard appears/dismisses smoothly | 1. TypeFlowView 2. Tap text field 3. Type 4. Tap Save | Keyboard animates smoothly, no jumping | ☐ | |
| 8.5 | Dark mode renders correctly | 1. Enable dark mode in system settings 2. Relaunch Dwellable | Colors/contrast correct, text readable | ☐ | |

---

## Phase 9 — Bug Fix Verification (3 scenarios)

> **Goal:** Verify that the three critical bugs fixed in this session work correctly

| # | Scenario | Steps | Expected | Status | Notes / Questions |
|---|---|---|---|---|---|
| 9.1 | Build completes with zero warnings (B-003 fix) | 1. In Xcode, clean build folder (Cmd+Shift+K) 2. Build project (Cmd+B) 3. Check build log for warnings | Build succeeds with **zero warnings** (previously had duplicate ID warnings in TranscribingView and CaptureView) | ☐ | |
| 9.2 | Login error message displays (B-007 fix) | 1. Open LoginView 2. Enter `test@example.com` 3. Enter wrong password: `wrongpassword` 4. Tap Login | Error message displays: **"Email or password is incorrect"** (stays on LoginView, does not proceed to MomentsListView). Valid test accounts: `test@example.com` / `password123` or `kell@example.com` / `test1234` | ☐ | |
| 9.3 | Offline moments persist during online workflow (B-008 fix) | 1. Log in (online) 2. Create 1 moment and save (appears in list) 3. Disable WiFi 4. Create 2 more moments offline 5. Enable WiFi 6. Wait 10s for sync | All 3 moments remain visible in MomentsListView (newly created offline moments don't disappear when going back online) | ☐ | |

---

## Quick Test Path (30 minutes)

If you're in a rush, test **these scenarios first:**

| Phase | Scenario |
|---|---|
| 1 (Offline) | 1.1, 1.3 |
| 2 (Auth) | 2.1, 2.4 |
| 3 (CRUD) | 3.1, 3.4 |
| 4 (Network) | 4.1, 4.2 |
| 5 (Persistence) | 5.1, 5.3 |
| 6 (Errors) | 6.4 |
| 7 (Performance) | 7.1 |
| 8 (UI/UX) | 8.1, 8.5 |

---

## Recording Results

For each scenario, mark Status as:
- `Pass` — Behavior matches expected
- `Fail` — Unexpected behavior or crash
- `Bug` — Document details in Notes column

**For failures, include in Notes:**
- What actually happened
- Device and network state
- Screenshot if possible

---

---

## Phase 10 — Audio Edge Cases & Recording Validation (7 scenarios)

> **Goal:** Verify audio transcription validation properly rejects blank/short recordings and stores audio URLs correctly

| # | Scenario | Steps | Expected | Status | Notes / Questions |
|---|---|---|---|---|---|
| 10.1 | Pure silence rejected (blank audio) | 1. MomentsListView 2. Tap mic 3. Record 2-3 seconds of pure silence 4. Tap Stop | Error message shown: **"Dwellable didn't catch that. Feel free to speak again."** No moment created. Log shows: `[WARNING] WhisperKit: rejected — blank audio` | ☐ | |
| 10.2 | Very short speech rejected (1-2 words) | 1. MomentsListView 2. Tap mic 3. Record 1-2 words quickly ("Hello") 4. Tap Stop | Error message shown. No moment saved. Log shows: `[WARNING] WhisperKit: rejected — too short (1 word)` | ☐ | |
| 10.3 | Normal speech accepted (3+ words) | 1. MomentsListView 2. Tap mic 3. Record normal sentence: "Hello, this is a test moment" 4. Tap Stop 5. Save | ReviewView displays full transcript. Moment saves successfully. Appears in MomentsListView. | ☐ | |
| 10.4 | Audio URL stored in database | 1. Create moment with voice (3+ words) 2. Save 3. Open Supabase dashboard → moments table | `audio_url` column shows file path (format: `{userId}/{filename}.m4a`). Example: `43601b86-a80e-4e60-83b9-d22cb0723b5f/moment_ABC123.m4a` | ☐ | |
| 10.5 | Audio file accessible via Edge Function | 1. Create moment with voice 2. View moment detail 3. Tap "Listen to Audio" button | Audio plays via Edge Function. No 404 errors. File serves securely (user must own it). | ☐ | |
| 10.6 | Retry after blank audio rejection | 1. Record silence → see error 2. Tap "Retry Transcription" 3. Record valid speech ("Testing now") 4. Save | Error clears. New transcript shows. Moment saves successfully. No "[BLANK_AUDIO]" text appears. | ☐ | |
| 10.7 | Database contains no blank moments | 1. Complete scenarios 10.1–10.3 2. Open Supabase dashboard → moments table 3. Check most recent moments | No moments with body = `"[BLANK_AUDIO]"` or single-word bodies. All moments have 3+ word transcriptions. | ☐ | |

---

## Phase 11 — Backend Integration (4 scenarios)

> **Goal:** Verify the three critical fixes from this session work end-to-end

| # | Scenario | Steps | Expected | Status | Notes / Questions |
|---|---|---|---|---|---|
| 11.1 | Issue #1: Audio URL storage working | 1. Create moment with voice 2. Check Supabase moments table 3. Verify `audio_url` column populated | File path visible in database (not null/empty). File exists in Storage bucket. Format: `{userId}/{filename}.m4a` | ☐ | |
| 11.2 | Issue #2: Usage events syncing | 1. Open app 2. Check device logs for sync confirmation 3. Open Supabase → usage_events table | Event syncs automatically. Log shows: `✅ Usage events synced to backend successfully (N events)`. Supabase table has entries with user_id + timestamps. | ☐ | |
| 11.3 | Issue #3: Blank audio validation end-to-end | 1. Record silence → error shown 2. Record 1-2 words → error shown 3. Record valid speech → saves 4. Check database | No blank moments in database. Only valid moments (3+ words) saved. Validation catches bad audio BEFORE upload. | ☐ | |
| 11.4 | No audio uploaded for rejected transcriptions | 1. Record silence → see rejection 2. Check Supabase Storage bucket 3. Look for orphaned audio files from failed recordings | No audio files in Storage from rejected recordings. Upload is skipped when transcription rejected. Keeps Storage clean. | ☐ | |

---

## Phase 12 — Audio Recording Duration (5 scenarios)

> **Goal:** Verify audio capture works correctly across different recording lengths

| # | Scenario | Steps | Expected | Status | Notes / Questions |
|---|---|---|---|---|---|
| 12.1 | Short recording (5 seconds) | 1. MomentsListView 2. Tap mic 3. Record for ~5 seconds ("This is a short test") 4. Stop & Save | Full text captured. Moment saved. No truncation. | ☐ | |
| 12.2 | Medium recording (1-2 minutes) | 1. Record for ~1-2 minutes (read a paragraph or list items) 2. Stop & Save | Full transcript captured. No gaps or dropouts. Quality good. | ☐ | |
| 12.3 | Long recording (5 minutes) | 1. Record for ~5 minutes (sustained speech, normal conversation) 2. Stop & Save | Complete transcript with no loss. Transcription time reasonable (~10-15s). | ☐ | |
| 12.4 | Extended recording (10 minutes) | 1. Record full 10-minute duration (will hit auto-stop at 10:00) 2. ReviewView should open with full transcript | Full 10-minute audio transcribed. No truncation at time limit. Transcript complete. | ☐ | |
| 12.5 | Multiple long sessions (3x 10-min recordings) | 1. Record 10-minute session, save 2. Wait 5 seconds 3. Record another 10-minute, save 4. Repeat once more (3 total) | All 3 moments saved successfully. No database or upload conflicts. Timestamps differ correctly. | ☐ | |

---

## Phase 13 — Recording Environment & Network Variations (6 scenarios)

> **Goal:** Verify audio capture quality and sync work correctly in different environments and network conditions

| # | Scenario | Steps | Expected | Status | Notes / Questions |
|---|---|---|---|---|---|
| 13.1 | Quiet environment | 1. Record in silent room (office, home, quiet space) 2. Normal speech volume 3. Save | Clear transcript, no ambient noise artifacts. Moment saves cleanly. | ☐ | |
| 13.2 | Moderate background noise | 1. Record with TV/music playing softly in background 2. Speak clearly, normal volume 3. Save | Transcript captures speech clearly, minimizes background noise. Readable and saveable. | ☐ | |
| 13.3 | Long recording on WiFi | 1. Connected to WiFi 2. Record 10-minute moment 3. Transcribe & Save | No interruptions. Fast sync to Supabase. Audio URL stored correctly. | ☐ | |
| 13.4 | Long recording online (cellular) | 1. On cellular data 2. Record 10-minute moment 3. Transcribe & Save | Transcription happens locally (offline-first). Syncs when complete. No disconnects. | ☐ | |
| 13.5 | Network change mid-transcription | 1. Record 5-minute moment online 2. Immediately disable WiFi mid-transcription 3. Let transcription complete | WhisperKit completes transcription (offline). Moment saves when trying to sync. No errors. | ☐ | |
| 13.6 | Battery drain during long recording | 1. Plug in device or check battery % 2. Record full 10-minute session 3. Check battery after | Battery usage reasonable (<5% for 10-min recording + transcription). No excessive heat. | ☐ | |

---

## Phase 14 — Recording Duration Reference Transcripts

> **Goal:** Compare actual transcripts from device testing to verify accuracy across different recording lengths

**Before testing:** Record reference audio clips at each duration level and document expected transcript for comparison.

| Duration | Reference Transcript | Device Transcript | Match | Notes |
|----------|-------------------|------------------|-------|-------|
| 5 seconds | "This is a short test" | | ☐ | |
| 1 minute | [Prepared 1-min speech, 100+ words] | | ☐ | Compare word count & accuracy |
| 5 minutes | [Prepared 5-min speech, 500+ words] | | ☐ | Check for truncation or gaps |
| 10 minutes | [Prepared 10-min speech, 1000+ words] | | ☐ | Full capture before auto-stop? |
| 10min Session 1 | [First 10-min recording] | | ☐ | Consistent quality vs. previous? |
| 10min Session 2 | [Second 10-min recording] | | ☐ | Any performance degradation? |
| 10min Session 3 | [Third 10-min recording] | | ☐ | Sustained performance over time? |

**How to use this section:**
1. Before testing, prepare reference audio (or use prepared scripts)
2. For each duration, record and transcribe on device
3. Copy the transcript from ReviewView into "Device Transcript" column
4. Compare word-for-word with reference — mark "Match" ☐ if 95%+ accurate
5. Note any issues: truncation, quality loss, timing problems, etc.

---

## After Testing

1. Share this file back — I'll read every Status + Note and respond to all questions
2. I'll create BUG tickets for any failures
3. I'll answer every question in the Notes columns

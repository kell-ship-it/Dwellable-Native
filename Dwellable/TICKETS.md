# Dwellable Native — Full Ticket Registry

**Last Updated:** March 7, 2026, 8:15 PM
**Convention:** This file tracks ALL tickets — completed and open — for the full initiative.

---

## ✅ Completed

### UI Screens — Main (6 screens)
- [x] **S-001:** Build LoginView
  - Dark theme, email/password fields, gold CTA button, wordmark

- [x] **S-002:** Build MomentsListView
  - Moments list with MomentRow, date header, chevron, divider separators
  - Empty state with centered prompt
  - 10 hardcoded sample moments (placeholder until backend ships)

- [x] **S-003:** Build CaptureView
  - Voice-first layout, centered mic button
  - "Type instead" pill navigation to TypeFlowView
  - TranscribingView overlay (UI only)

- [x] **S-004:** Build ReviewView
  - Voice review mode: pre-filled transcript, Re-record + Save footer
  - "Add where you sensed the Lord" hint field

- [x] **S-005:** Build TypeFlowView
  - Full-screen text entry, "Begin here..." placeholder
  - Save moment CTA

- [x] **S-006:** Build MomentDetailView
  - Full moment body with date header
  - "Sense of Lord" section with divider (conditional)

### Voice — UI Only
- [x] **S-007:** Build TranscribingView (UI)
  - 5 animated bars with staggered heights
  - Animated dot indicator, "Transcribing" label
  - UI complete — not wired to real recording state yet

### Voice — Recording & Transcription (Complete)
- [x] **V-001:** Implement microphone recording (AVFoundation)
  - AVAudioRecorder setup, start/stop recording
  - Audio file written to temp storage

- [x] **V-002:** Request microphone permission
  - `NSMicrophoneUsageDescription` in Info.plist
  - Runtime permission request, handle denial gracefully

- [x] **V-003:** Wire CaptureView mic button to recording
  - Tap to start/stop recording
  - Audio URL passed to ReviewView

- [x] **V-004:** Choose and integrate transcription service
  - Apple Speech Framework (offline, privacy-first, no API keys)
  - SFSpeechURLRecognitionRequest for audio file transcription
  - Error handling and permission requesting

- [x] **V-005:** Wire transcription output to ReviewView
  - TranscriptionManager integrated into ReviewView
  - Auto-transcribe on .onAppear when audioURL provided
  - Pre-fill momentBody with transcript on completion
  - Loading state and error display

- [x] **V-006:** Wire TranscribingView to real transcription state
  - Show overlay while request is in flight
  - Dismiss on completion or error

- [x] **V-007:** Handle transcription errors and edge cases
  - Empty transcript detection with user-friendly message
  - Enhanced error mapping for network, timeout, and permission failures
  - Timeout safety net (60-second limit) prevents infinite transcription attempts
  - Retry button in ReviewView for failed transcriptions
  - Better error messaging with visual feedback (error box + retry option)

- [x] **V-008:** Add recording duration timer UI
  - Live duration display in MM:SS format during recording
  - Timer starts at 0:00 and counts up in 0.1s increments
  - Monospaced gold-colored font for visual distinction
  - Automatic stop at 10-minute max duration with user notification
  - Timer properly cleaned up on recording stop

### Data Persistence (Complete)
- [x] **T-006:** Network error handling
  - Graceful offline support: moments saved locally when network fails
  - LocalStorageManager for persistent in-device storage
  - SyncManager monitors connectivity and auto-retries failed saves
  - User-friendly UI (1.5s "pending sync" delay before dismissal)
  - Retry logic with periodic 10-second sync attempts
  - Full offline-first architecture with transparent sync

### API Client Architecture & Authentication (Complete)
- [x] **API Client Architecture (Frontend-Ready)**
  - APIClient protocol defining endpoints (fetch moments, save, auth)
  - MockAPIClient with full mock implementation and 0.2-0.5s simulated delays
  - ReviewView and TypeFlowView save buttons wired to apiClient.saveMoment()
  - MomentsListView fetch moments from API on .onAppear
  - AppView instantiates MockAPIClient and passes to all views

- [x] **T-003:** Wire up authentication to backend
  - Created KeychainManager for secure token storage (iOS Keychain APIs)
  - Updated AuthManager to accept apiClient: APIClient in init
  - LoginView email/password fields now call apiClient.login() (not stub)
  - Auth token stored securely in Keychain, userId extracted from response
  - AuthManager checks for existing token on init via Keychain
  - DwellableApp instantiates MockAPIClient and passes to AuthManager
  - AppView conditionally shows LoginView or AppView based on isAuthenticated
  - Sign out button calls apiClient.logout() and clears Keychain
  - All previews updated to pass apiClient parameter
  - User session persists across app launches via Keychain

### Data Persistence
- [x] **T-004:** Replace hardcoded moments with API calls
  - Removed sample data from MomentsListView init — no longer hardcoded array
  - Fetch moments from API on .onAppear using authenticated userId
  - Added loading state (spinner) while fetching
  - Added error state with user-friendly message and retry button
  - Empty state displays when user has no moments
  - Moments properly sorted by createdAt (descending) from API
  - Data consistency: single MockAPIClient instance, save/fetch work seamlessly
  - **Pagination deferred:** MockAPIClient returns all moments; real backend will implement cursor-based pagination

- [x] **T-005:** Implement save functionality
  - ReviewView: save button wired to apiClient.saveMoment(), includes loading/error states, dismisses on success
  - TypeFlowView: save button wired to apiClient.saveMoment(), includes loading/error states, dismisses on success
  - Both views validate that moment body is not empty before saving
  - Both views extract senseOfLord field if provided, include userId from authenticated user
  - Error display with dismiss button, retry attempts work seamlessly
  - Loading spinner shows during save operation, button disabled while saving
  - Both views pass apiClient and userId as parameters from parent (CaptureView)

### Bugs (Complete)
- [x] **B-001:** Fix post-save navigation (ReviewView/TypeFlowView → MomentsListView)
  - Child views now dismiss themselves immediately after calling onMomentSaved() callback
  - Eliminates race condition that caused navigation to bounce through CaptureView
  - Solution: ReviewView, TypeFlowView call dismiss() in success/error paths
  - CaptureView simplified: removed momentWasSaved state and onChange logic
  - Navigation flow now direct: Save → Child dismisses → Parent dismisses → MomentsListView

### Backend Integration (Complete)
- [x] **T-001:** Set up backend API
  - Created Supabase project (lhcjobrtmbawlhjyodxz) with PostgreSQL backend
  - Set up users table (id, email, created_at, updated_at) with indexes
  - Set up moments table (id, user_id, body, created_at, updated_at) with foreign key to users
  - Created appropriate indexes for query performance
  - Obtained Supabase publishable API key (sb_publishable_...)
  - Integrated with GitHub via Supabase org

- [x] **T-002:** Define API endpoints
  - Created SupabaseAPIClient implementing APIClient protocol
  - `POST /rest/v1/moments` — Create moment (requires user_id, body, created_at)
  - `GET /rest/v1/moments?user_id=eq.{userId}&order=created_at.desc` — Fetch user's moments
  - `GET /rest/v1/moments?id=eq.{id}` — Fetch single moment
  - `DELETE /rest/v1/moments?id=eq.{id}` — Delete moment
  - `POST /auth/v1/token?grant_type=password` — Login with email/password
  - Bearer token authentication with Authorization header
  - JSON encoding/decoding with ISO8601 date formatting
  - Comprehensive error handling (404, 400-499, 500+)

---

## 🔄 In Progress
(None)

---

## 🔲 Not Started

---

### File Organization / Technical Debt
- [ ] **T-007:** Refactor embedded views to separate files
  - Move `TypeFlowView`, `MomentDetailView`, `TranscribingView`, `MomentRow` to own files

- [ ] **T-008:** Fix Xcode build target configuration
  - Ensure new Swift files auto-added to build target

- [ ] **T-009:** Centralize theme and styling
  - Extract all hardcoded colors and fonts to `Theme.swift`
  - Create reusable button and text styles

### UI Screens — Sub-screens
- [ ] **T-010:** Build SettingsView
  - User profile display, sign out, app version, terms/privacy links
  - Accessible from MomentsListView header

- [ ] **T-011:** Build EditMomentView *(deferred — v2)*
  - Edit existing moments, pre-populate data, delete with confirmation

- [ ] **T-012:** Build SearchView *(deferred — v2)*
  - Search by text, filter by date range, filter by sense of Lord

- [ ] **T-013:** Build ArchiveView / CollectionsView *(deferred — v2)*
  - Organize moments into collections, archive old moments

### Analytics & Observability
- [ ] **T-018:** Add basic analytics
  - Track screen views, moment creation (voice vs type), save success/failure
  - Privacy-conscious — minimize data collection

- [ ] **T-019:** Add error logging
  - Log auth failures, API errors, transcription errors with context

### Testing & QA
- [ ] **T-020:** Set up XCUI test target for automated UI testing
  - Create XCUITest target in Xcode project
  - Wire up test helper methods for login, moment creation, navigation
  - Set up test fixtures (mock data, test user account)
  - Write initial test cases for key workflows (see details in XCUI_TESTS.md)
  - Verify tests run on both simulator and physical device

- [ ] **T-021:** Unit tests for AuthManager
- [ ] **T-022:** Unit tests for StorageManager
- [ ] **T-023:** Unit tests for SyncManager
- [ ] **T-024:** Manual testing on real device
- [ ] **T-025:** TestFlight beta testing with users

### Deployment
- [ ] **T-026:** Prepare for App Store submission
  - Privacy policy, terms of service, screenshots, description, pricing

- [ ] **T-027:** Configure production environment *(deferred — v2)*
  - Production backend, Supabase project, CI/CD pipeline

- [ ] **T-028:** Create user onboarding flow *(deferred — v2)*
  - Welcome screen, permission explanations, quick tutorial

---

## 📊 Priority Summary

### 🔴 BLOCKING — Nothing ships without these
(All complete: T-001 · T-002 · T-003 · T-004 · T-005 · T-006 · API Client Architecture)

### 🟡 HIGH — Required before v1.0
V-001 · V-002 · V-003 · V-004 · V-005 · V-006 · T-007 · T-020 · T-026

### 🟢 MEDIUM — v1.1 quality improvements
V-007 · V-008 · T-008 · T-009 · T-010 · T-018 · T-019 · T-021 · T-022 · T-023 · T-024 · T-025

### ⚪ LOW — v2.0 and beyond
T-011 · T-012 · T-013 · T-027 · T-028

---

## 📈 Progress

| Category | Total | ✅ Done | 🔄 In Progress | 🔲 Not Started |
|---|---|---|---|---|
| UI Screens — Main | 7 | 7 | 0 | 0 |
| Voice Features | 8 | 8 | 0 | 0 |
| API & Auth | 2 | 2 | 0 | 0 |
| Backend Integration | 2 | 2 | 0 | 0 |
| Data Persistence | 3 | 3 | 0 | 0 |
| File Organization | 3 | 0 | 0 | 3 |
| UI Screens — Sub | 4 | 0 | 0 | 4 |
| Analytics | 2 | 0 | 0 | 2 |
| Testing & QA | 5 | 0 | 0 | 5 |
| Deployment | 3 | 0 | 0 | 3 |
| Bugs | 1 | 1 | 0 | 0 |
| **TOTAL** | **40** | **23** | **0** | **17** |

---

## 📝 Notes

- **Save/fetch fully functional end-to-end:** Create moment (voice/text) → save to Supabase → fetch in list
- **Supabase backend live:** PostgreSQL with REST API, JWT auth, users + moments tables
- Moments fetched per authenticated user, all data synced through single SupabaseAPIClient instance
- **Offline-first architecture complete:** Full local persistence with LocalStorageManager + auto-sync with SyncManager
- Pagination deferred (will implement with real backend when needed)
- All voice features (V-001–V-008) complete and functional
- **Next session priorities:** T-020 (XCUI test setup — HIGH), T-007 (refactor embedded views — HIGH), T-009 (centralize theme/styling — MEDIUM)
- User activity tracking in separate USER_ACTIVITIES.md + MANUAL_TESTING_CHECKLIST.md
- `NSMicrophoneUsageDescription` must be added to Info.plist before App Store submission

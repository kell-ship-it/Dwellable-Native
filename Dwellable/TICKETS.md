# Dwellable Native — Full Ticket Registry

**Last Updated:** March 7, 2026
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

---

## 🔄 In Progress

### Voice Features
- [ ] **V-001:** Implement microphone recording (AVFoundation)
  - AVAudioRecorder setup, start/stop recording
  - Audio file written to temp storage

- [ ] **V-002:** Request microphone permission
  - `NSMicrophoneUsageDescription` in Info.plist
  - Runtime permission request, handle denial gracefully

- [ ] **V-003:** Wire CaptureView mic button to recording
  - Tap to start/stop recording
  - Pass audio file forward to transcription step

---

## 🔲 Not Started

### Voice Features (remaining)
- [ ] **V-004:** Choose and integrate transcription service
  - Evaluate: OpenAI Whisper vs Apple Speech framework vs Google Cloud
  - Implement chosen service, handle API key securely

- [ ] **V-005:** Wire transcription output to ReviewView
  - Pass transcribed text as parameter
  - Pre-fill TextEditor in ReviewView on arrival

- [ ] **V-006:** Wire TranscribingView to real transcription state
  - Show overlay while request is in flight
  - Dismiss on completion or error

- [ ] **V-007:** Handle transcription errors and edge cases
  - Empty transcript, network failure, timeout, mic denied mid-session

- [ ] **V-008:** Add recording duration timer UI
  - Display live duration during recording
  - Stop at max length (TBD)

---

### Backend Integration
- [ ] **T-001:** Set up backend API
  - Define API server structure, database models, `.env` configuration

- [ ] **T-002:** Define API endpoints
  - `POST /moments`, `GET /moments`, `GET /moments/:id`
  - `DELETE /moments/:id`, `POST /auth/login`, `POST /auth/logout`

- [ ] **T-003:** Wire up authentication to backend
  - Connect LoginView to backend auth endpoint
  - Replace stub auth with real API calls
  - Store auth token in Keychain, handle session expiry

### Data Persistence
- [ ] **T-004:** Replace hardcoded moments with API calls
  - Remove sample data from MomentsListView
  - Fetch on app launch, implement pagination, add loading states

- [ ] **T-005:** Implement save functionality
  - Wire ReviewView and TypeFlowView save buttons to `POST /moments`
  - Add loading indicator, handle success/error

- [ ] **T-006:** Network error handling
  - Graceful offline support, retry logic, user-friendly error messages

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
- [ ] **T-020:** Unit tests for AuthManager
- [ ] **T-021:** Unit tests for StorageManager
- [ ] **T-022:** Unit tests for SyncManager
- [ ] **T-023:** Manual testing on real device
- [ ] **T-024:** TestFlight beta testing with users

### Deployment
- [ ] **T-025:** Prepare for App Store submission
  - Privacy policy, terms of service, screenshots, description, pricing

- [ ] **T-026:** Configure production environment *(deferred — v2)*
  - Production backend, Supabase project, CI/CD pipeline

- [ ] **T-027:** Create user onboarding flow *(deferred — v2)*
  - Welcome screen, permission explanations, quick tutorial

---

## 📊 Priority Summary

### 🔴 BLOCKING — Nothing ships without these
T-001 · T-002 · T-003 · T-004 · T-005

### 🟡 HIGH — Required before v1.0
V-001 · V-002 · V-003 · V-004 · V-005 · V-006 · T-006 · T-007 · T-025

### 🟢 MEDIUM — v1.1 quality improvements
V-007 · V-008 · T-008 · T-009 · T-010 · T-018 · T-019 · T-020 · T-021 · T-022 · T-023 · T-024

### ⚪ LOW — v2.0 and beyond
T-011 · T-012 · T-013 · T-026 · T-027

---

## 📈 Progress

| Category | Total | ✅ Done | 🔄 In Progress | 🔲 Not Started |
|---|---|---|---|---|
| UI Screens — Main | 7 | 7 | 0 | 0 |
| Voice Features | 8 | 0 | 3 | 5 |
| Backend Integration | 3 | 0 | 0 | 3 |
| Data Persistence | 3 | 0 | 0 | 3 |
| File Organization | 3 | 0 | 0 | 3 |
| UI Screens — Sub | 4 | 0 | 0 | 4 |
| Analytics | 2 | 0 | 0 | 2 |
| Testing & QA | 5 | 0 | 0 | 5 |
| Deployment | 3 | 0 | 0 | 3 |
| **TOTAL** | **40** | **7** | **3** | **30** |

---

## 📝 Notes

- All save buttons are stubs (no-op) until T-005 ships
- Authentication is UI-only until T-003 ships
- 10 hardcoded sample moments until T-004 ships
- Voice mic button is non-functional until V-001–V-003 ship
- `NSMicrophoneUsageDescription` must be added to Info.plist before App Store submission

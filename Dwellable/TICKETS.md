# Dwellable Native — Remaining Work

**Last Updated:** March 4, 2026
**Status:** Major UI milestone complete; backend integration next

---

## 🎯 Core Feature Work

### Backend Integration
- [ ] **T-001:** Set up backend API (Node/Express or similar)
  - Define API server structure
  - Set up database models
  - Create `.env` configuration for API endpoints

- [ ] **T-002:** Define API endpoints
  - `POST /moments` — Create a new moment
  - `GET /moments` — Fetch all moments for authenticated user
  - `GET /moments/:id` — Fetch single moment
  - `PATCH /moments/:id` — Update moment (future)
  - `DELETE /moments/:id` — Delete moment (future)
  - `POST /auth/login` — User authentication
  - `POST /auth/logout` — Session termination

- [ ] **T-003:** Wire up authentication to backend
  - Connect LoginView to backend auth endpoint
  - Replace stub authentication with real API calls
  - Store auth token securely (Keychain)
  - Handle session expiry and refresh

### Data Persistence
- [ ] **T-004:** Replace hardcoded moments with API calls
  - Remove sample data from MomentsListView
  - Fetch moments from backend on app launch
  - Implement pagination/lazy loading for large lists
  - Add loading states and error handling

- [ ] **T-005:** Implement save functionality
  - Wire ReviewView "Save" button to POST /moments endpoint
  - Wire TypeFlowView "Save moment" button to POST /moments endpoint
  - Add loading indicator during save
  - Handle success/error responses

- [ ] **T-006:** Network error handling
  - Add graceful offline support (queue moments for sync)
  - Implement retry logic with exponential backoff
  - Display user-friendly error messages
  - Handle 409 conflicts (duplicate moments)

### File Organization / Technical Debt
- [ ] **T-007:** Refactor embedded views to separate files
  - Move `TypeFlowView` from CaptureView.swift to `TypeFlowView.swift`
  - Move `MomentDetailView` from MomentsListView.swift to `MomentDetailView.swift`
  - Move `TranscribingView` to separate file
  - Move `MomentRow` to separate file (reusable component)

- [ ] **T-008:** Fix Xcode build target configuration
  - Ensure all new Swift files are added to build target automatically
  - Review and optimize build settings
  - Clean up derived data

- [ ] **T-009:** Centralize theme and styling
  - Extract all hardcoded colors to Theme.swift
  - Extract all hardcoded font sizes to Theme.swift
  - Create reusable button styles
  - Create reusable text styles

---

## 🎨 Remaining UI Screens (Sub-screens)

### Settings/Profile Screen
- [ ] **T-010:** Build SettingsView
  - User profile display (email, account info)
  - Sign out button (wire to AuthManager)
  - App version display
  - Terms/Privacy links
  - Navigation: accessible from MomentsListView header

### Edit Moment Screen (Future — Low Priority)
- [ ] **T-011:** Build EditMomentView
  - Allow users to edit existing moments
  - Pre-populate with current moment data
  - Save changes to backend
  - Add delete button with confirmation
  - **Status:** User indicated not needed yet; defer until v2

### Search/Filter Screen (Future — Low Priority)
- [ ] **T-012:** Build SearchView
  - Search moments by text content
  - Filter by date range
  - Filter by "sense of Lord" presence
  - **Status:** Defer to v2

### Archive/Collections Screen (Future — Low Priority)
- [ ] **T-013:** Build ArchiveView or CollectionsView
  - Organize moments into collections/tags
  - Archive old moments
  - **Status:** Defer to v2

---

## 🎙️ Voice Features

### Transcription Integration
- [ ] **T-014:** Integrate voice-to-text transcription
  - Choose transcription service (OpenAI Whisper, Google Cloud Speech, etc.)
  - Add microphone recording to CaptureView
  - Implement audio file handling
  - Send audio to transcription API
  - Display transcribed text in ReviewView
  - Add manual editing of transcription

- [ ] **T-015:** Implement audio permission handling
  - Request microphone permission from user
  - Handle permission denial gracefully
  - Display permission request prompt

- [ ] **T-016:** Add recording UI feedback
  - Animate waveform during recording
  - Display recording duration timer
  - Add stop/cancel buttons

- [ ] **T-017:** Implement TranscribingView functionality
  - Already UI-built; add backend integration
  - Show transcription progress
  - Handle transcription errors

---

## 🔄 State Management & Analytics

### User Feedback & Telemetry
- [ ] **T-018:** Add basic analytics
  - Track screen views
  - Track moment creation (voice vs. type)
  - Track save success/failure
  - **Note:** Be privacy-conscious; minimize data collection

- [ ] **T-019:** Add error logging
  - Log authentication failures
  - Log API errors with context
  - Log transcription errors

---

## 📋 Testing & QA

- [ ] **T-020:** Unit tests for AuthManager
- [ ] **T-021:** Unit tests for StorageManager (when created)
- [ ] **T-022:** Unit tests for SyncManager (when created)
- [ ] **T-023:** Manual testing on real device
- [ ] **T-024:** TestFlight beta testing with users

---

## 🚀 Deployment Readiness

- [ ] **T-025:** Prepare for App Store submission
  - Create app privacy policy
  - Create terms of service
  - Prepare app store screenshots
  - Write app store description
  - Set pricing (if paid) or free tier

- [ ] **T-026:** Configure production environment
  - Set up production backend
  - Configure production Supabase project
  - Set up CI/CD pipeline
  - Create release notes

- [ ] **T-027:** Create user onboarding flow
  - Welcome screen
  - Permission explanations
  - Quick tutorial (optional)

---

## 📊 Priority Grouping

### 🔴 **BLOCKING (Ship Blocker)**
- T-001: Backend API setup
- T-002: API endpoints definition
- T-003: Authentication integration
- T-004: Fetch moments from backend
- T-005: Save moment functionality

### 🟡 **HIGH (Before v1.0)**
- T-006: Network error handling
- T-007: Refactor embedded views
- T-014: Transcription integration
- T-015: Audio permissions
- T-025: App Store submission prep

### 🟢 **MEDIUM (v1.1+)**
- T-008: Fix Xcode build config
- T-009: Centralize theming
- T-010: Settings/Profile screen
- T-016: Recording UI feedback
- T-017: TranscribingView integration
- T-018-T-024: Testing & analytics

### ⚪ **LOW (v2.0+)**
- T-011: Edit moment screen
- T-012: Search/filter
- T-013: Archive/collections
- T-026: CI/CD pipeline
- T-027: User onboarding

---

## 🛠️ Current Project State

**Main Branch Status:** ✅ UI complete, no backend integration yet
**Main Screens (6):** LoginView, MomentsListView, CaptureView, ReviewView, TypeFlowView, MomentDetailView
**Sub-screens Remaining (3-4):** SettingsView, EditMomentView, SearchView, ArchiveView
**Tech Stack:** Swift/SwiftUI, Supabase (backend ready), Core Data (local persistence)

**Estimated Work:**
- Backend integration: ~8-10 hours
- Transcription integration: ~6-8 hours
- File organization & refactoring: ~4-6 hours
- Remaining screens: ~4-6 hours (sub-screens are simpler than main screens)
- Testing & polish: ~4-6 hours
- **Total to v1.0 launch:** ~30-40 hours

---

## 📝 Notes

- All sample data (10 moments) currently hardcoded in MomentsListView; will be replaced with backend data in T-004
- Voice recording UI (CaptureView) is built but non-functional; transcription integration in T-014
- All save buttons are stubs (no-op); will be wired in T-005
- Authentication is UI-only; actual login will be implemented in T-003
- App assumes authenticated state; logout will be implemented in T-003

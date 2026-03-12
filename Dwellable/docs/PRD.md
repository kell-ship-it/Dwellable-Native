# Dwellable — Product Spec

**Layer 1 Pilot** | **Founder:** Kell Golden | **Living Document** | **Updated:** March 11, 2026

---

## Purpose

Validate that users will adopt a faith-specific moment capture tool over generic alternatives (Notes, Day One, voice memos).

Layer 1 is not about building a complete product. It is about proving one thing: will people use this to capture their God moments instead of what they're using now?

## Problem Being Solved

Users struggle to easily capture their God moments in a way that feels intentional, low-friction, and faith-appropriate. Generic tools exist but are not designed for this context. Layer 1 builds the minimum viable proof that a dedicated tool creates different behavior.

## Pilot Parameters

- **Duration:** 7-day personal dogfooding (Kell) → QA testing (external beta) → demo prep → App Store submission
- **Phase 1 Users:** 10+ participants across consistent reflectors (Group 1) and selective reflectors (Group 2)
- **Distribution:** iOS via TestFlight
- **Auth:** Pre-provisioned Supabase email accounts (no self-signup)
- **Current Status:** Build 105 deployed to TestFlight; Phase 1 dogfooding in progress

## Success Definition

**Qualitative:** "This is not only easier to capture my God moments — I find myself capturing more of them."

**Quantitative:**
- Number of moments captured per user per week
- Number of moment views (user returns to read past moments)
- Time to first captured moment after onboarding
- Delta in capture frequency week 1 vs week 4
- Session frequency and app open patterns

**Emotional Outcome:** A measurable shift from anxious/uncertain to confident/anchored.

## User Flow (Happy Path)

1. User opens app
2. User lands on Moments list (home screen)
3. User taps "+" CTA at bottom
4. User lands on Capture screen — mic is centered, reflective prompt above
5. User taps mic to start recording their moment
6. User taps mic again to stop → brief "Transcribing..." state → Review screen with transcript pre-filled
7. Optional: User adds where they sensed the Lord (inline hint below body text)
8. User taps "Save" → returns to Moments list
9. Moment appears at top of list

**Alternate path (type instead):**
- From Capture screen, user taps "type instead →" → Review screen (blank, cursor ready)
- User types moment → taps "Save moment" → returns to Moments list

## Features In Scope (Layer 1)

### Core Screens (Built & Live)

**LoginView**
- Email + password login (pre-provisioned accounts)
- Wordmark + subtitle ("Document life. Discern over time.")
- Gold accent button
- Session persistence across app restarts

**CaptureView**
- Voice-first — mic centered on screen with reflective prompt above
- Tap mic to start recording; tap again to stop → auto-transcribes → Review screen
- "type instead →" link navigates to Review screen in type mode (blank canvas)
- Rotating reflective prompts:
  - "Did something meaningful stand out to you?"
  - "Is there a moment you don't want to forget?"
  - "Did God meet you in any way recently?"
  - "What has been on your heart lately?"

**ReviewView**
- Single screen, two modes determined by origin (voice / type)
- Voice mode: transcript pre-filled; "Re-record" + "Save" buttons in footer
- Type mode: blank canvas, cursor ready; single full-width "Save moment" button
- Optional "Where did you sense the Lord?" prompt shown as faint italic hint below body text
- Gold text cursor (#C9B27C)
- Save writes moment to backend with offline-first sync

**MomentsListView**
- Displays all captured moments sorted by most recent first
- Entry shows: date (small caps) + body text (15px, 3-line clamp) — no title line
- Tapping entry → Moment detail view (full body + metadata)
- "+" CTA button fixed at bottom
- Empty state centered with subtitle and CTA
- Pull-to-refresh / sync indicator for offline moments

**MomentDetailView**
- Full moment text display
- Date created + time
- Re-read count tracking (future: visual indicator)
- Clean, readable typography

**SettingsView**
- Profile section: email, sign out
- App info: version, build number
- Legal links (privacy, terms)
- Session management

### Backend & Sync

**Supabase Integration**
- Authentication: email + password
- Real-time sync: moments saved locally first, then synced to Supabase
- Offline-first architecture: all capture succeeds locally even without network
- Sync strategy: fire-and-forget when online; retried automatically when connection restored
- Row-Level Security (RLS) enforced: users can only access their own moments
- Analytics events tracked: app_opened, app_closed, moment_created (voice vs. text)

**Offline-First Architecture**
- Moments stored in Keychain (secure) + UserDefaults (sync queue)
- Voice recordings temporarily cached to disk, deleted after transcription
- Pending moments queue persists across app restarts
- Auto-sync when network becomes available
- Conflicts resolved via UUID-based upsert logic

### Analytics Tracking (New in Layer 1)

**Events Tracked:**
- `app_opened` — session start
- `app_closed` — session end
- `moment_created` — with momentType (voice or text)

**Captured Data:**
- User ID, event type, moment type, timestamp
- Events synced to Supabase usage_events table
- Available for Layer 1 success metrics (capture frequency, engagement patterns)

## Data Model

```swift
struct Moment: Codable {
    let id: String                  // UUID
    let userId: String              // Supabase auth user ID
    let body: String                // The moment itself
    let senseOfLord: String?        // Optional reflection
    let createdAt: Date             // ISO timestamp
    let updatedAt: Date
}

struct UsageEvent: Codable {
    let id: String
    let userId: String
    let eventType: String           // "app_opened", "app_closed", "moment_created"
    let momentType: String?         // "voice" or "text" (null for non-moment events)
    let timestamp: Date
}
```

## Explicitly Out of Scope (Layer 1)

- Editing or deleting moments
- Gallery view (Layer 2)
- AI-generated moment images (Layer 2)
- Reminders or push notifications
- Social features or sharing
- Pattern surfacing or AI reflection
- Interpretation or theological guidance
- Image or media attachments (beyond voice recording)
- Search or filtering
- Tags or categories
- Self-signup or account management
- User analytics dashboard (internal only)

## Current Status (March 11, 2026)

| Phase | Title | Status | Dates |
|-------|-------|--------|-------|
| Phase 1 | 7-Day Personal Dogfooding | 🔄 In Progress | Mar 10–17 |
| Phase 2 | QA Testing (Build 105) | 🔲 Not Started | Mar 17–20 |
| Phase 3 | Prototype Demo Prep | 🔲 Not Started | Mar 20–22 |
| Phase 4 | App Store Submission Prep | 🔲 Not Started | Mar 22–25 |
| Phase 5 | Final Validation | 🔲 Not Started | Mar 25–28 |

**Build Status:** Build 105 live on TestFlight with full analytics pipeline

**Tickets Complete:** 46/61 (75%)

## Roadmap

### Layer 2 Pilot (Planned)

Deepen the experience based on Layer 1 findings.

- Moment detail screen enhancements
- Gallery / pattern view — surface recurring themes
- AI-generated moment imagery
- Reflection nudges — return prompts based on pilot findings
- Push notifications — optional capture reminders

### App Store Launch (Post-Pilot)

- Self-signup flow
- App Store listing — screenshots, description, metadata
- App Store submission and review

## Tech Stack

- **Framework:** SwiftUI (native iOS)
- **Language:** Swift 5.9
- **Backend:** Supabase (Postgres + Auth + RLS)
- **Local Storage:** Keychain (secure) + UserDefaults (sync queue)
- **Voice Recording:** AVFoundation (native iOS audio framework)
- **Voice-to-Text:** Speech Framework (on-device iOS STT)
- **HTTP Client:** URLSession (native)

## Design Principles

- **Audio-first:** Voice input is the primary capture mechanism; text is the fallback
- **Minimal friction:** Three taps to capture a moment (tap mic, speak, save)
- **Spiritual tone:** Reflective UI, warm gold accents, thoughtful spacing
- **Offline-ready:** Every action succeeds locally; sync is automatic and invisible
- **Trustworthy:** Clear privacy stance (user data stays local until sync), no tracking except engagement metrics

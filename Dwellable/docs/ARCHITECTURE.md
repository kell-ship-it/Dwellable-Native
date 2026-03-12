# Architecture

**Product:** Dwellable Native iOS | **Stack:** Swift + SwiftUI | **Updated:** March 11, 2026

---

## Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| Framework | SwiftUI | Native iOS, iOS 15+  |
| Language | Swift 5.9 | Type-safe, compiled |
| IDE | Xcode | Native iOS development |
| Navigation | SwiftUI NavigationStack | File-based structure mimics Expo Router |
| State Management | @State, @StateObject, @EnvironmentObject | Decentralized; no global Redux-like store |
| Backend | Supabase | Postgres + JWT auth + Row-Level Security |
| Auth | Supabase email + password | Pre-provisioned accounts; no self-signup |
| Local Storage | Keychain + UserDefaults | Secure storage for tokens; sync queue for pending moments |
| Voice Recording | AVFoundation | Native iOS audio capture |
| Speech-to-Text | Speech Framework | On-device iOS STT; works offline |
| HTTP Client | URLSession | Native networking |
| Analytics | UsageTracker (in-app) + Supabase table | Events stored locally, synced to backend |
| UI Kit | SwiftUI + Theme.swift | Centralized colors, fonts, spacing |
| JSON Encoding | Codable | Swift's native serialization with custom date handling |

---

## Project Structure

```
Dwellable/
├── Dwellable/                          # App source code
│   ├── DwellableApp.swift              # App entry point
│   ├── AppView.swift                   # Root navigation stack
│   │
│   ├── Views/                          # SwiftUI screen files
│   │   ├── LoginView.swift             # Auth entry point
│   │   ├── MomentsListView.swift       # Home screen (moment list)
│   │   ├── CaptureView.swift           # Voice/text input screen
│   │   ├── ReviewView.swift            # Edit/confirm screen
│   │   ├── MomentDetailView.swift      # Moment reader (modal/detail)
│   │   ├── SettingsView.swift          # App settings & profile
│   │   ├── TranscribingView.swift      # Loading state during STT
│   │   └── TypeFlowView.swift          # Text-input variant
│   │
│   ├── Managers/                       # Business logic
│   │   ├── AuthManager.swift           # Session state + Supabase auth
│   │   ├── SyncManager.swift           # Moments sync + offline queue
│   │   ├── SupabaseAPIClient.swift     # HTTP + Supabase REST API
│   │   ├── MockAPIClient.swift         # Testing stub
│   │   └── UsageTracker.swift          # Analytics event logging
│   │
│   ├── Models/                         # Data structures
│   │   ├── Moment.swift                # Moment struct + Codable
│   │   ├── User.swift                  # User model
│   │   ├── UsageEvent.swift            # Analytics event model
│   │   └── LocalStorageManager.swift   # Keychain + UserDefaults ops
│   │
│   ├── Utilities/                      # Helpers
│   │   ├── Theme.swift                 # Colors, fonts, spacing
│   │   ├── Extensions.swift            # String, Date, etc. helpers
│   │   └── Constants.swift             # Magic numbers, config
│   │
│   ├── Assets.xcassets/                # Colors, images, icons
│   │   ├── AccentColor.colorset
│   │   ├── AppIcon.appiconset          # App icon (1024x1024 D)
│   │   └── Contents.json
│   │
│   └── Info.plist                      # App metadata + permissions
│
├── Dwellable.xcodeproj/                # Xcode project config
├── DwellableTests/                     # Unit tests (minimal Layer 1)
├── DwellableUITests/                   # UI tests (manual device testing preferred)
│
├── docs/                               # Documentation
│   ├── VISION.md                       # Product north star
│   ├── PRD.md                          # Specification
│   ├── ARCHITECTURE.md                 # This file
│   ├── WORKFLOW.md                     # Development workflow
│   ├── MEMORY.md                       # Session logs
│   └── KEY_LEARNINGS.md                # Critical lessons
│
├── TICKETS.md                          # Full ticket registry (61 total, 46 complete)
├── TICKETS.csv                         # Spreadsheet version
├── CLAUDE.md                           # Agent guidelines
├── AGENT_GUIDELINES.md                 # Session protocol
├── MEMORY.md                           # Global project memory
├── FOLDER_STRUCTURE.md                 # Directory guide
└── USER_ACTIVITIES.md                  # Layer 1 activities checklist
```

---

## Navigation Architecture

**SwiftUI NavigationStack** — flat hierarchy, no tab bar.

```
DwellableApp
  ├── AppView (auth check, main navigation stack)
  │   ├── LoginView (pre-login)
  │   └── MomentsListView (post-login home)
  │       └── [push] CaptureView
  │           └── [push] ReviewView
  │               └── [push] TranscribingView (loading state)
  │       └── [sheet] MomentDetailView
  │       └── [push] SettingsView
  │           └── [sheet] SignOutConfirmation
```

Key decisions:
- No tab bar; Stack-based navigation only
- `.sheet()` for modal overlays (MomentDetailView)
- `.navigationDestination()` for programmatic navigation
- Single source of truth for `@Published` auth state in AuthManager

---

## Data Flow

```
┌─────────────┐
│  User Input │ (voice tap / text type)
└──────┬──────┘
       │
       ↓
┌──────────────────────┐
│  ReviewView/View     │
│  Call saveMoment()   │
└──────┬───────────────┘
       │
       ↓
┌────────────────────────────┐
│  LocalStorageManager       │
│  Save to Keychain (secure) │
│  Add to UserDefaults queue │
│  Return local moment       │
└──────┬─────────────────────┘
       │
       ↓ (sync in background)
┌────────────────────────────┐
│  SyncManager               │
│  Check network status      │
│  Batch pending moments     │
│  POST to Supabase REST API │
│  Handle 409 conflicts      │
└──────┬─────────────────────┘
       │
       ↓
┌────────────────────────────┐
│  Supabase moments table    │
│  RLS enforces user_id      │
│  Data persisted in Postgres│
└────────────────────────────┘
```

---

## Auth Flow

```
App Launch
  │
  ├─→ AuthManager checks Keychain for stored token
  │
  ├─→ If token exists & valid:
  │   └─→ Restore session
  │       └─→ MomentsListView (home)
  │
  └─→ If no token:
      └─→ LoginView
          └─→ User enters email + password
              └─→ Supabase POST /auth/v1/token
                  └─→ Token stored in Keychain
                      └─→ Redirect to MomentsListView
```

Session persistence:
- Access token stored in Keychain (encrypted)
- Refresh token also stored
- AuthManager subscribes to Supabase `onAuthStateChange()`
- Token auto-refreshes when expired

---

## State Management

**Pattern: Local state first, lift only when needed**

| State | Scope | Tool | Example |
|-------|-------|------|---------|
| Form input | Single view | `@State` | CaptureView text input |
| Navigation | Multiple views | `@StateObject` + `@Environment` | AuthManager.currentUser |
| Loading | Single view | `@State` | ReviewView.isSaving |
| Global auth | Entire app | `@StateObject` in AppView | AuthManager.session |
| Sync status | Views needing network state | `@EnvironmentObject` | SyncManager.isOnline |

**No Redux/global store.** Each view owns its local state. AuthManager is the single source of truth for session/user data.

---

## Key Decisions

| Decision | Options | Chosen | Rationale |
|----------|---------|--------|-----------|
| **Framework** | UIKit, SwiftUI | SwiftUI | Modern, declarative, Xcode-first integration |
| **Navigation** | Tab bar, Split view, Stack | Stack only | Design spec; Moments list as single home |
| **Voice STT** | Whisper API, on-device Speech Framework | Speech Framework | On-device, free, works offline, native iOS |
| **Local storage** | Core Data, Realm, UserDefaults | Keychain + UserDefaults | Simple for Layer 1; Keychain for security |
| **Sync strategy** | Real-time, batch, fire-and-forget | Fire-and-forget + retry | Local-first; offline capture never blocked |
| **Auth method** | Magic link, OAuth, email+password | Email + password | Pre-provisioned; simpler for pilot scale |
| **Analytics** | Third-party SDK (Firebase, Mixpanel) | In-app UsageTracker | User privacy; full control over events |

---

## Offline-First Architecture

**Core principle:** All user actions succeed locally. Sync to server is automatic and transparent.

**Moments:**
- Save to Keychain immediately (user sees no latency)
- Add UUID to UserDefaults queue
- Background sync when network available
- Conflict resolution: upsert on UUID (409 conflicts ignored)

**Voice Recordings:**
- Cached to disk during capture
- Deleted after transcription succeeds
- Never synced (only transcribed text stored)

**Usage Events:**
- Logged to UserDefaults by UsageTracker
- Batch-synced to Supabase with moments sync
- Re-sync on network restoration

**Error Handling:**
- Network error: moment stays in queue, retry next sync
- Invalid JWT: clear token, redirect to login
- Sync conflict: silently ignore duplicate UUIDs
- Transcription error: show user, allow re-record or discard

---

## Security

**Authentication:**
- Supabase JWT (access + refresh tokens)
- Tokens stored in Keychain (encrypted by OS)
- Auto-refresh on token expiry
- Sign-out clears tokens from Keychain

**Data:**
- Row-Level Security (RLS) on moments table: `SELECT, INSERT` only for `auth.uid() = user_id`
- No UPDATE/DELETE exposed (out of Layer 1 scope)
- Moments encrypted at rest in Supabase (Postgres native)

**Voice:**
- Recordings never leave device (transcription on-device)
- No audio files uploaded to server

**Analytics:**
- UsageTracker logs events locally
- Events synced to Supabase (tied to user_id)
- No third-party analytics SDKs (Firebase, Mixpanel)

---

## Testing Strategy

| Type | Tool | Status |
|------|------|--------|
| Type checking | Swift compiler | Enforced via Xcode |
| Unit tests | XCTest | Minimal (API stubs tested) |
| Integration tests | XCTest + Supabase mock | Manual device testing preferred |
| Manual UI tests | Real iPhone 13 | Per-ticket device testing |
| Pilot | TestFlight | Build 105 live; 7-day dogfooding in progress |

**Rationale:** XCTest async/await limitations + simulator video sync issues make manual device testing more reliable for Layer 1. Full XCUI automation deferred to Layer 2.

---

## Performance Considerations

**Startup Time:**
- AuthManager checks Keychain on launch (~50ms)
- MomentsListView loads from UserDefaults (~10ms)
- Supabase fetch happens in background (user sees cached list first)

**Memory:**
- Moments kept in memory only during active view
- Voice recordings cached to disk, deleted after transcription
- No persistent Core Data store (optional for Layer 2)

**Sync:**
- Batch moment uploads (10 moments per request)
- Usage event batch sync (50 events per request)
- Network monitoring prevents sync attempts when offline

---

## Future Considerations (Layer 2+)

- Core Data for richer local queries (search, filtering)
- SQLite for larger moment libraries (>10k moments)
- Server-driven UI for theme/content updates
- Push notifications for reflection reminders
- iCloud sync for multi-device support

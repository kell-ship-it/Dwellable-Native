# CLAUDE.md

This file provides guidance to Claude when working in this repository.

## Project

Dwellable — Native iOS app built with Swift and SwiftUI.

## Tech Stack

- **Swift 5** / **SwiftUI**
- **Xcode** (native project — no Expo, no React Native, no npm)
- **AVFoundation** — microphone recording
- **Supabase** — backend (planned)

## Commands

```bash
# Build and run on simulator
xcodebuild -scheme Dwellable -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Install to booted simulator
xcrun simctl install booted <path-to-app>
xcrun simctl launch booted com.kellgolden.Dwell

# Check simulator logs
xcrun simctl spawn booted log show --predicate 'process == "Dwellable"' --last 10s

# Open in Xcode
open Dwellable.xcodeproj
```

## Project Structure

```
Dwellable/
  Views/          # SwiftUI screen files
  Assets.xcassets # Colors, images
  Info.plist      # App permissions and config
TICKETS.md        # Full ticket registry (all tickets, all statuses)
TICKETS.csv       # Spreadsheet version of ticket registry
```

## Key Project Info

- **Bundle ID:** `com.kellgolden.Dwell`
- **Team ID:** `38X95M6CUB`
- **Apple ID:** `kell.golden@outlook.com`
- **Design prototype:** `file:///Users/kell/dev/dwellable-rn-codex/design-mockups/prototype-v1.html`

## Screens Built (✅ Complete)

1. `LoginView.swift` — Email/password login (stub auth)
2. `MomentsListView.swift` — Home screen with MomentRow + MomentDetailView (embedded)
3. `CaptureView.swift` — Voice capture + TranscribingView + TypeFlowView (embedded)
4. `ReviewView.swift` — Voice review mode with Re-record + Save
5. `Theme.swift` — Centralized colors and fonts

## Conventions

- **File naming:** PascalCase for all Swift files (`LoginView.swift`)
- **Styling:** Use `Theme.swift` constants — avoid hardcoded colors or font sizes
- **State:** `@State` for local, `@Binding` for passed-down, `@StateObject` for shared models
- **Embeds:** TypeFlowView and MomentDetailView currently embedded in parent files (refactor tracked in T-007)

## Session Protocol

**At session START and session END, always present the full ticket table from TICKETS.md.**
The table must include ALL tickets — ✅ Complete, 🔄 In Progress, and 🔲 Not Started.

See `AGENT_GUIDELINES.md` for full session rules.

## Execution Rules

- Before major changes, summarize in 3 bullets what you're about to do and why
- One ticket at a time — no scope creep
- Always ask before adding new dependencies or editing Info.plist permissions
- Never commit without running a build first
- Treat `TICKETS.md` as the source of truth for project scope

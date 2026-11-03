# Dwelly Native iOS — Setup Instructions

## Quick Start

The Swift source files are ready. Now you need to create the Xcode project wrapper.

### Step 1: Create Xcode Project (GUI)

1. Open **Xcode**
2. File → New → Project
3. Choose: **iOS** → **App**
4. Configure:
   - Product Name: `Dwelly`
   - Team: (select your team)
   - Organization ID: `com.kellgolden` (or your preference)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - **DO NOT create Git repository** (we'll use the existing one)
5. Save location: `/Users/kell/Projects/Dwelly-Native/`

This creates a `.xcodeproj` file structure with build settings, assets, etc.

### Step 2: Replace Source Files

Once Xcode project is created:

1. In Xcode, select the `Dwelly/` folder (the app target folder)
2. Delete all existing `.swift` files
3. Drag the source files from `/Users/kell/Projects/Dwelly-Native/Dwelly/Dwelly/` into Xcode
   - Views/
   - Managers/
   - Models/
   - Utilities/

### Step 3: Install CocoaPods

From terminal in `/Users/kell/Projects/Dwelly-Native/Dwelly/`:

```bash
pod install
```

This creates:
- `Pods/` directory
- `.xcworkspace` file

### Step 4: Open Workspace (Important!)

Close the `.xcodeproj` file, then open the `.xcworkspace` file:

```bash
open Dwelly.xcworkspace
```

**ALWAYS use the `.xcworkspace` file after `pod install`, not the `.xcodeproj`.**

### Step 5: Configure Supabase Environment

1. Create `Dwelly/Config.swift`:

```swift
import Foundation

struct Config {
    static let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
    static let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
}
```

2. Add your Supabase URL and key from the React Native project

### Step 6: Build & Run

Cmd+B to build (should compile with no errors)
Cmd+R to run on simulator

---

## Current Status

### ✅ Completed
- DwellyApp.swift (app entry point)
- LoginView.swift (auth screen with D-002 subtitle fix)
- CaptureView.swift (voice UI with D-003 rotating prompts)
- ReviewView.swift (edit screen with D-004 gold cursor)
- MomentsListView.swift (placeholder for home screen)
- AppView.swift (main navigation placeholder)
- AuthManager.swift (auth state management - mock implementation)
- Models: Moment.swift
- Theme.swift (centralized colors/sizes)

### 🚧 TODO
- **Phase 1 (Today):**
  - Implement actual Supabase sign-in in AuthManager
  - Connect to existing Supabase project (use EXPO_PUBLIC_* vars)
  - Test login flow

- **Phase 2 (Tomorrow):**
  - Core Data setup for moment storage
  - Navigation between screens
  - Full screen implementations

- **Phase 3 (Later):**
  - Sync logic to Supabase
  - Voice recording UI refinement
  - Polish + testing

---

## Next Steps

1. Create Xcode project using steps above
2. Run on simulator
3. Test that app launches and shows login screen
4. Let me know when Xcode project is created — I'll implement Supabase integration

---

## File Structure

```
Dwelly-Native/
├── Dwelly/
│   ├── Dwelly/           # Source code (Swift files)
│   │   ├── DwellyApp.swift
│   │   ├── Views/
│   │   ├── Managers/
│   │   ├── Models/
│   │   └── Utilities/
│   ├── DwellyTests/
│   ├── Podfile              # CocoaPods dependencies
│   └── Dwelly.xcworkspace (created after pod install)
└── SETUP.md (this file)
```

---

## Troubleshooting

**"Pods directory not found"**
→ Run `pod install` in the `Dwelly/` directory

**"Errors when opening Xcode project"**
→ Make sure you're opening `.xcworkspace`, not `.xcodeproj`

**"Cannot find LoginView in DwellyApp"**
→ Make sure all Swift files are added to Xcode target (File Inspect → Target Membership)

---

When Xcode is set up and running, let me know! I'll implement Phase 1 features (Supabase auth integration).

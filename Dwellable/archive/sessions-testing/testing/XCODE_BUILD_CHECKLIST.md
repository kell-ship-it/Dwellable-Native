# Xcode Build & Testing Checklist

**Purpose:** Verify all changes from March 10 session build and run correctly on device/simulator

---

## 🔨 Build Verification

### Step 1: Clean Build
```bash
cd /Users/kell/Desktop/Dwellable-Native/Dwellable
xcodebuild clean -scheme Dwellable
xcodebuild build -scheme Dwellable -destination 'platform=iOS Simulator,name=iPhone 17'
```

**Expected result:** ✅ Build succeeds with no errors

### Step 2: Run on Simulator
```bash
xcodebuild build -scheme Dwellable -destination 'platform=iOS Simulator,name=iPhone 17'
open /Users/kell/Desktop/Dwellable-Native/Dwellable/DerivedData/Build/Products/Debug-iphonesimulator/Dwellable.app
```

Or simply: **Product → Run** in Xcode (⌘R)

---

## 🧪 Manual Testing Scenarios

### Scenario 1: Text Input Placeholder (NEW FIX)
**Location:** CaptureView → "Type instead" → TypeFlowView

**Steps:**
1. Launch app
2. Login with `test.normal@example.com` / `password123`
3. Tap "Type instead" on CaptureView
4. Verify: "Begin here..." placeholder text appears in the moment body field
5. Start typing: placeholder should disappear as you type
6. Type a moment and save

**Expected result:** ✅ Placeholder visible when empty, disappears on input, moment saves successfully

**Screenshot location:** TypeFlowView with moment body field

---

### Scenario 2: General Issues with Images (PREVIOUS SESSION)
**Location:** Testing checklist UI (Desktop, already tested)

**Verification:** This was tested in the March 10 session successfully
- ✅ Multiple unique issues per test
- ✅ Multiple images per issue
- ✅ Export includes all issues with image filenames
- ✅ Results file: `/Users/kell/Downloads/Dwellable_Testing_Results_2026-03-10.txt`

No changes needed — feature is working correctly.

---

### Scenario 3: Offline Moments (CONTEXT FOR T-030)
**Location:** All views when network disabled

**Steps:**
1. Login successfully (requires network)
2. Disable WiFi and cellular (airplane mode on)
3. Create a moment (voice or text)
4. Verify: Moment saves locally with "pending sync" indicator
5. Re-enable network
6. Verify: Pending moment auto-syncs to Supabase
7. Restart app
8. Verify: Moment still appears (sync persisted)

**Expected result:** ✅ Offline moments sync when network returns

**Note:** If user deletes app while offline:
- Old moments are lost (T-030 consideration for v1.1)
- This is expected behavior documented in TESTING_CLARIFICATIONS.md

---

## 📋 Commit Verification

All changes committed and ready:

```bash
git log --oneline -5
```

Should show:
```
02b3349 Update MEMORY.md with March 10 session summary
a864d35 Add testing tickets from March 10 session and clarification document
d518184 Add 'Begin here...' placeholder text to moment text input field
5cbac34 Enhance General Issues section with multi-issue, multi-image support
5b5f543 enhance: Add image upload per test + general issues section
```

---

## 👥 Creating Participant Accounts

Once you've verified the build works, create test accounts for beta participants:

### Supabase Dashboard Access
1. Go to https://supabase.com/dashboard
2. Project: `lhcjobrtmbawlhjyodxz`
3. Navigate to **Authentication** → **Users**

### Creating Manual Test Accounts
**Option A: Using Supabase Dashboard (Manual)**
1. Click **Invite User** or create directly in auth.users table
2. Set email (e.g., `participant.1@example.com`)
3. Set password (temporary, user can change)
4. Note down credentials

**Option B: Using Auth API (Programmatic)**
```bash
# Create user via Supabase REST API
curl -X POST https://lhcjobrtmbawlhjyodxz.supabase.co/auth/v1/admin/users \
  -H "Authorization: Bearer YOUR_SUPABASE_ADMIN_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "participant.1@example.com",
    "password": "TempPassword123!",
    "email_confirm": true
  }'
```

### Suggested Account Schema
| Role | Email | Password | Device | Notes |
|------|-------|----------|--------|-------|
| Power User | `power.user@example.com` | (generate) | iPhone 14+ | Heavy voice/text usage |
| Light User | `light.user@example.com` | (generate) | iPhone 12 | Occasional use |
| Offline Tester | `offline.tester@example.com` | (generate) | iPhone 13 | Test offline scenarios |
| Edge Cases | `edge.cases@example.com` | (generate) | iPad | Test on larger device |

### Participant Setup Instructions
Share with participants:
```
Welcome to Dwellable Beta!

Login credentials:
- Email: participant.1@example.com
- Password: [temporary password]

First time:
1. Download TestFlight from App Store
2. Accept beta invite link
3. Install Dwellable beta
4. Login with credentials above
5. Change password on first login

Testing focus areas:
- Voice recording (tap mic, speak, save)
- Text entry (tap "Type instead", write moment)
- Offline usage (disable WiFi, create moment, re-enable WiFi)
- Navigation between screens
- Any crashes or unexpected behavior

Please report issues with:
- Screenshot of issue
- Device model and iOS version
- Steps to reproduce
```

---

## ✅ Pre-Launch Checklist

- [ ] Xcode build succeeds (no errors/warnings)
- [ ] App runs on simulator/device
- [ ] Scenario 1: Text placeholder visible and disappears on input
- [ ] Scenario 2: Can create moment with text
- [ ] Scenario 3: Offline creation works, sync works when online
- [ ] Navigation between screens works smoothly
- [ ] No crashes observed
- [ ] Participant accounts created in Supabase
- [ ] Participant setup instructions prepared
- [ ] TestFlight beta build uploaded (if using TestFlight)

---

## 🚀 Next Steps After Verification

1. ✅ Build verified → **Ready for participant testing**
2. ✅ Create participant accounts → **Ready for beta distribution**
3. ✅ Get participant feedback → **Feed into T-029, T-030 decisions**
4. **After feedback:** Continue with:
   - T-010: SettingsView
   - T-009: Style refinements (if needed)
   - Sub-screens (EditMomentView, SearchView, ArchiveView)

---

**Last updated:** March 10, 2026
**Session:** Post-fix verification before beta launch

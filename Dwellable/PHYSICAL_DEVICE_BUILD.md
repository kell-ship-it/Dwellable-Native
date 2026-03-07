# Building Dwellable to Physical iPhone — Complete Guide

**Goal:** Deploy the Dwellable app from Xcode to your physical iPhone so you can test voice recording and offline functionality
**Time:** ~10–15 minutes (first time)
**Requirements:**
- Physical iPhone running iOS 16+ (tested on iPhone 16 Pro)
- Mac with Xcode 15+ installed
- USB-C to iPhone cable (or wireless if configured)
- Apple Developer Account (free account works for development)

---

## Step 1️⃣ — Prepare Your iPhone

### 1.1 Connect iPhone to Mac

Plug your iPhone into your Mac using a USB cable. You should see:
- "Trust This Computer?" prompt on phone → tap **Trust**
- Device appears in Xcode's device list

### 1.2 Enable Developer Mode (iOS 16+)

On your iPhone:
1. **Settings → Privacy & Security → Developer Mode**
2. Toggle **Developer Mode ON**
3. Confirm the warning popup
4. iPhone will restart
5. After restart, re-enable Developer Mode (settings → privacy)
6. Enter your device passcode to confirm

---

## Step 2️⃣ — Configure Signing in Xcode

Open Xcode and navigate to the Dwellable project:

```bash
cd /Users/kell/Projects/Dwellable-Native/Dwellable
open Dwellable.xcodeproj
```

### 2.1 Select Project Settings

1. In Xcode, select **Dwellable** (blue project icon) in the left sidebar
2. Select target **Dwellable** (not DwellableUITests)
3. Go to **Signing & Capabilities** tab

### 2.2 Configure Signing

In the **Signing & Capabilities** panel:

| Setting | Value |
|---|---|
| **Team** | kell.golden@outlook.com (personal team) |
| **Bundle Identifier** | `com.kellgolden.Dwell` |
| **Signing Certificate** | Automatic (let Xcode manage) |
| **Provisioning Profile** | Automatic (let Xcode manage) |

**If you see a red error:**
- Click **Fix Issue** button (blue) → Xcode will auto-create certificate
- If that fails, create a free Apple Developer account and try again

### 2.3 Verify All Targets

Also set signing for:
- **DwellableTests** (if exists)
- **DwellableUITests** (if exists)

Use same team and bundle ID for all targets.

---

## Step 3️⃣ — Select Your iPhone as Build Target

### 3.1 Choose Device in Xcode

In the top toolbar of Xcode:

1. Find the scheme selector (shows "Dwellable" on left side)
2. Click the device dropdown next to it
3. You should see your iPhone listed with its name (e.g., "iPhone (16 Pro)")
4. **Select your iPhone**

The toolbar should now show:
```
Scheme: Dwellable | Device: iPhone 16 Pro
```

### 3.2 Verify Connection

In Xcode menu: **Window → Devices and Simulators**
- You should see your iPhone listed under "Connected"
- Status should be "Paired" or "Connected"
- If not, disconnect/reconnect USB cable

---

## Step 4️⃣ — Build and Run on Device

### 4.1 Build the App

In Xcode:
1. **Product → Build** (or Cmd+B)
2. Wait for build to complete (check bottom panel for progress)
3. Look for **"Build Complete"** message

**If build fails:**
- Check error message in bottom panel
- Common issues:
  - Missing signing certificate → Fix Issue button
  - Derived data corrupted → **Product → Clean Build Folder** (Cmd+Shift+K)
  - Code sign error → Re-run signing setup in Step 2

### 4.2 Run on Physical Device

In Xcode:
1. **Product → Run** (or Cmd+R)
2. App will build, sign, and install on your iPhone
3. Watch for progress in Xcode console
4. App should launch on iPhone automatically

**First launch may prompt:**
- "Untrusted Developer" → Go to **Settings → General → Device Management → kell.golden → Trust**
- Then return to homescreen and tap Dwellable again

---

## Step 5️⃣ — Verify Installation

On your iPhone:
1. Look for **Dwellable** app icon on homescreen
2. Tap to launch
3. You should see **LoginView** (dark theme, gold button)

### 5.1 Test Basic Flow

Try a quick test:
1. **Login:** `test@example.com` / `password123`
2. **Check MomentsListView** appears with moments list
3. **Tap mic button** → You should hear audio permission request
4. **Grant microphone access** → Mic will be active (blue indicator)

---

## Step 6️⃣ — Test Voice Recording (Key Feature)

This is what you **can't test** on simulator:

### 6.1 Record a Moment

1. On MomentsListView, tap the **mic button** (circular)
2. Start speaking: *"This is a test of the Dwellable voice recording"*
3. Tap **Stop** (should show recording duration, e.g., "0:12")
4. View ReviewView with auto-transcribed text
5. Tap **Save**

### 6.2 Verify Result

- Moment appears in MomentsListView
- Transcript matches what you said (speech-to-text quality varies)
- Date/time is correct

---

## Step 7️⃣ — Test Offline Functionality (Critical)

This is where the physical device really shines:

### 7.1 Test Offline Save

1. **Disable WiFi + Cellular:**
   - iPhone Settings → WiFi → toggle OFF
   - Settings → Cellular → toggle OFF (or Settings → Airplane Mode ON)

2. **Create offline moment:**
   - MomentsListView → Tap mic
   - Record: *"Testing offline"*
   - Tap Stop → Tap Save

3. **Expected behavior:**
   - "Pending sync" message appears for 1.5 seconds
   - Moment still appears in list
   - No error shown

### 7.2 Test Auto-Sync

1. **Re-enable network:**
   - Settings → WiFi → toggle ON
   - Wait 10 seconds

2. **Expected behavior:**
   - Offline moment syncs automatically
   - No manual action needed
   - Moment persists in list

---

## Step 8️⃣ — Test App Restart with Offline Data

### 8.1 Create Offline, Restart, Then Sync

1. **Disable WiFi + Cellular** (airplane mode)
2. **Create moment** (voice or text)
3. See "Pending sync" message
4. **Force-quit app:**
   - Swipe up from bottom → Stop swiping → Swipe up again
   - Or: Settings → General → iPhone Storage → Dwellable → Delete App
5. **Re-launch app** (tap Dwellable icon)
6. Should still be logged in
7. Offline moment should still be there
8. **Enable WiFi** → Moment syncs automatically

---

## Step 9️⃣ — Debug Console Output

If anything goes wrong, check Xcode's console:

### 9.1 View Console Logs

In Xcode:
- **View → Debug Area → Show Debug Area** (Cmd+Shift+Y)
- Filter for errors: type `error` in search box

### 9.2 Common Errors

| Error | Cause | Fix |
|---|---|---|
| `"Cannot find 'SupabaseAPIClient' in scope"` | SupabaseAPIClient not in build target | Check TICKETS.md T-001 status |
| `"keychain permission denied"` | Keychain access issue | Rebuild, ensure signing is correct |
| `"Network error"` | API unreachable | Check Supabase project is running |
| `"Invalid request"` | Wrong credentials or API key | Verify Config.swift has correct Supabase URL + key |

---

## 🔟 Wireless Deployment (Optional)

Once you've deployed once via USB, you can deploy wirelessly:

### 10.1 Set Up Wireless

1. **Xcode → Window → Devices and Simulators**
2. Right-click your iPhone → **Connect via Network**
3. Xcode will upload signing certificates to device

### 10.2 Deploy Wirelessly

After setup:
1. Device should still appear in Xcode device selector
2. Select it (may show wireless icon)
3. **Product → Run** (Cmd+R)
4. App will deploy over WiFi (slower than USB, but works)

---

## 1️⃣1️⃣ Troubleshooting

### Issue: "Could not launch Dwellable"
**Solution:**
1. Disconnect USB cable
2. Reconnect
3. In Xcode: **Product → Clean Build Folder** (Cmd+Shift+K)
4. **Product → Run** (Cmd+R)

### Issue: "Untrusted Developer" on iPhone
**Solution (on iPhone):**
1. Settings → General → Device Management
2. Tap "kell.golden@outlook.com"
3. Tap "Trust"
4. Return and tap Dwellable app

### Issue: "Signing certificate not found"
**Solution:**
1. In Xcode: **Preferences → Accounts**
2. Add Apple ID (kell.golden@outlook.com)
3. Return to **Signing & Capabilities** → Click **Fix Issue**
4. Xcode will create development certificate

### Issue: App crashes on launch
**Check:**
1. Xcode console for error messages
2. Is Supabase project running? Check Supabase dashboard
3. Is API key in Config.swift correct?
4. Did you grant microphone permission?

### Issue: "Cannot connect to Supabase"
**Check:**
1. iPhone has WiFi enabled
2. WiFi is internet-connected
3. Config.swift has correct Supabase URL (https://lhcjobrtmbawlhjyodxz.supabase.co)
4. Try ping from Terminal: `ping supabase.co`

---

## 📸 Expected Screens

### LoginView (first launch)
- Dark background
- Dwellable wordmark (centered)
- "Email" text field
- "Password" secure field
- Gold "Login" button
- Message: "Enter your email and password to begin"

### MomentsListView (after login)
- Top: "Moments" header
- Empty state OR list of moments with:
  - Date header (e.g., "March 7, 2026")
  - Moment preview (first line of text)
  - Right chevron (→)
- Bottom: Circular mic button (blue when recording)

### CaptureView (after tapping mic)
- Circular mic button (centered, gold)
- "Tap to record" text above
- "Type instead" pill button below
- Recording duration timer (if recording)

### ReviewView (after recording)
- Transcribed text (from speech-to-text)
- "Sense of Lord" optional field
- Bottom: "Save" + "Re-record" buttons

---

## ✅ Success Criteria

You've successfully deployed if:
- [ ] App appears on iPhone homescreen
- [ ] App launches without crashing
- [ ] LoginView displays correctly
- [ ] Login works with test@example.com / password123
- [ ] MomentsListView shows existing moments
- [ ] Voice recording works (tap mic → record → stop)
- [ ] Transcription appears in ReviewView
- [ ] Saving moment works and adds to list
- [ ] Offline moment creation works
- [ ] Offline moment syncs when network restored
- [ ] Restarting app keeps you logged in (Keychain works)

---

## 🎯 Next Steps

After successful deployment:
1. **Run manual testing checklist:** MANUAL_TESTING_CHECKLIST.md
2. **Document results** in USER_ACTIVITIES.md
3. **Report findings** in session summary

---

## 📞 If Stuck

Check:
1. **Xcode Build Log** — Product → Show Build Folder in Finder → Build Log
2. **Console Messages** — View → Debug Area → Show Debug Area
3. **Device Status** — Window → Devices and Simulators → check "Paired" status
4. **Config.swift** — Verify Supabase URL and API key are correct


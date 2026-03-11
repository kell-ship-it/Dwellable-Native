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

| Action | Where |
|---|---|
| 1. Select **Dwellable** (blue project icon) | Left sidebar of Xcode |
| 2. Select target **Dwellable** | Under project, NOT DwellableUITests |
| 3. Go to **Signing & Capabilities** tab | Right panel of Xcode |

### 2.2 Configure Signing Settings

| Setting | Value |
|---|---|
| **Team** | kell.golden@outlook.com (personal team) |
| **Bundle Identifier** | `com.kellgolden.Dwell` |
| **Signing Certificate** | Automatic (let Xcode manage) |
| **Provisioning Profile** | Automatic (let Xcode manage) |

**If you see a red error:** Click **Fix Issue** button (blue) → Xcode will auto-create certificate

### 2.3 Verify All Targets

Apply same signing settings to these targets (if they exist):

| Target | Team | Bundle ID |
|---|---|---|
| Dwellable | kell.golden@outlook.com | com.kellgolden.Dwell |
| DwellableTests | kell.golden@outlook.com | com.kellgolden.Dwell |
| DwellableUITests | kell.golden@outlook.com | com.kellgolden.Dwell |

---

## Step 3️⃣ — Select Your iPhone as Build Target

### 3.1 Choose Device in Xcode

| Step | Action |
|---|---|
| 1 | In top toolbar, find scheme selector (shows "Dwellable") |
| 2 | Click device dropdown next to scheme |
| 3 | Look for your iPhone (e.g., "iPhone (16 Pro)") |
| 4 | **Select your iPhone** |

**Result:** Toolbar should show `Scheme: Dwellable | Device: iPhone 16 Pro`

### 3.2 Verify Connection

In Xcode: **Window → Devices and Simulators**

| Check | Expected | If Problem |
|---|---|---|
| iPhone listed | Under "Connected" section | Disconnect/reconnect USB |
| Status | "Paired" or "Connected" | Restart Xcode + iPhone |
| USB visible | Device shows in list | Check USB cable |

---

## Step 4️⃣ — Build and Run on Device

### 4.1 Build the App

| Action | Keyboard | What to See |
|---|---|---|
| Build | **Product → Build** | Cmd+B |
| Wait | Watch bottom panel | Progress bar fills |
| Verify | Check for | "Build Complete" message |

**If build fails:**

| Error | Cause | Fix |
|---|---|---|
| Red error in Signing & Capabilities | Missing signing certificate | Click blue "Fix Issue" button |
| Build fails after cleaning | Derived data corrupted | **Product → Clean Build Folder** (Cmd+Shift+K) |
| "Code signing denied" | Signing setup incomplete | Re-run Step 2 signing setup |

### 4.2 Run on Physical Device

| Step | Action | Expected |
|---|---|---|
| 1 | **Product → Run** (Cmd+R) | Build starts, watch console |
| 2 | App builds + signs | Takes 30–60 seconds |
| 3 | Install starts | See "Installing..." in console |
| 4 | App launches on iPhone | Icon appears, app opens |

**First launch may prompt:**

| Prompt | Action |
|---|---|
| "Untrusted Developer" appears | iPhone: **Settings → General → Device Management → kell.golden → Trust** |
| After trusting | Return to homescreen and tap Dwellable again |

---

## Step 5️⃣ — Verify Installation

| What to Do | Expected Result |
|---|---|
| 1. Look on homescreen | Find **Dwellable** app icon |
| 2. Tap app | App launches |
| 3. First screen | See **LoginView** (dark background, gold button) |

### 5.1 Test Basic Flow

| Action | Expected |
|---|---|
| **Login:** test@example.com / password123 | MomentsListView appears |
| **Check moments list** | See list of your moments |
| **Tap mic button** | Audio permission prompt appears |
| **Grant permission** | Mic is active (blue indicator) |

---

## Step 6️⃣ — Test Voice Recording (Key Feature)

This is what you **can't test** on simulator — physical device only! 🎙️

### 6.1 Record a Moment

| Step | Action |
|---|---|
| 1 | On MomentsListView, tap **mic button** (circular) |
| 2 | Speak clearly: *"This is a test of the Dwellable voice recording"* |
| 3 | Tap **Stop** button |
| 4 | See duration displayed (e.g., "0:12") |
| 5 | Wait for transcription to complete |
| 6 | See ReviewView with auto-transcribed text |
| 7 | Tap **Save** |

### 6.2 Verify Success

| Check | Expected |
|---|---|
| Moment appears in list | Yes, at top of MomentsListView |
| Transcript text | Matches what you said (quality varies) |
| Date/time | Correct timestamp shown |
| No crashes | App stays open |

---

## Step 7️⃣ — Test Offline Functionality (Critical)

### 7.1 Test Offline Save

| Step | Action |
|---|---|
| 1 | Disable network: **Settings → WiFi → OFF** |
| 2 | Alternative: **Settings → Airplane Mode → ON** |
| 3 | Go to MomentsListView |
| 4 | Tap mic button |
| 5 | Record: *"Testing offline"* |
| 6 | Tap Stop → Tap Save |

| Expected Result | Check |
|---|---|
| "Pending sync" message | Appears for 1.5 seconds |
| Moment in list | Still visible (not lost) |
| No error | App stays open |

### 7.2 Test Auto-Sync When Network Returns

| Step | Action |
|---|---|
| 1 | Enable WiFi: **Settings → WiFi → ON** |
| 2 | OR disable Airplane Mode |
| 3 | Wait 10 seconds |
| 4 | Watch moment in list |

| Expected Result | Check |
|---|---|
| Moment syncs | Automatically (no manual refresh) |
| Still in list | Moment persists |
| No sync message | Message disappears naturally |

---

## Step 8️⃣ — Test App Restart with Offline Data

### 8.1 Create Offline, Restart, Then Sync

| Step | Action |
|---|---|
| 1 | **Disable network:** Airplane Mode ON |
| 2 | **Create moment** (voice or text) |
| 3 | See "Pending sync" message |
| 4 | **Force-quit app:** Swipe up twice from bottom |
| 5 | **Re-launch:** Tap Dwellable icon |
| 6 | Check login status | Should still be logged in (Keychain) |
| 7 | Check moment | Offline moment still there |
| 8 | **Enable WiFi** → Moment syncs automatically |

| Expected Result | Check |
|---|---|
| Still logged in | No LoginView appears |
| Offline moment saved | Visible in list |
| Auto-sync works | Moment syncs without refresh |

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

Once you've deployed once via USB, deploy wirelessly:

### 10.1 Set Up Wireless

| Step | Action |
|---|---|
| 1 | **Xcode → Window → Devices and Simulators** |
| 2 | Right-click your iPhone |
| 3 | Select **Connect via Network** |
| 4 | Xcode uploads signing certificates |
| 5 | Wait for setup to complete |

### 10.2 Deploy Wirelessly

| Step | Action | Speed |
|---|---|---|
| 1 | Device appears in selector | Shows wireless icon |
| 2 | Select your iPhone | Appears in device dropdown |
| 3 | **Product → Run** (Cmd+R) | Initiates deployment |
| 4 | App deploys over WiFi | Slower than USB (but works) |

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


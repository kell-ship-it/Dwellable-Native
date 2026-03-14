# Quick Start: Layer 1 Testing

## Pre-Testing Setup

### 1. Build for Physical Device
```bash
cd /Users/kell/Desktop/Dwellable-Native/Dwellable
xcodebuild -scheme Dwellable -configuration Debug -arch arm64 \
  -sdk iphoneos -destination 'generic/platform=iOS'
```

### 2. Run on iPhone 13
- Connect iPhone 13 via USB
- Xcode → Select Device → Run
- OR: `xcodebuild ... -destination 'id=00008110-001A75863E38801E'`

---

## Quick Test Scenarios

### Scenario 1: 9-Minute Warning ⏱️ (5 min)
**Step 1:** Start recording
- Tap mic button in CaptureView
- Verify recording starts (mic turns red, timer shows)

**Step 2:** Wait until 9:00 mark (use CaptureView timer)
- Timer shows "9:00" or higher
- Look for warning message in **gold color**
- Message reads: "Hey, 60 seconds left in recording. Feel free to add another moment to supplement this."

**Step 3:** Verify warning only shows once
- Timer reaches 9:30, 9:45, 10:00
- Warning should remain visible (no flickering)

✅ **Pass:** Gold warning message appears at 9:00 mark

---

### Scenario 2: 10-Minute Auto-Stop ⏹️ (10 min)
**Step 1:** Start recording (same as Scenario 1)

**Step 2:** Wait until timer reaches 10:00
- Recording should **automatically stop**
- Error message appears in red
- Message reads: "You've reached the 10-minute capture limit. Start a new moment to continue."

**Step 3:** ReviewView appears with loading overlay
- Verify transcription starts automatically
- Wait for transcription to complete (use test audio if available)

✅ **Pass:** Recording stops at exactly 10:00, error message shows

---

### Scenario 3: Background During Recording 🔒 (3 min)
**Step 1:** Start recording
- Tap mic button, verify timer starts

**Step 2:** Record for 3 minutes (doesn't need full duration)

**Step 3:** Lock device (press power button)
- Recording should **stop immediately**
- Timer stops

**Step 4:** Unlock device
- ReviewView should appear automatically
- Transcription starts automatically
- 3-minute audio is ready to transcribe

✅ **Pass:** Recording stops on background, ReviewView appears, transcription starts

---

### Scenario 4: Background During Transcription 🎤 (5 min)
**Step 1:** Record 3-5 minutes of audio

**Step 2:** Review screen appears with "Processing your moment" overlay

**Step 3:** Lock device while transcribing
- Check iPhone console logs (connect via Xcode)
- Look for: `⚠️ [APP_BACKGROUND] App backgrounded during transcription`

**Step 4:** Unlock device after 5-10 seconds
- Check iPhone console logs
- Look for: `✅ [APP_FOREGROUND] App returned to foreground...`
- Verify partial or complete transcript appears in momentBody field

✅ **Pass:** App continues transcribing in background, partial results show on unlock

---

### Scenario 5: Cancel Mid-Transcription ❌ (3 min)
**Step 1:** Record 3-5 minutes of audio

**Step 2:** ReviewView appears with processing overlay

**Step 3:** Immediately tap back button (< 30 seconds into transcription)
- View navigates back to MomentsListView
- Check iPhone console logs
- Look for: `⚠️ [REVIEW_DISMISS] User closed view while transcribing`

**Step 4:** Wait 5 seconds for cleanup
- Check console logs
- Look for: `✅ [CLEANUP] Temporary audio file deleted: recording_XXXXX.m4a`

✅ **Pass:** Clean cancellation, no orphaned temp files

---

### Scenario 6: Save Incomplete Transcription 💾 (3 min)
**Step 1:** Record audio that might have recognition issues (soft audio, background noise)

**Step 2:** If transcription fails or is empty:
- Error message appears: "Dwellable didn't catch that..."
- momentBody field is empty

**Step 3:** Manually type some text in the moment field
- Type: "Manual notes for this moment"

**Step 4:** Tap Save button
- Button should be enabled (not grayed out)
- Moment saves successfully
- Navigation returns to MomentsListView

✅ **Pass:** Partial/manual text can be saved as moment

---

## Using Test Audio Files (For Automated Testing)

### Option 1: Manual Loading via File System
```bash
# Copy test audio to app's temp directory
cp /Users/kell/Desktop/Dwellable-Native/Dwellable/DwellableUITests/TestAssets/test_audio_10min.m4a \
   /tmp/test_audio.m4a
```

### Option 2: Using TestAudioHelper in Unit Tests
```swift
import XCTest
@testable import Dwellable

class TranscriptionTests: XCTestCase {
    func testTranscribe10MinAudio() {
        let url = TestAudioHelper.testAudioURL(duration: 600) // 10 minutes
        XCTAssertNotNil(url, "10-minute test audio should load")

        // Use url for transcription testing
    }
}
```

### Test Audio Files Available
| Duration | Filename | Size |
|----------|----------|------|
| 5 min | test_audio_5min.m4a | 8.3 MB |
| 10 min | test_audio_10min.m4a | 16 MB |
| 30 min | test_audio_30min.m4a | 49 MB |
| 1 hour | test_audio_1hour.m4a | 98 MB |
| 2.5 hours | test_audio_full.m4a | 257 MB |

---

## Console Log Reference

### What to Look For During Testing

```
Recording starts:
    ✅ [TRANSCRIPTION_START] File: recording_ABC.m4a, Size: 2.5 KB

Warning appears at 9 minutes:
    ⏱️ [WARNING] Recording approaching 10-minute limit

Recording hits limit:
    ⏱️ [LIMIT] Recording stopped at 10-minute limit

Transcription starts:
    ✅ [TRANSCRIPTION_TASK] Task created with streaming audio buffer

Partial results during transcription:
    📝 [PARTIAL_RESULT] Length: 150 chars

Successful transcription:
    ✅ [TRANSCRIPTION_COMPLETE] Length: 450 chars, Elapsed: 12.3s

Temp file cleanup:
    ✅ [CLEANUP] Temporary audio file deleted: recording_ABC.m4a

App backgrounding:
    ⚠️ [CAPTURE_BACKGROUND] App backgrounded during recording
    ⚠️ [APP_BACKGROUND] App backgrounded during transcription
    ✅ [APP_FOREGROUND] App returned to foreground

Errors:
    ❌ [TRANSCRIPTION_ERROR] Code: 216, Domain: kAFAssistantErrorDomain, Message: No speech detected
```

---

## Troubleshooting

### Issue: Warning doesn't appear at 9 minutes
- **Check:** Did you actually record for 9+ minutes?
- **Fix:** Use longer recording or lower your device volume to suppress background sounds
- **Verify:** Check console logs for "⏱️ [WARNING]" message

### Issue: Recording doesn't auto-stop at 10 minutes
- **Check:** Is the app running in foreground?
- **Fix:** Keep app in foreground during testing
- **Verify:** Check timer in CaptureView reaches 10:00

### Issue: Transcription hangs on 10-minute audio
- **Check:** Device has network connectivity (Speech Framework needs internet)
- **Fix:** Ensure WiFi or cellular is connected
- **Workaround:** Use shorter test audio (5min) first

### Issue: Temp files not deleting
- **Check:** Is there an error in transcription?
- **Fix:** Check console logs for "❌ [TRANSCRIPTION_ERROR]" or "⏱️ [TIMEOUT]"
- **Manual cleanup:** Delete /tmp/recording_*.m4a files manually

### Issue: Partial transcription shows wrong text
- **Check:** Is isIncompleteTranscription flag set correctly?
- **Fix:** Review logs for "⚠️ [REVIEW_DISMISS]" or "⚠️ [APP_BACKGROUND]"
- **Verify:** Partial results are from Speech Framework, not old cached text

---

## Success Criteria

| Feature | Test | Expected Result |
|---------|------|-----------------|
| 9-min warning | Record until timer shows 9:00 | Gold warning message appears |
| 10-min stop | Record until timer shows 10:00 | Recording stops, error message shows |
| Background during recording | Lock device while recording | Recording stops, ReviewView appears |
| Background during transcription | Lock device during processing | App continues, shows partial results on unlock |
| Mid-cancel | Close ReviewView while transcribing | Transcription cancels, temp file deleted |
| Save partial | Transcription fails, manually type text | Text saves as moment |
| Temp cleanup | Check /tmp/ directory | No recording_*.m4a files remain after save |

---

## Report Issues

If a test fails:
1. Note the scenario and exact step
2. Check console logs (attach relevant error messages)
3. Note device, iOS version, app build number
4. Include screenshots if helpful
5. Update testing checklist with findings

**Example Issue Report:**
```
Scenario: 9-Minute Warning
Status: ❌ FAILED
Step: Timer reaches 9:00
Expected: Gold warning message
Actual: No message appears
Console Log: No "⏱️ [WARNING]" message found
Device: iPhone 13, iOS 26.2
```

---

**Ready to test! Good luck! 🚀**

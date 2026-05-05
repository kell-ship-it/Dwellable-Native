# 🧪 Error Message Testing Guide

**Date:** March 10, 2026
**Purpose:** Verify all error scenarios display correct, friendly messages
**Testing Accounts:** 5 accounts to test across different scenarios

---

## Error Scenarios & Messages

### 1️⃣ Empty Recording (Too Short)

**How to trigger:**
- Tap mic button
- Immediately release (don't speak at all)
- Release to stop recording

**OLD Message:**
```
"Recording was too short. Please record at least 0.5 seconds of audio."
```

**NEW Message:**
```
"That was too quick. Try speaking for a bit longer and we'll catch it."
```

**Expected Result:** ✅ Shows error, no crash, "Retry Transcription" button appears

---

### 2️⃣ No Speech Detected (Silent Recording)

**How to trigger:**
- Tap mic button
- Make ambient noise or stay silent for 1+ second
- Release to stop recording
- App records but speech recognition finds no speech

**OLD Message:**
```
"No speech detected. Please speak clearly and try again."
```

**NEW Message:**
```
"Dwellable didn't catch that. Feel free to speak again."
```

**Expected Result:** ✅ Shows error on ReviewView, "Retry Transcription" button works

---

### 3️⃣ Transcription Timeout (Recording Too Long)

**How to trigger:**
- Tap mic button
- Speak continuously for 60+ seconds
- Wait for transcription to timeout

**OLD Message:**
```
"Transcription took too long. Please try a shorter recording."
```

**NEW Message:**
```
"That took a moment. Try again with a shorter recording."
```

**Expected Result:** ✅ Shows error after 60 second timeout

---

### 4️⃣ Network Error During Transcription

**How to trigger:**
- Tap mic button
- Speak for 2+ seconds
- Turn off WiFi/cellular DURING transcription (before it completes)
- Wait for error

**OLD Message:**
```
"Network error. Please check your connection and try again."
```

**NEW Message:**
```
"Network connection lost. Please check your connection and try again."
```

**Expected Result:** ✅ Shows network error if connection drops during transcription

---

### 5️⃣ Microphone Permission Denied

**How to trigger:**
- Open Settings → Dwellable → Microphone
- Disable microphone access
- Return to app
- Tap Capture → Tap mic button

**OLD Message:**
```
"Microphone permission denied. Enable it in Settings to record moments."
```

**NEW Message:**
```
"Microphone access is disabled. Enable it in Settings to capture moments."
```

**Expected Result:** ✅ Shows error instead of allowing recording

---

### 6️⃣ Speech Recognition Permission Denied

**How to trigger:**
- Open Settings → Privacy → Speech Recognition
- Disable Dwellable
- Return to app
- Attempt to record and transcribe

**OLD Message:**
```
"Speech recognition permission was denied. Please enable it in Settings."
```

**NEW Message:**
```
"Speech recognition is disabled. Enable it in Settings to continue."
```

**Expected Result:** ✅ Shows error when attempting transcription

---

### 7️⃣ Recording Start Failed

**How to trigger:**
- This is harder to trigger naturally (rare)
- Usually happens if audio session is busy
- Expected: If it occurs, error shows

**OLD Message:**
```
"Recording start failed: [technical error]"
```

**NEW Message:**
```
"Couldn't start recording. Try again in a moment."
```

**Expected Result:** ✅ Graceful error message (no technical details)

---

### 8️⃣ Audio Session Setup Failed

**How to trigger:**
- Rare scenario; usually happens if another app has exclusive audio access
- Try: Play music, then immediately try to record in Dwellable

**OLD Message:**
```
"Audio session setup failed: [technical error]"
```

**NEW Message:**
```
"Audio setup encountered an issue. Try again in a moment."
```

**Expected Result:** ✅ Graceful error without technical jargon

---

### 9️⃣ Speech Recognition Not Available

**How to trigger:**
- This shouldn't happen on modern devices
- Might occur on very old iOS versions
- Expected: If it occurs, friendly message shows

**OLD Message:**
```
"Speech recognition is not available on this device."
```

**NEW Message:**
```
"Speech recognition isn't available right now. Check your device settings."
```

**Expected Result:** ✅ Friendly, suggests checking settings

---

### 🔟 Recording Duration Max Reached (10 minutes)

**How to trigger:**
- Tap mic button
- Speak continuously (or let background noise record)
- After 10 minutes, recording stops automatically

**OLD Message:**
```
"Maximum recording duration (10 minutes) reached."
```

**NEW Message:**
```
"You've reached the 10-minute capture limit. Start a new moment to continue."
```

**Expected Result:** ✅ Recording stops, friendly message explains what happened

---

### 1️⃣1️⃣ Recording Encountered an Issue

**How to trigger:**
- Rare: Usually happens if audio file corruption occurs
- Expected: If error occurs, friendly message shows

**OLD Message:**
```
"Recording failed"
```

**NEW Message:**
```
"Recording encountered an issue. Try again."
```

**Expected Result:** ✅ Clear, non-technical message

---

### 1️⃣2️⃣ Generic Transcription Error

**How to trigger:**
- Speak something that causes transcription to fail
- Network glitches, speech framework errors, etc.
- May occur naturally during edge cases

**OLD Message:**
```
"Transcription failed. Please try again."
```

**NEW Message:**
```
"Dwellable didn't catch your capture. Feel free to articulate again or speak it once more."
```

**Expected Result:** ✅ Empathetic, brand-appropriate message

---

## 📋 Testing Checklist — 5 Accounts

### Account 1: `pilot@dwellable.com`
- [ ] Test Scenario 1 (Empty Recording)
- [ ] Test Scenario 2 (No Speech Detected)
- [ ] Test Scenario 5 (Microphone Permission)
- **Notes:** _______________________

### Account 2: `pilot1@dwellable.com`
- [ ] Test Scenario 1 (Empty Recording)
- [ ] Test Scenario 3 (Transcription Timeout)
- [ ] Test Scenario 6 (Speech Recognition Permission)
- **Notes:** _______________________

### Account 3: `pilot2@dwellable.com`
- [ ] Test Scenario 1 (Empty Recording)
- [ ] Test Scenario 4 (Network Error)
- [ ] Test Scenario 2 (No Speech Detected)
- **Notes:** _______________________

### Account 4: `pilot3@dwellable.com`
- [ ] Test Scenario 1 (Empty Recording)
- [ ] Test Scenario 10 (Max Duration Reached)
- [ ] Test Scenario 12 (Generic Error)
- **Notes:** _______________________

### Account 5: `tester1@example.com`
- [ ] Test Scenario 1 (Empty Recording)
- [ ] Test Scenario 7-9 (Rare scenarios if possible)
- [ ] Test Scenario 11 (Recording Issue)
- **Notes:** _______________________

---

## ✅ Verification Requirements

For **each scenario tested**, verify:

- ✅ **Error message appears** (use new message text, not old)
- ✅ **Message is readable and clear**
- ✅ **No technical jargon in the message**
- ✅ **"Retry Transcription" button appears** (for transcription errors)
- ✅ **Retry works on second attempt**
- ✅ **App doesn't crash**
- ✅ **Message tone is friendly/empathetic**

---

## 📸 Screenshot Requirements

For each error scenario tested, consider capturing:
1. Error message displayed on screen
2. "Retry Transcription" button interaction
3. Successful retry after error

This helps document that all error states work correctly.

---

## 🎯 Success Criteria

✅ **All 5 accounts successfully tested at least one scenario**
✅ **No crashes occur in any error state**
✅ **New messages display (not old messages)**
✅ **Retry functionality works**
✅ **Friendly tone is consistent throughout**

---

## Notes

- Some scenarios (like exact network timing) may be hard to reproduce consistently
- Focus on the core scenarios (1-3, 5-6) first
- Rare scenarios (7-9, 11) are acceptable if they don't naturally occur
- Document any unexpected behavior

---

**Status:** Ready for testing
**Build:** Latest commit with all error message updates
**Test Date:** [To be filled in]
**Tester Initials:** ___________


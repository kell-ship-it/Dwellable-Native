# BUG B-002 Fix Guide: Handle Empty Audio Recording

**Severity:** 🔴 CRITICAL (blocks voice recording)
**Found:** March 10, 2026 (Xcode testing)
**Fix Complexity:** Medium (2-3 file changes)

---

## The Problem

When a user:
1. Taps the mic button to start recording
2. Immediately stops recording (or releases without speaking)
3. The app crashes when trying to transcribe empty/silent audio

**Root Cause:** `TranscriptionManager` attempts to transcribe an empty or extremely short audio file without validating audio duration first.

---

## Where the Crash Happens

The crash likely occurs in `ReviewView` when it tries to transcribe:

```swift
// In ReviewView.swift - This is where it fails:
.onAppear {
    if let audioURL = audioURL {
        // TranscriptionManager tries to transcribe audioURL
        // But if audioURL is empty/silent, it crashes
        transcriptionManager.transcribe(audioURL: audioURL)
    }
}
```

---

## The Fix (3 Steps)

### Step 1: Add Audio Duration Validation

**File:** `TranscriptionManager.swift` (or similar)

Add a method to check if audio is valid:

```swift
func isValidAudio(url: URL) -> Bool {
    let asset = AVAsset(url: url)
    let duration = asset.duration

    // Reject audio shorter than 0.5 seconds
    return duration.seconds >= 0.5
}
```

### Step 2: Update TranscriptionManager.transcribe()

Modify the transcribe method to validate before processing:

```swift
func transcribe(audioURL: URL) async {
    // VALIDATE FIRST
    if !isValidAudio(url: audioURL) {
        await MainActor.run {
            isTranscribing = false
            error = "Recording was too short. Please record at least 0.5 seconds of audio."
        }
        return
    }

    // PROCEED WITH TRANSCRIPTION
    // ... existing transcription code ...
}
```

### Step 3: Update ReviewView to Handle Error

**File:** `ReviewView.swift`

The error should already display in the error UI, but ensure it's visible:

```swift
// In ReviewView - already exists, but verify:
if let errorMessage = transcriptionManager.error {
    VStack(spacing: 8) {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(Theme.error)
            Text(errorMessage)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Theme.error)
            Spacer()
        }

        Button(action: {
            transcriptionManager.error = nil
            // User can tap mic again to re-record
        }) {
            Text("Try Again")
        }
    }
}
```

---

## Testing the Fix

After implementing:

1. **Test 1: Empty Recording**
   - Tap mic
   - Immediately release (no speech)
   - Expected: User sees "Recording was too short" message
   - Result should be: ✅ No crash, clear error message

2. **Test 2: Short But Valid Recording**
   - Tap mic
   - Speak for 1+ second
   - Expected: Normal transcription flow
   - Result should be: ✅ Transcription works

3. **Test 3: Retry After Error**
   - Empty recording → error
   - Tap "Try Again" (or mic button)
   - Speak for 1+ second
   - Expected: Successful transcription on second attempt
   - Result should be: ✅ Works after retry

---

## Implementation Checklist

- [ ] Add `isValidAudio()` method to TranscriptionManager
- [ ] Update `transcribe()` to validate before processing
- [ ] Ensure error message is user-friendly
- [ ] Add "Try Again" button or auto-dismiss overlay
- [ ] Test empty recording scenario
- [ ] Test valid recording scenario
- [ ] Test retry after error
- [ ] Verify no crashes occur

---

## Files to Modify

1. **TranscriptionManager.swift**
   - Add `isValidAudio()` method
   - Update `transcribe()` method signature
   - Add error message for short recordings

2. **ReviewView.swift**
   - Verify error display exists
   - Ensure retry path works

---

## Alternative Approach (If Simple Fix Not Working)

If audio file is being created but transcription fails silently:

1. Add more detailed logging:
```swift
print("🎤 Audio file size: \(fileSize) bytes")
print("🎤 Audio duration: \(duration.seconds) seconds")
```

2. Check if speech framework has errors
3. Add more granular error handling in transcription request

---

## Priority

🔴 **CRITICAL** — Fix before participant beta testing

This bug will cause crashes during voice capture, which is the core feature.

---

**Estimated time to fix:** 15-30 minutes
**Risk level:** Low (clear error message, no data loss)
**Testing effort:** Medium (need to test empty and valid recordings)


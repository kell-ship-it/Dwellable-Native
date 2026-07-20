# Pillar 1: Capture (Voice + Text) — Strategy & Design Skeleton

**Status:** ✅ **COMPLETE** (Phase 1 Live on Build 107)  
**Last Updated:** May 5, 2026

---

## Design Summary

Users capture life moments in two ways:
1. **Voice-First (Primary):** Rotating prompts guide reflection while recording. Audio transcribed via Speech Framework (on-device, offline-capable).
2. **Text Fallback:** Typewriter-style text input for moments when audio isn't appropriate.

Both pathways feed into **Review View** where users confirm transcript and add optional "sense of Lord" reflection before saving.

---

## Core Design Decisions — Locked

### Capture UX
- **Primary:** Voice-first with rotating prompts (never prescriptive, always invitational)
- **Fallback:** Text input with minimal interface ("Begin here..." placeholder)
- **Recording UI:** Live duration timer, mic button center-focused, "Type instead" pill for quick switching
- **Prompts:** Rotate each session, never repeat consecutively

### Voice Transcription
- **Service:** Apple Speech Framework (offline, privacy-first, no API keys)
- **Validation:** Minimum 0.5s audio, reject blank/[BLANK_AUDIO] detections, minimum 2-word count
- **Error Handling:** User-friendly error message with retry button, never crash on silent audio
- **Performance:** Transcription within 60s timeout, loading state with animated bars

### Offline Capability
- **Moments saved locally** via LocalStorageManager when network unavailable
- **SyncManager monitors connectivity**, auto-retries failed uploads with exponential backoff
- **User sees:** "Pending sync" indicator during temporary network loss
- **Sync timing:** Immediate on network return, or manual refresh from list view

### Audio File Handling
- **Temporary storage:** Device temp directory while recording
- **Validation:** Check file duration before transcription (reject <0.5s)
- **Edge cases:** Handle user stopping before any speech (silent recording), very long recordings (10+ min auto-stop), pauses within speech (not filtered)

---

## UI Screens (Implemented)

| Screen | Purpose | Status |
|--------|---------|--------|
| **CaptureView** | Mic button + rotating prompts + "Type instead" pill | ✅ Live |
| **ReviewView** | Pre-filled transcript + "Sense of Lord" hint + Re-record/Save | ✅ Live |
| **TypeFlowView** | Full-screen text input + Save button | ✅ Live |
| **TranscribingView** | Loading state (5 animated bars + dot spinner) | ✅ Live |

---

## Technical Architecture

### Components

**AudioRecordingManager**
- Manages AVAudioRecorder lifecycle
- Records to `.m4a` format in temp directory
- Provides recording duration timer
- Handles 10-minute auto-stop with callback

**TranscriptionManager**
- Uses Speech Framework's SFSpeechURLRecognitionRequest
- Validates audio duration (>0.5s)
- Detects blank audio pattern (`[BLANK_AUDIO]`)
- Enforces minimum word count (2 words)
- Provides error messages for timeout/permission failures
- Singleton pattern with cached WhisperKit model

**LocalStorageManager**
- Saves pending moments to UserDefaults (unencrypted, offline queue)
- Saves synced moments from API (encrypted via T-062)
- Namespaced by userId to prevent multi-account conflicts

**SyncManager**
- Monitors network connectivity (NWPathMonitor)
- Queues offline moments locally
- Retries on connection restore with exponential backoff (10s, 20s, 40s...)
- Logs sync progress: "Pending sync" → "Synced"

---

## Data Model

**Moment** (Core)
```
id: UUID
userId: String (authenticated)
body: String (transcript or typed text)
senseOfLord: String (optional user reflection)
captureType: "voice" | "text"
createdAt: ISO8601
updatedAt: ISO8601
audioUrl: String? (S3 path or Edge Function endpoint, if voice)
```

**UsageEvent** (Analytics)
```
userId: String
eventType: "moment_created" | "app_opened"
momentType: "voice" | "text"
timestamp: ISO8601
```

---

## Considered & Rejected

| Decision | Reasoning |
|----------|-----------|
| **Structured capture forms (e.g., "What? Where? With whom?")** | Violates "unstructured capture" principle. Users should determine what matters about a moment. Forms create friction and prescriptive framing. |
| **Typing as primary, voice as fallback** | Spiritual formation in voice-first cultures emphasizes spoken word + presence. Voice captures tone, emotion, hesitation. Typing is secondary (still supported for accessibility). |
| **Mandatory prompts (user must answer rotating question)** | Prompts are invitational, never mandatory. User can ignore rotating prompt and just speak freely. |
| **Audio compression or cloud streaming during recording** | Offline-first principle requires local temp storage. No cloud dependency during capture. User controls upload timing via SyncManager. |
| **Auto-transcription via cloud service (Google Speech-to-Text, Azure, etc.)** | Privacy-first approach demands on-device transcription. Speech Framework (Apple native) chosen for privacy + offline capability. |
| **Photo/video capture alongside audio** | Out of scope for Phase 1. Capture is text + voice only. Rich media deferred to Phase 2+. |

---

## Open Questions

| Question | Status | Next Step |
|----------|--------|-----------|
| **Should users be able to capture multiple moments in rapid succession?** | Locked for P1 (yes, but no UI optimization) | Monitor for abuse patterns; add rate limiting if users spam capture |
| **How should we handle very long recordings (15+ min)?** | Locked for P1 (auto-stop at 10 min) | Validate 10-minute limit through user testing; adjust if users report interruption frustration |
| **Should users edit transcripts before saving?** | Deferred to Pillar 4 (Editing) | Design post-save editing flow; decide if edit history should be visible to user |
| **Should capture be available offline?** | Locked for P1 (yes, via LocalStorageManager) | Validate sync recovery handles large offline moment queues; test network restoration edge cases |
| **Should we support photo/video attachments?** | Deferred to Phase 2+ | Evaluate storage implications (S3 costs, device space) before deciding |
| **How should the app handle recording interruptions (calls, notifications)?** | In Progress — needs UX design | Design recovery flow: resume recording or restart? Auto-save draft? |

---

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| **Audio quality varies by device** | Speech Framework adapts to device audio input; users can re-record if unhappy |
| **Speech Framework accuracy in noisy environments** | App requests microphone permission; suggest quiet spaces; show transcript confidence |
| **10-minute auto-stop surprises users** | Timer visible during recording; soft notification when limit reached |
| **Blank audio crashes** | Validation checks for silence before transcription; graceful error message |
| **Offline moments lost on app uninstall** | Document: offline moments are device-local only; sync to cloud before deleting app |

---

## Completion Metrics (Phase 1 Validated)

✅ **Adoption:** 100% of Phase 1 users immediately adopted voice-first capture  
✅ **Capture Frequency:** 3-5 moments per user in 7-day pilot  
✅ **Audio Quality:** Transcriptions accurate >95% in normal environment  
✅ **Error Handling:** No crashes on edge cases (silent audio, very long recordings, network loss)  

---

## What's Next (Phase 2+)

- **Pillar 2 (Security & Privacy T-062):** Encrypt moments before upload (currently plaintext in transit)
- **Pillar 3 (Prayer):** Add Prayer/Prompts flows for captured moments
- **Pillar 4 (Editing):** Allow users to edit transcripts post-save
- **Pillar 5 (Search):** Semantic search across all moments (OpenAI + Hugging Face)
- **Pillar 6 (Formation Intelligence):** Detect themes from capture patterns

---

**Reference:** See PRD Section 2 — Pillar 1 for full requirements.

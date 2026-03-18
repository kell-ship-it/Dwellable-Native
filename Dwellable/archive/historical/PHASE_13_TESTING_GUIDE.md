# Phase 13: Environment, Audio Output & Battery Testing Guide

**Updated:** March 17, 2026
**Total Scenarios:** 10 (expanded from 6)
**Duration:** Approximately 90 minutes for full phase

---

## Scenario 13.6 — Battery Heat & Energy Assessment

### Why This Matters
- 10-minute recordings tax the device heavily (Speech Framework running continuously)
- WhisperKit transcription consumes battery on the neural engine
- Prolonged heat can trigger thermal throttling, slowing transcription
- Helps identify if app is suitable for sustained use

### How to Assess Battery Heat

#### Before Recording
1. Feel the back of the device near the camera — note baseline temperature
2. Check **Settings > Battery > Battery Health** (should be 90%+)
3. Note starting battery percentage
4. Close all background apps

#### During Recording
1. Record a full 10-minute moment using test audio or your voice
2. Monitor the battery percentage (watch for drain rate)
3. **Expected:** ~2-3% per minute is normal for active recording/speech processing
4. After 10 minutes: **20-30% total drain is expected**

#### After Recording (Immediate)
1. Stop recording and **immediately** check device temperature:
   - Feel the back of the phone (camera area and lower back)
   - Feel the sides and front
   - Normal: Warm to touch, comfortable to hold
   - **Concern:** Hot to touch, uncomfortable, might burn fingers
2. Open **Settings > Battery** and check:
   - "Dwellable" energy impact
   - Device temperature indicator (Settings > General > About if available)

#### Cooldown Period
1. Allow device to sit idle for 2-3 minutes
2. Feel temperature again — should drop noticeably
3. If temperature doesn't drop, device may have thermal protection issues

#### Transcription Quality Check
1. After recording, transcription should complete in **< 30 seconds**
2. If transcription takes > 60 seconds, device may be thermally throttled
3. Verify transcript accuracy (check console logs for processing time)

### Pass Criteria ✅
- Device becomes warm but **not uncomfortably hot**
- Battery drains 20-30% over 10 minutes
- Temperature returns to normal in 2-3 minutes
- Transcription completes in < 30 seconds
- No thermal shutdown warnings

### Red Flags 🚩 (Report as Bug)
- Device **hot to touch** (uncomfortable, may burn fingers)
- Excessive battery drain > 50% in 10 minutes
- Transcription takes > 60 seconds (thermal throttling)
- Device thermal shutdown warning appears
- Device automatically reduces screen brightness (power save)

---

## Scenarios 13.7–13.9 — Audio Output Testing

### Why This Matters
- Different audio outputs (headphones, Bluetooth, speaker) may affect:
  - Microphone sensitivity
  - Audio routing in the Speech Framework
  - Battery consumption (Bluetooth uses more power)
  - Transcription quality (feedback/echo from speakers)

### Test Setup

#### 13.7 — Wired Headphones
1. Connect **wired headphones or EarPods (3.5mm or Lightning)**
2. Record 2-minute moment
3. Check:
   - Audio routing (speak into microphone, not headphone mic if separate)
   - Transcript quality
   - No feedback/echo from headphone speaker
   - Microphone isolation is clean

#### 13.8 — Car Bluetooth
1. Connect device to **car audio system** (CarPlay or Bluetooth audio)
2. Record 2-minute moment
3. Check:
   - Audio input still comes from device mic (not car system)
   - Bluetooth power consumption (battery drain, device heat)
   - No interference from car audio system background
   - Transcript quality with potential car noise

#### 13.9 — No Bluetooth Connected
1. Ensure **all Bluetooth is OFF** (no AirPods, no car, no accessories)
2. Record 2-minute moment
3. Check:
   - App defaults to device speaker output
   - Microphone works cleanly
   - Baseline battery consumption (should be lowest)
   - Temperature baseline (should be lowest)

### Pass Criteria ✅
- Audio input consistent across all three scenarios
- Transcript quality comparable (no degradation due to audio output)
- No unexpected feedback, echo, or interference
- Battery drain increases with Bluetooth (expected)

### Red Flags 🚩
- Audio not being captured (silent transcripts)
- Feedback loop or echo in transcript
- Different transcript quality between wired/Bluetooth/speaker
- Bluetooth connection drops during recording

---

## Scenario 13.10 — Airplane Mode Long Recording

### Why This Matters
- **Offline transcription is a key feature** of Dwellable
- WhisperKit (on-device speech recognition) works WITHOUT network connection
- Airplane mode tests the offline-first architecture
- Ensures users can capture moments even when flying

### Test Steps

#### Setup
1. Ensure device is **fully charged** (battery test + airplane mode = high drain)
2. Enable **Airplane Mode** (Settings > Airplane Mode toggle ON)
   - Verify all network indicators disappear
   - Cellular icon → ✘
   - WiFi icon → ✘
   - Bluetooth symbol → ✘
3. Close any background apps that might try to sync

#### Recording
1. Open Dwellable and navigate to **Capture screen**
2. Record a **full 10-minute moment**
3. You can use:
   - Your own voice (recommended for authenticity)
   - Test audio file played through speaker
   - Conversation with another person

#### Transcription (Offline)
1. After recording stops, stay in Airplane Mode
2. Navigate to **ReviewView**
3. **Observe:** Transcription should begin immediately (no waiting for network)
4. **Expected:** Transcription completes in 20-45 seconds (WhisperKit offline processing)
5. Transcript should be **complete and accurate**

#### Verification
1. Edit/save the moment while still in Airplane Mode
2. Moment should save to **local storage** (SyncManager queue)
3. Turn off Airplane Mode
4. Verify moment **syncs to Supabase** after network returns
5. Check **MomentsListView** — moment should appear with correct transcript

#### Battery & Heat During Airplane Mode
- Record battery drain during the full 10-minute + transcription cycle
- Should be **similar to network-connected scenario** (Speech Framework dominates power use)
- This confirms transcription (not syncing) drives battery consumption

### Pass Criteria ✅
- Transcription starts **immediately** in Airplane Mode (no network wait)
- Transcript is accurate and complete
- Moment saves locally without network
- After disabling Airplane Mode, moment syncs to Supabase
- Moment appears correctly in MomentsListView

### Red Flags 🚩 (Report as Bug)
- Transcription hangs or times out in Airplane Mode
- Transcript is incomplete or corrupted
- Moment doesn't save without network
- After re-enabling network, moment fails to sync
- Error messages about network appear while in Airplane Mode

---

## Testing Timeline

### Quick Path (30 min)
- 13.1 Quiet environment (2 min)
- 13.3 WiFi long recording (10 min)
- 13.6 Battery heat check (10 min observation)
- 13.10 Airplane mode (8 min)

### Full Phase (90 min)
- 13.1 Quiet (2 min)
- 13.2 Background noise (2 min)
- 13.3 WiFi 10-min (10 min)
- 13.4 Cellular 10-min (10 min)
- 13.5 Network switch (8 min)
- 13.6 Battery heat (10 min)
- 13.7 Wired headphones (2 min)
- 13.8 Car Bluetooth (2 min)
- 13.9 No Bluetooth (2 min)
- 13.10 Airplane mode 10-min (15 min)
- Documentation/notes (15 min)

---

## Tools & Resources

### Temperature Assessment
- **Built-in:** Feel back of device (most accurate, takes practice)
- **iOS Settings:** Settings > General > About (may show "Device Temperature" on some iOS versions)
- **Console Logs:** Watch Xcode console during recording for CPU/GPU load
- **Battery Health:** Settings > Battery > Battery Health & Safety

### Battery Monitoring
- **Live:** Watch Settings > Battery during recording
- **Post-recording:** Settings > Battery > Battery Health
- **Console:** Xcode shows memory/CPU/GPU usage during development build

### Network Simulation
- **Disable WiFi:** Settings > WiFi toggle OFF
- **Cellular only:** Airplane Mode + toggle Cellular ON
- **Airplane Mode:** Settings > Airplane Mode toggle ON
- **Network conditions (advanced):** Xcode > Window > Devices > Simulator network settings

---

## Notes for Later Sessions

- Compare battery heat across iOS versions (some versions may be more efficient)
- Test with various Speech Framework models if user preference settings are added later
- Consider quantifying battery drain with automated battery measurement tools in future
- Monitor thermal logs during extended testing sessions for patterns

# Dwellable Testing Strategy — Manual + Automated

**Created:** March 17, 2026
**Status:** Ready for device testing

---

## One Comprehensive HTML File

**File:** `COMPREHENSIVE_TESTING_CHECKLIST.html`

### Two Sections:

#### 📱 Manual Testing (You) — 54 Scenarios, 14 Phases
**Total time to complete:** ~8-10 hours (spread over 4-7 days)

**Phases:**
1. Authentication (3) — Login, sign-up, persistence
2. Navigation (4) — Screen transitions, back button, tabs
3. Recording (5) — 5-sec, 9-min warning, 10-min auto-stop, cancel, app backgrounding
4. Transcription (5) — Quick transcription, edit, reject silence, mid-cancel, retry
5. Saving & Sync (4) — Online save, offline queue, auto-sync, optional fields
6. Viewing (3) — List display, detail view, scroll performance
7. Text Entry (3) — Short/long text, special characters
8. Audio Playback (3) — Play, pause/resume, different outputs
9. **Long Sessions (5 - CONSOLIDATED, NO REDUNDANCY):**
   - 10-min on WiFi with battery/heat monitoring
   - 10-min on cellular
   - 10-min on airplane mode (offline transcription)
   - Back-to-back 10-min sessions
   - Network switch during transcription
10. Audio Environment (4) — Quiet, background noise, audio isolation, transcription accuracy
11. Data Persistence (4) — Force-quit recovery, device restart, offline queue, background sync
12. UI/UX (4) — Orientation, buttons, text layout, empty state
13. Edge Cases (4) — Whitespace-only, Unicode/emoji, rapid save/delete, rapid recording
14. Reference Transcripts (3) — Compare 1-min, 5-min, 10-min recordings to what you actually said

---

#### ⚙️ Automated Testing (I can write) — 40 Scenarios, 6 Categories

These are tests I can write as XCUI/Unit tests once you confirm the app works correctly:

1. **API Integration (8)** — User registration, save, fetch, delete, audio upload/retrieval, batch sync, JWT refresh
2. **Database & RLS (6)** — Data isolation, cascade deletes, timestamp validation, UTF-8 handling, null fields
3. **Offline Sync (6)** — Queue logic, deduplication, order preservation, concurrent writes, edit during sync
4. **Error Handling (7)** — Network timeouts, invalid API responses, storage full, model load failure, corrupted audio, DB loss, timeout
5. **Edge Cases (7)** — Empty transcripts, single-word, [BLANK_AUDIO] stripping, emoji, very long text, nulls, duplicates
6. **Performance (6)** — Memory during recording, CPU during transcription, list with 100+ moments, sync speed, file cleanup, local storage bloat

---

## Testing Timeline (Recommended)

### Days 1-2: Phase 1-6 (Core functionality)
- Auth, navigation, basic recording, transcription, saving
- **Time:** ~3 hours

### Day 3: Phase 7-10 (Text, playback, long sessions, environment)
- Text entry, audio playback, 10-minute recordings (WiFi + cellular + offline), audio isolation
- **Time:** ~4 hours
- **Key:** This is where you'll test the 3x 10-minute recordings (consolidated into Scenario 9.4)

### Day 4: Phase 11-14 (Persistence, UI, edge cases, reference transcripts)
- Data recovery, UI/UX, edge cases, comparison testing
- **Time:** ~2-3 hours

### Days 5-6: Real-world use
- Use the app in normal journaling workflow
- Write actual moments, observe battery/heat, test in different locations
- **Time:** Ongoing, 10-15 min/day

### Day 7: Fix any issues, prepare for TestFlight
- Address any bugs found during real-world testing
- Then move to TestFlight

---

## Key Consolidations (No Redundancy)

### 10-Minute Recording Tests Consolidated

**Before:** 6 separate "10-minute" tests scattered across phases
- Phase 12.4: 10-min recording
- Phase 13.3: 10-min on WiFi
- Phase 13.4: 10-min on cellular
- Phase 13.6: 10-min battery heat
- Phase 13.10: 10-min airplane mode

**Now:** 5 distinct scenarios in Phase 9 (Long Recording Sessions)
- 9.1: 10-min WiFi + battery/heat/warning monitoring (comprehensive)
- 9.2: 10-min cellular (verify same behavior as WiFi)
- 9.3: 10-min airplane mode (offline transcription)
- 9.4: **Back-to-back 10-min sessions** (tests device heat accumulation, consistent quality)
- 9.5: Network switch during transcription (tests offline resilience)

**Result:** No redundancy. Each 10-minute test checks something different.

---

## Next Steps

1. **Open** `COMPREHENSIVE_TESTING_CHECKLIST.html` in a browser
2. **Choose tab:** 📱 Manual Testing
3. **Start with Phase 1:** Authentication
4. **Fill in Status** for each scenario (Pass/Fail/Bug)
5. **Add Notes** as you test
6. **After each phase, commit** results to remember where you left off
7. **Days 5-6:** Real-world journaling + observation
8. **Day 7:** Fix bugs, then TestFlight

---

## What I Can Test Automatically

Once you confirm the app works on device:
- API endpoint contracts
- Database RLS policies
- Offline sync logic
- Error recovery paths
- Data structure validation
- Performance benchmarks
- Memory/CPU during operations

I'll write XCUI tests that run automatically on every build.

---

## Why This Approach

- ✅ **No redundancy:** Each test checks something unique
- ✅ **Permanence:** Tests are repeatable, trackable, focus on core functionality
- ✅ **Real-world validation:** You test in actual journaling workflow, not in a test script
- ✅ **Efficient:** 54 manual tests cover all user-facing functionality
- ✅ **Scalable:** Automated tests catch regressions as code changes

---

## File Locations

- **Main checklist:** `testing/COMPREHENSIVE_TESTING_CHECKLIST.html` ← START HERE
- **This guide:** `testing/TESTING_STRATEGY.md`
- **Old files (for reference):** `TESTING_CHECKLIST_MASTER.html`, `PHASE_13_TESTING_GUIDE.md` (can delete after reviewing)

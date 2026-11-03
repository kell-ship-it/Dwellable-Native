# Your Testing Plan — March 17-22

**Your 6-day validation schedule before TestFlight**

---

## TODAY (March 17) — Phase 1: Quick Validation

### 7 Critical Path Tests (30 minutes)

**Build:**
```bash
⌘B in Xcode
→ Install on iPhone 16 Pro
```

**Run these 7 tests:**
1. ✓ Capture (5 sec) → Review → Save → View in list
2. ✓ Offline: Airplane mode → Save → Re-enable → Sync
3. ✓ 10-Minute Recording: Record full 10 min → Warning at 9:00 → Auto-stop at 10:00 → Save
4. ✓ Error Recovery: Record silence → Error → Retry → Record valid → Save
5. ✓ Backgrounding: Record 3 sec → Background app → Recording stops
6. ✓ Force-Quit Recovery: Save offline → Force-quit → Reopen → Enable network → Syncs
7. ✓ Text Entry: Type 200+ words → Save → View detail → All text displays

**Document:**
```
Journey 1: ✅ PASS
Journey 2: ✅ PASS
Journey 3: ✅ PASS
Journey 4: ✅ PASS
Journey 5: ✅ PASS
Journey 6: ✅ PASS
Journey 7: ✅ PASS
```

**Result:** All 7 pass? → Proceed to Phase 2 ✅

---

## Days 2-4 (March 18-20) — Phase 2: Real-World Usage

### Use the app naturally (2-3 hours/day)

**Create 15-20 actual moments:**
- Various durations: 30 sec, 2 min, 5 min, 10 min
- Various environments: Office, car, outside, quiet, noisy
- Various networks: WiFi, cellular, offline (airplane mode)

**Monitor:**
- ✓ App stability (crashes, hangs)
- ✓ Battery drain (% per session)
- ✓ Audio quality
- ✓ Transcription accuracy
- ✓ Performance (scrolling, saving)

**Document any issues:**
```
Issue: [Description]
When: [Time/condition]
Device state: [WiFi/cellular/offline, battery %, background/foreground]
Reproducible: [Yes/No]
Severity: [Critical | High | Medium | Low]
```

**Examples to watch for:**
- App crashes when switching to airplane mode
- Battery drains 10% per 10-min recording
- Transcript appears 1-2 seconds late
- Can't create 3 moments in quick succession
- Recording cuts off at exactly 10:00

**Result:** Document findings, note any critical issues

---

## Days 5-6 (Thursday/Friday) — Phase 3: Comprehensive Testing

### 57 Interactive Scenarios (4-5 hours)

**Open:**
```
testing/TESTING_CHECKLIST_MASTER.html
```

**Run through all 57 scenarios:**

**Tab 1: Overview**
- See all 14 phases, 57 scenarios
- Status: Most are ✅ COMPLETED or 🔄 IN PROGRESS
- You're completing the remaining ones

**Tabs 2-7: Phases 1-14**
- Each scenario has:
  - Steps to follow
  - Expected outcome
  - Input fields: Status (PASS/FAIL), Notes, Details
  - Screenshots if needed

**Quick highlights:**
- Phase 12: Recording durations (5s to 10min)
- Phase 13: Environment variations (WiFi, cellular, offline, battery heat, audio outputs)
- Phase 14: Reference transcripts (compare your recordings)

**Document for each scenario:**
```
Scenario #3.1: Record 30 seconds
Status: ✅ PASS  (or 🔴 FAIL)
Notes: Transcription appeared in 2 seconds, no issues
Details: (if needed)
```

**Result:** All 57 scenarios documented → Ready for TestFlight ✅

---

## Timeline

```
TODAY (March 17)
  └─ Phase 1: 7 Critical Path Tests
     Duration: 30 minutes
     Result: ✅ All pass? Proceed to Phase 2

TOMORROW-THURSDAY (March 18-20)
  └─ Phase 2: Real-World Usage
     Duration: 2-3 hours per day
     Result: Document any critical issues, fix if needed

THURSDAY EVENING / FRIDAY (March 21-22)
  └─ Phase 3: 57 Comprehensive Scenarios
     Duration: 4-5 hours
     Result: ✅ All pass? Ready for TestFlight

FRIDAY EVENING
  └─ Ship to TestFlight
     Build for release (not debug)
     Submit via Xcode/App Store Connect
```

---

## Success Criteria

**Phase 1 ✅**
- [ ] All 7 Critical Path Tests PASS
- [ ] No regressions from recent bug fixes

**Phase 2 ✅**
- [ ] Used app for 2-3 days with real moments (15-20 moments created)
- [ ] Tested various durations (30 sec to 10 min)
- [ ] Tested various environments (WiFi, cellular, offline)
- [ ] Documented any crashes/hangs
- [ ] Fixed any critical issues
- [ ] Battery drain acceptable

**Phase 3 ✅**
- [ ] All 57 scenarios documented in HTML
- [ ] PASS/FAIL recorded for each
- [ ] Notes added for any issues
- [ ] No critical blockers remaining

---

## What Happens After Phase 3

Once all 57 scenarios pass:

1. **Build for release**
   ```bash
   Xcode → Product → Build For → Any iOS Device (Release)
   ```

2. **Submit to TestFlight**
   - Xcode → Window → Organizer
   - Select app → Build
   - Distribute → TestFlight

3. **Add internal tester (you)**
   - Install TestFlight build on iPhone
   - Test for 1-2 days
   - If good → Release to external testers

4. **External testing**
   - Send to limited group of testers
   - Gather feedback
   - Fix any issues
   - Release to App Store (or continue TestFlight)

---

## Files You'll Use

**Phase 1:**
- Build on device
- Follow 7 tests from memory or CHANGE_MANAGEMENT_FRAMEWORK.md § Critical Path

**Phase 2:**
- Use app naturally
- Keep notes on any issues

**Phase 3:**
- Open: `testing/TESTING_CHECKLIST_MASTER.html`
- Fill in Status/Notes for each of 57 scenarios
- Screenshots if needed

---

## Questions During Testing?

- **Phase 1 test failing?** Stop, document, let me know
- **Issue found in Phase 2?** Document it, we'll prioritize (critical vs nice-to-fix)
- **Phase 3 scenario unclear?** Expand scenario in HTML, follow steps
- **Not sure if PASS or FAIL?** Document observation, we'll discuss

---

## Ready to Start?

Phase 1 starts: **TODAY (30 min)**

✅ **Ready to run 7 Critical Path Tests?**

Are you set up to:
- [ ] Open Xcode
- [ ] Build app (⌘B)
- [ ] Install on iPhone 16 Pro
- [ ] Run through 7 tests
- [ ] Document results

Let me know when you're ready to start!

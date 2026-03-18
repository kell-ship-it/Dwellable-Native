# Dwellable Layer 1 — User Activities Checklist

**Last Updated:** March 10, 2026, 8:45 PM
**Status:** Ready for 7-Day Dogfooding + Final QA
**Progress:** 45/61 tickets complete (74%)

---

## 📋 Overview

This document tracks **user-facing activities** (testing, QA, validation, and preparation) needed to complete **Layer 1 and prepare for launch**.

Build 104 is live on TestFlight. Analytics tracking is fully implemented. App is production-ready for your 7-day personal testing period.

---

## Phase 1: 7-Day Personal Dogfooding (March 10–17)

**Duration:** 7 days
**Objective:** Use the app daily in real-world scenarios; test analytics and tracking

### Phase 1.1 — Daily App Usage
- [ ] **Day 1–7: Create 15+ moments total**
  - [ ] Create 8+ voice moments across different contexts
  - [ ] Create 7+ text moments across different contexts
  - [ ] Mix offline and online usage (intentionally toggle airplane mode)
  - [ ] Use across 2+ devices if possible (e.g., iPhone + simulator)

### Phase 1.2 — Analytics Verification
- [ ] **Verify local event logging**
  - [ ] Create moments, check UserDefaults for `usage_events_<userId>` entries
  - [ ] Confirm events logged for both voice and text moments
  - [ ] Check app open/close events are captured

- [ ] **Test backend sync** *(T-037)*
  - [ ] Create 5+ moments, manually call sync
  - [ ] Verify events appear in Supabase `usage_events` table
  - [ ] Check Supabase dashboard: Run SQL query to view user's events
  - [ ] Test with 2+ accounts: Verify RLS policies (users can't see other users' events)

### Phase 1.3 — Subjective User Experience
- [ ] **Document personal impressions**
  - [ ] Ease of capturing moments (voice vs. text)
  - [ ] App responsiveness and loading times
  - [ ] Error message clarity
  - [ ] Overall workflow feel
  - [ ] Any friction points or confusing UI

**Output:** Screenshot/notes of analytics data (optional) + personal feedback

---

## Phase 2: QA Testing — Build 104 (March 17–20)

**Objective:** Comprehensive testing of error handling, performance, and UI consistency

### Phase 2.1 — T-033: Error Handling QA
- [ ] **Test network failures**
  - [ ] Enable airplane mode, try to save moment
  - [ ] Verify offline moment saves locally with "pending sync" indicator
  - [ ] Disable airplane mode, verify sync completes

- [ ] **Test transcription errors**
  - [ ] Try voice recording with no speech (silent recording)
  - [ ] Verify friendly error message appears (not a crash)
  - [ ] Try recording with background noise
  - [ ] Test recording interrupted mid-way

- [ ] **Test authentication errors**
  - [ ] Try login with wrong password
  - [ ] Verify error message: "Email or password is incorrect"
  - [ ] Try login with empty fields
  - [ ] Verify form validation error

- [ ] **Test save failures**
  - [ ] Create moment while network is degraded
  - [ ] Verify retry button works
  - [ ] Check error message copy matches design

**Documentation:** Record any error messages that feel unclear or unhelpful

### Phase 2.2 — T-034: Performance QA
- [ ] **Test app launch time**
  - [ ] Time app startup (from home screen to app visible)
  - [ ] Note if any slowness during login
  - [ ] Check if moments list loads promptly on sign-in

- [ ] **Test moment list scrolling**
  - [ ] Create 50+ moments (or use test account with many)
  - [ ] Scroll through list rapidly
  - [ ] Verify smooth scrolling, no jank or frame drops
  - [ ] Test on real device (not just simulator)

- [ ] **Test background activity**
  - [ ] Create moment while downloading large file
  - [ ] Record voice moment while background music playing
  - [ ] Verify no stuttering or interference

**Output:** Observations on responsiveness; note any slowness

### Phase 2.3 — T-035: UI/UX QA
- [ ] **Design consistency (colors, typography, spacing)**
  - [ ] Verify gold button color (#C9B27C) matches prototype
  - [ ] Check that all text uses Theme font sizes (not hardcoded)
  - [ ] Verify spacing between elements matches design
  - [ ] Compare against prototype-v1.html side-by-side

- [ ] **Accessibility**
  - [ ] Test keyboard navigation (tab between fields)
  - [ ] Verify button tap targets are at least 44x44pt
  - [ ] Check text contrast in light and dark modes
  - [ ] Test with accessibility features enabled (if available)

- [ ] **Edge cases & form handling**
  - [ ] Type very long moment (500+ characters)
  - [ ] Type very long "sense of lord" field
  - [ ] Leave fields empty, try to save (verify validation)
  - [ ] Test keyboard dismissal (tap outside field)

- [ ] **Empty states**
  - [ ] View empty moment list as new user
  - [ ] Verify "No moments yet" message displays
  - [ ] Check empty state layout and messaging

- [ ] **Loading indicators**
  - [ ] Verify spinner appears during fetch
  - [ ] Verify loading state during save
  - [ ] Check spinner is visible (not too subtle)

**Output:** Screenshots of any inconsistencies; note design mismatches

---

## Phase 3: Prototype Demo Preparation (March 20–22)

### Phase 3.1 — T-036: Create Layer 1 + Layer 2 Demo
- [ ] **Prepare demo script**
  - [ ] Define talking points for Layer 1 features
  - [ ] Define Layer 2 scope (EditMomentView, SearchView, etc.)
  - [ ] Plan 5–10 minute demo flow
  - [ ] Prepare test data (moments, multiple accounts)

- [ ] **Demo on physical device**
  - [ ] Test demo flow end-to-end on iPhone
  - [ ] Create/edit/view moments smoothly
  - [ ] Show offline functionality
  - [ ] Highlight voice capture workflow

- [ ] **Record demo walkthrough** (optional)
  - [ ] Screen recording of full flow
  - [ ] Include voice-over explaining features
  - [ ] Export to mp4 for sharing with partners

**Output:** Demo script + recorded walkthrough (or notes for live demo)

---

## Phase 4: App Store Submission Prep (March 22–25)

### Phase 4.1 — T-026: Prepare for App Store Submission
- [ ] **Create privacy policy**
  - [ ] Document what data is collected (moments, usage events, email)
  - [ ] Explain how data is stored and transmitted
  - [ ] Add to app Settings/SettingsView + website
  - [ ] Ensure GDPR/CCPA compliant

- [ ] **Create terms of service**
  - [ ] Define acceptable use
  - [ ] Clarify liability and warranty
  - [ ] Add to app Settings/SettingsView + website

- [ ] **Prepare app store assets**
  - [ ] Write app description (clear, benefit-focused)
  - [ ] Create 2–3 marketing screenshots showing key features
  - [ ] Write version release notes
  - [ ] Verify app icon renders correctly

- [ ] **Test App Store build process**
  - [ ] Build archive in Xcode
  - [ ] Upload to App Store Connect
  - [ ] Verify bundle ID and signing certificates
  - [ ] Run App Store validation (no errors)

- [ ] **Determine pricing** (if applicable)
  - [ ] Free tier or premium model?
  - [ ] In-app purchases?
  - [ ] Document pricing strategy

**Output:** Privacy policy + terms in app + App Store draft submission ready

---

## Phase 5: Final Validation (March 25–28)

### Phase 5.1 — Regression Testing
- [ ] **Test all core workflows**
  - [ ] Sign up → sign in → create moment → view in list
  - [ ] Record voice moment → review → save → view
  - [ ] Type text moment → save → edit (if available) → delete
  - [ ] Sign out → sign back in → moments still visible

- [ ] **Cross-device testing**
  - [ ] Test on 2+ physical devices (if available)
  - [ ] Test on simulator
  - [ ] Verify offline sync across devices

- [ ] **Browser back-compat** (if web version exists)
  - [ ] Test Supabase dashboard access from browser
  - [ ] Verify analytics data is queryable

**Output:** Final test report + sign-off

---

## 📊 Progress Tracker

| Phase | Title | Status | Due |
|-------|-------|--------|-----|
| 1 | 7-Day Dogfooding | 🔲 Pending | Mar 17 |
| 2.1 | Error Handling QA | 🔲 Pending | Mar 18 |
| 2.2 | Performance QA | 🔲 Pending | Mar 19 |
| 2.3 | UI/UX QA | 🔲 Pending | Mar 20 |
| 3.1 | Demo Prep | 🔲 Pending | Mar 22 |
| 4.1 | App Store Prep | 🔲 Pending | Mar 25 |
| 5.1 | Final Validation | 🔲 Pending | Mar 28 |

---

## 🎯 Success Criteria

**Phase 1 Complete:** 15+ moments created, analytics data visible in Supabase, personal feedback captured

**Phase 2 Complete:** All error messages are clear, app performs smoothly with 50+ moments, design matches prototype

**Phase 3 Complete:** Demo script ready, Layer 1 + Layer 2 scope clearly communicated

**Phase 4 Complete:** Privacy policy + terms drafted, App Store bundle ready for review

**Phase 5 Complete:** All core workflows verified, no regressions, sign-off on launch readiness

---

## 📝 Notes

- **Build 104 live on TestFlight** — Install on physical device for testing
- **Analytics integrated** — Events logging to UserDefaults; sync to Supabase ready (manual or integrated)
- **7-day personal use** — This is your primary feedback loop before partner conversations
- **Feedback channels:**
  - Document issues in TICKETS.md (create new tickets as needed)
  - Screenshot errors/inconsistencies for reference
  - Note UX friction points for Layer 2 improvements

---

## 📞 Quick Reference

**Key Files:**
- `TICKETS.md` — Full ticket registry
- `LAYER_1_USER_ACTIVITIES.md` — This file
- `TESTING_CHECKLIST_MASTER.html` — Detailed testing protocols (from Build 104)

**Key Endpoints:**
- Supabase Dashboard: https://app.supabase.com (login to view usage_events table)
- TestFlight: TestFlight app on iPhone (Build 104)
- App Code: `/Users/kell/Desktop/Dwellable-Native/Dwellable/`

---

**Last Updated:** March 10, 2026, 8:45 PM
**Next Review:** After Phase 1 completion (March 17)

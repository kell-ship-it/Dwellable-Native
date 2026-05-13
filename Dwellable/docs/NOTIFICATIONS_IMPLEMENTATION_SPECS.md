# Pillar 8: Notifications — Implementation Specs (T-083–T-091)

**Status:** Ready for implementation  
**Total Effort:** ~100–150 hours (3–4 weeks)  
**Dependencies:** Pillar 0 (Onboarding), Pillar 3 (Prayer/Dwelling), T-018 (Analytics)  
**Blocker:** Pillar 3 must be complete and compelling before MVP ships

---

## Overview

Pillar 8 implements a sparse, behavior-gap-aware notification system that invites users back to dwelling after they complete onboarding, capture a moment, pray, and return to journal. The system is built on a **funnel-stage model** (A → B1 → B2 → C → D) where each stage triggers specific notifications based on the user's deepest action.

**MVP Strategy:**
- Phase 1: Infrastructure (FCM setup, scheduling, analytics)
- Phase 2: Segmentation (funnel stage logic)
- Phase 3: Generic templates (activity-based, no personalization)
- Phase 4: Timing optimization (send when users are likely to open)

**Post-MVP (Phase 2 roadmap):**
- Formation Intelligence-triggered notifications (topic-aware, based on pattern detection)
- A/B testing on cadence and messaging tone
- Advanced timing (ML-driven send time optimization)

---

## Tickets: Detailed Specs

### T-083: Setup Firebase Cloud Messaging for iOS

**Acceptance Criteria:**
- [ ] Firebase project created and linked to Dwellable iOS app
- [ ] APNs key uploaded to Firebase Console
- [ ] FCM token successfully registered on app startup and stored in Supabase `user_profiles.fcm_token`
- [ ] Silent notification delivery verified (no alert shown if app is backgrounded)
- [ ] Token refresh logic implemented (re-register if token changes)
- [ ] Local persistence of FCM token with fallback if Supabase write fails

**Technical Details:**
- Use Firebase SDK (`firebase-ios-sdk`)
- Request user permission for push notifications during onboarding (P0 → T-086 owns the UI)
- Store FCM token in `user_profiles` table; include `token_updated_at` timestamp for debugging
- Implement token refresh callback (`didRefreshRegistrationToken()`)
- Handle token fetch failures gracefully (no error shown to user, logs to analytics)

**Integration Points:**
- Onboarding (P0): Request permission step includes "We'll send gentle invitations"
- Settings (T-086): Enable/disable toggle controls `is_notifications_enabled` in profiles
- Analytics (T-088): Log FCM token registration success/failure

**Testing Strategy:**
- Register token manually, verify appears in Supabase
- Disconnect network, register token, verify retries
- Revoke push permission via iOS Settings, verify silent failure handling
- Multiple app reinstalls, verify token refresh works

**Effort:** 6–8 hours  
**Dependencies:** None

---

### T-084: Build Notification Scheduling Engine (Cadence Logic)

**Acceptance Criteria:**
- [ ] Scheduling service created that respects stage-specific cool-off periods
- [ ] Weekly send window implemented for B1, B2, C1, D (1 push per 7 days max)
- [ ] Monthly send window for C3 (1 push per month max)
- [ ] Cool-off resets after user completes the action (e.g., prays → resets B1, advances to C)
- [ ] No double-sends in a single window (idempotent scheduling)
- [ ] Server-side cron job triggers nightly to check eligible users and queue notifications

**Technical Details:**
- Backend service: `NotificationScheduler` (runs nightly or every 4 hours)
- Database columns to add to `user_profiles`:
  - `current_stage` (A, B1, B2, C1, C2, C3, D)
  - `last_push_sent_at` (timestamp of last notification, per-user)
  - `stage_updated_at` (when they advanced to current stage)
  - `last_unprayed_capture_id` (for B1 cool-off logic)
- Query logic:
  - For B1: Find users in stage B1 whose `last_push_sent_at` was >7 days ago
  - For C1: Find users in stage C1 whose `last_push_sent_at` was >7 days ago
  - For D: Find users in stage D; send 1x/week (same window as B1)
- Queue notifications into `notification_queue` table for T-088 (analytics) to track delivery

**Integration Points:**
- T-085: Funnel stage logic feeds stage assignments
- T-087: Templates are fetched based on stage
- T-088: Queue records for analytics
- T-089: Testing validates push delivery

**Testing Strategy:**
- Backdate a user's `last_push_sent_at` to 8 days ago, run scheduler, verify push queued
- Schedule two pushes for same user within 24 hours, verify only one fires
- Verify cool-off resets when user completes action (e.g., prays)
- Load test: queue 10K pushes in one run, verify no duplicates

**Effort:** 8–10 hours  
**Dependencies:** T-083, T-085

---

### T-085: Build Funnel Stage Logic (A, B1, B2, C, D) for User Segmentation

**Acceptance Criteria:**
- [ ] Stage assignment logic implemented server-side
- [ ] Stages correctly assigned based on deepest action:
  - A0: Incomplete onboarding
  - A: Completed onboarding, no captures yet
  - B1: Captured, never prayed
  - B2: Captured, responded to prompt, never prayed
  - C1: Prayed, never returned to journal
  - C2: Journaled, still no prayer (edge case; treated as C for MVP)
  - C3: Quiet 14+ days (dormant)
  - D: Actively dwelling (prayer, prompt response, or journal return within last 7–10 days)
- [ ] Stage assignment updated on each event (capture, prayer, journal return, prompt response)
- [ ] `user_profiles.current_stage` updated in database
- [ ] No user advances backward (one-way funnel)
- [ ] B2 logic: User gets 1 prompt response, doesn't pray → stage B2 (softer urgency than B1)

**Technical Details:**
- Events trigger stage update:
  - `moment_captured` → B1 (if current < B1)
  - `prayer_completed` → C (if current = B1/B2)
  - `journal_returned` → C1 (if current = C)
  - `prompt_responded` → B2 (if current = B1, don't advance past B1)
- Query-time logic (for T-084 scheduler):
  - `SELECT * FROM user_profiles WHERE current_stage = 'B1' AND last_push_sent_at < NOW() - 7d`
- Dormancy logic (for C3):
  - Cron job daily: check `last_activity_at`, if >14 days, move to C3
  - Reset to D if any activity occurs

**Integration Points:**
- T-018 / T-019: Analytics/UsageTracker sends events to trigger stage updates
- T-084: Scheduler uses stage to determine eligibility
- T-086: Settings UI can display current stage (debug info)
- T-088: Analytics logs stage transitions

**Testing Strategy:**
- Create test user, verify initial stage A0
- Complete onboarding, verify moves to A
- Capture moment, verify B1
- Prompt response (if applicable), verify B2
- Prayer, verify C
- Journal return, verify C1
- 14+ days inactivity, verify C3 (if not active)
- Any activity after C3, verify returns to D
- Verify no backward movement (C never → B)

**Effort:** 6–8 hours  
**Dependencies:** T-018, T-019 (analytics events must exist)

---

### T-086: Build Settings UI for Notification Preferences

**Acceptance Criteria:**
- [ ] Settings view includes notification section
- [ ] Toggle: "Enable notifications" (default on)
- [ ] Dropdown: Frequency preference (Default / Sparse / Off)
  - Default: Stage cadence as per Volume Map
  - Sparse: 1/month max across all stages
  - Off: No push (in-app nudges remain)
- [ ] Changes persist to `user_profiles.notification_settings`
- [ ] Onboarding step added: "Enable notifications" with opt-out option
- [ ] Permission request shown first (iOS system dialog)
- [ ] Current status displayed: "Notifications are on" or "Off"

**Technical Details:**
- Add fields to `user_profiles`:
  - `is_notifications_enabled` (boolean, default true)
  - `notification_frequency` (enum: default, sparse, off)
  - `notification_settings_updated_at` (timestamp)
- Settings view:
  - Toggle switch: Updates `is_notifications_enabled`
  - Dropdown: Updates `notification_frequency`
  - Current stage display (for transparency): "You're in stage B1 (captured, waiting to pray)"
  - Last notification received: "Most recent: 3 days ago"
- Onboarding integration (Pillar 0):
  - After permission request, show "Enable notifications?" with brief explanation
  - Default: enabled (opt-out model)
  - User can disable in onboarding without blocking progress

**Integration Points:**
- T-083: Permission request and FCM token management
- Pillar 0: Onboarding enables notifications step
- T-084: Scheduler respects `is_notifications_enabled` flag
- T-088: Analytics logs frequency preference changes

**Testing Strategy:**
- Verify toggle persists across app restart
- Verify frequency dropdown changes take effect
- Verify "Sparse" mode reduces B1 sends to 1/month
- Verify "Off" mode prevents all push (in-app nudges still show)
- Test onboarding flow: permission → enable prompt → confirmation

**Effort:** 4–6 hours  
**Dependencies:** T-083, T-010 (SettingsView should already exist; add notification section)

---

### T-087: Write Generic Notification Templates (4–5 per Stage)

**Acceptance Criteria:**
- [ ] Stage A: 2–3 variants ("Hey, you've downloaded Dwellable!")
- [ ] Stage B1: 2–3 variants ("Hey, how are you feeling since that moment?" → CTA: "Let's pray about it")
- [ ] Stage B2: 2–3 variants (softer tone, "Reflecting on what you felt?")
- [ ] Stage C: 2–3 variants ("A prayer from earlier — ready to go deeper?")
- [ ] Stage D: 2 variants (locked MVP versions):
  - "Hey, how are you feeling since that prayer?" → "Let's capture what you're processing"
  - "A prayer from a few days ago — ready to go deeper?" → "Let's pray about what you've processed"
- [ ] All copy is activity-based (references action type, not content)
- [ ] No personalization for MVP (Post-MVP: topic-aware)
- [ ] Copy tone is invitational, not productivity-focused

**Technical Details:**
- Store templates in `notification_templates` table:
  - `id`, `stage`, `variant_index`, `body`, `cta_text`, `cta_route`, `created_at`
- Routes (what CTA button does):
  - B1/B2 → Open CaptureView (start new capture)
  - C → Open MomentDetailView for the prayer moment
  - D → Open CaptureView or MomentDetailView (alternating)
- Template selection: Choose random variant per user per send (A/B testing baseline)

**Variant Examples:**

**Stage A (no captures):**
- Variant 1: "You're here. That took something. Welcome."
- Variant 2: "Dwellable is a space for your inner world. Ready to capture what's on your heart?"

**Stage B1 (unprayed capture):**
- Variant 1: "Hey, how are you feeling since you captured that moment? Let's pray about it."
- Variant 2: "That moment you captured — your heart is still there. Ready to pray?"
- Variant 3: "You wrote something down. What does your heart need right now?"

**Stage B2 (prompted, no prayer):**
- Variant 1: "You reflected on a prompt. What's brewing in you?"
- Variant 2: "Your reflection matters. Ready to take it deeper?"

**Stage C (prayed, quiet):**
- Variant 1: "A prayer from a few days ago — ready to go deeper?"
- Variant 2: "You prayed about something real. How are you now?"
- Variant 3: "Your prayer is still there. Anything new to reflect on?"

**Stage D (actively dwelling):**
- Variant 1: "Hey, how are you feeling since that prayer? Let's capture what you're processing."
- Variant 2: "A prayer from a few days ago — ready to go deeper? Let's journal about what you've processed."

**Integration Points:**
- T-085: Template selection based on current stage
- T-084: Templates fetched at send time
- T-088: Analytics logs template variant shown (for A/B analysis)

**Testing Strategy:**
- Verify each stage has ≥2 variants
- Verify random variant selection (check logs for distribution)
- Verify CTA routes work (tap "Let's pray" → opens CaptureView)
- Verify tone is invitational, not "streaky" (no "3-day prayer streak!")
- Read 3–5 templates per stage, verify activity-based (no moment content referenced)

**Effort:** 3–4 hours  
**Dependencies:** T-085

---

### T-088: Integrate Analytics Logging for Notification Events

**Acceptance Criteria:**
- [ ] Analytics event created for FCM delivery (`notification_delivered`)
- [ ] Analytics event for push tap (`notification_tapped`, with destination: prayer, capture, or journal)
- [ ] Analytics event for in-app nudge impression (`nudge_shown`)
- [ ] Analytics event for stage transition (`stage_changed`, with from/to)
- [ ] Frequency preference change logged (`notification_settings_changed`)
- [ ] All events include: user_id, timestamp, stage, template_variant
- [ ] Events queryable in analytics dashboard for CTR calculation (delivery ÷ taps)
- [ ] Retention metrics computable: "% of notified users returning within 7 days"

**Technical Details:**
- Event schema:
  ```json
  {
    "event_type": "notification_delivered|notification_tapped|nudge_shown|stage_changed|notification_settings_changed",
    "user_id": "uuid",
    "timestamp": "ISO-8601",
    "stage": "A|B1|B2|C1|C3|D",
    "destination": "prayer|capture|journal|null",
    "template_variant": "int",
    "details": { }
  }
  ```
- Emit events from:
  - T-083: On FCM token registration
  - T-084: When notification queued (delivery event)
  - MomentsListView/CaptureView tap handler: On notification tap
  - T-085: On stage transition
  - T-086: On settings change

**Integration Points:**
- T-018 / T-019: UsageTracker service sends events
- Analytics dashboard (post-MVP): Compute CTR, retention, frequency distributions

**Testing Strategy:**
- Send test notification, verify `notification_delivered` event logged
- Tap notification, verify `notification_tapped` event includes destination
- Change stage via action, verify `stage_changed` event
- Verify event query returns user events by date range
- Compute CTR: delivered ÷ tapped, verify >0% (baseline)

**Effort:** 4–6 hours  
**Dependencies:** T-083, T-085

---

### T-089: Test Notification Delivery on Real Devices (iPhone)

**Acceptance Criteria:**
- [ ] Notifications successfully deliver to real iPhone (not simulator)
- [ ] Push notification appears with correct title/body
- [ ] Tapping notification opens correct screen (CaptureView, MomentDetailView, etc.)
- [ ] Silent notification delivery works (no alert shown if app backgrounded, but delivery event logged)
- [ ] 100+ concurrent pushes to same user don't cause failures or duplication
- [ ] Notification dismissal tracked (user sees, then dismisses without tapping)
- [ ] Metrics logged correctly for each notification
- [ ] Handle edge cases: app in foreground, app closed, low battery, network interrupted

**Technical Details:**
- Set up TestFlight beta or ad-hoc distribution
- Test users: ≥5 real devices (mix of iPhone models if possible)
- Test scenarios:
  1. App in foreground + push arrives → notification appears
  2. App in background + push arrives → notification appears in lock screen
  3. App closed + push arrives → notification appears, tap opens app
  4. User taps notification → correct screen opens, metrics logged
  5. 10 pushes to same user in 1 minute → only 1 or queued (no crash)
  6. Permission denied → graceful degradation (no push, no error)
- Manual test of each stage's notification (A, B1, B2, C, D)

**Integration Points:**
- T-083: FCM delivery
- T-084: Scheduler queues notifications
- T-085: Stage logic determines eligibility
- T-088: Analytics validates metrics
- T-089: Pre-TestFlight gate (must pass before beta)

**Testing Strategy:**
- Checklist: One test per stage × 3 variants = 15+ manual tests
- Metrics verification: Deliver 10 pushes, verify 10 `notification_delivered` events, ≥8 `notification_tapped`
- Stress test: Queue 100 pushes in one nightly batch, verify no failures or duplicates
- Permission scenario: Disable push in iOS Settings, verify silent failure (no app crash)

**Effort:** 6–8 hours  
**Dependencies:** T-083, T-084, T-085, T-086, T-087, T-088

---

### T-090: Optimize Send Time Based on User Behavior

**Acceptance Criteria:**
- [ ] Analyze each user's app open times (from analytics)
- [ ] Send notifications during their typical "active window" (±2 hours of their median open time)
- [ ] Timezone-aware sending (respect user's local time)
- [ ] Default: 8 AM local time (if no usage data available)
- [ ] A/B test: fixed time (8 AM) vs. smart time (user-optimal) for future iterations
- [ ] Opt-in for Post-MVP: Machine learning to predict optimal send time per user

**Technical Details:**
- Query: `SELECT user_id, timezone, app_open_times FROM analytics WHERE user_id = $1 AND date > NOW() - 30d`
- Compute: Median hour of app opens
- Store: `user_profiles.preferred_send_hour` (0–23, in user's timezone)
- Fallback: 8 AM if <5 app opens in past 30 days
- Scheduler (T-084) adjusts send window: Instead of "anytime in the week," send at `preferred_send_hour` on a specific day (e.g., Thursday)

**Integration Points:**
- T-084: Scheduler queries `preferred_send_hour` and adjusts queue time
- T-018: App open times logged via analytics
- Post-MVP: ML model for send time optimization

**Testing Strategy:**
- Create test user with known open times (e.g., 7–8 AM on weekdays)
- Compute preferred send hour, verify = 7 or 8
- Queue notification for test user, verify sends at their preferred hour
- Verify timezone logic: User in PST, preferred hour 8 → send at 8 AM PST, not UTC
- Verify fallback: New user with <5 app opens → default to 8 AM

**Effort:** 4–6 hours  
**Dependencies:** T-084, T-085 (usage data)

---

### T-091: Polish Edge Cases, Opt-Out Flows, Error Handling

**Acceptance Criteria:**
- [ ] Auto-suppression implemented: 3 consecutive no-clicks → pause 2 weeks → retry
  - Logic: Track `pushes_not_clicked_consecutively` counter, reset on tap
  - After 3 no-clicks, set `notification_paused_until` = now + 14 days
  - Scheduler skips user if paused
- [ ] Permission revocation handled: If user disables push in iOS Settings, detect on app open and log analytics event
- [ ] Network failure retry: If FCM send fails, retry up to 3 times with exponential backoff (1s, 4s, 16s)
- [ ] Orphaned tokens handled: If notification send fails with "invalid token" error, mark token as invalid and request re-registration
- [ ] Rate limiting: No more than 1 push per user per 24-hour window (across all stages)
- [ ] Error logging: Log all failures to analytics and error tracking (Sentry/Firebase Crashlytics)
- [ ] Graceful degradation: If FCM is down, notifications silently fail (no user-facing error)

**Technical Details:**

**Auto-suppression:**
- Add columns to `user_profiles`:
  - `pushes_not_clicked_count` (int, default 0)
  - `notification_paused_until` (timestamp, null by default)
- On push tap: `pushes_not_clicked_count` = 0
- On no-click after 24 hours: `pushes_not_clicked_count` += 1
- On `pushes_not_clicked_count` = 3: `notification_paused_until` = now + 14 days
- Scheduler: Skip user if `notification_paused_until` > now

**Permission revocation detection:**
- App startup: Check `UIApplication.shared.registeredUserNotificationSettings`
- If permission changed from enabled → disabled:
  - Log analytics event: `notification_permission_revoked`
  - Set `is_notifications_enabled` = false (soft disable)
  - User can re-enable in Settings

**Network retry:**
- FCM send failure → retry immediately (1s), then 4s, then 16s
- After 3 failures, mark as failed and log to analytics
- Don't retry more than 3 times (avoid cascading failures)

**Orphaned tokens:**
- FCM error: "InvalidRegistrationToken" or "NotRegisteredError"
- Action: Mark token as invalid, request re-registration on next app open
- User should see nothing (silent re-registration)

**Integration Points:**
- T-083: Token management, permission detection
- T-084: Auto-suppression logic in scheduler
- T-088: Analytics logs all edge case events
- T-089: Test all edge cases before beta

**Testing Strategy:**
- Auto-suppression: Queue 3 pushes to test user, don't tap any. On 4th attempt, verify paused.
- Permission revocation: Disable push in Settings, launch app, verify `notification_permission_revoked` logged.
- Network failure: Mock FCM call to fail 2x, succeed on 3rd. Verify retry behavior.
- Orphaned token: Simulate invalid token error, verify re-registration attempted on next open.
- Rate limiting: Queue 5 pushes in 1 hour for same user, verify only 1 actually sends.
- Error logging: Cause various errors (network down, invalid token, etc.), verify all logged to analytics.

**Effort:** 6–8 hours  
**Dependencies:** T-083, T-084, T-085, T-086, T-087, T-088, T-089, T-090

---

## Cross-Ticket Dependencies

```
T-083 (FCM Setup) ──┬──→ T-084 (Scheduling Engine)
                   ├──→ T-086 (Settings UI)
                   └──→ T-088 (Analytics)
                        │
T-085 (Funnel Logic) ───┼──→ T-084 (Scheduling)
                        ├──→ T-087 (Templates)
                        └──→ T-088 (Analytics)

T-084 + T-085 + T-087 ──→ T-089 (Testing)
                          ├──→ T-090 (Send Time Optimization)
                          └──→ T-091 (Edge Cases)

Critical Path: T-083 → T-085 → T-087 → T-089 → (Beta)
```

## Success Metrics (Post-Implementation)

| Metric | Target | Baseline | Notes |
|--------|--------|----------|-------|
| Push CTR → Prayer | >40% | TBD | Taps that lead to prayer completion |
| Push CTR → Capture | TBD | TBD | Taps that lead to new capture |
| D7 Retention (post-notif) | >35% | 0% (current Phase 1 issue) | App open within 7 days of notification |
| Formation Engagement | >25% | TBD | % who dwell within 3 days of tap |
| Opt-out rate | <10% | TBD | % who disable notifications |
| Auto-suppression activation | <5% | TBD | % who hit 3 consecutive no-clicks |

## Risk Mitigation

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Notification fatigue | High churn | Cap at 1–2/month; sparse better than frequent |
| Privacy backlash | Brand damage | Transparent: "metadata only"; no moment content referenced |
| iOS suppression | Delivery failure | Design for low frequency; respect user preferences |
| Generic feels cold | Low CTR | Focus on tone and timing; test messaging |
| FCM rate limits | Delivery failures | MVP at 1K users won't hit limits; cost monitoring |

## Post-MVP Roadmap

1. **Formation Intelligence Integration** (Pillar 7): Topic-aware notifications based on pattern detection (themes appearing 3+ times)
2. **A/B Testing Suite**: Test different cadences, tones, send times
3. **Advanced Personalization**: "You've been praying about family lately — ready to reflect further?"
4. **User-Configurable Cadence**: Users can set frequency preference (Default/Sparse/Off) ← **Already in T-086 MVP**
5. **ML-Driven Send Time**: Predict optimal send time per user based on historical behavior
6. **Deep Linking**: Notifications link directly to specific moments or journals (requires Pillar 4 & 5 complete)

---

## Implementation Timeline

**Week 1:** T-083, T-085, T-086, T-087 (infrastructure + basic templates)  
**Week 2:** T-084, T-088 (scheduling + analytics wiring)  
**Week 3:** T-089, T-090, T-091 (testing + optimization + edge cases)  
**Week 4 (Optional):** Stress testing, beta prep, post-MVP roadmap planning

---

## Sign-Off Checklist

- [ ] All 9 tickets reviewed by engineering lead
- [ ] Effort estimates agreed upon
- [ ] T-083 (FCM setup) scheduled as blocking ticket
- [ ] T-089 (real device testing) scheduled before beta
- [ ] T-091 (edge cases) scheduled as final polish
- [ ] Post-MVP roadmap (Formation Intelligence, A/B testing) documented for future sprints

**Status:** Ready for sprint planning and assignment.

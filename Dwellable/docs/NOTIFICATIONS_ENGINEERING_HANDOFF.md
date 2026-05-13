# Pillar 8: Notifications — Engineering Handoff

**Date:** May 13, 2026  
**Status:** Ready for implementation (Phase 2 MVP)  
**Owner:** TBD (engineer assignment)  
**Total Effort:** ~100–150 hours (3–4 weeks)

---

## Executive Summary

Pillar 8 implements a sparse, behavior-gap-aware notification system designed to re-engage users who have captured moments, prayed, and journaled. The system is built on a **funnel-stage model** where users progress from A (onboarding) through D (actively dwelling), with each stage triggering context-specific notifications.

**Key Decision:** MVP launches with **generic, activity-based notifications** (no personalization). Post-MVP will integrate Formation Intelligence (Pillar 7) for topic-aware messaging.

**Cost:** Infrastructure is essentially free (FCM free tier covers millions of messages/month).

**Blocker:** Pillar 3 (Prayer/Dwelling) must be complete and compelling before Pillar 8 ships.

---

## What Changed Since Last Phase

### Previous MVP Decision (Deferred)
- MVP: No notifications (silence)
- Post-MVP: Formation Intelligence-triggered notifications

### New MVP Decision (Locked)
- MVP: Sparse (1–2/month), activity-based notifications
- D-stage (active dweller): 1 weekly activity-based push with two locked variants:
  - "Hey, how are you feeling since that prayer? Let's capture what you're processing."
  - "A prayer from a few days ago — ready to go deeper? Let's journal about what you've processed."
- Post-MVP: Formation Intelligence-triggered topic-aware notifications

### Rationale
1. **Early signal:** MVP sends ~1–2 pushes/user/month. Low volume = minimal risk, high learning potential.
2. **Retention anchor:** Phase 1 showed 100% capture, 0% return. Notifications are explicitly designed to move the needle on return.
3. **Privacy safe:** Activity-based copy (no moment content) satisfies server-side encryption model (Pillar 2).
4. **Formation-aware:** Tone is invitational ("heart," "dwelling"), not productivity ("streak").

---

## Quick Reference: Funnel Stages & Push Cadence

| Stage | Definition | Max Pushes/Month | Trigger | MVP Copy Example |
|-------|-----------|------------------|---------|-----------------|
| **A0** | Incomplete onboarding | 1 | Day 2 | "You're here. That took something." |
| **A** | No captures yet | 1 | Day 3 | "Ready to capture what's on your heart?" |
| **B1** | Captured, never prayed | 4 | 1/week | "How are you feeling? Let's pray about it." |
| **B2** | Captured, responded to prompt, never prayed | 4 | 1/week | "Your reflection matters. Ready to go deeper?" |
| **C1** | Prayed, never returned to journal | 4 | 1/week (day 7) | "A prayer from a few days ago — ready to go deeper?" |
| **C3** | Quiet 14+ days | 1 | 1/month | "Your moments are still here. Ready to reflect?" |
| **D** | Actively dwelling | 4 | 1/week | See locked variants above |

**Cost at Scale:**
- 1K users: $0/month (free tier)
- 10K users: $0/month (free tier)
- 100K users: $0–100/month (still within free tier at typical engagement)

---

## Tickets: At-a-Glance

| Ticket | Title | Effort | Week | Status |
|--------|-------|--------|------|--------|
| T-083 | Setup Firebase Cloud Messaging | 6–8h | 1 | 🔲 Not Started |
| T-084 | Build scheduling engine (cadence logic) | 8–10h | 1–2 | 🔲 Not Started |
| T-085 | Build funnel stage logic (A, B1, B2, C, D) | 6–8h | 1 | 🔲 Not Started |
| T-086 | Build Settings UI for notification preferences | 4–6h | 1 | 🔲 Not Started |
| T-087 | Write generic templates (4–5 per stage) | 3–4h | 1–2 | 🔲 Not Started |
| T-088 | Integrate analytics logging | 4–6h | 2 | 🔲 Not Started |
| T-089 | Test delivery on real devices | 6–8h | 3 | 🔲 Not Started |
| T-090 | Optimize send time | 4–6h | 3 | 🔲 Not Started |
| T-091 | Polish edge cases & error handling | 6–8h | 3–4 | 🔲 Not Started |

**Critical Path:** T-083 → T-085 → T-087 → T-089  
**Blocking Items:** T-089 must pass before beta; T-091 before public release

---

## Key Integration Points

### Pillar 0 (Onboarding)
- **New step:** "Enable notifications" after permission request
- **Default:** Opt-out (enabled by default, user can disable)
- **Copy:** "We'll send sparse, gentle invitations when there's something worth coming back to."
- **Ticket involved:** T-086 (Settings UI implementation)

### Pillar 3 (Prayer/Dwelling)
- **Dependency:** Pillar 3 must be complete and compelling
- **Why:** Notifications invite users back to pray. If prayer experience is weak, notifications fail.
- **Timeline:** Pillar 8 cannot ship until Pillar 3 is in beta and validated.

### Pillar 7 (Formation Intelligence) — Post-MVP
- **Integration:** Once theme detection is live, notifications become topic-aware
- **Example:** "You've been reflecting on family — ready to go deeper?"
- **Timeline:** Post-MVP, after Pillar 7 validation

### Analytics (T-018, T-019)
- **Dependency:** Event logging must be in place for segmentation (T-085)
- **Events required:** `capture_moment`, `prayer_completed`, `journal_returned`, `prompt_responded`
- **Used by:** Funnel stage logic, send time optimization

---

## Design Decisions (Locked)

### 1. Privacy Model: Server-Side Encryption (Not E2E)
- **Decision:** Notifications use plaintext-readable server-side encryption
- **Impact:** Allows activity-based personalization without client-side analysis
- **Trade-off:** Kell can read moment plaintext (but not external hackers)
- **User promise:** "Your moments are encrypted. Only you and Dwellable can see them."

### 2. Cadence: Sparse (1–2/month per user)
- **Decision:** B1 and D both get 1/week MAX; most users see 1–2 per month
- **Rationale:** Notification fatigue is the #1 risk. Sparse + timely > frequent + generic.
- **Measurement:** Track opt-out rate <10% as health metric.

### 3. MVP Templates: Generic + Activity-Based
- **Decision:** No topic awareness, no personalization (no "You've been praying about family")
- **Rationale:** Formation Intelligence (theme detection) comes Post-MVP.
- **What we DO:** Reference activity type (prayer, capture, journal) and emotional tone.
- **What we DON'T:** Reference moment content, user name, specific themes.

### 4. Tone: Invitational + Formation-Centered
- **Decision:** "How are you feeling?" not "3-day prayer streak!"
- **Rationale:** Formation app, not a habit tracker.
- **Test:** All copy should feel like an invitation, not a reminder or prod.

### 5. Permissions Model: Opt-Out (Default Enabled)
- **Decision:** Notifications default ON; user can disable in Settings or during onboarding
- **Rationale:** Opt-in historically leads to <30% adoption. Opt-out balances adoption + trust.
- **Mitigation:** Auto-suppression after 3 consecutive no-clicks (pause 2 weeks, then retry).

---

## Success Criteria (Post-Implementation)

### Must-Haves
- [ ] Notifications deliver reliably to real devices (>99% delivery rate)
- [ ] No double-sends or orphaned notifications
- [ ] Auto-suppression works (3 no-clicks → pause → retry)
- [ ] All analytics events logged correctly
- [ ] Settings toggle persists across app restart
- [ ] Edge cases handled (permission denial, network failure, token refresh)

### Nice-to-Haves
- [ ] Send time optimization (send during user's active window)
- [ ] A/B test (fixed 8 AM vs. smart time)
- [ ] Push CTR >40% (stretch goal; industry baseline is 7–12%)
- [ ] D7 retention >35% (from notification tap)

### Post-MVP Milestones
- [ ] Formation Intelligence integration (topic-aware notifications)
- [ ] User-configurable cadence (Default/Sparse/Off) ← **Already in MVP (T-086)**
- [ ] Deep linking (notifications link to specific moments)
- [ ] ML-driven send time optimization

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| **Notification fatigue** | High churn, opt-out | Cap at 1–2/month; auto-suppression after 3 no-clicks |
| **Generic templates feel cold** | Low CTR, low engagement | Focus on invitational tone; iterate based on user feedback |
| **Privacy concerns** | Brand damage, churn | Transparent in Settings: "activity-based only"; no content referenced |
| **iOS notification suppression** | Delivery failure | Design for sparse frequency; respect user preferences |
| **FCM rate limits** | Delivery failure | MVP at 1K users stays within free tier; cost monitoring |
| **Pillar 3 not compelling** | Notifications drive returns, but returns are poor | **HARD BLOCKER:** Pillar 3 must be in beta and validated before Pillar 8 ships |

---

## Dependencies Checklist

Before starting T-083:
- [ ] Pillar 0 (Onboarding) complete or in final sprint (for onboarding step integration)
- [ ] Pillar 3 (Prayer/Dwelling) in beta and showing strong engagement (before shipping Pillar 8)
- [ ] T-018 / T-019 (Analytics) logging `capture_moment`, `prayer_completed`, `journal_returned` events
- [ ] T-010 (SettingsView) exists; notification section can be added
- [ ] Supabase project connected; backend team available for schema updates

---

## Deliverables for Engineering

1. **TICKETS.csv** — Updated with T-083–T-091
2. **NOTIFICATIONS_IMPLEMENTATION_SPECS.md** — Detailed acceptance criteria + technical specs for each ticket
3. **NOTIFICATIONS_COLLAB_REVIEW.html** — Strategy doc with locked decisions, volume map, and metrics
4. **NOTIFICATIONS_ENGINEERING_HANDOFF.md** — This document

---

## How to Use This Handoff

1. **Sprint Planning:** Assign T-083 as blocking ticket for Week 1
2. **Implementation:** Reference NOTIFICATIONS_IMPLEMENTATION_SPECS.md for detailed AC
3. **Testing:** Use T-089 checklist to validate before beta
4. **Metrics:** Track delivery rate, CTR, D7 retention post-launch

---

## Questions for Engineering Lead

1. **Effort estimates:** Do 100–150 hours align with your team's velocity?
2. **Resource allocation:** Who owns which tickets? (Suggested: 2 engineers, 3–4 weeks)
3. **T-089 timing:** When should real device testing start relative to other tickets?
4. **Post-MVP roadmap:** When should Formation Intelligence integration begin?

---

## Next Steps

1. Engineering lead reviews and confirms effort estimates
2. Assign tickets to engineers (T-083 → T-091)
3. Schedule sprint kickoff for Week 1
4. Establish metrics dashboard for launch metrics (delivery rate, CTR, opt-out rate)
5. Plan beta launch (after T-089 passes; before public release)

---

**Status:** Ready for assignment. Engineering lead: please confirm estimated effort and resource allocation by [DATE].

**Sign-off:**  
- Product: Kell (locked MVP strategy, MVP volumes, success metrics)
- Engineering: TBD
- QA/Testing: TBD

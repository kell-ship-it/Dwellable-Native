# PILLAR_7_NOTIFICATIONS_STRATEGY.md

**Pillar:** 7 (Notifications) | **Updated:** May 6, 2026 | **Status:** Strategy Locked

---

## 1. Overview

- **Pillar:** 7 (Notifications)
- **Purpose:** Drive user return and deeper reflection (soaking engagement) through sparse, contextual invitations to dwell
- **Scope:** Push notifications only; no in-app alerts or email (MVP)
- **Status:** Strategy locked, ready for implementation
- **Philosophy:** "Invitations to dwell," not "reminders to use the app"

---

## 2. Product Purpose

**The Problem Notifications Solve:**
- Phase 1 validation: 100% capture adoption, 0% return rate
- Root cause: Users aren't returning to reflect on moments they captured
- Solution: Sparse, meaningful notifications that invite users back to dwell on their moments

**Why Pillar 7 (Last):**
- Notifications only work *after* there are compelling experiences (Soaking from Pillar 3)
- Without good soaking prompts, notifications just nag users to use an empty app
- Pillar 6 (Menu) makes moments accessible; Pillar 7 invites users back to them

---

## 3. Success Criteria

**Qualitative:**
- [ ] Notifications feel like invitations, not reminders
- [ ] Users perceive notifications as genuinely helpful, not pushy
- [ ] Notifications respect the spiritual/faith tone of Dwellable (not productivity-gamified)

**Quantitative:**
- [ ] D7 Retention increases to >35% (from 0% baseline)
- [ ] Formation Engagement Rate (% of users soaking) increases >20%
- [ ] Click-through rate on notifications >40% (users act on invitations)
- [ ] Opt-out rate <10% (users keep notifications enabled)
- [ ] No increase in churn from notification fatigue

---

## 4. Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Frequency** | 1–2 per month | Very sparse; quality over quantity; avoid notification fatigue in faith context |
| **Opt model** | Opt-out (default on) | Maximizes reach; users can disable if unwanted; easier to adopt than opt-in |
| **Personalization** | Yes, contextual (metadata-based) | Generic notifications feel cold; personalized by user segment + behavior |
| **Timing** | User's typical app-open time | Better engagement; respects user's natural rhythm |
| **Message tone** | Invitation, not reminder | "Ready to reflect?" not "You haven't used the app" |
| **No streaks** | Avoid gamification | Aligns with faith-based philosophy; formation ≠ productivity |
| **Push only (no email)** | Native notifications | More immediate; respects privacy (email = broadcast) |

---

## 5. User Segmentation & Messaging

### **Segment 1: New Users (No Captures Yet)**

**Condition:** User signed up, but 0 moments captured after 3 days

**Goal:** Drive first capture

**Notification Examples:**
- "Ready to capture what's on your heart?"
- "What's something you'd like to remember from this week?"
- "Your voice is worth capturing."

**Cadence:** 1 notification (day 3), then pause

---

### **Segment 2: Non-Soakers (Captured but Not Reflecting)**

**Condition:** User has ≥1 moment, but 0 soaking responses

**Goal:** Invite deeper reflection (drive soaking engagement)

**Notification Examples (Generic):**
- "How has your heart been this week? Anything to reflect on?"
- "Your moments are waiting. Ready to go deeper?"

**Cadence:** 1 notification per month (sparse)

---

### **Segment 3: Occasional Soakers (Some Soaking, but Infrequent)**

**Condition:** User has soaked <1x per week on average

**Goal:** Encourage consistent dwelling

**Notification Examples (Contextual):**
- "You responded to a prompt last week. How about this week?"
- "Formation grows through consistency. Ready to dwell?"

**Cadence:** 1 notification per month

---

### **Segment 4: Active Dwellers (High Soaking Engagement)**

**Condition:** User soaks ≥1x per week consistently

**Goal:** Maintain engagement; offer advanced features (if available)

**Notification Examples (Contextual, not generic):**
- "You've been reflecting deeply on faith lately. Want to explore patterns?"
- (Mostly quiet; let them use app; only notify for genuinely valuable insights)

**Cadence:** 0–1 per month (very sparse; only high-signal notifications)

---

## 6. Personalization Rules (Metadata-Based, Due to E2E Encryption)

**NOTE:** Due to Pillar 2 (E2E Encryption), user moments are encrypted client-side. Kell cannot read plaintext. Therefore, notifications are personalized using **metadata only**, not moment content:

**What we CAN personalize (metadata):**
- ✓ Timing (when user typically opens app)
- ✓ Soaking history (prayer vs. prompt preference)
- ✓ Segment (new user, non-soaker, occasional, active)
- ✓ Engagement frequency (# of moments captured, # of soaking responses)

**What we CANNOT personalize (encrypted):**
- ✗ Moment themes ("You captured about faith")
- ✗ Specific moment content (reference to what user wrote)

**Generic Fallbacks (Always Available):**
- "How has your heart been this week? Anything to reflect on?"
- "You have unresponded moments. Ready to dwell?"
- "Your moments are waiting."

---

## 7. Frequency & Timing Strategy

### **Global Frequency Cap**
- **Max:** 1–2 notifications per user per month
- **Rationale:** Avoid notification fatigue; respect faith-based philosophy (not productivity-obsessed)

### **Per-Segment Timing**

| Segment | Initial | Follow-up | If No Action |
|---------|---------|-----------|--------------|
| New Users | Day 3 | None | None (let them explore) |
| Non-Soakers | Day 7 after capture | Every 2 weeks (max) | Back off after 3 "no clicks" |
| Occasional Soakers | After low-activity week | Every 2 weeks | Adjust based on soaking pattern |
| Active Dwellers | Rare (1–2x per quarter) | Only high-signal events | Mostly quiet |

### **Optimal Send Time**
- **Strategy:** Send at user's typical app-open time (inferred from usage data)
- **Fallback:** If pattern unclear, default to 9am their local time

---

## 8. Privacy & E2E Encryption Implications

**Privacy Promise (unchanged):**
*"Your responses are end-to-end encrypted. We never see your moments."*

**Notification Transparency:**
- Notifications are generated using metadata (timing, engagement patterns, segment)
- Moments are encrypted; notifications do not reference plaintext content
- Users can disable notifications entirely in settings

---

## 9. Notification Examples by Segment & Type

### **New User (Day 3, No Capture Yet)**
```
Title: "Ready to capture what's on your heart?"
Body: "Dwellable is a space to voice your faith, concerns, and breakthroughs. 
       Start with your voice—no perfection needed."
Action: Tap → Opens Create tab
```

### **Non-Soaker (Generic)**
```
Title: "How has your heart been this week?"
Body: "You have unresponded moments waiting. Ready to dwell on one?"
Action: Tap → Opens Today tab (shows recent moments)
```

### **Occasional Soaker (Contextual)**
```
Title: "You responded to a prompt last week. How about this week?"
Body: "Dwelling deepens faith. Ready to reflect on a moment?"
Action: Tap → Opens Today tab
```

### **Active Dweller (Rare, High-Signal)**
```
Title: "You've been reflecting deeply on faith."
Body: "Here's a pattern in your moments: growth through struggle. 
       Want to explore more?"
Action: Tap → Opens Insights tab
```

---

## 10. Alternatives Considered (Not Chosen)

| Alternative | Why Considered | Why Not Chosen |
|-------------|-----------------|-----------------|
| **Email notifications** | Reach more users, easier delivery | Email feels broadcast/impersonal; breaks intimacy of faith app |
| **Daily notifications** | Higher engagement, more touchpoints | Too noisy; violates faith philosophy; causes fatigue |
| **Streak gamification** | Proven engagement driver in habit apps | Contradicts faith-based philosophy; turns formation into productivity |
| **In-app badges/alerts** | Non-intrusive alternative to push | Requires app open; misses users who don't return |
| **SMS notifications** | High delivery rate, direct | Too intrusive; breaches privacy; not all users want SMS |
| **Notifications for all segments** | Maximize engagement | Wastes notifications on active users who don't need them; causes churn |
| **High frequency (daily or weekly)** | Drive habit formation | Contradicts "sparse, meaningful" philosophy; risks fatigue |
| **Opt-in model** | Safer from trust perspective | Lower adoption; users who need notifications most won't opt in |

---

## 11. Metrics to Track

| Metric | Definition | Success Target |
|--------|-----------|-----------------|
| **Click-through rate (CTR)** | % of delivered notifications that user clicks | >40% |
| **Conversion rate** | % of clicks that lead to soaking response | >30% |
| **D7 Retention** | % of users returning within 7 days after notification | >35% |
| **Formation Engagement (post-notif)** | % of notified users who engage in soaking within 3 days | >25% |
| **Opt-out rate** | % of users who disable notifications | <10% |
| **Segment conversion** | % of new users → first capture after notification | >20% |
| **Churn impact** | Change in churn rate before/after notifications | No increase |

---

## 12. Implementation Approach

**Phase 1: Infrastructure (Weeks 1–2)**
- [ ] Set up push notification service (Firebase Cloud Messaging for iOS)
- [ ] Build notification scheduling system
- [ ] Implement opt-out/settings UI
- [ ] Add analytics event logging

**Phase 2: User Segmentation (Weeks 2–3)**
- [ ] Build logic to identify segments (new, non-soaker, occasional, active)
- [ ] Store segment assignment in database

**Phase 3: Generic Notifications (Weeks 3–4)**
- [ ] Write generic notification templates for each segment
- [ ] Test delivery, timing, click behavior
- [ ] Measure baseline CTR and conversion

**Phase 4: Timing Optimization (Weeks 5+)**
- [ ] Analyze when users typically open app
- [ ] Schedule notifications for optimal time
- [ ] A/B test: fixed time vs. smart time

---

## 13. Tickets to Create

| Ticket | Title | Effort | Dependencies |
|--------|-------|--------|--------------|
| T-083 | Setup: Firebase Cloud Messaging for push notifications | M | None |
| T-084 | Build: Notification scheduling engine (cadence logic) | M | T-083 |
| T-085 | Build: User segmentation logic (new, non-soaker, occasional, active) | M | Analytics data |
| T-086 | Build: Settings UI for notification preferences | S | T-083 |
| T-087 | Write: Generic notification templates (4 templates per segment) | S | T-085 |
| T-088 | Integrate: Analytics logging (notification events) | M | T-083, T-085 |
| T-089 | Test: Notification delivery on real devices | M | T-083 through T-088 |
| T-090 | Optimize: Send time based on user behavior | M | T-084, usage data |
| T-091 | Polish: Edge cases, opt-out flows, error handling | M | All above |

**Estimated effort:** 9 tickets, ~100–150 hours (3–4 weeks)

**Blocker:** Pillar 3 (Soaking) must be complete and compelling before Pillar 7 ships. Notifications only work if there's something compelling to return to.

---

## 14. Dependencies & Blockers

| Dependency | Status | Impact |
|-----------|--------|--------|
| **Pillar 3 (Soaking)** | In design | Need soaking to exist; notifications invite users to it |
| **Pillar 2 (E2E Encryption)** | LOCKED | Determines privacy promise (metadata-only personalization) |
| **Analytics/UsageTracker** | In development | Need to track soaking engagement to identify non-soakers |
| **Settings UI** | Part of Pillar 6 | Need settings page for notification preferences |

---

## 15. Risks & Constraints

| Risk | Impact | Mitigation |
|------|--------|-----------|
| **Notification fatigue** | Users disable notifications, churn | Cap at 1–2/month; sparse is better than frequent |
| **Privacy backlash** | Users distrust Dwellable if notifications imply data access | Be transparent: "metadata only"; emphasize E2E encryption |
| **Generic notifications feel cold** | Low engagement, low conversion | Focus on tone and timing; avoid productivity language |
| **iOS notification suppression** | Some users' devices may suppress notifications | Design for low send frequency; respect user preferences |
| **Faith-app users may see notifications as pushy** | Increases churn risk | Test with pilot users; iterate messaging to be gentler |

---

## 16. Open Questions (To Resolve Before Tickets)

1. **Should we launch Pillar 7 with generic notifications only, or wait for better personalization?**
   - **Decision:** Ship generic first (Phases 1–3), validate if notifications drive return at all

2. **How do we handle users who never engage with notifications?**
   - **Strategy:** After 3 consecutive "no clicks," soft pause for 2 weeks, then retry

3. **Should onboarding explain why they're receiving notifications?**
   - **Recommendation:** Yes, brief tooltip explaining Pillar 7 purpose

4. **Should notification frequency be user-configurable?**
   - **Recommendation:** Yes, in Settings (weekly, bi-weekly, monthly options)

---

## Summary

| Aspect | Decision |
|--------|----------|
| **Goal** | Drive return + soaking engagement |
| **Philosophy** | Invitations to dwell, not reminders |
| **Cadence** | 1–2 per month (very sparse) |
| **Segments** | New users, non-soakers, occasional soakers, active dwellers |
| **Personalization** | Metadata-based (due to E2E encryption) |
| **Opt model** | Opt-out (default on) |
| **Privacy** | E2E encryption maintained |
| **Tone** | Spiritual ("heart," "dwell"), not productivity ("streak") |
| **Key metric** | D7 retention >35%, CTR >40% |
| **Blocker** | Pillar 3 validation + Soaking completion |

---

**Status:** Ready for implementation. T-083 is the first blocking ticket. However, Pillar 3 (Soaking) must ship first and prove compelling.

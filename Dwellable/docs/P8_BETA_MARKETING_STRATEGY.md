# Pillar 8: Beta & Marketing — Strategy & Design Specification

**Founder:** Kell Golden | **Status:** Design In Progress | **Updated:** May 7, 2026

---

## What We're Building

Pillar 8 enables the transition from Phase 1 personal dogfooding → Phase 2 closed beta with targeted user cohorts. This pillar includes self-signup flow for beta users, cohort management (tracking, segmentation, cohort-based rollout), feedback collection (in-app surveys, usage analytics, structured interviews), and community engagement (Discord, email updates).

The core principle: Validate dwelling behavior at scale before public launch. Measure whether Dwellable achieves its North Star: users notice and dwell on God's presence across their entire life.

---

## Happy Paths

### Path 1: Beta User Self-Signup

**Scenario:** A user hears about Dwellable (social media, word-of-mouth, church community) and wants to join the Phase 2 beta.

1. **User Visits Signup URL** → www.dwellable.app/beta or landing page
2. **See Beta Pitch** → Clear copy: "Dwellable is a faith-specific app for capturing and dwelling on God's presence. We're in Phase 2 beta. Apply now."
3. **Tap Apply** → User taps "Join Beta" button
4. **Fill Signup Form** → 
   - Name, email, phone (optional)
   - "What's your main practice? (Prayer, journaling, reflection, other)"
   - "What device? (iPhone 14+)"
   - "Why are you interested in Dwellable?" (optional open field)
   - Agree to terms/privacy
5. **Submit** → User submits form
6. **Waitlist Confirmation** → "Thanks for your interest! We'll email you when a spot opens."
7. **Email Confirmation** → User receives email with beta cohort info and next steps
8. **Beta Access Granted (Staggered)** → Once in a cohort, user receives TestFlight link + onboarding email
9. **Install TestFlight** → User installs Dwellable beta via TestFlight
10. **First Launch** → User enters app (Pillar 0 onboarding applies)

---

### Path 2: Cohort Enrollment & Tracking

**Scenario:** Beta manager assigns users to cohorts (Cohort A: consistent reflectors, Cohort B: selective reflectors, Cohort C: control) for staggered rollout and A/B testing.

1. **Admin Dashboard** → Manager views all signups in spreadsheet or dashboard
2. **Segment Users** → Manager reviews signup responses, categorizes into cohorts:
   - **Cohort A (Consistent Reflectors):** "I journal every day", "prayer rhythm is core"
   - **Cohort B (Selective Reflectors):** "I journal when something significant happens"
   - **Cohort C (Control/Waitlist):** Not yet activated
3. **Assign to Cohort** → Admin tags user with cohort; system auto-sends TestFlight invite
4. **Track Cohort Progress** → Dashboard shows per-cohort metrics:
   - Onboarding completion rate
   - First capture rate
   - Weekly active reflection rate (WAR)
   - Session length
   - Retention week 1 → week 4
5. **Staggered Activation** → Cohort A launches at T+0, Cohort B at T+1 week, Cohort C later
6. **Compare Metrics** → Identify which user segment engages best with Dwellable

---

### Path 3: In-App Feedback Collection

**Scenario:** User is in the app and sees optional feedback prompts that help inform Phase 2 iteration.

1. **After First Capture** → User sees: "How was your first moment capture?" (Quick reaction, optional)
2. **After First Dwelling Session** → "Did reflecting on this moment help you notice God's presence?" (Yes/No/Neutral + optional comment)
3. **Weekly Check-In** → Once per week, optional brief survey: "What's working? What's missing?" (free text)
4. **Moment Export** → Suggestion to share feedback or moments (optional)
5. **Feedback Submitted** → Data sent to analytics/feedback platform (PostHog, Typeform, etc.)
6. **User Sees Impact** → Email: "Your feedback about [feature] helped us improve..."

---

### Path 4: Structured Interview Process

**Scenario:** Beta manager conducts 1:1 interviews with selected users (every 2 weeks) to understand dwelling behavior qualitatively.

1. **Recruit Interviewees** → Manager emails: "We'd love to hear about your experience. 20-min call?"
2. **Schedule Interview** → User books 20-min slot
3. **Interview Script** → Standard questions:
   - "Tell me about a moment you captured recently"
   - "What made you return to it?"
   - "Did dwelling on it change how you see that moment?"
   - "What would make you return more often?"
   - "What's missing?"
4. **Record Notes** → Manager documents key insights
5. **Aggregate Findings** → Themes emerge across interviews (e.g., "Users want to see God's presence over time" or "Photo context is important")
6. **Share Learnings** → Weekly Slack/email summary of interview insights
7. **Iterate Product** → Use qualitative findings to inform Pillar design decisions

---

### Path 5: Community Engagement (Discord)

**Scenario:** Beta users want to discuss Dwellable, share insights, ask questions, and build early community.

1. **User Invited to Discord** → Onboarding email includes Discord server invite
2. **Join Server** → User accepts and sees channels:
   - #announcements (Phase 2 updates)
   - #feedback (feature requests, bugs)
   - #moments (users share moments, themes, prayers)
   - #help (Q&A)
3. **Participate** → User can:
   - Share a moment they captured and dwelled on
   - Ask questions about features
   - Suggest improvements
   - Connect with other believers
4. **Manager Monitoring** → Team monitors #feedback and #help, responds to questions, captures feature requests
5. **Iteration Loop** → Top feature requests feed into Phase 2+ planning

---

### Path 6: Email Engagement Campaign

**Scenario:** Regular email updates keep beta users informed, invited, and feeling part of the journey.

1. **Welcome Email (Day 1)** → Celebrates signup, explains Phase 2 roadmap, links to onboarding guide
2. **Onboarding Email (Day 3)** → "Your first capture is a huge step. Here's how to get the most out of dwelling..."
3. **Weekly Digest (Every Friday)** → 
   - Your stats this week (# moments, # times you dwelled)
   - An upcoming feature being tested
   - Invitation to Discord
4. **Feature Highlight (Bi-weekly)** → "This week we shipped a new way to search your moments..."
5. **Request for Feedback (Every 2 weeks)** → "Help us improve Dwellable: 2-min survey"
6. **Interview Invite (Periodic)** → "We'd love to chat about your experience..."
7. **Cohort Milestone (End of Beta)** → "You've been with us for 4 weeks. Here's what you've helped us learn..."

---

### Path 7: Metrics Dashboard (Internal)

**Scenario:** Beta manager and product team review live metrics to track Phase 2 success.

1. **Weekly Review Meeting** → Team views dashboard:
   - **Activation:** # signups, # invited, # installed, # first capture
   - **Engagement:** # weekly active users, WAR (weekly active reflections), session length, retention curves
   - **Dwelling Behavior:** # journal reads, # soaking sessions, # prayers prayed, # times returned to moment
   - **Cohort Breakdown:** Above metrics per cohort (A vs B)
   - **Support:** # bugs reported, # support questions, resolution time
2. **Analyze Trends** → 
   - Is WAR improving (target: 40-50% by week 8)?
   - Are consistent reflectors engaging more than selective?
   - What features have highest engagement?
3. **Iterate** → Use findings to prioritize Pillar design (e.g., "Users love Soaking but ignore Search → focus on Soaking refinement")
4. **Communicate Progress** → Share weekly summary with team, monthly with beta community

---

## Locked Decisions

1. ✅ **Closed Beta:** Phase 2 is invite-only (staggered rollout), not open to public
2. ✅ **Cohort Structure:** Segment users into consistent reflectors vs selective reflectors (vs control/waitlist)
3. ✅ **Feedback Collection:** Combine quantitative analytics + qualitative surveys + interviews
4. ✅ **Community Platform:** Use Discord for beta community engagement
5. ✅ **Email Cadence:** Weekly digest + bi-weekly feature highlights + periodic interview invites
6. ✅ **Success Metric:** Primary = WAR 40-50% by week 8; secondary = retention, session length, dwelling behavior
7. ✅ **Cohort Size:** Start with 20-30 users per cohort, expand based on stability
8. ✅ **Interview Frequency:** 1:1 interviews with ~5-10 users per week (structured)

---

## Tentative Decisions (TBD by Product)

1. ❓ **Waitlist Management:** Should we use signup priority (FIFO) or segment by region/practice? (Recommend: segment by practice type)
2. ❓ **Beta Duration:** How long is Phase 2 Beta (4 weeks? 8 weeks? 12 weeks)? (Recommend: 8-12 weeks minimum)
3. ❓ **Control Group:** Should we have a "no Soaking" control group to isolate dwelling impact? (Recommend: no, too complex; instead, measure engagement variance)
4. ❓ **Referral Bonus:** Should we incentivize existing users to refer friends? (Recommend: no monetary incentive, but thank-you)
5. ❓ **Beta Compensation:** Should beta testers receive free premium access post-launch? (Recommend: 1 year free for active participants)

---

## Open Questions (Deferred)

- Public launch strategy (App Store submission, press, partnerships) — Phase 3+
- Paid advertising / growth strategy — Phase 3+
- Influencer partnerships (Christian podcasts, authors) — Phase 3+
- Corporate/ministry partnerships (churches, prayer apps) — Phase 3+

---

## Success Metrics

### Quantitative (Analytics)

- **Activation:** >20 signups/week by week 3
- **Conversion:** >80% of signups complete onboarding
- **Engagement:** >50% weekly active users (WAR) by week 8
- **Retention:** >70% week 1 retention, >50% week 4 retention
- **Dwelling:** >60% of users dwell on moments within 24h of capture
- **Soaking Adoption:** >40% of users engage with prayer/prompts within first week

### Qualitative (Interviews)

- User quotes: "I'm noticing God's presence more often"
- User quotes: "I'm seeing patterns in how God shows up in my life"
- Themes from interviews: [Codified after week 2, week 4, week 8]

### User Satisfaction

- Post-capture survey: >4.0/5.0 satisfaction with moment capture
- Post-dwelling survey: >4.0/5.0 satisfaction with journal/soaking experience
- Net Promoter Score (NPS): >50 (calculated from "would you recommend Dwellable to a friend?")

---

## Integration Points with Other Pillars

- **All Pillars (0-7):** Beta tests all pillars; analytics track usage per pillar
- **Pillar 3 (Soaking):** Primary metric of success — measure engagement/dwelling behavior
- **Pillar 7 (Formation Intelligence):** Measure whether users report "seeing patterns" in Phase 2
- **Pillar 4 (Journal Creation):** Track journal synthesis quality, edit rates, user satisfaction

---

## Technical Considerations

### Infrastructure Needed

1. **TestFlight Distribution:** Apple TestFlight for app delivery
2. **Analytics Platform:** PostHog, Segment, or similar (track engagement events)
3. **Survey Platform:** Typeform, Qualtrics, or in-app surveys
4. **Community Platform:** Discord server for beta community
5. **Database:** Supabase (or existing backend) with cohort tracking tables
6. **Email Platform:** Mailchimp, Braze, or custom email service
7. **Metrics Dashboard:** Metabase, Grafana, or custom dashboard for weekly review

### Data Model

```swift
struct BetaUser: Codable {
    let id: String                              // UUID
    let email: String
    let name: String
    let signupDate: Date
    let cohort: String                          // "A" (consistent), "B" (selective), "C" (waitlist)
    let signupResponses: [String: String]       // Form responses
    let invitedAt: Date?                        // When TestFlight invite sent
    let acceptedAt: Date?                       // When user activated TestFlight
    let firstCaptureAt: Date?                   // First moment captured
    let interviewScheduled: Date?               // Next interview date
    let notes: String?                          // Manager notes
    let engaged: Bool                           // Currently active
}

struct BetaAnalytics: Codable {
    let userId: String
    let cohort: String
    let weekNumber: Int                         // Week 1, Week 2, etc
    let eventsThisWeek: Int                     // Total events
    let momentsCaptured: Int                    // # moments created
    let momentsRevisited: Int                   // # moments opened for dwelling
    let soakingSessionsCompleted: Int           // # times user engaged with soaking
    let prayersRecorded: Int                    // # prayers
    let journalsCreated: Int                    // # journals synthesized
    let searchQueriesPerformed: Int             // # searches
    let sessionLength: Double                   // Avg session length (minutes)
}
```

---

## Next Steps

1. Designer to finalize beta signup form and email templates
2. Product to define interview script and cohort segmentation criteria
3. Engineer to set up analytics tracking (PostHog or similar)
4. Create Discord server and onboarding channels
5. Build internal metrics dashboard for weekly review
6. Create implementation tickets for beta infrastructure

---

## Success Criteria for Design Lock

- ✅ Happy paths documented and reviewed
- ⏳ Beta signup form and email templates finalized
- ⏳ Interview script and questions documented
- ⏳ Cohort segmentation criteria defined
- ⏳ Analytics schema and dashboard mockups created
- ⏳ Discord server channels and moderation plan documented
- ⏳ Implementation tickets created for beta infrastructure

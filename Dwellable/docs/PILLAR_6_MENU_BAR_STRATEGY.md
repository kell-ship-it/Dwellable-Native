# PILLAR_6_MENU_BAR_STRATEGY.md

**Pillar:** 6 (Menu Bar / Navigation) | **Updated:** May 6, 2026 | **Status:** Strategy Locked

---

## 1. Overview

- **Purpose:** Define the primary navigation structure for the entire Dwellable app
- **Scope:** Tab-based navigation, not full app design
- **Status:** Strategy locked, ready for implementation

---

## 2. Product Purpose

**Why Menu matters:**
- Phase 1 validation: Capture works (100% adoption), but return rate is 0%
- **Problem:** Users capture moments but don't return to reflect
- **Menu's job:** Make it frictionless for users to navigate between capturing, reviewing, and dwelling
- **Success:** Each tab serves one clear purpose with zero friction

---

## 3. Success Criteria

**Qualitative:**
- [ ] Users intuitively understand what each tab does
- [ ] No confusion about where to find their moments
- [ ] Navigation never blocks the core user journey (capture → dwell → reflect)

**Quantitative:**
- [ ] >90% of sessions include at least 1 tab switch (users navigate)
- [ ] <5% session abandonment due to navigation confusion
- [ ] Avg time to navigate from Create → Entries = <2 seconds

---

## 4. Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Navigation pattern** | SwiftUI NavigationStack (stack-based) | No tab bar; design spec calls for single-screen focus |
| **Tab count** | 4 tabs (Today, Entries, Create, Insights) | More than 4 = cognitive overload; fewer = missing key features |
| **Tab ordering** | Today \| Entries \| Create \| Insights | Left-to-right: recent → archive → capture → metrics |
| **Primary action** | Create (prominent) | Capture is the core action; should be most accessible |
| **Home tab** | Today (default on app launch) | Shows recent moments, frictionless entry to dwelling |

---

## 5. Tab Architecture

### **Tab 1: Today**
- **Purpose:** Show recent moments from this week; entry point to dwelling
- **Content:** Moments from last 7 days, reverse chronological order
- **Actions:** Tap moment → opens Entries detail view (modal); pull-to-refresh
- **Empty state:** "No moments this week. Create one?" (button → Create tab)

### **Tab 2: Entries**
- **Purpose:** Complete archive of all moments; browse and filter
- **Content:** All moments (entire history); searchable; filterable by date/theme
- **Filters:** Date range, prayer-tagged, prompt-engaged, soaking-depth
- **Actions:** Tap moment → detail view; swipe to mark favorite
- **Empty state:** "No moments yet. Create your first?" (button → Create tab)

### **Tab 3: Create**
- **Purpose:** Capture new moment (voice or text)
- **Flow:** Voice tap → transcribe → review → save → back to Today
- **Actions:** Voice button, text button, cancel, save
- **Confirmation:** "Saved to your moments" → auto-return to Today

### **Tab 4: Insights**
- **Purpose:** Formation metrics dashboard
- **Metrics displayed:**
  - Weekly Active Reflections (WAR) — % of users who engaged with ≥1 prompt/prayer this week
  - Formation Engagement Rate — % of moments with soaking response
  - Soaking Depth — avg prompts/prayers per moment
  - Prayer Rate — % of soaking responses that were prayers
  - D7 Retention — % returning after 7 days
  - Avg Session Length — avg minutes per session
- **Visualizations:** Line charts (trends over time), cards (current week stats)
- **Actions:** Tap stat → detailed breakdown

---

## 6. Alternatives Considered (Not Chosen)

| Alternative | Why Considered | Why Not Chosen |
|-------------|-----------------|-----------------|
| **Bottom Tab Bar (iOS standard)** | iOS convention, users expect it | Design spec calls for minimalist stack navigation; avoids bottom-of-screen friction |
| **5+ Tabs (add Settings, Profile, Help)** | More features = more visibility | MVP focus: 4 core actions only; Settings deferred to Pillar X |
| **"Entries" + "Discover" as separate tabs** | Discover = curated/themed moments | "Discover" implies community features (not MVP scope); same data, different filter = one tab with filters |
| **Single "Browse" tab (Today + Entries merged)** | Fewer tabs = simpler | Separation needed: "Today" (entry point, recent) vs. "Entries" (full archive); distinct mental models |
| **Hamburger menu (side drawer)** | Proven navigation pattern | Less discoverable than tabs; adds extra tap to navigate |
| **Dedicated Search tab** | Search is powerful | Search lives as a filter within Entries (don't need full tab) |
| **Settings in Menu** | Users need settings access | Deferred; Settings accessed via Insights → gear icon (post-MVP) |
| **Floating action button for Create** | Common mobile pattern | Chose tab placement; Create is a first-class action, deserves tab real estate |

---

## 7. Metrics to Track

| Metric | Definition | Success Target |
|--------|-----------|-----------------|
| **Tab Switch Frequency** | Avg # of tab switches per session | >1.5 switches/session |
| **Today Engagement** | % of sessions starting on Today tab | >80% |
| **Entries Browse Time** | Avg time spent in Entries tab per session | >30 seconds |
| **Create Conversion** | % of Create tab visits that result in saved moment | >90% |
| **Insights Viewership** | % of users viewing Insights weekly | >40% |
| **Navigation Errors** | # of times user navigates to wrong tab | <5% of sessions |

---

## 8. Implementation Approach

**Phase 1 (Navigation Skeleton):**
- [ ] Build 4-tab SwiftUI NavigationStack
- [ ] Create empty placeholder screens for each tab
- [ ] Ensure tab switching works smoothly
- [ ] Test on device

**Phase 2 (Populate Each Tab):**
- [ ] **Today:** Wire to MomentsListView (recent 7 days)
- [ ] **Entries:** Wire to full moments list + filters
- [ ] **Create:** Wire to CaptureView (existing, no changes)
- [ ] **Insights:** Wire to analytics dashboard (pull metrics from UsageTracker)

**Phase 3 (Polish):**
- [ ] Empty states for each tab
- [ ] Loading states during data fetch
- [ ] Error handling (network failures, etc.)
- [ ] Device testing (iPhone 13+)

---

## 9. Tickets to Create

| Ticket | Title | Effort | Dependencies |
|--------|-------|--------|--------------|
| T-076 | Build: SwiftUI NavigationStack with 4 tabs | M | None |
| T-077 | Wire: Today tab to recent moments (7-day filter) | M | T-076 |
| T-078 | Wire: Entries tab to full moments list + filters | L | T-076, T-040 (moment list UI) |
| T-079 | Wire: Create tab (already exists, just navigate to it) | S | T-076 |
| T-080 | Build: Insights dashboard (WAR, Formation Rate, etc.) | L | T-076, analytics data ready |
| T-081 | Polish: Empty states, loading states, error handling | M | T-077, T-078, T-080 |
| T-082 | Test: Device testing + QA (iPhone 13, 14, 15, 16) | M | All tabs wired |

**Estimated effort:** 7 tickets, ~80–120 hours (2–3 weeks)

---

## 10. Risks & Constraints

| Risk | Impact | Mitigation |
|------|--------|-----------|
| **Analytics data not ready** | Can't populate Insights tab | Use mock data for MVP; wire real data once UsageTracker is complete |
| **Moment filtering complex** | Entries tab takes longer | Start with date filtering only; add theme/tag filtering in follow-up |
| **Device performance** | Navigation lag on older iPhones | Profile memory usage; optimize view rendering |
| **User confusion on first launch** | Users don't know what tabs do | Add onboarding tooltip on first launch explaining each tab |

---

## Summary

| Aspect | Decision |
|--------|----------|
| **Goal** | Frictionless navigation between capturing, reviewing, and dwelling |
| **Tab structure** | Today \| Entries \| Create \| Insights |
| **Philosophy** | Four core actions, no more, no less |
| **Success metric** | >90% tab switch frequency, <5% navigation confusion |
| **Key blocker** | Analytics ready for Insights tab |

---

**Status:** Ready for implementation. T-076 is the first blocking ticket.

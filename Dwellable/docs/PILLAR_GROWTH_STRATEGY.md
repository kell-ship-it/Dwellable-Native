# PILLAR: Growth (Formation Metrics & Dashboard)

**Pillar:** Growth | **Updated:** May 14, 2026 | **Status:** Strategy Locked

---

## 1. Overview

- **Purpose:** Show users their formation journey through metrics, trends, and emerging patterns
- **Scope:** Formation metrics, emotional themes, prayer engagement, settings, post-MVP glossary & emotional depth
- **Status:** Strategy locked, ready for implementation ticket creation
- **Tab Position:** 4th tab in main menu (Today | Entries | Create | Growth)

---

## 2. Product Purpose

**Why Growth matters:**
- Users need to **see themselves being formed** — not just capture moments, but understand patterns emerging
- Formation Intelligence requires visibility — "here's what's changing in your spiritual journey"
- Settings live here because they're personal to the user's growth context (notification rhythm, prayer frequency, theme preference)
- Growth affirms progress (total captures, prayers offered, emotional themes explored) — psychological reinforcement
- Post-MVP: Glossary + emotional depth reveal who they're becoming

---

## 3. Formation Intelligence System

**What Growth learns about the user:**
- Capture frequency and patterns (how many moments per week? concentrated or distributed?)
- Prayer engagement (how many moments led to prayer? prayer vs. prompt preference)
- Prayer depth (% of moments with ANY prayer response — prayer or prompts)
- Emotional landscape (which moods dominate? are they shifting over time?)
- Archetype confirmation (Jotter/Venter/Processor) based on capture style + prayer behavior
- Formation pace and consistency (steady dweller vs. sporadic vs. seasonal patterns)
- Emotional depth progression (are moods becoming more reflective/transcendent?)

**What system infers:**
- User's natural spiritual rhythm (frequency, time of day preference, day patterns)
- User's formation progress (is emotional landscape shifting toward peace/hope?)
- User's engagement depth (prayer %, prayer frequency, prompt thoughtfulness)
- User's identity as dweller (who are they becoming through this practice?)
- User's theme evolution (what patterns are emerging? Are they cycling or progressing?)
- User's growth velocity (are they deepening or plateauing?)

**How Growth feeds Formation Intelligence to next pillars:**
- **← P4 (Journal Creation):** Growth displays customization choices (moods, tags) as data
- **← P6 (Formation Intelligence):** Growth displays themes + patterns that P6 detects
- **→ P8 (Notifications):** Emotional progression + theme data inform breakthrough recognition notifications, theme emergence nudges
- **→ P7 (Beta):** Growth engagement metrics (theme taps, settings edits) validate whether users feel their formation is visible
- **→ Today:** Growth data informs whether daily prompt should emphasize recent themes or introduce new ones

**Formation Intelligence value:**
- Growth makes Formation Intelligence visible to user: "Here's what we see emerging in your journey"
- Metrics feel affirming, not judgmental ("You've prayed 19 times" not "Prayer rate: 40%")
- Themes + emotional distribution help user see themselves forming, not just capturing
- Post-MVP: Color wheel + Steward Score + Glossary deepen this visibility into emotional maturity + spiritual vocabulary

---

## 4. Success Criteria

**Qualitative:**
- [ ] Users feel their spiritual formation is visible and valued
- [ ] Metrics feel affirming, not judgmental ("You've prayed X times" not "You prayed X% of captures")
- [ ] Users understand what each metric means
- [ ] Users find settings easily within Growth tab

**Quantitative:**
- [ ] >50% of users view Growth tab at least once in first 2 weeks
- [ ] >40% return to Growth weekly (weekly habit check-in)
- [ ] >30% adjust prayer frequency or notification preferences after viewing Growth
- [ ] Emotional Themes page has >3.5/5.0 satisfaction (survey: "Does this feel accurate to your journey?")
- [ ] Users who view Growth weekly show 2x higher prayer engagement (dwelling rate)

---

## 4. Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Tab name** | Growth (not "Trends" or "Insights") | Affirms formation journey, not just metrics; aligns with spiritual language |
| **Primary metric** | Total Captures + Total Prayers (not WAR or engagement %) | Users want to see their own accumulation, not comparative data |
| **Emotional data** | Emotional Themes + distribution (not individual mood entries) | Shows patterns user is living through, not individual moods |
| **Settings location** | Nested within Growth tab (not separate modal) | Settings are part of their growth context; keeps them discoverable |
| **Glossary (post-MVP)** | Shows extracted moods/topics/people/things (not manually entered) | Automatic extraction honors user's actual journey, not curated list |
| **Emotional depth (post-MVP)** | Color wheel visualization (surface to transcendent) | Visual, intuitive way to see emotional maturation |
| **Steward Score (post-MVP)** | Reddit karma-style metric (can go up/down) | Gamified but contextual to formation, encourages ongoing engagement |
| **Time range filtering** | Week / Month / All-time (default: current month) | Users want context ("this month I've prayed X times") |

---

## 5. Growth Tab Sections — Detailed Specs

### **Section 1: Formation Overview**

**Display:**
```
┌──────────────────────────────┐
│ FORMATION OVERVIEW           │
├──────────────────────────────┤
│                              │
│ Total Captures               │
│ 47 moments captured          │  [Statcard]
│                              │
│ Total Prayers                │
│ 19 times you've prayed       │  [Statcard]
│                              │
│ Prayer Engagement           │
│ 40% of moments dwelt on      │  [Statcard]
│                              │
│ Prayer Preference            │
│ Prayer 70% | Prompts 30%     │  [Statcard]
│                              │
│ [Time range filter]          │
│ This Month | This Year | All │  [Dropdown]
└──────────────────────────────┘
```

**MVP Features:**
- **Total Captures:** Lifetime count ("47 moments captured")
  - Visual: large number + icon
  - Tap for breakdown (moments/week trend) — *post-MVP detailed view*
  
- **Total Prayers:** Count of moments where user chose Prayer in prayer flow
  - Visual: large number + prayer icon
  - Metric affirms action ("You've offered 19 prayers")
  
- **Prayer Engagement:** % of captured moments with ANY prayer response (prayer OR prompts)
  - Calculation: (moments with prayer) / (total moments) × 100
  - Visual: percentage card with trend indicator (↑ improving, → stable, ↓ declining)
  - Affirms dwelling behavior
  
- **Prayer Preference:** Pie/split showing Prayer vs. Prompts engagement
  - "Prayer 70% | Prompts 30%" shows their natural reflection style
  - Affirms their archetype (Jotter/Venter/Processor)
  
- **Time Range Filter:** Dropdown to switch between This Month / This Year / All-time
  - Default: This Month (relevant, recent context)
  - Allows users to see patterns over different windows

---

### **Section 2: Emotional Themes**

**Display:**
```
┌──────────────────────────────┐
│ EMOTIONAL THEMES             │
│ How you're expressing heart  │
├──────────────────────────────┤
│                              │
│ Peaceful        ████░░░░░░   │ 12 moments
│ Hopeful         ███░░░░░░░░  │ 8 moments
│ Uncertain       ██░░░░░░░░░  │ 5 moments
│ Joyful          █░░░░░░░░░░  │ 2 moments
│ Wrestling       ██░░░░░░░░░  │ 4 moments
│                              │
│ [Tap a theme → see moments]  │
└──────────────────────────────┘
```

**MVP Features:**
- **Emotional Themes list:** Top 5-7 moods user has tagged in captures
  - Sourced from P4 mood selections during journal creation
  - Bar chart showing frequency (# of moments with that mood)
  - Visual affirmation: "You've felt peaceful 12 times this month"
  
- **Tap theme → detail view:** Shows all moments tagged with that emotion
  - Allows user to explore: "What patterns do I see when I feel peaceful?"
  - Invites dwelling on themes

- **Distribution insight:** "Peaceful dominates your emotional landscape"
  - One-sentence observation (not AI interpretation, just pattern recognition)

**Post-MVP Features:**
- **Color wheel (emotional depth):** Shows surface vs. deep emotions
  - Outer ring: reactive/surface emotions (frustrated, angry, anxious)
  - Middle ring: reflective emotions (grateful, hopeful, at peace)
  - Inner ring: transcendent/spiritual (encountering God, breakthrough)
  - Visualization: "You're spending more time in reflection. Your emotional range is deepening."

### Formation Intelligence Integration ("Your Narrative" + Intent/Rhythm editing)

**Note:** this doc predates the more recent Growth redesign (T-196) and does not yet reflect "Your Narrative," or Intent/Rhythm editing (moved here from Account Profile per T-195, Aug 31 2026), as surfaces of this pillar — added here only as an integration pointer, not a fix to this doc's broader staleness.

**Your Narrative (Row 6, Row 7):**
- "Your Narrative" is generated and updated by Formation Intelligence (P6), not by this pillar directly.
- When a user taps "Yes, that's me" or "Not quite" on their Narrative, call this **Narrative Confirmation** (not "Confirmation Loop" — that term is reserved for Dwelly's conversation loops). The tap triggers Formation Intelligence logic, not Growth's own.
- "Not quite" is rate-limited to once a month and, when used, immediately regenerates the Narrative — an exception to the normal monthly cadence.

**Intent editing (Row 4) — lives here, not Account Profile, as of Aug 31 2026 (T-195):**
- When a user edits Intent from Growth, it overwrites `DwellerProfile.statedIntent` directly — synchronous write, no LLM call. The change must propagate live (not cached) back into this same screen's Narrative display.
- Open items not yet locked: whether Intent changes should be rate-limited, and whether the prior value should be retained.
- Rhythm editing (also moved here per T-195) does **not** touch Formation Intelligence at all in MVP — self-reported data only, this pillar's own concern, not part of the `DwellerProfile` model.

Full mechanism: see `docs/PILLAR_6_FORMATION_INTELLIGENCE_TECHNICAL_SPEC.md`, Row 4, Row 6, and Row 7.

---

### **Section 3: Settings (Nested)**

**Display:**
```
┌──────────────────────────────┐
│ SETTINGS                     │
├──────────────────────────────┤
│ Prayer Frequency             │
│ [5x per week]                │  [Edit]
│                              │
│ Notification Preferences     │
│ [Manage]                     │  [Button]
│                              │
│ Theme (Post-MVP)             │
│ [Dark Mode]                  │  [Edit]
│                              │
│ [Gear icon for full settings]│
│ [All Settings]               │  [Link to Settings Pillar]
└──────────────────────────────┘
```

**MVP Features:**
- **Prayer Frequency (Quick Edit):** Show current setting + "Edit" button
  - Tap Edit → dropdown (Daily / 5x week / 3x week / Weekly / As it comes)
  - Quick access without routing to full Settings pillar
  
- **Notification Preferences (Link):** Button that routes to full notification settings
  - "Manage" button → opens notification preferences (from Settings pillar)
  
- **Full Settings Link:** "All Settings" link at bottom routes to Settings pillar modal
  - Allows access to password, encryption, legal, etc.

---

### **Section 4: Glossary (Post-MVP)**

**Display:**
```
┌──────────────────────────────┐
│ GLOSSARY                     │
│ Your Spiritual Vocabulary    │
├──────────────────────────────┤
│                              │
│ MOODS YOU'VE FELT            │
│ Peaceful, Hopeful, Uncertain │
│ Joyful, Wrestling, Grateful  │
│                              │
│ TOPICS IN YOUR HEART         │
│ Family, Work, Calling, Trust │
│ Prayer, Breakthrough, Doubt  │
│                              │
│ PEOPLE YOU PRAY FOR          │
│ Mom, James, Sarah's grief    │
│ Church community, boss       │
│                              │
│ THINGS THAT MATTER           │
│ Home, Scripture, Morning     │
│ stillness, Creation          │
│                              │
│ [Tap any item → see moments] │
└──────────────────────────────┘
```

**Post-MVP Features:**
- **Automatic extraction:** System extracts moods, topics, people, things from user's moments (no manual input)
- **Organized by category:** Moods | Topics | People | Things
- **Tap item → see moments:** "Family" → shows all moments mentioning family
- **Count display:** "Family (8 moments)" shows frequency
- **Spiritual vocabulary:** Shows user's language, not generic keywords

---

## 6. Alternatives Considered (Not Chosen)

| Alternative | Why Considered | Why Not Chosen |
|-------------|-----------------|-----------------|
| **Detailed trends charts** | Shows growth over time (visual, compelling) | MVP scope: stat cards simpler; charts post-MVP |
| **Comparative metrics** ("You're in top 10%") | Gamified, motivating | Dwellable is personal formation, not competitive; comparative data breaks trust |
| **Mood calendar heatmap** | Visual pattern (like GitHub contributions) | Post-MVP feature; MVP stat cards easier to parse |
| **Journaling streaks** | Motivational, proven pattern | Soft streak (prayer rhythm benchmark) not hard streak; deferring to P0 tickets |
| **Settings in separate modal** | Keeps Growth tab focused | Settings are contextual to growth; nesting them keeps discoverability high |
| **WAR metric (Weekly Active Reflections)** | Beta metric, important for us | Internal metric for founders; users care about "I prayed X times" not "% of active reflectors" |
| **Prayer depth (avg prompts per moment)** | Shows reflection intensity | Too abstract for MVP; emotional themes + engagement % simpler |

---

## 7. Metrics to Track

| Metric | Definition | Success Target |
|--------|-----------|-----------------|
| **Growth Tab Access Rate** | % of users viewing Growth weekly | >40% |
| **Formation Metrics Comprehension** | % of users who understand what each metric means (survey) | >80% |
| **Emotional Themes Engagement** | % of users who tap a theme to see moments | >30% |
| **Settings Edit Rate** | % of users who adjust prayer frequency or notifications from Growth | >30% in first month |
| **Emotional Themes Accuracy** | % of users who agree "these moods feel accurate to my journey" (survey) | >3.5/5.0 |
| **Glossary Interaction (post-MVP)** | % of users who tap glossary items to browse moments | >40% |
| **Prayer Engagement Correlation** | Users viewing Growth weekly show 2x higher prayer rate | 2x lift |
| **Growth Impact on WAR** | Users with >weekly Growth visits show >50% WAR | 50% threshold |

---

## 8. Implementation Approach

**Phase 1 (MVP Launch):**
- [ ] Build Growth tab shell with 2 sections (Formation Overview + Emotional Themes + Settings + Full Settings link)
- [ ] Implement Formation Overview section
  - Display Total Captures, Total Prayers, Prayer Engagement, Prayer Preference
  - Wire to UsageTracker data (analytics)
  - Add time range filter (This Month / This Year / All-time)
- [ ] Implement Emotional Themes section
  - Extract top 5-7 moods from user's P4 journals
  - Display bar chart (mood name + frequency)
  - Wire tap-to-detail view (show moments with that mood)
- [ ] Implement Settings subsection
  - Prayer frequency quick-edit + button
  - Notification preferences link
  - Full Settings link
- [ ] Wire Formation Overview cards to tap-for-detail (post-MVP; MVP = read-only cards)
- [ ] Test on device (iPhone 13+)

**Phase 2 (Post-MVP Polish):**
- [ ] Implement Glossary section (auto-extract moods, topics, people, things)
- [ ] Implement Color wheel (emotional depth visualization)
- [ ] Implement detailed trends (moments/week over time, prayer rate trend, etc.)
- [ ] Implement Steward Score (Reddit karma-style formation engagement metric)
- [ ] Add trend indicators (↑ ↓ → to show week-over-week change)

---

## 9. Tickets to Create

| Ticket | Title | Effort | Dependencies |
|--------|-------|--------|--------------|
| T-XXX | Build: Growth Tab Shell (4 sections, navigation) | M | T-076 (Menu Bar) |
| T-XXX | Build: Formation Overview Section (stat cards + time filter) | M | T-XXX, UsageTracker data ready |
| T-XXX | Build: Emotional Themes Section (bar chart + tap-to-detail) | L | T-XXX, P4 mood data captured |
| T-XXX | Build: Settings Subsection (prayer frequency + notification link) | S | T-XXX, Settings Pillar wired |
| T-XXX | Feature: Time Range Filter (This Month / Year / All-time) | S | T-XXX |
| T-XXX | Test: Growth Tab on device (iPhone 13+) | S | All sections |
| T-XXX (Post-MVP) | Feature: Glossary Section (auto-extract moods/topics/people) | L | NLP/extraction logic |
| T-XXX (Post-MVP) | Feature: Color Wheel (emotional depth visualization) | L | Mood depth classification |
| T-XXX (Post-MVP) | Feature: Steward Score (formation engagement metric) | M | Data model |

**Estimated effort (MVP):** 6 tickets, ~80–100 hours (2–2.5 weeks)  
**Estimated effort (Post-MVP additions):** 3 tickets, ~60–80 hours (1.5–2 weeks)

---

## 10. Risks & Constraints

| Risk | Impact | Mitigation |
|------|--------|-----------|
| **Metrics feel like gamification** | Users feel judged or compared | Affirming copy: "You've prayed 19 times" not "Prayer rate: 40%"; no comparative data |
| **Emotional Themes inaccurate** | Users don't trust extraction | Test with real users; ensure moods match P4 mood selections; solicit feedback in app |
| **Settings buried in Growth tab** | Users can't find notification preferences | Quick-access buttons + full Settings link; tooltip on first visit |
| **UsageTracker data not ready** | Can't populate Formation Overview | Use mock data for MVP; wire real data once UsageTracker complete (T-XXX) |
| **Time filter complexity** | Dropdown adds UX friction | Simple 3-option dropdown (This Month / Year / All-time); default to This Month |
| **Color wheel too abstract (post-MVP)** | Users don't understand emotional depth | Plain-language explanation + one-sentence insight ("You're deepening your reflection") |
| **Glossary extraction errors (post-MVP)** | Moods/topics extracted incorrectly | Start with high-confidence extraction (exact mood matches); expand with NLP over time |

---

## 11. Cross-Pillar Dependencies

- **Pillar 0 (Onboarding):** Growth displays prayer frequency from P0; links to edit prayer intent
- **Pillar 1 (Capture):** Growth counts total captures from P1
- **Pillar 4 (Journal Creation & Ownership):** Emotional Themes sourced from P4 mood selections
- **Menu Bar/Navigation:** Growth is Tab 4 (implementation only, T-076–T-082 — no dedicated pillar)
- **Pillar 6 (Formation Intelligence):** Post-MVP glossary + emotional depth leverage P6 theme detection
- **Pillar 9 (Account Profile / Settings) — UPDATED July 11, 2026:** Growth's top-right corner is the sole entry point (gear icon) to the full Pillar 9 Settings modal — not visible from Today/Entries/Create. Growth's own nested Settings subsection (§5.3: prayer frequency quick-edit, notification link) references the same underlying fields as Pillar 9's Preferences section; the "All Settings" link inside that subsection and the top-corner gear icon both route to the same Pillar 9 modal.
- **UsageTracker / Analytics:** Growth metrics depend on accurate tracking (separate infrastructure ticket)

---

## 12. Summary

| Aspect | Decision |
|--------|----------|
| **Goal** | Help users see their formation journey through affirming metrics and emerging patterns |
| **Tab Position** | 4th tab (Today \| Entries \| Create \| Growth) |
| **MVP Sections** | Formation Overview \| Emotional Themes \| Settings \| Full Settings Link |
| **MVP Metrics** | Total Captures, Total Prayers, Prayer Engagement, Prayer Preference, Emotional Themes |
| **Post-MVP** | Glossary (moods/topics/people/things), Color Wheel (emotional depth), Steward Score, Trends |
| **Success Metric** | >40% weekly growth visits, >80% metric comprehension, 2x prayer engagement lift |
| **Key blocker** | UsageTracker data ready; P4 mood selections accurate |

---

**Status:** Ready for ticket creation. All design decisions locked.

**Next:** Create implementation tickets (T-XXX–T-XXX) and assign to engineer.

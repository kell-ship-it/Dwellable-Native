# PILLAR: Today (Daily Reflection Dashboard)

**Pillar:** Today | **Updated:** May 14, 2026 | **Status:** Strategy Locked

---

## 1. Overview

- **Purpose:** Provide a personalized daily invitation to reflection, grounded in user's own moments + Scripture
- **Scope:** Personalized greeting, unprayed moments, daily biblical prompt, feature promotions (post-MVP)
- **Status:** Strategy locked, ready for implementation ticket creation
- **Tab Position:** 1st tab in main menu (Today | Entries | Create | Growth)

---

## 2. Product Purpose

**Why Today matters:**
- Users open the app and need an **affirming greeting** ("Mighty Man of God") not a generic prompt ("Welcome back")
- Today surfaces the **most recent unprayed moment** — implicit invitation: "Do you want to pray about this?"
- Daily biblical prompt (contextual to user's life) integrates Scripture as a **dwelling companion**, not a separate feature
- Today transforms from "list of moments" → "invitation to reflection"
- Post-MVP: Feature promotions slot (announce new features, celebrate milestones, invite feedback)

---

## 3. Formation Intelligence System

**What Today learns about the user:**
- Daily engagement pattern: When does user open the app? What time of day?
- Unprayed moment behavior: Does user respond to the invitation to dwell on recent moments?
- Daily prompt resonance: Which biblical themes resonate? (based on prompt engagement)
- Greeting receptivity: Does personalized greeting feel affirming or intrusive?

**What system infers:**
- User's formation rhythm (morning prayer person? Evening dweller?)
- User's responsiveness to invitation vs. mandate (do soft CTAs work better?)
- User's spiritual vulnerability (how quickly do they engage with biblical content?)
- User's emotional readiness for reflection (unprayed moments indicate incomplete processing)

**How Today feeds Formation Intelligence to next pillars:**
- **→ P3 (Soaking):** Signals readiness for prayer/reflection. Recent unprayed moment + daily prompt create two pathways into soaking.
- **→ P6 (Formation Intelligence):** Daily engagement pattern helps detect user's natural rhythm, informing when to surface themes/breakthroughs
- **→ Growth/Notifications (P8):** Daily prompt resonance data feeds personalization engine (which biblical themes to surface, when)

**Formation Intelligence value:**
- Today honors user's actual pace (morning person vs. evening reflector) by meeting them where they are
- Daily prompt contextuality powered by Rich Context + user's theme history = user feels "seen" not "preached to"

---

## 4. Success Criteria

**Qualitative:**
- [ ] Users feel welcomed, not passive ("Mighty Man of God" resonates)
- [ ] Most recent unprayed moment feels like an invitation, not a to-do
- [ ] Daily prompt feels contextual to user's journey, not generic
- [ ] Today tab orients user toward reflection (not distraction)

**Quantitative:**
- [ ] >80% daily open rate (primary entry point)
- [ ] >50% tap on unprayed moment (invitation acceptance rate)
- [ ] >40% engagement with daily prompt (dwelling initiation)
- [ ] <2 sec load time (app should feel snappy)
- [ ] >3.5/5.0 satisfaction: "Daily greeting feels personal to me" (survey)
- [ ] Users who see Today daily show 2x higher prayer engagement than non-daily users

---

## 4. Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Tab position** | 1st tab (Today \| Entries \| Create \| Growth) | Entrance experience; user opens app and sees reflection invitation first |
| **Greeting style** | Personalized + affirming ("Mighty Man of God" / "Hi Kell") | Generic greetings break trust; affirming language aligns with spiritual formation mission |
| **Unprayed moment display** | Most recent moment without prayer (1 prominent card) | Invites dwelling action; signals: "You captured this, now dwell?" Singular = clear focus |
| **Daily prompt source** | Biblical story/verse contextual to dweller's themes (Rich Context powered) | Scripture integration as dwelling companion, not separate feature; contextuality matters |
| **Prompt refresh cadence** | New prompt each day (7am or user timezone) | Consistent daily habit anchor; aligns with prayer rhythm |
| **Feature promotion (post-MVP)** | Slot below prompt for announcements, celebrations, feedback requests | Post-MVP enhancement; doesn't clutter MVP experience |
| **Soft CTAs (not hard)** | "Want to pray?" / "Read this?" (optional framing) | Affirming tone; honors user agency |

---

## 5. Today Tab Sections — Detailed Specs

### **Section 1: Personalized Greeting**

**Display:**
```
┌──────────────────────────────┐
│                              │
│ Mighty Man of God            │
│ (or: "Hi Kell")              │
│                              │
│ [Optional: reflection icon]  │
└──────────────────────────────┘
```

**MVP Features:**
- **Greeting text:** Personalized with user's name OR affirming statement
  - Options: "Mighty Man of God", "Beloved", "Seeker", "Dweller" (based on user's identity/intent)
  - Fallback: User's first name ("Hi Kell")
  - Sourced from: P0 Onboarding (name, theological framework, intent)
  - Visual: Large, affirming typography; no urgency language

---

### **Section 2: Most Recent Unprayed Moment**

**Display:**
```
┌──────────────────────────────┐
│ Want to pray about this?     │
├──────────────────────────────┤
│                              │
│ [Moment title]               │
│ [Brief excerpt or mood]      │
│ [Captured: 2 hours ago]      │
│                              │
│ [Tap to enter prayer/prompts]│
└──────────────────────────────┘
```

**MVP Features:**
- **Most recent unprayed moment:** Query all user's moments, filter for `has_soaking = false`, show most recent
  - Visual: Moment title (from P4), mood tag (from P4), timestamp relative ("2 hours ago")
  - Tap destination: Opens Soaking flow (P3) for that moment
  - Implicit message: "You captured this. Do you want to dwell?"
  - If no unprayed moments: Show empty state: "You've dwelt on everything. Capture something new?"

---

### **Section 3: Daily Prompt (Biblical + Contextual)**

**Display:**
```
┌──────────────────────────────┐
│ Prompt of the Day            │
├──────────────────────────────┤
│                              │
│ [Biblical story/verse]       │
│ [1-2 sentences explaining]   │
│ [Why this matters to YOUR    │
│  journey]                    │
│                              │
│ [Tap to dwell on this prompt]│
│ [Optional: Read full passage]│
└──────────────────────────────┘
```

**MVP Features:**
- **Daily biblical prompt:** Generated daily (7am or user timezone)
  - Content: Bible verse OR short biblical story (1-2 paragraphs)
  - Context: Generated via Rich Context (LLM)
    - Input: User's recent themes, intent, theological framework, current moment patterns
    - Output: Bible verse/story + plain-language explanation of why it matters to their journey
  - Example: User has been wrestling with doubt (theme detected) → Prompt shows story of Thomas doubting Jesus, with explanation: "You've been exploring doubt in your moments. Thomas's story is yours too."
  - Tap destination: Opens Soaking flow with this prompt as the dwelling text
  - Post-MVP: "Read full passage" link routes to full Bible text (if applicable)

**Post-MVP Enhancement:**
- **AI curation:** System learns which biblical passages resonate with user (based on engagement) and surfaces them more often
- **Seasonal/liturgical awareness:** Prompts align with liturgical calendar (Advent, Lent, Easter, etc.) if user opts in

---

### **Section 4: Feature Promotion Slot (Post-MVP)**

**Display:**
```
┌──────────────────────────────┐
│ What's New?                  │
├──────────────────────────────┤
│                              │
│ [Feature announcement]       │
│ [e.g., "Emotional Themes     │
│  are now live. Discover      │
│  patterns in your journey."] │
│                              │
│ [Tap to see feature]         │
│ [Dismiss]                    │
└──────────────────────────────┘
```

**Post-MVP Features:**
- **Feature announcements:** Celebrate new features (Color Wheel, Steward Score, Glossary, etc.)
  - Sourced from: Marketing/product team
  - Frequency: 1-2x per month (not overwhelming)
  - Dismiss: One-tap to hide
  - Tap destination: Routes to relevant new feature (e.g., "Emotional Themes" → Growth tab)
- **Milestone celebrations:** Celebrate user milestones ("You've prayed 50 times!" / "1 month of dwelling!")
  - Sourced from: UsageTracker data
  - Frequency: Once per milestone
  - Tone: Affirming, not gamified

---

## 6. Alternatives Considered (Not Chosen)

| Alternative | Why Considered | Why Not Chosen |
|-------------|-----------------|-----------------|
| **List of all today's moments** | Familiar pattern (note-taking apps) | Overwhelming; Today is invitation, not retrieval |
| **Generic "Welcome back" + empty state** | Minimalist | Loses affirming tone; doesn't leverage user data |
| **Moment carousel (swipe through)** | Engaging, visual | Too interactive; Today should focus reflection, not browsing |
| **Prayer streak counter** | Gamified motivation | Deferred per earlier decision; soft rhythm preferred over hard streak |
| **Random historical moment** | "Reminisce" pattern | Distracting; Today should focus forward (unprayed moment) not backward |
| **AI-generated daily reflection** | Personalized, introspective | Generic AI tone mismatches formation mission; Rich Context Scripture > AI reflection |
| **Multiple unprayed moments** | Show more opportunities | Overwhelming; singular focus honors user agency |
| **Auto-open Soaking for unprayed moment** | Reduces friction | Respects user agency; invite > mandate |

---

## 7. Metrics to Track

| Metric | Definition | Success Target |
|--------|-----------|-----------------|
| **Daily Open Rate** | % of users opening Today tab daily | >80% |
| **Unprayed Moment Engagement** | % of users tapping unprayed moment | >50% |
| **Prompt Engagement Rate** | % of users tapping daily prompt | >40% |
| **Greeting Satisfaction** | % of users who feel greeting is personal (survey) | >3.5/5.0 |
| **Prompt Relevance** | % of users who find prompt contextual to their journey (survey) | >3.5/5.0 |
| **Prayer Correlation** | Users with daily Today visits show X% higher prayer engagement | 2x lift |
| **Load Time** | Time to render Today tab | <2 sec |
| **Feature Promotion CTR (post-MVP)** | % of users tapping on feature announcements | >20% |

---

## 8. Implementation Approach

**Phase 1 (MVP Launch):**
- [ ] Build Today tab shell
- [ ] Implement Personalized Greeting
  - Query user's name from P0 Onboarding
  - Display affirming greeting (or fallback name)
- [ ] Implement Most Recent Unprayed Moment
  - Query moments where `has_soaking = false`, sort by date desc, show most recent
  - Display moment title (from P4), mood, timestamp
  - Wire tap → Soaking flow (P3)
  - Handle empty state ("You've dwelt on everything")
- [ ] Implement Daily Prompt
  - Set up daily generation (7am or user timezone)
  - Wire LLM to generate contextual prompt using Rich Context
    - Input: User's recent themes (P6), intent (P0), theological framework (P0)
    - Output: Bible verse/story + explanation
  - Cache prompt for 24 hours (avoid regenerating mid-day)
  - Wire tap → Soaking flow with prompt
- [ ] Wire Today as 1st tab in menu navigation
- [ ] Test on device (iPhone 13+)

**Phase 2 (Post-MVP Polish):**
- [ ] Implement Feature Promotion slot
  - Admin panel to create/schedule announcements
  - Display logic: One announcement at a time, rotates weekly
- [ ] Implement Milestone Celebrations
  - Track user milestones (prayer count, dwelling days, etc.)
  - Generate celebration messages on-demand
- [ ] Implement "Read Full Passage" link for biblical prompts
- [ ] Implement AI curation (learn which prompts resonate)
- [ ] Implement seasonal/liturgical awareness (optional)

---

## 9. Tickets to Create

| Ticket | Title | Effort | Dependencies |
|--------|-------|--------|--------------|
| T-XXX | Build: Today Tab Shell (4 sections, navigation) | M | T-076 (Menu Bar) |
| T-XXX | Build: Personalized Greeting (pull from P0) | S | T-XXX |
| T-XXX | Build: Most Recent Unprayed Moment (query + display) | M | T-XXX, P4 soaking data |
| T-XXX | Build: Daily Prompt (LLM generation + caching) | L | T-XXX, Rich Context system, P6 themes |
| T-XXX | Wire: Today Tab to Menu (1st position) | S | T-XXX (all sections) |
| T-XXX | Test: Today Tab on device (iPhone 13+) | S | All sections |
| T-XXX (Post-MVP) | Feature: Promotion Slot (announcements + celebrations) | M | T-XXX |
| T-XXX (Post-MVP) | Feature: Read Full Passage Link (Bible integration) | S | T-XXX |
| T-XXX (Post-MVP) | Feature: AI Curation (learn prompt preference) | M | T-XXX |

**Estimated effort (MVP):** 5 tickets, ~50–70 hours (1.25–1.75 weeks)  
**Estimated effort (Post-MVP additions):** 3 tickets, ~30–50 hours (1 week)

---

## 10. Risks & Constraints

| Risk | Impact | Mitigation |
|------|--------|-----------|
| **LLM prompt generation fails** | Daily prompt is generic or irrelevant | Use fallback prompt library (curated Bible verses); improve LLM context over time |
| **No unprayed moments** | Empty state feels lonely | Frame as success: "You've dwelt on everything. Capture something new?" Affirming tone |
| **Daily prompt generation too slow** | Shows stale prompt mid-day | Generate at 7am, cache for 24 hours; pre-generate next day's prompt at 11pm |
| **User timezone complexity** | Prompt generates at wrong time | Use user's device timezone (simpler than server-side TZ handling); worst case: everyone gets 7am UTC |
| **Rich Context not ready** | Can't generate contextual prompts | MVP with curated prompt library; wire Rich Context when ready (post-MVP enhancement) |
| **Greeting feels generic even with name** | User doesn't feel affirmed | Test language with real users; iterate if needed |
| **Feature promotions clutter experience** | Users dismiss announcements | Limit to 1-2x/month; careful messaging; link directly to feature |

---

## 11. Cross-Pillar Dependencies

- **Pillar 0 (Onboarding):** Today displays user's name, intent, theological framework from P0
- **Pillar 1 (Capture):** Today surfaces moments from P1
- **Pillar 3 (Soaking):** Tapping unprayed moment or prompt routes to P3 prayer/prompts flow
- **Pillar 4 (Journal Creation):** Today references soaking status + mood from P4
- **Pillar 6 (Formation Intelligence):** Daily prompt generated via Rich Context + user's themes (P6)
- **Growth Pillar:** Today can cross-promote Growth tab features (post-MVP)
- **Menu Bar:** Today is Tab 1 in navigation (Pillar 6 Menu responsibility)

---

## 12. Summary

| Aspect | Decision |
|--------|----------|
| **Goal** | Welcome user daily with affirming greeting + invitation to reflection (unprayed moment + Scripture) |
| **Tab Position** | 1st tab (entrance experience) |
| **3 Core Sections** | Personalized Greeting \| Unprayed Moment \| Daily Prompt |
| **MVP Scope** | Greeting + unprayed moment + contextual Bible prompt (LLM or curated fallback) |
| **Post-MVP Scope** | Feature promotions, milestone celebrations, full passage reading, AI curation, liturgical awareness |
| **Success Metric** | >80% daily opens, >50% unprayed moment engagement, >40% prompt engagement, 2x prayer lift |
| **Key blocker** | Rich Context system (P6) must be ready for contextual prompt generation |

---

**Status:** Ready for ticket creation. All design decisions locked.

**Next:** Create implementation tickets (T-XXX–T-XXX) and assign to engineer.

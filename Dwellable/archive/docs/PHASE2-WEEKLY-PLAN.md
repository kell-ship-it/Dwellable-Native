# Dwellable Phase 2 Strategy Week
## April 21–27, 2026

---

## Weekly Goals
1. **Define Phase 2 MVP scope** (features, non-features, timeline)
2. **Complete competitive + behavioral research** (note-taking, Bible apps, faith tools, LLM products)
3. **Synthesize learnings into design specs** for Phase 2a (reminder system, gallery view, onboarding)
4. **Identify technical blockers** and dependencies for May sprint

---

## Day 1: Monday, April 21 — Phase 1 Synthesis & Research Plan

### Morning (2h)
- **Read & annotate Phase 1 feedback themes**
  - Pull all user feedback from Airtable surveys and notes
  - Map to pain points vs. delights
  - Identify contradictions (e.g., "app is simple" vs. "onboarding too long")
  - Document in MEMORY.md under "Phase 1 User Themes"

### Afternoon (3h)
- **Research Plan Design**
  - Define research questions for each category:
    - **Note-taking apps:** How do Notion, Apple Notes, OneNote handle return/re-engagement? What prompts users back?
    - **Bible apps:** YouVersion, Olive Tree, Logos — how do they surface moments/passages? Reminder mechanisms?
    - **Faith tools:** Pray.com, Glorify, Abide — engagement loops? Reflection mechanics?
    - **LLM apps:** ChatGPT, Claude, Perplexity — how do they handle conversation history? Re-engagement with past content?
  - Create a research grid (app × category × insights) to fill during the week

---

## Day 2–3: Tuesday–Wednesday, April 22–23 — Deep Research Phase

### Tuesday: Note-Taking + Bible Apps (Full Day, 5h blocks)

**Morning Block (9am–12pm): Note-Taking Apps**
- [ ] Notion
  - How does it surface older notes?
  - Collaborative features (shared notes, comments) — relevance to reflection?
  - Template system — could inspire moment "re-frames"?
  - Reminder/notification system?

- [ ] Apple Notes
  - Folder organization — does it encourage re-reading?
  - Pin/star feature behavior — do users leverage it?
  - Collaboration features — impact on re-engagement?

- [ ] OneNote
  - Notebook hierarchy — how does depth affect return rate?
  - Search/discovery mechanisms?

**Afternoon Block (1pm–5pm): Bible Apps**
- [ ] YouVersion
  - How does reading history work?
  - Reminder system (plans, daily verses)?
  - Sharing/community features?
  - What drives daily return?

- [ ] Olive Tree
  - Cross-references and study tools — do they encourage deeper dwelling?
  - Highlighting/annotation — saved in history?
  - Sync across devices?

- [ ] Logos Bible Software
  - Research tool complexity — does it attract scholars?
  - How does it encourage return to passages?

**Capture for each app:**
- UI screenshot (note-taking: how are past notes displayed; Bible: how is history/reflection shown)
- Re-engagement mechanics (reminders, daily streaks, etc.)
- Friction points (onboarding, complexity, privacy)

---

### Wednesday: Faith-Based Tools + LLM Apps (Full Day, 5h blocks)

**Morning Block (9am–12pm): Faith-Based Tools**
- [ ] Pray.com
  - How does prayer history work?
  - Reminder system for prayer?
  - Community features?
  - Engagement metrics (daily DAU)?

- [ ] Glorify
  - Daily devotional mechanics?
  - Journaling features (if present)?
  - Re-read mechanisms?

- [ ] Abide
  - Meditation/dwelling-focused — how do they surface past sessions?
  - Subscription/paywall structure — impact on engagement?

- [ ] Sacred (or similar journaling app)
  - Prompt-based journaling — effectiveness?
  - Search/discovery of past entries?

**Afternoon Block (1pm–5pm): LLM Apps**
- [ ] ChatGPT
  - How does conversation history display work?
  - Do users return to past conversations? Evidence?
  - Folder/organization system?
  - Search functionality — critical to re-engagement?

- [ ] Claude (Web)
  - Similar questions — conversation history, return patterns
  - Project-based organization?

- [ ] Perplexity
  - Collections feature — do they drive re-engagement?
  - How is research history surfaced?

**Capture for each app:**
- Primary use case (are users coming back daily or sporadically?)
- History/archive UI and accessibility
- Reasons users return (reminders, habit, discovery, utility)
- Privacy/data handling (relevant for faith content)

---

## Day 4: Thursday, April 24 — Synthesis & Analysis

### Morning (3h): Research Grid Analysis
- Fill in research grid with findings from Tue–Wed
- Identify patterns across categories:
  - **Common re-engagement mechanics:** reminders, daily streaks, prompts, search
  - **Gaps:** Which apps handle reflection poorly?
  - **Surprises:** Unexpected learnings that change assumptions

### Afternoon (3h): Write Synthesis Document
- Document in `/Dwellable/docs/PHASE2-RESEARCH.md`:
  - Key findings per category (note-taking, Bible, faith, LLM)
  - Competitive analysis: What Dwellable should copy, avoid, improve
  - Insights for Phase 2 design (reminder timing, gallery UX, re-engagement loops)
  - Evidence for Monica (if faith apps succeed, Dwellable can too)

### Evening (1h): Update MEMORY.md
- Log research findings
- Flag any new blockers or dependencies discovered

---

## Day 5: Friday, April 25 — Phase 2 Scope & Design Specs

### Morning (4h): Phase 2 MVP Definition
- **Scope:** What ships in Phase 2a (May 15–20)?
  - Reminder/nudge system (scope: frequency, timing, on-device vs. server?)
  - Gallery view (scope: simple grid, thumbnail previews, search?)
  - Onboarding refresh (scope: 1-screen or 3-screen?)
  - **Non-scope:** AI theme surfacing, Bible verse prompts (defer to Phase 2b)

- **Success criteria:** Define what "return works" means
  - >50% re-read rate (measurable)
  - Avg <7 days to 2nd read
  - Weekly active users >70%

### Afternoon (4h): Design Specs Document
- Create `/Dwellable/docs/PHASE2A-DESIGN.md`:
  - **Reminder System:**
    - When to send (3 days after capture? Weekly digest?)
    - How many notifications (limit to avoid fatigue)?
    - Content (e.g., "You captured something about [topic] 3 days ago. Take a moment to dwell?")
  - **Gallery View:**
    - Grid vs. list — pros/cons
    - Filtering (by date, keyword, type)?
    - Thumbnail content (text snippet, first 50 chars?)
  - **Onboarding Refresh:**
    - Reduce screens from 3 → 1 or 2
    - Lead with value ("Capture God moments, return to dwell on them")
    - Privacy callout ("All on-device. No cloud storage of audio.")

- **Dependencies & Blockers:**
  - Reminder system requires: notification permission, scheduler on-device or server-side?
  - Gallery requires: refactor MomentsListView or new view?
  - Onboarding requires: how to migrate existing Phase 1 users?

---

## Day 6: Saturday, April 26 — Planning & Roadmap

### Morning (3h): Phase 2 Roadmap
- Create `/Dwellable/docs/PHASE2-ROADMAP.md`:
  - **Phase 2a (May 1–20):** MVP features (reminder system, gallery, onboarding refresh)
  - **Phase 2b (June 1–30):** Enhancements (AI theme surfacing, Bible verse prompts, search)
  - **Phase 3 (July+):** Return + formation (patterns, semantic search, optional biblical anchoring)

### Afternoon (3h): Ticket Creation & Backlog Refresh
- Create new tickets for Phase 2a work:
  - **T-060:** Design and implement reminder/nudge system
  - **T-061:** Refactor MomentsListView → Gallery view
  - **T-062:** Onboarding flow refresh (privacy-first messaging)
  - **T-063:** Phase 2a testing plan (re-read rate measurement)
  - **T-064:** Monica testimonial prep (case study from Phase 1)

- Reorder TICKETS.md to reflect Phase 2 priorities (move T-055 up, defer T-034)

### Evening (2h): Monica Follow-Up Prep
- Draft Phase 2 preview email to Monica (for mid-May):
  - Share Phase 2 research findings (faith apps analysis)
  - Confirm timeline for endorsement request (May 20)
  - Ask if she has advice on messaging (teaching hearing God vs. interpretation)

---

## Day 7: Sunday, April 27 — Review & Reflection

### Full Day (4h blocks, flexible)
- **Morning:** Review all documentation created during the week
  - PHASE2-RESEARCH.md: Does it answer research questions?
  - PHASE2A-DESIGN.md: Are specs clear and implementable?
  - PHASE2-ROADMAP.md: Is timeline realistic?

- **Afternoon:** 
  - Update MEMORY.md with weekly summary
  - Prepare "Phase 2 Ready" status for Kell
  - Create 1-page executive summary of key Phase 2 decisions

- **Deliverables:**
  - [ ] PHASE2-RESEARCH.md (findings + competitive analysis)
  - [ ] PHASE2A-DESIGN.md (MVP scope + design specs)
  - [ ] PHASE2-ROADMAP.md (6-month roadmap with milestones)
  - [ ] Updated TICKETS.md (Phase 2 backlog created, priorities reordered)
  - [ ] Monica follow-up email (ready to send May 20)

---

## Research Grid Template

| App | Category | Re-engagement | Friction | Privacy | Insight | Relevance to Dwellable |
|-----|----------|---------------|----------|---------|---------|------------------------|
| Notion | Note-taking | Push for collaborators → low for solo | Steep onboarding | Cloud-based | Collaboration drives return; solitude doesn't | Low (Dwellable is solo) |
| YouVersion | Bible | Daily verse plan + community | Many features | Cloud + tracking | Habit-loop works; community = engagement | High (implement daily habit) |
| ChatGPT | LLM | Folder system + search | Cluttered history | Uncertain | Search = rediscovery | Medium (gallery = search substitute) |

---

## Success Criteria for the Week

- [ ] Visited and analyzed 12+ apps (3–4 per category)
- [ ] Documented findings in structured format (grid + synthesis doc)
- [ ] Phase 2a MVP scoped and designed (3 core features defined)
- [ ] Phase 2 backlog created with realistic May timeline
- [ ] Zero blockers that prevent May sprint kickoff
- [ ] Monica follow-up email ready for mid-May send

---

## Notes for Session

- **Time investment:** ~35–40 hours for the week (research, analysis, design, documentation)
- **Deliverable quality:** Specs should be implementable by May 1 (no ambiguity)
- **Research rigor:** Capture screenshots and quotes, not impressions
- **Integration:** All findings feed directly into PHASE2A-DESIGN.md (no orphaned research)


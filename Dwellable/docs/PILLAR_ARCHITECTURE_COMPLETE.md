# Dwellable Pillar Architecture — Complete Overview

**Founder:** Kell Golden | **Status:** All Phase 2 Pillars Happy Paths Complete | **Updated:** May 7, 2026

---

## Executive Summary

Dwellable's Phase 2 Beta architecture consists of **9 pillars** (0-8, with Pillar 9 deferred):

| Pillar | Name | Status | Happy Paths | Design Doc | Phase 2? |
|--------|------|--------|-------------|-----------|---------|
| **0** | Onboarding (Sign-Up & Account) | ✅ Complete | 1 main path | PILLAR_ONBOARDING_STRATEGY.md | ✅ |
| **1** | Capture (Voice + Text) | ✅ Complete | 2 main paths | PILLAR_1_CAPTURE_STRATEGY.md | ✅ |
| **2** | Security & Privacy (E2E Encryption) | 🔄 In Progress | N/A (infrastructure) | PRD.md | ✅ |
| **3** | Soaking/Responding to Captures | ✅ Complete | 2 main paths | PILLAR_3_SOAKING_STRATEGY.md | ✅ |
| **4** | Journal Creation (Synthesis) | ✅ Complete | 1 main path (6 steps) | P4_SUMMARY.html | ✅ |
| **5** | Editing (Moment + Journal) | 🔄 Design In Progress | 5 paths | P5_EDITING_STRATEGY.md | ✅ |
| **6** | Search & Discovery | 🔄 Design In Progress | 6 paths | P6_SEARCH_STRATEGY.md | ✅ |
| **7** | Formation Intelligence (Patterns) | 🔄 Design In Progress | 5 paths | P7_FORMATION_INTELLIGENCE_STRATEGY.md | ✅ |
| **8** | Beta & Marketing | 🔄 Design In Progress | 7 paths | P8_BETA_MARKETING_STRATEGY.md | ✅ |
| **9** | Notifications & Nudges | ⭕ Deferred | TBD | PRD.md (Pillar 9 section) | ❌ Phase 3+ |

---

## Data Flow: Pillar Sequencing

```
User Opens App
    ↓
Pillar 0: Onboarding → (create account, set intent, set rhythm)
    ↓
Pillar 1: Capture → (record voice/text moment)
    ↓
Pillar 2: Security & Privacy → (E2E encrypt data in transit/at rest)
    ↓
Pillar 3: Soaking → (optional: pray or reflect with prompts)
    ↓
Pillar 4: Journal Creation → (LLM synthesis: title + body using Rich Context)
    ↓
Pillar 5: Editing → (optional: edit transcript, edit journal, delete)
    ↓
[User can now return via Pillars 6, 7, or check email/Discord for Pillar 8]
    ↓
Pillar 6: Search & Discovery → (find moments/journals via search or browse)
    ↓
Pillar 7: Formation Intelligence → (view themes, see patterns over time)
    ↓
(Return to Pillar 3 for re-dwelling on discovered moments)
    ↓
Pillar 8: Beta & Marketing → (provide feedback, join Discord, participate in cohort)
    ↓
[Pillar 9: Notifications - deferred to Phase 3+]
```

---

## Happy Path Summary by Pillar

### Pillar 0: Onboarding (✅ COMPLETE)
**1 Main Happy Path:** Welcome → Spiritual Intent → Prayer Rhythm → Account Setup → Privacy → First Capture Prompt

**Key Design Points:**
- 7-screen sequential flow
- Establishes psychological contract (formation tool, not productivity app)
- >90% completion target
- See: PILLAR_ONBOARDING_STRATEGY.md

---

### Pillar 1: Capture (✅ COMPLETE)
**2 Main Happy Paths:**
1. Voice-first: Tap mic → Speak → Transcribe → Review → Save
2. Text fallback: Type instead → Review → Save

**Key Design Points:**
- Voice-first with text fallback
- Rotating prompts to inspire reflection
- Offline-first architecture
- >100% adoption rate (Phase 1 validation)
- See: PILLAR_1_CAPTURE_STRATEGY.md

---

### Pillar 2: Security & Privacy (🔄 IN PROGRESS)
**Infrastructure (No user happy paths):** E2E Encryption, key derivation, sync

**Key Design Points:**
- AES-256-GCM encryption
- Argon2id key derivation from password
- Client-side encryption before cloud sync
- Row-Level Security on Supabase
- See: PRD.md Pillar 2 section

---

### Pillar 3: Soaking/Responding to Captures (✅ COMPLETE)
**2 Main Happy Paths:**
1. Prayer: Capture complete → Confirmation screen → Guided Prayer → Return
2. Prompts: Capture complete → Confirmation screen → Socratic Prompts → Return

**Key Design Points:**
- Rich Context powered (references user's story + themes)
- 2-option skeleton (Prayer + Prompts)
- Invitational framing ("Want to?", not "You should")
- Gallery + Soak Mode enables dwelling
- >40-50% WAR target by week 8
- See: PILLAR_3_SOAKING_STRATEGY.md

---

### Pillar 4: Journal Creation (✅ COMPLETE)
**1 Main Happy Path (6 Steps):**
Capture Complete → Confirmation Screen (Option A) → Guided Prayer (v1) → Journal Synthesis (background) → Dwelling Place Tab → Editing & Customization

**Key Design Points:**
- LLM synthesis: title (4-6 words) + body (2-3 paragraphs) using Rich Context
- Dwelling Place tab as primary journal home
- Photo management v1 (add/remove post-synthesis)
- Mood/tag selection (predefined palette)
- Soft delete capability
- AES-256-GCM encryption
- <2 sec synthesis latency target
- See: P4_SUMMARY.html

---

### Pillar 5: Editing (🔄 DESIGN IN PROGRESS)
**5 Main Happy Paths:**
1. Edit moment transcript (pre-synthesis)
2. Edit journal title & body (post-synthesis, detail view only)
3. Delete moment (soft delete, 30-day recovery)
4. Delete journal (soft delete, moment preserved)
5. Recover deleted moment/journal (optional, future)

**Key Design Points:**
- Edit transcript before synthesis, journal title/body after
- Detail view only (prevents accidental edits)
- Marked with `edited: true` flag
- Soft delete + 30-day recovery window
- Encourages re-capture over endless editing
- No edit history tracking (Phase 2)
- See: P5_EDITING_STRATEGY.md

---

### Pillar 6: Search & Discovery (🔄 DESIGN IN PROGRESS)
**6 Main Happy Paths:**
1. Full-text search (keywords across moments + journals)
2. Filter by date range (preset or custom picker)
3. Filter by mood/theme (checkboxes, multi-select)
4. Browse chronologically (gallery view by date)
5. Save/pin moments (favorites access)
6. Search by sense of Lord (spiritual content filter)

**Key Design Points:**
- Full-text search across transcripts + journal bodies
- Encrypted search index (searchable without decrypting library)
- Multi-filter combination (AND logic)
- Real-time results as user types
- Exclude soft-deleted items from results
- <200ms search latency target
- See: P6_SEARCH_STRATEGY.md

---

### Pillar 7: Formation Intelligence (🔄 DESIGN IN PROGRESS)
**5 Main Happy Paths:**
1. Discover emerging theme (3+ occurrence detection, Rich Context powered)
2. Explore themes in reflection (linked from Soaking)
3. Weekly theme summary (pull-based dashboard)
4. Filter search by theme (Pillar 6 integration)
5. Monthly formation review (arc of themes over time)

**Key Design Points:**
- Theme detection at 3+ occurrences
- Rich Context powered (user's language, not just keywords)
- Invitational framing ("What patterns do you notice?")
- No interpretation (user makes meaning)
- Timeline view of theme evolution
- Linked to moments + journals
- Integrated into Soaking prompts
- See: P7_FORMATION_INTELLIGENCE_STRATEGY.md

---

### Pillar 8: Beta & Marketing (🔄 DESIGN IN PROGRESS)
**7 Main Happy Paths:**
1. Beta user self-signup (form → waitlist → cohort invite → install)
2. Cohort enrollment & tracking (admin assigns users to cohorts)
3. In-app feedback collection (post-capture, post-dwelling surveys)
4. Structured interview process (1:1 interviews, bi-weekly)
5. Community engagement on Discord (share moments, feature requests)
6. Email engagement campaign (weekly digest, feature highlights, feedback requests)
7. Internal metrics dashboard (weekly review of WAR, retention, engagement)

**Key Design Points:**
- Closed beta (invite-only)
- Cohort structure: consistent reflectors (A) vs selective reflectors (B) vs waitlist (C)
- Analytics + surveys + interviews (quantitative + qualitative)
- Discord community platform
- Weekly email digest + bi-weekly feature highlights
- Success metric: WAR 40-50% by week 8
- Cohort start: 20-30 users per cohort, staggered rollout
- See: P8_BETA_MARKETING_STRATEGY.md

---

### Pillar 9: Notifications & Nudges (⭕ DEFERRED)
**Status:** Design deferred to Phase 3+ (post-beta)

**Rationale:** Need to validate all other pillars and dwelling behavior in Phase 2 before knowing what to notify users about.

**Concept (Draft):** Rich Context + pattern detection → contextual nudges when themes detected but not prayed over ("You reflected on anxiety, haven't prayed. Want to now?")

**See:** PRD.md Pillar 9 section

---

## Critical Architectural Features (Cross-Pillar)

### Rich Context (Product Principle)
- **Enables:** Personalized synthesis (P4), personalized prompts (P3), personalized nudges (P9)
- **Powers:** Theme detection (P7), formation understanding
- **Definition:** Use full conversation history + user themes to generate hyper-personalized experiences
- **Architecture:** LLM has access to user's moment archive + theme history when synthesizing/generating prompts

### Encryption (E2E, AES-256-GCM)
- **Applies to:** Moments (P1), Journals (P4), Themes (P7), Search index (P6), all user data at rest and in transit
- **Key Derivation:** Argon2id from user password
- **Client-Side:** Encrypt before sending to cloud, decrypt on-device
- **User Control:** User controls encryption key (they never leave device)

### Soft Delete (Recovery)
- **Applies to:** Moments (P5), Journals (P5)
- **Duration:** 30-day recovery window, then permanent deletion
- **User Control:** Users can recover deleted items within 30 days
- **Technical:** Flag `deleted: true` + `deletedAt: timestamp`, exclude from searches/lists

### User Segmentation (Beta)
- **Pillar 8:** Cohort A (consistent reflectors), Cohort B (selective reflectors), Cohort C (waitlist)
- **Rationale:** Different user segments engage differently; measure per-segment metrics
- **Metrics Tracked:** Activation, onboarding completion, first capture, WAR, retention, dwelling behavior

---

## Phase 2 Success Metrics (All Pillars)

### Primary Metric
- **Weekly Active Reflections (WAR):** 40-50% of beta users return weekly by week 8

### Secondary Metrics (by Pillar)
- **Pillar 0:** >90% onboarding completion, >80% first capture rate
- **Pillar 1:** >5 moments/user/week (engagement), >95% transcription accuracy
- **Pillar 3:** >40% prayer engagement, >30% prompt engagement
- **Pillar 4:** <2 sec synthesis latency, >4.0/5.0 satisfaction (survey)
- **Pillar 5:** <10% edit rate (indicates good synthesis quality), >4.0/5.0 delete UX satisfaction
- **Pillar 6:** >50% search adoption, >30% filter adoption, >80% search success rate
- **Pillar 7:** >50% theme engagement, >4.0/5.0 theme relevance (survey)
- **Pillar 8:** >20 signups/week, >80% conversion to installed, >50% cohort A retention week 4

### Qualitative Metrics
- User quotes: "I'm noticing God's presence more often"
- User quotes: "I see patterns in how God shows up"
- Net Promoter Score (NPS): >50
- Interview themes: [documented per cohort]

---

## Architectural Priorities for Implementation

### Must Have (Pillar 0-4)
1. Onboarding (Pillar 0) ← foundation
2. Capture (Pillar 1) ← core feature
3. Security & Encryption (Pillar 2) ← prerequisite for cloud sync
4. Soaking/Prayer & Prompts (Pillar 3) ← return mechanism (Phase 1 learning)
5. Journal Creation (Pillar 4) ← dwelling experience

### Important (Pillar 5-8)
6. Editing (Pillar 5) ← refinement, user control
7. Search & Discovery (Pillar 6) ← re-engagement, revisiting
8. Formation Intelligence (Pillar 7) ← pattern surfacing, spiritual formation
9. Beta & Marketing (Pillar 8) ← validation, community, iteration

### Deferred (Pillar 9)
10. Notifications & Nudges (Pillar 9) ← post-MVP, post-validation

---

## Next Steps

1. **Ticket Creation:** Create implementation tickets for Pillars 5-8 based on strategy docs
2. **Dependency Mapping:** Map all inter-pillar dependencies (which pillars must complete before others)
3. **Effort Estimation:** Estimate engineering hours per pillar (should be in strategy docs)
4. **Sequencing:** Determine implementation order (recommend: 0→1→2→3→4→6→5→7→8)
5. **Team Assignment:** Assign pillars to engineers based on expertise
6. **Design Handoff:** Designer creates mockups for Pillars 5-8
7. **LLM Research:** Finalize LLM selection (Gemini vs Mistral vs Claude vs OpenAI) for synthesis + theme detection + prompts

---

## Files Reference

| Pillar | Strategy File | Status |
|--------|-----------|--------|
| 0 | PILLAR_ONBOARDING_STRATEGY.md | ✅ Exists |
| 1 | PILLAR_1_CAPTURE_STRATEGY.md | ✅ Exists |
| 2 | PRD.md (Pillar 2 section) | ✅ Exists |
| 3 | PILLAR_3_SOAKING_STRATEGY.md | ✅ Exists |
| 4 | P4_SUMMARY.html | ✅ Exists |
| 5 | P5_EDITING_STRATEGY.md | ✅ NEW (Created May 7) |
| 6 | P6_SEARCH_STRATEGY.md | ✅ NEW (Created May 7) |
| 7 | P7_FORMATION_INTELLIGENCE_STRATEGY.md | ✅ NEW (Created May 7) |
| 8 | P8_BETA_MARKETING_STRATEGY.md | ✅ NEW (Created May 7) |
| 9 | PRD.md (Pillar 9 section) | ✅ Exists |

---

## Summary

✅ **All Phase 2 Pillars (0-8) now have documented happy paths.**

The architecture is complete in terms of design specification. Each pillar has:
- Clear happy path(s) documenting the user experience
- Locked decisions defining scope and approach
- Integration points with other pillars
- Success metrics and validation criteria
- Technical considerations and data models
- Next steps for design/engineering

**Ready for:** Implementation ticket creation, effort estimation, team assignment, design handoff.

**Deferred to Phase 3+:** Pillar 9 (Notifications & Nudges), post-MVP features, visual galleries, semantic search, AI recommendations.

# Dwellable Pillar Architecture — Complete Overview

**Founder:** Kell Golden | **Status:** ✅ Formation Intelligence System Complete (P0-P8); Ready for Implementation Sequencing | **Updated:** May 10, 2026

---

## Executive Summary

Dwellable's Phase 2 Beta architecture consists of **8 pillars** (0-7, with Pillar 8 deferred):

**Current Status:**
- ✅ **Pillars 0-7:** Formation Intelligence System COMPLETE. All pillars documented with integrated FI articulation.
  - P0-P1: Formation Intelligence locked + validated (earlier sessions)
  - P2-P3: Formation Intelligence locked + documented (May 7)
  - P4: Formation Intelligence locked + documented (May 10) — now combines Journal Creation + Ownership
  - P5-P7: Formation Intelligence locked + documented (May 10) — relabeled from P6-P8
- ⭕ **Pillar 8:** Deferred to Post MVP (Notifications & Nudges)

| Pillar | Name | Status | Happy Paths | Design Doc | Phase 2? |
|--------|------|--------|-------------|-----------|---------|
| **0** | Onboarding (Sign-Up & Account) | ✅ Complete | 1 main path | PILLAR_ONBOARDING_STRATEGY.md | ✅ |
| **1** | Capture (Voice + Text) | ✅ Complete | 2 main paths | PILLAR_1_CAPTURE_STRATEGY.md | ✅ |
| **2** | Security & Privacy (Server-Side Encryption) | 🔄 In Progress | N/A (infrastructure) | PRD.md | ✅ |
| **3** | Soaking/Responding to Captures | ✅ Complete | 2 main paths | PILLAR_3_SOAKING_STRATEGY.md | ✅ |
| **4** | Journal Creation & Ownership (Synthesis + Customization) | ✅ Complete | 1 unified path (9 steps) | PILLAR_4_JOURNAL_CREATION_AND_OWNERSHIP_STRATEGY.md | ✅ |
| **5** | Search & Discovery | 🔄 Design In Progress | 6 paths | P5_SEARCH_STRATEGY.md | ✅ |
| **6** | Formation Intelligence (Patterns) | 🔄 Design In Progress | 5 paths | P6_FORMATION_INTELLIGENCE_STRATEGY.md | ✅ |
| **7** | Beta & Marketing | 🔄 Design In Progress | 7 paths | P7_BETA_MARKETING_STRATEGY.md | ✅ |
| **8** | Notifications & Nudges | ⭕ Deferred | TBD | PRD.md (Pillar 8 section) | ❌ Post MVP |

---

## Data Flow: Pillar Sequencing

```
User Opens App
    ↓
Pillar 0: Onboarding → (create account, set intent, set rhythm)
    ↓
Pillar 1: Capture → (record voice/text moment)
    ↓
Pillar 2: Security & Privacy → (encrypt data at rest/in transit, server-managed key, transient decrypt for processing)
    ↓
Pillar 3: Soaking → (optional: pray or reflect with prompts)
    ↓
Pillar 4: Journal Creation & Ownership → (LLM synthesis + user customization)
    ↓ [User synthesizes journal, customizes headline/tags/moods, saves in same session]
    ↓
[User can now return via Pillars 5, 6, or check email/Discord for Pillar 7]
    ↓
Pillar 5: Search & Discovery → (find moments/journals via search or browse by tags/moods)
    ↓
Pillar 6: Formation Intelligence → (view themes, see patterns over time)
    ↓
(Return to Pillar 3 for re-dwelling on discovered moments)
    ↓
Pillar 7: Beta & Marketing → (provide feedback, join Discord, participate in cohort)
    ↓
[Pillar 8: Notifications - deferred to Post MVP]
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
**Infrastructure (No user happy paths):** Server-side encryption at rest, transient decrypt for processing, sync

**Key Design Points (updated July 22, 2026 — see docs/PILLAR_2_SECURITY_STRATEGY.md):**
- AES-256-GCM encryption
- Server-managed encryption key (independent of user password)
- Encrypted at rest; decrypted transiently for legitimate processing (display, LLM calls)
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

### Pillar 4: Journal Creation & Ownership (✅ COMPLETE)
**1 Unified Happy Path (9 Steps):**
Capture Complete → Confirmation Screen → Guided Prayer (v1) → Journal Synthesis (background) → Dwelling Place Tab View → Edit Headline → Customize Tags → Assign Mood → Finalize & Save

**Key Design Points:**
- LLM synthesis: title (4-6 words) + body (2-3 paragraphs) using Rich Context
- Title shared between Entry (conversation) and Dwelling Place (journal) tabs
- Customization: headlines (user-editable), tags (max 2, auto-suggested + custom), moods (8 preset + 1 custom), photos (add/remove)
- Personalized mood message generated
- Soft delete capability
- AES-256-GCM encryption
- <2 sec synthesis latency target
- <5 min customization flow target
- See: PILLAR_4_JOURNAL_CREATION_AND_OWNERSHIP_STRATEGY.md

---

### Pillar 5: Search & Discovery (🔄 DESIGN IN PROGRESS)
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

### Pillar 6: Formation Intelligence (🔄 DESIGN IN PROGRESS)
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

### Pillar 7: Beta & Marketing (🔄 DESIGN IN PROGRESS)
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

### Pillar 8: Notifications & Nudges (⭕ DEFERRED)
**Status:** Design deferred to Post MVP (post-beta)

**Rationale:** Need to validate all other pillars and dwelling behavior in Phase 2 before knowing what to notify users about.

**Concept (Draft):** Rich Context + pattern detection → contextual nudges when themes detected but not prayed over ("You reflected on anxiety, haven't prayed. Want to now?")

**See:** PRD.md Pillar 8 section

---

## Critical Architectural Features (Cross-Pillar)

### Trust Principle (Cross-Pillar)
- **Definition:** Every interaction is a trust-building or trust-breaking moment. Users share intimate spiritual and emotional content—the app's reliability, accuracy, and care in handling that content directly impacts Formation Intelligence.
- **Applies to:** All pillars, but especially Search (P5), where accurate results affirm understanding, and Encryption (P2), where security affirms safety.
- **Manifestations:**
  - **P5 (Search):** Fast, accurate results build trust. Slow search, irrelevant results, or missing moments breaks trust.
  - **P2 (Encryption):** Transparent security builds trust. Users must understand their data is theirs alone.
  - **P4 (Journal Synthesis):** Accurate synthesis (reflects their voice, not LLM voice) builds trust. Generic or misaligned synthesis breaks trust.
  - **P3 (Prayer & Prompts):** Contextual, non-generic responses build trust. Generic prayers break trust.
  - **P1 (Capture):** Reliable transcription and saving builds trust. Lost captures or transcription errors break trust.
- **Architecture Implication:** All systems must prioritize accuracy and user understanding over feature richness. A trusted, minimal feature set beats an untrusted, feature-rich one.

### Rich Context (Product Principle)
- **Enables:** Personalized synthesis (P4), personalized prompts (P3), personalized nudges (P9)
- **Powers:** Theme detection (P7), formation understanding
- **Definition:** Use full conversation history + user themes to generate hyper-personalized experiences
- **Architecture:** LLM has access to user's moment archive + theme history when synthesizing/generating prompts

### Encryption (Server-Side, AES-256-GCM)
- **Applies to:** Moments (P1), Journals (P4), Themes (P7), Search index (P6), all user data at rest and in transit
- **Key Management:** Server-managed, independent of user password (updated July 22, 2026 — supersedes old client-side E2E/Argon2id model)
- **Processing:** Encrypted at rest; decrypted transiently only for legitimate processing (display, LLM calls for Dwelly/Prayer/Journal synthesis) — never persisted as plaintext, never logged
- **User Promise:** "Your moments are secure with us" — protected from theft/unauthorized access, not a zero-knowledge guarantee

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
5. Journal Creation & Ownership (Pillar 4) ← dwelling experience + personalization

### Important (Pillar 5-7)
6. Search & Discovery (Pillar 5) ← re-engagement, revisiting, pattern discovery
7. Formation Intelligence (Pillar 6) ← pattern surfacing, spiritual formation
8. Beta & Marketing (Pillar 7) ← validation, community, iteration

### Deferred (Pillar 8)
9. Notifications & Nudges (Pillar 8) ← post-MVP, post-validation

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
| 4 | PILLAR_4_JOURNAL_CREATION_AND_OWNERSHIP_STRATEGY.md | ✅ NEW (Combined May 10) |
| 5 | P5_SEARCH_STRATEGY.md | ✅ Exists (relabeled from P6) |
| 6 | P6_FORMATION_INTELLIGENCE_STRATEGY.md | ✅ Exists (relabeled from P7) |
| 7 | P7_BETA_MARKETING_STRATEGY.md | ✅ Exists (relabeled from P8) |
| 8 | PRD.md (Pillar 8 section) | ✅ Exists (relabeled from P9) |

**Deprecated Files:**
- PILLAR_4_JOURNAL_CREATION_STRATEGY.md (merged into P4)
- PILLAR_5_EDITING_STRATEGY.md (merged into P4)

---

## Summary

✅ **Formation Intelligence System (P0-P7) COMPLETE**

All Phase 2 Pillars (0-7) now have:
- Documented strategy specifications with happy paths
- **Integrated Formation Intelligence articulation** (what pillar is, what it learns, what it communicates, how it prepares the next pillar)
- Clear architectural role within the 8-pillar Formation Intelligence cascade
- Locked design decisions and success metrics

**Architecture Complete:**
- **P0-P1 (Identity Foundation & Capture):** Formation Intelligence foundation. Establishes who user is and captures raw moments.
- **P2-P3 (Trust & Prayer Response):** Formation Intelligence enabler. Encryption builds trust; prayer seals moments and signals value to God.
- **P4 (Synthesis & Ownership):** Formation Intelligence building. Journal synthesizes AND user personalizes (combined pillar). User claims ownership in one session.
- **P5-P6 (Discovery & Pattern Naming):** Formation Intelligence deepening. Search reveals patterns; themes name patterns.
- **P7 (Validation & Celebration):** Formation Intelligence articulation & celebration. Beta validates the entire system works.

Each pillar document includes:
- Formation Intelligence System section (defining pillar's role in the cascade)
- Clear happy path(s) documenting the user experience
- Locked design decisions and tentative/TBD items
- Integration points with other pillars
- Success metrics and validation criteria
- Technical architecture and data models
- Open questions and deferred decisions

**Ready for:**
1. ✅ Formation Intelligence system validation with founder (completed May 10)
2. Implementation sequencing and ticket generation (next phase)
3. Effort estimation and team assignment
4. Design handoff for Pillars 5-7 UI/UX
5. LLM selection finalization (Gemini vs Mistral vs Claude vs OpenAI for synthesis, theme detection, prompts)

**Deferred to Post MVP:** Pillar 8 (Notifications & Nudges), post-MVP features, visual galleries, semantic search, AI recommendations.

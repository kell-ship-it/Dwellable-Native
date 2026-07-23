# Pillar Dependency Graph — Phase 2 Implementation Sequencing

**Status:** Locked for T-092 Phase 2 Launch Readiness — **all pillar designs (P0–P11) now complete as of July 23, 2026**
**Last Updated:** July 23, 2026 (P2 model corrected to server-side encryption; P6/T-062 dependency corrected — now blocks four pillars, not three; P7 design locked including Cohort A acquisition strategy; P7 positioned in build sequence; T-125 Crisis Protocol reclassified MVP and moved to P1 ownership, flagged as a critical-path timeline risk; critical path estimate validated against real ticket-level hours and recalibrated for the actual solo Kell + Claude Code execution model, not a fictional team — Owner Assignments table corrected accordingly; P3 and P4 broken into real tickets (T-145–T-159), superseding 4 stale P3 tickets; **Navigation Shell's stale T-077/T-080 also superseded (same collision pattern found a third time); P6 (T-160–164) and P7 Prep (T-165–167) ticketed for the first time; Auth verified already fully covered — sequencing (Gantt, Build Order, summary table) now references real ticket numbers throughout instead of pillar-level guesses**)

---

## 0. Numbering Correction (Read This First — July 21, 2026)

This document's original diagram, matrix, and build-order sections were written before the May 10, 2026 pillar renumbering fully propagated here, and use a stale scheme. Corrected mapping:

- What this doc originally called **"P6 (Menu Bar)"** is not a standalone pillar. Menu Bar/Navigation is a thin integration layer (the tab-hosting tickets T-076–T-082, confirmed July 11, 2026) — it hosts tabs designed by other pillars and doesn't get its own pillar number. Referred to below as the **Navigation Shell**.
- What this doc originally called **"P7 (Formation Intelligence)"** is **P6**, per the May 10, 2026 renumbering. All references below are corrected.
- **P7** is actually **Beta & Marketing** — not yet represented in this graph; not yet started (see TICKETS.md pillar sequence).
- **"Settings," "Today Tab," and "Growth Tab"** were originally informal supporting labels in this graph. They are now fully-designed pillars — **P9 (Account Profile)**, **P10 (Today)**, **P11 (Growth)** — each with a locked FigJam system design, User Scenarios/AC, and Technical Tools Needed audit. Referenced by their proper numbers below.

The historical audit corrections in §0-A predate this fix and use the old "P7 = Formation Intelligence" language in places — read them with this correction in mind rather than as contradictory.

---

## 0-A. July 9–10, 2026 Update — Findings From Per-Pillar Audits (Historical Record)

This graph was last substantively updated May 14, 2026 and predated several decisions made since. Rather than rewrite it wholesale at the time, this section reconciled what had changed; retained here as the historical audit trail.

**Process established here:** as each pillar's "User Scenarios + Acceptance Criteria" and "Technical Tools Needed" audit is completed (T-092 deliverable 4), fold any newly-discovered dependency directly into this graph at that time — not deferred to one big reconciliation pass at the end. This is what closed the May 8–15 memory-desync gap; the same discipline applies here so this graph doesn't go stale the same way. *(Note: it did go stale again on the pillar-numbering front — see §0 above. The discipline held for content; it didn't catch a renumbering that happened elsewhere. Worth remembering next time a pillar gets renumbered: grep this file too.)*

**Corrections/additions from the P1 (July 8) and P3 (July 9) audits:**

1. **LLM selection superseded.** §8 originally referenced "Gemini 2.0 Flash → Mistral 7B" — superseded May 15, 2026. **Actual locked decision: Groq Llama 3.3 70B (primary, free) → GPT-4o mini (backup, paid)**, via Vercel AI SDK. See the Notion "🧠 LLM Decision (LOCKED)" page.

2. **P2 (Encryption) is no longer a standalone pillar in the build sequence.** Encryption is a cross-cutting layer designed across every data-capturing pillar (capture, prayer, journal, settings), not a single isolated pillar. Engineering sequencing (§1/§2/§7) can still treat it as parallel-track infrastructure; the *design* work happens as a holistic audit after experience pillars are designed. T-062 (Server-Side Encryption implementation) remains a real, still-unstarted blocking ticket regardless. **Model updated July 22, 2026:** client-side E2E → server-side encryption at rest with transient decrypt for processing (see docs/PILLAR_2_SECURITY_STRATEGY.md).

3. **Cross-pillar blocker: P1 archetype inference → P3 Load Context.** P3's Rich Context step needs the user's archetype (Jotter/Venter/Processor) as input. P1's audit confirmed archetype inference is **not implemented in code** yet. P3 engineering cannot fully deliver contextual prayers until P1 ships this.

4. **Cross-pillar blocker: PrayerArtifact storage → T-062 (hard) + P4 JournalEntry model (soft).** Prayer artifacts must be stored with the journal entry, not merely linked to the moment. **(a)** PrayerArtifact cannot ship encrypted-at-rest until T-062 lands, and **(b)** the journal-embedding relationship depends on P4's JournalEntry model, which also does not exist in code yet. Recommend P3 ship with `journalEntryId`/resonance fields nullable/stubbed until both land.

5. **P3 MVP scope confirmed:** guided prayer only (no open-ended prompts MVP) — the "Prompts" alternative moved to Post-MVP.

**Corrections/additions from the P4 (July 9) audit:**

6. **T-062 confirmed zero code anywhere — single highest-leverage blocking ticket.** Hard-blocks both P3's PrayerArtifact and P4's JournalEntry encrypted storage. Recommend sequencing T-062 *before* either pillar's full implementation.

7. **Three pillars share an identical unbuilt dependency: LLM infrastructure.** P1 (Dwelly Agent loop), P3 (PrayerGenerationManager), P4 (JournalSynthesisManager) all need the same Groq → GPT-4o mini calling pattern via Vercel AI SDK. Build one shared, reusable service, not three.

8. **P4's Mood and Object pickers likely share one UI component.** Both are "N presets + 1 custom" patterns (Mood: 8 preset + inferred/overridable; Object: 6 preset + fully user-chosen). Build one generic preset+custom picker, reuse it.

9. **P4's prayer-embedding logic is a pure consumer of P3's resonance signal** — reads P3's `resonance` field directly, not `userEngaged`. One-way, read-only dependency.

10. **P4's synthesis error fallback was an open product decision** — since resolved: raw transcript stands in as the journal entry on synthesis failure (see P4 Notion page).

11. **Shared requirement: density-tiered AI generation (T-127)**, spanning Captures/Prayer/Journal/future Notifications. Input depth should scale output depth — never invented content to hit a fixed length. Reuses the **Reflective Density Model (L1–L8)**. Density *detection* is not implemented in code anywhere — a fourth pillar's worth of unbuilt dependency stacking on the same missing infrastructure.

**Corrections/additions from the P5 (July 10) audit:**

12. **P5 splits into two screens with very different dependency depths.** Screen 1 (calendar + month list) only needs P1's moments (`dateCreated`) — no encryption, no journals, no P3/P4 data. Screen 2 (dedicated Search page) depends on P4 (JournalEntry, Mood/Object taxonomy), P3 (resonance field), T-062 (encrypted index).

13. **P5's Prayed filter reads P3's resonance field directly** — a direct dependency, not merely inherited through P4.

14. **T-062 now confirmed to block a third pillar: P5's encrypted SearchableContent index.**

15. **P5's Filter UI depends on P4 building Mood/Object as a reusable component**, not merely on P4 shipping data.

16. **Two P5 decisions reduced dependency surface:** date range filter removed (redundant with Screen 1's calendar); Pinned paused.

17. **"Ask a Question" (Post-MVP, natural-language querying)** will depend on whatever LLM infrastructure P6 (Formation Intelligence) eventually builds. *(Corrected reference: originally said "P7" — that's P6 post-renumbering.)* Out of scope for P5 MVP.

18. **RESOLVED July 10, 2026: both P5 screens are MVP.** Screen 1 folded into T-078 (Navigation Shell's Entries tab spec). Screen 2 elevated to MVP as new ticket T-128, runs parallel to Navigation Shell/Today/Growth — MVP timeline unaffected.

19. **RESOLVED July 20, 2026: P8 (Notifications) reclassified to MVP.** All 7 stages (A–G) unified as originally designed — was "Deferred to Post-MVP." Directly addresses Phase 1's 0%-return finding.

---

## 0-B. July 21, 2026 Update — Pillar 6 (Formation Intelligence) MVP Scope Pivot

**Pillar 6 is no longer "theme detection" as its MVP deliverable.** MVP ships as the **Dweller Profile** — a single, continuously-evolving narrative understanding of the user (Wispr Flow "Your Voice"-inspired), reassessed on a threshold basis (not real-time, not edit-triggered), reading journal entries directly. Discrete named-theme detection (the original design — dashboard, weekly/monthly review, parent/child theme structure) is now Post-MVP. Full spec: Pillar 6's Notion page.

**Corrected dependency shape for P6:**
- **P6 depends on:** P0 (Intent/Rhythm, initial snapshot), P3 (prayer completion + resonance, plus the internal "Closing the Loop" signal), P4 (journal entries + Mood/Object tags — **primary read source**), P9 (Intent/Rhythm **updates** — the ongoing/living source, not just P0's one-time snapshot), **P2/T-062 (Encryption — real storage dependency, corrected July 23, 2026)**
- **P6 blocks:** P11 (Your Narrative display — **MVP**). Post-MVP, P6 also blocks P3 (in-prayer contextual theme prompts), P5 (theme-based filtering), P8 (v2 formation-aligned notification types), P10 (cross-entry Daily Prompt personalization)
- **P6 does NOT depend on P1 directly at MVP** — raw captures/transcripts are explicitly excluded as an FI input; only the synthesized journal entry (P4) counts. Archetype inference (P1, Jotter/Venter/Processor) is a Post-MVP input only.
- **🔄 CORRECTED July 23, 2026 — P6 DOES have a real data dependency on P2/T-062.** The Dweller Profile (narrative, mood arc, Object-tag frequency, etc.) is itself a persisted artifact derived from the user's spiritual data — it must be encrypted at rest like everything else, requiring its own encrypted storage. Previous claim that "P2 is a constraint, not a feed relationship" was wrong — P6 needs T-062's encryption infrastructure for its own storage layer, not just as a downstream consumer of P4's already-encrypted journals. **T-062 now confirmed to block four pillars: P3, P4, P5, P6** (was previously undercounted as three in places — see §8 and §10, corrected).

**Privacy correction:** the original P6 strategy doc's "on-device first" detection assumption is superseded — Formation Intelligence uses the same server-side/cloud LLM architecture already locked for Journal synthesis (P4) and Notifications (P8), not on-device processing. On-device was never realistic given the app doesn't run models locally.

**Capture-without-surfacing principle (locked):** P6's reassessment engine ingests all of the above inputs from MVP launch — including prayer completion/resonance and Intent/Rhythm updates — even though only a subset of possible outputs (narrative, mood arc, Object-tag frequency, Rhythm-match, resurfaced highlight) displays in P11 at MVP. This is a locked requirement on whatever ticket builds the engine, not an implicit assumption — feeding happens now so Post-MVP consumers aren't starting from a data backfill later.

**Prompt contextuality boundary (clarified July 21, 2026):** "contextual" at MVP means contextual *within a single conversation* (e.g., Dwelly referencing what was just said in that capture session). Contextual awareness *across* past reflections/journals — which is what P6's Dweller Profile enables — is a Post-MVP consumer relationship for P1, P3, and P10 alike.

---

## 0-C. July 20–21, 2026 Update — P8 and P11 Changes

**P8 (Notifications) reclassified to MVP** (July 20, 2026) — see §0-A.19. Stands as-is post-renumbering.

**P11 (Growth) amended** (July 21, 2026) — MVP is now three sections: **Your Narrative** (new — the P6 Dweller Profile's display surface), **Your Plain Stats** (renamed from "Formation Overview," otherwise unchanged), **Settings** (unchanged). **Emotional Themes removed from MVP** — redundant with P5 Search's already-locked Mood filter; no second entry point needed into the same data. P11's dependency on "theme data" (as this graph originally phrased it, attributing it to "P7") is corrected: **P11 depends on P6** for Your Narrative's content, full stop.

---

## 1. Dependency Graph (Visual, Corrected)

```
┌─────────────────────────────────────────────────────────────────────┐
│                     PHASE 2 BUILD SEQUENCE                          │
└─────────────────────────────────────────────────────────────────────┘

                          INFRASTRUCTURE LAYER
                          ┌────────────────────┐
                          │  Auth Pillar       │ (Gatekeeper)
                          └─────────┬──────────┘
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
                ▼                   ▼                   ▼
         ┌──────────────┐   ┌──────────────┐   ┌──────────────────┐
         │   P0         │   │    P2        │   │  Navigation Shell │
         │ Onboarding   │   │  Encryption  │   │ (T-076–082, hosts │
         │              │   │   (E2E)      │   │  tabs — not a     │
         └──────┬───────┘   └──────┬───────┘   │  standalone pillar│
                │                  │            └─────────┬─────────┘
                │ (enables)        │ (enables)             │ (routes to)
                ▼                  ▼                       ▼
         ┌──────────────┐          │              ┌──────────────────┐
         │   P1         │◄─────────┘              │  P9 Account      │
         │  Capture     │                         │  Profile /       │
         │              │                         │  Settings        │
         └──────┬───────┘                         └──────────────────┘
                │ (moments needed)
                ▼
         ┌──────────────┐
         │   P3         │──────────────┐ (Intent/Rhythm updates)
         │  Prayer      │              │
         └──────┬───────┘              ▼
                │ (prayer artifacts)  P9 also feeds P6 directly
                ▼                     (ongoing Intent/Rhythm source)
         ┌──────────────┐
         │   P4         │
         │  Journal     │
         │  Creation    │
         └──────┬───────┘
                │ (journal entries + tags — primary read source)
    ┌───────────┼──────────────┬─────────────────┐
    │           │              │                 │
    ▼           ▼              ▼                 ▼
┌─────────┐ ┌──────────┐ ┌───────────────┐  (P0/P3/P9 also feed P6 — see 0-B)
│  P5     │ │   P6     │ │  P10 Today    │
│ Search  │ │Formation │ │  (same-       │
│(Screen 2│ │  Intel   │ │  conversation │
│ Post-MVP│ │(Dweller  │ │  context only,│
│ theme   │ │ Profile, │ │  MVP; cross-  │
│ filter) │ │ MVP)     │ │  entry Post-  │
└─────────┘ └────┬─────┘ │  MVP)         │
                  │       └───────────────┘
                  │ (Your Narrative — MVP)
                  ▼
           ┌──────────────┐
           │  P11 Growth  │
           │ (Your        │
           │  Narrative,   │
           │  Plain Stats, │
           │  Settings)    │
           └──────────────┘

Post-MVP consumers of P6 (not on critical path): P3 (in-prayer prompts),
P5 (theme filter), P8 (v2 formation-aligned notifications), P10 (cross-entry prompt)
```

---

## 2. Dependency Matrix (Corrected)

| Pillar | Depends On | Blocks | MVP Critical? | Can Parallelize? |
|--------|-----------|--------|---------------|-----------------|
| **Auth** | None | Everything | ✅ YES | N/A (Gatekeeper) |
| **P0 (Onboarding)** | Auth | P1 | ✅ YES | No |
| **P2 (Encryption)** | Auth, P0 | All data ops | ✅ YES | Yes (infrastructure) |
| **P1 (Capture)** | P0, Auth, P2 | P3, P4, P10 | ✅ YES | No |
| **T-125 (Crisis Protocol)** | Bundled into P1's build (not standalone) — detection runs at capture time via OpenAI Moderation API | P3 (inherits non-refusal rule, no detection of its own) | ✅ YES — reclassified MVP + moved to P1 ownership, July 23, 2026 | No — critical path, adds real risk to P1's timeline (L–XL effort) |
| **P3 (Prayer)** | P1, P2 | P4, P8, P6 (input) | ✅ YES | No |
| **P4 (Journal)** | P1, P3, P2 | P5, P6, P11 | ✅ YES | No |
| **P5 (Search) — Screen 2 (Filters/Query)** | P1, P3 (resonance), P4 (JournalEntry, Mood/Object components), T-062 | None | ✅ YES — elevated to MVP July 10, 2026 | Yes (after P4, parallel to Navigation Shell/P10/P11) |
| **Navigation Shell (T-076–082, not a pillar)** | P0–P4 | Tab access | ✅ YES | Yes (after P4) — hosts P9/P10/P11's tabs; Entries tab (T-078) includes P5 Screen 1 |
| **P6 (Formation Intelligence — Dweller Profile)** | P0 (Intent/Rhythm), P3 (prayer + resonance), P4 (journals — primary), P9 (Intent/Rhythm updates), **P2/T-062 (own encrypted storage — corrected July 23, 2026)** | P11 (MVP); P3/P5/P8/P10 (Post-MVP) | ✅ YES (Dweller Profile only — see §0-B) | Yes (after P4 and T-062) |
| **P7 (Beta & Marketing)** | Prep work: none (can start immediately, parallel to everything). Full cohort activation: P0–P4 + Navigation Shell broadly functional | Public/wider beta launch | ✅ Design locked July 23, 2026; implementation not started | Prep: Yes (parallel, anytime). Activation: No (needs MVP-functional app) |
| **P8 (Notifications)** | P6 (v2, Post-MVP), P3 (v1, MVP) | None | ✅ YES — reclassified MVP July 20, 2026 | Yes (v1 after P3; v2 after P6) |
| **P9 (Account Profile)** | Auth, P0 | P6 (Intent/Rhythm feed), P8 (settings link) | ✅ YES | Yes (parallel) |
| **P10 (Today)** | P1, P3 | None (same-conversation context only, MVP) | ✅ YES | Yes (parallel); cross-entry Daily Prompt is Post-MVP, depends on P6 |
| **P11 (Growth)** | P1, P3, P4, **P6** | None | ✅ YES | Yes (after P6) |

---

## 3. Critical Path (Longest Dependency Chain)

```
Auth
    ↓ (1–2 weeks)
P0: Onboarding
    ↓ (2–3 weeks)
P1: Capture
    ↓ (2–3 weeks)
P3: Prayer
    ↓ (2–3 weeks)
P4: Journal Creation
    ↓ (1–2 weeks)
Navigation Shell (T-076–082) [tabs hosting P9/P10/P11, incl. P5 Screen 1]
    ↓ (1 week)
MVP LAUNCH ✅
```

**Critical Path Duration:** ~11–16 weeks, **at risk of extending** (July 23, 2026 — T-125 crisis protocol reclassified to MVP and bundled into P1, which sits on the critical path; L–XL effort ticket now shares P1's 2–3 week window. Recommend scoping T-125's MVP slice to the minimum safety floor — detection + compassionate response + resource surfacing — and deferring the fuller Formation Intelligence tie-in, to avoid extending the critical path)

**⚠️ Estimate basis validated + recalibrated (July 23, 2026):** This estimate was originally sized against a fictional multi-role team (see corrected §9 Owner Assignments below). Actual execution is **solo — Kell + Claude Code, no other engineers.** Recomputed from real ticket-level hour estimates (not pillar-level guesses) where they exist: Auth (~90–120h, per its own doc) + P0 (~60–90h, T-100–116) + P1 (~75–95h, T-118–124) + T-125 bundled (~30–50h estimate, no precise ticket hours yet) + Navigation Shell (~85–110h, T-076–082) ≈ **340–465 hours** for those five alone. At a **near-full-time pace (35–40 hrs/week, confirmed by Kell)**, that's ~9–13 weeks.

**✅ P3 and P4 ticket breakdowns complete (July 23, 2026)** — no longer pillar-level guesses. Also caught and fixed a real problem while doing this: TICKETS.md's old T-063–T-066 (Pillar 3 implementation tickets) described a **stale, superseded design** — user-typed prayers, a separate Socratic "Prompts" flow at MVP, and Rich Context/cross-moment history powering prompts at MVP. None of that matches what's actually locked (guided **LLM-generated** prayer only, Prompts is Post-MVP, Rich Context explicitly excluded from P3 at MVP). Those four are now marked superseded; **T-145–T-150** are the corrected P3 tickets, **T-151–T-159** are the new P4 tickets.
- **P3: ~51–75 hours** (T-145–T-150, plus already-ticketed T-124/T-119) — came in **lighter** than the original 2–3 week guess once broken into real tickets
- **P4: ~79–115 hours** (T-151–T-159) — roughly matches the original 2–3 week guess

**Recomputed full critical path:** Auth (~90-120h) + P0 (~60-90h) + P1+T-125 (~105-145h) + P3 (~51-75h) + P4 (~79-115h) + Nav Shell (~85-110h) ≈ **470–655 hours ≈ 12–16 weeks** at 35-40 hrs/week. This lands squarely inside — actually slightly better-grounded than — the original 11–16 week estimate, now with every pillar on the critical path backed by real ticket-level hours instead of guesses.

---

## 4. Parallelizable Work (Can Run Alongside Critical Path)

| Pillar | Start After | Duration | Notes |
|--------|------------|----------|-------|
| **P2 (Encryption)** | Auth | 2–3 weeks | Infrastructure; needed for data ops |
| **P9 (Account Profile)** | Auth | 2–3 weeks | Cross-cutting; independent |
| **P10 (Today)** | P1 (mid-way) | 1–2 weeks | Depends on P1 + P3; same-conversation context only at MVP |
| **P6 (Formation Intel — Dweller Profile)** | P4 (mid-way) | 2–3 weeks | Needs P0, P3, P4, P9 data flowing; builds the engine P11 displays |
| **P11 (Growth)** | P6 (mid-way) | 1–2 weeks | Displays Your Narrative once P6's engine can provide it |
| **P5 Search (Screen 2)** | P4 (T-062 already done by then) | 2–3 weeks | Elevated to MVP July 10, 2026. Screen 1 folded into Navigation Shell's T-078 |
| **P8 (Notifications)** | P3 (v1, MVP); P6 (v2, Post-MVP) | 2–3 weeks | Reclassified MVP July 20, 2026. v1 funnel-stage notifications don't need P6; v2 formation-aligned types do |

**Deferred to Post-MVP:**

| Pillar | Reason | Target Phase | Duration |
|--------|--------|--------------|----------|
| **Account Deletion** | Legal/compliance feature; not MVP-blocking | Phase 2.1 (post-launch) | 1 week |
| **Multi-device Sync** | Server-managed key simplifies this vs. old E2E model; still Phase 2+ scheduling | Post-MVP | TBD |
| **P6 fuller theme graph** | Discrete named themes, parent/child structure, dashboard/weekly/monthly review | Post-MVP | TBD |
| **P7 (Beta & Marketing) — full cohort activation** | Design locked July 23, 2026; needs P0–P4 + Navigation Shell broadly functional. Prep work (Discord setup, personal-outreach list, email templates, interview script) can start immediately in parallel — see §6/§7 | Post-MVP launch prep | TBD |

---

## 5. MVP vs. Post-MVP Breakdown

### MVP Launch (Critical Path + Parallel Infrastructure)

**Must Ship:**
- ✅ Auth Pillar
- ✅ P0 (Onboarding) — all 7 screens
- ✅ P1 (Capture) — voice + text, same-conversation contextual prompts
- ✅ P2 (Encryption) — server-side encryption at rest, server-managed key
- ✅ P3 (Prayer) — guided prayer only (no open-ended prompts MVP)
- ✅ P4 (Journal) — AI synthesis, mood selection
- ✅ Navigation Shell (T-076–082) — 4-tab hosting (Today, Entries, Create, Growth); Entries tab (T-078) includes P5 Screen 1
- ✅ **P5 Search Screen 2** — dedicated Search page: keyword + Mood/Object/Prayed filter shortcuts
- ✅ **P6 (Formation Intelligence) — Dweller Profile only** (MVP scope locked July 21, 2026; fuller theme graph is Post-MVP)
- ✅ P9 (Account Profile / Settings) — password change, notification prefs, legal links, Rhythm/Intent editing
- ✅ P10 (Today) — greeting, unprayed moments, same-conversation daily prompt
- ✅ **P11 (Growth) — Your Narrative, Your Plain Stats, Settings** (amended July 21, 2026 — Emotional Themes removed)
- ✅ **P8 (Notifications)** — reclassified MVP July 20, 2026, all 7 stages (A–G) unified; v1 funnel-stage only, v2 formation-aligned is Post-MVP

**Cannot Launch Without:**
- ✅ Auth, P0, P1, P3, P4 (core experience + core output)

### Post-MVP Phase 2.1 (Launch + 2 Weeks)

- ⏳ P6 fuller theme graph — discrete named themes, dashboard, weekly/monthly review, parent/child structure
- ⏳ P6 Post-MVP consumers activate: P3 in-prayer contextual prompts, P5 theme filtering, P8 v2 formation-aligned notifications, P10 cross-entry Daily Prompt
- ⏳ P11 Post-MVP additions: Archetype hero framing, Spiritual Gifts, "[Name]'s Language" (renamed from Glossary), Closing the Loop (uncategorized)
- ⏳ Account Deletion — self-service account removal with 30-day recovery
- ⏳ P7 (Beta & Marketing) — not yet started

### Phase 2.2 (Launch + 4–6 Weeks)

- ⏳ Multi-device sync (key distribution strategy)
- ⏳ Open-ended prayer option (user writes own prayer)
- ⏳ Email verification on sign-up
- ⏳ Biometric unlock (Face ID / Touch ID)
- ⏳ Data export (download moments as PDF/JSON)

---

## 6. Implementation Sequencing (Gantt-Style)

```
WEEK 1–2:    Auth Pillar ═════════════════════════════════════
             P7 Prep (T-165 outreach list, T-166 pitch script, T-167 Discord + contacts) ═ [Parallel — no dependencies, lowest-cost early start, ~6-13 hours total]
WEEK 3–4:    P0 (Onboarding) ════════════════════════════════
             P2 (Encryption) ════════════════════════════════  [Parallel — T-062, now blocks 4 pillars: P3/P4/P5/P6]
WEEK 5–6:    P1 (Capture) ═══════════════════════════════════
             ├─ T-125 (Crisis Protocol, bundled — OpenAI Moderation API + response) ══ [Same window, real timeline risk — L–XL effort]
             P9 (Account Profile) ═════════════════════════════ [Parallel]
WEEK 7–8:    P3 (Prayer) ═══════════════════════════════════
WEEK 9–10:   P4 (Journal) ═══════════════════════════════════
             P6 (T-160-164, ~56-80h) ══════════════════════════   [Parallel start, mid-P4, needs T-062 done by now]
WEEK 11–12:  Navigation Shell (T-076–082, incl. P5 Screen 1) ══
             P10 (Today) ═══════════════════════════════════════ [Parallel]
             P11 (Growth) ═══════════════════════════════════════ [Parallel, after P6]
             P5 Search Screen 2 (T-128) ══════════════════════   [Parallel]
             P8 (Notifications, v1 Stage A/B) ═══════════════   [Parallel — don't need P3/P6 fully]
WEEK 13:     P8 (Notifications, v1 Stage C–G, once P3 ready) ═══
             P7 Cohort A activation begins (direct personal outreach — doesn't need full public funnel) ═
             Testing, QA, Launch Prep
WEEK 14:     ✅ MVP LAUNCH (Cohort A already seeded via P7 personal outreach, not blocked on launch)

POST-LAUNCH (WEEK 15+):
             Account Deletion ══════════════════════════════════
             P6 fuller theme graph ═══════════════════════════════
             P8 v2 (formation-aligned, needs P6 fuller graph) ═════
             P7 Cohort B/C (public landing page + waitlist, Path 1) ═
```

---

## 7. Build Order (Recommended Sequencing)

**Phase 1: Gatekeeper + Foundation (Weeks 1–4)**

1. **Auth Pillar** (1–2 weeks) — already thoroughly ticketed (T-003 login/JWT, Phase 1, ✅ complete; T-109 signup; T-110 onboarding views incl. AccountView; T-111 schema; T-112 nav gate; T-113 dead-token handling; T-114 device test matrix; T-115 signup abuse protection; T-116 funnel analytics; T-067 forgot-password; T-131 password change) — verified July 23, 2026, no new tickets needed
2. **P0 Onboarding** (2–3 weeks, starts after Auth)
3. **P2 Encryption** (2–3 weeks, parallel to P0) — T-062, now confirmed to block **four** pillars (P3, P4, P5, P6 — corrected July 23, 2026, P6 storage dependency added)
3b. **P7 Prep** (ongoing, starts Week 1, zero dependencies) — **T-165** (outreach list, 2-4h), **T-166** (pitch script, 1-3h), **T-167** (Discord + church/ministry outreach, 3-6h). ~6-13 hours total. Lowest-cost, highest-lead-time item in the whole plan — no reason to wait on it.

**Phase 2: Core Pillars (Weeks 5–12)**

4. **P1 Capture** (2–3 weeks, starts after P0) — **bundles T-125** (Crisis Protocol: OpenAI Moderation API detection + compassionate response + 988/Crisis Text Line resource surfacing, all at capture time). Real risk this extends P1's window given L–XL effort; recommend scoping to the MVP safety floor only
5. **P3 Prayer** (~51–75 hours / ~1.5–2 weeks at full-time pace, starts after P1) — T-145 (Invitation UI) → T-146 (Load Context) → T-147 (PrayerGenerationManager) → T-148 (Reading screen + exit) → T-149 (Resonance + PrayerArtifact, hard-blocked on T-062) → T-150 (token accounting). Ticket-level breakdown replaces the old pillar-level guess July 23, 2026 — came in lighter than expected.
6. **P4 Journal Creation** (~79–115 hours / ~2–3 weeks, starts after P3) — T-151 (JournalSynthesisManager) → T-152 (JournalEntry model, hard-blocked on T-062) → T-153/T-154 (Mood/Object UI) → T-155 (two-tab UI) → T-156 (photo mgmt, parallel) → T-157 (resonance-gated embedding, depends on P3's T-149) → T-158 (soft delete) → T-159 (synthesis fallback). Ticket-level breakdown added July 23, 2026 — matches the original guess.
7. **Navigation Shell** (1–2 weeks, starts after P4) — T-076 (4-tab nav), T-078 (Entries tab, includes P5 Screen 1)

**Phase 3: Supporting Experiences (Weeks 6–12, Parallel)**

7b. **P5 Search — Screen 2** (2–3 weeks, starts after P4) — T-128
8. **P9 Account Profile** (2–3 weeks, parallel to P1)
9. **P6 Formation Intelligence — Dweller Profile** (~56–80 hours, starts mid-P4) — **T-160** (data model, blocked on T-062) → **T-161** (reassessment/threshold engine) → **T-162** (LLM generation, shares infra with P1/P3/P4) → **T-163** (confirmation loop UI, coordinate with P11's T-140) → **T-164** (Closing the Loop internal signal)
    - Build the reassessment engine per the input contract in §0-B (journals, tags, prayer completion/resonance, Intent/Rhythm) — not just what P11 displays
    - Threshold-based reassessment logic (Wispr-style, not real-time, not edit-triggered)
    - Confirmation loop (feeds future reassessment)
10. **P10 Today** (1–2 weeks, parallel to Navigation Shell) — same-conversation contextual prompt only at MVP
11. **P11 Growth** (1–2 weeks, starts after P6 has data to display)
    - Your Narrative (displays P6's Dweller Profile)
    - Your Plain Stats (Total Captures, Total Prayers)
    - Settings (nested)

**Phase 4: MVP Launch + Polish (Weeks 13–14)**

12. **Testing & QA** (1 week)
13. **Launch Prep & Go-Live** (1 week)

**Week 13 (parallel to Testing/QA):**

13b. **P7 Cohort A Activation** — direct personal outreach (15-20 known contacts) + Phase 1 dogfooding re-invite + curated church/ministry referrals. Doesn't wait for full launch polish; only needs the core experience (P0–P4) functional enough to demo/use.

**Post-MVP (Weeks 15+)**

14. **P8 Notifications v1** (2–3 weeks) — funnel-stage, doesn't need P6
15. **P6 fuller theme graph** — discrete named themes, dashboard, weekly/monthly review
16. **P8 v2, P3 in-prayer prompts, P5 theme filter, P10 cross-entry prompt** — all depend on #15
17. **Account Deletion** (1 week)
18. **P7 Cohort B/C** — public landing page + open waitlist (Path 1) activates once Cohort A is validating well; this is also when the locked FIFO waitlist decision starts to matter

---

## 8. Risk Dependencies (Critical Blockers)

| Risk | Mitigation | Responsible |
|------|-----------|-------------|
| ~~LLM selection not locked~~ **RESOLVED** | Groq Llama 3.3 70B (primary) → GPT-4o mini (backup), via Vercel AI SDK. Benchmarked July 4-5 (4,705 tokens/loop, ~$0.00084/loop). Token allocation locked July 9 (T-119). | CTO/LLM owner |
| **Supabase auth setup delayed** | Have Supabase project + auth tables ready before Auth pillar starts | Infra engineer |
| **Encryption T-062 not complete** | Confirmed hard blocker for P3, P4, P5, and P6's encrypted storage — **four pillars now** (P6 added July 23, 2026 — its Dweller Profile needs its own encrypted storage, not just a read dependency on P4). Highest-urgency ticket in this graph, still 🔲 Not Started with zero code | Crypto engineer |
| **LLM API integration slow** | P3 prayer generation needs low-latency LLM calls (<3s); test early against real Groq/GPT-4o mini latency | Backend/LLM owner |
| **Rich Context context size exceeds token limit** | Test P4 journal synthesis with large moment histories; may need chunking | LLM/Backend owner |
| **Decryption latency on device/server** | Target <200ms for display/processing use cases; test on slower devices | iOS engineer |
| **P1 archetype inference not built, blocks P3 context** | P1 must ship archetype inference before P3's Load Context step is contextually complete | iOS/Backend engineer |
| **PrayerArtifact storage blocked on T-062 + P4 JournalEntry model** | P3 ships with nullable/stubbed `journalEntryId` until both land | Backend engineer |
| **Three pillars (P1, P3, P4) each need identical unbuilt LLM infra** | Build one shared Groq→GPT-4o mini calling service, reuse across all three | Backend/LLM owner |
| **Density-tiered AI generation (T-127) needed across 4 surfaces, detection unbuilt** | Reflective Density Model (L1–L8) detection doesn't exist in code anywhere; build once as shared infra | Backend/ML engineer |
| **NEW (July 21): P6's Dweller Profile engine must ingest the full input contract, not just what P11 displays** | Explicit acceptance criteria on P6's build ticket must list journals, tags, prayer completion/resonance, and Intent/Rhythm updates as required inputs — not just journal entries, and not scoped down to only what's needed for P11's current display | Backend/ML engineer (P6 owner) |
| **NEW (July 21): P6/P7 numbering confusion risk** | This document itself had P6 and P7 swapped for months. Any new doc or ticket referencing "Formation Intelligence" or "Menu Bar" by pillar number should be double-checked against the Pillars index in Notion, not assumed from memory or older docs | Whoever's writing the next doc |
| **RESOLVED July 10, 2026:** P5 screen split — both MVP | Screen 1 folded into Navigation Shell's T-078; Screen 2 is T-128 | Kell (resolved) |
| **RESOLVED July 20, 2026:** P8 reclassified MVP | All 7 stages unified, v2 stays Post-MVP | Kell (resolved) |
| **RESOLVED July 21, 2026:** P6 MVP scope is the Dweller Profile, not theme detection | Fuller graph moves to Post-MVP | Kell (resolved) |
| **RESOLVED July 23, 2026:** P6/T-062 relationship corrected | P6 has a real storage dependency on T-062, not just a constraint — T-062 now blocks four pillars, not three | Kell (resolved) |
| **RESOLVED July 23, 2026:** P7 (Beta & Marketing) design locked | All 5 tentative decisions locked; Cohort A acquisition strategy locked (direct personal outreach, not public funnel); implementation not yet started | Kell (resolved) |
| **NEW (July 23, 2026): T-125 (Crisis Protocol) reclassified MVP + bundled into P1, adds real critical-path risk** | L–XL effort ticket now shares P1's 2–3 week window. Mitigation: scope T-125's MVP slice to the minimum safety floor (OpenAI Moderation API detection + compassionate response + 988/Crisis Text Line resources), defer the Formation Intelligence crisis_signal tracking (deliverable 7) to Post-MVP without extending P1 | iOS/Backend engineer (P1 owner) |

---

## 9. Owner Assignments — CORRECTED July 23, 2026

**This table previously proposed a fictional 6-8 role team (iOS Engineer, Backend Engineer, Crypto/Security Engineer, ML Engineer, QA Engineer, etc.) working in parallel. Actual execution model: solo — Kell + Claude Code, no other engineers.** This matters for the estimate above: work that a team could genuinely parallelize (P2 while someone else does P0, P9 while someone else does P1) still competes for the same one person's attention in practice, even when the dependency graph marks it "parallelizable." The roles below now describe *what kind of work* each pillar requires, not *who* does it — useful for knowing what skillset/mode you're in for that pillar, not for staffing.

| Component | Work Type (not a separate person) |
|-----------|--------|
| **Auth Pillar** | Backend/auth integration |
| **P0 Onboarding** | iOS/SwiftUI |
| **P1 Capture** | iOS + Backend/LLM integration |
| **P2 Encryption** | Security/crypto integration |
| **P3 Prayer** | Backend + LLM |
| **P4 Journal** | Backend + LLM |
| **P5 Search** | Backend |
| **Navigation Shell** | iOS/SwiftUI |
| **P6 Formation Intelligence** | ML/Backend |
| **P7 Beta & Marketing** | Founder-led personal outreach (genuinely Kell-only, not a coding task) |
| **P8 Notifications** | Backend + iOS |
| **P9 Account Profile** | iOS/SwiftUI |
| **P10 Today** | iOS/SwiftUI |
| **P11 Growth** | iOS + Backend |
| **E2E Testing** | Real-device QA — this one specifically **cannot be delegated to Claude Code**; it requires Kell's own hands-on-device time per the project's own WORKFLOW.md ("manual device testing preferred over simulator") |

---

## 10. Summary

| Aspect | Decision |
|--------|----------|
| **Critical Path** | Auth → P0 → P1 → P3 → P4 → Navigation Shell (11–16 weeks to MVP); P6, P9, P10, P11, P5-Screen2, P8 all run parallel, don't extend this chain |
| **MVP Launch** | Auth, P0–P4, Navigation Shell, P5-Screen2, **P6 (Dweller Profile only)**, P8 (v1), P9, P10, P11 |
| **Post-MVP** | Account Deletion, P6 fuller theme graph, P8 v2, P3 in-prayer prompts, P5 theme filter, P10 cross-entry prompt, P11's Archetype/Spiritual Gifts/"[Name]'s Language"/Closing the Loop, P7 (not yet started) |
| **Parallel Work** | P2, P9, P10, **P6**, **P11**, P5 Screen 2, P8 can all run alongside the critical path |
| **Deferred to Post-MVP** | Multi-device sync, open-ended prayer, email verification, biometric unlock |
| **Critical Blocker** | T-062 (encryption) blocks **four** pillars (P3, P4, P5, P6 — P6 added July 23, 2026) — highest-urgency ticket, still 🔲 Not Started. P1 archetype inference also a confirmed P3 blocker |
| **RESOLVED July 21, 2026** | Pillar numbering corrected throughout (P6 = Formation Intelligence, not Menu Bar; Menu Bar isn't a pillar). P6 MVP scope locked as the Dweller Profile. P11 amended (Your Narrative added, Emotional Themes removed) |
| **RESOLVED July 23, 2026** | P2 model locked as server-side encryption (not E2E). P6/T-062 dependency corrected (real, not just a constraint). P7 (Beta & Marketing) design fully locked — all pillar designs (P0–P11) now complete. Cohort A acquisition strategy locked: direct personal outreach, not public funnel; P7 Prep can start Week 1 in parallel with zero dependencies. T-125 (Crisis Protocol) reclassified MVP, ownership moved from orphaned "P3/P6" to **P1** (where free-form user text actually enters the system) — bundled into P1's build, adding real critical-path timeline risk (L–XL effort); mitigation is scoping to the minimum safety floor |
| **Longest Pillar Build** | P4 (Journal, ~79-115h, T-151-159) or P6 (Formation Intelligence engine, ~56-80h, T-160-164) — roughly 2-3 weeks each at full-time pace |
| **All tickets now exist** (July 23, 2026) | Every pillar on the critical path and every parallel-track pillar has real, individually-estimated tickets — no pillar-level guesses remain. Auth verified already covered (T-003/067/109-116/131); P6 (T-160-164) and P7 Prep (T-165-167) newly created; P3's stale T-063-066 superseded by T-145-150; Nav Shell's stale T-077/T-080 superseded, pointing to T-135-139/T-140-144 |

---

**Ready for sprint planning and owner assignment. This graph is the basis for T-092 completion.**

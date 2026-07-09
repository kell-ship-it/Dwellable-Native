# Pillar Dependency Graph — Phase 2 Implementation Sequencing

**Status:** Locked for T-092 Phase 2 Launch Readiness  
**Last Updated:** July 9, 2026 (reconciled with P1/P3/P4 Technical Tools Needed audits — see §0)

---

## 0. July 9, 2026 Update — Findings From Per-Pillar Audits (Read This First)

This graph was last substantively updated May 14, 2026 and predates several decisions made since. Rather than rewrite it wholesale, this section reconciles what's changed; the sections below retain their original content except where explicitly corrected inline.

**Process going forward:** as each pillar's "User Scenarios + Acceptance Criteria" and "Technical Tools Needed" audit is completed (T-092 deliverable 4), fold any newly-discovered dependency directly into this graph at that time — not deferred to one big reconciliation pass at the end. This is what closed the May 8–15 memory-desync gap; the same discipline applies here so this graph doesn't go stale the same way.

**Corrections/additions from the P1 (July 8) and P3 (July 9) audits:**

1. **LLM selection superseded.** This doc (§8 Risk Dependencies) still references "Gemini 2.0 Flash → Mistral 7B" — that was superseded May 15, 2026. **Actual locked decision: Groq Llama 3.3 70B (primary, free) → GPT-4o mini (backup, paid)**, via Vercel AI SDK. See the Notion "🧠 LLM Decision (LOCKED)" page.

2. **P2 (Encryption) is no longer a standalone pillar in the build sequence.** Per Kell's July 9 correction, encryption is a cross-cutting layer that must be designed across every data-capturing pillar (capture, prayer, journal, settings) — not a single isolated pillar slotted in parallel to P0. **This graph's treatment of P2 as a parallel-track pillar (§1 diagram, §2 matrix, §7 build order) is now considered directionally correct for engineering sequencing purposes (encryption infra can still be built early/in parallel) but the *design* work for P2 happens as a holistic audit after P1–P8 experience pillars are designed, not up front.** T-062 (E2E Encryption implementation) remains a real, still-unstarted blocking ticket regardless of when the design audit happens.

3. **New cross-pillar blocker discovered: P1 archetype inference → P3 Load Context.** P3's "Load Context" step (Rich Context, MVP-scoped to the immediate reflection only) needs the user's archetype (Jotter/Venter/Processor) as input. P1's own Technical Tools Needed audit (July 8) confirmed archetype inference is **not implemented in code** — it's inferred passively per the design, but no code does this yet. **P3 engineering cannot fully deliver contextual prayers until P1 ships this.** Not previously visible in this graph's P1→P3 arrow (§1), which only labeled the dependency "moments needed" — it's more specific than that.

4. **New cross-pillar blocker discovered: PrayerArtifact storage → T-062 (hard) + P4 JournalEntry model (soft).** This session locked that prayer artifacts must be **stored with the journal entry**, not merely linked to the moment. Two consequences not previously captured here: **(a)** PrayerArtifact cannot ship encrypted-at-rest until T-062 lands (hard blocker — same relationship P0's Screen 6 privacy copy already depends on), and **(b)** the journal-embedding relationship depends on P4's JournalEntry model existing, which — per the P3 audit's codebase search — **does not exist in code yet either**, despite P4's PRD status reading "Design Complete, Implementation Ready." Recommend P3 ship with `journalEntryId`/resonance fields nullable/stubbed until both land, rather than blocking P3 engineering entirely on P4 completing first.

5. **P3 MVP scope corrections not yet reflected below:** §5's "P3 (Soaking) — guided prayer only (no open-ended prompts MVP)" is **still accurate** — the July 9 FigJam session confirmed prayer-only for MVP and moved the "Prompts" (Socratic reflection) alternative to Post-MVP backlog, consistent with what this doc already assumed. No correction needed there.

**Corrections/additions from the P4 (July 9, same evening) audit:**

6. **T-062 confirmed to have zero code anywhere — now the single highest-leverage blocking ticket.** The P4 audit's codebase search (CryptoKit/AES/Argon2id patterns) returned zero matches, same as P3's. T-062 isn't just unstarted — there's no partial scaffolding on either side. It hard-blocks **both** P3's PrayerArtifact encrypted storage and P4's JournalEntry encrypted storage. Recommend T-062 be sequenced *before* either pillar's full implementation, not in parallel with them as §7's original build order assumed.

7. **Three pillars now share an identical unbuilt dependency: LLM infrastructure.** P1 (Dwelly Agent loop, T-120), P3 (PrayerGenerationManager), and P4 (JournalSynthesisManager) all need the same Groq Llama 3.3 70B → GPT-4o mini calling pattern via Vercel AI SDK. None of the three have built it yet. Recommend whichever pillar's engineering starts first builds one shared, reusable LLM-calling service — not three independent implementations. This wasn't visible as a shared risk until three separate audits converged on the same gap.

8. **P4's Mood and Object pickers likely share one UI component.** Both are "N presets + 1 custom" selection patterns (Mood: 8 preset + inferred/overridable; Object: 6 preset + fully user-chosen, not inferred). Worth building one generic preset+custom picker component and reusing it, rather than two bespoke UIs.

9. **New cross-pillar dependency: P4's prayer-embedding logic is a pure consumer of P3's resonance signal.** P4 does not independently decide whether to show "🙏 You prayed over this" — it reads P3's `resonance` field directly (not the `userEngaged`/"Prayed" field — see P3 Scenario 5 / P4 Scenario 3). This is a one-way, read-only dependency: P4 cannot be fully tested until P3's resonance field's exact shape is finalized, but P4 has no logic of its own to build here beyond the boolean check.

10. **P4's synthesis error fallback is an open product decision, not an engineering gap.** Per `P4_SUMMARY.html`'s own open questions list, whether a failed synthesis falls back to Entry-only, retries, or requires manual entry has never been decided. Flagged (not silently resolved) in P4's User Scenarios Scenario 4 — needs Kell's input before that scenario's acceptance criteria can be completed.

---

## 1. Dependency Graph (Visual)

```
┌─────────────────────────────────────────────────────────────────────┐
│                     PHASE 2 BUILD SEQUENCE                          │
└─────────────────────────────────────────────────────────────────────┘

                          INFRASTRUCTURE LAYER
                          ┌────────────────────┐
                          │  Auth Pillar       │ (Gatekeeper)
                          │  - Login           │
                          │  - Account Mgmt    │
                          └─────────┬──────────┘
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
                ▼                   ▼                   ▼
         ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
         │   P0         │   │    P2        │   │     P6       │
         │ Onboarding   │   │  Encryption  │   │   Menu Bar   │
         │              │   │   (E2E)      │   │ (Navigation) │
         └──────┬───────┘   └──────┬───────┘   └──────┬───────┘
                │                  │                  │
                │ (enables)         │ (enables)       │ (routes to)
                │                  │                  │
                ▼                  ▼                  ▼
         ┌──────────────┐          │         ┌──────────────┐
         │   P1         │◄─────────┘         │  Settings    │
         │  Capture     │                    │  (cross-cut) │
         │              │                    │              │
         └──────┬───────┘                    └──────────────┘
                │
                │ (moments needed)
                ▼
         ┌──────────────┐
         │   P3         │
         │  Soaking     │
         │  (Prayer)    │
         └──────┬───────┘
                │
                │ (prayer artifacts)
                ▼
         ┌──────────────┐
         │   P4         │
         │  Journal     │
         │  Creation    │
         └──────┬───────┘
                │
    ┌───────────┴──────────────┐
    │                          │
    ▼                          ▼
┌─────────────┐          ┌──────────────┐
│   P5        │          │   P7         │
│  Search     │          │  Formation   │
│  (Entries)  │          │  Intelligence│
└─────────────┘          └──────┬───────┘
                                │
                                │ (theme insights)
                                ▼
                         ┌──────────────┐
                         │   P8         │
                         │Notifications │
                         └──────────────┘

SUPPORTING LAYERS (Parallel to Core):
    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
    │  Today Tab   │  │ Growth Tab   │  │ Account Del  │
    │  (depends on │  │ (depends on  │  │  (Auth Pillar│
    │   P1, P3)    │  │  P1,P3,P4,P7)│  │   feature)   │
    └──────────────┘  └──────────────┘  └──────────────┘
```

---

## 2. Dependency Matrix

| Pillar | Depends On | Blocks | MVP Critical? | Can Parallelize? |
|--------|-----------|--------|---------------|-----------------|
| **Auth** | None | Everything | ✅ YES | N/A (Gatekeeper) |
| **P0 (Onboarding)** | Auth | P1 | ✅ YES | No |
| **P2 (Encryption)** | Auth, P0 | All data ops | ✅ YES | Yes (infrastructure) |
| **P1 (Capture)** | P0, Auth, P2 | P3, P4, Today | ✅ YES | No |
| **P3 (Soaking)** | P1, P2 | P4, P8 | ✅ YES | No |
| **P4 (Journal)** | P1, P3, P2 | P5, P7, Growth | ✅ YES | No |
| **P5 (Search)** | P4, P1 | None (optional) | ⏳ NO (Post-MVP) | Yes (after P4) |
| **P6 (Menu Bar)** | P0–P4 | Navigation | ✅ YES | Yes (after P4) |
| **P7 (Formation Intel)** | P1, P3, P4 | P8, Growth | ✅ YES | Yes (after P4) |
| **P8 (Notifications)** | P7, P3 | None | ⏳ NO (Post-MVP) | Yes (after P7) |
| **Settings** | Auth, P0, P8 | None | ✅ YES | Yes (parallel) |
| **Today Tab** | P1, P3 | None | ✅ YES | Yes (parallel) |
| **Growth Tab** | P1, P3, P4, P7 | None | ✅ YES | Yes (after P7) |

---

## 3. Critical Path (Longest Dependency Chain)

The critical path determines minimum time to MVP launch. Each pillar on this path must complete before the next can start.

```
Auth (T-XXX)
    ↓ (1–2 weeks)
P0: Onboarding (T-076, T-077, T-078)
    ↓ (2–3 weeks)
P1: Capture (T-079, T-080)
    ↓ (2–3 weeks)
P3: Soaking/Prayer (T-082, T-083)
    ↓ (2–3 weeks)
P4: Journal Creation (T-084, T-085)
    ↓ (1–2 weeks)
P6: Menu Bar (T-088, T-089) [OR P5 if omitting P6 from MVP]
    ↓ (1 week)
MVP LAUNCH ✅
```

**Critical Path Duration:** ~11–16 weeks (MVP launch, core pillars only)

---

## 4. Parallelizable Work (Can Run Alongside Critical Path)

These pillars can be built in parallel with the critical path, not blocking launch:

**Parallel to Critical Path:**

| Pillar | Start After | Duration | Notes |
|--------|------------|----------|-------|
| **P2 (Encryption)** | Auth | 2–3 weeks | Infrastructure; needed for data ops |
| **Settings** | Auth | 2–3 weeks | Cross-cutting; independent |
| **Today Tab** | P1 (mid-way) | 1–2 weeks | Depends on P1 + P3; can start when both are feature-complete |
| **P7 (Formation Intel)** | P4 (mid-way) | 2–3 weeks | Needs P1, P3, P4 data; can start once core pillars have data flowing |
| **Growth Tab** | P7 (mid-way) | 1–2 weeks | Visualization; starts after P7 can provide theme data |

**Deferred to Post-MVP:**

| Pillar | Reason | Target Phase | Duration |
|--------|--------|--------------|----------|
| **P5 (Search)** | Nice-to-have; P4 journals exist without it | Phase 2.1 (post-launch) | 2–3 weeks |
| **P8 (Notifications)** | Requires P7 themes; can launch without push notifications | Phase 2.1 (post-launch) | 2–3 weeks |
| **Account Deletion** | Legal/compliance feature; not MVP-blocking | Phase 2.1 (post-launch) | 1 week |
| **Multi-device Sync** | E2E encryption + key distribution; Phase 2+ only | Phase 3 | TBD |

---

## 5. MVP vs. Post-MVP Breakdown

### MVP Launch (Critical Path + Parallel Infrastructure)

**Must Ship:**
- ✅ Auth Pillar (login, account creation, password reset, account recovery)
- ✅ P0 (Onboarding) — all 7 screens
- ✅ P1 (Capture) — voice + text, contextual prompts
- ✅ P2 (Encryption) — E2E encryption, key derivation
- ✅ P3 (Soaking) — guided prayer only (no open-ended prompts MVP)
- ✅ P4 (Journal) — AI synthesis, mood selection
- ✅ P6 (Menu Bar) — 4-tab navigation (Today, Entries, Create, Growth)
- ✅ Settings — password change, notification prefs, legal links
- ✅ Today Tab — entry experience, unprayed moments, daily prompt
- ✅ Growth Tab — formation metrics, emotional themes, settings

**Cannot Launch Without:**
- ✅ Auth (can't use app without login)
- ✅ P0 (can't use app without account creation + intent)
- ✅ P1 (nothing to do without capture)
- ✅ P3 (core experience; sealing moments is core value prop)
- ✅ P4 (journals embed prayers; core output)

### Post-MVP Phase 2.1 (Launch + 2 Weeks)

**Add Shortly After:**
- ⏳ P5 (Search) — allow users to find moments
- ⏳ P7 (Formation Intelligence) — theme detection
- ⏳ P8 (Notifications) — theme breakthroughs, re-dwelling invitations
- ⏳ Growth Tab Theme Exploration — tap theme to see moments
- ⏳ Account Deletion — self-service account removal with 30-day recovery

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
WEEK 3–4:    P0 (Onboarding) ════════════════════════════════
             P2 (Encryption) ════════════════════════════════  [Parallel]
WEEK 5–6:    P1 (Capture) ═══════════════════════════════════
             Settings ════════════════════════════════════════  [Parallel]
WEEK 7–8:    P3 (Soaking) ═══════════════════════════════════
             P7 (Formation Intel) ══════════════════════════    [Parallel start]
WEEK 9–10:   P4 (Journal) ═══════════════════════════════════
             P7 (Formation Intel) ═══════════════════════════  [Parallel end]
WEEK 11–12:  P6 (Menu Bar) ══════════════════════════════════
             Today Tab ════════════════════════════════════════  [Parallel]
             Growth Tab (without themes) ═════════════════════  [Parallel]
WEEK 13:     Testing, QA, Launch Prep
WEEK 14:     ✅ MVP LAUNCH

POST-LAUNCH (WEEK 15–16):
WEEK 15–16:  P5 (Search) ════════════════════════════════════
             P8 (Notifications) ════════════════════════════════  [Parallel]
             Account Deletion ══════════════════════════════════  [Parallel]
```

---

## 7. Build Order (Recommended Sequencing)

**Phase 1: Gatekeeper + Foundation (Weeks 1–4)**

1. **Auth Pillar** (1–2 weeks)
   - T-XXX: Supabase auth integration
   - T-XXX: Login screen
   - T-XXX: Account creation (P0 integration)
   - T-XXX: Forgot password + password reset
   - T-XXX: Password change + sign out

2. **P0 Onboarding** (2–3 weeks, starts after Auth)
   - T-076: Screens 1–4 (Welcome, Education, Intent, Rhythm)
   - T-077: Screen 5 (Account creation integration)
   - T-078: Screens 6–7 (Privacy, Notifications, First capture mandate)

3. **P2 Encryption** (2–3 weeks, parallel to P0)
   - T-062: E2E encryption implementation (Argon2id, AES-256-GCM)
   - T-XXX: Keychain integration
   - T-XXX: Encryption key derivation on login/signup

**Phase 2: Core Pillars (Weeks 5–12)**

4. **P1 Capture** (2–3 weeks, starts after P0)
   - T-079: Voice capture + transcription
   - T-080: Text capture + contextual prompts

5. **P3 Soaking/Prayer** (2–3 weeks, starts after P1)
   - T-082: Prayer generation (LLM integration)
   - T-083: Soaking flow (prayer display + engagement signal)

6. **P4 Journal Creation** (2–3 weeks, starts after P3)
   - T-084: LLM synthesis (title + body generation)
   - T-085: Journal artifact creation + mood selection

7. **P6 Menu Bar** (1–2 weeks, starts after P4)
   - T-088: 4-tab navigation (Today, Entries, Create, Growth)
   - T-089: Tab routing + persistence

**Phase 3: Supporting Experiences (Weeks 6–12, Parallel)**

8. **Settings** (2–3 weeks, parallel to P1)
   - T-090: Settings modal (5 sections: Account, Security, Preferences, Support, Legal)
   - T-091: Integration with gear icon, prayer frequency, notification prefs

9. **P7 Formation Intelligence** (2–3 weeks, starts mid-P4)
   - T-XXX: Theme detection (from journals + captures)
   - T-XXX: Formation metrics calculation
   - T-XXX: Emotional landscape analysis

10. **Today Tab** (1–2 weeks, parallel to P6)
    - T-XXX: Entry experience (greeting, unprayed moments, daily prompt)
    - T-XXX: Integration with P1 + P3 data

11. **Growth Tab** (1–2 weeks, parallel to P6)
    - T-XXX: Formation Overview (captures, prayers, soaking %, preference)
    - T-XXX: Emotional Themes (without P7 integration, use P4 mood data)
    - T-XXX: Settings subsection

**Phase 4: MVP Launch + Polish (Weeks 13–14)**

12. **Testing & QA** (1 week)
13. **Launch Prep & Go-Live** (1 week)

**Post-MVP (Weeks 15–18)**

14. **P5 Search** (2–3 weeks) — Start after MVP
15. **P8 Notifications** (2–3 weeks) — Parallel to P5
16. **Account Deletion** (1 week) — Parallel to P5/P8

---

## 8. Risk Dependencies (Critical Blockers)

| Risk | Mitigation | Responsible |
|------|-----------|-------------|
| ~~LLM selection not locked~~ **RESOLVED** | ~~Lock Gemini 2.0 Flash → Mistral 7B~~ — **Superseded May 15, 2026: Groq Llama 3.3 70B (primary) → GPT-4o mini (backup), via Vercel AI SDK.** Live-benchmarked July 4-5 (4,705 tokens/loop, ~$0.00084/loop). Token allocation across Dwelly/prayer/journal locked July 9 (T-119). | CTO/LLM owner |
| **Supabase auth setup delayed** | Have Supabase project + auth tables ready before Auth pillar starts | Infra engineer |
| **Encryption T-062 not complete** | P2 (redesigned as cross-cutting audit, not standalone pillar) must complete before P1 ships data; also now a confirmed hard blocker for P3's PrayerArtifact encrypted storage (see §0.4) | Crypto engineer |
| **LLM API integration slow** | P3 prayer generation needs low-latency LLM calls (<3s per PILLAR_3_SOAKING_STRATEGY.md); test early against real Groq/GPT-4o mini latency for the prayer-generation prompt shape specifically | Backend/LLM owner |
| **Email service unreliable** | Password reset emails must deliver >99%; use SendGrid or Supabase email function | Email infra owner |
| **Rich Context context size exceeds token limit** | Test P4 journal synthesis with large moment histories; may need chunking strategy | LLM/Backend owner |
| **Key derivation too slow on device** | Argon2id ~1 second on iPhone 13; test on slower devices (iPhone 12) | iOS engineer |
| **Theme detection accuracy low** | P7 themes impact P8 notifications; if inaccurate, users will disable notifications | ML/Backend owner |
| **NEW (July 9): P1 archetype inference not built, blocks P3 context** | P1 must ship archetype inference (Jotter/Venter/Processor passive detection) before P3's Load Context step can be contextually complete — currently no code exists for this in either pillar | iOS/Backend engineer (P1 owner) |
| **NEW (July 9): PrayerArtifact storage blocked on T-062 + P4 JournalEntry model** | P3's "store prayer WITH journal" requirement needs both T-062 (encryption) and P4's JournalEntry model to exist. Recommend P3 ships with nullable/stubbed `journalEntryId` field until both land, rather than hard-blocking P3 engineering | Backend engineer (P3/P4 owners) |
| **NEW (July 9, P4 audit): T-062 confirmed zero code anywhere — top-priority blocker** | Codebase search found no CryptoKit/AES/Argon2id usage at all. T-062 now blocks both P3 and P4's encrypted storage simultaneously. Recommend sequencing T-062 ahead of both pillars' full implementation, not parallel to them | Crypto engineer |
| **NEW (July 9, P4 audit): three pillars (P1, P3, P4) each need identical unbuilt LLM infra** | P1's Dwelly loop, P3's PrayerGenerationManager, P4's JournalSynthesisManager all require the same Groq→GPT-4o mini calling pattern. Build one shared service once, reuse across all three, rather than three independent implementations | Backend/LLM owner (whichever pillar starts engineering first) |
| **NEW (July 9, P4 audit): synthesis error fallback undecided** | P4_SUMMARY.html's open question (Entry-only? retry? manual entry?) has never been locked. Blocks completing P4 Scenario 4's acceptance criteria until Kell decides | Kell (product decision, not engineering) |

---

## 9. Owner Assignments (Proposed)

| Component | Owner | Backup |
|-----------|-------|--------|
| **Auth Pillar** | Backend Engineer | iOS Engineer |
| **P0 Onboarding** | iOS Engineer | Frontend |
| **P1 Capture** | iOS Engineer + Backend | — |
| **P2 Encryption** | Crypto/Security Engineer | Backend |
| **P3 Soaking** | Backend + LLM Engineer | — |
| **P4 Journal** | Backend + LLM Engineer | — |
| **P5 Search** | Backend Engineer | iOS |
| **P6 Menu Bar** | iOS Engineer | Frontend |
| **P7 Formation Intel** | ML/Backend Engineer | Data Engineer |
| **P8 Notifications** | Backend + iOS Engineer | — |
| **Settings** | iOS Engineer | Frontend |
| **Today Tab** | iOS Engineer | Frontend |
| **Growth Tab** | iOS Engineer + Backend | Frontend |
| **E2E Testing** | QA Engineer | iOS Engineer |

---

## 10. Summary

| Aspect | Decision |
|--------|----------|
| **Critical Path** | Auth → P0 → P1 → P3 → P4 → P6 (11–16 weeks to MVP) |
| **MVP Launch** | 10 core pillars + 3 supporting tabs (Auth, P0–P4, P6, Settings, Today, Growth) |
| **Post-MVP** | P5 (Search), P8 (Notifications), Account Deletion, advanced features (2–4 weeks after launch) |
| **Parallel Work** | P2 (Encryption), Settings, P7, Today, Growth can run alongside critical path |
| **Deferred to Phase 2+** | Multi-device sync, open-ended prayer, email verification, biometric unlock |
| **Critical Blocker** | Supabase setup (week 1); LLM selection is now resolved (Groq → GPT-4o mini). **New as of July 9:** T-062 (encryption) and P1 archetype inference are confirmed hard/soft blockers for P3's PrayerArtifact storage — see §0. |
| **Longest Pillar Build** | P4 (Journal) or P7 (Formation Intel) — 2–3 weeks each |

---

**Ready for sprint planning and owner assignment. This graph is the basis for T-092 completion.**

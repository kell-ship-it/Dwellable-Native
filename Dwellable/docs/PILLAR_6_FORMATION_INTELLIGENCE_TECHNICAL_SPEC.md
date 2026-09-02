# Pillar 6 — Formation Intelligence — Technical Spec

## TL;DR

Formation Intelligence is shared infrastructure, not a screen — it's the one system that reads what a user gives across every pillar and turns it into a single, continuously-updated understanding of that person (the **Dweller Profile**), which every other pillar reads from for personalization.

**Two engines, layered:** Theme Detection (cheap, runs on every new journal) feeds structured themes up to the Dweller Profile Engine (the higher-order layer that writes the Narrative and updates the profile). Kept as separate LLM calls on purpose — easier to debug and improve independently.

**Two update speeds:** a cheap **incremental merge** fires on every qualifying event (flat cost forever), and a **monthly full-batch reconciliation** rereads everything from ground truth for a gated subset of users only (reflection tier + recent activity + paid tier all required) — this is the only place cost grows with user tenure.

**7 inputs, fully specified below:** Onboarding Intent (write) → Capture (read) → Journal created (two sequential calls, write) → Intent changed later (write) → Journal edited (no-op for MVP, not permanent — a Post-MVP open question) → Narrative Confirmation (branching Yes/Not-quite, once a month) → Monthly reconciliation (three-condition gate).

**Two net-new data models defined here for the first time:** `DwellerProfile` (never had a concrete struct before this doc) and `CorrectionRecord` (weighted like a capture, but its own distinct type — never a capture, never a journal).

**8 open items flagged, none silently assumed** — see Section 7. The biggest blockers: the qualifying paid tier for the reconciliation gate isn't defined anywhere yet, and "once a month" needs one precise definition (calendar month vs. rolling 30 days) before the rate limits are buildable.

**Status:** Locked (this document), Sept 1, 2026 session
**Supersedes for technical detail:** `PILLAR_7_FORMATION_INTELLIGENCE_STRATEGY.md`, `P7_FORMATION_INTELLIGENCE_STRATEGY.md`, `FORMATION_INTELLIGENCE_STRATEGY.md` — those docs predate the Dweller Profile Engine model below and should be treated as historical reference only, not current design.
**Companion visual references (FigJam):**
- [System Design board](https://www.figma.com/board/RiXUmpziTdiV4lXuw6SPfU/Pillar-6---Formation-Intelligence---System-Design) — engine flow, Narrative Confirmation, cross-pillar consumer map
- [Inputs & Outputs Map](https://www.figma.com/board/dU2FxKKsbIzchKR0wcbIEe) — the 7-row input-by-input breakdown this doc formalizes

**Numbering note:** "Pillar 6" refers exclusively to Formation Intelligence as of this session. The earlier numbering collision with Menu Bar/Navigation is resolved — see `TICKETS.csv` T-076/T-078 (renamed to epic "Menu Bar / Navigation (Cross-Cutting)") and T-180.

---

## 1. Purpose

Formation Intelligence is not a feature with its own screen — it is shared infrastructure. It is the one system that reads what a user gives across every pillar and turns it into a single, continuously-updated understanding of that person (the **Dweller Profile**), which every other pillar that wants personalized content reads from.

Guardrail (per `docs/VISION.md`): Formation Intelligence surfaces patterns and enables personalization — it never interprets, prescribes, or claims spiritual authority. Every generated artifact (a prompt, a Narrative line) speaks in invitational, Socratic language, never in declarative "this is what your life means" language.

---

## 2. Architecture Overview

Two engines, layered, not parallel and not merged into one call:

1. **Theme Detection** — runs cheaply and incrementally, per qualifying event. Reads one new piece of content, decides whether it reinforces an existing `DetectedTheme` or starts a new one. Cheap because it never rereads full history — only the new content plus the current theme list.
2. **Dweller Profile Engine** — the higher-order layer. Reads accumulated `DetectedTheme` records (not raw content) plus recent context to generate/update the `DwellerProfile`, including the user-facing Narrative.

These are **two separate LLM calls, kept intentionally separate** (not combined into one), because combining a narrative-writing task and a structured-data-update task into one call makes each harder to debug and improve independently — worth the small extra token cost for the decoupling.

**Two update speeds, not one:**
- **Incremental merge** — fires on every qualifying event (see Section 5). Cheap, flat cost forever, never rereads full history.
- **Monthly full-batch reconciliation** — gated (Section 6), rereads everything from ground truth once a month for qualifying users only. Cost grows with each user's accumulated history — the real long-term cost driver, unlike the incremental side.

**Read model:** each downstream consumer pulls only the slice of the profile it needs (e.g. Today pulls a small recent-theme+tone slice, Dwelly pulls the fuller running summary), never the whole profile on every read. Structured fields, not prose, for the same reason — cheap to slice, cheap to re-parse.

---

## 3. Data Models

### 3.1 `DwellerProfile` (net-new — never previously defined in any doc)

```swift
struct DwellerProfile: Codable {
    let id: String                              // UUID
    let userId: String                          // Supabase auth user ID

    var statedIntent: String                    // Row 1: single-select value from onboarding (see 3.4 for the "define what each Intent means" ticket)

    var runningSummary: String                  // Row 2/3: accumulated summary of past captures, handed to Dwelly at the start of every capture (the "notebook" Dwelly reads from)

    var detectedThemeIds: [String]              // Row 3: references to DetectedTheme records (see 3.2)

    var narrativeText: String?                  // the current generated "Your Narrative" shown in Growth (P11) — nil until the user crosses the reflection-count tier that unlocks it (T-161 tiers)
    var narrativeGeneratedAt: Date?
    var narrativeConfirmationState: ConfirmationState   // unconfirmed / affirmed / corrected — for the CURRENT narrative only, not historical
    var narrativeConfirmationUsedThisMonth: Bool        // Row 6 rate-limit tracking ("Not quite" capped at 1x/month)

    var lastReconciledAt: Date?                 // Row 7: timestamp of last monthly full-batch reconciliation (nil if never run for this user)

    let createdAt: Date
    var updatedAt: Date

    let encryptedContent: Data                  // per T-062 model: encrypted at rest, transient decrypt only for processing, never persisted or logged as plaintext
}
```

**Explicitly excluded from this struct:** Rhythm. Confirmed this session — Rhythm is self-reported only and is not part of Formation Intelligence's model for MVP. It lives in Account Profile's own data, not here. Post-MVP candidate to add later, not now.

**Open question, not yet resolved (T-178):** should this struct also carry `priorStatedIntent: String?`, so a future Narrative could reference "you used to want X, now you want Y"? Flagged, not decided — do not implement until answered.

### 3.2 `DetectedTheme` (locked prior session, restated here for completeness)

```swift
struct DetectedTheme: Codable {
    let id: String
    let userId: String
    var name: String                    // short label, user's own language preferred over an LLM-abstracted category
    var status: ThemeStatus             // active / resolved / dormant
    var relatedMomentIds: [String]
    var relatedJournalIds: [String]
    let firstDetectedAt: Date
    var lastReinforcedAt: Date
    var occurrenceCount: Int
    var emotionalArc: String?
    var summary: String                 // 1-2 sentences, cheap slice for consumers
    var confirmationState: ConfirmationState   // unconfirmed / affirmed / corrected
    var archived: Bool
    let encryptedContent: Data
}

enum ThemeStatus: String, Codable { case active, resolved, dormant }
enum ConfirmationState: String, Codable { case unconfirmed, affirmed, corrected }
```

**Reward/confidence system:** explicitly NOT decided. A `timesConfirmed`-style counter was proposed and parked as an open question — does repeated confirmation need to change how the engine trusts or uses a theme, and if so how? Unresolved. Do not implement a confidence-weighting mechanism until this is answered.

### 3.3 `CorrectionRecord` (net-new, from Row 6)

```swift
struct CorrectionRecord: Codable {
    let id: String
    let userId: String
    let profileId: String               // the DwellerProfile this correction applies to
    let correctionText: String          // free text from a "Not quite" response
    let narrativeSnapshotId: String?    // which version of the Narrative this was correcting, if tracked
    let createdAt: Date
    let encryptedContent: Data
}
```

**Explicit design decision, not a bug:** this is deliberately a distinct type, not a `Moment`. It is weighted equally to a captured moment in how much it counts toward "do we know this user" — but it is never labeled or stored as a capture, and it never appears as a visible journal entry in the user's Dwelling Place. If the correction text is thin/non-substantive, the resulting theme update will simply be thin. No validation is required or wanted here.

### 3.4 Tickets needed to complete this section

- **Define what each Intent option concretely means** — `statedIntent` is currently a single-select value with no documented enum or meaning-per-option. Needed before the engine can contextualize anything against it. (New ticket, Pillar 0.)
- **Define the exact tier count basis** for "reflection-count tier" (T-161's 0-2/3-5/6+) — does it count moments, journals, or something else? Confirm against T-161's existing definition rather than assume here.
- **Define the qualifying paid tier** for Row 7's gate — no premium tier structure is locked anywhere yet (T-099 covers a free-tier journal cap only). Blocking for Row 7's implementation.

---

## 4. The 7 Inputs — Technical Detail

Each row below states: the triggering event, the technical mechanism recommended (flagging where real infra decisions are still needed), what gets read/written, and error handling. Recommended mechanism defaults to the already-locked shared LLM proxy (**T-168, Supabase Edge Function**) for any LLM call — this spec does not introduce a new LLM-calling pattern.

### Row 1 — Onboarding Intent
- **Trigger:** user submits their Intent selection during onboarding (P0).
- **Mechanism:** synchronous write, client → Supabase, no LLM call. Creates the `DwellerProfile` row for this user for the first time.
- **Write:** `statedIntent` field set. No other field populated yet.
- **Read (explicit output):** a lookup table (Intent value → matching first-capture prompt set) is queried client-side or via a simple non-LLM endpoint — no LLM needed, per the locked decision that this is deterministic.
- **Error handling:** if the profile-creation write fails, onboarding should not block — retry on next app foreground, consistent with the existing offline-first sync pattern already used for Moments (`SyncManager`).

### Row 2 — Capture (Dwelly conversation)
- **Trigger:** every time a capture begins, before Dwelly's first message.
- **Mechanism:** synchronous read of `DwellerProfile.statedIntent` + `runningSummary`, injected into the prompt sent to the shared LLM proxy for Dwelly's conversational turn.
- **Read only — no write.** This row never mutates the profile.
- **Error handling:** if the profile read fails or the profile doesn't exist yet (shouldn't happen post-onboarding, but defensively), Dwelly should fall back to a generic prompt rather than blocking capture — capture must never be blocked by a Formation Intelligence failure.

### Row 3 — Journal entry created
- **Trigger:** user ends the capture conversation.
- **Mechanism — two sequential calls, both via the shared LLM proxy (T-168):**
  - **Call A (Pillar 4, Journal Synthesis):** conversation transcript → title + body + suggested mood/object tags. Writes the `Journal`/`JournalEntry` record (see `PILLAR_4_JOURNAL_CREATION_AND_OWNERSHIP_STRATEGY.md` — note that doc's `object` field is stale/dropped per T-154, don't carry it forward).
  - **Call B (Formation Intelligence, Theme Detection) — chained to run only after Call A succeeds:** reads the finished journal, compares against the current `detectedThemeIds` list, either updates an existing `DetectedTheme` (increment `occurrenceCount`, update `lastReinforcedAt`, append this journal's ID) or creates a new one.
- **Write:** `DetectedTheme` created/updated; `DwellerProfile.runningSummary` updated to reflect the new theme state (this is what Row 2 reads on the next capture).
- **Error handling:** if Call A fails, fall back to the existing locked P4 fallback (raw transcript stands in as the journal body — see `docs/MEMORY.md` Aug 27 decision that this is a permanent silent-retry state, not a dead end). If Call A succeeds but Call B fails, the journal still saves successfully (user-facing outcome unaffected) — Call B should retry via the same silent-background-retry pattern, and worst case gets caught by the next monthly reconciliation (Row 7) if retries exhaust. **This is the one legitimate case where a "missed" Theme Detection run is acceptable to leave for reconciliation** — unlike journal edits (Row 5), which are never picked up by reconciliation by design.

### Row 4 — Intent changed later
- **Trigger:** user edits Intent via Growth (P11) — corrected Sept 1, 2026: Rhythm and Intent editing moved from Account Profile to Growth on Aug 31, 2026 (see T-195); Row 4 was initially mis-attributed to Account Profile (P9) earlier the same session this doc was written, then corrected against the ticket history.
- **Mechanism:** synchronous write, no LLM call — overwrites `statedIntent`.
- **Write:** `DwellerProfile.statedIntent` overwritten. No reconciliation logic runs.
- **Explicit output:** the new value must propagate to wherever Growth displays the current Intent — confirm this is a live read (not cached) so the Growth tab reflects the change immediately.
- **Open items (not yet decided, do not implement without answering):**
  - Should Intent changes be rate-limited (e.g. once a month, like a username change)? Flagged, not locked.
  - Should the profile retain the old value (`priorStatedIntent`, see 3.1)? Flagged, not locked.

### Row 5 — Journal edited after creation
- **Trigger:** user edits a journal's title/body/tags post-synthesis (P4/P5 editing capability).
- **Mechanism:** none. This is a deliberate no-op for Formation Intelligence.
- **Write:** none to `DwellerProfile` or `DetectedTheme`. The journal's own edit is handled entirely within P4/P5's own data model.
- **Confirmed explicitly this session:** this is an MVP scope decision — out of scope for now, **not a permanent architectural rule.** Not a gap the monthly reconciliation will fill in the meantime, either. Row 7's reconciliation must NOT reread edited journal content differently than unedited — from Formation Intelligence's perspective, an edited journal is indistinguishable from an unedited one; it is not re-processed at all, in MVP.
- **Post-MVP open question:** should an edited journal ever feed back into the profile? Not decided — this is a real candidate to revisit, not a closed door.

### Row 6 — Narrative Confirmation
- **Trigger:** user taps "Yes, that's me" or "Not quite" (+ optional free text) on their Narrative in Growth (P11).
- **Terminology note:** call this "Narrative Confirmation" in all engineering artifacts, not "Confirmation Loop" — "loop" is reserved for the Dwelly conversation loops.
- **Mechanism, two branches (OR, not both):**
  - **"Yes":** synchronous write, no LLM call. Sets `narrativeConfirmationState = .affirmed`. No content change.
  - **"Not quite" (rate-limited to 1x/month via `narrativeConfirmationUsedThisMonth`):** creates a `CorrectionRecord` (3.3), then immediately (not deferred) triggers Theme Detection against the correction text — same mechanism as Row 3's Call B, treating the correction as equal in weight to a captured moment for profile-update purposes, without labeling it as one. The Narrative then regenerates immediately (a deliberate exception to the monthly cadence, justified because corrections are rare and high-signal).
- **Rate limit implementation detail needed:** "once a month" is not yet defined precisely — calendar month, rolling 30 days, or anchored to signup date? Needs one concrete answer before `narrativeConfirmationUsedThisMonth` can be correctly reset.
- **Error handling:** if the correction's Theme Detection call fails, the `CorrectionRecord` should still persist (don't lose the user's input), with the same silent-retry pattern as Row 3's Call B.

### Row 7 — Monthly full-batch reconciliation
- **Trigger:** calendar-based, evaluated per-user (recommend a scheduled job — e.g. Supabase `pg_cron` — iterating eligible accounts; exact scheduling infra not yet confirmed, flagging as an infra decision needed).
- **Gate — all three conditions required, evaluated per user before running:**
  1. User is above the reflection-count tier that makes them Narrative-eligible (T-161's tiers).
  2. Their profile has been updated at least once since the last cycle, via a capture (Row 3), a Narrative Confirmation (Row 6), or an Intent change (Row 4) — **journal edits (Row 5) never count toward this condition.**
  3. User is on a qualifying paid tier (tier definition: see Section 3.4, blocking open item).
- **If any condition fails, skip this user for this cycle entirely** — no partial run.
- **Mechanism (for gated-in users only):** reread all journals, all `DetectedTheme` records (confirmed/corrected state included), and Intent/Rhythm history from ground truth. Rebuild `DwellerProfile` fresh. Regenerate the Narrative.
- **Write:** `DwellerProfile` fully rebuilt; `lastReconciledAt` updated; `narrativeConfirmationUsedThisMonth` and any Intent-change rate limit reset for the new cycle.
- **Explicit output:** freshly regenerated Narrative appears in Growth, timed to land when the user's monthly Narrative Confirmation allowance resets.
- **Confirmed explicitly this session:** journal edits (Row 5) are NEVER caught by this reconciliation, not even incidentally. If a journal was edited since the last cycle, this reread does not re-derive anything different because of that edit — it is out of scope, full stop.

---

## 5. Cost Model Summary

- **Incremental merges (Rows 1, 3's Call B, 4, 6's "Not quite" branch):** flat, negligible cost per event, forever. Cost does not grow with user tenure.
- **Monthly full-batch reconciliation (Row 7):** cost grows with each user's accumulated history over time — the real long-term cost driver to monitor, not day-one cost. Mitigated by the three-condition gate in Section 4/Row 7, which should keep this to a small subset of the user base (tier-eligible + active + paying).
- **Two-call separation (Row 3):** costs slightly more in tokens than a single combined call would, kept intentionally for independent debuggability of journal synthesis vs. theme detection quality.

---

## 6. Consumers (who reads the `DwellerProfile`)

| Consumer | Status | What it reads |
|---|---|---|
| Growth "Your Narrative" (P11) | **MVP, live** | `narrativeText`, full |
| Capture/Dwelly conversation (P1) | MVP (Row 2 is a live read, already specified above) | `statedIntent`, `runningSummary` |
| Today tab contextual prompts (P10) | Post-MVP | small recent-theme+tone slice (not yet specified) |
| Notifications, contextual (P8) | Post-MVP | theme-status slice (not yet specified) |
| Search, theme-based filtering (P5) | Post-MVP | `detectedThemeIds` (not yet specified) |
| Journal synthesis quality improvement (P4) | Post-MVP | not yet specified — this would be a new read added to Row 3's Call A, closing the loop described in the original holistic map |

Per-consumer slice specs are not yet written for the Post-MVP rows — each needs its own short technical addendum when picked up, following the same pattern as Row 2 above (a scoped read, not the full profile).

---

## 7. Summary of Open Items (do not implement without resolving)

1. Reward/confidence-weighting system for repeated theme confirmation — parked, not decided.
2. Whether `DwellerProfile` should retain prior Intent values (`priorStatedIntent`).
3. Whether Intent changes should be rate-limited.
4. Exact definition of "once a month" for rate-limit resets.
5. Qualifying paid tier definition for Row 7's gate.
6. Whether an edited journal should ever feed the profile (Post-MVP question).
7. Scheduling infrastructure for Row 7 (recommend `pg_cron` or equivalent, not yet confirmed).
8. Per-consumer read-slice specs for the 5 Post-MVP consumers in Section 6.

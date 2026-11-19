# Crisis Support (unnumbered) — System Design (Stage 1 of 3: SYSTEM DESIGN → VISUAL DESIGN → ENGINEERING)

**Status: SYSTEM DESIGN drafted, awaiting Codex's visual-design artifacts as the gate before any engineering begins.**

**Canonical Notion pillar page (created and read back by Codex, under the verified Pillars index — do not duplicate):** https://app.notion.com/p/41dcbe07e0c9817fb28cf4432e49ade8

**Numbering note:** this is deliberately an *unnumbered* pillar, not "Pillar 12." `Theme.swift` already labels P12 as the locked Payment pillar palette (see `Theme.Payment`, matching the `dwelly-redesign` Figma file's P12 Payment tokens), so Crisis Support cannot reuse that number. This doc and its tickets previously said "Pillar 12 - Crisis Support" in error and have been corrected to the unnumbered name; renumber only if the authoritative Notion Pillars index itself assigns one later — Kell asked for a name, not a number.

This is a new pillar — it does not correspond to any existing numbered pillar (P0–P11) in the Notion Pillars index. It **supersedes** the ad-hoc "Pillar 1 - Crisis & Safety" epic used for T-302–T-310 in `TICKETS.csv`: those tickets' underlying safety-detection/classification mechanics (moderation + contextual read, output check, scenario matrix, system-prompt guardrails, country-aware resources, logging, ToS/Privacy) remain the detection layer this pillar sits on top of, but the **product behavior once a real concern is identified** is now stricter and different from what T-304/T-306 originally assumed (see "What this supersedes" below). T-302–T-310 are not being deleted or renumbered; this doc and its ticket family build on them.

## Locked policy (Kell, Nov 19 2026 — supersedes earlier proposals)

**UI shape — one continuous thread, not separate screens.** Support is a *mode* of the single Capture conversation, rendered in the same dark/gold UI the rest of Capture uses — never a modal, a separate screen, or a visually distinct "crisis flow." Reference: the superseded separated-screen concept (Figma node `xxOverFuFKWIOC9cYWjhgD?node-id=2-28`) is replaced by the continuous approach, prototyped at `/Users/kell/.codex/visualizations/2026/11/19/01a1f446-a3df-79a0-b055-518781f304d4/dwelly-continuous-support.html`.

**What counts as misuse vs. ordinary vulnerability.** Ordinary sensitive vulnerability is not misuse — ordinary adult sexual feelings, abuse disclosure, and past pain stay fully in normal reflection. Only **current/unresolved** risk — to self, to another named person, or ongoing danger — triggers support mode. Ambiguity gets one gentle, direct clarifying question, not an assumption either way. Intrusive thoughts are never assumed to be intent. Faith or hope expressed in the same turn does **not** clear a present, unresolved self-harm signal — the two are independent and both must be read. A clearly metaphorical or historical-only turn, with no unresolved signal left in the conversation, can return to ordinary reflection.

**Latching.** Once a genuine current/unresolved concern is established, support **latches** for the rest of that conversation — through to Finish — even if the user calms down or the conversation shifts into a God-encounter/worship register. It does not silently revert to normal mode because the tone changed.

**No journal, no Formation, for the whole conversation.** This is the strictest and most important rule in this doc, and it is a materially stricter rule than the one built under T-125's downstream-exclusion work (`FormationEligibilityPolicy`, Nov 19 2026): that mechanism excludes a conversation from *Formation Intelligence/profile eligibility only*, while still creating and saving a journal entry. Under this pillar's locked policy, once support has latched, the **whole conversation** produces:
- **no** journal entry (not created, not previewed, not saved — not even with `profileExcluded = true`)
- **no** Formation Intelligence update, no partial extracted facts, no summary contribution, no Growth contribution

`FormationEligibilityPolicy.isActive` staying `false`, or any future activation of its candidate-tier exclusion, does **not** satisfy this requirement on its own — that mechanism governs profile eligibility for entries that still get saved. This pillar needs its own, separate gate that suppresses the save/synthesis path entirely for a latched conversation, with no async/race/retry path able to create or send the entry after the fact. (Engineering-stage concern — flagged here, not solved here.)

**During the conversation.** Practical human support and country-aware resources (existing T-306 scope) continue to show, without requiring a safety-plan/target checklist for imminent danger — no forced halt, no auto-contact with police or any outside party, no promise of live monitoring (consistent with the existing T-308 pilot-scope notice). After a supportive reply, an in-thread notice states plainly: *"We won't create a journal from this conversation. Let's focus on getting you support."* — accessible detail, no mention of "Formation" by name to the user, just the plain fact that nothing will be saved/used that way.

**Resource card replaces the journal-preview artifact, same thread.** Where the ordinary flow would show a journal-preview card before Finish, a latched conversation shows a resource card in that same position/thread instead — the composer stays usable underneath it, support is additive, not a wall. "Finish for now" appears **only** as the top header action — no duplicate bottom button (matches the existing single-location Finish pattern already locked for ordinary Capture).

**Closure.** Finishing is the user's own choice. Resources remain visible/available at close; the app does not automatically start a new reflection or journal prompt, and never claims the user is now safe.

## Explicitly open / not decided here

- **Transcript retention is OPEN.** This doc does not create any new full-transcript persistence, and does not assert any invented legal retention requirement. The actual provider/access/retention picture (Groq/OpenAI as processors, who could technically access what, how long anything already persists today) needs to be documented honestly — no "zero storage" claim without verifying it first, consistent with the evidence-only standard used throughout T-125's prior work.
- **Diagnostics stay off** pending a real retention decision, consistent with T-307's existing default.
- **Framing**: Dwelly's response in support mode is faith-centered God-moment reflection, not therapy or diagnosis. No pressure to forgive, reconcile, or stay in an unsafe situation; prayer/scripture never substitutes for a practical safety action (this already matches T-305's locked guardrail language and is reaffirmed here, not changed).
- Terms of Service / Privacy Policy (T-309) need to be checked against this doc's "no journal, no Formation" guarantee once it's built, so the policy documents don't overclaim or underclaim what actually happens.

## What this supersedes (so a future session doesn't silently use the stale version)

- The earlier separated-screen support concept (superseded Figma frame, see above).
- T-304's matrix as originally written assumed the conversation would still become a journal entry (with safety-aware tone) after a crisis/misuse turn. Under this pillar, a **latched** conversation produces no journal entry at all — T-304 needs a revision pass once engineering starts, not treated as still-accurate today.
- The idea that `FormationEligibilityPolicy` (profile-eligibility-only) is sufficient protection for this scenario — it is not; see "No journal, no Formation" above.

## Visuals already provided (reference only — not yet canonical Figma artifacts)

- FigJam system-design board (Kell-provided): `https://www.figma.com/board/1D2UH0giP8V4yNAmsDHc22`
- Superseded separated-screen concept: `https://www.figma.com/design/xxOverFuFKWIOC9cYWjhgD?node-id=2-28` — **do not build from this; it is explicitly superseded.**
- Continuous-approach HTML reference (local, Codex-authored): `/Users/kell/.codex/visualizations/2026/11/19/01a1f446-a3df-79a0-b055-518781f304d4/dwelly-continuous-support.html`
- Diagram convention for the system-design board: top-to-bottom chronological, parent flow first with branches/examples below; elbow-routed labeled arrows; solid lines for user-facing steps, dashed for internal/system steps; color coding blue = support/reflection, yellow = clarify, red = no-journal/no-profile (explicitly **not** "halt"), white = worked examples. Must read `Theme.swift` for real token values; no post-onboarding logo per existing design convention.

The Notion pillar page itself is now canonical (link above, filed by Codex). The Figma artifacts above are still reference-only until Codex files them into the canonical Figma File & Board Index and links them back — that link-back is the VISUAL DESIGN gate T-312 needs before ENGINEERING (T-313+) can start. Codex owns all Notion/Figma writes; this session only reads them back and reports titles/acceptance text for Codex to mirror.

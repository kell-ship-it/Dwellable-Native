# Pillar 11 — Growth: Acceptance Criteria

**Status:** Verified against live Figma file, Oct 20, 2026 | **Design file:** `dwelly-redesign` → page `🌱 P11 — Growth (Redesign)`

Organized by the 4 scenario flows a user actually moves through. 15 screens across 6 labeled scenario sections. All items below were checked programmatically against the live file (bound colors, strokes, timestamps, tap targets) plus visual screenshot review — not just asserted.

---

## Flow 1 — Confirming the Narrative ("Yes, that's me")

**Section:** Scenario A — User Agrees with the Narrative (Default → Confirmed)

- [x] "Yes, that's me" reads as a real CTA: solid gold fill, dark text — verified bound/solid on the Default screen
- [x] Confirmed state shows a green checkmark + "Confirmed" + reassurance copy
- [x] Confirmed screen's timestamp reads "Updated 3 days ago" — confirmed never jumps to "just now" (verified: Confirmed screen's only "Updated" string is "Updated 3 days ago")
- [x] No narrative text changes between Default and Confirmed

## Flow 2 — Rejecting the Narrative ("Not quite")

**Section:** Scenario B — User Disagrees with the Narrative (Default → Feedback Open → Regenerating → Regenerated)

- [x] "Not quite" has no stroke/border — matches `Pill/Mood` (filled `surface/pill`, no stroke)
- [x] Tapping "Not quite" opens a free-text box + Submit, matching the `CorrectionRecord` protocol
- [x] Disclaimer line sits directly under the main paragraph, not adjacent to Submit
- [x] A dedicated "Regenerating" processing screen exists between Submit and the outcome — old (wrong) text never lingers, no "Updating soon" holding message (would misrepresent the spec's "not deferred" design)
- [x] Post-submit screen shows "Updated just now" — verified this is the *only* screen in the entire file with that exact string
- [x] Post-submit screen shows "Updated based on your feedback" acknowledgment — verified present
- [x] Confirmation pills reset to neutral/available on the regenerated narrative
- [x] No disabled/offline state anywhere in this flow (Offline scenario removed entirely per Oct 20 decision)

## Flow 3 — Changing Rhythm

**Section:** Scenario C — User Changes Their Rhythm (Default → Rhythm Open)

- [x] Dropdown shows all 5 options; selected = gold text + checkmark, unselected = plain text, no stroke on any option row
- [x] Changing Rhythm has zero effect on the Narrative (excluded from `DwellerProfile` for MVP)
- [x] Narrative text/timestamp unchanged — verified "Updated 3 days ago" on both Default and Rhythm Open
- [x] Open-state gold border removed per your direct edit — verified zero strokes on both Rhythm and Intent rows' open state

## Flow 4 — Changing Intent

**Section:** Scenario D — User Changes Their Intent (Default → Intent Open)

- [x] Dropdown shows all 5 options, same treatment as Rhythm
- [x] **Updated Oct 20:** Intent's `DwellerProfile` effect is now Post-MVP — zero effect on Narrative for MVP, same status as Rhythm. Updated in `PILLAR_GROWTH_STRATEGY.md` and `PILLAR_6_FORMATION_INTELLIGENCE_TECHNICAL_SPEC.md` (Row 4), not just this doc.
- [x] Narrative text/timestamp unchanged before/after
- [ ] **Open, not a bug:** "Hold onto answered prayers" appears as one of the 5 Intent dropdown options. It's a personal-hope description, not a claim the app has a Prayer feature — but the system-wide rule below says "no Prayer-related copy anywhere," so this is a judgment call for you, not something I silently resolved either way.

---

## System-wide (verified across all 15 screens)

- [x] No unbound colors introduced by this build — the 4 unbound entries present on every screen trace to the pre-existing shared `TabBar`/`Button/Capture-Launch` components (not touched this session)
- [x] Header is title + gold Capture button only, every screen — zero instances of the search icon or bordered header pill found
- [x] Stat tile has zero stroke, every screen
- [x] TabBar never overlaps body content, every screen (verified: TabBar y always ≥ body bottom)
- [x] Tap targets ≥44×44pt — Rhythm/Intent value boxes confirmed at 47px
- [x] No blue-leaning tokens remain (`text/secondary`→`text/supporting`, `text/faint`, `surface/card`, `background/input` all corrected at the variable level, cascades everywhere)

## Capture Volume States

- [x] Moment Removed: no trash-can icon (removed per your instruction), stat reads "0 moments captured"
- [x] One Moment: stat label is singular ("1 moment captured")
- [x] New User (Pre-Threshold): no "praying" language, no "Updated" timestamp (verified: zero timestamp strings on this screen — correct, no narrative exists below threshold)
- [x] Hundred Moments / Tier 2: tone-shift and topics sections visibly tagged POST-MVP

---

## Explicitly out of scope / confirmed decisions, not gaps

- Offline/connectivity states — removed entirely (every Growth action is local-write-then-sync, same as the rest of the app)
- Glossary, Color Wheel, Steward Score — Post-MVP per `PILLAR_GROWTH_STRATEGY.md`
- Search in Growth header — intentionally absent
- Intent's effect on Formation Intelligence — Post-MVP (Oct 20 decision, documented in spec)

## Known open items, not yet resolved

- `TabBar/4-Tab` renders in Instrument Sans while the rest of the system uses Inter/Instrument Serif — pre-existing, shared component, not fixed this session
- "Once a month" rate limit for "Not quite" has no precise definition yet (calendar month vs. rolling 30 days) — engineering spec gap, not a design gap
- No UI state exists yet for "Not quite" being rate-limited (already used this month) — flagged during the cost-concern discussion, not built
- Token fixes made this session are shared variables — not yet confirmed clean on the other pillars (P0, P1, P4, P5, P6, P10)
- "Hold onto answered prayers" Intent option — see Flow 4 above, needs your call

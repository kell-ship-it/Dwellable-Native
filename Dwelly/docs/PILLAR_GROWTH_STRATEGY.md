# PILLAR: Growth (Formation Narrative & Stats)

**Pillar:** Growth | **Updated:** November 17, 2026 (T-196 doc sync) | **Status:** MVP shell built (T-140), locked design confirmed live against Figma

---

## 1. Overview

- **Purpose:** Show users their formation journey — not through Prayer/engagement metrics (Prayer has no real capture flow anywhere in the app), but through a narrative reflection of their own captures plus one plain stat.
- **Scope (MVP):** Your Narrative (Pre-Threshold / Tier 1) + Your Plain Stats (moments-captured count). Rhythm & Intent and everything in §6 below are Post-MVP.
- **Status:** Shell built and closed (T-140, Nov 17 2026). This doc was stale from May 14 2026 (pre-dated the Aug 31 2026 redesign entirely) until this sync.
- **Tab Position:** 4th tab (Today | Entries | Growth | Profile) — "Create"/Capture is not a tab; it's the persistent gold circle in each screen's own header (T-076).

---

## 2. What changed from the original (May 2026) strategy

The original version of this doc described a Prayer-metrics dashboard (Total Prayers, Prayer Engagement %, Prayer Preference, Emotional Themes bar chart, a nested Settings subsection, a Glossary, a Color Wheel, a Steward Score) with a Week/Month/All-time filter. **None of that is the real design.** The Aug 31 2026 Growth redesign (T-195/T-196) replaced it with:

| What the old doc said | What's actually real |
|---|---|
| Formation Overview (4 Prayer-based stat cards) | **Your Narrative** — a generated reflection of the user's own captures (T-275), not a stat card grid |
| Total Prayers / Prayer Engagement / Prayer Preference | Gone entirely — Pillar 3 (Prayer) has no real capture flow anywhere in the app; there's nothing true to count (T-141) |
| Emotional Themes bar chart | Not built, not in the locked Figma design |
| Time range filter (Week/Month/All-time) | **Does not exist anywhere in the real P11 Growth Figma page** (confirmed live via Figma MCP against every scenario frame, Nov 17 2026) — this was stale ticket text, never actually designed |
| Nested Settings subsection + "All Settings" link | Not part of Growth — Pillar 9 (Account Profile) owns Settings; Growth has no settings UI |
| Glossary / Color Wheel / Steward Score (Post-MVP) | Still genuinely Post-MVP, not reachable from any current screen |
| Total Captures | Survives, rescoped: **Your Plain Stats**, a single moments-captured count (T-141) |
| Rhythm/Intent editing moved in from Account Profile (T-195) | Moved in, then **deferred to Post-MVP** (T-181, Kell's direct call Nov 16 2026) — `GrowthPlaceholderView`'s "Rhythm and Intent are coming soon" placeholder is correct and deliberate |

---

## 3. MVP Growth Tab — what's actually built

**Screen structure (`GrowthPlaceholderView.swift`):**
```
┌──────────────────────────────┐
│ Growth                   [+] │  TabScreenHeader
├──────────────────────────────┤
│ YOUR NARRATIVE                │  YourNarrativeCard (T-275)
│ [generated reflection text]   │  Pre-Threshold / Tier 1 states built
├──────────────────────────────┤
│ YOUR PLAIN STATS               │  PlainStatsSection (T-140/T-141)
│ 47                              │
│ moments captured                │
├──────────────────────────────┤
│ 🍃 Rhythm and Intent are        │  Placeholder only — deferred (T-181)
│    coming soon.                 │
└──────────────────────────────┘
```

**Your Narrative** (T-275, built): generated and updated by Formation Intelligence (P6), not by this pillar directly — see §4 below for the Narrative Confirmation / Intent / Rhythm mechanism, which is design-complete even though its Growth-tab surface is deferred.

**Your Plain Stats** (T-141, built): one card, one number — a plain count of captured Moments. No second stat. "Total Prayers" is correctly absent (not deferred, not stubbed — Prayer has no capture flow to count).

**No time-range filter.** Checked directly against the real locked Figma (every P11 scenario frame — New User Pre-Threshold, Tier 2 Full Narrative, and the four Tier 1 agree/disagree/rhythm/intent scenarios) before this doc sync: none of them show a Month/Year/All-time control. T-140 closed on this finding rather than building a filter with no design backing.

---

## 4. Formation Intelligence Integration ("Your Narrative" + Intent/Rhythm editing)

*(Carried forward unchanged from the pre-sync doc — this section's content was already current, just mis-filed under a stale parent structure.)*

**Your Narrative (Row 6, Row 7):**
- "Your Narrative" is generated and updated by Formation Intelligence (P6), not by this pillar directly.
- When a user taps "Yes, that's me" or "Not quite" on their Narrative, call this **Narrative Confirmation** (not "Confirmation Loop" — that term is reserved for Dwelly's conversation loops). The tap triggers Formation Intelligence logic, not Growth's own.
- "Not quite" is rate-limited to once a month and, when used, immediately regenerates the Narrative — an exception to the normal monthly cadence.

**Intent editing (Row 4) — lives here, not Account Profile, as of Aug 31 2026 (T-195); its Growth-tab UI is deferred Post-MVP (T-181, Nov 16 2026):**
- **Update, Oct 20 2026:** Intent's write to `DwellerProfile.statedIntent` — Intent playing any role in Formation Intelligence / the spiritual profile — is now Post-MVP. For MVP, Intent editing works exactly like Rhythm: self-reported, editable in Growth, zero effect on the Narrative or `DwellerProfile`. The locked mechanism below is preserved for when this is picked back up, not discarded.
- (Post-MVP) When a user edits Intent from Growth, it overwrites `DwellerProfile.statedIntent` directly — synchronous write, no LLM call. The change must propagate live (not cached) back into this same screen's Narrative display.
- Open items not yet locked: whether Intent changes should be rate-limited, and whether the prior value should be retained.
- Rhythm editing (also moved here per T-195) does **not** touch Formation Intelligence at all in MVP — self-reported data only, this pillar's own concern, not part of the `DwellerProfile` model. Intent now matches this for MVP as well.

Full mechanism: see `docs/PILLAR_6_FORMATION_INTELLIGENCE_TECHNICAL_SPEC.md`, Row 4, Row 6, and Row 7.

---

## 5. Cross-Pillar Dependencies (current)

- **Pillar 1 (Capture):** Your Plain Stats counts total captures from P1.
- **Pillar 4 (Journal Creation):** Your Narrative's source material comes from journal entries P4 produces.
- **Pillar 6 (Formation Intelligence):** Generates and updates Your Narrative; owns Narrative Confirmation logic.
- **Menu Bar/Navigation:** Growth is Tab 3 of 4 (Today | Entries | Growth | Profile) — T-076.
- **Pillar 9 (Account Profile):** Owns all Settings; Growth has no settings UI, nested or otherwise (corrects the pre-sync doc's §5.3/§11, which both described a nested Settings subsection that was never built and isn't in the locked design).
- **Pillar 3 (Prayer):** No dependency — Prayer has no real capture flow yet, so none of Growth's real metrics reference it.

---

## 6. Post-MVP (unchanged scope, not re-validated against current Figma this sync)

These remain named as future ambitions; this sync did not re-verify any of them against a current design, since none are in the MVP Figma pass this doc otherwise reflects:

- **Glossary:** Auto-extracted moods/topics/people/things from the user's own moments, organized by category, tap-to-browse.
- **Color Wheel (emotional depth):** Surface → reflective → transcendent emotional-maturity visualization.
- **Steward Score:** A Reddit-karma-style formation engagement metric.
- **Detailed trend charts:** Moments/week over time, rate trends, week-over-week indicators.

---

## 7. Summary

| Aspect | Decision |
|--------|----------|
| **Goal** | Help users see their formation journey through their own narrative and one plain, affirming stat — not comparative or Prayer-dependent metrics |
| **Tab Position** | 3rd of 4 tabs (Today \| Entries \| Growth \| Profile) |
| **MVP Sections** | Your Narrative \| Your Plain Stats \| (Rhythm & Intent — deferred, placeholder only) |
| **MVP Metrics** | Moments captured (count only) |
| **Post-MVP** | Rhythm & Intent editing surfaced here, Glossary, Color Wheel, Steward Score, trend charts |
| **No time-range filter** | Confirmed absent from the real locked Figma design — not a gap, never designed |
| **No nested Settings** | Settings live entirely in Pillar 9 (Account Profile) |

---

**Status:** MVP shell built and closed (T-140). This doc now matches the real app and the real locked Figma; previous versions describing Prayer metrics, a time filter, or nested Settings were stale from before the Aug 31 2026 redesign.

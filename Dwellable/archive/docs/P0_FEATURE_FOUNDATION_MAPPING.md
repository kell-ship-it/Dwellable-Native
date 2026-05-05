# Phase 2 Layer 1 (P0) — Feature-to-Foundation Alignment

**Document Purpose:** Validate that each P0 feature honors the Five Strategic Foundations and prevents scope creep or brand drift.

**Strategic Foundations (From PHASE2_DISCOVERY_RESEARCH.md):**
1. **Brand Positioning:** Keeper of sacred moments, not interpreter
2. **Interaction Model:** Socratic reflection (questions, not answers)
3. **Spiritual Integrity Guardrails:** User agency, hermeneutical alignment, Scripture authority
4. **End-State Principle:** Formed Christian with deepened faith through accumulated witness
5. **Category Positioning:** Personal spiritual moments—the full spectrum of daily life—not generic notes

**Note on "Personal Spiritual Moments":** These include the extraordinary (breakthroughs, encounters, clarity) AND the mundane (rough days, work, doubts, celebrations). Dwellable helps users see God in all of it, not just the special.

---

## Gallery View

### Feature Description
Tile-based visual catalog showing moment previews (headline/first words), dates, optional AI imagery. Users tap to open full moment detail.

### Foundation Alignment

| Foundation | How Gallery Serves | Risk Mitigation |
|---|---|---|
| **Keeper, not Interpreter** | Gallery *presents* moments visually without commentary or analysis. User sees their raw experiences. | ✅ No interpretive overlays, summaries, or "lessons learned" — just visual retrieval cues |
| **Socratic Reflection** | Gallery prompts contemplation: "Why do I return to this moment?" "What patterns do I notice?" Enables user-generated insight. | ✅ Gallery is passive; active reflection happens in Soak Mode + detail view. Gallery doesn't answer questions. |
| **User Agency** | User decides which moments to revisit. Gallery shows all moments equally; Dwellable doesn't rank or curate. | ✅ No algorithmic curation (unlike Facebook feed). User controls return, not algorithm. |
| **End-State Principle** | Accumulated visual witness — seeing *all* moments across weeks/months builds cumulative sense of God's presence. | ✅ Gallery is comprehensive, not filtered. Shows trajectory of faith over time. |
| **Personal Spiritual Moments** | Gallery showcases *user's* moments, not quotes/devotionals. Ownership is clear — "these are my experiences." | ✅ Never compares to others' moments (P2 feature). P0 stays solo-focused. |

### P0 Specification
- **Visual elements:** Headline (user-generated or auto-default), date, moment body preview (first 20 words), optional color accent (based on tag or sentiment — if available)
- **Layout:** 2-column or 3-column tile grid (user choice)
- **Interaction:** Tap to open detail view; long-press to pin favorite moments (future feature)
- **No ranking:** Moments sorted by date (newest first) only. No "trending," "popular," or algorithmic sorting.
- **Accessibility:** Text contrast ≥4.5:1; tap targets ≥44px

---

## Tags & Headlines

### Feature Description
Optional user-generated metadata. Auto-suggested tags (max 5 per moment); user-written headlines as retrieval cues.

### Foundation Alignment

| Foundation | How Tags/Headlines Serve | Risk Mitigation |
|---|---|---|
| **Keeper, not Interpreter** | Tags/headlines are *retrieval cues*, not interpretations. "Doubt" tags what the user experienced, not what it meant. | ✅ Tags are descriptive, not prescriptive. "Doubt" ≠ "Doubt means God is absent." User generates meaning. |
| **Socratic Reflection** | Tags enable pattern recognition: "Oh, I notice 60% of my moments involve solitude." Prompts Socratic questions. | ✅ Tags reveal patterns; user interprets patterns. Dwellable doesn't say "this pattern means X." |
| **User Agency** | User creates headlines + chooses tags. No forced categorization. Optional feature. | ✅ All tagging is opt-in. No requirement to tag. User-generated tags only (not prescriptive). |
| **End-State Principle** | Patterns accumulated over time show trajectory of faith. "I've moved from doubting to trusting" (user observation from tags). | ✅ Tags reveal user's own spiritual journey, not external framework. |
| **Personal Spiritual Moments** | Headlines are user's words. "God's peace in the waiting" is their language, not corporate jargon. | ✅ No pre-written headlines. User-generated only to preserve voice. |

### P0 Specification
- **Headlines:** Optional, user-written (8-word default if not customized). Appears in gallery + detail view header.
- **Tags:** 
  - Auto-suggested (5 max): derived from moment content (NLP, not user-prescribed)
  - Suggested tags: Clarity, Doubt, Encounter, Sorrow, Joy, Solitude, Community, Prayer, Rest, Struggle, Peace, Presence
  - User can accept, edit, ignore, or create custom tags
  - No force to tag; optional feature
- **No AI-generated headlines:** User generates or inherits auto-default (first 8 words). Avoids reductive interpretation.
- **Privacy in tagging:** Tags are user's private taxonomy, not shared/ranked against others

---

## Notifications (2x Weekly)

### Feature Description
Gentle reflection invitations (Sunday 6 PM, Thursday 7 AM). Copy emphasizes dwelling, not capturing. Fully user-controlled (disable anytime).

### Foundation Alignment

| Foundation | How Notifications Serve | Risk Mitigation |
|---|---|---|
| **Keeper, not Interpreter** | Notifications invite dwelling on *user's* moments, not external content. "How are you sitting with this?" is open-ended. | ✅ Invitations, not answers. No spiritual direction or interpretation. User decides what dwelling means. |
| **Socratic Reflection** | Notifications pose questions: "What patterns do you notice?" "How has this moved you?" Open-ended, not prescriptive. | ✅ All notification copy is question-based (Socratic) or invitational. No statements or conclusions. |
| **User Agency** | Notifications are fully optional. User can disable, pause, or adjust timing in Settings. No coercion. | ✅ User controls notification frequency + content. Can mute anytime. Dwellable respects choice. |
| **End-State Principle** | Notifications invite contemplation of accumulated moments — "How has this shaped you since then?" Reflects on transformation. | ✅ Notifications reference spiritual growth, not external achievement. Focus on *being*, not *doing*. |
| **Personal Spiritual Moments** | Notifications reference *user's* moments only. No comparison to others. "Your moments," not "trending moments." | ✅ All copy uses second-person singular ("your moments," "your faith"). Solo-focused. |

### Notification Copy Guidelines
- **Invite, don't command:** "How are you sitting with this?" not "Reflect on your moment"
- **Question > Statement:** "What changed since then?" not "Your faith has grown"
- **Dwelling > Capturing:** "Revisit a moment" not "Add a moment"
- **User agency:** Every notification includes "Not now" or "Disable" option
- **Frequency:** 2x weekly max (Sunday 6 PM, Thursday 7 AM). No daily.
- **No achievement metrics:** Never show "You've reflected on X% of moments" (avoids gamification)

### P0 Specification
- **Frequency:** 2x weekly (user-customizable: 1x, 2x, or pause 1-4 weeks)
- **Timing:** Sunday 6 PM (weekly reflective moment), Thursday 7 AM (mid-week invitation)
- **Copy variants (rotate to prevent fatigue):**
  - "How are you sitting with your moments?"
  - "Dwell on a moment from last week"
  - "What patterns do you notice in your moments?"
  - "Revisit the first moment you captured"
  - "How has a moment shaped you since then?"
- **Personalization:** After 5 moments, notifications can reference specific moments ("Your moment about 'peace in uncertainty' is worth revisiting")
- **Opt-in + easy disable:** Default OFF; user enables in Settings. Can disable from notification itself.

---

## Soak Mode (Optional Contemplative Feature)

### Feature Description
Optional "soak" button on moment detail view. Plays ambient soundscape (piano, rain, forest, etc.) while moment text remains visible. User chooses duration (5/10/15 min).

### Foundation Alignment

| Foundation | How Soak Mode Serves | Risk Mitigation |
|---|---|---|
| **Keeper, not Interpreter** | Soak Mode provides *silence*, not interpretation. Ambient music supports contemplative presence, not analysis. | ✅ No voiceover narration or spiritual commentary. User alone with their moment + silence. |
| **Socratic Reflection** | Soak invites pre-verbal contemplation. Questions emerge from presence, not from guidance. User finds their own understanding. | ✅ No prompts during soaking. Pure silence + moment text. Reflection is post-soak, user-generated. |
| **User Agency** | Soak Mode is entirely optional (35-40% adoption expected). No nudge toward soaking. User chooses. | ✅ Optional feature, never required. User controls duration + music selection. Can exit anytime. |
| **End-State Principle** | Soaking cultivates contemplative presence — foundation for faith deepening. Shifts from thinking-about to being-with God. | ✅ Aligns with contemplative prayer tradition. Supports spiritual formation, not just information. |
| **Personal Spiritual Moments** | User soaks with *their* moment, not generic content. Soundscape is neutral (not worship music) — supports user's interpretation. | ✅ No prescriptive spiritual framing. Ambience supports user's own contemplative path. |

### Soundscape Selection Criteria
- **Neutral spiritually:** No worship songs, hymns, or explicitly Christian content in P0
- **High-quality audio:** Stereo, lossless preferred
- **Variety:** 8-12 options (piano, rain, forest, waves, meditation bell, silence-only, etc.)
- **Licensing:** Artlist, Epidemic Sound, or royalty-free sources (never copyrighted music)

### P0 Specification
- **Placement:** Detail view, below moment text
- **Button label:** "Soak" (one-tap activation)
- **Duration options:** 5, 10, 15 minutes (user choice)
- **Music library:** 10-12 ambient soundscapes
- **Controls during soak:** 
  - Pause/resume music
  - Exit soak (return to detail view)
  - Adjust volume
  - No notifications/interruptions during soak
- **Post-soak:** Optional "Save moment as favorite" or just return to gallery
- **Analytics:** Track soak adoption + average duration (research metric only, not user-facing)

---

## Headlines (User-Generated Retrieval Cues)

### Feature Description
Optional user-written headlines (8-word default if not customized). Appears in gallery + detail view. Purpose: retrieval cue for quick recall.

### Foundation Alignment

| Foundation | How Headlines Serve | Risk Mitigation |
|---|---|---|
| **Keeper, not Interpreter** | Headlines are retrieval cues ("Prayer in the car"), not summaries or meanings. User's language preserved. | ✅ User writes headline in their own voice. Dwellable doesn't impose headlines or suggest interpretations. |
| **Socratic Reflection** | Headlines prompt recall, which enables Socratic questions. "Why did that moment matter?" emerges from re-encounter. | ✅ Headlines are question-triggers, not answer-providers. User generates meaning. |
| **User Agency** | Headlines are optional (40-50% adoption). User writes or accepts auto-default. No forced titling. | ✅ Opt-in feature. User controls wording + can edit anytime. |
| **End-State Principle** | Headlines cumulative across moments show trajectory: "God's presence in uncertainty," "Peace in waiting," "Faith in doubt." Pattern reveals formation. | ✅ User's language patterns show their spiritual journey over time. |
| **Personal Spiritual Moments** | Headlines are in user's voice and words. "Hymn brought clarity" is their phrasing, not corporate language. | ✅ User-generated only. No system-suggested headlines in P0 (avoid reductive AI). |

### P0 Specification
- **Default:** Auto-fills with first 8 words of moment (example: "I felt God's presence when I read" → "I felt God's presence when I read")
- **User edit:** One-tap to customize to desired retrieval cue
- **Max length:** 12 words (prevents over-summary)
- **Examples of good headlines:**
  - "God's peace in the waiting"
  - "Encountered presence in solitude"
  - "How doubt led to deeper faith"
  - "Hymn brought unexpected clarity"
- **Placement:** Gallery tile headline + detail view header
- **No auto-generation:** User-written only (no AI in P0). Avoids reductive interpretation.
- **Optional:** No penalty for moments without custom headlines. Auto-default sufficient.

---

## P0 Feature Consistency Check

### Do All P0 Features Align with Five Foundations?

**Gallery View:**
- ✅ Keeper (visual presentation, no interpretation)
- ✅ Socratic (invites pattern-finding questions)
- ✅ User Agency (user controls returns, not algorithm)
- ✅ End-State (accumulation shows faith trajectory)
- ✅ Personal (user's moments, not external content)

**Tags & Headlines:**
- ✅ Keeper (retrieval cues, not interpretations)
- ✅ Socratic (patterns prompt questions)
- ✅ User Agency (user-generated only, optional)
- ✅ End-State (patterns reveal formation over time)
- ✅ Personal (user's language + taxonomy)

**Notifications:**
- ✅ Keeper (open-ended invitations, no answers)
- ✅ Socratic (question-based copy)
- ✅ User Agency (fully optional + customizable)
- ✅ End-State (contemplation of spiritual growth)
- ✅ Personal (user's moments only)

**Soak Mode:**
- ✅ Keeper (silence + presence, not instruction)
- ✅ Socratic (contemplation precedes questions)
- ✅ User Agency (optional, user chooses duration)
- ✅ End-State (contemplative practice supports formation)
- ✅ Personal (user alone with their moment)

**Headlines:**
- ✅ Keeper (retrieval cues, user-written)
- ✅ Socratic (triggers recall-based reflection)
- ✅ User Agency (optional, user controls wording)
- ✅ End-State (language patterns show spiritual arc)
- ✅ Personal (user's voice throughout)

### Scope Creep Prevention: What P0 DOESN'T Include

❌ **Social features** (comparison, sharing, ranking) — deferred to P2
❌ **AI interpretation** (auto-generated headlines, meaning-making) — respects user hermeneutics
❌ **Forced practices** (daily streaks, gamification) — optional, user-controlled
❌ **External content** (quotes, devotionals, Scripture) — user's moments only in P0
❌ **Recommendation engine** ("users like you also..." patterns) — avoids social comparison
❌ **Prescriptive categories** ("God's Faithfulness," "Answered Prayer") — user vocabulary only
❌ **Spiritual direction** (guidance, interpretation, advice) — user's own reflection only

---

## Success Metrics: Foundation Alignment

For each feature, measure if users report alignment with foundations:

| Foundation | Key Question | Metric |
|---|---|---|
| **Keeper** | "Does Dwellable help me hold my moments, not analyze them?" | User survey: "Dwellable respects my own interpretation" (target: 85%+) |
| **Socratic** | "Am I discovering insights myself, not being told meanings?" | Qualitative: "I found my own pattern/understanding" (target: 60%+ of active users) |
| **User Agency** | "Do I control my reflection practice, or does Dwellable control it?" | Feature adoption rates voluntary (Gallery: 85%, Tags: 50%, Notifications: 60%, Soak: 40%) |
| **End-State** | "Can I see my faith deepening over time through my own moments?" | User reports: "I notice how I've grown" (target: 65%+ of P0 users by week 8) |
| **Personal** | "Are these *my* moments and *my* understanding, not someone else's?" | Survey: "Dwellable feels personal to my faith journey" (target: 80%+) |

---

## Next Steps

1. ✅ **P0 Feature Research Findings** (created)
2. ✅ **Feature-to-Foundation Alignment** (this document)
3. ✅ **FigJam Roadmap** (created — link below)
4. ⏳ **T-060 Final 1-Pager:** Integrate research + alignment + roadmap into Phase 2 Themes strategic document
5. ⏳ **P1 Feature Planning:** Once P0 research is validated, apply same framework to P1 features (Socratic Reflection, Themes, Scripture, Seasonal)

---

**FigJam Roadmap:** https://www.figma.com/online-whiteboard/create-diagram/63428f5e-019c-4058-aea4-bbfbc7783bb8

**Document prepared for:** T-060 (Phase 2 Themes 1-Pager)
**Date:** April 29, 2026 (Updated for emphasis pivot: all moments, not just peak experiences)
**Prepared by:** Claude Code (Dwellable Agent)

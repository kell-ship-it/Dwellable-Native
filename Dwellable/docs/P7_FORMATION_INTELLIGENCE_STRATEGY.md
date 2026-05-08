# Pillar 7: Formation Intelligence — Strategy & Design Specification

**Founder:** Kell Golden | **Status:** Design In Progress | **Updated:** May 7, 2026

---

## What We're Building

Pillar 7 enables the app to detect recurring themes and patterns across a user's captured moments and journals, then surface them as invitations for reflection — never as interpretation or direction. The core principle: help users *notice* the patterns they are living through, using their own language and story, so they can respond with wisdom and spiritual discernment.

This is where Dwellable becomes a *witness* to the user's spiritual journey, not an interpreter of it.

---

## Core Concept

**Theme Detection (Not Analysis):** 
- Detect words, phrases, concepts that appear 3+ times across moments/journals
- Example: User captures moments mentioning "doubt", "questioning", "uncertainty" → Theme emerges: *"Wondering"*
- Example: User captures 5 moments about relational conflict → Theme emerges: *"Relational friction"*
- Example: User captures moments about morning prayer, spiritual clarity, peace → Theme emerges: *"Morning encounters"*

**Rich Context Powered:**
- Use conversation history to understand *context* of themes (not just word frequency)
- Don't just count occurrences; understand *how* the user is talking about the theme
- Reference user's actual language and story arc when surfacing themes

**Invitational Framing (Never Prescriptive):**
- Not: "You're struggling with anxiety. Here's what you should do." ❌
- Yes: "You've reflected on doubt 8 times in the past month. What patterns do you notice?" ✅

---

## Happy Paths

### Path 1: Discover an Emerging Theme

**Scenario:** User has captured 3-4 moments over a 2-week period, each mentioning variations of the same struggle (doubt, questioning, uncertainty). App detects the theme and invites reflection.

1. **User Captures Moment #4** → Mentions "I'm questioning whether God is listening"
2. **Theme Detection Runs (Background)** → LLM analyzes all user's moments, finds pattern: "doubt/questioning" appears in moments 1, 3, 4
3. **Theme Emerges** → System marks theme as detected: *"Wondering"* (abstracted from user's language)
4. **Optional: Gentle In-App Indication** → User might see subtle notification or card: "A pattern is emerging" (non-intrusive)
5. **User Returns to App** → User opens app and sees themes in a "Themes" or "Patterns" dashboard
6. **Tap Theme** → User taps "Wondering" to see:
   - The 3 moments that form this pattern
   - How the user talked about it (snippets from journals)
   - An invitational prompt: "You've sat with this 3 times. What are you noticing?"

---

### Path 2: Explore Themes in Reflection

**Scenario:** User is in Soaking mode (dwelling on a past moment) and wants to understand how this moment connects to broader patterns.

1. **In Soaking/Dwelling Place** → User is reading a journal entry about doubt
2. **See Linked Themes** → Bottom of screen shows "This moment relates to: Wondering (3 moments)"
3. **Tap to Explore** → User taps theme link
4. **View Theme Context** → See all 3 moments + timeline of when theme emerged
5. **Reflection Prompt** → "You've visited this struggle across these moments. What's shifted?"
6. **Guided Reflection** → Optional: User can respond with prayer or prompt sequence (Pillar 3 integration)
7. **Return to Original Moment** → User can return to original moment or continue exploring

---

### Path 3: Weekly Theme Summary

**Scenario:** User receives optional weekly summary of emerging themes (pull-based, not push).

1. **User Opens App** → Sees "Weekly themes" card (optional feature)
2. **View Summary** → "This week you reflected on: Hope (2 moments), Relational Joy (3 moments), Guidance (1 moment)"
3. **Tap Theme** → Can dive into any theme to see moment context
4. **Reflection Prompt** → "What story is emerging across these themes?"
5. **Pray or Journal** → User can respond, or dismiss and return later

---

### Path 4: Filter Search & Discovery by Theme

**Scenario:** User is in Search mode and wants to find all moments related to a detected theme.

1. **In Search** → User is browsing moments from past month
2. **Apply Theme Filter** → User taps "Filter by theme" and sees detected themes
3. **Select Theme** → User chooses "Wondering" 
4. **See Filtered Results** → Only moments tagged with "Wondering" theme appear
5. **Explore Context** → User sees how theme evolved across these moments
6. **Return to Search** → User can remove theme filter or add more filters

---

### Path 5: Monthly Formation Review

**Scenario:** User reviews their spiritual journey over a month and sees the arc of themes that emerged.

1. **From Dashboard** → User taps "Monthly Review" or "Formation View"
2. **See Month's Themes** → Visual or text summary: "In April, your journey included..."
   - Joy & Gratitude (5 moments)
   - Uncertainty (4 moments)
   - Breakthrough (2 moments)
3. **View Timeline** → Themes appear in chronological order so user can see the arc
4. **Reflection Questions** → "How did Joy & Gratitude emerge after Uncertainty?"
5. **Spiritual Discernment** → User can see their own story, make their own meaning

---

## Locked Decisions

1. ✅ **Theme Detection Trigger:** Automatic detection when theme appears 3+ times (or configurable threshold)
2. ✅ **Rich Context Required:** Themes must use conversation history + user's language, not just keyword frequency
3. ✅ **Invitational Framing:** All prompts are questions, never directives ("What patterns do you notice?" not "Here's what this means")
4. ✅ **No Interpretation:** Themes surface observed patterns; user interprets meaning
5. ✅ **User Language:** Theme names use user's own words/phrases when possible (abstracted but authentic)
6. ✅ **Theme Linking:** Themes link moments to journals, enabling cross-moment reflection
7. ✅ **Timeline View:** Show when themes emerged and evolved over time
8. ✅ **Privacy by Default:** Theme detection is on-device first (optional cloud sync for cross-device)

---

## Tentative Decisions (TBD by Designer/Product)

1. ❓ **Theme Naming:** Auto-generated names (LLM abstraction) vs user-customizable names? (Recommend: auto-generated for MVP, customizable Phase 3)
2. ❓ **Push vs Pull:** Should themes be proactively surfaced (notifications) or pull-based (dashboard only)? (Recommend: pull-based for MVP, notifications Phase 3)
3. ❓ **Theme Threshold:** Should detection trigger at 3 occurrences, 5, or configurable? (Recommend: 3 for MVP)
4. ❓ **Monthly Review:** Should this be automated or user-triggered? (Recommend: user-triggered for MVP)
5. ❓ **Visual vs Text:** Should themes be visualized (images, colors) or text-only? (Recommend: text-only for MVP, visuals Phase 3)

---

## Open Questions (Deferred)

- Predictive pattern recognition ("Based on your patterns, here's what might emerge next") — Phase 3+
- AI-generated moment illustrations by theme — Phase 3+
- Collaborative theme discussion (community) — post-launch
- Spiritual direction integration (clergy partnerships) — post-launch
- Machine learning on user's interpretation of themes — Phase 3+

---

## Success Metrics

- Theme detection accuracy: >80% of detected themes align with user's actual patterns (qualitative survey)
- User engagement: >50% of users interact with discovered themes
- Reflection depth: Users who engage with themes have >2x session length vs non-theme users
- User sentiment: >4.0/5.0 satisfaction with theme relevance (survey)
- Formation perception: Users report "I'm seeing patterns in how God shows up" (qualitative)

---

## Integration Points with Other Pillars

- **Pillar 1 (Capture):** Detect themes in captured moment transcripts
- **Pillar 4 (Journal Creation):** Detect themes in synthesized journal bodies (richer content for detection)
- **Pillar 3 (Soaking):** Show theme context in reflection; offer theme-related prompts/prayers
- **Pillar 6 (Search & Discovery):** Filter moments/journals by detected themes
- **Pillar 8 (Beta & Marketing):** Measure theme engagement as key dwelling metric

---

## Technical Considerations

### Theme Detection Architecture

```swift
struct DetectedTheme: Codable {
    let id: String                              // UUID
    let userId: String                          // Owner
    let name: String                            // Theme name (user language)
    let description: String?                    // What the theme is about (rich context summary)
    let relatedMomentIds: [String]              // Moments that form this theme
    let relatedJournalIds: [String]             // Journals that express this theme
    let firstDetectedAt: Date                   // When theme first emerged
    let lastUpdatedAt: Date                     // When theme was last updated
    let frequency: Int                          // Count of appearances
    let emotionalArc: String?                   // How user's emotional tone changed across theme moments
    let richContextSummary: String?             // LLM-generated understanding of theme's meaning to user
    let userInterpretation: String?             // User's own notes about what theme means (optional)
    let archived: Bool                          // User can archive themes they've "processed"
}

struct ThemeTimeline: Codable {
    let themeId: String
    let momentIds: [String]                     // Chronological order of theme appearances
    let emotionalProgression: [String]          // How user's feeling evolved
    let insights: [String]                      // Key moments where insight occurred
}
```

### Theme Detection Flow (Backend/LLM)

1. **Trigger:** New moment created OR periodic batch detection (daily/weekly)
2. **Context Gathering:** Retrieve user's last 50 moments + journals
3. **LLM Analysis:** "What recurring themes appear across these moments? What patterns are emerging in this person's spiritual journey?"
4. **Theme Extraction:** LLM returns [{ theme_name, related_moments, why_it_matters, emotional_arc }]
5. **Persist Themes:** Save detected themes to database, mark new ones
6. **Notification (Optional):** If enabled, notify user of new themes

### Encryption Implications

- Theme detection must work on-device first (don't send raw content to cloud)
- Option: Cloud-based detection with encrypted content transmission
- Store theme data encrypted (same AES-256-GCM as other pillars)

---

## Next Steps

1. Designer to finalize theme presentation UI (dashboard, timeline, linked view)
2. Define LLM prompts for theme detection (what input/output format)
3. Engineer to scope on-device LLM integration (where/how does detection run)
4. Create implementation tickets with effort estimates

---

## Success Criteria for Design Lock

- ✅ Happy paths documented and reviewed
- ⏳ Mockups created for theme dashboard and timeline views
- ⏳ LLM prompts defined for theme detection and naming
- ⏳ Data model for themes finalized
- ⏳ Integration points with Soaking (Pillar 3) specified
- ⏳ Implementation tickets created with effort estimates

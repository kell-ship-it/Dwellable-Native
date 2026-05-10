# Pillar 7: Formation Intelligence (Theme Detection & Patterns) — Strategy & Design Specification

**Founder:** Kell Golden | **Status:** 🔄 **DESIGN IN PROGRESS** | **Updated:** May 10, 2026

---

## Design Summary

Pillar 7 enables Dwellable to detect recurring themes and patterns across a user's captured moments and journals, then surface them as invitations for reflection — never as interpretation or direction. The core principle: help users *notice* the patterns they are living through, using their own language and story, so they can respond with wisdom and spiritual discernment.

This is where Dwellable becomes a *witness* to the user's spiritual journey, not an interpreter of it.

---

## Formation Intelligence System — What Pillar 7 Is & Learns

### What Pillar 7 Is (in the Formation Intelligence System)

**The pattern-naming layer. Synthesis + witness.**

| Pillar | Role |
|--------|------|
| **P0 (Onboarding)** | Establishes foundation: identity + theological framework |
| **P1 (Capture)** | Captures raw moment + infers archetype |
| **P2 (Security)** | Protects moments so P3+ can use rich context confidently |
| **P3 (Soaking)** | Seals moment with prayer — signals value to God |
| **P4 (Journal Creation)** | Synthesizes moment into narrative dwelling place |
| **P5 (Editing)** | Personalizes narrative — user claims ownership |
| **P6 (Search & Discovery)** | Reveals patterns across time — user discovers themselves |
| **P7 (Formation Intelligence)** | *Names* patterns. Makes formation visible. Gives user language for growth. |

### What P7 Learns About the User

P7 learns *what patterns the user is actually living through*, and how they are thinking about them:

1. **Core Themes:** What spiritual/emotional struggles recur? What joys return? What growth patterns repeat?
2. **Emotional Arc:** How does the user's tone shift across moments about the same theme? Do they move from doubt → certainty? Anxiety → peace?
3. **Naming Preference:** How does the user naturally talk about their patterns? (Use their language, not app language)
4. **Pattern Urgency:** Which themes appear with greatest frequency/intensity? (Signals what's formation-critical right now)
5. **Theme Evolution:** Do themes shift over time? Does "Anxiety" become "Uncertainty"? Does "Healing" resolve into "Gratitude"?

### What P7 Communicates to the User

**Profound signal: Your spiritual journey is real, visible, and worth understanding.**

1. **"You have a story."**
   - Not just moments. Not just journals. A *pattern* — a spiritual arc — that's visible across time.
   - Pattern visibility = proof of formation happening.

2. **"Your growth is real."**
   - *"You've struggled with doubt 8 times. Look at how you're talking about it now vs. three months ago."*
   - Themes prove that change is happening, even when it feels invisible.

3. **"You get to name your journey."**
   - P7 uses the user's own language for themes, not clinical terminology.
   - This signals: your way of understanding your story is valid.

4. **"God is witnessing your formation."**
   - By naming patterns, P7 says: *"The patterns in your life are not random. They're the shape of your spiritual journey."*
   - This connects formation to faith (God sees the arc too).

### How P7 Prepares P8 (Beta & Marketing)

**P8 cannot celebrate user success without P7's articulation.**

Example (P8 future behavior):
- User completes first month. P8 says: *"Over 4 weeks, you captured 20 moments. Your biggest themes: 'Seeking' (7 moments) and 'Breakthrough' (5 moments). You're witnessing formation happen. Here's your story."*

This is only possible if:
1. P6 enabled discovery (user could search and see patterns themselves)
2. **P7 detected and named those themes** with Rich Context (not just keywords, but meaning)
3. P8 can now celebrate user's spiritual journey with actual evidence

**P7 removes abstract feedback:** By naming patterns clearly, P7 gives P8 concrete language to celebrate user success and invite continued engagement.

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

## Happy Paths (5 Main Paths)

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

### Path 2: Explore Themes in Reflection

**Scenario:** User is in Soaking mode (dwelling on a past moment) and wants to understand how this moment connects to broader patterns.

1. **In Soaking/Dwelling Place** → User is reading a journal entry about doubt
2. **See Linked Themes** → Bottom of screen shows "This moment relates to: Wondering (3 moments)"
3. **Tap to Explore** → User taps theme link
4. **View Theme Context** → See all 3 moments + timeline of when theme emerged
5. **Reflection Prompt** → "You've visited this struggle across these moments. What's shifted?"
6. **Guided Reflection** → Optional: User can respond with prayer or prompt sequence (Pillar 3 integration)
7. **Return to Original Moment** → User can return to original moment or continue exploring

### Path 3: Weekly Theme Summary

**Scenario:** User receives optional weekly summary of emerging themes (pull-based, not push).

1. **User Opens App** → Sees "Weekly themes" card (optional feature)
2. **View Summary** → "This week you reflected on: Hope (2 moments), Relational Joy (3 moments), Guidance (1 moment)"
3. **Tap Theme** → Can dive into any theme to see moment context
4. **Reflection Prompt** → "What story is emerging across these themes?"
5. **Pray or Journal** → User can respond, or dismiss and return later

### Path 4: Filter Search & Discovery by Theme

**Scenario:** User is in Search mode and wants to find all moments related to a detected theme.

1. **In Search** → User is browsing moments from past month
2. **Apply Theme Filter** → User taps "Filter by theme" and sees detected themes
3. **Select Theme** → User chooses "Wondering"
4. **See Filtered Results** → Only moments tagged with "Wondering" theme appear
5. **Explore Context** → User sees how theme evolved across these moments
6. **Return to Search** → User can remove theme filter or add more filters

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

## Data Model

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
    let encryptedContent: Data?                 // Theme data encrypted (AES-256-GCM)
}

struct ThemeTimeline: Codable {
    let themeId: String
    let momentIds: [String]                     // Chronological order of theme appearances
    let emotionalProgression: [String]          // How user's feeling evolved
    let insights: [String]                      // Key moments where insight occurred
}
```

---

## Technical Architecture

### Theme Detection Pipeline

```
New moment created (P1)
    ↓
Journal synthesized (P4)
    ↓
Background: LLM analyzes user's last 50 moments + journals
    ↓
LLM detects patterns: "What recurring themes appear in this person's spiritual journey?"
    ↓
Theme extraction: {theme_name, related_moments, why_it_matters, emotional_arc}
    ↓
Themes persisted to database (encrypted)
    ↓
User sees new themes in dashboard
    ↓
Optional: If user enables, mild notification ("New pattern detected")
```

### Key Components

**ThemeDetectionManager**
- Triggers on new moment creation OR periodic batch detection (daily/weekly)
- Retrieves user's last 50 moments + journals for context
- Calls LLM with Rich Context prompt: "What recurring themes appear across these moments?"
- Extracts theme data and persists to database

**ThemeLinkingService**
- Links detected themes to moments, journals, prayer responses
- Builds theme timeline (chronological order of appearances)
- Tracks emotional progression across theme instances

**EncryptionManager** (Shared with P2)
- Encrypts theme data before storing (same AES-256-GCM as other pillars)
- Decrypts on-device for display

**ThemeDashboardController**
- Displays detected themes in readable format
- Shows theme frequency, timeline, related moments
- Handles theme filtering in search (P6 integration)

---

## Security & Encryption

**Encryption Impact:**
- Theme names encrypted (derived from user's language)
- Theme descriptions encrypted (rich context summaries)
- Related moment/journal IDs encrypted
- Theme data stored encrypted (same AES-256-GCM as P2/P4)

**Privacy:**
- Theme detection can run on-device first (optional cloud-based)
- Themes are private to user (no cross-user theme visibility)
- User can archive/hide themes they've processed

---

## Success Metrics (P7)

### Formation Intelligence Perspective
- ✅ Theme detection accuracy: >80% of detected themes align with user's actual patterns (qualitative survey)
- ✅ User engagement: >50% of users interact with discovered themes
- ✅ Reflection depth: Users who engage with themes have >2x session length vs non-theme users
- ✅ User sentiment: >4.0/5.0 satisfaction with theme relevance
- ✅ Formation perception: Users report *"I'm seeing patterns in how God shows up"* (qualitative)
- ✅ Theme accuracy: Themes use user's own language and feel authentic

### Technical Perspective
- ✅ Theme detection latency <5 seconds (background)
- ✅ Encryption working reliably for theme data
- ✅ Theme linking across moments + journals working correctly
- ✅ No performance degradation with 50+ detected themes

---

## Open Questions & TBD

1. **Theme Naming Strategy?** (TBD)
   - Auto-generated names (LLM abstraction) vs user-customizable names?
   - Recommend: auto-generated for MVP, customizable Post MVP

2. **Push vs Pull?** (TBD)
   - Should themes be proactively notified (push) or pull-based (dashboard only)?
   - Recommend: pull-based for MVP, notifications Post MVP

3. **Theme Threshold?** (Locked: 3 occurrences)
   - Should detection trigger at 3 occurrences, 5, or configurable?
   - MVP: 3 occurrences

4. **Predictive Patterns?** (Deferred to Post MVP)
   - Should P7 predict *upcoming* themes based on patterns?
   - "Based on your patterns, X might emerge next" — Post MVP feature

5. **Visual Theming?** (Deferred to Post MVP)
   - Should themes have colors, icons, illustrations?
   - MVP: text-only, Post MVP: visual theming

---

## Considered & Rejected

| Decision | Reasoning |
|----------|-----------|
| **AI-generated moment illustrations** | Visual design deferred to Post MVP. MVP focus: text-only themes. |
| **Community theme discussion** | Social features deferred to post-launch. MVP: personal themes only. |
| **Automatic theme naming (no review)** | User should see + validate theme names. Let them customize if needed. |
| **Predictive pattern recognition** | Too speculative for MVP. Focus on detecting current patterns first. |
| **Spiritual direction integration** | Clergy partnerships deferred to post-launch. MVP: personal reflection only. |

---

## Integration Points with Other Pillars

| Pillar | Integration |
|--------|-----------|
| **P1 (Capture)** | Detect themes in captured moment transcripts. |
| **P4 (Journal Creation)** | Detect themes in synthesized journal bodies (richer content for detection). |
| **P3 (Soaking)** | Show theme context in reflection; offer theme-related prompts/prayers. |
| **P5 (Editing)** | Tags + moods edited by user inform theme detection (personalized signals). |
| **P6 (Search & Discovery)** | Filter moments/journals by detected themes. Search by theme. |
| **P8 (Beta & Marketing)** | Use detected themes to celebrate user's spiritual journey (evidence of formation). |

---

## Next: How P7 Prepares P8

Once P7 is implemented, P8 (Beta & Marketing) can be articulated as:
- **What P8 is:** A celebration + retention layer that uses P7's theme articulation to show users their spiritual progress
- **What P8 learns:** Which formation narratives resonate with users, what stories keep them engaged
- **How P8 prepares future phases:** By validating that Formation Intelligence works (users see themselves, trust the system, return repeatedly)

---

**Ready to lock P7 Formation Intelligence and move to P8?**

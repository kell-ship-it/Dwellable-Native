# Pillar 9: Notifications & Formation Intelligence

**Status:** Strategy Reframe (Formation Intelligence Lens) | **Updated:** May 11, 2026 | **Extends:** PILLAR_7_NOTIFICATIONS_STRATEGY.md

---

## The Reframe: From "Invitations to Return" to "Invitations to Notice"

The current Notifications strategy (PILLAR_7_NOTIFICATIONS_STRATEGY.md) is strong on **engagement** (CTR, D7 retention, opt-out rates) but misses a critical insight: **notifications should serve spiritual formation, not just app usage**.

**What shifts:**
- Current: "Come back and reflect on something" → metric: CTR, return rate
- Formation-Aligned: "Here's a pattern emerging in your spiritual journey. What do you notice?" → metric: Formation depth, spiritual discernment

This requires tying notifications to **Formation Intelligence** — what the user is becoming, not just what they're using.

---

## Formation Intelligence + Notifications: The Connection

Dwellable's Formation Intelligence system (Pillar 7) tracks:
- **P0:** User's spiritual foundation (valuable + worthy) and theological framework
- **P1:** User's archetype (Jotter / Venter / Processor) and emotional/spiritual tone
- **P3:** How user prays and what prompts they engage (prayer style, reflection depth)
- **P4:** How user's emotional arc shifts across moments (growth signals)
- **P6:** What themes emerge across moments (patterns user is living through)
- **P7:** Metadata about user's formation journey (pace, consistency, breakthroughs)

**Notifications should leverage this system to help the user *see themselves forming*.**

---

## Reframed Notification Purpose

### Current Purpose
Bring user back to the app to engage with moments (return rate metric).

### Formation-Aligned Purpose
Help user notice patterns and rhythms in their spiritual journey so they can respond with greater wisdom and discernment (formation metric).

---

## Four Types of Formation-Aligned Notifications

Instead of generic "come back and reflect," Notifications should be tied to Formation Intelligence signals:

### Type 1: **Archetype-Affirming Notifications** (P1 → Notification)

**What we learned:** P1 captures user's archetype (Jotter, Venter, Processor).

**Formation-aligned notification:** Affirm the user's natural way of processing.

**Examples:**
- **Jotter Archetype:** "You've captured 7 moments this month. You're building a beautiful record of your journey. Want to read back and see the arc?"
- **Venter Archetype:** "You've processed a lot this month. Dwelling helps you move from feeling to understanding. Ready to go deeper?"
- **Processor Archetype:** "You're seeking understanding in your moments. A prompt might help you discover something new."

**Signal:** Moments captured count, archetype detected, emotional tone of moments

**Formation value:** Affirms user's natural spiritual style (not trying to change them into a different archetype)

---

### Type 2: **Breakthrough Recognition Notifications** (P4 + P6 → Notification)

**What we learned:** P4 detects shifts in mood/emotional tone; P6 detects themes.

**Formation-aligned notification:** Celebrate moments of growth or breakthrough.

**Examples:**
- "Over the past week, you've shifted from doubt to hope. What shifted?"
- "You've been wrestling with anxiety, and this week something changed. Want to explore?"
- "In your last moment, you wrote about finding clarity. That's a breakthrough moment worth dwelling on."

**Signal:** Mood/tone shift detected (P4), theme progression detected (P6), emotional arc trending positive

**Formation value:** Helps user *see* their own spiritual growth, not just capture moments

---

### Type 3: **Theme Emergence Notifications** (P6 + P7 → Notification)

**What we learned:** P6/P7 detect recurring themes (doubt, relational joy, trust, etc.).

**Formation-aligned notification:** Invite user to notice patterns they're living through.

**Examples:**
- "You've reflected on doubt 4 times this month. What does doubt feel like for you right now? What are you learning?"
- "A theme is emerging: moments about being seen and loved. You're capturing these. What does that tell you?"
- "Over the past 6 weeks, joy appears in moments with specific people. Do you notice what that means?"

**Signal:** Theme detection (3+ occurrences), theme frequency increase, new theme emergence

**Formation value:** Helps user become aware of their own patterns (not interpreting them, but inviting discernment)

---

### Type 4: **Contemplative Rhythm Notifications** (P7 → Notification)

**What we learned:** P7 tracks user's reflection rhythm and consistency.

**Formation-aligned notification:** Invite user to notice their own pace and rhythm of spiritual formation.

**Examples:**
- "You typically dwell on Sundays. It's Sunday morning. Ready to reflect?"
- "Your pace of formation has been steady this month. You're building something. Want to see the arc?"
- "You responded to 2 prompts last week. That's your natural rhythm. This week?"
- "You've been quiet for 2 weeks. No pressure—but if there's something on your heart, we're here."

**Signal:** Engagement frequency (P7), day/time patterns (P7), consistency metrics

**Formation value:** Honors user's actual rhythm (not pushing them to be more frequent) while inviting them to notice their own patterns

---

## How This Differs from Current Strategy

| Aspect | Current | Formation-Aligned |
|--------|---------|------------------|
| **Trigger** | User segment + app usage metrics | Formation Intelligence signals (archetype, themes, breakthrough, rhythm) |
| **Message Tone** | "Come back and reflect" | "Notice what's emerging in your journey" |
| **Data Source** | Usage frequency, soaking engagement | Moment content patterns, emotional arc, theme detection |
| **Success Metric** | CTR (click-through), D7 retention | Formation depth (user sees their own patterns, responds with discernment) |
| **Privacy Impact** | Metadata-only (due to encryption) | **Still metadata-only** (Formation Intelligence works with encrypted data) |
| **User Experience** | "The app is inviting me back" | "The app is helping me understand myself and God's work in my life" |

---

## Formation Intelligence + Encryption: Why This Works

**The challenge:** E2E encryption means we can't read user content. So how can we do Formation Intelligence signals?

**The solution:** Formation Intelligence works on **encrypted data patterns**, not plaintext:

**What we CAN detect (even with encryption):**
- ✓ Frequency of moments (how many moments captured this week)
- ✓ Mood tags captured by user (moods are user-selected metadata, not encrypted)
- ✓ Timing patterns (when user captures, when user reflects)
- ✓ Theme metadata (theme names detected and stored as metadata)
- ✓ Emotional progression (mood tag sequence over time = arc)
- ✓ Archetype signals (moment creation style, prompt preferences)
- ✓ Soaking behavior (prayer vs prompt preference, reflection depth)

**What we CANNOT do:**
- ✗ Reference specific moment content in notifications
- ✗ Personalize with details from encrypted journals
- ✗ Interpret the "meaning" of encrypted moments

**Translation:**
- Can't say: "You wrote about your brother yesterday. He matters to you."
- Can say: "Relational moments are emerging as a theme. What's happening in your relationships?"

---

## Revised Notification Examples (Formation Intelligence Lens)

### Segment 1: New User (Archetype Detection)
```
After user captures first 3 moments, system detects archetype.

JOTTER ARCHETYPE:
Title: "You're building a record of what matters"
Body: "You've captured 3 moments. That's the start of a beautiful archive 
       of how God is moving in your life. Want to read them back?"
Action: Opens Dwelling Place

VENTER ARCHETYPE:
Title: "You're processing something real"
Body: "You've shared what's on your heart. Now comes the deeper work: 
       what are you learning? A prompt might help."
Action: Opens Soaking mode

PROCESSOR ARCHETYPE:
Title: "You're seeking understanding"
Body: "Your moments ask questions. Dwell on one and see what emerges."
Action: Opens Soaking mode
```

### Segment 2: Theme Emergence
```
User has captured 4 moments. Detection runs. Theme emerges: "Doubt"

Title: "A pattern is becoming visible"
Body: "You've reflected on doubt 4 times this month. That's real. 
       What do you notice about doubt in your spiritual journey?"
Action: Opens theme view (shows 4 moments + invitational prompt)
```

### Segment 3: Breakthrough Recognition
```
User's mood tags over 2 weeks: Conflicted → Unsure → Hopeful → Peaceful

Title: "Something is shifting"
Body: "Two weeks ago you were wrestling. This week your tone changed. 
       Want to dwell on what shifted?"
Action: Opens recent moments (shows emotional progression)
```

### Segment 4: Rhythm Recognition
```
User typically captures Mondays and Thursdays. It's Monday morning.

Title: "It's Monday. Your rhythm"
Body: "You usually capture on Mondays. No obligation—but if there's 
       something to notice from your week, we're listening."
Action: Opens Create tab
```

---

## Implementation Notes for T-093+ Notifications Tickets

When creating implementation tickets for Pillar 9, ensure:

1. **Data model includes Formation Intelligence metadata:**
   - User archetype (detected from P1)
   - Theme metadata (detected from P6/P7)
   - Mood tag history (for emotional arc)
   - Reflection rhythm (frequency patterns)
   - Breakthrough signals (mood shift detection)

2. **LLM prompt for notification generation includes Formation Intelligence context:**
   - "Generate a notification for a [Jotter/Venter/Processor] user who is..."
   - "Generate a notification about the [theme_name] theme that's emerging in [user's] journey..."
   - "Generate a notification recognizing this breakthrough: [emotional_arc_summary]..."

3. **Privacy maintained throughout:**
   - Reference no encrypted moment content
   - Use only metadata and user-selected tags
   - Keep E2E encryption promise intact

4. **Metrics should measure formation, not just engagement:**
   - Users who receive formation-aligned notifications show >3x engagement depth
   - Users report notifications feel "personally relevant" (>4.0/5.0)
   - Formation Engagement Rate (% dwelling on notified themes) > 30%

---

## Next Steps

1. **Finalize this strategy** (user approval needed)
2. **Rewrite T-083 through T-091 tickets** to include Formation Intelligence requirements
3. **Create notification copy guidelines** that honor the Formation Intelligence lens
4. **Define LLM prompts** for Formation Intelligence-powered notification generation
5. **Build Formation Intelligence data model** if not already in T-062 (Encryption) or subsequent pillars

---

## Key Questions to Resolve

1. **Should we launch with Formation Intelligence notifications, or start with current generic strategy?**
   - Recommendation: Start with generic (T-083–T-091 as planned), then layer Formation Intelligence in Phase 2+
   - Rationale: Formation Intelligence system (P6/P7) must ship first; notifications depend on it

2. **How much Formation Intelligence context is "safe" to surface without compromising privacy?**
   - Current answer: Metadata-only (mood tags, theme names, frequency patterns)
   - Verify with T-062 (Encryption) that this remains true

3. **Should users see "why" they got a notification?**
   - Recommendation: Yes. "We noticed a pattern in your moments..." makes Formation Intelligence transparent

4. **What's the opt-out rate if we personalize with Formation Intelligence?**
   - Hypothesis: Lower than generic (users feel "seen" not "tracked")
   - Plan to A/B test: generic vs Formation Intelligence in beta

---

**This reframe turns Notifications from an engagement lever into a formation lever — helping users see themselves being formed.**

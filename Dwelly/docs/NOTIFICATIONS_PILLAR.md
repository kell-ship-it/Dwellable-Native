# Notifications Pillar (Pillar 8)

**Status:** Concept locked, design deferred to Phase 2+  
**Sequence:** Last pillar — comes after all experiences exist  
**Session Locked:** May 4, 2026

---

## Purpose

Notify users about reflections that didn't get prayer, especially when a theme emerges.

Enable users to revisit incomplete reflections and deepen their dwelling practice.

---

## Core Concept

**Problem:** User captures and reflects on moments, but doesn't always respond with prayer. Without a gentle return mechanism, they miss the opportunity to deepen their spiritual response to what God is doing in their life.

**Solution:** Pattern detection + contextual nudges

- User reflects on "anxiety" 3 times without praying
- App detects emerging theme and sends notification: *"You reflected on anxiety, but haven't prayed. Want to now?"*
- User clicks through to respond with prayer/prompt right then, or save to revisit later

---

## How It Works

### Pattern Detection
- Monitors reflections that skip the prayer response layer
- Identifies when a theme emerges (3+ moments on similar topics)
- Uses Rich Context to understand user's history and language

### Notification Trigger
- Only notify when pattern is clear (not after first moment, not too soon)
- Invitational, not prescriptive: "Want to?" not "You should"
- Contextual to user's actual story (personalized via Rich Context)

### User Flow
1. User receives notification about unprayed reflections on anxiety
2. User can:
   - Respond with prayer right now
   - Respond with prompts (deeper reflection)
   - Dismiss and revisit later (saved to soaking layer)
   - Adjust notification frequency/preferences

---

## Rich Context Integration

Notifications are powered by Rich Context:
- Understand user's actual story (themes, arcs, patterns over time)
- Generate contextual nudges that reference their journey
- Example: *"You've talked about this relationship struggle for months. We haven't prayed about it yet. Want to now?"*

---

## Why This Pillar Matters

Notifications is the **return mechanism** for dwelling.

Without it: Users capture → respond → move on. Moments feel complete but never deepened.

With it: Users capture → respond → get gently invited back when patterns emerge. They experience their moments accumulating into a living record of God's presence.

---

## Design Questions (Deferred)

When we design Pillar 8 (Phase 2+), we'll answer:

- **Timing:** When should nudge arrive? (next day? after 3rd moment? week later? user-configurable?)
- **Theme detection:** How to identify themes without prescriptive interpretation? (keywords? semantic similarity? user tagging?)
- **User control:** Can they opt-out? Customize frequency? Choose which themes trigger nudges?
- **Scope:** What counts as a "theme"? Single word or semantic pattern?
- **Frequency cap:** Avoid notification fatigue—limit nudges per week/month

---

## Why Deferred to Last

**Pillar Resequencing Decision (May 4, 2026):**

> "We need to confirm what experiences we are creating before knowing what we are notifying dwellers of."

Notifications requires:
1. Responding to Captures layer to exist (Pillar 3 — what are they responding with?)
2. Other pillars to define the shape of the app (what else deserves notification?)
3. Clear data model for tracking unresponded reflections

Build the experiences first, *then* design the return mechanisms.

---

## Connection to Other Pillars

- **Responds to:** Pillar 3 (Soaking/Responding to Captures) — nudges for unprayed reflections
- **Feeds into:** Future pattern surfacing, seasonal reviews, formation intelligence
- **Data dependency:** Rich Context (Pillar 2) — notifications require understanding user's story

---

## Phase 2+ Implementation

When Pillar 8 design begins:

1. **Research** (Step 2): How do meditation/prayer apps handle return nudges? (Calm, Waking Up, Ten Percent Happier)
2. **Pattern Extraction** (Step 3): What themes emerge across competitive apps?
3. **Skeleton Design** (Step 4): 2-3 notification types (unprayed reflections, weekly theme digests, seasonal reviews)
4. **Implementation:** Backend queries for unprayed moments, notification scheduling, user preferences

---

## Success Metrics

- % of unprayed reflections that users return to and complete prayer
- Engagement lift from notification (do moments get more re-reads after nudge?)
- User satisfaction (do nudges feel helpful or intrusive?)
- Theme accuracy (do detected themes match user's perception?)

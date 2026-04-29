# Dwellable Onboarding — Design Guidelines

**Document Purpose:** Establish onboarding principles and messaging strategy for Phase 2 + beyond. Ensures new users understand who Dwellable is for, what problems it solves, and how it works.

**Created:** April 29, 2026  
**Status:** Foundation for P0 onboarding design

---

## Onboarding Philosophy: Tell the Essential, Show the Rest

The core tension in onboarding: **What must be explicitly stated vs. what can emerge through experience?**

Dwellable's onboarding approach: **Tell the non-obvious, show the intuitive.**

### What Gets TOLD (Explicit Messaging)

These truths cannot be discovered through UX alone. They must be stated so users make an informed choice to engage:

1. **Identity:** "Dwellable is for Christians capturing all their moments—highs, lows, mundane—and noticing God's presence."
   - Why tell: "God moments" could mean supernatural/special. We're broader: daily life + faith.
   - Filters out non-target audience early (respectfully).

2. **Promise:** "We hold your moments. We don't interpret them for you."
   - Why tell: This is the core relationship contract. Users need to trust us *before* being vulnerable.
   - Can't be shown in onboarding alone; must be stated.

3. **Practice:** "Dwellable is about capturing your life and reflecting on how God shows up—not just capturing."
   - Why tell: The difference between journal app (many) and formation tool (ours) needs to be clear.
   - Without this, users might think it's generic journaling.

4. **Entry Point:** "You don't need a special 'God moment' to capture something. Everything is worth reflecting on."
   - Why tell: Removes the adoption barrier ("I don't have a moment to capture today").
   - Clarifies that mundane moments count.

---

### What Gets SHOWN (Experiential Discovery)

These emerge naturally through the onboarding flow. Users discover them through action, not reading:

1. **Ease of capture:** User taps mic → speaks → moment saved (3 taps). Shows that capture is frictionless.
2. **Privacy + safety:** Moments stay on device. Screens explicitly show "Your articles stored only on your device."
3. **Personal relevance:** "What brings you here?" questions help user articulate their own problem. They discover "this is for me" through their own answer.
4. **Reflection focus:** Gallery, Headlines, and eventual Soak Mode show (rather than tell) that this is about dwelling, not just keeping.

---

## Hybrid Onboarding Flow

### Screen 1 (TELL — Essential Framing)
**Purpose:** Establish identity + promise  
**Copy approach:** Direct, clear, permission-giving

```
Headline: "Dwellable is for Christians"

Body copy: "We help you capture your entire life—work, relationships, 
doubts, breakthroughs, ordinary moments—and notice how God shows up.

We hold your moments. We don't interpret them for you.

You don't need a special 'God moment.' Everything is worth reflecting on.
Everything is worth dwelling on."

CTA: "Let's get started"
```

**Why this works:**
- Explicitly filters for Christians (permission to engage)
- Clarifies "all moments," not special ones
- States the keeper promise upfront
- Gives permission to capture ordinary things

---

### Screen 2–N (SHOW — Discovery Through Questions)
**Purpose:** Invite personal reflection + understand context  
**Copy approach:** Socratic, open-ended

```
Screen 2: "What brings you here?"
[User types or speaks answer]

Screen 3: "What was the moment that made you download this?"
[Helps them articulate their own problem]

Screen 4: [Privacy assurance screen]
"Your moments stay private.
Everything you capture is stored only on your device.
We see none of it."
```

**Why this works:**
- Questions let user define their own problem (feels personal)
- Answering the questions *is* the first moment capture
- Privacy shown (not just told)
- No feature dump—just conversation

---

### Screen N+1 (Transition to Core Loop)
**Purpose:** Enter capture experience  
**Copy approach:** Welcoming, action-oriented

```
"You're all set.

Now let's capture what's on your heart.
Tap the mic to start, or type if that feels better."

[User lands on CaptureView]
```

**Why this works:**
- Frames capture as the natural next step
- Offers both voice + text (respects preference)
- Minimal friction to first action

---

## Messaging Principles

### ✅ DO:

- **Frame as a practice, not a feature list** — "Capture + reflect" not "Gallery + tags + soak"
- **Invite, don't prescribe** — "Notice how God shows up" not "Learn God's lessons"
- **Permission-giving** — "Your moment can be anything" not "Moments should be..."
- **Personal pronouns** — "Your life," "Your faith," "Your practice" (singular, intimate)
- **Honest scope** — "We help you notice God in all of it" not "We'll transform your life"
- **User agency** — "You decide what's worth capturing" (optional, user-controlled)

### ❌ DON'T:

- ~~Feature dump~~ — Avoid listing Gallery, Tags, Soak Mode in onboarding
- ~~Spiritual direction copy~~ — Avoid "God wants you to..." or "You should reflect..."
- ~~Jargon~~ — Avoid "contemplative practice," "spiritual formation," "hermeneutics" (explain simply)
- ~~Comparison~~ — Avoid "unlike other apps" (focus on ourselves, not competitors)
- ~~Pressure~~ — Avoid "daily habit," "never miss a moment," gamification language
- ~~Generic benefits~~ — Avoid "feel better," "reduce stress," "find peace" (too broad)

---

## Onboarding Sequence Summary

| Screen | Purpose | Type | User Action |
|--------|---------|------|-------------|
| 1 | Tell essential identity + promise | Copy-forward (TELL) | Reads + taps "Get started" |
| 2 | Invite personal problem articulation | Question (SHOW) | Answers "What brings you here?" |
| 3 | Understand context + motivation | Question (SHOW) | Answers "What moment made you download?" |
| 4 | Establish trust through privacy clarity | Copy-forward (TELL) | Reads + understands data safety |
| 5 | Transition to core loop | Copy-forward + CTA | Taps "Capture your moment" |
| 6 | First capture experience | Action (SHOW) | Voice or text moment capture |

---

## Success Criteria for Onboarding

**Primary metrics:**
- Time to first moment: < 3 minutes from app open
- Completion rate: 85%+ reach Screen 6 (first capture)
- User comfort: "I understand what Dwellable is for" (target: 90%+ agree)

**Secondary signals:**
- Return rate after first capture: 70%+ return within 7 days
- Quote from user testing: "I didn't realize Dwellable was about capturing everyday moments, not just spiritual encounters"

---

## Iteration & Testing

After P0 launch, measure:
1. **Comprehension:** Do users understand "all moments" positioning? (Survey in week 1)
2. **Adoption:** What % of users complete onboarding? (Funnel analysis)
3. **Confidence:** Do users feel safe capturing vulnerable moments? (Post-first-capture survey)

If comprehension < 80%, iterate Screen 1 copy. If adoption < 70%, reduce screen count. If safety concerns arise, emphasize privacy more explicitly.

---

## Related Documents

- **VISION.md** — North star (notice God across entire life)
- **PRD.md** — Problem statement (journal + reflection gap)
- **P0_FEATURE_RESEARCH_FINDINGS.md** — Research basis for features
- **T-060_Phase2_Themes_1Pager.md** — Strategic positioning

---

**Document prepared for:** P0 onboarding design (Phase 2)  
**Author:** Claude Code (Dwellable Agent)  
**Date:** April 29, 2026

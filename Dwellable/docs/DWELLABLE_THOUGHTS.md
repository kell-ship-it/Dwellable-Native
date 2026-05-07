# Dwellable Random Thoughts & Architectural Considerations

**Purpose:** Capture stray architectural questions, design ideas, and product considerations that don't fit neatly into pillar strategy docs or the PRD.

**Format:** Each thought is dated, labeled by pillar/area, and includes context + question(s) for future resolution.

---

## Thoughts

### 1. Soaking Reflection Placement (Pillar 3)
**Date:** May 5, 2026  
**Pillar:** Soaking & Reflection  
**Status:** Open — Design Decision Needed

**Question:** When soaking is enabled per reflection, what's the UX context?

- **Option A (Focused/Immersive):** User is in Soak Mode for a single moment (fullscreen, moment text prominent, soundscape controls, timer) — view is moment-focused, not gallery-aware
- **Option B (List Context):** User is browsing Gallery → taps "Soak" pill/button on a moment → soaks while seeing gallery behind it as context or as dismissible
- **Option C (Hybrid):** Start in Gallery list → select moment → transition to fullscreen Soak Mode

**Current Assumption:** Option A (fullscreen, immersive, moment-focused) aligns with "contemplative environment" language in Pillar 3 skeletal system. Soaking is meant to shift from passive scroll (30s) to active contemplation (5-15 min), suggesting full-screen focus.

**Next Step:** Validate this UX assumption through wireframes or user testing in Phase 2.

---

### 2. Reflection Display Format (Pillar 4 — Headlines, Tags, Editing)
**Date:** May 5, 2026  
**Pillar:** Editing & Reflection Display  
**Status:** Open — Design Direction Needed

**Question:** How should user reflections be displayed after saving?

- **Option A (Conversational):** Moment + Prompt + User Response displayed as back-and-forth dialogue (like iMessage bubbles or Untold format). Feels interactive, shows the reflection process, implies ongoing conversation with app/prompts.
- **Option B (Polished/Final):** Reflection rendered as a finished journal entry (clean, cohesive, complete-feeling). Feels more traditional, less process-visible, emphasizes the outcome.

**Context:**
- Untold uses conversational format (shows user entry + AI-generated summary + editing capability)
- Some users may prefer conversational (seeing their reflection journey); others may prefer final/polished (feeling of completion)
- Dwellable's "let Dwellable reflect with your God moment" framing suggests conversational dialogue, but needs validation

**Next Step:** User testing or competitor analysis to determine which resonates with Dwellable's intended audience (contemplative users vs. reflective journalers vs. both).

---

## To Add

(This file will grow as architectural questions surface during Pillar 4/5 design and implementation.)

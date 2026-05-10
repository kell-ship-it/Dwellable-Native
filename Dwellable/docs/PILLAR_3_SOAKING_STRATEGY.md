# Pillar 3: Soaking & Responding to Captures — Strategy & Design Skeleton

**Status:** 🔄 Design Complete, Implementation Not Started (T-063, T-064, T-065, T-066)  
**Last Updated:** May 5, 2026

---

## Key Job to Be Done

**Phase 1 Proven:** Capture adoption is 100%. Users will voice-record moments when it's frictionless.

**Phase 1 Gap:** Return rate is 0%. Users captured moments but never re-opened the app to reflect on them. The barrier is not *capturing* moments—it's **dwelling on them**.

**Pillar 3's Job:** Transform captured moments from static artifacts into anchors for reflection and spiritual formation by inviting users back to their moments through visible galleries, gentle prompts, and contemplative experiences.

---

## Skeletal System Overview

Pillar 3 consists of four interconnected features that together create the **dwelling experience**:

### 1. **Gallery View (Visual Moment Catalog)**
- **What:** Tile-based visual grid showing all user's moments (work days, breakthroughs, struggles, celebrations)
- **Design:** Each tile shows:
  - Moment preview (first 20 words or auto-generated headline)
  - Date stamp
  - Optional visual indicator (emoji, color, or AI-generated imagery — deferred to P1)
  - Tap to open full moment detail
- **Entry Point:** Primary way users discover and return to moments
- **Research Validation:** Stoic App (3.2x re-engagement), Day One (40% increase with visual timeline)

### 2. **Tags & Headlines (Metadata for Pattern Recognition)**
- **What:** User-written headlines + optional suggested tags for organizational clarity
- **Design:**
  - Headline: 8-word user-generated retrieval cue (e.g., "God's peace in uncertainty")
  - Tags: 5 max per moment, user-controlled (e.g., Presence, Peace, Waiting)
  - Both optional—preserve user agency
- **Purpose:** Enable pattern discovery ("I notice 60% of my moments involve solitude") without interpretation
- **Research Validation:** Evernote users who organize return 2.1x more frequently; Bible app users who tag verses return 3x more

### 3. **Soak Mode (Contemplative Environment)**
- **What:** Optional 5/10/15-minute contemplative mode with ambient soundscape + moment text visible
- **Design:**
  - User selects moment
  - Chooses duration (5, 10, or 15 minutes)
  - Selects ambient soundscape (piano, rain, forest, silence)
  - Moment text displayed prominently
  - Soft timer (not intrusive)
- **Purpose:** Shift dwelling session from passive scroll (30 seconds) to active contemplation (5-15 minutes)
- **Research Validation:** Contemplative traditions emphasize sensory re-engagement; 7+ minute threshold activates spiritual presence

### 4. **Reflection Prompts (Socratic Questions)**
- **What:** Optional, gentle prompts that ask users Socratic questions about their moments
- **Design:** Two flows based on user choice:

#### **A. Prayer Flow**
- User selects moment
- System presents: "How can you pray about what you wrote here?"
- Structured but open prayer guidance (not prescriptive)
- User response saved as reflection attached to moment

#### **B. Prompts Flow**
- User selects moment
- System asks Socratic questions in three tiers:
  - **Tier 1 (Gentle):** "What stands out to you now?" / "How do you feel reading this today?"
  - **Tier 2 (Deeper):** "How did God meet you here?" / "What did you learn about yourself?"
  - **Tier 3 (Pattern-seeking):** "You've mentioned this theme five times—how is it evolving?" (only after 5+ related moments)
- User response saved as reflection

---

## Competitor Research & Skeletal References

### Prayer Lock (Prayer + Reflection App)
**Design Pattern:** Structured prayer flow with moment-based reflection  
**Key Insight:** Users pray *about* their moments rather than analyzing them. Prayer as response deepens personal agency.  
**Screenshot reference:** [User selects moment → prayer prompt appears → user writes prayer response → saved to moment]  
**Dwellable adoption:** Prayer Flow incorporates this pattern

### Untold (Faith Storytelling App)
**Design Pattern:** User narrative accumulation + visual timeline  
**Key Insight:** Seeing your story unfold visually (not just text list) creates emotional resonance and return frequency.  
**Screenshot reference:** [Timeline view showing moment cards with dates, themes, preview text]  
**Dwellable adoption:** Gallery View skeletal system based on this pattern

### Calm & Medito (Contemplative Apps)
**Design Pattern:** Ambient soundscape + guided presence experience  
**Key Insight:** Audio environment + visual simplicity + time threshold = deeper contemplation than text alone.  
**Screenshot reference:** [Fullscreen moment text + ambient sound selector + gentle timer]  
**Dwellable adoption:** Soak Mode skeletal system incorporates soundscape + time-awareness

### Day One & Stoic (Journaling + Reflection)
**Design Pattern:** Gallery view + tag/category organization + revisit nudges  
**Key Insight:** Visual + metadata + gentle reminders create habit-forming return cycle.  
**Screenshot reference:** [Tile grid of moments with headlines + category badges + notification prompt]  
**Dwellable adoption:** Gallery + Tags + Headlines features informed by this research

### Dwell (Christian Habit App)
**Design Pattern:** Scripture + reflection prompts on shared passages  
**Key Insight:** External + personal reflection combined, but Dwell uses external (Scripture); Dwellable inverts this (user's moment is the text).  
**Screenshot reference:** [Moment card + prompt suggestions + user-written response]  
**Dwellable adoption:** Prompts Flow design informed by this, but all text is user-generated, not external

---

## Intended Outcome

### Quantitative Target
- **Weekly Active Reflections (WAR):** 40-50% of users return to moments weekly by week 8
- **Gallery adoption:** 85%+ voluntary usage
- **Notification open rate:** 25-35% (gentle frequency, not all users need reminders)
- **Soak adoption:** 35-40% (contemplative diversity—not everyone wants audio)
- **Tags adoption:** 40-50% (metadata adds friction; reasonable adoption)

### Qualitative Target
- **User Experience:** "I find myself going back to my moments. They help me see patterns in how God shows up."
- **Foundation Alignment:**
  - "Dwellable respects my interpretation" (85%+)
  - "I discover insights myself in Dwellable" (60%+ of active users)
  - "I see my faith deepening through dwelling" (65%+ by week 8)
  - "Dwellable feels personal to my faith journey" (80%+)

### Spiritual Formation Impact
- Users build **active memory of God's faithfulness** (can point to specific moments)
- Users develop **increased attentiveness to the Spirit** (capture discipline becomes spiritual discipline)
- Users gain **resilience through pattern recognition** (when doubt comes, they return to moments of God's presence)
- Users experience **deeper integration of faith & life** (dwelling becomes a spiritual practice)

---

## Considered & Rejected

| Decision | Reasoning |
|----------|-----------|
| **AI-interpreted theme summaries ("Your moments show a pattern of trusting God")** | Violates "keeper not interpreter" principle. User must discover their own patterns. Rejected interpretation engine entirely; relying on user + Socratic prompts instead. |
| **Mandatory daily dwelling practice or streaks** | Contradicts grace-centered design ("no guilt"). Dwelling is invitation, not obligation. All features optional; no gamification. |
| **Auto-generated reflections or AI-written responses** | Users own their reflection. AI can prompt; users provide answers. Deferred AI response assistance to Post MVP. |
| **Social sharing of moments or responses** | Privacy-first brand. Moments stay private by default. Sharing deferred to Phase 2+; when added, will be explicit opt-in only. |
| **Scripture anchoring or biblical commentary in P0** | "Keeper not interpreter" principle. Users can link moments to Scripture themselves; Dwellable doesn't guide or suggest passages. Deferred to Phase 2+. |
| **Real-time moment notifications** | Risk of constant pinging. Dwelling invitation (2x weekly) is intentional, not reactive. No push-on-capture or real-time engagement loops. |

---

## Open Questions

| Question | Status | Next Step |
|----------|--------|-----------|
| **How can we surface themes from accumulated moments without interpretation?** | In Progress — P1 design | Design theme surfacing as "here's what you've been saying" (mirror) not "here's what it means" (interpretation) |
| **How often should we invite users to return without creating fatigue?** | Locked for P0 (2x weekly) | Validate through beta: test 1x, 2x, 3x weekly + opt-out rates; adjust based on engagement data |
| **Should soundscapes stream or be bundled locally?** | Locked for P0 (local bundle) | Validate storage footprint doesn't exceed device limits; test on iPhone SE baseline |
| **Should both Prayer + Prompts flows be available, or one primary?** | Locked for P0 (both optional) | Validate through user testing: do users find both options clarifying or confusing? |
| **Should user reflections be saved as separate Response objects or appended to moments?** | Locked for P0 (separate Response model) | Test sync performance with nested response threading; validate revision history UX |
| **How should Rich Context personalization work without revealing our interpretation?** | In Progress — needs validation | Test whether users perceive Rich Context-powered prompts as "understanding me" vs. "interpreting me"; validate theological safety |

### Top 5 Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| **User Discovery Failure** — Gallery/Soak exist but users don't find them | Return rate stays 0% | Progressive feature onboarding on first return; in-app explainers for Gallery + Soak; highlighted in home screen |
| **Notification Fatigue** — 2x weekly feels intrusive | Opt-out rate > 30% | Default OFF; fully customizable (1x, 2x, pause); sunset copy variants monthly based on engagement data |
| **Interpretation Drift** — Prompts or AI subtly interpret moments ("This shows your spiritual growth") | Violates core principle (keeper, not interpreter) | All prompts are questions, never statements; no AI interpretation in P0; user responses stored as-is without analysis |
| **Scope Creep** — Adding social/sharing/ranking during P0 | Brand drift; theological misalignment | Strictly enforce scope: P0 = solo dwelling only. Social deferred to P2. No moment ranking or comparison features. |
| **Retention Cliff** — Return rate peaks week 4, then drops | WAR < 40% by week 8, fails P0 gate | Reserve mid-P0 design review (week 4) to iterate copy, onboarding, notification timing based on early data |

---

## Blocking Dependency

**T-062 (End-to-End Encryption):** Must complete before Pillar 3 features ship to production.  
- **Why:** Users expect moments to be private. E2E encryption ensures no Dwellable servers, Supabase, or third parties can read moment content.
- **Impact:** P0 development can begin in parallel, but TestFlight/GA release blocked until T-062 complete.
- **Timeline:** T-062 = 16-24 hours; Pillar 3 = 4-6 weeks. E2E encryption is the bottleneck.

---

## What's NOT Included (Deferred to Phase 1+)

❌ AI-generated moment imagery  
❌ Semantic search or theme surfacing  
❌ Social features (sharing, ranking, comparison)  
❌ Scripture integration or biblical anchoring  
❌ Prescription spiritual direction  
❌ Forced practices (daily streaks, gamification)  
❌ External content (devotionals, verses, quotes)  

These are explicitly deferred and will only be considered if P0 (dwelling phase) succeeds via WAR metric.

---

## Implementation Tickets (Not Started)

- **T-063:** Prayer Flow — Moment selection → Prayer prompt → Response save
- **T-064:** Prompts Flow — Moment selection → Socratic prompt tiers → Response save
- **T-065:** Rich Context Integration — Use user's own language/themes to personalize prompts
- **T-066:** Response Persistence — Save reflections, view response history per moment

---

**Reference:** See `archive/docs/PHASE2_DISCOVERY_RESEARCH.md`, `archive/docs/P0_FEATURE_RESEARCH_FINDINGS.md`, and `archive/docs/T-060_Phase2_Themes_1Pager.md` for full research backing.

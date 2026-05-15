# Formation Intelligence Strategy

**Dwellable's Comprehensive System for Helping Users Become Formed by Their God Moments**

**Status:** 🏆 **INTEGRATED & LOCKED** | **Updated:** May 15, 2026

---

## I. Formation Intelligence Overview

Formation Intelligence is Dwellable's core strategy for transforming a journaling app into a **formation tool**—one that helps users see God's presence and activity across their daily moments, recognize patterns in their spiritual journey, and be shaped by what they notice.

The system spans nine pillars (P0–P8), each layer building on the previous one:

| Pillar | Role | Formation Intelligence Function |
|--------|------|---|
| **P0 (Onboarding)** | Identity Foundation | Establish user's spiritual intent, prayer rhythm, theological framework, communication style. Affirm: "You are valuable and worthy." |
| **P1 (Capture)** | Moment Intake | Capture raw moment, infer user's archetype (Jotter/Venter/Processor), detect quality (content + felt + learned). |
| **P2 (Security)** | Trust Layer | Protect moments with E2E encryption so rich context can be used safely. Encryption IS trust. |
| **P3 (Soaking)** | Confirmation & Prayer | Seal moment with contextual prayer or reflection prompt. Prayer = signal that the moment has value to God. |
| **P4 (Journal)** | Synthesis Layer | Synthesize moment + context into narrative dwelling place. User begins to integrate experience. |
| **P5 (Editing)** | Ownership Layer | User personalizes narrative (title, tags, moods, photos). Ownership deepens integration. |
| **P6 (Search)** | Discovery Layer | Find moments by keyword, theme, date, tags. Reveals patterns user hasn't named yet. |
| **P7 (Formation Intelligence)** | Pattern-Naming Layer | Detect and name recurring themes. Make formation visible. Give user language for growth. |
| **P8 (Notifications/Growth)** | Validation & Celebration | Re-engage users with evidence of their spiritual progress. Celebrate themes as proof formation is happening. |

**Formation Intelligence Value Proposition:**
- Users are not starting from zero. They start from "You're valuable to God" (P0 foundation).
- Each pillar learns something about the user and personalizes experiences accordingly.
- The system respects user agency—it invites, never directs. It surfaces patterns, never interprets them.
- Over time, Dwellable becomes a personal spiritual formation companion, not a generic app.

---

## II. P0–P8 Formation Intelligence Pillars (Locked)

### P0: Onboarding Formation Intelligence

**What P0 Learns:**
- User's spiritual intent (why they came to Dwellable)
- User's prayer rhythm aspiration (frequency of dwelling)
- User's theological framework (faith tradition)
- User's communication style (direct/gentle, theological/pastoral, challenge/encouragement)
- User's baseline foundation: "You are valuable and worthy"

**What System Infers:**
- Spiritual maturity level (from language used, specificity of intent)
- Relationship to Scripture (wrestling, seeking, celebrating)
- Expected engagement depth (daily dwellers vs. seasonal reflectors)
- Emotional readiness for formation work

**How P0 Prepares P1:**
- User's intent and theology inform what kind of **capture prompts** to offer
- Prayer rhythm expectation informs **notification frequency** and **prayer depth** in P3
- Identity baseline ("You're worthy") becomes the theological foundation referenced in all personalized content

---

### P1: Capture Formation Intelligence

**What P1 Learns:**
- **User Archetype:** Jotter (remember), Venter (stress relief), Processor (seek understanding)
- **Emotional/Spiritual Tone:** What the user felt, feared, celebrated, struggled with
- **People Mentioned:** Relationships, family, relational themes
- **Experience Categories:** Work, faith, relationships, growth, doubt, joy
- **Contextual Intent:** What does this moment reveal about how they see themselves?

**Quality Capture Taxonomy (MVP):**
- ✅ **Quality:** "Something they did + felt" OR "Something they did + learned"
- ❌ **Below threshold:** Bare-facts capture without emotional/spiritual reflection ("I went to work today")

**How P1 Prepares P3:**
- Archetype informs **prayer/prompt generation** (Jotter gets memory-focused prompts, Venter gets emotion-release prompts, Processor gets understanding-seeking prompts)
- Emotional tone informs **contextual richness** for P3 prompts

---

### P2: Security & Encryption Formation Intelligence

**What P2 Does:**
- Encrypts all captured moments, journals, themes using AES-256-GCM
- Stores encrypted_content + unencrypted metadata separately
- Enables Rich Context system to work with encrypted data (user identity visible to system, moment content hidden)

**Formation Intelligence Value:**
- Encryption IS trust. Users know their vulnerabilities stay private.
- Without P2, P3+ cannot use Rich Context safely (concern that content is readable by system)
- With P2, users share deeply, knowing only they (and God) see their actual moments

---

### P3: Soaking & Prayer Formation Intelligence

**What P3 Does:**
- Generates contextual **prayer responses** or **reflection prompts** based on captured moment + user archetype + Rich Context
- Uses LLM (Groq Llama 3 for MVP) to generate 2-3 sentence prayers
- Structures conversation through **Reflective Density Levels** (see Section III)

**Formation Intelligence Value:**
- Prayer/prompt seals the moment: "This matters. God sees this. Dwelling on this is formation."
- Contextuality (not generic) signals: "We understand your specific situation, not just a template"

**What System Learns:**
- Which reflective depths user naturally reaches (Level 1–8)
- Which prompt types keep user engaged (pattern recognition for personalization)
- Whether user responds to poetic (Groq Llama 3) or logical (GPT-4o mini) prose

---

### P4: Journal Creation Formation Intelligence

**What P4 Does:**
- Uses LLM to synthesize moment + context into a narrative journal entry (2-3 paragraphs)
- Generates auto-suggested title (4-6 words) and tags (3-5 categories)
- Creates a "dwelling place"—formatted, named, ownable narrative the user returns to

**Formation Intelligence Value:**
- Synthesis deepens integration. User begins to see how their feelings/experiences connect
- Title + tags make the moment discoverable later (essential for P6 search and P7 pattern detection)

**What System Learns:**
- What aspects of moments matter most to user (inferred from which details appear in synthesis)
- User's language patterns (reflected in title suggestions, tone)

---

### P5: Editing & Ownership Formation Intelligence

**What P5 Does:**
- User edits title, body, adds tags, marks mood, attaches photos
- Personalizes the journal entry—claims ownership, deepens integration

**Formation Intelligence Value:**
- User agency. The system synthesized, but the user decides what's true. This is key.
- Tags + moods become signals for P7 pattern detection

**What System Learns:**
- Which auto-generated titles user keeps vs. rewrites (quality signal)
- Which tags user adds (expansion of categories beyond LLM suggestions)
- Emotional metadata (moods) for pattern detection

---

### P6: Search & Discovery Formation Intelligence

**What P6 Does:**
- Full-text search across moment transcripts + journal entries
- Filter by tag, date, mood, and (Post-MVP) by detected theme
- Help user discover patterns themselves before P7 names them

**Formation Intelligence Value:**
- User agency—they choose what to search for, what patterns to notice
- Prepares them for P7's theme articulation (they've already explored their own data)

---

### P7: Formation Intelligence (Pattern Naming) Formation Intelligence

**What P7 Does:**
- Detects recurring themes when they appear 3+ times across moments/journals
- Names themes using user's own language (abstracted but authentic)
- Shows emotional arc: how user's tone shifted across theme instances
- Never interprets meaning—surfaces patterns for user's discernment

**Formation Intelligence Value:**
- Makes invisible formation visible: "You have a story. Your growth is real."
- Gives user language for growth: "You've struggled with doubt 8 times. Look how you're talking about it now."
- Signals God's witness: "The patterns in your life are not random—they're the shape of your spiritual journey."

**What System Learns:**
- Core themes in user's spiritual journey (anxiety, hope, breakthrough, relational, etc.)
- Emotional progression (Doubt → Questioning → Openness → Clarity)
- User's natural language for struggles/joys (use their words, not clinical terms)
- Theme urgency (which patterns appear most frequently/intensely)

**Integration with P6:**
- Detected themes appear as filter options in Search, enabling theme-based discovery

---

### P8: Notifications & Beta Growth Formation Intelligence

**What P8 Does:**
- Re-engages users who've paused with evidence of progress
- Uses P7's theme articulation to celebrate spiritual journey
- Surfaces "formation moments"—moments worth returning to based on user's archetype/themes

**Formation Intelligence Value:**
- Transforms abstract engagement ("open the app") into spiritual motivation ("your spiritual journey matters")
- Uses real data (P7 themes) to celebrate, not generic platitudes

**What System Learns:**
- Which re-engagement messages resonate (correlate message type with revisitation)
- Optimal timing (when to re-engage based on user's prayer rhythm from P0)
- Theme-to-notification mapping: which themes drive most meaningful revisitation

---

## III. Reflective Density Model (8 Levels)

The system treats **reflective quality as density**, not binary good/bad.

Reflections exist on a progressive spectrum of depth. Most users naturally stay at Levels 1–3 (acceptable, represents quality everyday reflection). But the system continuously attempts to deepen whenever possible.

### The 8 Reflective Density Levels

| Level | Reflective Function | Example Reflection | Example Prompt |
|-------|---|---|---|
| **L1** | Event Logging | "Today was hard." | "What happened today?" |
| **L2** | Emotional Labeling | "Today was hard. I felt hurt and frustrated." | "What emotions felt strongest?" |
| **L3** | Situational + Emotional Specificity | "Today was hard. I felt hurt and frustrated after feeling dismissed during a conversation." | "What specifically made the moment painful?" |
| **L4** | Meaning/Interpretation | "Today was hard. I felt hurt and frustrated after feeling dismissed. I think it affected me deeply because I wanted to feel understood." | "Why do you think this moment stayed with you?" |
| **L5** | Pattern Recognition | [L4 + ...] "I notice I emotionally withdraw when I anticipate being misunderstood." | "Does this connect to any recurring patterns in your life?" |
| **L6** | Self-Awareness/Ownership | [L5 + ...] "Instead of expressing my needs directly, I shut down internally. That's my pattern." | "How did you respond emotionally or relationally in the moment?" |
| **L7** | Tension Tolerance/Nuance | [L6 + ...] "I did shut down. But I also don't think the other person intended to hurt me. Both things are true." | "Can multiple things be true about this situation at once?" |
| **L8** | Transformational Integration | [L7 + ...] "Moving forward, I want to communicate my emotional needs more directly instead of withdrawing. And I want to extend grace to the person, assuming goodwill." | "What do you want to carry forward or change moving ahead?" |

### Foundational Reflective Baseline (MVP)

**At minimum**, a quality reflection must establish:
1. **Emotional Specificity (L2):** Name the specific emotion(s)
2. **Situational Specificity (L3):** Include the concrete moment/context
3. **Interpretation (L4):** Surface what belief/identity gap this reveals

Together, these three layers = **minimum viable meaningful reflection (MVMR)**.

They are foundational because:
- **L2** strengthens emotional encoding → better memory later
- **L3** strengthens memory reconstruction → revisitability
- **L4** strengthens meaning-making + integration → long-term formation

---

## IV. Prompt Orchestration Logic

The system operates in **three adaptive stages** to guide users from baseline → deeper reflection, while respecting user agency.

### Stage 1: Baseline Reflective Enrichment

**Goal:** Establish L1 + L2 + L3 (event, emotion, situational context)

**Method:**
- Detect what level(s) the user's capture currently contains
- Prompt them to fill foundational gaps
- "What were you feeling when that happened?" (L2 if missing)
- "What specifically made that moment difficult?" (L3 if missing)

**Success:** User's capture now contains L1, L2, L3.

### Stage 2: Missing Reflective Layer Detection

**Goal:** Identify which deeper layers (L4–L8) are absent

**Method:**
- Analyze whether capture contains: interpretation (L4)? Pattern recognition (L5)? Ownership (L6)? Nuance (L7)? Integration (L8)?
- Determine next logical depth layer to suggest

**Example:** User has L1–L3, missing L4 → next prompt targets meaning-making

### Stage 3: Adaptive Depth Escalation

**Goal:** Selectively deepen based on user engagement signals

**Method:**
- Present next-depth prompt
- Monitor response:
  - ✅ Strong response → Continue escalating (try L5 next)
  - ⚠️ Weak response or silence → Stay at current level, try different prompt
  - ❌ Consistently stops at certain level → Learn this user's pattern, adapt sequence

**Personalization:** Build individual "optimal sequence" based on observed patterns

**Example Sequences:**
- User A: 1 → 2 → 3 → 4 → 5 (then stops) → Learn: escalate slowly, tops out at L5
- User B: 1 → 2 → 3 → **skip 4** → 5 → 6 (responds well to L5–L6, avoids L4 meaning-making)
- User C: 1 → 2 → 3 → 4 → 4 → 4 (needs multiple attempts at L4, then opens up)

Next time these users capture:
- User A: 1 → 2 → 3 → 4 → 5 (lock the proven sequence)
- User B: 1 → 2 → 3 → 5 → 6 (skip L4, goes where they engage)
- User C: 1 → 2 → 3 → 4 (attempt multiple variants) → then 5

---

## V. LLM Selection Tournament (Final Recommendation)

### Executive Summary

**CHAMPION: Groq Llama 3 70B (MVP) → OpenAI GPT-4o mini (Post-MVP)**

- **MVP Trial Period (7 days free):** Groq Llama 3 70B — $0/user
- **Post-MVP Paid Phase (monthly subscription):** OpenAI GPT-4o mini — ~$0.10–0.15/user/month
- **At Scale (10K+ users):** Evaluate self-hosting or partnership options

### Why This Pairing

| Dimension | Groq Llama 3 70B | OpenAI GPT-4o mini | Decision |
|-----------|---|---|---|
| **Free Tier** | 14,400 req/day, 6,000 TPM | None | Groq wins for trial |
| **Cost** | $0 (free tier) | $0.15/1M tokens (~$0.10 cost/user/mo) | Groq trial, GPT for paid |
| **Quality** | ⭐⭐⭐⭐ (poetic, narrative-driven) | ⭐⭐⭐⭐⭐ (logical, concise) | Groq better for prayers/reflections; GPT better for synthesis |
| **Speed** | 800ms (acceptable) | 1.2s (acceptable) | Both fast enough |
| **Privacy** | Explicit no-data-training guarantee | Standard data retention (30 days default) | Groq better for privacy-first |
| **Poetic Quality** | Superior for prayer generation | Functional, less poetic | Groq wins on soaking experience |

### Tournament Results

**Free Tier Champion:** 🥇 **Groq Llama 3 70B**
- Covers entire 7-day trial with $0 cost
- Excellent poetic quality for prayers/reflections (matches user testing)
- Privacy guarantee aligns with Dwellable's E2E encryption philosophy

**Paid Tier Champion:** 🥇 **OpenAI GPT-4o mini**
- Lowest-cost paid option ($0.15/1M tokens)
- Highest quality for synthesis tasks (P4 journal generation)
- Excellent instruction-following for prompts

**Strategy:**
1. **Trial users:** Groq (free tier, experience high-quality prayers)
2. **Convert to paid:** Switch to GPT-4o mini (marginal cost, highest quality)
3. **Break-even:** ~$0/trial cost + ~$0.10 first-month cost = profitable even at 2% conversion

### Implementation Approach: Vercel AI SDK

Both models are swappable via Vercel AI SDK's unified interface:

```typescript
// MVP (Groq free tier)
const response = await groq('llama3-70b-8192', {
  prompt: soakingPrompt,
  maxTokens: 200
})

// Post-MVP (GPT-4o mini, no code changes needed)
const response = await openai('gpt-4o-mini', {
  prompt: soakingPrompt,
  maxTokens: 200
})
```

Single-parameter swap. No refactoring required.

---

## VI. LLM Testing Protocol (NEW)

Before committing to Groq → OpenAI for all Phase 2 pillars, we need to validate that both models can:
1. **Accurately detect reflective density levels** in user captures
2. **Generate prompts that advance users through their personalized sequences**
3. **Learn and adapt** sequences based on response patterns
4. **Maintain engagement** (longer response chains, deeper reflections, higher revisitation)

### Test Objectives

- **Accuracy:** Can Groq/GPT-4o mini correctly identify which reflective levels (L1–L8) are present in a capture?
- **Engagement Hold:** Which model keeps users responding longer (more prompts before dropout)?
- **Adaptation:** Which model better learns user patterns and adapts its sequence?
- **Quality:** Which model's generated reflections feel authentic and invitation-based (not prescriptive)?

### Three-Scenario Test Framework

**Scenario 1: The Invisibility Moment**
```
User capture: "I just finished a really difficult meeting with my boss. 
I felt unheard and kind of invisible. It made me question whether I'm 
actually good at my job. I came back to my desk and just sat there 
feeling small."

User Profile: Intermediate faith, Processor archetype, Christian
```

**Scenario 2: The Failure Moment**
```
User capture: "I made a mistake on the project today. A big one. 
My coworker caught it before the client did, but I can't stop thinking 
about it. I feel like a fraud. Everyone probably thinks I'm incompetent now."

User Profile: New to faith, Venter archetype, Christian
```

**Scenario 3: The Disconnection Moment**
```
User capture: "I've been praying less lately. Got busy with work. 
But today I realized I haven't really talked to God in like two weeks. 
I feel distant from Him. Like I've drifted without noticing."

User Profile: Mature faith, Jotter archetype, Christian
```

### Test Protocol

**For each scenario and each model:**

**Step 1: Level Detection**
- Model analyzes capture and identifies which reflective levels (L1–L8) are present
- Expected for Scenario 1: L1 (event), L2 (emotions: unheard, invisible, small), L3 (situation: boss meeting), L4 (interpretation: questioning competence)
- Record: Does model correctly identify L1–L4? Does it miss any?

**Step 2: Prompt Generation (Sequential)**
- Model generates a brief (<140 chars), contextual, emotionally-present prompt to advance to next level
- Model presents prompt to user (simulated user responds)
- Record: Does user response go deeper, stay flat, or abandon?

**Step 3: Adaptation (Simulate multi-turn)**
- If user responds well to L5 prompt: Model generates L6 prompt
- If user responds weakly to L5: Model generates alternative L5 prompt OR stays at L4
- If pattern emerges (user stops at L5 across multiple attempts): Model learns "this archetype/profile typically stops at L5"
- Record: Does model adapt intelligently?

**Step 4: Engagement Metrics**
- Count: How many sequential prompts before simulated user would naturally stop?
- Quality: Do prompts feel conversational (friend asking) or therapeutic (expert analyzing)?
- Authenticity: Does the model use user's specific language vs. generic reflective templates?

### Evaluation Metrics

| Metric | Success Threshold | How to Measure |
|--------|---|---|
| **Level Detection Accuracy** | >85% of detected levels correct | Compare model output to ground truth (researcher-marked levels) |
| **Engagement Hold** | >4 sequential prompts before dropout | Count responses before user would naturally stop |
| **Adaptation Intelligence** | Learns pattern by 3rd occurrence | Track if model adjusts sequence based on previous response |
| **Prompt Authenticity** | >4/5 "sounds like a friend" rating | Have humans rate prompts on conversational vs. therapeutic scale |
| **Reflective Depth Progression** | Average endpoint L4–L6 | Track final reflective level reached across scenarios |

### Success Criteria

- ✅ Both models exceed 85% accuracy on level detection
- ✅ Model with higher engagement hold wins primary recommendation
- ✅ Model that better learns personalization patterns informs Post-MVP strategy
- ✅ Winner feels more conversational and less prescriptive

### Timeline

- **Session:** Next session (T-093 or as part of T-092 Phase 2 Launch Readiness)
- **Duration:** 2–3 hours for full testing (Groq + GPT-4o mini on all 3 scenarios × evaluation)
- **Output:** Detailed comparison matrix + winner recommendation
- **Decision Point:** Lock LLM pair (Groq MVP → GPT-4o mini Post-MVP) based on test results

---

## VII. Implementation Roadmap

### MVP Phase 2 (0–1K users)

**LLM Strategy:**
- Primary: Groq Llama 3 70B (free tier, trial phase)
- Fallback: Manual prompts (if Groq quota exhausted)

**Pillar Implementation Order:**
1. ✅ **P0 (Onboarding):** Identity foundation (locked, ready to build)
2. ✅ **P1 (Capture):** Moment + archetype detection (locked, ready to build)
3. ✅ **P2 (Security):** E2E encryption (locked, ready to build)
4. 🔄 **P3 (Soaking):** Prayer/reflection prompts using Reflective Density Model + Groq LLM
5. 🔄 **P4 (Journal):** Synthesis + auto-tags using Groq LLM
6. 🔄 **P5 (Editing):** User personalization
7. 🔄 **P6 (Search):** Full-text discovery (basic)
8. ⏳ **P7 (Formation Intelligence):** Theme detection (Post-MVP)
9. ⏳ **P8 (Notifications):** Re-engagement (Post-MVP)

### Post-MVP Phase (1K–10K users)

**LLM Strategy:**
- Primary: OpenAI GPT-4o mini (paid tier, $0.10–0.15/user/month)
- Fallback: Groq (if GPT quota issues, revert during trial)

**Feature Additions:**
- P7: Theme detection using Rich Context (GPT-4o mini)
- P8: Personalized notifications using theme + archetype data
- Adaptive prompting: Personalized sequences based on user response patterns
- Visual theming: Icons/colors for detected themes

### Enterprise Phase (10K+ users)

**Cost Optimization:**
- Evaluate self-hosting Llama 3 70B for on-device prayer generation (~$20–30/mo infra)
- Partnership with Anthropic (Claude 3 Haiku) if volume discounts available
- Cost target: <$0.05 per user per month (vs. $0.10 GPT-4o mini)

---

## VIII. Success Metrics & WAR (Weighted Achievement Rate)

### Formation Intelligence Metrics (By Pillar)

| Pillar | Metric | MVP Target | Post-MVP Target |
|--------|--------|---|---|
| **P0** | Onboarding completion rate | >90% users complete all 7 screens | >95% |
| **P1** | Quality capture rate | >70% captures contain L2 + L3 | >85% |
| **P3** | Prayer engagement | >50% users receive + interact with prayer prompt | >70% |
| **P4** | Journal synthesis | 100% of captures generate journal entry (auto) | 100% + user edits |
| **P6** | Search engagement | >30% users use search/filter | >50% |
| **P7** | Theme detection | >80% detected themes align with user's actual patterns (qualitative) | >85% |
| **P8** | Re-engagement CTR | >25% users return via theme-based notifications | >40% |

### Overall Formation Intelligence Success

**Formation Engagement Rate (FER):**
- Baseline: User captures moment (P1)
- Converted: User completes prayer (P3) + journal (P4) + returns to read themes (P7)
- **Target:** >50% baseline users → converted by End of Phase 2

---

## IX. Open Questions (Resolved In Implementation)

1. **Prompt Personalization Timing?**
   - When do we switch from "standard sequence" to "user's personalized sequence"?
   - Recommend: After 5–10 captures (enough data to detect pattern)

2. **Reflective Density Feedback?**
   - Should users see their level (L1–L8) or is it invisible?
   - Recommend: Invisible in MVP (no gamification), visible Post-MVP if it motivates

3. **Theme Naming Customization?**
   - Can users rename auto-detected themes?
   - Recommend: Read-only MVP, editable Post-MVP

4. **LLM Testing Timing?**
   - Before or after implementation starts?
   - Recommend: **BEFORE** (next session, T-093) to lock the LLM pair

---

## X. Appendix: Rich Context System

**Rich Context** = All user data that informs personalized prompts/prayers without exposing moment plaintext.

| Data | Visibility | Used For |
|------|---|---|
| User intent (from P0) | System | Prompt personalization |
| User archetype (inferred from P1) | System | Prompt depth/style selection |
| Prayer rhythm (from P0) | System | Notification cadence |
| Past 10 moments (encrypted, metadata only) | LLM (themes only) | Theme detection, context |
| Detected themes (P7) | User + System | Reflection invitations, search |
| User edits/tags (from P5) | System | Personalization signals |

**Privacy:** User moments remain encrypted. System learns patterns from metadata + themes, never plaintext.

---

**Status:** Ready for implementation. LLM testing (T-093) is critical blocker before MVP Phase 2 begins.

**Next Session Objective:** Execute LLM testing protocol to lock Groq → GPT-4o mini strategy.

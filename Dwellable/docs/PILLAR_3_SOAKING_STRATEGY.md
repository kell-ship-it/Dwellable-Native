# Pillar 3: Soaking (Guided Prayer) — Strategy & Design Skeleton

**Status:** 🔄 **Phase 2 Beta** (Design In Progress)  
**Last Updated:** May 10, 2026

---

## Design Summary

Pillar 3 is where users **seal their moments through guided prayer**. After capturing a moment (P1), users are invited to pray over it with an AI-generated, contextually-rich prayer that reflects back what they shared.

Prayer is not prescriptive. It's a **confirmation signal** — when users pray with us, they're affirming: *"Yes, you understand me."*

**MVP Scope:** Guided prayer only (AI-created, contextual to conversation)  
**V2 Scope:** Open-ended prayer option (user writes their own)

---

## Formation Intelligence — What Pillar 3 Is & Learns

### What Pillar 3 Is (in the Formation Intelligence System)

**P3 is the sealing layer — it transforms captured moments into spiritual artifacts.**

| Pillar | Role |
|--------|------|
| **P0 (Onboarding)** | Establishes foundation (intent, theology, support style) |
| **P1 (Capture)** | Captures moment + context (archetype, emotional tone, intent) |
| **P2 (Security)** | Protects the data (enables trust) |
| **P3 (Soaking/Prayer)** | **Seals the moment spiritually** (affirms understanding, deepens engagement) |
| **P4+ (Journal, Themes)** | Uses sealing signal to synthesize and pattern |

### What Pillar 3 Learns

**P3 learns through the act of praying.**

When a user prays with us, they signal: *"Yes, you understand me."* This is a **soft yes** — alignment confirmation.

**P3 learns:**
- **Which moments they choose to pray over** (what matters most spiritually)
- **Whether we understood correctly** (did they engage with the prayer? did it resonate?)
- **Their spiritual engagement pattern** (do they pray over all moments? some? struggles only?)
- **What themes recur in prayer** (what keeps coming back to their heart)
- **Their prayer-to-moment ratio** (indicator of spiritual depth-seeking)

Over time: **Formation patterns emerge** — what they're growing in, what they're wrestling with, where God is meeting them.

### What Pillar 3 Communicates to the User

#### "We heard you. We understand what you're feeling."

The guided prayer is proof:
- Includes their **name** (personalization)
- References **specific feelings** they expressed (acknowledgment)
- Names **specific people** they mentioned — and their role (witness)
- Articulates the **intended outcome** they're yearning for (hope)

**Not generic. Theirs.**

#### "Your feelings matter. Your experience is sacred."

Prayer structure **honors complexity:**
- Acknowledges the hard feelings: *"I feel unworthy"* ✓ (we see it)
- Doesn't dismiss it: ✓ (we don't minimize)
- Counteracts with God's truth: *"But God, you call me worthy"* ✓ (we point to hope)

Never: *"Thank you for making me worthy"* ❌ (that affirms the lie)

#### "This moment is sealed. I won't forget it."

**Prayer = spiritual seal:**
- Before prayer: relief (they were heard)
- After prayer: very heard + secure (moment is sealed)
- Prayer artifact in journal: proof this moment was brought before God

**Trust signal:** "We care about this moment as much as you do."

### How Pillar 3 Prepares Pillar 4 (Journal Creation)

#### The Flywheel

1. **P1 Capture:** User captures moment + context
2. **P3 Prayer:** User prays over it → generates "Prayed" signal
3. **P4 Journal:**
   - Creates journal automatically (always)
   - If "Prayed" signal present → embeds prayer artifact
   - Journal entry carries spiritual weight: *"I didn't just capture this. I prayed over this."*
   - Journal synthesis uses prayer's themes (what we surfaced, what they affirmed)

#### Data Handoff

P3 gives P4:
- **Prayer content** (what we highlighted, what God's truth we offered)
- **Confirmation signal** (they prayed → they're going deeper)
- **Spiritual tone** (the prayer's language, their engagement level)

P4 uses it:
- Synthesizes journal with prayer's themes
- Creates narrative: *"Here's what happened AND here's what I brought to God"*
- Embeds prayer artifact as digital signal of spiritual engagement

#### The Depth Spiral

- Every moment → every prayer → every journal
- Deeper context → better prayer → richer journal
- Better prayer → more trust → deeper next capture
- **Depth creates breadth; breadth enables more depth**

---

## User Experience (MVP)

### Happy Path

1. **User completes conversation** (P1 Capture)
2. **Sees CTA:** "Want to pray over this?"
3. **Taps → Guided prayer screen** (AI-generated, contextual)
4. **Reads prayer silently or aloud** (user prays with it)
5. **Confirmation signal:** "Prayed" appears
6. **Transition** to next experience (likely journal preview or moments list)
7. **Prayer artifact embedded** in journal creation (automatic, signals spiritual engagement)

### What User Is Experiencing

- **Heard** (conversation was understood)
- **Very heard** (prayer proves it)
- **Secure** (moment won't be forgotten; it's sealed spiritually)
- **Invited deeper** (prayer deepens engagement, not closes it)

---

## Guided Prayer Specification (MVP)

### What Prayer Must Include

- **User's name** (personalization, not generic)
- **Specific feelings** they expressed (acknowledgment)
- **Specific people** they mentioned (+ their role: boss, friend, parent, etc.)
- **Intended outcome** they're yearning for (what they hope for)

### Counteracting Negative Beliefs

**Structure: Acknowledge + Counteract**

❌ **Wrong:**  
*"Thank you for making me worthy"* (affirms the lie that they were unworthy)

✅ **Right:**  
*"Although I feel unworthy, God you call me worthy"* (honors the feeling, points to truth)

### What Prayer Should Avoid

- ❌ Identifying user as bad person
- ❌ Negative reinforcement of characteristics
- ❌ Dismissing difficult feelings
- ❌ Prescriptive advice ("You should...")
- ❌ Generic spiritual platitudes

### Prayer Language Principles

- **Specific, not generic** — reference their actual story
- **Contemplative, not instructional** — invite prayer, don't teach
- **Honest about struggle** — don't bypass the hard feelings
- **Hope-oriented** — always point to God's perspective
- **Client-appropriate** — match their theological language (if they said "Lord," use that; if "God," use that)

---

## Technical Architecture

### Prayer Generation

**Input data (from P0–P2):**
- User's name (from P0 Onboarding)
- Theological framework (if shared in P0)
- Support style preference (from P0)
- Conversation transcript (from P1 Capture)
- Encrypted context (from P2 Security layer)

**LLM task:**
1. Extract feelings, people, intended outcomes from transcript
2. Identify spiritual themes (doubt, joy, relationship, breakthrough, etc.)
3. Generate contextual prayer using template + rich context
4. Ensure prayer counteracts negative beliefs with God's perspective
5. Match user's theological language/style

**Output:**
- Guided prayer text (300–400 words, contemplative tone)
- "Prayed" signal (boolean flag for P4 embedding)

### Prayer Artifact Storage

**Encrypted in Supabase:**
```swift
struct PrayerArtifact: Codable {
    let id: String                      // UUID
    let momentId: String                // Reference to P1 capture
    let userId: String                  // User ID
    let prayerText: String              // LLM-generated prayer
    let encryptedContent: Data          // AES-256-GCM encrypted
    let createdAt: Date                 // ISO timestamp
    let userEngaged: Bool               // Did user read/pray with it?
}
```

**Embedded in Journal:**
- Prayer artifact linked to journal entry
- Visual indicator: "🙏 You prayed over this"
- User can view prayer again when reading journal

---

## Formation Intelligence Learning

### What Formation Happens Here

**P3 operates at the root level:**

Formation is about going to the root of challenging experiences and replacing them with healthy spiritual perspective.

**P3's role:**
- User captures root-level experience (P1)
- P3 prayer brings it to God, surfaces what's underneath
- Next moment, we know them deeper (more context for P3 next time)
- Over time: **Depth spiral** → formation accelerates

### Every Moment Matters

- Not one powerful prayer that changes everything
- But **every moment treated with equal spiritual significance**
- More specific context → more appropriate prayer → more trust
- Over 100 moments: depth creates visible formation trajectory

---

## Success Metrics (MVP)

### Formation Intelligence Perspective
- ✅ User feels understood through prayer content
- ✅ Prayer language resonates (feels authentic to user's theology)
- ✅ "Prayed" signal creates sense of spiritual sealing
- ✅ Prayer artifact in journal reinforces spiritual significance of moment
- ✅ Users return to moments more because they're spiritually sealed

### Technical Perspective
- ✅ Prayer generation latency <3s
- ✅ Prayer content contextual (references specific names, feelings, outcomes)
- ✅ Prayer avoids negative reinforcement patterns
- ✅ Prayer artifact successfully embedded in journal creation
- ✅ "Prayed" signal reliably transitions to next experience

---

## Open Questions for MVP

1. **How do we handle difficult emotions in P3?**
   - User captures: "I feel suicidal" or trauma material
   - What's our pastoral responsibility in prayer?
   - Do we refer? Do we normalize? How do we not harm?
   - **Not a blocker; flag for careful MVP design**

2. **What else can we do post-prayer to deepen the experience?**
   - Are there other modular experiences we can offer after prayer?
   - What else can be inferred from their capture + prayer to create deeper spiritual engagement?
   - Examples to explore: Scripture connection? Meditation invitation? Prompt for journaling? Invitation to review similar past moments?
   - Can this be modular — let users opt-in to different post-prayer experiences?
   - **Not a blocker for MVP; exploratory for future versions**

---

## Backlog for V2

1. **Open-ended prayer option** — user writes their own prayer instead of guided
2. **Multiple prayers on same moment** — user can pray again, see prayer progression
3. **Prayer variations** — different prayer styles/traditions for diverse users
4. **Scripture connection** — surface relevant Scripture during/after prayer
5. **Meditation/stillness option** — guided meditation paired with prayer

---

## Next: How P3 Prepares P4

Once P3 is locked, P4 (Journal Creation) can be articulated as:
- **What P4 is:** LLM-powered synthesis that weaves moment + prayer into narrative
- **What P4 learns:** How users integrate their experience with spiritual reflection
- **How P4 prepares P5+:** By capturing the full arc (moment → prayer → journal), P4 creates rich formation data

---

**Ready to lock P3 and move to P4?**

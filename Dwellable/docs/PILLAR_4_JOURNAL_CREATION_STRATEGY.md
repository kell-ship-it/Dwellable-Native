# Pillar 4: Journal Creation (Synthesis & Dwelling) — Strategy & Design Skeleton

**Status:** ✅ **COMPLETE** (Phase 2 Beta)  
**Last Updated:** May 10, 2026

---

## Design Summary

Pillar 4 is the **synthesis layer** of Dwellable's Formation Intelligence system. It transforms captured moments into meaningful journal entries via LLM synthesis, enabling users to:

1. **See their spiritual story emerge** — raw conversation becomes a dwelling place
2. **Own their narrative** — they can edit, customize, and refine their journals
3. **Understand formation patterns** — journals become the data foundation for future pillars

The flow: Capture → Confirmation (with prayer CTA) → Guided Prayer → Journal Synthesis (background) → Dwelling Place Tab → Editing & Customization.

---

## Formation Intelligence — What Pillar 4 Is & Learns

### What Pillar 4 Is (in the Formation Intelligence System)

**Not just a feature. A narrative layer.**

| Pillar | Role |
|--------|------|
| **P0 (Onboarding)** | Establishes foundation: *"You are valuable and worthy"* + spiritual context |
| **P1 (Capture)** | Captures raw moment + infers archetype (Jotter, Venter, Processor) |
| **P2 (Security)** | Protects moments so P3+ can use rich context confidently |
| **P3 (Soaking)** | Seals the moment with prayer — user confirms value + connection to God |
| **P4 (Journal Creation)** | *Synthesizes* the moment into a dwelling place. **Narrative proof** that formation is happening. |

### What P4 Learns About the User

P4 doesn't just store data—it learns *how the user sees themselves*:

1. **Narrative Style:** How does the user emphasize their moment? (Detail-focused? Emotional? Action-oriented? Spiritual-seeking?)
2. **What's Journal-Worthy:** What kinds of moments do they choose to dwell on? What gets edited vs left alone?
3. **Story Arc:** Over time, P4 sees patterns in their spiritual narrative. Are they moving toward maturity? Wrestling? Resting? Growing?
4. **Customization Patterns:** Which moods do they choose? Do they add photos? Do they edit heavily? (Signals ownership + depth)
5. **Signal Capture (MVP Infrastructure):** Capture metadata about edits (mood changes post-capture, content deletions, edit timestamps), but defer inference to Post-MVP. Build the infrastructure now to track these signals; decide later (P7/P8) what to do with them.

### What P4 Communicates to the User

**More important than learning is the signal P4 sends:**

1. **"Your moments become stories."**
   - Not generic notes. Not data to be analyzed. Sacred moments reframed as dwelling places.
   - The journal is where the user meets themselves and God together.

2. **"You own your narrative."**
   - The app generates a starting point. You decide if it's true and beautiful.
   - Editing + customization = claiming ownership over your spiritual story.

3. **"Formation is happening."**
   - Journals are proof that growth, reflection, and transformation are real.
   - Over time, the accumulation of journals shows the user's spiritual arc.

4. **"You are worth dwelling on."**
   - The fact that the app dedicates a special "Dwelling Place" for your moments signals: your spiritual life is sacred.
   - This is not productivity. This is formation.

5. **"Your feelings from the moment are reflected here."**
   - The journal preserves the emotional and spiritual state from when you captured the moment.
   - Emotional continuity between capture → prayer → journal affirms that your experience was heard and held.

### How P4 Prepares P5 (Editing)

**P5 cannot exist meaningfully without P4's foundation.**

Example (P5 future behavior):
- User sees "Edit Journal" option — because P4 gave them something worth editing
- User customizes title, mood, adds photos — because P4 signals: "Your narrative matters enough to refine"
- User can also start from scratch — because P4 respects their autonomy over their narrative
- User keeps journal for years — because P4 made it beautiful and personal

**P4 removes the blank-page problem while respecting user ownership:** By synthesizing the moment into a journal, P4 provides a high-quality starting point that the user can refine (edit, customize, approve) or replace entirely (start from scratch). This balances guidance with autonomy.

---

## Core Design Decisions — Locked

### Happy Path (6 Steps)

1. **Capture Complete** — User finishes conversational moment capture (Pillar 1), taps "Done"
2. **Confirmation Screen** — App shows: *"Captured your moment! We briefly talked about [x, y, z], would you like to pray over these things?"* (Shows app listened; invites prayer via CTA)
3. **Guided Prayer (v1)** — User enters Pillar 3 flow; guided prayer focused on captured moment. Prayer attaches to journal.
4. **Journal Synthesis (Background)** — LLM generates title (4-6 words) + body (2-3 paragraph narrative) + suggested moods while user prays
5. **Dwelling Place Tab** — User sees synthesized journal in "Dwelling Place" tab; can view original conversation in "Entry" tab
6. **Editing & Customization** — User can select/modify moods, add photos (camera or library), edit journal text. Delete capability included.

### Synthesis Specification

**LLM Output (from conversation transcript):**
- **Title:** Auto-generated headline, 4-6 words. Contemplative, personal, affirming. Becomes the title for BOTH Entry (conversation) and Dwelling Place (journal), creating a unified narrative arc.
- **Body:** 2-3 paragraph narrative prose (not structured sections). Mirrors user's language but reframes as spiritual reflection.
- **Moods/Tags:** 2-3 auto-generated tags from predefined palette (emotional + spiritual moods). User can override. Signals to user what emotions/spiritual states the AI detected from their conversation.

**Tone:** Contemplative, personal, affirming. Acknowledges user's experience and points toward formation/growth.

**Powered by:** Rich Context (uses P0 identity, P1 archetype, theology, support style to make synthesis personal)

**Relational Formation Intelligence Signal:** The AI-generated title, moods, and prayer reference create a complete view of the user's moment. The system says: "Here's what you shared (Entry) → here's how we're reflecting on it (title + moods + prayer) → here's where you dwell on it (journal). Your whole spiritual experience is held."

### Journal Artifact Structure

```swift
struct Journal: Codable {
    let id: String                      // UUID
    let userId: String                  // User ID (authenticated)
    let dateCreated: Date               // When journal was synthesized
    let title: String                   // Auto-generated (4-6 words)
    let body: String                    // LLM synthesis (2-3 paragraphs)
    let moods: [String]                 // Tags selected by user (2-3 from palette)
    let photos: [String]?               // Photo IDs (optional, added post-synthesis)
    let prayerReference: String?        // Link to attached prayer artifact (Pillar 3)
    let originalMomentId: String        // Link back to Pillar 1 conversation
    let encryptedContent: Data          // AES-256-GCM encrypted
    let encryptedMetadata: Data?        // Moods, mood metadata (encrypted)
    let edited: Bool                    // Tracks if user modified post-synthesis
    let deleted: Bool                   // Soft delete flag
    let createdAt: Date                 // ISO8601
    let updatedAt: Date                 // ISO8601
}
```

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Two-Tab Architecture (Entry + Dwelling Place)** | Preserves original conversation while providing synthesized reflection space. Both tabs share the AI-generated title, creating a unified narrative that shows the user their moment has been heard and reframed as a dwelling place. |
| **Confirmation Screen Before Prayer** | Shows app understood the moment ("talked about X, Y, Z"), invites contemplative response. Natural transition: capture → prayer → journal. |
| **Moods/Tags Unified** | Single predefined palette (emotional + spiritual moods). For spiritual journaling, emotional state IS spiritual mood. Reduces mental overhead. |
| **LLM Synthesis Over Manual Entry** | Conversation is already deeply reflective; synthesis reframes as journal. Removes blank-page anxiety. User can edit post-synthesis. |
| **Post-Synthesis Photo Upload (v1)** | User can add/remove photos after journal created. Not all moments are visual; this allows flexibility. |
| **Journal Editability (Detail View Only)** | Users edit in detail view (not on list cards). Can modify moods, add photos, edit text. Encourages ownership. |
| **Soft Delete + 30-Day Recovery** | Encourages fresh captures (new journals) over endless edits to old entries. User can recover within 30 days. |
| **Linking to Pillar 1** | Journal stores `original_moment_id`. User can navigate between Entry (conversation) and Dwelling Place (synthesis). |
| **AES-256-GCM Encryption** | Same as Pillar 2. Conversation + journal encrypted at rest and in transit. Client-side encryption only. |

---

## Technical Architecture

### Journal Creation Pipeline

```
Capture complete (P1)
    ↓
Confirmation screen shown (shows theme extraction from transcript)
    ↓
User taps "Pray About This"
    ↓
Routes to Pillar 3 (Guided Prayer)
    ↓
While user prays: LLM synthesis runs in background
    ↓
Synthesis completes: Title + Body + Suggested Moods generated
    ↓
Prayer completes: User returns from P3
    ↓
Dwelling Place tab shows synthesized journal
    ↓
User can: customize moods, add photos, edit text, delete journal
    ↓
Journal encrypted + synced to Supabase (T-062)
```

### Key Components

**JournalSynthesisManager**
- Receives conversation transcript + Rich Context (user identity, archetype, themes)
- Calls LLM (Gemini 2.0 Flash MVP) to generate title + body
- Returns structured output (title, body, suggested moods)
- Handles timeout/error cases (fallback to Entry-only view)

**JournalStorageManager**
- Saves draft journal locally (unencrypted, for offline capability)
- Encrypts before syncing to Supabase (same encryption as P2)
- Handles soft delete + 30-day recovery window
- Manages mood palette + photo relationships

**EncryptionManager** (Shared with P2)
- Derives key from user password (Argon2id)
- Encrypts journal body + metadata before cloud sync
- Decrypts on read (transparent to UI)

---

## Data Model & Encryption Impact

**Encrypted Fields:**
- `body` (full journal text)
- `encryptedMetadata` (moods, tags)
- Original moment transcript (via P1 + P2)

**Unencrypted Fields:**
- `id`, `userId` (for auth + routing)
- `dateCreated`, `createdAt`, `updatedAt` (for chronological view)
- `title` (MVP: encrypted in phase 2+; currently unencrypted for Dwelling Place tab title display)

**Photos:** Handled separately via S3/storage service (file paths encrypted, files encrypted per S3 policies)

---

## Security Exclusions & Deferred Decisions

| Feature | Status | Reason |
|---------|--------|--------|
| **Server-side synthesis** | ❌ Excluded | LLM always runs client-side; prevents plaintext transmission |
| **Cloud key backup for journals** | ❌ Excluded | Keys stay on device only (inherited from P2) |
| **Unlimited journal editing** | ⏳ Deferred | v1 allows full edit; v2 will track edit history |
| **Journal export (PDF, etc.)** | ⏳ Deferred | Post-MVP feature; deferred to v2+ |
| **Journal sharing (private/public)** | ⏳ Deferred | v1 focus on personal reflection; v2+ sharing/collaboration |
| **On-device synthesis (Mistral 7B)** | ⏳ Deferred | MVP: cloud-based (Gemini 2.0). v2: on-device option for true offline |
| **GAI photo descriptions** | ⏳ Deferred | v2+ feature; v1 text-only journals supported |
| **AI-generated journal photos** | ⏳ Deferred | Post-MVP: ML-generated images for journals without user photos |

---

## Success Metrics (P4)

### Formation Intelligence Perspective
- ✅ Users see their spiritual story emerge through journals
- ✅ >75% satisfaction with auto-generated journal titles + bodies
- ✅ >70% of users customize suggested moods (signals ownership)
- ✅ >50% of users edit journal text post-synthesis (signals deep engagement)
- ✅ Journals become foundation for P5-P7 features

### Technical Perspective
- ✅ <5 sec average latency from prayer completion to Dwelling Place visible
- ✅ >80% of captured moments result in journal entries (completion rate)
- ✅ All journals encrypted before Supabase sync (AES-256-GCM)
- ✅ No plaintext journals ever stored server-side
- ✅ Journal structure supports rich linking (P1, P3, P5+)

---

## Open Questions & TBD

1. **Synthesis Latency UX?** (TBD)
   - Silent background work vs loading spinner vs confirmation screen showing progress?
   - Recommend: confirmation screen shows "Generating your journal..." while prayer completes

2. **Error State Handling?** (TBD)
   - If synthesis fails, fallback to Entry tab only? Retry? Manual entry prompt?
   - Decision needed before launch

3. **Journal Search Scope?** (To be designed in P6)
   - Should user search journal text + conversation transcript together, or separately?
   - Impacts search index strategy in P6

4. **Reflection Limits?** (TBD)
   - Can users add unlimited reflections to old entries, or encourage fresh captures?
   - Design question: endless editing vs depth through recapture

5. **Prompts in P4?** (LOCKED: Yes, include thoughtful prompts)
   - Should P4 include optional prompts to deepen journal reflection?
   - Decision: YES. P4 includes non-redundant prompts that build on P1 conversation, invite deeper reflection on synthesized journal. Separate from P3 prayer prompts; complementary to them.
   - Avoid redundancy with P1 capture prompts by focusing on "what changed in your thinking since you captured this?"

6. **What Triggers Journal Review?** (LOCKED: Multi-channel approach)
   - Out-app notifications: Reference questions from original moment's conversation (post-MVP)
   - In-app prompts: Contextual invitations to return and add missing details that would make journal more reflectable
   - Both mechanisms are invitational, never prescriptive

7. **Edit-Based Inferences?** (LOCKED: Capture now, infer Post-MVP)
   - MVP: Capture metadata about edits (mood changes, content deletions, edit timestamps, edit count)
   - Post-MVP: Use this metadata to make inferences about user's reflection patterns, emotional shifts, narrative evolution
   - Infrastructure built now enables future P7/P8 features without requiring schema changes

8. **AI Photo Generation (V2)?** (DEFERRED to Post-MVP)
   - ML-generated photos for journals that don't have user-provided images
   - Document in deferred decisions section

---

## Integration Points with Other Pillars

| Pillar | Integration |
|--------|-----------|
| **P1 (Capture)** | Journal entry links to original moment. User navigates between Entry (conversation) and Dwelling Place (synthesis). Conversation provides rich context for synthesis. |
| **P2 (Security)** | Conversation + journal encrypted at rest + transit (AES-256-GCM). Same key derivation as P2. Full E2E encryption. |
| **P3 (Soaking)** | Confirmation screen routes to P3 guided prayer. Prayer attaches to journal. Prayer becomes contemplative response to moment. |
| **P5 (Editing)** | Journals editable post-synthesis (moods, photos, text). Editing engagement signals quality + user ownership. |
| **P6 (Search)** | Journals searchable via full-text, filterable by moods/tags, browsable chronologically. Supports pattern discovery. |
| **P7 (Formation Intelligence)** | Journal entries analyzed for theme patterns. Moods + tags + content contribute to theme detection (3+ occurrence threshold). |
| **P8 (Beta)** | Journal creation rate + synthesis quality tracked as key engagement metrics. User cohorts measured by journaling behavior. |

---

## Next: How P4 Prepares P5

Once P4 is implemented, P5 (Editing) can be articulated as:
- **What P5 is:** A refinement layer for user ownership of their narrative
- **What P5 learns:** Editing patterns (do they truncate? expand? reframe?), ownership signals, narrative evolution
- **How P5 prepares P6:** By enabling rich journal customization, P5 gives P6 (Search) high-quality, personalized content to search across

---

**Ready to lock P4 Formation Intelligence and move to P5?**

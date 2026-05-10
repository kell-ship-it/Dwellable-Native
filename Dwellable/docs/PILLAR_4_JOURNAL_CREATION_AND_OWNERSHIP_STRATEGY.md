# Pillar 4: Journal Creation & Ownership (Synthesis + Customization) — Strategy & Design Skeleton

**Status:** ✅ **COMPLETE** (Phase 2 Beta)  
**Last Updated:** May 10, 2026

---

## Design Summary

Pillar 4 is the **synthesis + ownership layer** of Dwellable's Formation Intelligence system. It transforms captured moments into meaningful, personalized journal entries via LLM synthesis, then empowers users to refine and claim ownership over their narrative through customization.

The complete flow is: Capture → Confirmation (with prayer CTA) → Guided Prayer → Journal Synthesis (background) → Dwelling Place View → Editing & Customization (headlines, tags, moods, photos) → Saved.

P4 signals two profound truths:
1. **Your moments become stories** — Raw conversation reframes as a dwelling place
2. **Your narrative belongs to you** — App generates a starting point; you decide if it's true and beautiful

---

## Formation Intelligence — What Pillar 4 Is & Learns

### What Pillar 4 Is (in the Formation Intelligence System)

**The synthesis + ownership layer. Narrative creation AND personalization.**

| Pillar | Role |
|--------|------|
| **P0 (Onboarding)** | Establishes foundation: *"You are valuable and worthy"* + spiritual context |
| **P1 (Capture)** | Captures raw moment + infers archetype (Jotter, Venter, Processor) |
| **P2 (Security)** | Protects moments so P3+ can use rich context confidently |
| **P3 (Soaking)** | Seals the moment with prayer — user confirms value + connection to God |
| **P4 (Journal Creation & Ownership)** | *Synthesizes* moment into dwelling place, then empowers user to personalize and claim ownership. **Narrative proof** that formation is happening, authored by the user. |

### What P4 Learns About the User

P4 learns *how the user sees themselves* through both synthesis acceptance and customization choices:

1. **Narrative Style:** How do they emphasize their moment? (Detail-focused? Emotional? Action-oriented? Spiritual-seeking?)
2. **What's Journal-Worthy:** What kinds of moments do they choose to dwell on? What gets customized vs left default?
3. **Story Arc:** Over time, patterns in their spiritual narrative emerge. Are they moving toward maturity? Wrestling? Resting? Growing?
4. **Ownership Patterns:** Which moods do they choose? Do they add photos? Do they edit headlines? Customize tags? (Signals ownership depth + engagement)
5. **Signal Capture (MVP Infrastructure):** Capture metadata about edits (mood changes post-synthesis, content deletions, edit timestamps, edit count). Defer inference to Post-MVP; build infrastructure now.
6. **Editing Preferences:** Do they truncate headlines? Expand? Reframe? Which auto-suggested tags do they accept vs. reject? (Signals narrative preference)
7. **Tag/Mood Patterns:** Over time, what moods dominate their entries? Which themes do they emphasize? (Signals emotional/spiritual state evolution)

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

6. **"Precision is sacred."**
   - The mood you choose, the headline you write, the tags you select — these are not generic metadata.
   - They're your way of saying: "This is what this moment *meant* to me."

7. **"Your narrative is not fixed."**
   - The AI generated a starting point. You can keep it, refine it, or rewrite it entirely.
   - Customization freedom = narrative agency = spiritual formation through choice.

### How P4 Prepares P5 (Search & Discovery)

**P5 cannot surface patterns without P4's richness.**

Example (P5 future behavior):
- *"Search results: 12 moments with 'Healing' tag. You tagged these from Jan-Mar. Any themes you notice?"*
- *"You've tagged 60% of moments as 'Grateful' this quarter. Shift from last quarter's 40%?"*

This is only possible if:
1. P4 synthesizes rich journal content
2. **P4 empowers users to customize with precise, intentional metadata** (headlines, tags, moods)
3. P5 can now analyze patterns with confidence

**P4 removes two blockers:** By synthesizing moments AND allowing customization, P4 gives users something worth owning (not blank-page anxiety) and ensures P5 sees intentional data (not auto-generated defaults).

---

## Core Design Decisions — Locked

### Happy Path (9 Steps, Unified)

1. **Capture Complete** — User finishes conversational moment capture (Pillar 1), taps "Done"
2. **Confirmation Screen** — App shows: *"Captured your moment! We briefly talked about [x, y, z], would you like to pray over these things?"* (Shows app listened; invites prayer)
3. **Guided Prayer (v1)** — User enters Pillar 3 flow; guided prayer focused on captured moment. Prayer attaches to journal.
4. **Journal Synthesis (Background)** — While user prays, LLM generates title (4-6 words) + body (2-3 paragraphs) + suggested moods + auto-suggested tags
5. **Dwelling Place View** — User sees synthesized journal in "Dwelling Place" tab; can view original conversation in "Entry" tab. Both tabs share the AI-generated title.
6. **Edit Headline** — User can modify auto-generated headline (≤12 words suggested). Headline serves as title for both Entry and Dwelling Place.
7. **Set Object & Prayed Status** — User selects: (a) Object category (Family, Romance, Career, Health, Spiritual, Other), and (b) Prayed status (Not Yet Prayed | Prayed | Reflecting). System suggests Object based on entry content; user confirms or changes.
8. **Assign Mood** — User selects from preset emoji moods (Affection, Contentment, Enthusiasm, Surprised, Inward, Fearful, Angry, Sad) + optional custom mood field (≤20 chars). System provides personalized message reflecting mood + object + entry.
9. **Finalize & Save** — User confirms customization. Journal encrypted + synced to Supabase. Mood message appears as affirmation.

**Optional additions (same session):**
- Add/remove photos (camera or library)
- Edit journal body text (detail view only)
- Delete journal (soft delete, 30-day recovery)

### Synthesis Specification

**LLM Output (from conversation transcript):**
- **Title:** Auto-generated headline, 4-6 words. Contemplative, personal, affirming. Becomes title for BOTH Entry (conversation) and Dwelling Place (journal), creating unified narrative arc.
- **Body:** 2-3 paragraph narrative prose (not structured sections). Mirrors user's language but reframes as spiritual reflection.
- **Metadata Suggestions:** Auto-generates (1) Object category (Family, Romance, Career, Health, Spiritual, Other) and (2) suggested mood from preset palette (user can override). Signals to user what life domain + emotional/spiritual state the AI detected from their conversation.

**Tone:** Contemplative, personal, affirming. Acknowledges user's experience and points toward formation/growth.

**Powered by:** Rich Context (uses P0 identity, P1 archetype, theology, support style to make synthesis personal)

**Relational Formation Intelligence Signal:** The AI-generated title, suggested Object, moods, and Prayed status create a complete view of the user's moment. The system says: "Here's what you shared (Entry) → here's how we're reflecting on it (title + object category + mood + prayer status) → here's where you dwell on it (journal). Your whole spiritual experience is held and categorized."

### Editing Architecture

**What's Editable (Post-Synthesis):**
- `headline` (auto-generated, full user edit)
- `tags` (max 2, from suggested library or custom creation)
- `mood` (preset emoji + 1 custom field)
- `body` (journal text, detail view only)
- Photos (add/remove, before or after synthesis)

**What's NOT Editable (Preserves Integrity):**
- Original moment body (conversation transcript or typed text)
- Date/time of capture
- User's "Sense of Lord" reflection from capture

**Explicit UI Pattern:** "Edit Entry" button or inline editable fields in Dwelling Place tab. Changes happen in a focused editing context, not careless inline editing (prevents accidental changes).

### Metadata Components

#### Headlines (Auto-Generated + Editable)

**Generation:**
- System analyzes moment content (transcript/typed text)
- Generates 4-6 word headline contemplatively

**User Control:**
- Can edit before saving, or anytime via "Edit Entry"
- Single text field, plain text, soft suggestion: ≤12 words
- No edit tracking needed (user owns the headline freely)

#### 3-Dimensional Metadata Model (Prayed × Mood × Object)

**MVP Structure (Locked):**

Reflections have exactly 3 metadata dimensions:

1. **Prayed (Status)**
   - Options: Not Yet Prayed | Prayed | Reflecting
   - Indicates whether user has prayed over / responded to this moment
   - User can update anytime (signals engagement depth)

2. **Mood (Emotional + Spiritual State)**
   - Preset options: Affection, Contentment, Enthusiasm, Surprised, Inward, Fearful, Angry, Sad
   - AI-suggests based on entry content; user selects or overrides
   - Single mood per entry (enforces clarity)
   - Optional custom mood field for nuance (≤20 chars)

3. **Object (What It's About)**
   - Predefined categories: Family | Romance | Career | Health | Spiritual | Other
   - Single selection per entry (enforces focus)
   - System suggests based on content; user selects
   - These categories enable thematic discovery ("show me all Family moments")

**Why This Structure:**
- Bounded MVP scope (no unlimited custom tags causing cognitive overhead)
- Enables sophisticated filtering (Prayed + Mood + Object = rich discovery)
- Rich Context ready (system understands: "user has unprayed moment about Family anxiety")
- Formation signals dense (these 3 dimensions reveal spiritual formation trajectory)

**Post-MVP Feature: Custom Tagging**
- Allow users to create custom tags beyond the 6 Object categories
- Will be added after MVP validates search/discovery success
- Infrastructure built in MVP to support future custom tag expansion

#### Moods (Preset + 1 Custom)

**Preset Moods (Emoji + Text):**
- Affection, Contentment, Enthusiasm, Surprised, Inward, Fearful, Angry, Sad
- Single selectable option (no sub-moods in v1)

**Custom Mood:**
- 1 user-defined text field for nuance not covered by presets
- Can represent mood, person, concept, or contextual label
- Examples: "With Sarah", "Work Breakthrough", "Uncertain"

**Personalized Response:**
- System provides brief, contextual message reflecting mood + entry
- Example: *"It's okay to feel both uncertain and hopeful, Kell. This moment matters."*
- Template-based in v1 (no AI generation for mood message; preserves "keeper not interpreter" principle)

### Journal Artifact Structure

```swift
struct Journal: Codable {
    let id: String                      // UUID
    let userId: String                  // User ID (authenticated)
    let dateCreated: Date               // When journal was synthesized
    
    // Synthesis Fields
    let title: String                   // Auto-generated (4-6 words), shared with Entry
    let body: String                    // LLM synthesis (2-3 paragraphs)
    let originalMomentId: String        // Link back to Pillar 1 conversation
    
    // Customization Fields (Editable) — 3D Metadata Model
    var headline: String                // User-editable title (same as title field, in sync)
    var prayed: PrayedStatus            // Enum: NotYetPrayed | Prayed | Reflecting
    var mood: String                    // Preset emoji value (Affection, Contentment, etc.)
    var customMood: String?             // Optional user-defined mood nuance (≤20 chars)
    var object: String                  // Object category (Family, Romance, Career, Health, Spiritual, Other)
    var moodMessage: String             // Personalized affirmation based on mood + object
    var photos: [String]?               // Photo IDs (optional, added post-synthesis)
    
    // Metadata
    let prayerReference: String?        // Link to attached prayer artifact (Pillar 3)
    var edited: Bool                    // Tracks if user modified post-synthesis
    var editCount: Int                  // Track how many times user has edited
    var metadataEditedAt: Date?         // Timestamp of last metadata edit
    
    // Encryption & Sync
    let encryptedContent: Data          // AES-256-GCM encrypted (title, body, custom fields)
    let encryptedMetadata: Data?        // Moods, tags, metadata (encrypted)
    var deleted: Bool                   // Soft delete flag
    let createdAt: Date                 // ISO8601
    var updatedAt: Date                 // ISO8601
}

// Custom tagging infrastructure deferred to Post-MVP.
// In MVP, Object categories (Family, Romance, Career, Health, Spiritual, Other) are predefined.
```

### Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Two-Tab Architecture (Entry + Dwelling Place)** | Preserves original conversation while providing synthesized reflection space. Both tabs share the AI-generated title, creating a unified narrative showing moment → reflection → dwelling place. |
| **Unified Synthesis + Customization** | Editing is not separate; it's part of claiming ownership in the same session. User synthesizes → customizes → confirms in one coherent flow. |
| **Headline Serves Both Tabs** | Title generated by synthesis becomes the official title for Entry (conversation) and Dwelling Place (journal), showing user's moment has been heard and reframed. |
| **Confirmation Screen Before Prayer** | Shows app understood the moment ("talked about X, Y, Z"), invites contemplative response. Natural transition: capture → prayer → journal. |
| **3-Dimensional Metadata Model (Prayed × Mood × Object)** | For spiritual journaling, three metadata dimensions provide complete context without overwhelming user. Prayed status tracks engagement; Mood captures emotional/spiritual state; Object identifies life domain. All predefined in MVP (bounded scope). Custom tagging deferred to Post-MVP. |
| **LLM Synthesis Over Manual Entry** | Conversation is already deeply reflective; synthesis reframes as journal. Removes blank-page anxiety. User can edit post-synthesis with full autonomy. |
| **Post-Synthesis Photo Upload (v1)** | User can add/remove photos after journal created. Not all moments are visual; this allows flexibility. |
| **Max 2 Tags Per Entry** | Enforces focus on core themes. Prevents tag bloat and over-categorization. |
| **Journal Editability (Detail View + Modal)** | Users edit in focused context (not on list cards). Can modify moods, add photos, edit headline + body. Encourages ownership. |
| **Soft Delete + 30-Day Recovery** | Encourages fresh captures (new journals) over endless edits to old entries. User can recover within 30 days. |
| **Linking to Pillar 1** | Journal stores `originalMomentId`. User can navigate between Entry (conversation) and Dwelling Place (synthesis). |
| **AES-256-GCM Encryption** | Same as Pillar 2. Conversation + journal encrypted at rest and in transit. Client-side encryption only. |
| **Read-Only Moment Body** | Original moment body cannot be edited in P4. Preserves integrity of capture. Moments are truth; journals are interpretation. |
| **No Edit History (v1)** | Track `metadataEditedAt` timestamp only; no full edit history in v1. Simplicity prioritized; deferred to v2. |

---

## Technical Architecture

### Journal Creation & Customization Pipeline

```
Capture complete (P1)
    ↓
Confirmation screen shown
    ↓
User taps "Pray About This"
    ↓
Routes to Pillar 3 (Guided Prayer)
    ↓
While user prays: LLM synthesis runs in background
    → Title (4-6 words)
    → Body (2-3 paragraphs)
    → Suggested moods + tags
    ↓
Prayer completes: User returns from P3
    ↓
Dwelling Place tab shows synthesized journal
    ↓
User enters edit flow:
    → Edits headline if desired
    → Selects/customizes tags (SELECTED | SUGGESTED | ALL)
    → Selects mood (preset + optional custom)
    → Receives personalized affirmation
    → Optionally adds photos
    → Optionally edits body text
    ↓
User taps "Done" / "Save"
    ↓
All changes persisted locally (unencrypted, for offline)
    ↓
Encryption applied: title + body + metadata
    ↓
Sync to Supabase
```

### Key Components

**JournalSynthesisManager**
- Receives conversation transcript + Rich Context (user identity, archetype, themes)
- Calls LLM (Gemini 2.0 Flash MVP) to generate title + body + suggested tags/moods
- Returns structured output (title, body, suggested moods, suggested tags)
- Handles timeout/error cases (fallback to Entry-only view)

**JournalCustomizationManager**
- Manages headline editing (text field, soft max 12 words)
- Manages tag selection (3-tier display: SELECTED | SUGGESTED | ALL)
- Manages tag library (system + user-created)
- Manages mood selection (preset emoji + custom field)
- Generates personalized mood message (template-based)

**JournalStorageManager**
- Saves draft journal locally (unencrypted, for offline capability)
- Encrypts before syncing to Supabase (same encryption as P2)
- Handles soft delete + 30-day recovery window
- Manages mood palette + photo relationships

**EncryptionManager** (Shared with P2)
- Derives key from user password (Argon2id)
- Encrypts journal body + headline + metadata before cloud sync
- Decrypts on read (transparent to UI)

**HeadlineEditor**
- Text field for user to edit auto-generated headline
- Validates against soft max (≤12 word suggestion)
- Returns edited headline string

**TagSelector (3-Tier)**
- Shows SELECTED tags (removable)
- Shows SUGGESTED tags (tappable to add)
- Shows searchable ALL TAGS library
- Implements max-2 constraint
- Handles custom tag creation UI

**MoodSelector**
- Modal with 8 preset emoji options
- Text field for 1 custom mood
- Triggers personalized message generation
- Stores mood selection + custom text to entry metadata

**MoodMessageGenerator**
- Template-based (v1, no AI)
- Examples:
  - *"It's okay to feel [mood], [name]. This moment matters."*
  - *"Your [custom mood] is valid and worth noting."*
- Pulls user's name from P0 profile; uses selected mood/custom field

---

## Data Model & Encryption Impact

**Encrypted Fields:**
- `body` (full journal text)
- `headline` (title, unencrypted in v1, encrypted in v2)
- `encryptedMetadata` (moods, tags, custom mood)
- Original moment transcript (via P1 + P2)

**Unencrypted Fields:**
- `id`, `userId` (for auth + routing)
- `dateCreated`, `createdAt`, `updatedAt` (for chronological view)

**Photos:** Handled separately via S3/storage service (file paths encrypted, files encrypted per S3 policies)

---

## Security Exclusions & Deferred Decisions

| Feature | Status | Reason |
|---------|--------|--------|
| **Server-side synthesis** | ❌ Excluded | LLM always runs client-side; prevents plaintext transmission |
| **Cloud key backup** | ❌ Excluded | Keys stay on device only (inherited from P2) |
| **Unlimited journal editing** | ⏳ Deferred | v1 allows full edit; v2 will track complete edit history |
| **Journal export (PDF, etc.)** | ⏳ Deferred | Post-MVP feature; deferred to v2+ |
| **Journal sharing (private/public)** | ⏳ Deferred | v1 focus on personal reflection; v2+ sharing/collaboration |
| **On-device synthesis (Mistral 7B)** | ⏳ Deferred | MVP: cloud-based (Gemini 2.0). v2: on-device option for true offline |
| **AI-generated journal photos** | ⏳ Deferred | Post-MVP: ML-generated images for journals without user photos |
| **Tag suggestion personalization** | ⏳ Deferred | v1: simple content-based suggestions. v2: Rich Context-powered adaptive suggestions (risk: feels intrusive) |
| **Custom mood sharing** | ⏳ Deferred to V2 | v1: moods private per user. v2: explore discoverable/shareable custom moods |
| **Tag de-duplication** | ⏳ Deferred to V2+ | As tag library grows, tag merge/alias system needed (v2+) |

---

## Success Metrics (P4)

### Formation Intelligence Perspective
- ✅ Users see their spiritual story emerge through journals
- ✅ >75% satisfaction with auto-generated journal titles + bodies
- ✅ >70% of users customize suggested moods (signals ownership)
- ✅ >50% of users edit journal text post-synthesis (signals deep engagement)
- ✅ >60% of users edit entries post-creation (ownership signal)
- ✅ Headline acceptance >75% (users keep or minimally edit)
- ✅ Tag adoption >80% of entries have 1-2 tags (either auto or user-selected)
- ✅ Mood adoption >55% of entries have mood assigned
- ✅ Custom mood usage >30-40% of users add custom mood at least once
- ✅ Users report: *"I feel like my moments are well-tagged and contextualized"* (survey)
- ✅ Journals become foundation for P5-P7 features

### Technical Perspective
- ✅ <5 sec average latency from prayer completion to Dwelling Place visible
- ✅ >80% of captured moments result in journal entries (completion rate)
- ✅ All journals encrypted before Supabase sync (AES-256-GCM)
- ✅ No plaintext journals ever stored server-side
- ✅ Journal structure supports rich linking (P1, P3, P5+)
- ✅ Edit Entry discovery >90% of users find button/action within first 3 entries
- ✅ Edit time <2 minutes per entry (headline + tags + mood)
- ✅ No sync conflicts when editing across devices (conflict resolution working)
- ✅ All edits encrypted + synced to Supabase

---

## Open Questions & TBD

1. **Synthesis Latency UX?** (TBD)
   - Silent background work vs loading spinner vs confirmation screen showing progress?
   - Recommend: confirmation screen shows "Generating your journal..." while prayer completes

2. **Error State Handling?** (TBD)
   - If synthesis fails, fallback to Entry tab only? Retry? Manual entry prompt?
   - Decision needed before launch

3. **Journal Search Scope?** (To be designed in P5)
   - Should user search journal text + conversation transcript together, or separately?
   - Impacts search index strategy in P5

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

---

## Considered & Rejected

| Decision | Reasoning |
|----------|-----------|
| **Unlimited tags** | Risk of tag bloat + over-categorization. Max 2 forces focus on core themes. |
| **AI-powered mood suggestions** | Violates "keeper not interpreter" principle. Mood is user's sovereign choice; system doesn't assign. |
| **Inline editing** | Explicit "Edit Entry" button clarifies intent + prevents accidental changes (Untold pattern). |
| **Editable moment body** | Preserves integrity of original capture. Moments are truth; journals are interpretation. |
| **Multiple custom moods** | v1 constraint: 1 custom field. Prevents mood from becoming another tagging system. |
| **Mood sub-categories** | v1 simplicity: 8 presets + 1 custom covers most cases. Sub-moods deferred to v2+. |
| **Separate P5 pillar** | Editing is not a separate pillar; it's integral to the journal creation experience. User claims ownership in the same session: synthesis → customize → save. |

---

## Integration Points with Other Pillars

| Pillar | Integration |
|--------|-----------|
| **P1 (Capture)** | Journal entry links to original moment. User navigates between Entry (conversation) and Dwelling Place (synthesis). Conversation provides rich context for synthesis. Can view original moment within edit modal (read-only context). |
| **P2 (Security)** | Conversation + journal encrypted at rest + transit (AES-256-GCM). Same key derivation as P2. Full E2E encryption. |
| **P3 (Soaking)** | Confirmation screen routes to P3 guided prayer. Prayer attaches to journal. Prayer becomes contemplative response to moment. |
| **P5 (Search & Discovery)** | Journals searchable via full-text, filterable by moods/tags, browsable chronologically. Supports pattern discovery. Tags + moods edited in P4 become the foundation for P5 search/filtering. User can search "All 'Healing' moments" because P4 enabled precise tagging. |
| **P6 (Formation Intelligence)** | Journal entries analyzed for theme patterns. Moods + tags + content contribute to theme detection (3+ occurrence threshold). Theme detection (P6) analyzes tag + mood patterns created/refined in P4. Tag frequency + mood distribution reveal formation arc. |
| **P7 (Beta & Marketing)** | Journal creation rate + synthesis quality tracked as key engagement metrics. User cohorts measured by journaling behavior + customization depth. |

---

## Next: How P4 Prepares P5 (Search & Discovery)

Once P4 is implemented, P5 (Search & Discovery) can be articulated as:
- **What P5 is:** A discovery layer that uses P4's enriched metadata to surface patterns and enable re-engagement
- **What P5 learns:** Search patterns (what users look for), filter preferences (mood vs. tag vs. date), browsing behavior
- **How P5 prepares P6:** By tracking what users search for and what patterns interest them, P5 signals which themes are formation-relevant to the user

---

**✅ P4 Formation Intelligence & Ownership: LOCKED**

P4 now combines journal synthesis with user customization into one coherent pillar that gives users permission to dwell on their moments AND claim ownership of their narratives.

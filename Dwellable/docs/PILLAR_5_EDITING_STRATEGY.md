# Pillar 5: Editing (Headlines, Tags & Moods) — Strategy & Design Skeleton

**Status:** 🔄 **DESIGN IN PROGRESS** (T-070+)  
**Last Updated:** May 10, 2026

---

## Design Summary

Pillar 5 is the **ownership layer** of Dwellable's Formation Intelligence system. It enables users to refine and personalize journals and moments by editing metadata (headlines, tags, moods) post-creation. This layer signals to users that:

1. **Their narrative belongs to them** — they can reshape how they frame their moments
2. **Precision matters** — the moods and tags they choose become data for deeper formation understanding
3. **Control enables formation** — by owning the "shape" of their story, they gain agency in their spiritual journey

Pillar 5 does NOT edit the original moment body (preserving integrity), but allows full customization of how moments are labeled and contextualized.

---

## Formation Intelligence — What Pillar 5 Is & Learns

### What Pillar 5 Is (in the Formation Intelligence System)

**An ownership + agency layer.**

| Pillar | Role |
|--------|------|
| **P0 (Onboarding)** | Establishes foundation: identity + theological framework |
| **P1 (Capture)** | Captures raw moment + infers archetype |
| **P2 (Security)** | Protects moments so P3+ can use rich context confidently |
| **P3 (Soaking)** | Seals moment with prayer — signals value to God |
| **P4 (Journal Creation)** | Synthesizes moment into narrative dwelling place |
| **P5 (Editing)** | *Personalizes* the narrative. User claims ownership over how their story is framed. |

### What P5 Learns About the User

P5 learns through the *choices* users make when personalizing:

1. **Editing Patterns:** Do they truncate? Expand? Reframe auto-generated headlines? (Signals narrative preference)
2. **Tag Selection:** Which themes do they emphasize? Are auto-suggested tags rejected or accepted? (Signals what matters to them)
3. **Mood Patterns:** Over time, what moods dominate their entries? Seasonal shifts? Growth patterns? (Signals emotional/spiritual state evolution)
4. **Customization Depth:** Do they add custom moods? Multiple tags? Edit every entry or let some default? (Signals engagement depth + ownership)
5. **Metadata Consistency:** How consistent are they with tagging strategy? Does this reveal discipline or exploratory nature? (Signals formation style)

### What P5 Communicates to the User

**Powerful signal: You get to decide how your story is told.**

1. **"Your narrative is not fixed."**
   - App generated a starting point. You decide if it's accurate and beautiful.
   - Editing freedom = narrative agency = spiritual formation through choice.

2. **"Precision is sacred."**
   - The mood you choose, the tags you select — these are not generic metadata.
   - They're your way of saying: "This is what this moment *meant* to me."

3. **"Your patterns matter."**
   - By selecting moods + tags consistently, you're building a map of your spiritual life.
   - Future pillars will see these patterns and help you understand your formation journey.

### How P5 Prepares P6 (Search & Discovery)

**P6 cannot surface patterns without P5's richness.**

Example (P6 future behavior):
- *"Search results: 12 moments with 'Healing' tag. You tagged these from Jan-Mar. Any themes you notice?"*
- *"You've tagged 60% of moments as 'Grateful' this quarter. Shift from last quarter's 40%?"*

This is only possible if:
1. P4 created rich journal content
2. **P5 enriched it with precise, intentional metadata** (headlines, tags, moods)
3. P6 can now analyze patterns with confidence

**P5 removes generic metadata:** By allowing users to customize tags/moods/headlines, P5 ensures that P6 sees *intentional* data, not auto-generated default values.

---

## Core Design Decisions — Locked

### Happy Paths (5 Main Paths)

1. **Edit Moment Headline:** User taps "Edit Entry" → modifies auto-generated headline → saves
2. **Customize Tags:** User sees SELECTED | SUGGESTED | ALL TAGS → adds/removes tags → saves (max 2)
3. **Assign Mood:** User selects from preset emoji moods + optional custom field → sees personalized message → saves
4. **Remove Unwanted Metadata:** User removes auto-suggested tags or moods they don't align with
5. **Create Custom Tags:** User creates new tag on-the-fly if existing library doesn't fit their narrative

### Editing Architecture

**What's Editable:**
- `headline` (auto-generated, full user edit)
- `tags` (max 2, from suggested or custom library)
- `mood` (preset emoji + 1 custom field)
- Photos (add/remove post-synthesis)

**What's NOT Editable (Preserves Integrity):**
- Original moment body (conversation transcript or typed text)
- Date/time of capture
- User's "Sense of Lord" reflection from capture

**Explicit UI Pattern:** "Edit Entry" button opens dedicated edit modal/screen (Untold pattern). Changes happen in a focused editing context, not inline editing (prevents accidental changes).

### Metadata Components

#### Headlines (Auto-Generated + Editable)

**Generation:**
- System analyzes moment content (transcript/typed text)
- Generates 5-8 word headline when quality threshold met (min. 50 chars OR 10 words)

**User Control:**
- Can edit before saving, or anytime via "Edit Entry"
- Single text field, plain text, no hard limit (soft suggestion: ≤12 words)
- No edit tracking needed (user owns the headline freely)

#### Tags (3-Tier Selection, Max 2)

**Auto-Generation:**
- System suggests 1-2 tags based on entry content analysis
- Lock icon marks auto-generated tags; user-selected tags unmarked

**Three-Tier Display (when editing):**
1. **SELECTED:** Tags currently assigned to this entry (removable with X)
2. **SUGGESTED:** AI-recommended tags based on entry content (user can tap to add)
3. **ALL TAGS:** Searchable library of all existing tags; user can search/create new

**Constraints:**
- Max 2 tags per entry (enforces focus on core themes)
- User can remove any tag (including auto-suggested)
- Custom tags created on-the-fly if existing ones don't fit

#### Moods (Preset + 1 Custom)

**Preset Moods (Emoji + Text):**
- Affection, Contentment, Enthusiasm, Surprised, Inward, Fearful, Angry, Sad
- Selectable options (no sub-moods in v1)

**Custom Mood:**
- 1 user-defined text field for nuance not covered by presets
- Can represent mood, person, concept, or contextual label
- Examples: "With Sarah", "Work Breakthrough", "Uncertain"

**Personalized Response:**
- System provides brief, contextual message reflecting mood + entry
- Example: *"It's okay to feel both uncertain and hopeful, Kell. This moment matters."*

---

## Technical Architecture

### Edit Entry Flow

```
User in Moment Detail View
    ↓
Taps "Edit Entry" button
    ↓
Edit Modal/Screen opens
    ↓
User can edit: headline, tags (SELECTED|SUGGESTED|ALL), mood (preset + custom)
    ↓
Original moment body visible but READ-ONLY (no editing)
    ↓
Taps "Done" button
    ↓
All metadata changes saved to entry
    ↓
Journal encryption updated (if needed)
    ↓
Sync to Supabase
```

### Key Components

**HeadlineEditor**
- Text field for user to edit auto-generated headline
- Validates against min. length (kept short for ≤12 word suggestion)
- Returns edited headline string

**TagSelector (3-Tier)**
- Shows SELECTED tags (removable)
- Shows SUGGESTED tags (tappable to add)
- Shows searchable ALL TAGS library
- Implements max-2 constraint
- Handles custom tag creation UI

**TagLibraryManager**
- Maintains system tag library (auto-generated + user-created)
- Provides search/filter on tag library
- Associates tags with moments

**MoodSelector**
- Modal with 8 preset emoji options
- Text field for 1 custom mood
- Triggers personalized message generation
- Stores mood selection + custom text to entry metadata

**MoodMessageGenerator**
- Simple template-based (v1, no AI)
- Examples:
  - *"It's okay to feel [mood], [name]. This moment matters."*
  - *"Your [custom mood] is valid and worth noting."*
- Pulls user's name from P0 profile; uses selected mood/custom field

**EditEntryController**
- Coordinates all editing flows
- Ensures read-only fields stay protected
- Handles validation before saving
- Triggers encryption + sync after edit

---

## Data Model & Integration

### Entry Metadata (Updated from P4)

```swift
struct JournalEntry {
    // ... existing fields from P4 ...
    
    // Editable metadata
    var headline: String                // User can edit anytime
    var tags: [String]                  // Max 2, from library or custom
    var mood: String                    // Preset emoji value
    var customMood: String?             // Optional user-defined mood
    var moodMessage: String             // Generated personalized message
    
    // Tracking
    var metadataEditedAt: Date?         // Timestamp of last metadata edit
    var editCount: Int                  // Track how many times user has edited
}
```

### Tag Library (System)

```swift
struct TagLibrary {
    var id: String                      // UUID
    var tagName: String                 // "Healing", "Anxiety", etc.
    var isSystemGenerated: Bool         // Auto-suggested or user-created
    var frequency: Int                  // How many moments use this tag
    var firstUsedAt: Date              // When tag first appeared
    var lastUsedAt: Date               // Most recent use
}
```

---

## Security & Encryption

**Encryption Impact:**
- Headline (unencrypted in v1, encrypted in v2)
- Tags & moods (encrypted as metadata)
- Same AES-256-GCM encryption as P2/P4

**Privacy:**
- Tag library shared at user level (not public)
- Custom moods private to user (v1); potential sharing explored in v2+

---

## Success Metrics (P5)

### Formation Intelligence Perspective
- ✅ Users edit >60% of entries post-creation (ownership signal)
- ✅ Headline acceptance >75% (users keep or minimally edit)
- ✅ Tag adoption >80% of entries have 1-2 tags (either auto or user-selected)
- ✅ Mood adoption >55% of entries have mood assigned
- ✅ Custom mood usage >30-40% of users add custom mood at least once
- ✅ Users report: *"I feel like my moments are well-tagged and contextualized"* (survey)

### Technical Perspective
- ✅ Edit Entry discovery >90% of users find button/action within first 3 entries
- ✅ Edit time <2 minutes per entry (headline + tags + mood)
- ✅ No sync conflicts when editing across devices (conflict resolution working)
- ✅ All edits encrypted + synced to Supabase

---

## Open Questions & TBD

1. **Tag Suggestion Personalization?** (TBD)
   - Should tag suggestions adapt based on user's past tagging patterns (Rich Context)?
   - Risk: feels intrusive vs. helpful. User testing needed.

2. **Custom Mood Sharing?** (Deferred to V2)
   - Should custom moods be discoverable/shareable across app like tags?
   - Or stay private per user? Design decision needed.

3. **Tag De-duplication?** (Deferred to V2+)
   - As tag library grows, users may create similar tags ("Healing" vs "Heal", "Anxiety" vs "Worried")
   - Tag merge/alias system needed eventually (v2+)

4. **Edit History?** (Deferred to V2)
   - Track full edit history for moods + tags? Show *what changed* when user edits?
   - v1 simplicity: track `metadataEditedAt` timestamp only

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

---

## Integration Points with Other Pillars

| Pillar | Integration |
|--------|-----------|
| **P1 (Capture)** | User can view original moment within Edit Entry modal (read-only context). |
| **P4 (Journal Creation)** | Edits to headlines/tags/moods refine the synthesized journal created by P4. |
| **P6 (Search)** | Tags + moods edited in P5 become the foundation for P6 search/filtering. User can search "All 'Healing' moments" because P5 enabled precise tagging. |
| **P7 (Formation Intelligence)** | Theme detection (P7) analyzes tag + mood patterns created/refined in P5. Tag frequency + mood distribution reveal formation arc. |

---

## Next: How P5 Prepares P6

Once P5 is implemented, P6 (Search & Discovery) can be articulated as:
- **What P6 is:** A discovery layer that uses P5's enriched metadata to surface patterns and enable re-engagement
- **What P6 learns:** Search patterns (what users look for), filter preferences (mood vs. tag vs. date), browsing behavior
- **How P6 prepares P7:** By tracking what users search for and what patterns interest them, P6 signals which themes are formation-relevant to the user

---

**Ready to lock P5 Formation Intelligence and move to P6?**

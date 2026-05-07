# Pillar 4: Editing — Headlines, Tags & Moods — Architectural Design Skeleton

**Status:** 🔄 Architectural Design Complete, Implementation Not Started (T-067, T-068, T-069, T-070)  
**Last Updated:** May 5, 2026

---

## Key Job to Be Done

**Phase 1 Proven:** Capture works. Users record/type moments. System auto-generates headlines and tags.

**Phase 2 Gap:** Moments are captured but metadata (headlines, tags, moods) need refinement. Users should be able to:
- Accept or customize auto-generated headlines post-capture
- Add/remove tags to align with how *they* categorize their reflection
- Assign emotional/contextual moods to moments for pattern recognition
- Edit all three without touching the original moment text (preserving integrity)

**Pillar 4's Job:** Provide a focused editing flow (headlines + tags + moods) that respects user agency while leveraging system-generated starting points (headlines, suggested tags).

---

## Skeletal System Overview

Pillar 4 consists of three interconnected metadata layers plus an explicit "Edit Entry" flow:

### 1. **Headlines (Auto-Generated + Editable)**
- **Generation:** System analyzes reflection content (voice transcript or typed text) and auto-generates a 5-8 word headline once quality threshold is met (min. character count, coherence)
- **User Control:** User can remove/edit headline before saving, or edit anytime via "Edit Entry"
- **Design:** Single text field, plain text, no character limit but soft suggestion ≤12 words
- **Edit Tracking:** No subtext needed for edited headlines (unlike reflections); user owns the headline

### 2. **Tags (3-Tier Selection + Max 2)**
- **Auto-Generation:** System suggests 1-2 tags based on entry content analysis
- **Three-Tier Display (when editing):**
  - **SELECTED:** Tags currently assigned to this entry (can remove with X or swipe)
  - **SUGGESTED:** AI-recommended tags based on entry content (user can tap to add)
  - **ALL TAGS:** Searchable library of all existing tags in system; user can search/create new tags
- **Max 2 Tags:** Hard limit to avoid bloat and keep tagging focused on core themes
- **Lock Icon:** Auto-generated tags marked with lock icon; user-selected tags unmarked
- **Custom Tags:** User can create new tags on-the-fly if existing ones don't fit
- **Removal:** User can remove any tag (including auto-suggested) before or after saving

### 3. **Moods (Preset + 1 Custom)**
- **Preset Moods:** Emoji + text options representing primary emotional states
  - Affection, Contentment, Enthusiasm, Surprised, Inward, Fearful, Angry, Sad
  - Each mood is a selectable option (not expandable sub-moods in v1)
- **Custom Mood:** 1 user-defined field (text input) for nuance not covered by presets
  - Can represent a mood, person, concept, or contextual label
  - Example: "With Sarah" or "Work Breakthrough" or "Uncertain"
- **Personalized Response:** System provides brief, contextual message reflecting mood + entry (e.g., "It's okay to feel both uncertain and hopeful, Kell")
- **Visual Indicator:** Mood shown in entry metadata; filterable in search (Pillar 5)

### 4. **Edit Entry Flow (Explicit Action)**
- **Trigger:** User taps "Edit Entry" button in moment detail/menu (Untold pattern)
- **Flow:**
  1. Modal or full-screen view opens
  2. Headline editable (text field)
  3. Tags section (SELECTED | SUGGESTED | ALL TAGS)
  4. Mood selector (preset modal + custom text field)
  5. Original reflection text visible but NOT editable (read-only)
  6. "Done" button saves all metadata changes
- **What's NOT Editable:** Original moment body, date, time (preserves data integrity)
- **Edited Reflection Subtext:** If user has added reflections/responses to moment, show "edited on [date]" timestamp (but no edit history v1)

---

## Competitor Research & Skeletal References

### Untold (Edit Flow Pattern)
**Design Pattern:** Explicit "Edit Entry" action opens dedicated edit view; metadata and content clearly separated  
**Key Insight:** Users understand they're in edit mode; reduces accidental changes. Clear affordance prevents confusion about what's changeable.  
**Screenshot reference:** [Modal showing editable fields separate from read-only content]  
**Dwellable adoption:** "Edit Entry" button triggers editing flow; moment body is read-only

### Reflection.app (Three-Tier Tag Selection)
**Design Pattern:** SELECTED | SUGGESTED | ALL TAGS interface with search; lock icon for system tags  
**Key Insight:** Progressive tag discovery—users see what's assigned, what's suggested, and what's available without overwhelming choice.  
**Screenshot reference:** [Three distinct sections of tags; search/add field at top; lock icons on auto-generated]  
**Dwellable adoption:** Exact three-tier tag display for editing flow

### Prayer Lock & Abide (Mood Selection)
**Design Pattern:** Emoji + text mood picker with personalized message reflecting selected mood  
**Key Insight:** Mood context humanizes the entry and enables emotional pattern recognition. Personalized response validates user's state.  
**Screenshot reference:** [Modal with emoji moods; below shows contextual message like "It's okay to feel uncertain"]  
**Dwellable adoption:** Preset emoji moods + 1 custom field for user-defined nuance

---

## Technical Architecture

### Components

**HeadlineGenerator**
- Analyzes reflection text (transcript or typed)
- Extracts key themes/first impression phrases
- Generates 5-8 word headline
- Quality threshold: min. 50 characters or 10 words (tunable)
- Returns headline string + confidence score

**TagSuggester**
- Analyzes reflection content using semantic similarity or keyword extraction
- Suggests 1-2 tags from existing tag library (or creates new if novel theme detected)
- Returns suggested tag array + confidence scores
- Tags marked as system-generated in database

**MoodSelector**
- Modal with preset emoji options (8 primary moods + custom field)
- User selection triggers personalized message generation (simple templates based on mood)
- Stores mood + custom text to entry metadata

**EditEntryView**
- SwiftUI modal/full-screen view
- Displays: headline field, tag selector (3-tier), mood picker, read-only reflection
- Handles tag add/remove/search
- Custom tag creation flow
- Saves all metadata changes to entry

**MoodMessageGenerator**
- Simple template-based system (v1)
- Examples: "It's okay to feel [mood], [name]. This moment matters." / "Your [custom mood] is valid and worth noting."
- Pulls user's name from profile; uses selected mood/custom field
- No AI response (template only) for v1

### Data Persistence

**Moment Model Updates:**
```
headline: String (auto-generated, user-editable)
tags: [String] (max 2, user-selected/suggested)
mood: String (preset enum)
customMood: String (optional, user-defined)
moodMessage: String (generated based on mood selection)
reflectionEditedAt: ISO8601? (timestamp if user added/edited reflections)
```

**Tag Library (System):**
- All tags ever created (auto-generated or user-created)
- Associated with moments for search/filtering
- Persisted to Supabase; synced across devices

---

## UI Screens (Implementation Phase)

| Screen | Purpose | Status |
|--------|---------|--------|
| **Edit Entry (Modal/Full-Screen)** | Headline + Tags + Mood editing interface | 🔲 Not Started |
| **Tag Selector (3-Tier)** | SELECTED \| SUGGESTED \| ALL TAGS with search | 🔲 Not Started |
| **Custom Tag Creation** | Flow to create new tag if existing ones don't fit | 🔲 Not Started |
| **Mood Picker** | Emoji + preset options + custom text field | 🔲 Not Started |
| **Moment Detail View (Updated)** | Show headline, tags, mood as metadata; "Edit Entry" affordance | 🔲 Not Started |

---

## Considered & Rejected

| Decision | Reasoning |
|----------|-----------|
| **Unlimited tags** | Risk of tag bloat and over-categorization. Max 2 forces focus on core themes. Users can refine during editing if needed. |
| **AI-powered mood suggestions based on content** | Violates "keeper not interpreter" principle. Mood is user's choice; system doesn't interpret emotional state. User selects, not system assigns. |
| **Edit history for headlines** | v1 simplicity. Users can see when reflection was edited but not headline-specific changelog. Deferred to Phase 3. |
| **Inline editing (tap to edit in-place)** | Reduces accidental changes; explicit "Edit Entry" action clarifies intent (Untold pattern). In-place editing creates ambiguity. |
| **Editable reflection text** | Preserves moment integrity and audit trail. Reflections are additions to moments, not replacements. Edit tracking keeps reflections trustworthy. |
| **Multiple custom moods** | v1 constraint: 1 custom field per entry. Limits flexibility slightly but prevents mood as another tagging system. Deferred if needed post-launch. |
| **Mood sub-categories (expandable moods)** | v1 simplicity. Eight preset moods + 1 custom covers most cases. Sub-moods (e.g., "Sad → Melancholy") deferred to Phase 2+. |

---

## Open Questions

| Question | Status | Next Step |
|----------|--------|-----------|
| **How should headline auto-generation quality be tuned?** | Locked for P2 (min. 50 chars or 10 words threshold) | Validate threshold through user testing; adjust if headlines are too generic or too specific |
| **Should users be able to create tags before editing existing ones?** | Deferred to Phase 2+ | Explore whether tag creation at capture time (vs. only via edit) improves user adoption |
| **Should tag suggestions change based on user's editing patterns?** | In Progress — needs Rich Context | Test whether personalized tag suggestions (based on user's past tags) feel helpful or intrusive |
| **How should system handle conflicts if same moment is edited on two devices simultaneously?** | Blocked by sync architecture review | Design conflict resolution (last-write-wins vs. merge) for offline edits across devices |
| **Should mood be filterable separately from tags in search?** | Locked for P2 (yes, both filterable) | Validate whether mood filtering helps users discover patterns (Pillar 5 decision) |
| **Should custom moods be shareable/discoverable across app, or private per user?** | Deferred to Phase 2+ | Explore whether custom mood library (like tags) adds value or creates noise |

---

## Top 5 Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| **Headline quality too generic** — System generates bland headlines ("My Moment", "Reflection") | Users don't find headlines helpful; skip editing | Tune headline generation threshold; test on real reflections; allow user to reject + regenerate |
| **Tag bloat over time** — Users create redundant tags (e.g., "Healing" + "Heal") | Search & filtering become noisy; discovery suffers | Max 2 tags enforces discipline. Implement tag merge/alias system in future if needed. |
| **Mood selection feels disconnected from reflection** — Custom mood field ignored by most users | Feature underutilized; poor personalization signal | User testing: validate that preset moods + 1 custom field feels balanced. Consider preset expansion if needed. |
| **Edit Entry button discovery failure** — Users don't find affordance to edit | Headlines/tags/moods never get refined; metadata quality degrades | Prominent button placement; tutorial on first entry view; context menu + gesture affordances |
| **Sync conflicts when editing on multiple devices** — User edits tags on iPhone, then iPad, first edit overwrites second | Data loss; user frustration | Implement conflict detection; default to last-write-wins with user notification; consider merge strategy for Phase 2+ |

---

## Blocking Dependency

**None explicit.** Pillar 4 can ship independently after Pillar 3 (Soaking) is live. However, tag/mood data should flow to Pillar 5 (Search), so coordinate implementation timeline.

---

## Intended Outcome

### Adoption Metrics
- **Edit Entry usage:** 60%+ of users refine headlines/tags/moods post-capture by week 4
- **Headline acceptance:** 75%+ of users keep system-generated headlines (minimal rejection rate)
- **Tag adoption:** 80%+ of entries have 1-2 tags (either auto-suggested or user-added)
- **Mood adoption:** 55%+ of entries have mood assigned (optional, not mandatory)
- **Custom mood usage:** 30-40% of users add custom mood on at least one entry

### Experience Metrics
- **Edit Entry discovery:** 90%+ of users find the "Edit Entry" button/action within first 3 entries
- **Confidence in metadata:** Users report "I feel like my moments are well-tagged and contextualized" (survey post-edit)
- **Time to edit:** Editing headlines/tags/moods takes <2 minutes per entry

### Pattern Recognition Outcomes
- Users begin to see themes in their tag selection ("I notice 60% of my entries are tagged 'Healing'")
- Mood patterns emerge (seasonal mood trends, stress-response patterns)
- Tags + moods enable meaningful search results (Pillar 5 feeds these signals)

---

## What's NOT Included (Deferred to Phase 2+)

❌ Edit history / revision history for headlines  
❌ Mood sub-categories or expandable moods  
❌ Tag merging or de-duplication system  
❌ Editable reflection text (preserving integrity)  
❌ Multiple custom moods per entry  
❌ AI-powered mood suggestions based on entry content  
❌ Social sharing of tags or moods  
❌ Tag analytics or trending tag visualization  

These are explicitly deferred and will only be considered if Phase 2 (Headlines + Tags + Moods) succeeds via adoption metrics.

---

## Implementation Tickets (Not Started)

- **T-067:** Headline auto-generation + user edit flow
- **T-068:** Three-tier tag selector + custom tag creation
- **T-069:** Mood picker (preset + custom) + personalized message generation
- **T-070:** Edit Entry modal + moment metadata updates

---

**Reference:** See `PILLAR_ONBOARDING_STRATEGY.md`, `PILLAR_1_CAPTURE_STRATEGY.md`, and `PILLAR_3_SOAKING_STRATEGY.md` for related pillars; see `DWELLABLE_THOUGHTS.md` for reflection display format considerations.

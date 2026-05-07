# Pillar 5: Search — Query & Discover Reflections — Architectural Design Skeleton

**Status:** 🔄 Architectural Design Complete, Implementation Not Started (T-071, T-072, T-073, T-074)  
**Last Updated:** May 5, 2026

---

## Key Job to Be Done

**Phase 1-2 Proven:** Users capture moments, dwell on them, add metadata (headlines, tags, moods). But they need a way to *find* moments again.

**Phase 2 Gap:** Moments are saved but discovery is passive (scrolling gallery). Users need multiple search/filter pathways:
- Browse by date (calendar interface)
- Filter by tags ("show me all Healing moments")
- Filter by reflection status ("show me entries I've prayed about")
- Full-text search across all content

**Phase 2+ Vision:** Semantic search + unified discovery connecting Dwellable moments to external spiritual content (Bible verses, studies, books, films).

**Pillar 5's Job:** Enable users to *find their moments* through multiple query pathways, starting with date/tag/status filtering (v1), expanding to semantic search and cross-platform discovery (Phase 2+).

---

## Skeletal System Overview

Pillar 5 consists of two phases: **v1 (Query & Filter)** and **future (Semantic Discovery)**.

### Phase 1: Query & Filter (v1)

#### 1. **Calendar View (Date-Based Discovery)**
- **Layout:** Month view at top (Untold pattern)
- **Interaction:** 
  - User sees current month with all days
  - Tap date → filters entry list to show only entries from that day
  - Previous/Next arrows navigate months
  - Days with entries have visual indicator (bold, highlight, or dot)
- **Purpose:** Enables rapid date-based browsing ("show me what I captured in early May")
- **Design Pattern:** Untold, Apple Calendar

#### 2. **Entry List (Filtered Results)**
- **Layout:** Vertical scrollable list below calendar
- **Display per entry:**
  - Headline (title)
  - Preview text (first 30-50 words)
  - Date + metadata (Journal label, tags, mood indicator)
  - Optional thumbnail/visual indicator
- **Filter State:** List updates as user changes calendar date, tag filter, or status filter
- **Tap to Open:** Each entry opens full detail view

#### 3. **Tag Filter (Multi-Select)**
- **Trigger:** Tap tag icon or "Filter by tags" button
- **Interface:** Modal/sidebar with searchable tag list
- **Behavior:**
  - User can select multiple tags (OR logic: show entries with *any* selected tag)
  - User can remove individual tag selections
  - "Clear filters" button resets to all entries
  - Tag count shows how many entries match selected tags
- **Combined with Date:** User can filter by date *and* tags simultaneously
- **Design Pattern:** Reflection.app, Evernote

#### 4. **Prayed Status Filter**
- **Purpose:** Distinguish entries with reflections/prayers from those without
- **Options:**
  - All entries (default)
  - Only entries with reflections/prayers ("Prayed")
  - Only entries without reflections yet ("Not yet prayed")
- **Logic:** Reflection = user response to prayer prompt or soaking prompt
- **Design Pattern:** Simple toggle or radio buttons

#### 5. **Full-Text Search**
- **Trigger:** Magnifying glass icon at top
- **Interface:** Search input field at top of screen
- **Behavior:**
  - Searches across: headlines, entry text, tags, custom moods
  - Real-time results as user types (debounced)
  - Shows matching entries in list below
  - Highlights matching terms in results (optional)
- **Scope:** Searches only user's own moments (no cross-user search)
- **Design Pattern:** Untold, Apple Notes

#### 6. **Ask Your Entries (Future v1.1)**
- **Button:** "Ask Your Entries" prompt at top
- **Purpose:** AI-powered query across all reflections
- **Example Queries:** "What themes show up most in my reflections?" / "When do I feel most at peace?" / "How has my faith evolved?"
- **Response:** Natural language summary + relevant matching entries
- **Status:** Deferred to Phase 2.1 (after v1 search + tagging mature)
- **Tech:** Requires embeddings + semantic search on user's reflection corpus

---

### Phase 2+: Semantic Discovery (Future)

#### 7. **Unified Discovery (Cross-Platform)**
- **Concept:** Search for a theme (e.g., "Love") and see:
  - Dwellable reflections tagged/mentioning "Love"
  - Bible verses about love (YouVersion API integration)
  - Bible studies/plans on love
  - Books, films, music about love (external content API)
  - All unified in a single results view
- **Purpose:** Connect user's personal moments to broader spiritual/cultural context
- **Design Pattern:** Bible App's unified search, Spotify cross-platform discovery
- **Status:** Deferred to Phase 2+ (requires external API integrations, content licensing)

---

## Competitor Research & Skeletal References

### Untold (Calendar + Entry List)
**Design Pattern:** Month calendar picker at top; filtered entry list below; tap date to filter  
**Key Insight:** Date-based browsing is the most natural discovery path for journaling apps. Visual calendar makes it clear which days have content.  
**Screenshot reference:** [Calendar view with May selected; entries listed below by date]  
**Dwellable adoption:** Calendar at top, entry list below; Untold's layout is the skeletal model

### Reflection.app (Multi-Select Filtering)
**Design Pattern:** Tag modal with searchable list; user can select/deselect multiple tags; count shows results  
**Key Insight:** Users want to explore intersections of themes ("show me Healing + Gratitude moments"). Multi-select enables this without overwhelming UI.  
**Screenshot reference:** [Tag filter modal with checkboxes; tag count and result preview]  
**Dwellable adoption:** Multi-select tag filtering with modal interface

### Apple Calendar & Notes (Full-Text Search)
**Design Pattern:** Search icon at top; input field shows real-time results; highlights matching terms  
**Key Insight:** Full-text search is the power-user path. Simple input + instant results beats complex filter chains.  
**Screenshot reference:** [Search field at top; results listed with matching term highlighted]  
**Dwellable adoption:** Full-text search interface for content search

### Bible App / YouVersion (Unified Discovery)
**Design Pattern:** Cross-platform search returning Bible passages, plans, devotionals, commentary all in one results view  
**Key Insight:** Context matters. When user searches "Love", they want *all* relevant content (verses, plans, commentary, etc.), not just one content type.  
**Screenshot reference:** [Search results showing verses, plans, devotionals in unified list]  
**Dwellable adoption:** Future unified discovery model; not v1 but architectural direction

---

## Technical Architecture

### Components

**DateFilterManager**
- Tracks selected month/date
- Filters entry list by calendar selection
- Handles month navigation (prev/next)
- Triggers entry list update on date change

**TagFilterManager**
- Maintains selected tags (array)
- Filters entry list by OR logic (any selected tag)
- Supports add/remove individual tag
- Clear all filters reset
- Returns count of matching entries

**PrayedStatusFilter**
- Enum: ALL | PRAYED | NOT_YET_PRAYED
- Filters entries by whether reflection/prayer exists (Response object linked to entry)
- Updates on status change

**FullTextSearchManager**
- Searches across: headline, body, tags, customMood fields
- Uses local full-text search (SQLite FTS or Supabase full-text search)
- Real-time results with debounce (300ms)
- Highlights matching terms in results (optional)
- Scope: user's moments only

**EntryListView (Updated)**
- Displays filtered results from all active filters (date + tags + prayed status + search)
- Combines filter conditions with AND logic (all filters apply simultaneously)
- Shows: headline, preview, date, metadata, tap to open detail

**AskYourEntriesManager (Future)**
- Generates embeddings for user's reflections (OpenAI/Hugging Face)
- Processes natural language queries
- Returns semantic matches + summary response
- Status: Phase 2.1+

**UnifiedDiscoveryManager (Future)**
- Queries Dwellable reflection database
- Queries external APIs (Bible API, book/film databases)
- Merges results by relevance
- Deduplicates/ranks cross-platform results
- Status: Phase 2+

---

## Data Model

**Search/Filter Context (Session State):**
```
selectedDate: Date? (nil = show all dates)
selectedTags: [String] (array of tag IDs)
prayedStatus: FilterStatus (ALL | PRAYED | NOT_YET_PRAYED)
searchQuery: String (full-text search term)
```

**Entry Model (Updated):**
```
id: UUID
headline: String (searchable)
body: String (searchable)
tags: [String] (filterable)
mood: String (searchable)
customMood: String (searchable)
createdAt: Date (filterable by calendar)
hasReflection: Bool (derivable from Response.count)
```

**Response Model (Existing):**
```
id: UUID
momentId: UUID (links to Moment)
content: String
type: "prayer" | "prompt_response" (determines hasReflection)
createdAt: Date
```

---

## UI Screens (Implementation Phase)

| Screen | Purpose | Status |
|--------|---------|--------|
| **Search/Entries Home** | Calendar + filtered entry list + search bar | 🔲 Not Started |
| **Tag Filter Modal** | Searchable multi-select tag list | 🔲 Not Started |
| **Prayed Status Toggle** | Filter by reflection/prayer status | 🔲 Not Started |
| **Full-Text Search Results** | Live results as user types search query | 🔲 Not Started |
| **Entry Detail View (Updated)** | Show full entry + associated reflections + edit button | Already exists (update needed) |
| **Ask Your Entries (Future)** | AI query interface + natural language response | 🔲 Deferred to Phase 2.1 |

---

## Considered & Rejected

| Decision | Reasoning |
|----------|-----------|
| **Complex boolean search (AND/OR/NOT syntax)** | Too complex for casual users. Simple multi-select tag filtering (OR) is more discoverable. Advanced queries deferred to Phase 3. |
| **Saved searches/filters** | v1 simplicity. Users can re-apply filters quickly if needed. Saved filters (like Evernote) deferred to Phase 2+. |
| **Search suggestions / autocomplete** | Real-time debounced search is sufficient for v1. Autocomplete adds complexity; deferred to Phase 2. |
| **Social search (find other users' moments with tag X)** | Privacy-first design. Search is personal only. Social discovery deferred to Phase 3+ if ever. |
| **Faceted search (filter by date range, mood range, etc.)** | Overwhelms UI. Date picker + tag + prayed status is sufficient. Faceted search deferred to Phase 2+. |
| **Search ranking / relevance scoring** | v1: chronological or tag-match order. Relevance ranking (using embeddings) deferred to Phase 2.1+. |
| **Full-text search with AI reranking** | Overkill for v1. Local FTS is fast enough. AI reranking for Phase 2.1+ after embeddings ready. |

---

## Open Questions

| Question | Status | Next Step |
|----------|--------|-----------|
| **Should date filter default to today or show all?** | Locked for v1 (show all by default) | Validate through user testing; may change to "today first" if users want to see recent entries |
| **Should tag filtering use OR or AND logic?** | Locked for v1 (OR: any selected tag) | Consider AND logic (only entries with *all* selected tags) for Phase 2 if users request intersection queries |
| **How should search results be sorted if multiple filters active?** | Locked for v1 (chronological, newest first) | Later: add sort options (by date, by relevance, by mood) |
| **Should full-text search be case-insensitive?** | Locked for v1 (yes, case-insensitive) | No changes expected |
| **When should "Ask Your Entries" AI feature launch?** | Deferred to Phase 2.1 | Validate embeddings infrastructure + cost model before committing |
| **Which external APIs for unified discovery (Phase 2+)?** | In Progress — needs vendor evaluation | Research YouVersion (Bible), Google Books, OMDB (films), Spotify (music) API availability and licensing |
| **Should search include reflections/responses, or only original moments?** | Locked for v1 (yes, include reflections) | Searches across full entry + all associated responses |

---

## Top 5 Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| **Search performance degrades with large entry corpus (500+ entries)** | Search becomes sluggish; user experience deteriorates | Use indexed full-text search (SQLite FTS or Supabase pg_trgm); test with 1000+ entries; optimize queries |
| **Tag filter overwhelms with too many tags** | User can't find tag they want; filter UX unusable | Cap tag display to 50 most common; add search within tag filter; archive/hide stale tags in Phase 2 |
| **Users don't discover filtering features** | Calendar/tag/search exist but users scroll gallery instead | Prominent affordances (search icon, filter button); onboarding tutorial; help text on first visit |
| **Date filter logic confuses users** — unclear whether selected date filters or anchors view | User frustration; incorrect filtering | Clear visual feedback (highlight selected date; show "Showing entries from May 5" label) |
| **Full-text search returns too many irrelevant results** | User overwhelmed with results; search feels broken | Ranked results (by date, by match confidence); limit to 20 results; allow result refinement (add filters) |

---

## Blocking Dependency

**None explicit.** Pillar 5 (Search) can ship independently once entry data is stable (Pillar 4 + Pillar 3 must ship first so there's data to search).

---

## Intended Outcome

### Adoption Metrics
- **Search/Filter usage:** 70%+ of users use at least one search/filter method by week 2
- **Calendar discovery:** 60%+ of users browse by date at least once
- **Tag filtering:** 50%+ of users filter by tag at least once
- **Full-text search:** 40%+ of users perform keyword search
- **Prayed status filter:** 35%+ of users filter by reflection status

### Experience Metrics
- **Search discoverability:** 85%+ of users find search icon within first entry view
- **Filter clarity:** Users report "I easily found the moment I was looking for" (survey post-use)
- **Search speed:** Full-text search returns results in <500ms for typical corpus (500 entries)
- **Result relevance:** 80%+ of search results are relevant to user's query

### Behavioral Outcomes
- Users re-engage with older moments through search/discovery
- Patterns emerge (temporal, thematic) from filter usage
- Users return weekly not just to capture, but to search/reflect on past moments
- Search enables "dwelling on a theme" (e.g., "show me all Healing moments from the past month")

---

## What's NOT Included (Deferred to Phase 2+)

❌ AI-powered "Ask Your Entries" query interface  
❌ Semantic search / embeddings-based discovery  
❌ Unified cross-platform discovery (Bible, books, films)  
❌ Saved searches / filter presets  
❌ Advanced boolean search (AND/OR/NOT syntax)  
❌ Faceted search (filter by date range, mood range, etc.)  
❌ Search result ranking / relevance scoring  
❌ Search suggestions / autocomplete  
❌ Social search (find other users' moments)  
❌ Search history / recent searches  

These are explicitly deferred and will only be considered if Phase 2 (Search v1) succeeds via adoption metrics.

---

## Implementation Tickets (Not Started)

- **T-071:** Calendar date filter + entry list integration
- **T-072:** Tag filter modal + multi-select logic
- **T-073:** Full-text search interface + real-time results
- **T-074:** Prayed status filter + reflection linking

---

**Reference:** See `PILLAR_4_EDITING_STRATEGY.md` for tags/moods that feed into search; see `PILLAR_3_SOAKING_STRATEGY.md` for reflection data model; see `PILLAR_6_MENU_BAR_STRATEGY.md` (forthcoming) for navigation context.

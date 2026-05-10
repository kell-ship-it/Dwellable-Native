# Pillar 5: Search — Query & Discover Reflections — Architectural Design Skeleton

**Status:** 🔄 Architectural Design Complete, Implementation Not Started (T-071, T-072, T-073, T-074)  
**Last Updated:** May 10, 2026

---

## Formation Intelligence System

**What Pillar 5 Is:**  
Search & Discovery is the *discovery layer* of Formation Intelligence. Users revisit and re-examine moments, revealing what they're wrestling with, celebrating, and dwelling on over time.

**What P5 Learns:**  
Every search interaction is a formation signal. We learn:
- **Search themes:** What topics users return to (anxiety, gratitude, relationships, faith questions)
- **Temporal patterns:** When users search (after tough weeks, before decisions, during seasons)
- **Unresolved questions:** Searches without matching results reveal what users are seeking that they haven't yet captured
- **Re-dwelling patterns:** How often users revisit the same moment or theme (signals deep wrestling or celebration)
- **Recent searches:** History of searches reveals obsessions, preoccupations, spiritual concerns across time

Through search behavior, we understand the user's interior life better than any single capture could reveal.

**What P5 Communicates:**  
- "We understand you, and we are here for you" — Search results affirm that we've been listening and remembering
- "Your moments matter." — Making them findable celebrates their significance
- "You're not alone in this." — Discovering patterns in their own moments shows consistency and God's faithfulness
- "We're here to help you dwell." — Search enables re-engagement with moments for deeper reflection

**How P5 Prepares P6 (Formation Intelligence / Pattern Naming):**  
P5 collects the *behavioral signals* that P6 needs. Search interactions, recent searches, filter patterns—these feed into P6's ability to name themes with confidence. P6 says "You keep searching for moments about anxiety"—P5 made that visible first.

**Trust Principle (Cross-Pillar):**  
Search is foundational to trust. Accurate, fast search results that surface the moments users are looking for affirm that we understand them and have been faithfully recording their life. Slow search, irrelevant results, or missing moments breaks trust at the core level. Every search interaction is a trust moment.

**Search Intelligence (MVP Scope):**  
Although metadata is bounded (3D model only: Prayed × Mood × Object), search is still intelligent because it's contextual. We search based on:
- What we know about the user from P0 (their identity, intent, theological framework)
- What we know from P1 (their archetype: Jotter, Venter, Processor)
- Current moment content (what they just captured)
- Recent history (what they've been searching for)

Minimal data, maximum understanding: P5 searches are personalized because we know the dweller, not because we have unlimited metadata.

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

#### 3. **Object Filter (Single Select)**
- **Trigger:** Tap "Filter by Object" or category icon
- **Interface:** Modal/sidebar with Object category list
- **Options:** Family | Romance | Career | Health | Spiritual | Other
- **Behavior:**
  - User can select one Object category at a time (shows all moments in that domain)
  - User can clear filter to see all Objects
  - Category count shows how many entries match
- **Combined with Date & Prayed Status:** User can filter by date *and* object *and* prayed status simultaneously
- **Design Pattern:** Apple Mail (category-based organization)

#### 4. **Prayed Status Filter**
- **Purpose:** Distinguish moments by engagement level (whether user has prayed/responded)
- **Options:**
  - All entries (default)
  - Prayed (user has prayed over or reflected on the moment)
  - Not Yet Prayed (captured but not yet prayed over)
  - Reflecting (user actively revisiting and exploring the moment)
- **Logic:** Prayed status tracks user engagement depth with each moment
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

#### 6. **Recent Searches**
- **Purpose:** Quick access to recently searched queries, themes, or objects
- **Trigger:** Tap search field (shows recent search history)
- **Display:** List of last 5-10 searches (objects, moods, keywords)
- **Behavior:**
  - User can tap recent search to re-run it
  - Each recent search shows what was searched + when
  - Swipe to remove individual searches from history
  - "Clear all" option to reset history
- **Formation Intelligence Signal:** Reveals what themes user revisits, what they're wrestling with, temporal search patterns
- **Design Pattern:** iOS Search, Google Search

#### 7. **Ask Your Entries (Future v1.1)**
- **Button:** "Ask Your Entries" prompt at top
- **Purpose:** AI-powered query across all reflections
- **Example Queries:** "What themes show up most in my reflections?" / "When do I feel most at peace?" / "How has my faith evolved?"
- **Response:** Natural language summary + relevant matching entries
- **Status:** Deferred to Phase 2.1 (after v1 search + tagging mature)
- **Tech:** Requires embeddings + semantic search on user's reflection corpus

---

### Phase 2+: Semantic Discovery (Future)

#### 8. **Unified Discovery (Cross-Platform)**
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
| **Complex boolean search (AND/OR/NOT syntax)** | Too complex for casual users. Simple multi-select tag filtering (OR) is more discoverable. Advanced queries deferred to Post MVP. |
| **Saved searches/filters** | v1 simplicity. Users can re-apply filters quickly if needed. Saved filters (like Evernote) deferred to Phase 2+. |
| **Search suggestions / autocomplete** | Real-time debounced search is sufficient for v1. Autocomplete adds complexity; deferred to Phase 2. |
| **Social search (find other users' moments with tag X)** | Privacy-first design. Search is personal only. Social discovery deferred to Post MVP if ever. |
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

## Post-MVP Feature: Notating Answered Prayers

### Concept

Users should be able to mark prayers as "answered" after they've been prayed over, creating a record of God's work in their life.

**Flow:**
1. User views an old moment with "Prayed" status
2. Sees affordance: "Mark prayer as answered"
3. Taps to mark prayer with answer date + optional note ("How God answered this")
4. Answered prayer now searchable/filterable as a distinct category
5. Formation Intelligence (P6) can surface patterns in answered prayers

**Why This Matters:**
- Celebrates God's faithfulness (spiritual formation signal)
- Creates a dwelling place not just for the prayer, but for the answer
- Enables reflection on God's timing and methods
- Builds evidence of formation over time

### Potential Pillar Placement (TBD)

This feature could belong to:
- **P3 Extension** — Prayers are attached here; marking answers is part of the prayer lifecycle
- **P6 Extension** — Formation Intelligence could detect themes in answered prayers and celebrate patterns ("You've seen 7 prayers answered about Career in 2026")
- **P8 Extension** — Notifications could celebrate answered prayers or remind users to check if prayers were answered
- **Standalone Post-MVP** — Could be its own feature requiring deeper architecture (answer tracking, prayer lifecycle states)

**Recommendation:** Document across P3, P6, P8 strategy docs as a potential enhancement after MVP validation. Decision on final pillar placement deferred to Post-MVP planning.

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

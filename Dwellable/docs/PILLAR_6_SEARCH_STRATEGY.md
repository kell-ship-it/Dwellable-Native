# Pillar 6: Search & Discovery (Query & Explore Moments) — Strategy & Design Skeleton

**Status:** 🔄 **DESIGN IN PROGRESS** (T-074+)  
**Last Updated:** May 10, 2026

---

## Design Summary

Pillar 6 is the **discovery layer** of Dwellable's Formation Intelligence system. It enables users to find and re-engage with moments through multiple search/filter pathways (date, tags, moods, full-text search). More importantly, it reveals patterns in the user's spiritual story that were invisible in real-time capture.

Discovery transforms moments from isolated entries into a searchable archive where users can:

1. **Find themselves again** — relive moments from specific seasons
2. **See patterns emerge** — notice recurring themes across time
3. **Understand formation** — watch their spiritual journey unfold chronologically

---

## Formation Intelligence — What Pillar 6 Is & Learns

### What Pillar 6 Is (in the Formation Intelligence System)

**A discovery + pattern-revealing layer.**

| Pillar | Role |
|--------|------|
| **P0 (Onboarding)** | Establishes foundation: identity + theological framework |
| **P1 (Capture)** | Captures raw moment + infers archetype |
| **P2 (Security)** | Protects moments so P3+ can use rich context confidently |
| **P3 (Soaking)** | Seals moment with prayer — signals value to God |
| **P4 (Journal Creation)** | Synthesizes moment into narrative dwelling place |
| **P5 (Editing)** | Personalizes narrative — user claims ownership |
| **P6 (Search & Discovery)** | *Reveals* patterns across time. Shows formation happening. |

### What P6 Learns About the User

P6 learns through *search behavior* and *discovery patterns*:

1. **Temporal Patterns:** When does the user return to moments? Which seasons get revisited? (Signals what matters across time)
2. **Thematic Interests:** Which tags do they search for most? What moods dominate certain periods? (Signals spiritual focus evolution)
3. **Discovery Paths:** Do they browse by date? Filter by tag? Use full-text search? (Signals how they make meaning of their story)
4. **Re-engagement Triggers:** What causes them to search/browse? Do patterns shift seasonally? (Signals formation rhythm)
5. **Pattern Recognition:** Do they notice that "Anxiety + Prayer" moments are followed by "Grateful + Peace"? (Signals spiritual awareness growth)

### What P6 Communicates to the User

**Profound signal: Your life has a pattern. You're growing.**

1. **"Time reveals formation."**
   - By searching, users see that anxious seasons pass. Grateful seasons return. Themes evolve.
   - Discovery is proof of spiritual transformation.

2. **"Your story is connected."**
   - Searching "Healing" returns 12 moments across 6 months. User sees: *"I've been walking this path longer than I realized. I'm not starting from zero."*
   - Pattern visibility = continuity = formation.

3. **"You can learn from yourself."**
   - *"In August I prayed about this. In October it resolved. What did I learn?"*
   - Discovery enables the user to be their own spiritual director.

### How P6 Prepares P7 (Formation Intelligence / Themes)

**P7 cannot reveal themes without P6's infrastructure.**

Example (P7 future behavior):
- *"Over the past 3 months, you've tagged 15 moments 'Anxiety'. You've also added the custom mood 'Uncertain' 8 times. These moments happen on Mondays + Thursdays. Is there a pattern you notice?"*

This is only possible if:
1. P5 enabled precise tagging (headlines, moods)
2. **P6 created search infrastructure** to find those moments by tag/date/mood
3. P7 can now analyze patterns with confidence

**P6 removes discovery friction:** By making search easy and results discoverable, P6 proves to the user that patterns exist — setting up P7 to *name* those patterns.

---

## Core Design Decisions — Locked

### Happy Paths (6 Main Paths)

1. **Browse by Date:** User opens calendar → selects month/date → sees moments from that period
2. **Filter by Tags:** User opens tag filter → selects 1-2 tags → sees all moments with those tags
3. **Filter by Mood:** User filters by emotional/spiritual mood → discovers mood-based patterns
4. **Filter by Reflection Status:** User shows only moments "with prayer" vs. "not yet prayed" → sees engagement patterns
5. **Full-Text Search:** User searches keyword (e.g., "healing") → gets real-time results across headlines + body
6. **Combined Filters:** User combines date + tag + mood filters simultaneously → discovers intersections (e.g., "All 'Anxiety' moments from January-March")

### Discovery Interface

**Calendar View (Date-Based Discovery)**
- Month view at top with all days visible
- Days with entries marked (bold, highlight, or dot)
- Previous/Next arrows navigate months
- Tap date → filters entry list to show only entries from that day

**Entry List (Filtered Results)**
- Vertical scrollable list showing filtered moments
- Per entry: headline, preview text (first 50 words), date, tags, mood indicator
- Tap entry → opens full detail view
- List updates as user changes filters (real-time responsiveness)

**Tag Filter (Multi-Select)**
- Modal/sidebar with searchable tag list
- User can select multiple tags (OR logic: show entries with any selected tag)
- Shows count of matching entries
- Can combine with date + mood + search simultaneously

**Mood Filter**
- Filter by preset emoji moods or custom mood text
- Shows which moods are most common across user's archive
- Can combine with tag + date filters

**Full-Text Search**
- Search icon + input field at top of screen
- Searches across: headlines, journal body, tags, custom moods
- Real-time results (debounced, 300ms)
- Results highlighted with matching terms
- Scope: user's moments only (no cross-user search)

---

## Technical Architecture

### Search & Filter Pipeline

```
User opens Search/Discovery home
    ↓
Calendar view shown (month selected by default)
    ↓
User can:
  - Tap date in calendar (date filter)
  - Tap filter icon (tag/mood/status filters)
  - Tap search icon (full-text search)
    ↓
All filters apply simultaneously (AND logic)
    ↓
Entry list updates with matching results
    ↓
Tap entry → opens detail view (shows full journal + associated prayers)
```

### Key Components

**DateFilterManager**
- Tracks selected month/date
- Filters entry list by calendar selection
- Handles month navigation (prev/next)
- Default: show all dates (user can select to narrow)

**TagFilterManager**
- Maintains selected tags (array)
- Filters entry list by OR logic (any selected tag)
- Supports add/remove individual tag
- Returns count of matching entries
- Searchable tag list (helps discover tags)

**MoodFilterManager**
- Filters entries by selected mood (preset or custom)
- Shows mood frequency distribution (helps users see patterns)
- Can combine with tag + date filters

**ReflectionStatusFilter**
- Enum: ALL | WITH_PRAYER | WITHOUT_PRAYER
- Filters by whether linked prayer/reflection exists
- Helps users see engagement patterns

**FullTextSearchManager**
- Searches across: headline, body, tags, customMood
- Uses indexed full-text search (SQLite FTS or Supabase pg_trgm)
- Real-time results with debounce (300ms)
- Highlights matching terms in results
- Scope: user's moments only
- Returns results sorted chronologically (newest first)

**EntryListController**
- Displays filtered results from all active filters
- Combines filter conditions with AND logic
- Shows: headline, preview, date, metadata
- Tap to open detail view
- Responsive: updates immediately as filters change

---

## Data Model & Search Index

### Search Context (Session State)

```swift
struct SearchFilter {
    var selectedDate: Date?              // nil = show all dates
    var selectedTags: [String]           // Array of tag IDs (OR logic)
    var selectedMood: String?            // Preset or custom mood filter
    var reflectionStatus: FilterEnum     // ALL | WITH_PRAYER | WITHOUT_PRAYER
    var searchQuery: String?             // Full-text search term
}
```

### Searchable Fields (Entry Model)

- `headline` — user-edited journal title
- `body` — LLM-synthesized journal text + user edits
- `tags` — user-selected tags
- `customMood` — user-defined mood text
- `createdAt` — timestamp (for date filtering)
- `hasReflection` — boolean (derived from linked Prayer object count)

### Search Index

**Full-Text Index:**
- Built on: headline + body + tags + customMood
- Indexed via SQLite FTS (on-device) or Supabase PostgreSQL full-text search
- Encrypted search: index itself is encrypted (searchable only on authenticated device)

**Tag Index:**
- Maintains frequency count (how many moments per tag)
- Helps UI show popular tags first

**Mood Index:**
- Frequency distribution (helps reveal mood patterns to user)

---

## Security & Encryption

**Encryption Impact:**
- All searchable fields encrypted (headlines, bodies)
- Search index itself encrypted (searchable only on authenticated device)
- No plaintext search data stored on server
- Full-text search decrypts data on-device before indexing

**Privacy:**
- All search happens in user's encrypted context (no server-side search)
- Search queries are never logged/stored
- Search results visible to user only

---

## Success Metrics (P6)

### Formation Intelligence Perspective
- ✅ Users discover search/filter features: 70%+ use at least one method by week 2
- ✅ Calendar browsing: 60%+ browse by date at least once
- ✅ Tag filtering: 50%+ filter by tag
- ✅ Full-text search: 40%+ perform keyword search
- ✅ Pattern recognition emerging: Users report noticing themes (survey feedback)
- ✅ Re-engagement via search: >50% of users return weekly to search/browse (not just capture)

### Technical Perspective
- ✅ Search speed <500ms for typical corpus (500 entries)
- ✅ 80%+ search result relevance (users finding what they look for)
- ✅ Full-text index working with encrypted data
- ✅ No performance degradation up to 1000+ entries

---

## Open Questions & TBD

1. **Should search default to showing all dates or recent-first?** (TBD)
   - Current: show all by default (user can filter)
   - Alternative: show recent entries first, allow expand to see older
   - User testing needed

2. **Tag Filter Logic — OR vs AND?** (Locked: OR for v1)
   - v1: OR logic (show entries with *any* selected tag)
   - Future: Consider AND logic (only entries with *all* selected tags) if users request intersection

3. **Search Result Ranking?** (TBD)
   - v1: chronological (newest first)
   - Future: relevance ranking, configurable sort (by date, by relevance, by mood)

4. **Advanced Search Syntax?** (Deferred to v2)
   - Boolean operators (AND, OR, NOT)? Too complex for v1
   - Defer to Phase 2+ if users request

5. **"Ask Your Entries" AI Query?** (Deferred to Phase 2.1)
   - Natural language query: *"What themes show up in my reflections?"*
   - Requires embeddings + semantic search
   - Valuable but deferred until search v1 matures

---

## Considered & Rejected

| Decision | Reasoning |
|----------|-----------|
| **Complex boolean search syntax** | Too complex for casual users. Simple tag filtering (OR) more discoverable. |
| **Saved searches / filter presets** | v1 simplicity. Users can re-apply filters quickly if needed. Deferred to v2. |
| **Search suggestions / autocomplete** | Real-time debounced search sufficient. Autocomplete adds complexity. |
| **Social search** | Privacy-first design. Search is personal only. Social features deferred. |
| **Faceted search** | Overwhelming UI. Date + tag + mood sufficient. Faceted search deferred to v2+. |
| **AI search ranking** | Local FTS fast enough for v1. AI reranking deferred to v2.1+ after embeddings ready. |

---

## Integration Points with Other Pillars

| Pillar | Integration |
|--------|-----------|
| **P1 (Capture)** | User can navigate from Search back to original moment (Entry tab). |
| **P4 (Journal Creation)** | Searching returns synthesized journals. Journal headlines + text searchable. |
| **P5 (Editing)** | Tags + moods edited in P5 become the primary filters in P6. Search depends on P5's metadata precision. |
| **P7 (Formation Intelligence)** | P7 analyzes patterns discovered in P6. User discovers "12 Anxiety moments"; P7 then says: "I notice this pattern..." |

---

## Next: How P6 Prepares P7

Once P6 is implemented, P7 (Formation Intelligence / Themes) can be articulated as:
- **What P7 is:** A pattern-naming layer that uses P6's search infrastructure to surface themes
- **What P7 learns:** Which patterns matter to the user (derived from what they search for, which results they return to)
- **How P7 prepares future pillars:** By naming patterns, P7 enables P8 (Beta/Marketing) to communicate user success and spiritual growth

---

**Ready to lock P6 Formation Intelligence and move to P7?**

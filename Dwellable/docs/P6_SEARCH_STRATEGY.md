# Pillar 6: Search & Discovery — Strategy & Design Specification

**Founder:** Kell Golden | **Status:** Design In Progress | **Updated:** May 7, 2026

---

## What We're Building

Pillar 6 enables users to find and revisit moments and journals across their entire history. Users can perform full-text search across moment transcripts and journal bodies, filter by date range/moods/themes, and browse search results with context. The core principle: make re-engagement effortless by surfacing relevant moments when users want to revisit or explore their story.

---

## Happy Paths

### Path 1: Full-Text Search

**Scenario:** User wants to find moments related to a specific topic (e.g., "doubt", "breakthrough", "relationship").

1. **From Home Screen** → User taps search icon (magnifying glass) in header or bottom nav
2. **Search Input** → User sees search field with placeholder "Search moments & journals..."
3. **Type Query** → User types keyword (e.g., "doubt") or phrase (e.g., "relationship with mom")
4. **Real-Time Results** → Results appear as user types (or after tapping search)
5. **View Search Results** → List shows moments/journals matching query, with preview snippet
6. **Tap Result** → User taps result to open full moment/journal detail view
7. **Returns to Search** → User can refine search or continue browsing results

---

### Path 2: Filter by Date Range

**Scenario:** User wants to revisit moments from a specific time period (e.g., "past month", "July 2026").

1. **From Search Results** → User taps "Filter" button to expand filter options
2. **Select Date Range** → User chooses preset (Past week, Past month, Past 3 months) OR custom date picker
3. **Filter Applied** → Results narrow to matching date range
4. **View Filtered Results** → Shows moments/journals from selected timeframe
5. **Combine with Search** → User can type search query + apply date filter simultaneously

---

### Path 3: Filter by Mood/Theme

**Scenario:** User wants to find moments where they felt "hopeful" or "conflicted" or moments tagged with a particular theme.

1. **From Search Results** → User taps "Filter" to expand filter options
2. **Select Moods/Tags** → User sees mood palette (Reflective, Conflicted, Exhausted, Hopeful, Loved, Prayerful, etc.)
3. **Choose Multiple** → User can select multiple moods (checkboxes)
4. **Filter Applied** → Results narrow to moments/journals with selected moods
5. **View Filtered Results** → Shows matching moments
6. **Combine Filters** → User can combine mood + date + search simultaneously

---

### Path 4: Browse by Date (Chronological Gallery)

**Scenario:** User wants to casually browse moments from oldest to newest (or newest to oldest) without searching.

1. **From Home/Search Screen** → User taps "Gallery" or "Timeline" view (alternate view mode)
2. **See Chronological List** → Moments/journals displayed in reverse chronological order (newest first)
3. **Scroll to Browse** → User scrolls through moments, seeing date headers ("May 2026", "April 2026", etc.)
4. **Tap Moment** → User taps a moment to open detail view
5. **Return to Gallery** → User can continue browsing or switch back to list view

---

### Path 5: Saved/Pinned Moments

**Scenario:** User wants to mark certain moments as favorites to return to them easily.

1. **From Moment Detail View** → User sees heart/star icon in header
2. **Tap to Pin** → User taps heart to save/pin moment (toggles between pinned/unpinned)
3. **Pin Confirmed** → Visual feedback (heart fills in)
4. **View Pinned Moments** → User can filter by "Pinned" or see "Favorites" view
5. **Saved Across Sessions** → Pinned status persists

---

### Path 6: Search by Sense of Lord (Optional)

**Scenario:** User wants to find moments where they sensed God's presence or had particular spiritual insights.

1. **From Search/Filter Options** → User taps "Sense of Lord" filter (if data exists)
2. **Filter by Presence** → Shows moments that have "senseOfLord" field populated
3. **View Results** → Lists moments with spiritual reflections
4. **Combine with Other Filters** → User can filter by "sense of Lord" + date + mood simultaneously

---

## Locked Decisions

1. ✅ **Full-Text Search:** Implement across moment transcripts AND journal bodies (both searchable)
2. ✅ **Encryption-Aware Search:** Use encrypted search index (searchable without decrypting entire library)
3. ✅ **Real-Time Results:** Show results as user types (or debounce to reduce load)
4. ✅ **Result Context:** Display snippet of matching text + metadata (date, moods)
5. ✅ **Filter Combination:** Support AND logic (mood + date + search all apply together)
6. ✅ **Sort Options:** Default sort = newest first; allow toggle to oldest first
7. ✅ **Deleted Items:** Exclude soft-deleted moments/journals from search results (filter by `deleted: false`)
8. ✅ **Encryption:** Search index is encrypted or uses privacy-preserving indexing (no plaintext index on server)

---

## Tentative Decisions (TBD by Designer)

1. ❓ **Saved Searches:** Should users be able to save frequently-used searches? (Recommend: defer to Phase 3)
2. ❓ **Search History:** Should we track user's search history? (Recommend: no, privacy concern)
3. ❓ **Gallery View:** Should we include visual gallery mode (showing generated images)? (Recommend: defer to Phase 3)
4. ❓ **Semantic Search:** Should Phase 2 include semantic/meaning-based search or just full-text? (Recommend: full-text only for MVP)
5. ❓ **Search Results Limit:** How many results show by default before pagination? (Recommend: 20 results with infinite scroll or pagination)

---

## Open Questions (Deferred)

- Semantic search (AI-powered meaning search) — Phase 3+
- AI-powered recommendations ("You might also like...") — Phase 3+
- Social/collaborative search — post-launch
- Advanced filters (by prayer type, reflection frequency, etc.) — Phase 3+
- Export/download search results — Phase 3+

---

## Success Metrics

- Search adoption: >50% of users perform at least one search per month
- Search latency: <200ms for results to appear
- Filter adoption: >30% of searches use filters
- Result relevance: >4.0/5.0 user satisfaction with search results (survey)
- Search success rate: >80% of users find what they're looking for within 3 searches

---

## Integration Points with Other Pillars

- **Pillar 1 (Capture):** Search across captured moments (full transcript)
- **Pillar 4 (Journal Creation):** Search across synthesized journals (title + body)
- **Pillar 5 (Editing):** Exclude soft-deleted items from search results
- **Pillar 7 (Formation Intelligence):** Surface themes in search filters; allow filtering by theme
- **Pillar 3 (Soaking):** Link to prayer responses if available

---

## Technical Considerations

### Search Index Architecture

```swift
struct SearchableContent: Codable {
    let momentId: String                        // Reference to original moment
    let journalId: String?                      // Reference to journal (if exists)
    let fullText: String                        // Concatenated searchable content
    let dateCreated: Date                       // For date range filtering
    let moods: [String]                         // For mood filtering
    let senseOfLord: String?                    // For spiritual content filtering
    let isDeleted: Bool                         // Exclude deleted items
    let isPinned: Bool                          // For favorites filtering
    let lastUpdated: Date                       // For index freshness
    let encryptedIndex: Data?                   // Encrypted search index (optional)
}
```

### Encryption Implications

- Search index must be encrypted (to avoid plaintext exposure)
- Two approaches: (a) Encrypt full searchable content, or (b) Use privacy-preserving hashing for index
- Recommend approach (a) for MVP: encrypt index, decrypt on-device for search

### Database Queries

- Index moments and journals in Postgres with FTS (Full Text Search)
- Use RLS to ensure users only search their own content
- Create efficient indexes on `dateCreated`, `moods`, `deleted` fields

---

## Next Steps

1. Designer to finalize search UI mockups (search field, results list, filters)
2. Engineer to scope search index implementation (encrypted FTS)
3. Determine filter priority order (date vs mood vs sense of Lord)
4. Create implementation tickets with effort estimates

---

## Success Criteria for Design Lock

- ✅ Happy paths documented and reviewed
- ⏳ Mockups created for search screen and filter options
- ⏳ Data model for searchable content finalized
- ⏳ Implementation tickets created with effort estimates
- ⏳ Error states documented (no results, search timeout, offline search)

# Pillar 5: Search & Discovery — Design Skeleton

**Status:** ✅ Design Complete (6 scenarios, ~14 Figma screens, all confirmed via Claude Artifact before Figma), Implementation Not Started (T-128, T-177)
**Last Updated:** August 27, 2026 (full rewrite — supersedes the May 10, 2026 version below, which described a since-cut Prayed/Object filter model and Soaking-era references)

---

## What Changed From the May 10, 2026 Version (Read This First)

The prior version of this doc assumed an architecture that no longer exists:

- ❌ **Prayed status filter** — cut. Prayer (Pillar 3) is Post-MVP with zero integration into Pillar 4's journal model; there is no `hasPrayed`/prayed-status field on a journal entry to filter by.
- ❌ **Object filter** (Family/Romance/Career/Health/Spiritual/Other) — cut. This field doesn't exist in Pillar 4's actual data model (P4 dropped the Object field entirely — see T-154, marked ⚪ Dropped).
- ❌ **"Soaking"** terminology — renamed to "Prayer" project-wide back on July 20, 2026 (see `docs/MEMORY.md`'s permanent naming change entry). Any "Soaking" reference below this line is historical.
- ❌ **Tag multi-select (OR logic)** as its own filter axis — cut. P5 doesn't have a separate tag system; it reuses P4's single **Mood** taxonomy (8 preset + 1 custom, single-select for search purposes).
- ✅ **What's locked instead:** Search filters are **Mood (single-select) + free-text only**. Search runs **fully offline** against already-synced local data. **Pending entries are excluded from search entirely** — not indexed, never appear in results (still reachable by scrolling the Entries list).

---

## Formation Intelligence System

**What Pillar 5 Is:**
Search & Discovery is the *discovery layer* of Formation Intelligence. Users revisit and re-examine moments, revealing what they're wrestling with, celebrating, and dwelling on over time.

**What P5 Learns:**
- **Search themes:** What topics users return to (anxiety, gratitude, relationships, faith questions)
- **Temporal patterns:** When users search (after tough weeks, before decisions, during seasons)
- **Unresolved questions:** Searches without matching results reveal what users are seeking that they haven't yet captured
- **Re-dwelling patterns:** How often users revisit the same moment or theme
- **Recent searches:** History of searches reveals obsessions, preoccupations, spiritual concerns across time

**How P5 Prepares P6 (Formation Intelligence):**
P5 collects the *behavioral signals* that P6 needs. Search interactions, recent searches, filter patterns feed into P6's ability to name themes with confidence.

**Trust Principle (Cross-Pillar):**
Search is foundational to trust. Accurate, fast search results that surface the moments users are looking for affirm that we understand them and have been faithfully recording their life.

**Search Intelligence (MVP Scope):**
Metadata is intentionally minimal — **Mood only** (no Object, no Prayed status). Search is still personal/contextual because it's scoped to the user's own moments and reflects what they've actually captured, not because of a large metadata surface.

---

## Locked Design (Aug 27, 2026)

### Screen 1 — Calendar + Entries List

Untold-style month calendar at top + vertical entry list below, matching Pillar 6's real tab structure (**Today / Entries / Growth** — Capture is not a tab, it's a floating action).

- **Pending entries** shown via a small pulsing "Pending" tag on their list row.
- **Approved entries carry no status label at all** — absence *is* the Approved state (Kell's explicit correction; don't invent a "Approved" badge to mirror the Pending one).
- **Header:** tab bar is the real locked 3-tab set (Today/Entries/Growth). A floating "+" (Capture) merges into one pill together with the search icon and a profile icon (referencing the Journey app's header pattern). The "+" icon matches the real locked Pillar 6 `HeaderPlusButton` component exactly — thin gold stroke, not a bold glyph.
- **Tab bar treatment:** translucent/blurred floating pill (iOS's native tab-bar treatment), list scrolls fully underneath it — not a solid opaque block that clips content.
- Tapping an entry or the magnifying glass both **push** a new screen in from the right (NavigationStack, back-arrow to return) — they're destinations you navigate to.
- Tapping "+" **slides Capture up** from the bottom as a modal (✕ to dismiss) — it's creating something new, deliberately a different gesture from push navigation.

### Screen 2 — Search

Five states, all confirmed via Claude Artifact:

1. **Idle** — Recent Searches list, per-item removal and "Clear all," both instant with no confirmation modal (search history isn't user content worth protecting behind a confirm step).
2. **Real-time typed results** — matching text highlighted in gold, Mood filter combined with free-text via AND logic.
3. **No-results** — a reassuring empty state, not blank space.
4. **One-recent-search-removed.**
5. **All-recent-cleared** — a quiet inline message, deliberately *not* a big illustrated empty state, since nothing of value was lost.

**Locked:**
- **Pending entries are excluded from search entirely** — not indexed, never appear in results, still reachable by scrolling the Entries list.
- **Search runs fully offline** against already-synced local data — no special offline state needed, consistent with P4's Edit/View/Delete offline-first precedent.
- Filters: **Mood (single-select) + free-text only.** No Prayed filter, no Object filter (see "What Changed" above).

### Delete (Reuses Pillar 4)

Delete-from-search reuses P4's already-locked View/⋯-menu/delete-confirmation screens rather than inventing new ones (4-step storyboard: List → View → Delete confirmation → List again, entry and its calendar dot both gone).

- **Recently Deleted lives in Settings** (new architecture call, Aug 27, 2026), not inside the Entries list itself — keeps the list showing only active entries. Tracked as **T-176** (Pillar 9).
- Confirmation copy (corrected to match P4 exactly): *"This entry will move to Recently Deleted in Settings and be permanently removed after 30 days. You can restore it before then."*

---

## Post-MVP: Full-Transcript Search

Searching raw capture transcripts (not just synthesized journal bodies) is explicitly deferred — tracked as **T-177** (Post-MVP backlog). MVP search scope is journal title/body + Mood only.

---

## Data Model (Corrected)

**Search/Filter Context (Session State):**
```
selectedMood: String? (nil = show all moods; single-select, drawn from P4's 8 preset + 1 custom Mood taxonomy)
searchQuery: String (free-text, matched against journal title + body)
```

**Journal Entry fields relevant to Search** (see `docs/P4_SUMMARY.html` for the full model):
```
id: UUID
title: String? (null while status == "pending" — excluded from search while pending)
body: String? (null while status == "pending" — excluded from search while pending)
moods: [String] (searchable/filterable, 2-3 per entry)
status: "pending" | "approved" (only "approved" entries are searchable)
starred: Bool
createdAt: Date (filterable by calendar in Screen 1)
```

There is no `hasPrayed`/prayed-status field and no Object field — both were part of the superseded model above.

---

## Competitor Research & Skeletal References (Unchanged From Prior Version)

### Untold (Calendar + Entry List)
**Design Pattern:** Month calendar picker at top; filtered entry list below; tap date to filter
**Dwellable adoption:** Calendar at top, entry list below — Untold's layout is the skeletal model for Screen 1.

### Apple Calendar & Notes (Full-Text Search)
**Design Pattern:** Search icon at top; input field shows real-time results; highlights matching terms
**Dwellable adoption:** Full-text search interface for Screen 2, gold highlight on matched terms.

### Bible App / YouVersion (Unified Discovery)
**Design Pattern:** Cross-platform search returning Bible passages, plans, devotionals, commentary all in one results view
**Dwellable adoption:** Future unified discovery model; not MVP, architectural direction only (Phase 2+, unchanged from before).

---

## What's NOT Included (Deferred to Phase 2+)

❌ AI-powered "Ask Your Entries" query interface
❌ Semantic search / embeddings-based discovery
❌ Unified cross-platform discovery (Bible, books, films)
❌ Saved searches / filter presets
❌ Advanced boolean search (AND/OR/NOT syntax)
❌ Full-transcript search (raw capture transcripts) — **T-177**
❌ Prayed-status filtering — cut entirely, not just deferred (Prayer has no P4/P5 integration in MVP)
❌ Object filtering — cut entirely, not just deferred (field doesn't exist in the data model)

---

## Implementation Tickets

- **T-128:** P5 Search — Screen 2 (Search Page: Filters + Keyword Query) — Mood single-select + free-text, offline, Pending-excluded
- **T-177:** Post-MVP — Full-Transcript Search (query raw capture transcripts)

---

**Reference:** See `docs/P4_SUMMARY.html` for the Mood taxonomy and journal entry data model this pillar searches over. See `docs/MEMORY.md` (Aug 27, 2026 session entries) for the full session narrative behind this rewrite. The Notion **"P5 User Scenarios & Acceptance Criteria"** page mirrors this doc's locked decisions as testable scenarios.

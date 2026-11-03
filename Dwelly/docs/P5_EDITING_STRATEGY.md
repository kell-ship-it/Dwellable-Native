# Pillar 5: Editing — Strategy & Design Specification

**Founder:** Kell Golden | **Status:** ✅ LOCKED | **Updated:** May 8, 2026

---

## What We're Building

Pillar 5 enables users to refine synthesized journals and manage their captures through deletion and recovery. Transcripts are read-only — the core principle is to encourage re-capture rather than editing. Users can edit only the synthesized journal title/body (post-synthesis), and soft-delete moments or journals with a 30-day recovery window via Trash view.

---

## Happy Paths

### Path 1: Edit Journal Title & Body (Post-Synthesis)

**Scenario:** User reads synthesized journal entry and wants to refine the title or body text to better capture their feeling.

1. **From Dwelling Place Tab** → User opens synthesized journal entry (detail view)
2. **Tap Edit Button** → "Edit Journal" button appears in detail view
3. **Edit Title** → User modifies auto-generated title (free text input)
4. **Edit Body** → User modifies synthesized body paragraphs (rich text editor)
5. **Save Edits** → Taps "Save Journal Changes"
6. **Mark as Edited** → System marks `edited: true` flag
7. **Returns to Dwelling Place** → User sees updated journal with changes reflected

---

### Path 2: Delete Moment (Soft Delete with Recovery Option)

**Scenario:** User decides a moment is no longer relevant or was captured in error, and wants to remove it.

1. **From Moments List or Detail View** → User taps "..." menu or swipes to reveal actions
2. **Tap Delete** → Confirmation dialog appears: "Delete this moment and its journal? You can recover it within 30 days."
3. **Confirm Delete** → User taps "Delete" in confirmation
4. **Soft Delete Applied** → System marks moment and its journal with `deleted: true`, sets `deletedAt: timestamp`
5. **Removed from Main View** → Moment and journal disappear from Moments List and search results
6. **Accessible via Trash** → Users can access "Trash" section to view and recover deleted items
7. **30-Day Retention** → After 30 days, permanently deleted from system

---

### Path 3: Delete Journal Entry (Soft Delete — Deletes Conversation Too)

**Scenario:** User wants to delete the synthesized journal and its associated conversation/transcript.

1. **From Dwelling Place Tab Detail View** → User taps "..." menu or swipes
2. **Tap Delete Journal** → Confirmation dialog: "Delete this journal and its conversation? You can recover it within 30 days."
3. **Confirm Delete** → User taps "Delete"
4. **Soft Delete Applied** → System marks journal AND its conversation/transcript with `deleted: true`, sets `deletedAt: timestamp`
5. **Removed from Both Views** → Journal removed from Dwelling Place; conversation removed from Moments List
6. **Accessible via Trash** → Recoverable within 30 days

---

### Path 4: Recover Deleted Moment/Journal

**Scenario:** User changed their mind and wants to restore a deleted moment or journal from trash.

1. **From Trash View** → User navigates to "Trash" or "Recently Deleted" section (Phase 2)
2. **View Deleted Items** → Shows moments/journals deleted in past 30 days with deletion date
3. **Tap Recover** → User selects item and taps "Recover"
4. **Restore Applied** → System marks `deleted: false`, clears `deletedAt`
5. **Reappears in Main View** → Moment/journal returns to Moments List and Dwelling Place

---

## Locked Decisions

1. ✅ **Transcripts are read-only.** Transcripts/conversations cannot be edited after capture. Re-capture is the intended path.
2. ✅ **Edit Scope:** Journal title/body only (post-synthesis, detail view only). No pre-synthesis editing, no re-synthesis in Phase 2.
3. ✅ **Journal Editability:** Detail view only — not inline from list view. Prevents accidental edits.
4. ✅ **Edited Flag:** Mark journals with `edited: true` so user knows they've modified the AI synthesis.
5. ✅ **Soft Delete Strategy:** Soft delete (flag + timestamp) rather than hard delete. 30-day recovery window.
6. ✅ **Delete Journal = Delete Conversation:** Deleting a journal also deletes its associated conversation/transcript. Nothing is preserved separately.
7. ✅ **Delete Moment = Delete Journal:** Deleting a moment also deletes its synthesized journal.
8. ✅ **Trash View in Phase 2:** Included in Phase 2 (Phase 2 is the final beta phase).
9. ✅ **Recovery Window:** 30 days from deletion date.
10. ✅ **Edit History:** Do NOT track edit history in Phase 2.
11. ✅ **Encryption:** Edits re-encrypt `encryptedContent`. Soft delete updates metadata flags only (fast).
12. ✅ **Sync:** Edits sync to cloud immediately (or queue if offline).

---

## Backlog (Future Features)

- **Edit Alerts:** Gentle nudge to re-capture instead of heavily editing — deferred, not in Phase 2 scope
- **Undo/Redo:** In edit view — deferred
- **Edit Timestamps:** Tracking when edits were made — deferred (keep simple)
- **Edit History:** Show original vs. current version — deferred
- **Version Control:** Too complex for Phase 2

---

## Open Questions (Deferred)

- Collaborative editing — post-launch only, if at all
- Pre-synthesis editing — out of scope for Phase 2

---

## Success Metrics

- Edit adoption rate: <10% of journals edited post-synthesis (indicates strong synthesis quality)
- Edit latency: Edits apply instantly (<500ms)
- Delete confidence: >70% user satisfaction with delete/recovery flow (survey)
- Soft delete recovery: <5% of deleted items actually recovered (indicates good deletion UX)

---

## Integration Points with Other Pillars

- **Pillar 1 (Capture):** Transcripts are read-only post-capture; re-capture is the editing path
- **Pillar 4 (Journal Creation):** Edit journal title/body in detail view only
- **Pillar 6 (Search & Discovery):** Soft-deleted items excluded from search results
- **Pillar 7 (Formation Intelligence):** Themes do not include deleted moments or journals

---

## Technical Considerations

### Data Model

```swift
struct MomentMetadata: Codable {
    let deleted: Bool
    let deletedAt: Date?
    let recoveryDeadline: Date?         // deletedAt + 30 days
}

struct JournalMetadata: Codable {
    let edited: Bool                    // Whether journal text was edited post-synthesis
    let editedAt: Date?
    let deleted: Bool
    let deletedAt: Date?
    let recoveryDeadline: Date?         // deletedAt + 30 days
}
```

### Encryption Implications

- Edits update `encryptedContent` (re-encrypt entire object)
- Soft delete updates metadata flags only (fast operation, no re-encryption needed)
- Recovery restores `deleted: false`, clears `deletedAt` (fast operation)

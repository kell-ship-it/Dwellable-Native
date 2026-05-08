# Pillar 5: Editing — Strategy & Design Specification

**Founder:** Kell Golden | **Status:** Design In Progress | **Updated:** May 7, 2026

---

## What We're Building

Pillar 5 enables users to refine their captured moments and synthesized journals. Users can edit the original moment transcript (before or after synthesis), edit synthesized journal title/body (detail view only post-synthesis), and permanently or soft-delete moments/entries. The core principle: encourage re-capture rather than endless editing.

---

## Happy Paths

### Path 1: Edit Moment Transcript (Pre-Synthesis)

**Scenario:** User captures a moment, reviews the transcript, and notices transcription errors or wants to clarify wording.

1. **From Capture Screen** → User taps "Review Transcript" or sees Review screen after voice→text conversion
2. **Edit Transcript** → User selects/edits text inline, corrects transcription errors
3. **Save Edits** → User taps "Save Edited Moment"
4. **Synthesis Triggered** → Journal synthesis begins with edited transcript (background)
5. **Returns to Moments List** → User sees moment in list, journal synthesis in progress

---

### Path 2: Edit Journal Title & Body (Post-Synthesis)

**Scenario:** User reads synthesized journal entry and wants to refine the title or body text to better capture their feeling.

1. **From Dwelling Place Tab** → User opens synthesized journal entry (detail view)
2. **Tap Edit Button** → "Edit Journal" button appears in detail view
3. **Edit Title** → User modifies auto-generated title (free text input)
4. **Edit Body** → User modifies synthesized body paragraphs (rich text editor)
5. **Save Edits** → Taps "Save Journal Changes"
6. **Mark as Edited** → System marks `edited: true` flag
7. **Returns to Dwelling Place** → User sees updated journal with changes reflected

---

### Path 3: Delete Moment (Soft Delete with Recovery Option)

**Scenario:** User decides a moment is no longer relevant or was captured in error, and wants to remove it.

1. **From Moments List or Detail View** → User taps "..." menu or swipes to reveal actions
2. **Tap Delete** → Confirmation dialog appears: "Delete this moment and its journal? You can recover it within 30 days."
3. **Confirm Delete** → User taps "Delete" in confirmation
4. **Soft Delete Applied** → System marks moment/journal with `deleted: true`, sets `deletedAt: timestamp`
5. **Removed from Main View** → Moment disappears from Moments List and search results
6. **Optional: Show Trash View** → Users can access "Trash" section to view deleted items (future)
7. **30-Day Retention** → After 30 days, permanently deleted from system

---

### Path 4: Delete Journal Entry (Soft Delete with Moment Preserved)

**Scenario:** User wants to delete the synthesized journal but keep the original moment (for re-journaling later).

1. **From Dwelling Place Tab Detail View** → User taps "..." menu or swipes
2. **Tap Delete Journal** → Confirmation dialog: "Delete this journal? Your original moment will be preserved."
3. **Confirm Delete** → User taps "Delete Journal"
4. **Soft Delete Applied** → System marks journal entry with `deleted: true`, sets `deletedAt: timestamp`
5. **Original Moment Preserved** → Moment remains in Moments List (moment not deleted, only journal)
6. **Returns to Moments List** → User can re-capture or re-synthesize the moment later if desired

---

### Path 5: Recover Deleted Moment/Journal (Optional - Future)

**Scenario:** User changed their mind and wants to restore a deleted moment or journal from trash.

1. **From Trash View** → User navigates to "Trash" or "Recently Deleted" section
2. **View Deleted Items** → Shows moments/journals deleted in past 30 days with deletion date
3. **Tap Recover** → User selects item and taps "Recover"
4. **Restore Applied** → System marks `deleted: false`, clears `deletedAt`
5. **Reappears in Main View** → Moment/journal returns to Moments List and Dwelling Place

---

## Locked Decisions

1. ✅ **Edit Scope:** Edit only transcript (before synthesis) and journal title/body (after synthesis). Do NOT allow re-synthesis of edited moment in Phase 2.
2. ✅ **Journal Editability:** Edit journal title/body in detail view ONLY (not from list view or inline). Prevents accidental edits.
3. ✅ **Edited Flag:** Mark journals with `edited: true` so user knows they've modified the AI synthesis.
4. ✅ **Soft Delete Strategy:** Use soft delete (flag + timestamp) rather than hard delete. Allows recovery within 30 days.
5. ✅ **Moment vs Journal:** Deleting a moment also deletes its journal. Deleting a journal preserves the moment (allows re-journaling).
6. ✅ **Edit History:** Do NOT track edit history in Phase 2. Too much overhead for minimal value.
7. ✅ **Encryption:** Edits apply to encrypted data. Update `encryptedContent` after edits.
8. ✅ **Sync:** Edits sync to cloud immediately (or queue if offline).

---

## Tentative Decisions (TBD by Designer)

1. ❓ **Trash View:** Should Phase 2 include a "Trash" view or defer to Phase 3? (Recommend: defer if constrained on time)
2. ❓ **Recovery Period:** 30-day recovery window or different timeline?
3. ❓ **Edit Alerts:** Should we alert user if they edit significantly after initial save (to encourage re-capture)?
4. ❓ **Undo/Redo:** Should edit view include undo/redo buttons? (Recommend: defer to Phase 3)
5. ❓ **Edit Timestamps:** Should we track when edits were made? (Recommend: no, keep simple)

---

## Open Questions (Deferred)

- Edit history timeline — should we show "original version" vs "current version"?
- Collaborative editing — post-launch only, if at all
- Version control — too complex for MVP; defer to Phase 3
- Pre-synthesis editing workflow — design flow where user edits transcript before synthesis even happens

---

## Success Metrics

- Edit adoption rate: <10% of moments edited post-capture (indicates good synthesis quality)
- Edit latency: Edits apply instantly (<500ms)
- Delete confidence: >70% user satisfaction with delete/recovery flow (survey)
- Soft delete recovery: <5% of deleted items actually recovered (indicates good deletion UX)

---

## Integration Points with Other Pillars

- **Pillar 1 (Capture):** Edit moment transcript immediately after capture (pre-synthesis)
- **Pillar 4 (Journal Creation):** Edit journal title/body in detail view only
- **Pillar 6 (Search & Discovery):** Soft-deleted items should be excluded from search results
- **Pillar 7 (Formation Intelligence):** Themes should not include deleted moments

---

## Technical Considerations

### Data Model Additions

```swift
struct MomentMetadata: Codable {
    let edited: Bool                    // Whether original transcript was edited
    let editedAt: Date?                 // Timestamp of last edit
    let deleted: Bool                   // Soft delete flag
    let deletedAt: Date?                // Timestamp of soft delete
    let recoveryDeadline: Date?         // 30 days from deletedAt
}

struct JournalMetadata: Codable {
    let edited: Bool                    // Whether journal text was edited post-synthesis
    let editedAt: Date?                 // Timestamp of last edit
    let deleted: Bool                   // Soft delete flag
    let deletedAt: Date?                // Timestamp of soft delete
    let recoveryDeadline: Date?         // 30 days from deletedAt
}
```

### Encryption Implications

- Edits update `encryptedContent` (re-encrypt entire object)
- Soft delete only updates metadata flags (fast operation)
- Recovery restores `deleted: false` (fast operation)

---

## Next Steps

1. Designer to finalize edit UI flows (screenshot mockups for edit detail view)
2. Determine Phase 2 scope: Trash view included or defer?
3. Create implementation tickets after happy path validation
4. Define error states: What if edit fails? Offline edit sync?

---

## Success Criteria for Design Lock

- ✅ Happy paths documented and reviewed
- ⏳ Mockups created for edit screens
- ⏳ Error state handling documented
- ⏳ Implementation tickets created with effort estimates

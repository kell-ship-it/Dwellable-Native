import SwiftUI
import PhotosUI
import UIKit

/// The real "Dwelling Place" reading screen (Pillar 4) — replaces the old, pre-dark-theme
/// `MomentDetailView` as the one place a saved moment is actually read. Rebuilt to match
/// Kell's approved reference mock exactly (Nov 10 2026): back chevron + star (favorite) +
/// ellipsis (more actions) in one top row; date left-aligned below that row, NOT centered;
/// serif title; mood tag pills; then body. Deliberately scoped down from the full locked
/// `Journal` artifact spec in `docs/PILLAR_4_JOURNAL_CREATION_STRATEGY.md` (no prayer link
/// or encrypted storage yet -- that's T-152/T-153, not started) to just what's real today,
/// laid out the way the approved design actually shows it.
///
/// Edit/menu chrome, hero photo, mood editing, and voice re-record (Nov 10 2026) are pulled
/// directly from the Figma file (t5MUGEtpeFcUixobvHiYMc, page "P4-Journal Synthesis",
/// Scenarios 2-8) rather than improvised -- see each piece's own comment below for what's
/// real vs. still a visual placeholder.
///
/// Honesty note that applies to the whole file: title/moods/scripture/starred now persist
/// for real via `JournalEntry` (T-152) -- loaded in `.task` below and written back on every
/// mood/star change and after a body edit. The one thing still genuinely local-only is the
/// hero photo (no Supabase Storage bucket or column exists for it yet).
struct JournalDisplayMeta {
    let title: String
    let moods: [String]
    // Nov 11 2026: the real synthesized narrative (optimistic, pre-`loadEntry()`) --
    // see `JournalDetailView.effectiveBody`'s own comment for why this is no longer
    // ever `moment.body` (the raw transcript) once synthesis has actually succeeded.
    let body: String?
    let scriptureQuote: String?
    let scriptureReference: String?

    init(title: String, moods: [String] = [], body: String? = nil, scriptureQuote: String? = nil, scriptureReference: String? = nil) {
        self.title = title
        self.moods = moods
        self.body = body
        self.scriptureQuote = scriptureQuote
        self.scriptureReference = scriptureReference
    }
}

/// Figma's full preset list (Mood Sheet, Scenario 7) -- same eight words shown across all
/// three mood-sheet variants in the file.
// Not `private` -- `JournalSynthesisManager` reuses this exact list (Nov 11 2026) so
// LLM-suggested moods match the manual picker's vocabulary instead of drifting from it.
let presetMoods = ["Peaceful", "Grateful", "Reflective", "Hopeful", "Conflicted", "Exhausted", "Prayerful", "Loved"]
private let maxMoods = 3
// Figma's custom-mood-word row (Mood Sheet, Scenario 7) caps input at 20 characters.
private let customMoodMaxLength = 20
// T-294 (Nov 16 2026, Kell's call): how many distinct custom mood words a user can
// accumulate in their shared vocabulary -- keeps the grid from growing unbounded.
let maxCustomMoods = 4

struct JournalDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.apiClient) private var apiClient
    let moment: Moment
    // Only needed to edit/delete -- `MomentsListView`'s own call site already has one;
    // `CaptureConversationView`'s onboarding call site passes its own. `nil` is fine for
    // read-only contexts (there are none left right now, but keeping it optional avoids
    // forcing every future call site to thread one through if a pure-reading entry point
    // is ever added).
    var syncManager: SyncManager? = nil
    var meta: JournalDisplayMeta? = nil
    // Set only when this screen is reached from the mandatory onboarding first
    // capture (`CaptureConversationView`'s own "Continue" button, not its
    // always-available inline "Open" link) -- same reasoning as that screen's
    // own `isOnboarding` flag: there's nothing to go back TO during onboarding,
    // so the back chevron is replaced with a real "Continue" the user taps once
    // they've actually read their first journal entry, instead of either a bare
    // dismiss or a silent auto-advance.
    var onDone: (() -> Void)? = nil

    // T-152: the persisted JournalEntry for this moment, loaded in `.task` below.
    // `meta` (passed straight from a just-finished capture, before the background
    // save in CaptureConversationView.finishAndSave necessarily completes) is the
    // optimistic fallback for title/scripture until `loadedEntry` arrives; once it
    // does, `loadedEntry` wins. `effectiveTitle`/`effectiveScripture*` below do that
    // merge so the rest of the view doesn't have to think about which source it's
    // reading from.
    @State private var loadedEntry: JournalEntry?
    @State private var isFavorited = false

    // Editing is scoped to exactly the one thing that's actually real and persisted
    // today: `moment.body`, via the SAME `apiClient.saveMoment` path
    // `CaptureConversationView.finishAndSave()` already uses, which the `save-moment`
    // Edge Function performs as a genuine `upsert(onConflict: "id")` -- confirmed by
    // reading that function directly, not assumed -- so saving the same `id` with new
    // text updates the existing row rather than creating a duplicate.
    @State private var isEditing = false
    @State private var editedBody: String
    @State private var displayBody: String
    @State private var isSaving = false
    @State private var saveErrorMessage: String?

    @State private var isDeleting = false
    @State private var showDeleteConfirmation = false
    @State private var deleteErrorMessage: String?

    // T-155's own spec: tapping ✕ with unsaved changes shows a confirm-discard
    // modal rather than discarding silently or blocking navigation (locked Aug 27,
    // 2026). "Unsaved" is scoped to the two fields edit mode actually lets you
    // change and keep unsaved: body text and moods -- a picked hero photo has no
    // saved/unsaved state of its own yet (no persistence at all, see this file's
    // top-of-file note), so it's not part of this check.
    @State private var showDiscardConfirmation = false

    // Moods (Figma Scenario 7, "Mood Sheet"): persisted for real via `loadedEntry`
    // (T-152). Seeded from `meta` optimistically, overwritten once the real entry loads.
    @State private var selectedMoods: [String]
    @State private var showMoodSheet = false
    @State private var customMoodText = ""
    // Kell caught this live (Nov 16 2026): tapping/typing inside the sheet mutated
    // `selectedMoods` immediately, so swiping the sheet away (anywhere but "Done")
    // still kept the change -- there was no way to back out. `draftMoods` is seeded
    // from `selectedMoods` when the sheet opens and only written back on "Done";
    // any other dismissal (swipe, tap outside) just discards the draft.
    @State private var draftMoods: [String] = []
    // T-294 (Nov 16 2026): the user's own mood vocabulary, shared across every entry --
    // loaded fresh every time the sheet opens so a word added on another entry (or
    // another device) shows up here too. New words typed into "Add your own word" are
    // held here as drafts and only actually written to `custom_moods` on "Done", same
    // draft/commit split as `draftMoods` itself -- swiping the sheet away without Done
    // shouldn't pollute the user's permanent mood vocabulary any more than it should
    // change this entry's own moods.
    @State private var customMoodsLibrary: [CustomMood] = []
    @State private var pendingNewCustomWords: [String] = []
    @State private var customMoodLimitMessage: String?
    // T-294: the custom mood pending the delete-confirm alert below (Kell's call,
    // Nov 16 2026 -- deleting is permanent for future entries, so it gets a confirm
    // step, same as Delete Entry / Delete Account elsewhere in this file).
    @State private var customMoodPendingDelete: CustomMood?
    // Kell caught this live (Nov 16 2026): "View Original Chat" did nothing at
    // all -- a plain `Button(action: {})`, per the old comment, because there's
    // no stored link to the real back-and-forth `CaptureConversationView`
    // transcript. That's still true (real scope, not done here), but
    // `moment.body` -- the user's own raw words, already loaded, right here --
    // is a genuine "original" to show instead of leaving the menu item inert.
    @State private var showOriginalChat = false

    // Hero photo (Figma Scenarios 4/5/8): session-local only, same reasoning -- no
    // Supabase Storage bucket or `moments` column for it yet (T-151, not started).
    // Uses the system photo picker and system camera rather than hand-rolling either,
    // which is both less work and more correct than recreating OS chrome Figma could
    // only mock up as static frames.
    @State private var heroImage: UIImage?
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var showCamera = false

    // Voice note re-record (Figma Scenario 6): this one IS real end-to-end -- reuses
    // the same `AudioRecordingManager` + `TranscriptionManager.shared` (WhisperKit)
    // pipeline `CaptureConversationView` already uses, so the transcript that comes
    // back is genuinely transcribed audio, appended into the edit text, not a stub.
    @StateObject private var voiceRecorder = AudioRecordingManager()
    @State private var isRecordingVoiceNote = false
    @State private var isTranscribingVoiceNote = false
    @State private var voiceNoteErrorMessage: String?

    init(moment: Moment, syncManager: SyncManager? = nil, meta: JournalDisplayMeta? = nil, onDone: (() -> Void)? = nil) {
        self.moment = moment
        self.syncManager = syncManager
        self.meta = meta
        self.onDone = onDone
        // Nov 11 2026: seeded from the real synthesized body when the optimistic
        // `meta` already has one (right after a capture that synthesized
        // successfully); `moment.body` (the raw transcript) is only ever the
        // fallback here -- before synthesis has a chance to run at all, or if it
        // never produced a body. `loadEntry()` below corrects this once the real
        // persisted entry loads, same pattern as title/moods/scripture.
        let initialBody = meta?.body ?? moment.body
        _editedBody = State(initialValue: initialBody)
        _displayBody = State(initialValue: initialBody)
        _selectedMoods = State(initialValue: meta?.moods ?? [])
    }

    private var hasUnsavedChanges: Bool {
        editedBody != displayBody || selectedMoods != (loadedEntry?.moods ?? (meta?.moods ?? []))
    }

    private func exitEditMode() {
        isEditing = false
        editedBody = displayBody
        selectedMoods = loadedEntry?.moods ?? (meta?.moods ?? [])
        saveErrorMessage = nil
    }

    // T-159: real pending/approved split. `loadedEntry` is the only source of truth
    // for this -- `meta` (optimistic, post-capture) never carries a pending status,
    // so a brand-new capture briefly shows the approved-looking optimistic view until
    // `loadEntry()` returns, same as title/scripture already do.
    private var isPending: Bool { loadedEntry?.status == "pending" }

    private var effectiveTitle: String? { loadedEntry?.title ?? meta?.title }
    private var effectiveScriptureQuote: String? { loadedEntry?.scriptureQuote ?? meta?.scriptureQuote }
    private var effectiveScriptureReference: String? { loadedEntry?.scriptureReference ?? meta?.scriptureReference }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let heroImage {
                        heroPhotoHeader(heroImage)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text(moment.createdAt.formatted(date: .abbreviated, time: .omitted).uppercased())
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.Payment.textSupporting)

                        if isPending {
                            pendingContent
                        } else {
                            approvedContent
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, isEditing ? 100 : 40)
                }
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            // Kell's direct ask: the bottom "Continue" CTA is gone, onboarding
            // included -- the top-left back chevron (always shown now, see below)
            // is the sole way out of this entry, returning to the journal list.
            if isEditing {
                editToolbar
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Delete this entry?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { Task { await deleteEntry() } }
        } message: {
            Text("This entry will move to Recently Deleted in Settings and be permanently removed after 30 days. You can restore it before then.")
        }
        .alert("Discard changes?", isPresented: $showDiscardConfirmation) {
            Button("Keep Editing", role: .cancel) {}
            Button("Discard", role: .destructive) { exitEditMode() }
        } message: {
            Text("Your edits haven't been saved. If you leave now, they'll be lost.")
        }
        .sheet(isPresented: $showMoodSheet) {
            moodSheet
        }
        .sheet(isPresented: $showOriginalChat) {
            originalChatSheet
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { image in
                heroImage = image
            }
            .ignoresSafeArea()
        }
        .onChange(of: photoPickerItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    heroImage = image
                }
            }
        }
        .task { await loadEntry() }
    }

    /// Pending (Aug 27, 2026 locked state, Flow 4b): title/body don't exist yet --
    /// no title slot at all (date already covers it), raw transcript shown ONLY as a
    /// temporary placeholder labeled "In your words" so it's never mistaken for
    /// finished synthesis, and a cause-agnostic "Still working on this" badge --
    /// never "Offline", never surfacing which of the three possible causes (offline,
    /// provider outage, exhausted budget) applies. No edit affordance exists here at
    /// all; the ⋯ menu's Edit Entry item is hidden in `header` for this state.
    @ViewBuilder
    private var pendingContent: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 11))
                .foregroundColor(Theme.gold)
            Text("Still working on this")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.gold)
        }

        Text("Your reflection is safe and being formed into a journal entry. This can take a little while -- no need to do anything.")
            .font(.system(size: 13))
            .foregroundColor(Theme.Payment.textSupporting)

        Text("IN YOUR WORDS")
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(Theme.Payment.textSupporting)
            .padding(.top, 8)

        Text(moment.body)
            .font(.system(size: 17, weight: .light))
            .italic()
            .foregroundColor(Theme.Capture.textBody)
            .lineSpacing(1.6)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var approvedContent: some View {
                        if let effectiveTitle {
                            Text(effectiveTitle)
                                .font(.system(size: 28, design: .serif))
                                .foregroundColor(Theme.Payment.textHeading)
                        }

                        if isEditing {
                            editableMoodRow
                        } else if !selectedMoods.isEmpty {
                            readOnlyMoodRow(selectedMoods)
                        }

                        if isEditing {
                            TextEditor(text: $editedBody)
                                .font(.system(size: 17, weight: .light))
                                .foregroundColor(Theme.Capture.textBody)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                // A TextEditor nested inside a ScrollView sizes itself to
                                // its own minHeight rather than filling available space --
                                // ScrollView gives children their ideal size, it doesn't
                                // stretch them. 200pt left a large, unusable empty gap
                                // between the editor and the toolbar below; Kell flagged
                                // this live (Nov 11 2026) as "the space is very limiting."
                                // A screen-relative minHeight fills that gap without the
                                // GeometryReader plumbing a precise fill would need.
                                .frame(minHeight: UIScreen.main.bounds.height * 0.45)
                        } else {
                            Text(displayBody)
                                .font(.system(size: 17, weight: .light))
                                .foregroundColor(Theme.Capture.textBody)
                                .lineSpacing(1.6)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        if let saveErrorMessage {
                            Text(saveErrorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(Theme.error)
                        }

                        if let deleteErrorMessage {
                            Text(deleteErrorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(Theme.error)
                        }

                        if let voiceNoteErrorMessage {
                            Text(voiceNoteErrorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(Theme.error)
                        }

                        // Locked placement (Nov 10 2026, Kell): AFTER the body, as its own
                        // bordered card -- not a header, not inline italic text. The body is
                        // the user's own words in their own voice; the verse arrives as a
                        // quiet payoff once they've read their reflection back, not a lead-in
                        // that frames their story as illustrating it.
                        //
                        // Frozen-at-synthesis policy (locked this session): once generated,
                        // this verse does NOT regenerate just because the user edits the
                        // body. The one exception, which `saveEdit()` below enforces: if the
                        // body is edited down to fully empty, that's effectively a new
                        // entry, so the verse is dropped from display alongside it rather
                        // than persisting orphaned from nothing.
                        if !isEditing, !displayBody.isEmpty, let quote = effectiveScriptureQuote, let reference = effectiveScriptureReference {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("\u{201C}\(quote)\u{201D}")
                                    .font(.system(size: 16, design: .serif))
                                    .italic()
                                    .foregroundColor(Theme.Payment.textHeading)

                                Text(reference.uppercased())
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(Theme.Payment.textSupporting)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(Theme.Capture.badgeBackground)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.Capture.journalCardBorder, lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.top, 8)
                        }
    }

    // MARK: - Header

    @ViewBuilder
    private var header: some View {
        if isEditing {
            // Figma "iPhone 17 — Edit Entry (Neutral)" (node 1423:3980): circular ✕ close
            // on the left, centered serif "Edit Entry" title, undo + save (checkmark) on
            // the right.
            ZStack {
                Text("Edit Entry")
                    .font(.system(size: 17, design: .serif))
                    .foregroundColor(Theme.Payment.textHeading)

                HStack {
                    Button(action: {
                        if hasUnsavedChanges {
                            showDiscardConfirmation = true
                        } else {
                            exitEditMode()
                        }
                    }) {
                        // Plain icon, no circle -- Kell caught (Nov 11 2026) that the
                        // circle emphasis had ended up here instead of on the checkmark,
                        // where the locked design actually puts it.
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.Capture.textPrimary)
                            .frame(width: 38, height: 38)
                    }

                    Spacer()

                    HStack(spacing: 16) {
                        Button(action: {
                            editedBody = displayBody
                            selectedMoods = loadedEntry?.moods ?? (meta?.moods ?? [])
                        }) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 17))
                                .foregroundColor(hasUnsavedChanges ? Theme.Capture.textPrimary : Theme.Capture.textMuted)
                                // Kell caught this live (Nov 16 2026): the save
                                // checkmark next to this button "populates but
                                // won't let me click it" -- intermittently, not
                                // every time, which is the signature of a tap
                                // target smaller than it looks rather than a real
                                // logic bug. Both this and the save button below
                                // rendered their icon at its own bare glyph size
                                // (well under Apple's 44pt minimum); a tap near the
                                // visible edge of the icon could land outside the
                                // actual hit area entirely. Explicit 44x44 frame +
                                // contentShape so the whole square is tappable, not
                                // just the glyph's own pixels.
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .disabled(!hasUnsavedChanges)

                        Button(action: { Task { await saveEdit() } }) {
                            if isSaving {
                                ProgressView().tint(Theme.gold)
                                    .frame(width: 32, height: 32)
                                    .frame(width: 44, height: 44)
                                    .contentShape(Rectangle())
                            } else if hasUnsavedChanges {
                                // Gold circle only appears when there's something to
                                // save -- matches the Stop-button's own "commits right
                                // now" emphasis convention elsewhere in this design system.
                                ZStack {
                                    Circle().fill(Theme.gold)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(Theme.Payment.backgroundPrimary)
                                }
                                .frame(width: 32, height: 32)
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                            } else {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Theme.Capture.textMuted)
                                    .frame(width: 32, height: 32)
                                    .frame(width: 44, height: 44)
                                    .contentShape(Rectangle())
                            }
                        }
                        .disabled(isSaving || !hasUnsavedChanges || editedBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 20)
        } else {
            HStack {
                // Always the real back action now, onboarding included (Kell's direct
                // ask) -- the chevron itself IS "return to the journal list," so it has
                // to be the thing that actually finishes onboarding when there's an
                // `onDone`, not a second, separate dismiss that bypasses it. Previously
                // this chevron was hidden entirely during onboarding in favor of a
                // bottom "Continue" button, specifically because tapping it used to
                // just `dismiss()` without ever calling `onDone` -- silently skipping
                // `completeOnboarding()`, which made the very next ordinary capture get
                // routed through the mandatory first-capture flow all over again. Now
                // that `onDone` fires here too, that failure mode is gone and the
                // chevron can safely be the one, universal way back.
                Button(action: {
                    if let onDone { onDone() } else { dismiss() }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Theme.Capture.textPrimary)
                        .frame(width: 44, height: 44)
                }
                // T-223 sweep -- this was the one Digital Cotton's original review
                // comment named directly ("the Journal Entry detail screen uses a
                // chevron inside a filled circular button"); that circular fill is
                // already gone (bare chevron, matching every onboarding screen), so
                // the one remaining gap was this missing label.
                .accessibilityLabel("Back")
                Spacer()
                HStack(spacing: 20) {
                    Button(action: {
                        isFavorited.toggle()
                        Task { await persistEntry() }
                    }) {
                        Image(systemName: isFavorited ? "star.fill" : "star")
                            .font(.system(size: 17))
                            .foregroundColor(Theme.Capture.textPrimary)
                    }
                    // Figma "Context Menu" (node 1423:4197): Edit Entry / View Original
                    // Chat / Delete Entry, pencil/message/trash glyphs, Delete in the
                    // design's warm destructive orange. Edit and Delete are real below;
                    // View Original Chat is NOT -- `Moment` has no stored link back to
                    // the originating `CaptureConversationView` transcript, so there's
                    // nothing to navigate to yet. Shown per the approved menu rather
                    // than silently dropped, but inert and flagged -- needs its own
                    // ticket to store that link.
                    Menu {
                        // Pending (T-159): no edit affordance exists at all here, per
                        // the locked spec -- there's nothing finished yet to edit.
                        if !isPending {
                            Button(action: {
                                editedBody = displayBody
                                saveErrorMessage = nil
                                isEditing = true
                            }) {
                                Label("Edit Entry", systemImage: "pencil")
                            }
                        }
                        Button(action: { showOriginalChat = true }) {
                            Label("View Original Chat", systemImage: "message")
                        }
                        Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                            Label("Delete Entry", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Theme.Capture.textPrimary)
                    }
                }
                .frame(height: 44)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Hero photo (Scenarios 4/5/8)

    private func heroPhotoHeader(_ image: UIImage) -> some View {
        // Figma "Hero Photo" spans past the screen's own side margins (x: -20, width:
        // 423 against a 353-wide content column) -- a deliberate edge-to-edge bleed,
        // not a layout bug, so this is NOT wrapped in the 20pt horizontal padding the
        // rest of the content uses.
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 240)
                .clipped()

            if isEditing {
                Button(action: { heroImage = nil }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                }
                .padding(12)
            }
        }
    }

    // MARK: - Mood rows (Scenario 7)

    private func readOnlyMoodRow(_ moods: [String]) -> some View {
        HStack(spacing: 8) {
            ForEach(moods, id: \.self) { mood in
                Text(mood)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Theme.Capture.cardBorder)
                    .clipShape(Capsule())
            }
        }
    }

    private var editableMoodRow: some View {
        // Re-pulled directly from the Figma "Edit Entry (Neutral)" frame (node 280:1378,
        // pills 280:1420/280:1422/280:1424) on Nov 16 2026 -- the gold border+fill treatment
        // this previously had was never actually in the design: selected pills there are
        // the SAME filled dark chip as the read-only row (Theme.Payment.pillBackground +
        // textSupporting, no border at all), and only "+ Add mood" gets gold -- in its
        // text, not its border, which is the neutral moodChipBorder dash instead.
        HStack(spacing: 8) {
            // Tappable even once at the 3-mood cap (no "+ Add mood" pill is shown then) --
            // otherwise there was no way back into the sheet to swap a mood out once full.
            ForEach(selectedMoods, id: \.self) { mood in
                Text(mood)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Theme.Payment.pillBackground)
                    .clipShape(Capsule())
                    .onTapGesture { showMoodSheet = true }
            }

            if selectedMoods.count < maxMoods {
                Button(action: { showMoodSheet = true }) {
                    Text("+ Add mood")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.gold)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .overlay(Capsule().stroke(Theme.Payment.moodChipBorder, style: StrokeStyle(lineWidth: 1, dash: [3, 3])))
                }
            }
        }
    }

    /// Figma "Mood Sheet" (Scenario 7, nodes 1420:3096 / 1421:170 / 1421:253): preset
    /// grid up to 3 selections, a live "X / 3 selected" counter once at least one is
    /// picked, and a free-text "Add your own word" row for a mood not in the preset list.
    private var moodSheet: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Moods")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Theme.Payment.textHeading)
                Spacer()
                Button("Done") {
                    selectedMoods = draftMoods
                    showMoodSheet = false
                    Task { await commitPendingCustomMoods() }
                }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.gold)
            }
            .padding(.top, 8)

            Text("Choose up to 3 that fit this entry")
                .font(.system(size: 13))
                .foregroundColor(Theme.Payment.textSupporting)
                .padding(.top, 10)

            // Re-pulled directly from Figma (nodes 284:166 "Mood Sheet (Base)" and
            // 286:1590 "Mood Sheet (Limit Reached)") on Nov 16 2026 -- the previous
            // "thin outline always, filled only by checkmark" read of the design was
            // wrong. The real design fills a SELECTED chip solid (Theme.Payment.
            // pillBackground, textHeading text, gold checkmark); only unselected chips
            // use the thin moodChipBorder outline. Disabled/capped-out chips stay that
            // same outline, just dimmed to 0.4 opacity (pixel-matched from node 286:1647)
            // -- that's what actually signals "you're capped," not a border/fill swap.
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], alignment: .leading, spacing: 8) {
                // Kell caught this live (Nov 16 2026): a custom word typed into "Add
                // your own word" got added to draftMoods and counted toward the 3/3
                // cap, but never showed up as a chip anywhere in the grid -- there was
                // no way to see it was selected, or to tap it off again. Preset moods
                // stay first (matches Figma's fixed grid order), then the user's saved
                // custom vocabulary (T-294, shared across every entry), then any
                // selected mood that's in neither list yet (a brand-new word still only
                // in this sheet's own draft).
                ForEach(allSelectableMoods, id: \.self) { mood in
                    let isSelected = draftMoods.contains(mood)
                    let isCappedOut = !isSelected && draftMoods.count >= maxMoods
                    // T-294 (Kell's call, Nov 16 2026): deleting a custom word now
                    // happens right here instead of a separate Settings screen -- an
                    // always-visible "x" on custom (non-preset) chips only. It's a
                    // second, independent tap target from the toggle button so it still
                    // works even when the chip itself is capped-out/disabled -- deleting
                    // one is exactly how you free a slot to add another.
                    let matchingCustomMood = customMoodsLibrary.first { $0.word == mood }
                    HStack(spacing: 6) {
                        Button(action: { toggleMood(mood) }) {
                            HStack(spacing: 6) {
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Theme.gold)
                                }
                                Text(mood)
                                    .font(.system(size: 14))
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(isCappedOut)
                        .opacity(isCappedOut ? 0.4 : 1)

                        if let matchingCustomMood {
                            Button(action: { customMoodPendingDelete = matchingCustomMood }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .foregroundColor(isSelected ? Theme.Payment.textHeading : Theme.Payment.textSupporting)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(isSelected ? Theme.Payment.pillBackground : Color.clear)
                    .overlay(
                        isSelected ? nil : Capsule().stroke(Theme.Payment.moodChipBorder, lineWidth: 1)
                    )
                    .clipShape(Capsule())
                }
            }
            .padding(.top, 16)

            // Figma's custom-word row (same two nodes above) caps input at 20
            // characters with a live "X / 20" counter underneath -- there was no
            // limit or counter here before.
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Theme.Payment.textSupporting)
                    TextField("Add your own word", text: $customMoodText)
                        .font(.system(size: 14))
                        .foregroundColor(Theme.Capture.textPrimary)
                        .tint(Theme.gold)
                        .onChange(of: customMoodText) { newValue in
                            if newValue.count > customMoodMaxLength {
                                customMoodText = String(newValue.prefix(customMoodMaxLength))
                            }
                        }
                        .onSubmit(addCustomMood)
                    if !customMoodText.trimmingCharacters(in: .whitespaces).isEmpty {
                        Button("Add", action: addCustomMood)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.gold)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .overlay(
                    Capsule().stroke(customMoodText.isEmpty ? Theme.Payment.moodChipBorder : Theme.gold, lineWidth: 1)
                )
                .clipShape(Capsule())

                if !customMoodText.isEmpty {
                    Text("\(customMoodText.count) / \(customMoodMaxLength)")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .padding(.leading, 4)
                }
            }
            .padding(.top, 12)
            .disabled(draftMoods.count >= maxMoods)
            .opacity(draftMoods.count >= maxMoods ? 0.4 : 1)

            if let customMoodLimitMessage {
                Text(customMoodLimitMessage)
                    .font(.system(size: 11))
                    .foregroundColor(Theme.error)
                    .padding(.top, 6)
            }

            if !draftMoods.isEmpty {
                Text("\(draftMoods.count) / \(maxMoods) selected")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .padding(.top, 10)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.background.ignoresSafeArea())
        .applyMoodSheetPresentationBackground()
        .presentationDetents([.medium])
        .onAppear {
            draftMoods = selectedMoods
            pendingNewCustomWords = []
            customMoodLimitMessage = nil
            Task { await loadCustomMoodsLibrary() }
        }
        .alert("Delete \"\(customMoodPendingDelete?.word ?? "")\"?", isPresented: Binding(
            get: { customMoodPendingDelete != nil },
            set: { if !$0 { customMoodPendingDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let customMoodPendingDelete {
                    Task { await deleteCustomMood(customMoodPendingDelete) }
                }
            }
        } message: {
            Text("It stays on any entry that already used it, but won't be offered again.")
        }
    }

    // T-294: the full set of chips the sheet can show -- presets, then the user's saved
    // custom vocabulary, then (rare) a word already selected on this entry that's in
    // neither list yet, e.g. a brand-new word still only in this sheet's own draft.
    private var allSelectableMoods: [String] {
        let savedCustomWords = customMoodsLibrary.map(\.word)
        let known = Set(presetMoods).union(savedCustomWords)
        let stillUnknown = draftMoods.filter { !known.contains($0) }
        return presetMoods + savedCustomWords + stillUnknown
    }

    /// Not the real back-and-forth conversation (Dwelly's side of it is never
    /// persisted anywhere -- see `CaptureConversationView.fullTranscript`'s own
    /// comment), just the raw words the user actually spoke/typed, read-only.
    /// Genuinely real and already loaded; a stand-in until a real transcript link
    /// exists, not a second placeholder.
    private var originalChatSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Original Reflection")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Theme.Payment.textHeading)
                Spacer()
                Button("Done") { showOriginalChat = false }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.gold)
            }

            Text("Your own words, exactly as captured -- before Dwelly's reframing turned them into this journal entry.")
                .font(.system(size: 13))
                .foregroundColor(Theme.Payment.textSupporting)

            ScrollView {
                Text(moment.body)
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(Theme.Capture.textBody)
                    .lineSpacing(1.6)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .background(Theme.background)
        .presentationDetents([.medium, .large])
    }

    // Kell caught this live (Nov 16 2026): these used to mutate `selectedMoods`
    // and fire `persistEntry()` on every tap/submit, so a mood change was already
    // saved to Supabase before "Done" was ever pressed -- swiping the sheet away
    // instead of hitting Done didn't undo anything. They now only touch the sheet's
    // own `draftMoods`; "Done" (above) is the one place that copies the draft back
    // into `selectedMoods`, and persisting still goes through the normal edit-mode
    // Save button, same as the body text.
    private func toggleMood(_ mood: String) {
        if let index = draftMoods.firstIndex(of: mood) {
            draftMoods.remove(at: index)
        } else if draftMoods.count < maxMoods {
            draftMoods.append(mood)
        }
    }

    private func addCustomMood() {
        let trimmed = customMoodText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, draftMoods.count < maxMoods, !draftMoods.contains(trimmed) else { return }
        // T-294: a word already in presetMoods or the user's saved library is just
        // being re-selected, not a new addition -- only a genuinely new word counts
        // against the 10-word cap, and only genuinely new words need to be queued for
        // `custom_moods` on Done.
        let isNewWord = !presetMoods.contains(trimmed) && !customMoodsLibrary.contains { $0.word == trimmed }
        if isNewWord && customMoodsLibrary.count + pendingNewCustomWords.count >= maxCustomMoods {
            customMoodLimitMessage = "You've reached your limit of \(maxCustomMoods) custom moods. Tap the ✕ on one below to delete it and add another."
            return
        }
        customMoodLimitMessage = nil
        draftMoods.append(trimmed)
        if isNewWord {
            pendingNewCustomWords.append(trimmed)
        }
        customMoodText = ""
    }

    // T-294: fetches the user's shared mood vocabulary fresh every time the sheet
    // opens, so a word added from another entry (or another device) shows up here too.
    private func loadCustomMoodsLibrary() async {
        guard let moods = try? await apiClient.fetchCustomMoods(userId: moment.userId) else { return }
        customMoodsLibrary = moods
    }

    // Only runs on "Done" -- writes any brand-new words typed into this sheet back to
    // `custom_moods` so every future entry (this user's, on any device) can offer them
    // too. Swiping the sheet away without Done never reaches this, same as `draftMoods`.
    private func commitPendingCustomMoods() async {
        for word in pendingNewCustomWords {
            if let saved = try? await apiClient.addCustomMood(userId: moment.userId, word: word) {
                customMoodsLibrary.append(saved)
            }
        }
        pendingNewCustomWords = []
    }

    // T-294: deletes a custom mood from the user's shared library, confirmed first
    // (see the moodSheet alert above). Runs immediately on confirm -- unlike adding a
    // word, this isn't gated behind "Done", since removing one is exactly how a user
    // frees a slot to add another while still in the sheet. Left in draftMoods/
    // selectedMoods untouched if it was already selected on this entry; the delete
    // only affects whether it's offered to pick again in the future.
    private func deleteCustomMood(_ mood: CustomMood) async {
        if (try? await apiClient.deleteCustomMood(id: mood.id)) != nil {
            customMoodsLibrary.removeAll { $0.id == mood.id }
        }
        customMoodPendingDelete = nil
    }

    // MARK: - Edit toolbar (photo / camera / mic)

    private var editToolbar: some View {
        HStack(spacing: 4) {
            PhotosPicker(selection: $photoPickerItem, matching: .images) {
                Image(systemName: "photo")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Capture.textPrimary)
                    .frame(width: 40, height: 40)
            }

            Button(action: { showCamera = true }) {
                Image(systemName: "camera")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Capture.textPrimary)
                    .frame(width: 40, height: 40)
            }

            Button(action: { Task { await toggleVoiceNoteRecording() } }) {
                if isTranscribingVoiceNote {
                    ProgressView().tint(Theme.gold)
                        .frame(width: 40, height: 40)
                } else {
                    Image(systemName: isRecordingVoiceNote ? "stop.circle.fill" : "mic")
                        .font(.system(size: 16))
                        .foregroundColor(isRecordingVoiceNote ? Theme.error : Theme.Capture.textPrimary)
                        .frame(width: 40, height: 40)
                }
            }
            .disabled(isTranscribingVoiceNote)
        }
        .padding(8)
        .background(Theme.Capture.badgeBackground)
        .overlay(Capsule().stroke(Theme.Capture.journalCardBorder, lineWidth: 1))
        .clipShape(Capsule())
        .padding(.bottom, Theme.Spacing.lg)
    }

    // MARK: - Actions

    /// Nov 11 2026: edits the synthesized entry (`journal_entries.body`), NOT
    /// `moments.body` (the raw transcript) -- matches the locked spec's own "What's
    /// NOT Editable" list (original moment transcript stays untouched). Before the
    /// real body-synthesis build, this was the only body there was to edit, so it
    /// wrote through `apiClient.saveMoment`; that's gone now that there's a real
    /// distinction between "what I actually said" and "the journal entry about it."
    private func saveEdit() async {
        let trimmed = editedBody.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard trimmed != displayBody else {
            isEditing = false
            return
        }
        isSaving = true
        saveErrorMessage = nil
        displayBody = editedBody
        isEditing = false
        await persistEntry(edited: true)
        isSaving = false
    }

    /// T-152: loads the real persisted title/body/moods/scripture/starred for this
    /// moment, if an entry exists yet. `meta` (from a just-finished capture) stays the
    /// display fallback until this returns -- see `effectiveTitle` etc. above.
    private func loadEntry() async {
        guard let entry = try? await apiClient.fetchJournalEntry(momentId: moment.id) else { return }
        loadedEntry = entry
        if !entry.moods.isEmpty { selectedMoods = entry.moods }
        if let body = entry.body, !isEditing {
            displayBody = body
            editedBody = body
        }
        isFavorited = entry.starred

        // T-188: the Today tab's "Journal Ready" tile's only signal for "already
        // seen" -- stamp it the first time this screen actually loads the entry.
        // Best-effort/fire-and-forget: a missed stamp just means the tile shows up
        // one extra time, never worth surfacing as an error on a detail screen.
        if entry.viewedAt == nil {
            Task { try? await apiClient.markJournalEntryViewed(id: entry.id) }
        }
    }

    /// Writes the current body/moods/starred (+ title/scripture, carried over from
    /// whatever `effectiveTitle`/`effectiveScripture*` already resolve to) back to
    /// `journal_entries`. Safe to call from capture time (no `loadedEntry` yet)
    /// through to a body edit years later (`loadedEntry` already exists) -- upserts
    /// on `moment_id` either way.
    private func persistEntry(edited: Bool = false) async {
        let entry = JournalEntry(
            id: loadedEntry?.id ?? UUID().uuidString,
            momentId: moment.id,
            userId: moment.userId,
            title: effectiveTitle,
            body: displayBody,
            moods: selectedMoods,
            scriptureQuote: effectiveScriptureQuote,
            scriptureReference: effectiveScriptureReference,
            starred: isFavorited,
            edited: edited || (loadedEntry?.edited ?? false),
            createdAt: loadedEntry?.createdAt ?? Date(),
            // T-188: same upsert-overwrites-every-column risk -- without carrying this
            // forward, editing body/moods after opening an entry would silently
            // un-view it, making the Journal Ready tile reappear for something already
            // read. Found while fixing the identical T-127 gap just below.
            viewedAt: loadedEntry?.viewedAt,
            // T-127: saveJournalEntry upserts every column -- without carrying these
            // forward, editing body/moods here would silently reset formation
            // eligibility to false and wipe extractedFacts on every save, breaking
            // Growth eligibility retroactively for an already-eligible entry.
            formationEligible: loadedEntry?.formationEligible ?? false,
            extractedFacts: loadedEntry?.extractedFacts
        )
        loadedEntry = try? await apiClient.saveJournalEntry(entry)
    }

    private func deleteEntry() async {
        isDeleting = true
        deleteErrorMessage = nil
        do {
            try await apiClient.deleteMoment(id: moment.id)
            dismiss()
        } catch {
            deleteErrorMessage = "Couldn't delete — check your connection and try again."
        }
        isDeleting = false
    }

    private func toggleVoiceNoteRecording() async {
        voiceNoteErrorMessage = nil
        if isRecordingVoiceNote {
            voiceRecorder.stopRecording {
                Task { await transcribeVoiceNote() }
            }
            isRecordingVoiceNote = false
        } else {
            voiceRecorder.startRecording()
            isRecordingVoiceNote = true
        }
    }

    private func transcribeVoiceNote() async {
        guard let url = voiceRecorder.audioURL else {
            voiceNoteErrorMessage = "Couldn't find the recording — try again."
            return
        }
        isTranscribingVoiceNote = true
        await withCheckedContinuation { continuation in
            TranscriptionManager.shared.transcribeAudio(from: url) { transcript in
                DispatchQueue.main.async {
                    if let transcript, !transcript.isEmpty {
                        editedBody = editedBody.isEmpty ? transcript : editedBody + "\n\n" + transcript
                    } else {
                        voiceNoteErrorMessage = "Couldn't transcribe that recording — try again."
                    }
                    isTranscribingVoiceNote = false
                    continuation.resume()
                }
            }
        }
    }
}

/// Thin `UIViewControllerRepresentable` around `UIImagePickerController`'s camera
/// source -- SwiftUI has no native camera API (unlike `PhotosPicker` for the library),
/// so this is the minimum real wrapper needed rather than hand-rolling camera chrome
/// the way Figma's static "Viewfinder" mock necessarily did.
private struct CameraPicker: UIViewControllerRepresentable {
    let onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

private extension View {
    /// The Moods sheet's own `.background(...).ignoresSafeArea()` paints the content
    /// area, but the system sheet chrome itself -- behind the top grabber capsule and
    /// the bottom home-indicator strip -- is a separate layer underneath that, and
    /// stayed the default translucent gray material no matter what the content's own
    /// background was set to (Kell caught this live, Nov 16 2026). `presentationBackground`
    /// is the only API that actually recolors that underlying sheet layer; it's iOS
    /// 16.4+, so below that this intentionally falls back to just the content fix.
    @ViewBuilder
    func applyMoodSheetPresentationBackground() -> some View {
        if #available(iOS 16.4, *) {
            self.presentationBackground(Theme.background)
        } else {
            self
        }
    }
}

#Preview {
    NavigationStack {
        JournalDetailView(
            moment: Moment(
                userId: "preview-user",
                body: "An unexpected wave of calm broke through the noise of the day. Sitting with Mom, I realized the peace wasn't something I made — it just arrived, uninvited and welcome.\n\nWe talked about old memories, the kind that usually stay folded away, and for a moment the busyness of everything else just quieted down.",
                createdAt: Date()
            ),
            meta: JournalDisplayMeta(
                title: "A Conversation with Mom",
                moods: ["Peaceful", "Grateful"],
                scriptureQuote: "Be still, and know that I am God.",
                scriptureReference: "Psalm 46:10"
            )
        )
    }
}

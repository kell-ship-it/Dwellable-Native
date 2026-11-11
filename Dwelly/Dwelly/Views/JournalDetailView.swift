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
                    .padding(.bottom, isEditing ? 100 : (onDone == nil ? 40 : 100))
                }
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            if isEditing {
                editToolbar
            } else if let onDone {
                // Onboarding's first-ever journal only -- see `onDone`'s comment.
                // Same pattern as CaptureConversationView's own onboarding footer:
                // a real tap the user controls, not a timer.
                Button(action: onDone) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Payment.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                }
                .background(Theme.gold)
                .clipShape(Capsule())
                .padding(.horizontal, 24)
                .padding(.bottom, Theme.Spacing.xxl)
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
                        }
                        .disabled(!hasUnsavedChanges)

                        Button(action: { Task { await saveEdit() } }) {
                            if isSaving {
                                ProgressView().tint(Theme.gold)
                                    .frame(width: 32, height: 32)
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
                            } else {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Theme.Capture.textMuted)
                                    .frame(width: 32, height: 32)
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
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Theme.Capture.textPrimary)
                        .frame(width: 44, height: 44)
                }
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
                        Button(action: {}) {
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
        // Figma mood pills in "Edit Entry" use the gold/accent treatment (border +
        // 8%-opacity fill), distinct from the read-only screen's neutral pill -- plus a
        // dashed "+ Add mood" pill that opens the Mood Sheet below.
        HStack(spacing: 8) {
            ForEach(selectedMoods, id: \.self) { mood in
                Text(mood)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.gold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Theme.gold.opacity(0.08))
                    .overlay(Capsule().stroke(Theme.gold, lineWidth: 1))
                    .clipShape(Capsule())
            }
            if selectedMoods.count < maxMoods {
                Button(action: { showMoodSheet = true }) {
                    Text("+ Add mood")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.gold)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .overlay(Capsule().stroke(Theme.gold.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
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
                Button("Done") { showMoodSheet = false }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.gold)
            }
            .padding(.top, 8)

            Text("Choose up to 3 that fit this entry")
                .font(.system(size: 13))
                .foregroundColor(Theme.Payment.textSupporting)
                .padding(.top, 10)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(presetMoods, id: \.self) { mood in
                    let isSelected = selectedMoods.contains(mood)
                    Button(action: { toggleMood(mood) }) {
                        HStack(spacing: 6) {
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            Text(mood)
                                .font(.system(size: 14))
                        }
                        .foregroundColor(isSelected ? Theme.gold : Theme.Capture.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(isSelected ? Theme.gold.opacity(0.1) : Theme.Capture.cardBorder)
                        .clipShape(Capsule())
                    }
                    .disabled(!isSelected && selectedMoods.count >= maxMoods)
                }
            }
            .padding(.top, 16)

            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Capture.textPrimary)
                TextField("Add your own word", text: $customMoodText)
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Capture.textPrimary)
                    .onSubmit(addCustomMood)
                if !customMoodText.trimmingCharacters(in: .whitespaces).isEmpty {
                    Button("Add", action: addCustomMood)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Theme.gold)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Theme.Capture.badgeBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.top, 20)
            .disabled(selectedMoods.count >= maxMoods)
            .opacity(selectedMoods.count >= maxMoods ? 0.4 : 1)

            if !selectedMoods.isEmpty {
                Text("\(selectedMoods.count) / \(maxMoods) selected")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .padding(.top, 10)
            }
        }
        .padding(20)
        .background(Theme.background)
        .presentationDetents([.medium])
    }

    private func toggleMood(_ mood: String) {
        if let index = selectedMoods.firstIndex(of: mood) {
            selectedMoods.remove(at: index)
        } else if selectedMoods.count < maxMoods {
            selectedMoods.append(mood)
        }
        Task { await persistEntry() }
    }

    private func addCustomMood() {
        let trimmed = customMoodText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, selectedMoods.count < maxMoods, !selectedMoods.contains(trimmed) else { return }
        selectedMoods.append(trimmed)
        customMoodText = ""
        Task { await persistEntry() }
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
            createdAt: loadedEntry?.createdAt ?? Date()
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

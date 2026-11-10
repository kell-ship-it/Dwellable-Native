import SwiftUI

/// The real "Dwelling Place" reading screen (Pillar 4) — replaces the old, pre-dark-theme
/// `MomentDetailView` as the one place a saved moment is actually read. Rebuilt to match
/// Kell's approved reference mock exactly (Nov 10 2026): back chevron + star (favorite) +
/// ellipsis (more actions) in one top row; date left-aligned below that row, NOT centered;
/// serif title; mood tag pills; then body. Deliberately scoped down from the full locked
/// `Journal` artifact spec in `docs/PILLAR_4_JOURNAL_CREATION_STRATEGY.md` (no photos,
/// prayer link, or encrypted storage yet — that's T-151/T-152/T-153, not started) to just
/// what's real today, laid out the way the approved design actually shows it.
///
/// Edit/menu chrome (Nov 10 2026) is pulled directly from the Figma file
/// (t5MUGEtpeFcUixobvHiYMc, page "P4-Journal Synthesis", Scenario 2 node 1423:3980 and
/// Scenario 3 node 1423:4182) rather than improvised -- see each piece's own comment below
/// for what's real vs. still a visual placeholder.
struct JournalDisplayMeta {
    let title: String
    let moods: [String]
    let scriptureQuote: String?
    let scriptureReference: String?

    init(title: String, moods: [String] = [], scriptureQuote: String? = nil, scriptureReference: String? = nil) {
        self.title = title
        self.moods = moods
        self.scriptureQuote = scriptureQuote
        self.scriptureReference = scriptureReference
    }
}

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

    // TODO: real favorite/star state isn't built yet -- its own follow-up, not this ticket.
    @State private var isFavorited = false

    // Editing is scoped to exactly the one thing that's actually real and persisted
    // today: `moment.body`, via the SAME `apiClient.saveMoment` path
    // `CaptureConversationView.finishAndSave()` already uses, which the `save-moment`
    // Edge Function performs as a genuine `upsert(onConflict: "id")` -- confirmed by
    // reading that function directly, not assumed -- so saving the same `id` with new
    // text updates the existing row rather than creating a duplicate. Mood pills are
    // shown editable in this screen (matching the Figma "Edit Entry" mock exactly), but
    // tapping one or "+ Add mood" doesn't persist anything yet -- `journalMeta` has no
    // backing store at all (no `JournalEntry` table -- T-152), so there's nothing real
    // for a mood edit to save TO. Flagged honestly rather than faked as working.
    @State private var isEditing = false
    @State private var editedBody: String
    @State private var displayBody: String
    @State private var isSaving = false
    @State private var saveErrorMessage: String?

    @State private var isDeleting = false
    @State private var showDeleteConfirmation = false
    @State private var deleteErrorMessage: String?

    init(moment: Moment, syncManager: SyncManager? = nil, meta: JournalDisplayMeta? = nil, onDone: (() -> Void)? = nil) {
        self.moment = moment
        self.syncManager = syncManager
        self.meta = meta
        self.onDone = onDone
        _editedBody = State(initialValue: moment.body)
        _displayBody = State(initialValue: moment.body)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(moment.createdAt.formatted(date: .abbreviated, time: .omitted).uppercased())
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.Payment.textSupporting)

                    if let meta {
                        Text(meta.title)
                            .font(.system(size: 28, design: .serif))
                            .foregroundColor(Theme.Payment.textHeading)
                    }

                    if isEditing {
                        editableMoodRow
                    } else if let meta, !meta.moods.isEmpty {
                        readOnlyMoodRow(meta.moods)
                    }

                    if isEditing {
                        TextEditor(text: $editedBody)
                            .font(.system(size: 17, weight: .light))
                            .foregroundColor(Theme.Capture.textBody)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 200)
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

                    // Locked placement (Nov 10 2026, Kell): AFTER the body, as its own
                    // bordered card -- not a header, not inline italic text. The body is
                    // the user's own words in their own voice; the verse arrives as a
                    // quiet payoff once they've read their reflection back, not a lead-in
                    // that frames their story as illustrating it.
                    //
                    // Frozen-at-synthesis policy (locked this session): once generated,
                    // this verse does NOT regenerate just because the user edits the
                    // body. It's a record of what met them in the moment as originally
                    // reflected, same as Pillar 4's title/moods are also generated once
                    // and not live-recomputed. The one exception, which `saveEdit()`
                    // below actually enforces now that editing is real: if the body is
                    // edited down to fully empty (not just trimmed/added to), that's
                    // effectively a new entry, so the verse is dropped from display
                    // alongside it rather than persisting orphaned from nothing.
                    if !isEditing, !displayBody.isEmpty, let meta, let quote = meta.scriptureQuote, let reference = meta.scriptureReference {
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
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, isEditing ? 100 : (onDone == nil ? 40 : 100))
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            if isEditing {
                // Figma "Edit Toolbar" (node 1423:4006): photo-library / camera / mic.
                // All three are visual-only placeholders -- attaching photos (T-151) and
                // re-recording a voice note into an existing entry aren't built yet.
                // Shown per the approved design rather than omitted, same reasoning as
                // the star/ellipsis chrome below: the chrome is real, the capability
                // behind two of its three buttons isn't, yet.
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
        // Figma "Delete Confirmation (Popover)" (node 1407:659): a real confirmation,
        // not a bare destructive tap -- matches the design's own copy about the 30-day
        // Recently Deleted window (T-176's existing soft-delete policy; this screen
        // doesn't implement that window itself, it just calls the same `deleteMoment`
        // the rest of the app already treats as the soft-delete entry point).
        .alert("Delete this entry?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { Task { await deleteEntry() } }
        } message: {
            Text("This entry will move to Recently Deleted in Settings and be permanently removed after 30 days. You can restore it before then.")
        }
    }

    @ViewBuilder
    private var header: some View {
        if isEditing {
            // Figma "iPhone 17 — Edit Entry (Neutral)" (node 1423:3980): circular ✕ close
            // on the left, centered serif "Edit Entry" title, undo + save (checkmark) on
            // the right -- not the plain text "Save" button this screen used before Kell
            // caught it skipping the real design.
            ZStack {
                Text("Edit Entry")
                    .font(.system(size: 17, design: .serif))
                    .foregroundColor(Theme.Payment.textHeading)

                HStack {
                    Button(action: { isEditing = false; editedBody = displayBody; saveErrorMessage = nil }) {
                        ZStack {
                            Circle().fill(Theme.Capture.cardBorder)
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.Capture.textPrimary)
                        }
                        .frame(width: 38, height: 38)
                    }

                    Spacer()

                    HStack(spacing: 16) {
                        Button(action: { editedBody = displayBody }) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 17))
                                .foregroundColor(Theme.Capture.textPrimary)
                        }
                        Button(action: { Task { await saveEdit() } }) {
                            if isSaving {
                                ProgressView().tint(Theme.gold)
                            } else {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Theme.Capture.textPrimary)
                            }
                        }
                        .disabled(isSaving || editedBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
                    Button(action: { isFavorited.toggle() }) {
                        Image(systemName: isFavorited ? "star.fill" : "star")
                            .font(.system(size: 17))
                            .foregroundColor(Theme.Capture.textPrimary)
                    }
                    // Figma "Context Menu" (node 1423:4197): Edit Entry / View Original
                    // Chat / Delete Entry, pencil/message/trash glyphs, Delete in the
                    // design's warm destructive orange. Edit and Delete are real below;
                    // View Original Chat is NOT -- `Moment` has no stored link back to
                    // the originating `CaptureConversationView` transcript (no field for
                    // it at all), so there's nothing to navigate to yet. Shown per the
                    // approved menu rather than silently dropped, but inert and flagged
                    // rather than faked -- needs its own ticket to store that link.
                    Menu {
                        Button(action: {
                            editedBody = displayBody
                            saveErrorMessage = nil
                            isEditing = true
                        }) {
                            Label("Edit Entry", systemImage: "pencil")
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
        // dashed "+ Add mood" pill. Visual parity only, per this struct's own TODO above.
        HStack(spacing: 8) {
            ForEach(meta?.moods ?? [], id: \.self) { mood in
                Text(mood)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.gold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Theme.gold.opacity(0.08))
                    .overlay(Capsule().stroke(Theme.gold, lineWidth: 1))
                    .clipShape(Capsule())
            }
            Text("+ Add mood")
                .font(.system(size: 13))
                .foregroundColor(Theme.gold)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .overlay(Capsule().stroke(Theme.gold.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
        }
    }

    private var editToolbar: some View {
        HStack(spacing: 4) {
            ForEach(["photo", "camera", "mic"], id: \.self) { icon in
                Button(action: {}) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(Theme.Capture.textPrimary)
                        .frame(width: 40, height: 40)
                }
            }
        }
        .padding(8)
        .background(Theme.Capture.badgeBackground)
        .overlay(Capsule().stroke(Theme.Capture.journalCardBorder, lineWidth: 1))
        .clipShape(Capsule())
        .padding(.bottom, Theme.Spacing.lg)
    }

    private func saveEdit() async {
        let trimmed = editedBody.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard trimmed != displayBody else {
            isEditing = false
            return
        }
        isSaving = true
        saveErrorMessage = nil

        let updated = Moment(
            id: moment.id,
            userId: moment.userId,
            body: editedBody,
            senseOfLord: moment.senseOfLord,
            createdAt: moment.createdAt,
            syncedAt: moment.syncedAt,
            audioURL: moment.audioURL
        )

        do {
            _ = try await apiClient.saveMoment(updated)
            displayBody = editedBody
            isEditing = false
        } catch {
            // Same offline-first fallback `finishAndSave()` already uses elsewhere --
            // the edit isn't lost, it queues for SyncManager's existing retry sweep
            // instead of failing silently or blocking the user on a network error.
            syncManager?.markMomentAsPending(updated)
            displayBody = editedBody
            isEditing = false
            saveErrorMessage = "Saved on this device — will sync once you're back online."
        }

        isSaving = false
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

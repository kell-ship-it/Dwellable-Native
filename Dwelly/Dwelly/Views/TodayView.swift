import SwiftUI

/// Today tab's "journal ready" card data -- the most recent approved entry the user
/// hasn't opened yet (`JournalEntry.viewedAt == nil`), paired with its `Moment` since
/// `JournalDetailView` needs the moment, not just the entry.
private struct JournalReadyEntry: Identifiable {
    let moment: Moment
    let entry: JournalEntry
    var id: String { entry.id }
}

/// T-135/T-136: the real Today tab, pulled directly from Figma's locked "Today (MVP)"
/// frame (dwelly-redesign jBOzv1vO2C2DSMePqRl4c4, P10, node 570:508). This frame is the
/// real scope -- it has no "Unprayed Moment" card anywhere on it, so T-137 (hasPrayed
/// field + unprayed-moment query) doesn't apply to what actually ships here; Prayer (P3)
/// has zero code today regardless, so that section was correctly un-buildable either way.
///
/// The "Word for Today" verse and the 3 reflection tiles (Mood/Intercession/Life-Domain)
/// are static for MVP, not the LLM-generated daily prompt T-139 describes -- that's hard
/// blocked on Formation Intelligence's LLM path (P6), which doesn't exist yet. This is the
/// honest "Question Bank" fallback the docs already describe for exactly this situation,
/// not a placeholder pretending to be the real thing.
///
/// Tapping the verse or any tile opens a real capture conversation pre-opened with that
/// specific prompt via `CaptureConversationView`'s existing `initialMessage`/
/// `initialMessageIsPrompt` (built for onboarding's topic cards, just never had a caller
/// outside CaptureView's own grid until now) -- `onOpenPrompt` is threaded up to
/// `MainTabView`, which owns the actual `fullScreenCover` + paywall gate.
struct TodayView: View {
    @Environment(\.apiClient) private var apiClient
    let userId: String
    var onCapture: () -> Void
    var onOpenPrompt: (_ prompt: (title: String, category: String)) -> Void

    // T-188: nil until loadJournalReady() finds an unviewed approved entry. Fetched
    // fresh every appearance (not cached) since the whole point is reacting to a
    // journal that just finished synthesizing since the last time this tab was shown.
    @State private var journalReady: JournalReadyEntry?

    private var firstName: String? {
        let name = ProfileManager.shared.localProfile(userId: userId).name
        return (name?.isEmpty ?? true) ? nil : name
    }

    private var greeting: String {
        if let firstName { return "Hi \(firstName)." }
        return "Hi there."
    }

    private let verseReference = "Mark 9:24 · ESV"
    private let verseQuote = "\"Lord, I believe; help my unbelief.\""
    private let verseQuestion = "When you see this verse, what does that mean to you? What comes to mind?"

    private let tiles: [(icon: String, category: String, title: String, subtitle: String)] = [
        ("heart", "Mood", "What are you grateful for today?", "Even something small counts."),
        ("hands.sparkles", "Intercession", "Anyone on your heart lately?", "Worth a thought right now."),
        ("mountain.2", "Life-Domain", "Have you had any dreams lately?", "Sometimes that's where God shows up.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // T-128: no onSearch here -- search only exists on Entries (see
            // TabScreenHeader's own comment).
            TabScreenHeader(title: greeting, onCapture: onCapture)

            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    heroCard

                    // T-188: a 4th card above the 3-tile stack, per the locked Oct 22
                    // 2026 design -- an added slot, not a replacement of any of the 3.
                    if let journalReady {
                        journalReadyCard(journalReady)
                    }

                    ForEach(tiles, id: \.title) { tile in
                        tileRow(tile)
                    }

                    interlude
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.top, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.xxl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Payment.background.ignoresSafeArea())
        .task { await loadJournalReady() }
    }

    /// T-188: the most recent approved entry this user hasn't opened yet, if any.
    /// Re-fetched on every appearance rather than cached -- the whole point of this
    /// card is reacting to a journal that finished synthesizing since Today was last
    /// shown (e.g. the background retry sweep in SyncManager finishing after the
    /// user already backed out of a capture).
    private func loadJournalReady() async {
        guard let entries = try? await apiClient.fetchApprovedJournalEntries(userId: userId) else { return }
        guard let latest = entries.filter({ $0.viewedAt == nil }).max(by: { $0.createdAt < $1.createdAt }) else {
            journalReady = nil
            return
        }
        guard let moment = try? await apiClient.fetchMoment(id: latest.momentId) else { return }
        journalReady = JournalReadyEntry(moment: moment, entry: latest)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("A WORD FOR TODAY")
                .font(.system(size: 11, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(Theme.Payment.textSupporting)

            Text(verseReference)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.Payment.textSupporting)

            Text(verseQuote)
                .font(.system(size: 24, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)
                .fixedSize(horizontal: false, vertical: true)

            Text(verseQuestion)
                .font(.system(size: 11))
                .foregroundColor(Theme.Payment.textSupporting)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: {
                onOpenPrompt((title: verseQuestion, category: "Scripture"))
            }) {
                HStack(spacing: 8) {
                    Text("Sit with this")
                        .font(.system(size: 14, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(Theme.Payment.backgroundPrimary)
                .padding(.horizontal, 18)
                .frame(height: 44)
                .background(Theme.gold)
                .clipShape(Capsule())
            }
            .buttonStyle(.pressableCard)
        }
        .padding(19)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Payment.surfaceCard)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Theme.Payment.borderDivider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    /// T-188: same card shape/background as `tileRow` (T-233's one-accent rule) and
    /// the same pressed state (T-234's `PressableCardStyle`), but a `NavigationLink`
    /// to the real finished entry instead of a `Button` opening a new capture --
    /// tapping this should land on what's already written, not start something new.
    private func journalReadyCard(_ ready: JournalReadyEntry) -> some View {
        NavigationLink(destination: JournalDetailView(moment: ready.moment)) {
            HStack(spacing: 16) {
                Circle()
                    .fill(Theme.Payment.pillBackground)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "book.closed")
                            .font(.system(size: 17))
                            .foregroundColor(Theme.gold)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("JOURNAL READY")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.2)
                        .foregroundColor(Theme.gold)
                    Text(ready.entry.title ?? "Your Reflection")
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(Theme.Payment.textHeading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text("Ready to read.")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                Image(systemName: "arrow.right")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Payment.textSupporting)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(Theme.Payment.surfaceCard)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Theme.Payment.borderDivider, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .buttonStyle(.pressableCard)
    }

    private func tileRow(_ tile: (icon: String, category: String, title: String, subtitle: String)) -> some View {
        Button(action: {
            onOpenPrompt((title: tile.title, category: tile.category))
        }) {
            HStack(spacing: 16) {
                Circle()
                    .fill(Theme.Payment.pillBackground)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: tile.icon)
                            .font(.system(size: 17))
                            .foregroundColor(Theme.gold)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(tile.category.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.2)
                        .foregroundColor(Theme.gold)
                    Text(tile.title)
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(Theme.Payment.textHeading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(tile.subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                Image(systemName: "arrow.right")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Payment.textSupporting)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            // Background/border live inside the button's own content, not chained
            // after it -- PressableCardStyle's dim+scale wraps whatever Button()
            // was given as its label, so the whole card (not just the text/icons)
            // needs to be part of that content to visibly press as one piece.
            .background(Theme.Payment.surfaceCard)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Theme.Payment.borderDivider, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .buttonStyle(.pressableCard)
    }

    private var interlude: some View {
        VStack(spacing: 11) {
            Image(systemName: "scribble")
                .font(.system(size: 18))
                .foregroundColor(Theme.Payment.textSupporting)
                .rotationEffect(.degrees(-10))

            Text("Some days don't need new words.")
                .font(.system(size: 17, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)
                .multilineTextAlignment(.center)

            Text("Just showing up counts.")
                .font(.system(size: 13))
                .foregroundColor(Theme.Payment.textFaint)
        }
        .padding(.top, Theme.Spacing.xl)
    }
}

#Preview {
    TodayView(userId: "preview-user", onCapture: {}, onOpenPrompt: { _ in })
}

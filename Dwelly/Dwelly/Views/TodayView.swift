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
/// The "Word for Today" verse is a curated pick (`DailyVerseLibrary`), not the
/// LLM-generated daily prompt T-139 describes -- that's hard blocked on Formation
/// Intelligence's LLM path (P6), which doesn't exist yet. This is the honest "Question
/// Bank" fallback the docs already describe for exactly this situation, not a
/// placeholder pretending to be the real thing. The 3 sub-hero tiles are Mood,
/// Sustain/Follow-up (or Intercession when there's no eligible history to follow up
/// on -- the locked fallback rule), and Life-Domain -- see `loadFollowUpTile(from:)`.
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

    // T-138: was 3 hardcoded `let`s showing the same single verse forever -- now
    // sourced from `DailyVerseLibrary`'s curated pool + 24h cache, `@State` since it's
    // read fresh (cache-checked) once per appearance rather than computed per-render.
    @State private var dailyVerse: DailyVerse = DailyVerseLibrary.verses[0]
    // Caught live (Nov 17 2026): `.onAppear` fires more than once per launch for this
    // tab (same reattachment behavior `CaptureConversationView.hasInitialized` already
    // guards against for the same reason) -- without this, a second firing could
    // re-roll the verse mid-session even though the UserDefaults cache was already
    // correct, so the displayed verse and the cached one silently diverged. Loads
    // exactly once per view lifetime; the real 24h/day-boundary cache lives in
    // `DailyVerseLibrary` itself, not here.
    @State private var hasLoadedDailyVerse = false

    // T-182: Mood and Life-Domain rotate daily through their real locked pools
    // (`TodayPromptLibraries.swift`) instead of always showing the same fixed prompt --
    // same once-per-appearance-load guard `hasLoadedDailyVerse` already uses, for the
    // same reattachment reason.
    @State private var hasLoadedRotatingTiles = false
    @State private var moodTile: TodayPrompt = MoodPromptLibrary.prompts[0]
    @State private var lifeDomainTile: TodayPrompt = LifeDomainPromptLibrary.prompts[0]

    // T-182 continued: the middle slot is Sustain/Follow-up when there's real,
    // already-viewed capture history to follow up on, falling back to a rotating
    // Intercession prompt when there isn't -- the locked design's own fallback rule
    // (`docs/PILLAR_TODAY_PROMPT_TAXONOMY.md`, "Designated fallback category:
    // Intercession"), not a 4th always-on tile. `nil` until `loadFollowUpTile()`
    // resolves; re-derived from the same entries fetch `loadJournalReady()` already
    // does, not a second network round-trip.
    @State private var followUpTile: (icon: String, category: String, title: String, subtitle: String)?
    @State private var intercessionFallback: TodayPrompt = IntercessionPromptLibrary.prompts[0]

    private var tiles: [(icon: String, category: String, title: String, subtitle: String)] {
        [
            (moodTile.icon, moodTile.category, moodTile.title, moodTile.subtitle),
            followUpTile ?? (intercessionFallback.icon, intercessionFallback.category, intercessionFallback.title, intercessionFallback.subtitle),
            (lifeDomainTile.icon, lifeDomainTile.category, lifeDomainTile.title, lifeDomainTile.subtitle)
        ]
    }

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
        .onAppear {
            guard !hasLoadedDailyVerse else { return }
            hasLoadedDailyVerse = true
            dailyVerse = DailyVerseLibrary.verseForToday()
        }
        .onAppear {
            guard !hasLoadedRotatingTiles else { return }
            hasLoadedRotatingTiles = true
            moodTile = MoodPromptLibrary.promptForToday()
            lifeDomainTile = LifeDomainPromptLibrary.promptForToday()
            intercessionFallback = IntercessionPromptLibrary.promptForToday()
        }
    }

    /// T-182: Sustain/Follow-up's real selection logic, per the locked fallback rules
    /// (`docs/PILLAR_TODAY_PROMPT_TAXONOMY.md`, "Follow-up: data lifecycle & fallback
    /// rules"). Looks only at already-viewed, formation-eligible entries -- an
    /// unviewed one is already surfaced by the separate "Journal Ready" card above,
    /// so Follow-up would otherwise point at the exact same entry twice on one screen.
    /// Prefers a real anniversary (same month+day, a prior year) over the plain most-
    /// recent pick, matching the doc's long-range example ("one year ago today");
    /// falls back to Intercession (set via `intercessionFallback`, already loaded)
    /// when there's no eligible history at all -- never fabricates a Sustain item.
    private func loadFollowUpTile(from entries: [JournalEntry]) {
        let eligible = entries.filter { $0.formationEligible && $0.viewedAt != nil }
        guard !eligible.isEmpty else {
            followUpTile = nil
            return
        }

        let calendar = Calendar.current
        let today = calendar.dateComponents([.month, .day], from: Date())
        let anniversary = eligible.first {
            let components = calendar.dateComponents([.month, .day, .year], from: $0.createdAt)
            return components.month == today.month && components.day == today.day
                && !calendar.isDate($0.createdAt, inSameDayAs: Date())
        }

        guard let picked = anniversary ?? eligible.max(by: { $0.createdAt < $1.createdAt }) else {
            followUpTile = nil
            return
        }

        let headline = picked.title ?? "A moment you captured"
        let timeAgo = Self.relativeTimeAgoFormatter.localizedString(for: picked.createdAt, relativeTo: Date())
        let subtitle = anniversary != nil ? "From \(timeAgo). Does it still feel the same?" : "Captured \(timeAgo)."
        followUpTile = ("arrow.uturn.left", "Sustain", "You wrote about \u{201C}\(headline)\u{201D}", subtitle)
    }

    private static let relativeTimeAgoFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    /// T-188: the most recent approved entry this user hasn't opened yet, if any.
    /// Re-fetched on every appearance rather than cached -- the whole point of this
    /// card is reacting to a journal that finished synthesizing since Today was last
    /// shown (e.g. the background retry sweep in SyncManager finishing after the
    /// user already backed out of a capture).
    private func loadJournalReady() async {
        guard let entries = try? await apiClient.fetchApprovedJournalEntries(userId: userId) else { return }
        loadFollowUpTile(from: entries)
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

            Text(dailyVerse.reference)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.Payment.textSupporting)

            Text(dailyVerse.quote)
                .font(.system(size: 24, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)
                .fixedSize(horizontal: false, vertical: true)

            Text(dailyVerse.question)
                .font(.system(size: 11))
                .foregroundColor(Theme.Payment.textSupporting)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: {
                onOpenPrompt((title: dailyVerse.question, category: "Scripture"))
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

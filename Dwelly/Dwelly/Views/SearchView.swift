import SwiftUI

/// T-128/T-257: Search & Discovery, pulled directly from Figma (dwelly-redesign
/// jBOzv1vO2C2DSMePqRl4c4, page "P5 — Search & Discovery", frames 02-06). Real-time
/// keyword + single-select mood filter (AND logic) against the user's own already-
/// synced approved journal entries -- locked Aug 27, 2026: pending entries have no
/// title/body/moods yet, so they're excluded from search entirely, same exclusion
/// `EntriesView` already applies when deciding what counts as a real entry to show.
/// No separate network/error state here (Kell's call, Nov 16 2026) -- this runs
/// entirely against already-synced local data, same offline-first precedent P4's own
/// Edit/View screens set, so there's nothing to retry; a load failure just leaves the
/// result set empty rather than surfacing an error banner.
struct SearchView: View {
    @Environment(\.apiClient) private var apiClient
    let userId: String
    let syncManager: SyncManager?
    var onDismiss: () -> Void

    private struct SearchableEntry: Identifiable {
        let moment: Moment
        let entry: JournalEntry
        var id: String { entry.id }
    }

    @State private var allEntries: [SearchableEntry] = []
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var selectedMood: String?
    // Kell (Nov 25 2026): quick filter to see only starred journals.
    @State private var starredOnly = false
    @State private var recentSearches: [String] = []

    private static let maxRecentSearches = 10
    private var recentSearchesKey: String { "recentSearches_\(userId)" }

    private var trimmedQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // A search is "active" (showing results, not Idle/Recent) once there's a real
    // keyword or a mood filter narrower than "All Moods" -- matches Figma frames
    // 03/04 (both require at least one of the two).
    private var isActiveSearch: Bool {
        !trimmedQuery.isEmpty || selectedMood != nil || starredOnly
    }

    private var results: [SearchableEntry] {
        allEntries.filter { searchable in
            let matchesQuery = trimmedQuery.isEmpty
                || (searchable.entry.title?.localizedCaseInsensitiveContains(trimmedQuery) ?? false)
                || (searchable.entry.body?.localizedCaseInsensitiveContains(trimmedQuery) ?? false)
            let matchesMood = selectedMood == nil || searchable.entry.moods.contains(selectedMood!)
            return matchesQuery && matchesMood && (!starredOnly || searchable.entry.starred)
        }
    }

    private var resultsSummary: String {
        let countPart = "\(results.count) result\(results.count == 1 ? "" : "s")"
        var parts: [String] = []
        if !trimmedQuery.isEmpty { parts.append("\u{201c}\(trimmedQuery)\u{201d}") }
        if starredOnly { parts.append("Starred") }
        if let selectedMood { parts.append(selectedMood) }
        return parts.isEmpty ? countPart : "\(countPart) \u{b7} \(parts.joined(separator: " + "))"
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            moodFilterRow

            if isActiveSearch {
                resultsSection
            } else {
                recentSearchesSection
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Payment.backgroundPrimary.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            recentSearches = UserDefaults.standard.stringArray(forKey: recentSearchesKey) ?? []
            await loadEntries()
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.Payment.textHeading)
                    .frame(width: 44, height: 44)
            }

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Payment.textPlaceholder)
                TextField("Search your journal...", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Payment.textHeading)
                    .tint(Theme.gold)
                    .submitLabel(.search)
                    .onSubmit { commitRecentSearch(trimmedQuery) }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(Theme.Payment.surfaceCard)
            .overlay(Capsule().stroke(Theme.Payment.moodChipBorder, lineWidth: 1))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }

    // MARK: - Mood filter

    private var moodFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                moodChip(label: "\u{2605} Starred", isSelected: starredOnly) { starredOnly.toggle() }
                moodChip(label: "All Moods", isSelected: selectedMood == nil) { selectedMood = nil }
                ForEach(presetMoods, id: \.self) { mood in
                    moodChip(label: mood, isSelected: selectedMood == mood) {
                        selectedMood = (selectedMood == mood) ? nil : mood
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
    }

    private func moodChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isSelected ? Theme.Payment.backgroundPrimary : Theme.Payment.textSupporting)
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(isSelected ? Theme.gold : Color.clear)
                .overlay(
                    isSelected ? nil : Capsule().stroke(Theme.Payment.borderDivider, lineWidth: 1)
                )
                .clipShape(Capsule())
        }
    }

    // MARK: - Recent searches (Idle state, Figma frames 02/05/06)

    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if recentSearches.isEmpty {
                Text("No recent searches.")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .padding(.horizontal, 20)
            } else {
                HStack {
                    Text("RECENT SEARCHES")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.Payment.textSupporting)
                    Spacer()
                    Button("Clear all") { clearAllRecentSearches() }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.gold)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

                ForEach(recentSearches, id: \.self) { term in
                    VStack(spacing: 0) {
                        HStack {
                            Button(action: { searchText = term }) {
                                Text(term)
                                    .font(.system(size: 15))
                                    .foregroundColor(Theme.Capture.textBody)
                            }
                            Spacer()
                            Button(action: { removeRecentSearch(term) }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14))
                                    .foregroundColor(Theme.Payment.textSupporting)
                                    .frame(width: 44, height: 44)
                            }
                        }
                        .padding(.horizontal, 20)
                        Divider().background(Theme.Payment.borderDivider)
                    }
                }
            }
            Spacer()
        }
        .padding(.top, 4)
    }

    // MARK: - Results (Figma frames 03/04)

    private var resultsSection: some View {
        Group {
            if isLoading {
                Spacer()
                ProgressView().tint(Theme.gold)
                Spacer()
            } else if results.isEmpty {
                noResultsState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(resultsSummary)
                            .font(.system(size: 13))
                            .foregroundColor(Theme.Payment.textSupporting)
                            .padding(.horizontal, 20)

                        ForEach(results) { searchable in
                            NavigationLink(destination: JournalDetailView(
                                moment: searchable.moment,
                                syncManager: syncManager,
                                meta: JournalDisplayMeta(
                                    title: searchable.entry.title ?? "",
                                    moods: searchable.entry.moods,
                                    body: searchable.entry.body,
                                    scriptureQuote: searchable.entry.scriptureQuote,
                                    scriptureReference: searchable.entry.scriptureReference
                                )
                            )) {
                                resultCard(for: searchable)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                }
            }
        }
    }

    private func resultCard(for searchable: SearchableEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(searchable.entry.createdAt.formatted(.dateTime.month(.abbreviated).day()).uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Theme.Payment.textSupporting)

            Text(searchable.entry.title ?? "A Moment With God")
                .font(.system(size: 17, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)
                .lineLimit(1)

            if let body = searchable.entry.body, !body.isEmpty {
                Text(body)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Capture.textBody)
                    .lineLimit(2)
            }

            if !searchable.entry.moods.isEmpty {
                HStack(spacing: 6) {
                    ForEach(searchable.entry.moods, id: \.self) { mood in
                        Text(mood)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Theme.Payment.textSupporting)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Theme.Payment.pillBackground)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Payment.backgroundSurface)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.Payment.borderDivider, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var noResultsState: some View {
        VStack(spacing: 16) {
            Spacer()
            Circle()
                .stroke(Theme.Payment.borderDivider, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                .frame(width: 72, height: 72)
            Text("Nothing yet")
                .font(.system(size: 22, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)
            Text(noResultsMessage)
                .font(.system(size: 14))
                .foregroundColor(Theme.Capture.textBody)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
            Spacer()
            Spacer()
        }
    }

    private var noResultsMessage: String {
        if !trimmedQuery.isEmpty {
            return "No entries match \u{201c}\(trimmedQuery)\u{201d}. Try a different word, or clear the mood filter."
        }
        if starredOnly && selectedMood == nil {
            return "No starred entries yet. Tap the star on any journal to keep it here."
        }
        return "No entries match \(selectedMood ?? "that filter"). Try another mood."
    }

    // MARK: - Data

    private func loadEntries() async {
        isLoading = true
        async let moments = apiClient.fetchMoments(userId: userId)
        async let approved = apiClient.fetchApprovedJournalEntries(userId: userId)
        guard let (fetchedMoments, approvedEntries) = try? await (moments, approved) else {
            isLoading = false
            return
        }
        let momentsById = Dictionary(uniqueKeysWithValues: fetchedMoments.map { ($0.id, $0) })
        allEntries = approvedEntries.compactMap { entry in
            guard let moment = momentsById[entry.momentId] else { return nil }
            return SearchableEntry(moment: moment, entry: entry)
        }
        isLoading = false
    }

    // MARK: - Recent searches persistence (T-257)

    private func commitRecentSearch(_ term: String) {
        guard !term.isEmpty else { return }
        var updated = recentSearches.filter { $0.caseInsensitiveCompare(term) != .orderedSame }
        updated.insert(term, at: 0)
        if updated.count > Self.maxRecentSearches {
            updated.removeLast(updated.count - Self.maxRecentSearches)
        }
        recentSearches = updated
        UserDefaults.standard.set(updated, forKey: recentSearchesKey)
    }

    private func removeRecentSearch(_ term: String) {
        recentSearches.removeAll { $0 == term }
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }

    private func clearAllRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: recentSearchesKey)
    }
}

#Preview {
    let apiClient = MockAPIClient()
    NavigationStack {
        SearchView(userId: "preview-user", syncManager: nil, onDismiss: {})
    }
    .environment(\.apiClient, apiClient)
}

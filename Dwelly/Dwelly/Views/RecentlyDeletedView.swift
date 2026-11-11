import SwiftUI

/// T-176: browse/restore soft-deleted journal entries, reached from Settings (not from
/// the Entries list itself -- Kell's explicit call, keeps the active list uncluttered).
/// Soft delete itself (`moments.deleted_at`) was built in T-158; this is the one place a
/// user can actually see and act on what's sitting in that 30-day window, plus the one
/// place "Delete Forever" is genuinely, irreversibly permanent (unlike Delete Entry,
/// which this screen's own existence is what makes recoverable).
struct RecentlyDeletedView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.apiClient) private var apiClient
    let userId: String

    @State private var deletedMoments: [Moment] = []
    // Keyed by moment id -- best-effort title lookup (a moment that never finished
    // synthesis, or predates T-152, has no JournalEntry at all; falls back to a
    // truncated body snippet in that case, same as the rest of the app does).
    @State private var titles: [String: String] = [:]
    @State private var isLoading = true
    @State private var restoringId: String?
    @State private var momentPendingPermanentDelete: Moment?
    @State private var errorMessage: String?

    private static let thirtyDays: TimeInterval = 30 * 24 * 60 * 60

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    Button(action: { dismiss() }) {
                        Text("‹")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.tertiaryText)
                    }
                    Text("Recently Deleted")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Theme.tertiaryText)
                    Spacer()
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.vertical, Theme.Spacing.md)

                if isLoading {
                    Spacer()
                    ProgressView().tint(Theme.gold)
                    Spacer()
                } else if deletedMoments.isEmpty {
                    Spacer()
                    Text("Nothing here right now.")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.tertiaryText)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: Theme.Spacing.md) {
                            if let errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.error)
                            }

                            ForEach(deletedMoments) { moment in
                                row(for: moment)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.xl)
                        .padding(.vertical, Theme.Spacing.lg)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Delete forever?", isPresented: Binding(
            get: { momentPendingPermanentDelete != nil },
            set: { if !$0 { momentPendingPermanentDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Forever", role: .destructive) {
                if let moment = momentPendingPermanentDelete {
                    Task { await permanentlyDelete(moment) }
                }
            }
        } message: {
            Text("This can't be undone. This entry will be gone for good.")
        }
        .task { await load() }
    }

    private func row(for moment: Moment) -> some View {
        let daysRemaining = daysRemaining(for: moment)
        return VStack(alignment: .leading, spacing: 8) {
            Text(titles[moment.id] ?? String(moment.body.prefix(60)))
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Theme.text)
                .lineLimit(1)

            HStack(spacing: 6) {
                if let deletedAt = moment.deletedAt {
                    Text("Deleted \(deletedAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.tertiaryText)
                }
                Text("·")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.tertiaryText)
                Text(daysRemaining <= 1 ? "1 day left" : "\(daysRemaining) days left")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(daysRemaining <= 3 ? Theme.error : Theme.tertiaryText)
            }

            HStack(spacing: Theme.Spacing.md) {
                Button(action: { Task { await restore(moment) } }) {
                    if restoringId == moment.id {
                        ProgressView().tint(Theme.gold)
                    } else {
                        Text("Restore")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.gold)
                    }
                }
                .disabled(restoringId != nil)

                Button(action: { momentPendingPermanentDelete = moment }) {
                    Text("Delete Forever")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Theme.error)
                }
                .disabled(restoringId != nil)
            }
            .padding(.top, 4)
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surfaceBackground)
        .cornerRadius(10)
    }

    private func daysRemaining(for moment: Moment) -> Int {
        guard let deletedAt = moment.deletedAt else { return 30 }
        let elapsed = Date().timeIntervalSince(deletedAt)
        let remaining = Self.thirtyDays - elapsed
        return max(0, Int(ceil(remaining / 86400)))
    }

    private func load() async {
        isLoading = true
        guard let moments = try? await apiClient.fetchDeletedMoments(userId: userId) else {
            isLoading = false
            return
        }
        deletedMoments = moments
        isLoading = false

        // Best-effort title lookups, one per moment -- not worth a batch endpoint
        // for a list that's rarely more than a handful of entries at once.
        for moment in moments {
            if let entry = try? await apiClient.fetchJournalEntry(momentId: moment.id), let title = entry.title {
                titles[moment.id] = title
            }
        }
    }

    private func restore(_ moment: Moment) async {
        restoringId = moment.id
        errorMessage = nil
        do {
            try await apiClient.restoreMoment(id: moment.id)
            deletedMoments.removeAll { $0.id == moment.id }
        } catch {
            errorMessage = "Couldn't restore — check your connection and try again."
        }
        restoringId = nil
    }

    private func permanentlyDelete(_ moment: Moment) async {
        errorMessage = nil
        do {
            try await apiClient.permanentlyDeleteMoment(id: moment.id)
            deletedMoments.removeAll { $0.id == moment.id }
        } catch {
            errorMessage = "Couldn't delete — check your connection and try again."
        }
    }
}

#Preview {
    let apiClient = MockAPIClient()
    NavigationStack {
        RecentlyDeletedView(userId: "preview-user")
    }
    .environment(\.apiClient, apiClient)
}

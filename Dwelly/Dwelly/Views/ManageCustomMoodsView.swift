import SwiftUI

/// T-294: lets a user see and delete their own saved mood vocabulary (the words they've
/// typed into the Journal Mood Sheet's "Add your own word" field, capped at
/// `maxCustomMoods`) -- reached from Settings, same pattern as `RecentlyDeletedView`.
/// Deleting one here frees a slot under that cap; it does not touch any past journal
/// entry that already used the word, only whether it's offered again going forward.
struct ManageCustomMoodsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.apiClient) private var apiClient
    let userId: String

    @State private var customMoods: [CustomMood] = []
    @State private var isLoading = true
    @State private var deletingId: String?
    @State private var errorMessage: String?

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
                    Text("Custom Moods")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Theme.tertiaryText)
                    Spacer()
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.vertical, Theme.Spacing.md)

                Text("\(customMoods.count) / \(maxCustomMoods) used")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.tertiaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Theme.Spacing.xl)
                    .padding(.bottom, Theme.Spacing.md)

                if isLoading {
                    Spacer()
                    ProgressView().tint(Theme.gold)
                    Spacer()
                } else if customMoods.isEmpty {
                    Spacer()
                    Text("No custom moods yet. Add one from any journal entry's Mood Sheet.")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.tertiaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.xl)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            if let errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.error)
                            }

                            // Kell's call (Nov 16 2026): same pill language as the Mood
                            // Sheet itself (Theme.Payment.pillBackground fill, textHeading
                            // text), just scaled up -- this is a bigger version of that
                            // same chip, not a settings list row. The checkmark there
                            // becomes an "x" here: the action on this screen is remove,
                            // not select.
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 12)], alignment: .leading, spacing: 12) {
                                ForEach(customMoods) { mood in
                                    pill(for: mood)
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.xl)
                        .padding(.vertical, Theme.Spacing.lg)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .task { await load() }
    }

    private func pill(for mood: CustomMood) -> some View {
        Button(action: { Task { await delete(mood) } }) {
            HStack(spacing: 10) {
                Text(mood.word)
                    .font(.system(size: 17))
                    .foregroundColor(Theme.Payment.textHeading)
                if deletingId == mood.id {
                    ProgressView().tint(Theme.Payment.textSupporting)
                } else {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Theme.Payment.textSupporting)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(Theme.Payment.pillBackground)
            .clipShape(Capsule())
        }
        .disabled(deletingId != nil)
    }

    private func load() async {
        isLoading = true
        customMoods = (try? await apiClient.fetchCustomMoods(userId: userId)) ?? []
        isLoading = false
    }

    private func delete(_ mood: CustomMood) async {
        deletingId = mood.id
        errorMessage = nil
        do {
            try await apiClient.deleteCustomMood(id: mood.id)
            customMoods.removeAll { $0.id == mood.id }
        } catch {
            errorMessage = "Couldn't delete — check your connection and try again."
        }
        deletingId = nil
    }
}

#Preview {
    let apiClient = MockAPIClient()
    NavigationStack {
        ManageCustomMoodsView(userId: "preview-user")
    }
    .environment(\.apiClient, apiClient)
}

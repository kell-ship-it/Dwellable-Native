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
                        VStack(spacing: Theme.Spacing.md) {
                            if let errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.error)
                            }

                            ForEach(customMoods) { mood in
                                row(for: mood)
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

    private func row(for mood: CustomMood) -> some View {
        HStack {
            Text(mood.word)
                .font(.system(size: 14))
                .foregroundColor(Theme.text)
            Spacer()
            Button(action: { Task { await delete(mood) } }) {
                if deletingId == mood.id {
                    ProgressView().tint(Theme.error)
                } else {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.error)
                }
            }
            .disabled(deletingId != nil)
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.surfaceBackground)
        .cornerRadius(10)
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

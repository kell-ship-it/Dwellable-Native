import SwiftUI

struct MomentsListView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var moments: [Moment] = []
    @State private var isLoading = true
    @State private var error: String?
    @State private var refreshTrigger = UUID()

    let apiClient: APIClient
    let userId: String
    let syncManager: SyncManager

    init(apiClient: APIClient, userId: String, syncManager: SyncManager) {
        self.apiClient = apiClient
        self.userId = userId
        self.syncManager = syncManager
    }

    private func fetchMoments() async {
        isLoading = true
        error = nil

        do {
            let fetchedMoments = try await apiClient.fetchMoments(userId: userId)
            DispatchQueue.main.async {
                self.moments = fetchedMoments
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if isLoading {
                VStack(spacing: 0) {
                    Spacer()
                    ProgressView()
                        .tint(Theme.gold)
                    Spacer()
                }
            } else if let error = error {
                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 20) {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(Color(red: 0.95, green: 0.2, blue: 0.2))

                            Text("Failed to load moments")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.text)

                            Text(error)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(Theme.secondaryText)
                                .multilineTextAlignment(.center)
                        }

                        Button(action: {
                            Task {
                                await fetchMoments()
                            }
                        }) {
                            Text("Try Again")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.05))
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Theme.gold)
                                .cornerRadius(18)
                        }
                        .padding(.horizontal, 32)
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
            } else if moments.isEmpty {
                VStack(spacing: 0) {
                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Moments")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(Theme.text)

                            Text("Document life. Discern over time.")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(Theme.secondaryText)
                        }

                        Spacer()

                        HStack(spacing: 12) {
                            Button(action: {
                                Task {
                                    await fetchMoments()
                                }
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(Theme.tertiaryText)
                            }

                            Button(action: {
                                Task {
                                    await authManager.signOut()
                                }
                            }) {
                                Text("Sign out")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(Theme.tertiaryText)
                            }
                        }
                    }
                    .padding(20)

                    Spacer()

                    VStack(spacing: 24) {
                        // Circle with dot
                        ZStack {
                            Circle()
                                .stroke(Color(red: 0.25, green: 0.27, blue: 0.31), lineWidth: 1)
                                .frame(width: 64, height: 64)

                            Circle()
                                .fill(Color(red: 0.6, green: 0.64, blue: 0.71))
                                .frame(width: 6, height: 6)
                        }

                        VStack(spacing: 12) {
                            Text("No moments yet.")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(Theme.text)

                            Text("Start small — a thought, a feeling, a prayer. Anything worth holding onto.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Theme.secondaryText)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 220)
                        }

                        NavigationLink(destination: CaptureView(apiClient: apiClient, userId: userId, syncManager: syncManager, onMomentSaved: {
                            refreshTrigger = UUID()
                        })) {
                            Text("Capture your first moment")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.05))
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(Theme.gold)
                                .cornerRadius(22)
                        }
                        .padding(.horizontal, 32)
                    }

                    Spacer()
                }
            } else {
                VStack(spacing: 0) {
                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Moments")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(Theme.text)

                            Text("Document life. Discern over time.")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(Theme.secondaryText)
                        }

                        Spacer()

                        HStack(spacing: 12) {
                            Button(action: {
                                Task {
                                    await fetchMoments()
                                }
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(Theme.tertiaryText)
                            }

                            Button(action: {
                                Task {
                                    await authManager.signOut()
                                }
                            }) {
                                Text("Sign out")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(Theme.tertiaryText)
                            }
                        }
                    }
                    .padding(20)

                    List(moments) { moment in
                        NavigationLink(destination: MomentDetailView(moment: moment)) {
                            MomentRow(moment: moment)
                        }
                        .listRowBackground(Theme.background)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)

                    // Bottom "Capture moment" button
                    VStack {
                        NavigationLink(destination: CaptureView(apiClient: apiClient, userId: userId, syncManager: syncManager, onMomentSaved: {
                            refreshTrigger = UUID()
                        })) {
                            Text("Capture moment")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.05))
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(Theme.gold)
                                .cornerRadius(22)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .onAppear {
            Task {
                await fetchMoments()
            }
        }
        .task(id: refreshTrigger) {
            await fetchMoments()
        }
    }

}

struct MomentRow: View {
    let moment: Moment

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(moment.body)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Theme.text)
                .lineLimit(2)

            Text(moment.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Theme.secondaryText)
        }
        .padding(12)
    }
}

#Preview {
    let apiClient = MockAPIClient()
    MomentsListView(apiClient: apiClient, userId: "preview-user", syncManager: SyncManager(apiClient: apiClient))
        .environmentObject(AuthManager(apiClient: apiClient))
}

struct MomentDetailView: View {
    @Environment(\.dismiss) var dismiss
    let moment: Moment

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button with date
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        Button(action: { dismiss() }) {
                            Text("‹")
                                .font(.system(size: 20))
                                .foregroundColor(Theme.tertiaryText)
                        }
                        Button(action: { dismiss() }) {
                            Text("Moments")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Theme.tertiaryText)
                        }
                        Spacer()
                    }

                    Text(moment.createdAt.formatted(date: .abbreviated, time: .omitted).uppercased())
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Theme.tertiaryText)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                // Full moment text
                VStack(spacing: 0) {
                    ScrollView {
                        Text(moment.body)
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(Theme.text)
                            .lineSpacing(1.8)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

import SwiftUI

struct MomentsListView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var moments: [Moment] = []
    @State private var isLoading = true
    @State private var error: String?
    @State private var refreshTrigger = UUID()
    @State private var showCapture = false
    @State private var isOffline = false

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
                self.isOffline = false
            }
        } catch {
            // Network error — load from local storage instead
            print("🔴 Network fetch failed: \(error.localizedDescription)")
            let localMoments = LocalStorageManager.shared.getAllLocalMoments()
            DispatchQueue.main.async {
                self.moments = localMoments
                self.isLoading = false
                self.isOffline = !localMoments.isEmpty
                self.error = localMoments.isEmpty ? error.localizedDescription : nil
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
                                .foregroundColor(Theme.error)

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
                                .foregroundColor(Theme.goldDark)
                                .frame(maxWidth: .infinity)
                                .padding(Theme.Button.secondaryPadding)
                                .background(Theme.gold)
                                .cornerRadius(Theme.Button.primaryCornerRadius)
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
                                .stroke(Theme.borderMuted, lineWidth: 1)
                                .frame(width: 64, height: 64)

                            Circle()
                                .fill(Theme.circleStroke)
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

                        Button(action: { showCapture = true }) {
                            Text("Capture your first moment")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.goldDark)
                                .frame(maxWidth: .infinity)
                                .padding(Theme.Button.primaryPadding)
                                .background(Theme.gold)
                                .cornerRadius(Theme.Button.primaryCornerRadius)
                        }
                        .padding(.horizontal, Theme.Spacing.xxl)
                        .accessibilityIdentifier("Capture your first moment")
                    }

                    Spacer()
                }
            } else {
                VStack(spacing: 0) {
                    // Offline indicator
                    if isOffline {
                        HStack(spacing: Theme.Spacing.sm) {
                            Image(systemName: "wifi.slash")
                                .font(.system(size: 10, weight: .regular))
                            Text("Offline — showing cached moments")
                                .font(.system(size: 11, weight: .regular))
                            Spacer()
                        }
                        .foregroundColor(Theme.secondaryText)
                        .padding(.horizontal, Theme.Spacing.xl)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(Theme.offlineIndicator)
                    }

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
                    .accessibilityIdentifier("MomentsList")

                    // Bottom "Capture moment" button
                    VStack {
                        Button(action: { showCapture = true }) {
                            Text("Capture moment")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.goldDark)
                                .frame(maxWidth: .infinity)
                                .padding(Theme.Button.primaryPadding)
                                .background(Theme.gold)
                                .cornerRadius(Theme.Button.primaryCornerRadius)
                        }
                        .accessibilityIdentifier("Capture moment")
                    }
                    .padding(Theme.Spacing.lg)
                }
            }
        }
        .navigationDestination(isPresented: $showCapture) {
            CaptureView(apiClient: apiClient, userId: userId, syncManager: syncManager, onMomentSaved: {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    showCapture = false
                }
                refreshTrigger = UUID()
            })
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

#Preview {
    let apiClient = MockAPIClient()
    MomentsListView(apiClient: apiClient, userId: "preview-user", syncManager: SyncManager(apiClient: apiClient))
        .environmentObject(AuthManager(apiClient: apiClient))
}

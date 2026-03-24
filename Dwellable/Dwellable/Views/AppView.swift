import SwiftUI

struct AppView: View {
    @EnvironmentObject var authManager: AuthManager
    let apiClient: APIClient
    let syncManager: SyncManager

    var body: some View {
        // AppView is only shown when authenticated, so we can safely force-unwrap currentUser
        if let user = authManager.currentUser {
            NavigationStack {
                MomentsListView(apiClient: apiClient, userId: user.id, syncManager: syncManager)
            }
            .environment(\.colorScheme, .dark)
            .onAppear {
                // Set real userId on SyncManager (replaces placeholder "app-sync")
                syncManager.updateUserId(user.id)
                syncManager.syncPendingMoments()

                // Log app session
                print("🔍 AppView: Logging app_opened — userId: \(user.id.prefix(8)), email: \(user.email)")
                UsageTracker.shared.logAppOpened(userId: user.id, userEmail: user.email)

                // Sync analytics to backend
                Task {
                    do {
                        try await UsageTracker.shared.syncEventsToBackend(userId: user.id, apiClient: apiClient)
                    } catch {
                        print("⚠️ Analytics sync failed: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            // Fallback if currentUser is nil (shouldn't happen in normal flow)
            ProgressView("Loading...")
                .environment(\.colorScheme, .dark)
        }
    }
}

#Preview {
    let apiClient = MockAPIClient()
    let syncManager = SyncManager(apiClient: apiClient, userId: "preview-user")
    AppView(apiClient: apiClient, syncManager: syncManager)
        .environmentObject(AuthManager(apiClient: apiClient))
}

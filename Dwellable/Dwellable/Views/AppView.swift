import SwiftUI

struct AppView: View {
    @EnvironmentObject var authManager: AuthManager
    let apiClient: APIClient

    var body: some View {
        // AppView is only shown when authenticated, so we can safely force-unwrap currentUser
        if let user = authManager.currentUser {
            // Create SyncManager with userId for proper multi-account isolation
            let syncManager = SyncManager(apiClient: apiClient, userId: user.id)
            NavigationStack {
                MomentsListView(apiClient: apiClient, userId: user.id, syncManager: syncManager)
            }
            .environment(\.colorScheme, .dark)
        } else {
            // Fallback if currentUser is nil (shouldn't happen in normal flow)
            ProgressView("Loading...")
                .environment(\.colorScheme, .dark)
        }
    }
}

#Preview {
    let apiClient = MockAPIClient()
    AppView(apiClient: apiClient)
        .environmentObject(AuthManager(apiClient: apiClient))
}

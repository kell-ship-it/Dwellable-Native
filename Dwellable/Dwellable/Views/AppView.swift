import SwiftUI

struct AppView: View {
    @EnvironmentObject var authManager: AuthManager
    let apiClient: APIClient
    let syncManager: SyncManager

    var body: some View {
        if authManager.isAuthenticated, let user = authManager.currentUser {
            NavigationStack {
                MomentsListView(apiClient: apiClient, userId: user.id, syncManager: syncManager)
            }
            .environment(\.colorScheme, .dark)
        } else {
            LoginView()
                .environment(\.colorScheme, .dark)
        }
    }
}

#Preview {
    let apiClient = MockAPIClient()
    let syncManager = SyncManager(apiClient: apiClient)
    AppView(apiClient: apiClient, syncManager: syncManager)
        .environmentObject(AuthManager(apiClient: apiClient))
}

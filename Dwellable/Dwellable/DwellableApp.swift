import SwiftUI

@main
struct DwellableApp: App {
    @StateObject private var authManager: AuthManager
    private let apiClient: APIClient
    private let syncManager: SyncManager

    init() {
        let apiClient = SupabaseAPIClient()
        self.apiClient = apiClient
        self.syncManager = SyncManager(apiClient: apiClient)
        _authManager = StateObject(wrappedValue: AuthManager(apiClient: apiClient))
    }

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                AppView(apiClient: apiClient, syncManager: syncManager)
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}

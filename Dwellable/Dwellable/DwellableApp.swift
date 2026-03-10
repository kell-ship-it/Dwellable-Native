import SwiftUI

@main
struct DwellableApp: App {
    @StateObject private var authManager: AuthManager
    private let apiClient: APIClient
    private let syncManager: SyncManager

    init() {
        // Auto-detect test environment and use appropriate client
        let resolvedClient: APIClient

        // Check if XCTest is loaded (indicates we're running tests)
        if NSClassFromString("XCTest") != nil {
            // Use MockAPIClient when running XCUI tests
            resolvedClient = MockAPIClient()
        } else {
            // Use real Supabase client in production
            resolvedClient = SupabaseAPIClient()
        }

        self.apiClient = resolvedClient
        self.syncManager = SyncManager(apiClient: resolvedClient)
        _authManager = StateObject(wrappedValue: AuthManager(apiClient: resolvedClient))
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

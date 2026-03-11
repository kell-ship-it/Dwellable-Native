import SwiftUI

@main
struct DwellableApp: App {
    @StateObject private var authManager: AuthManager
    private let apiClient: APIClient
    @StateObject private var syncManager: SyncManager

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
        _authManager = StateObject(wrappedValue: AuthManager(apiClient: resolvedClient))
        // B-013 Fix: Create SyncManager at app startup with placeholder userId
        // It will be used for all users; userId is passed per-view
        _syncManager = StateObject(wrappedValue: SyncManager(apiClient: resolvedClient, userId: "app-sync"))
    }

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                AppView(apiClient: apiClient, syncManager: syncManager)
                    .environmentObject(authManager)
                    .onAppear {
                        // Sync analytics when app launches
                        if let userId = authManager.currentUser?.id {
                            syncAnalytics(userId: userId)
                        }
                    }
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }

    private func syncAnalytics(userId: String) {
        Task {
            do {
                try await UsageTracker.shared.syncEventsToBackend(userId: userId, apiClient: apiClient)
            } catch {
                print("⚠️ Analytics sync failed: \(error.localizedDescription)")
            }
        }
    }
}

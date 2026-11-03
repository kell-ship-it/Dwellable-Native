import SwiftUI

// MARK: - APIClient Environment Key

/// Allows any SwiftUI View to access the APIClient via @Environment(\.apiClient).
/// This eliminates passing protocol existentials through nested init chains,
/// which can crash on iPad due to SwiftUI's navigationDestination metadata layout.

private struct APIClientKey: EnvironmentKey {
    static let defaultValue: APIClient = MockAPIClient()
}

extension EnvironmentValues {
    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}

import SwiftUI

#if DEBUG
/// DEBUG-ONLY (compiled out of release builds). Launch the app with
/// `-CrisisSupportUIHarness` to open the REAL CaptureConversationView against
/// MockAPIClient with `omitCaptureSafetyTier = true` -- the same no-verdict response
/// shape today's deployed llm-proxy returns -- so Crisis Support's on-screen states
/// can be seen and screenshotted with no network calls and no live database writes.
/// Not reachable from any in-app navigation.
struct CrisisSupportUIHarnessView: View {
    static var isRequested: Bool {
        ProcessInfo.processInfo.arguments.contains("-CrisisSupportUIHarness")
    }

    private let client: MockAPIClient
    @StateObject private var syncManager: SyncManager

    init() {
        let mock = MockAPIClient()
        mock.omitCaptureSafetyTier = true
        client = mock
        _syncManager = StateObject(wrappedValue: SyncManager(apiClient: mock, userId: "crisis-support-ui-harness"))
    }

    var body: some View {
        NavigationStack {
            CaptureConversationView(userId: "crisis-support-ui-harness", userEmail: nil, syncManager: syncManager)
        }
        .environment(\.apiClient, client)
    }
}
#endif

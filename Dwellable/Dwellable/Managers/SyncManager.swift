import Foundation
import Network

class SyncManager: ObservableObject {
    @Published var isSyncing = false
    @Published var hasPendingMoments = false
    @Published var lastSyncError: String?
    @Published var isOnline = true

    private let apiClient: APIClient
    private let localStorage = LocalStorageManager.shared
    private let monitor = NWPathMonitor()
    private var syncTimer: Timer?
    private var userId: String

    init(apiClient: APIClient, userId: String) {
        self.apiClient = apiClient
        self.userId = userId
        startMonitoringConnectivity()
    }

    func updateUserId(_ newUserId: String) {
        self.userId = newUserId
        updatePendingStatus()
    }

    deinit {
        monitor.cancel()
        syncTimer?.invalidate()
    }

    // MARK: - Network Monitoring

    private func startMonitoringConnectivity() {
        let queue = DispatchQueue(label: "com.dwellable.network-monitor")
        monitor.start(queue: queue)

        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let wasOnline = self?.isOnline ?? false
                self?.isOnline = path.status == .satisfied

                // If just came online, try syncing immediately
                if !wasOnline && self?.isOnline == true {
                    self?.syncPendingMoments()
                    // Also sync any pending usage events
                    if let userId = self?.userId, let apiClient = self?.apiClient {
                        Task {
                            try? await UsageTracker.shared.syncEventsToBackend(userId: userId, apiClient: apiClient)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Sync Operations

    func syncPendingMoments() {
        let pending = localStorage.getPendingMoments(userId: userId)
        guard !pending.isEmpty, !isSyncing, isOnline else {
            return
        }

        isSyncing = true
        lastSyncError = nil

        Task {
            for moment in pending {
                do {
                    let synced = try await apiClient.saveMoment(moment)
                    localStorage.removePendingMoment(id: moment.id, userId: self.userId)
                    localStorage.saveSyncedMoment(synced, userId: self.userId)

                    DispatchQueue.main.async {
                        self.updatePendingStatus()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.lastSyncError = error.localizedDescription
                        self.isSyncing = false
                    }
                    return // Stop on first error, retry later
                }
            }

            // After moments sync, also sync any pending usage events
            do {
                try await UsageTracker.shared.syncEventsToBackend(userId: self.userId, apiClient: self.apiClient)
            } catch { }

            DispatchQueue.main.async {
                self.isSyncing = false
                self.updatePendingStatus()
            }
        }
    }

    func updatePendingStatus() {
        hasPendingMoments = !localStorage.getPendingMoments(userId: userId).isEmpty
    }

    func markMomentAsPending(_ moment: Moment) {
        localStorage.savePendingMoment(moment, userId: userId)
        updatePendingStatus()

        // Start periodic retry attempts if not already syncing
        if !isSyncing {
            startPeriodicSync()
        }
    }

    private func startPeriodicSync() {
        syncTimer?.invalidate()
        syncTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.syncPendingMoments()
        }
    }
}

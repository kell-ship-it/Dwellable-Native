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
        let queue = DispatchQueue(label: "com.dwelly.network-monitor")
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

            // T-159 fast path -- see retryPendingJournalEntries' own doc comment.
            await self.retryPendingJournalEntries()
            // T-176 fast path -- see purgeExpiredDeletedMoments' own doc comment.
            await self.purgeExpiredDeletedMoments()

            DispatchQueue.main.async {
                self.isSyncing = false
                self.updatePendingStatus()
            }
        }
    }

    /// T-159, fast-path mechanism: whenever a sync pass runs (new-capture save, or the
    /// moment-pending retry loop above), also sweep every pending `JournalEntry` for this
    /// user and retry synthesis. Entries are independent LLM calls against independent
    /// transcripts -- one completing has no bearing on another -- this is just a
    /// convenient, frequent hook, not a claim they're related. The other mechanism
    /// (DwellyApp's BGTaskScheduler job) is the guarantee that runs even if the user
    /// never triggers a sync; this just tends to be faster in practice for an actively
    /// journaling user. Best-effort throughout: a single entry failing to re-synthesize
    /// just leaves it pending for the next sweep, not an error surfaced anywhere.
    func retryPendingJournalEntries() async {
        guard isOnline else { return }
        guard let pending = try? await apiClient.fetchPendingJournalEntries(userId: userId), !pending.isEmpty else { return }

        for entry in pending {
            guard let moment = try? await apiClient.fetchMoment(id: entry.momentId) else { continue }
            // Only the user's own words are available here, not Dwelly's side of the
            // conversation (that's never persisted anywhere -- see
            // CaptureConversationView.fullTranscript's own comment) -- a retried
            // synthesis is real, just with less conversational context than the
            // original attempt had.
            let userWordCount = moment.body.split(whereSeparator: { $0.isWhitespace }).count
            guard let result = try? await JournalSynthesisManager.synthesize(transcript: moment.body, userWordCount: userWordCount, apiClient: apiClient) else { continue }

            var updated = entry
            updated.status = "approved"
            updated.title = result.title
            updated.body = result.body
            updated.moods = result.moods
            updated.scriptureQuote = result.scriptureQuote
            updated.scriptureReference = result.scriptureReference
            _ = try? await apiClient.saveJournalEntry(updated)
        }
    }

    /// T-176: the actual 30-day purge the Recently Deleted screen's own copy promises
    /// ("permanently removed after 30 days"). Soft-deleting (T-158) only ever hid an
    /// entry from normal browsing -- something still has to make "after 30 days" real,
    /// since nothing else in the app runs on a calendar. Same two-mechanism pattern as
    /// `retryPendingJournalEntries` (piggyback here + DwellyApp's BGTaskScheduler job),
    /// sharing this one sweep rather than a second parallel background system.
    func purgeExpiredDeletedMoments() async {
        guard isOnline else { return }
        guard let deleted = try? await apiClient.fetchDeletedMoments(userId: userId), !deleted.isEmpty else { return }

        let thirtyDaysAgo = Date(timeIntervalSinceNow: -30 * 24 * 60 * 60)
        for moment in deleted {
            guard let deletedAt = moment.deletedAt, deletedAt < thirtyDaysAgo else { continue }
            _ = try? await apiClient.permanentlyDeleteMoment(id: moment.id)
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

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
            // T-251: this pending-moments pass reaching here at all means every
            // queued moment made it to the server -- exactly what "a confirmed
            // server sync" means for the dormancy clock. Best-effort: a failed touch
            // just leaves last_synced_at slightly stale, not worth surfacing as a
            // sync error to the user.
            try? await self.apiClient.touchLastSynced(userId: self.userId)

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
            // The retry passes the same role-labelled transcript the first attempt used
            // (`moment.synthesisTranscript`, "Me:"/"Dwelly:" turns for current moments) plus
            // the user's own words (`moment.userWords`) as the separate user-only input.
            // T-127 (rebuilt Nov 17 2026): same one-call decision
            // CaptureConversationView.generateJournalMeta uses on the first attempt -- no
            // deterministic pre-check.
            // T-125: `entry.profileExcluded` is the ORIGINAL exclusion decision,
            // persisted at the first save attempt (CaptureConversationView.finishAndSave)
            // from that conversation's own safety tiers -- this retry has no access to
            // those tiers itself (only `moment.body`/`entry` survive to this point), so
            // it reads the decision back rather than silently losing it and falling
            // back to the substance-only gate alone.
            guard let result = try? await JournalSynthesisManager.synthesize(transcript: moment.synthesisTranscript, userOnlyText: moment.userWords, policyExcluded: entry.profileExcluded, apiClient: apiClient) else { continue }

            let updated = JournalRetryApplier.applying(
                .init(title: result.title, body: result.body, moods: result.moods,
                      scriptureQuote: result.scriptureQuote, scriptureReference: result.scriptureReference,
                      formationEligible: result.formationEligible, extractedFacts: result.extractedFacts),
                to: entry)
            // T-274/T-127: same formation-eligibility gate as the first-attempt path.
            // Save failure => entry stays pending, profile untouched (see applier).
            _ = await JournalRetryApplier.persist(
                updated,
                save: { try await self.apiClient.saveJournalEntry($0) },
                feedProfile: { await DwellerProfileManager.updateRunningSummary(newEntryBody: $0, userId: self.userId, apiClient: self.apiClient) }
            )
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

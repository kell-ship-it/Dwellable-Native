import Foundation

class LocalStorageManager {
    static let shared = LocalStorageManager()

    private let pendingMomentsKey = "pending_moments"
    private let syncedMomentsKey = "synced_moments"

    // MARK: - Pending Moments (awaiting sync)

    func savePendingMoment(_ moment: Moment) {
        var pending = getPendingMoments()
        pending.append(moment)
        if let encoded = try? JSONEncoder().encode(pending) {
            UserDefaults.standard.set(encoded, forKey: pendingMomentsKey)
        }
    }

    func getPendingMoments() -> [Moment] {
        guard let data = UserDefaults.standard.data(forKey: pendingMomentsKey) else {
            return []
        }
        return (try? JSONDecoder().decode([Moment].self, from: data)) ?? []
    }

    func removePendingMoment(id: String) {
        var pending = getPendingMoments()
        pending.removeAll { $0.id == id }
        if let encoded = try? JSONEncoder().encode(pending) {
            UserDefaults.standard.set(encoded, forKey: pendingMomentsKey)
        }
    }

    func clearAllPending() {
        UserDefaults.standard.removeObject(forKey: pendingMomentsKey)
    }

    // MARK: - Synced Moments (confirmed on server)

    func saveSyncedMoment(_ moment: Moment) {
        var synced = getSyncedMoments()
        // Remove if already exists (update case)
        synced.removeAll { $0.id == moment.id }
        synced.append(moment)
        if let encoded = try? JSONEncoder().encode(synced) {
            UserDefaults.standard.set(encoded, forKey: syncedMomentsKey)
        }
    }

    func getSyncedMoments() -> [Moment] {
        guard let data = UserDefaults.standard.data(forKey: syncedMomentsKey) else {
            return []
        }
        return (try? JSONDecoder().decode([Moment].self, from: data)) ?? []
    }

    func removeSyncedMoment(id: String) {
        var synced = getSyncedMoments()
        synced.removeAll { $0.id == id }
        if let encoded = try? JSONEncoder().encode(synced) {
            UserDefaults.standard.set(encoded, forKey: syncedMomentsKey)
        }
    }

    // MARK: - Combined

    func getAllLocalMoments() -> [Moment] {
        let pending = getPendingMoments()
        let synced = getSyncedMoments()
        return (pending + synced).sorted { $0.createdAt > $1.createdAt }
    }
}

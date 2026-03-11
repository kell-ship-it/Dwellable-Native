import Foundation

class LocalStorageManager {
    static let shared = LocalStorageManager()

    private func pendingMomentsKey(userId: String) -> String {
        "pending_moments_\(userId)"
    }

    private func syncedMomentsKey(userId: String) -> String {
        "synced_moments_\(userId)"
    }

    // MARK: - Pending Moments (awaiting sync)

    func savePendingMoment(_ moment: Moment, userId: String) {
        var pending = getPendingMoments(userId: userId)
        pending.append(moment)
        if let encoded = try? JSONEncoder().encode(pending) {
            UserDefaults.standard.set(encoded, forKey: pendingMomentsKey(userId: userId))
        }
    }

    func getPendingMoments(userId: String) -> [Moment] {
        guard let data = UserDefaults.standard.data(forKey: pendingMomentsKey(userId: userId)) else {
            return []
        }
        return (try? JSONDecoder().decode([Moment].self, from: data)) ?? []
    }

    func removePendingMoment(id: String, userId: String) {
        var pending = getPendingMoments(userId: userId)
        pending.removeAll { $0.id == id }
        if let encoded = try? JSONEncoder().encode(pending) {
            UserDefaults.standard.set(encoded, forKey: pendingMomentsKey(userId: userId))
        }
    }

    func clearAllPending(userId: String) {
        UserDefaults.standard.removeObject(forKey: pendingMomentsKey(userId: userId))
    }

    // MARK: - Synced Moments (confirmed on server)

    func saveSyncedMoment(_ moment: Moment, userId: String) {
        var synced = getSyncedMoments(userId: userId)
        // Remove if already exists (update case)
        synced.removeAll { $0.id == moment.id }
        synced.append(moment)
        if let encoded = try? JSONEncoder().encode(synced) {
            UserDefaults.standard.set(encoded, forKey: syncedMomentsKey(userId: userId))
        }
    }

    func getSyncedMoments(userId: String) -> [Moment] {
        guard let data = UserDefaults.standard.data(forKey: syncedMomentsKey(userId: userId)) else {
            return []
        }
        return (try? JSONDecoder().decode([Moment].self, from: data)) ?? []
    }

    func removeSyncedMoment(id: String, userId: String) {
        var synced = getSyncedMoments(userId: userId)
        synced.removeAll { $0.id == id }
        if let encoded = try? JSONEncoder().encode(synced) {
            UserDefaults.standard.set(encoded, forKey: syncedMomentsKey(userId: userId))
        }
    }

    func replaceSyncedMoments(_ moments: [Moment], userId: String) {
        if let encoded = try? JSONEncoder().encode(moments) {
            UserDefaults.standard.set(encoded, forKey: syncedMomentsKey(userId: userId))
        }
    }

    // MARK: - Combined

    func getAllLocalMoments(userId: String) -> [Moment] {
        let pending = getPendingMoments(userId: userId)
        let synced = getSyncedMoments(userId: userId)
        return (pending + synced).sorted { $0.createdAt > $1.createdAt }
    }
}

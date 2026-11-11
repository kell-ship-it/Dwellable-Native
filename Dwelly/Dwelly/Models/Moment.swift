import Foundation

struct Moment: Identifiable, Codable {
    let id: String
    let userId: String
    let body: String
    let senseOfLord: String?
    let createdAt: Date
    var syncedAt: Date?
    let audioURL: String?  // Local filename for original audio (e.g., "moment_12345.m4a")
    // T-176: only ever populated by fetchDeletedMoments (fetch-moments' own list query
    // still excludes soft-deleted rows, see T-158) -- nil everywhere else. Drives the
    // Recently Deleted screen's "days remaining" countdown.
    let deletedAt: Date?

    init(
        id: String = UUID().uuidString,
        userId: String,
        body: String,
        senseOfLord: String? = nil,
        createdAt: Date = Date(),
        syncedAt: Date? = nil,
        audioURL: String? = nil,
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.body = body
        self.senseOfLord = senseOfLord
        self.createdAt = createdAt
        self.syncedAt = syncedAt
        self.audioURL = audioURL
        self.deletedAt = deletedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case body
        case senseOfLord = "sense_of_lord"
        case createdAt = "created_at"
        case syncedAt = "synced_at"
        case audioURL = "audio_url"
        case deletedAt = "deleted_at"
    }
}

import Foundation

struct Moment: Identifiable, Codable {
    let id: String
    let userId: String
    let body: String
    let senseOfLord: String?
    let createdAt: Date
    var syncedAt: Date?

    init(
        id: String = UUID().uuidString,
        userId: String,
        body: String,
        senseOfLord: String? = nil,
        createdAt: Date = Date(),
        syncedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.body = body
        self.senseOfLord = senseOfLord
        self.createdAt = createdAt
        self.syncedAt = syncedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case body
        case senseOfLord = "sense_of_lord"
        case createdAt = "created_at"
        case syncedAt = "synced_at"
    }
}

import Foundation

/// T-133: a row from the Support & Feedback screen's "Send Feedback" or "Report a Bug"
/// card (Figma node 689:329). `type` is the only thing distinguishing the two -- same
/// table, same columns, same submit path.
enum FeedbackType: String, Codable {
    case feedback
    case bug
}

struct FeedbackSubmission: Codable, Identifiable {
    let id: String
    let userId: String
    let type: FeedbackType
    let message: String
    let appVersion: String?
    let platform: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type = "feedback_type"
        case message
        case appVersion = "app_version"
        case platform
        case createdAt = "created_at"
    }
}

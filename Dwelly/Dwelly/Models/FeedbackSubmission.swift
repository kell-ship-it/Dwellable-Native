import Foundation

/// T-133 (Kell's approved direction, Nov 18 2026): the one in-app Support & Feedback
/// form's category picker -- replaces the earlier feedback/bug card split. No mailto
/// hand-off; this submits straight to `feedback_submissions`.
enum FeedbackCategory: String, Codable, CaseIterable {
    case problem
    case idea
    case other

    var displayName: String {
        switch self {
        case .problem: return "Report a problem"
        case .idea: return "Suggest an idea"
        case .other: return "Something else"
        }
    }
}

struct FeedbackSubmission: Codable, Identifiable {
    let id: String
    let userId: String
    let category: FeedbackCategory
    let message: String
    let appVersion: String?
    let platform: String
    // T-133: optional screenshot, stored in the feedback-screenshots bucket (private,
    // RLS own-folder-only, same pattern as moments-audio) -- nil when none was attached.
    let screenshotPath: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case category = "feedback_type"
        case message
        case appVersion = "app_version"
        case platform
        case screenshotPath = "screenshot_url"
        case createdAt = "created_at"
    }
}

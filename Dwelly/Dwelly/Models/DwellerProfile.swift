import Foundation

/// T-274 (Nov 11 2026): the "doctor's notes" MVP -- a short, plain-text running summary
/// of a user's journal entries over time, so Dwelly has *something* to recall about who
/// they are. Deliberately store-and-show only for this ticket: nothing anywhere reads
/// this back into a capture conversation yet (that's a real, separate, costlier decision
/// -- see TICKETS.md). `runningSummary` is built from already-synthesized `JournalEntry`
/// bodies, not raw transcripts -- the summarization material already exists for free.
///
/// Unencrypted by design, same reasoning as `JournalEntry`'s own fields: this is a
/// summary of content (journal bodies) that's already stored unencrypted, so there's
/// nothing new to protect here that direct `/rest/v1` reads/writes would expose.
struct DwellerProfile: Codable {
    let userId: String
    var runningSummary: String?
    var updatedAt: Date

    init(userId: String, runningSummary: String? = nil, updatedAt: Date = Date()) {
        self.userId = userId
        self.runningSummary = runningSummary
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case runningSummary = "running_summary"
        case updatedAt = "updated_at"
    }
}

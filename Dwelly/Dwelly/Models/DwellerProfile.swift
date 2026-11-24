import Foundation

/// T-274 (Nov 11 2026): the "doctor's notes" MVP -- a short, plain-text running summary
/// of a user's journal entries over time, so Dwelly has *something* to recall about who
/// they are. Deliberately store-and-show only for this ticket: nothing anywhere reads
/// this back into a capture conversation yet (that's a real, separate, costlier decision
/// -- see TICKETS.md). `runningSummary` is built from already-synthesized `JournalEntry`
/// bodies, not raw transcripts -- the summarization material already exists for free.
///
/// Encrypted at rest: `runningSummary` is stored as AES-256-GCM ciphertext and read/written
/// only through the `dweller-profile` Edge Function (decrypted server-side for display).
struct DwellerProfile: Codable {
    let userId: String
    var runningSummary: String?
    var updatedAt: Date
    // T-163: when the user confirmed ("Yes, that's me") the narrative currently in
    // `runningSummary`. A narrative regenerated after this timestamp (updatedAt newer
    // than confirmedAt) is treated as unconfirmed again -- see `isConfirmed`.
    var confirmedAt: Date?

    init(userId: String, runningSummary: String? = nil, updatedAt: Date = Date(), confirmedAt: Date? = nil) {
        self.userId = userId
        self.runningSummary = runningSummary
        self.updatedAt = updatedAt
        self.confirmedAt = confirmedAt
    }

    var isConfirmed: Bool {
        guard let confirmedAt else { return false }
        return confirmedAt >= updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case runningSummary = "running_summary"
        case updatedAt = "updated_at"
        case confirmedAt = "confirmed_at"
    }
}

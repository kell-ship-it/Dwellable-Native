import Foundation

/// T-294: a user's own mood words, shared across every journal entry -- previously a
/// custom word typed into the Mood Sheet only ever lived inside that one entry's
/// `JournalEntry.moods` array, so the next entry had no way to offer it back. This is
/// the one place a user's custom vocabulary persists, independent of any single entry.
struct CustomMood: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let word: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case word
        case createdAt = "created_at"
    }
}

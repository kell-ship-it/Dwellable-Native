import Foundation

/// T-152: the persisted synthesis metadata layered on top of a `Moment` -- title,
/// moods, scripture verse, and starred/edited state. One entry per moment (1:1 via
/// `momentId`). Deliberately does NOT duplicate the journal body: that stays on
/// `moments.encrypted_content` (surfaced as `Moment.body`), so there's exactly one
/// place a body edit has to be written to.
///
/// Not yet modeled here (out of this ticket's scope): `status` is always "approved"
/// today because synthesis in `CaptureConversationView` runs synchronously before a
/// `JournalEntry` is ever created -- there's no pending/retry path yet (T-159, not
/// built), so the field exists for forward compatibility but every entry this app
/// creates is approved immediately. Photos aren't modeled here either -- no Storage
/// bucket/column exists yet for them (same gap `JournalDetailView`'s hero photo
/// already flags).
struct JournalEntry: Identifiable, Codable {
    let id: String
    let momentId: String
    let userId: String
    var status: String
    var title: String?
    var moods: [String]
    var scriptureQuote: String?
    var scriptureReference: String?
    var starred: Bool
    var edited: Bool
    let createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        momentId: String,
        userId: String,
        status: String = "approved",
        title: String? = nil,
        moods: [String] = [],
        scriptureQuote: String? = nil,
        scriptureReference: String? = nil,
        starred: Bool = false,
        edited: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.momentId = momentId
        self.userId = userId
        self.status = status
        self.title = title
        self.moods = moods
        self.scriptureQuote = scriptureQuote
        self.scriptureReference = scriptureReference
        self.starred = starred
        self.edited = edited
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case momentId = "moment_id"
        case userId = "user_id"
        case status
        case title
        case moods
        case scriptureQuote = "scripture_quote"
        case scriptureReference = "scripture_reference"
        case starred
        case edited
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

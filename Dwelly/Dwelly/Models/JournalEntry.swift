import Foundation

/// T-152: the persisted synthesis metadata layered on top of a `Moment` -- title,
/// body (real synthesized narrative, added Nov 11 2026), moods, scripture verse, and
/// starred/edited state. One entry per moment (1:1 via `momentId`).
///
/// `body` here is the actual reframed journal narrative the LLM writes -- NOT the same
/// thing as `moments.encrypted_content`/`Moment.body`, which stays the user's raw,
/// unedited words (the transcript). Before this field existed, `JournalDetailView`
/// silently displayed the raw transcript AS IF it were the finished journal entry --
/// Kell caught this directly comparing a real saved entry's displayed body against
/// what synthesis actually generates (Nov 11 2026). Now there are genuinely two
/// things: the raw words (preserved, shown as "In your words" while pending, and via
/// "View Original Chat" once approved) and the synthesized entry (`body` here, what's
/// actually shown as the journal once synthesis succeeds).
///
/// `status` is "pending" (body/title/scripture all nil) until synthesis succeeds,
/// "approved" once it has -- see T-159 for the retry mechanism that moves a pending
/// entry forward. Photos aren't modeled here either -- no Storage bucket/column
/// exists yet for them (same gap `JournalDetailView`'s hero photo already flags).
struct JournalEntry: Identifiable, Codable {
    let id: String
    let momentId: String
    let userId: String
    var status: String
    var title: String?
    var body: String?
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
        body: String? = nil,
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
        self.body = body
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
        case body
        case moods
        case scriptureQuote = "scripture_quote"
        case scriptureReference = "scripture_reference"
        case starred
        case edited
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

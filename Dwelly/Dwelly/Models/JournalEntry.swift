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
/// entry forward. `photoPath` (T-156) closes the gap `JournalDetailView`'s hero photo
/// used to flag -- a real Storage object path now, not session-local only.
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
    // T-188: NULL until JournalDetailView's loadEntry() stamps it the first time this
    // entry is actually opened -- the "Journal Ready" Today-tab tile reads this to
    // know when to stop showing itself, instead of guessing off a recency timer.
    var viewedAt: Date?
    // T-127 (rebuilt Nov 17 2026): the real, independent formation-eligibility signal --
    // never proxied by scriptureQuote presence or by whether synthesis ran. Gates
    // DwellerProfileManager updates and Growth's narrative eligibility.
    var formationEligible: Bool = false
    var extractedFacts: String? = nil
    // T-156: Storage object path in the (private) "journal-photos" bucket, e.g.
    // "<userId>/<file>.jpg" -- never a signed/public URL, same reasoning as
    // `Moment.audioURL`. Nil when no photo is attached.
    var photoPath: String? = nil
    // T-125 (Nov 19 2026): minimal, purpose-specific eligibility flag -- NOT a
    // detailed safety label. True if ANY turn in the source conversation was flagged
    // by the crisis/misuse safety layer in a way FormationEligibilityPolicy excludes.
    // Independent of `formationEligible` (substance-based); both must be true for
    // this entry's facts to actually reach DwellerProfileManager -- see
    // JournalSynthesisManager.synthesize's enforcement. Default false matches
    // FormationEligibilityPolicy.isActive being off: nothing is excluded yet.
    var profileExcluded: Bool = false

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
        updatedAt: Date = Date(),
        viewedAt: Date? = nil,
        formationEligible: Bool = false,
        extractedFacts: String? = nil,
        photoPath: String? = nil,
        profileExcluded: Bool = false
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
        self.viewedAt = viewedAt
        self.formationEligible = formationEligible
        self.extractedFacts = extractedFacts
        self.photoPath = photoPath
        self.profileExcluded = profileExcluded
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
        case viewedAt = "viewed_at"
        case formationEligible = "formation_eligible"
        case extractedFacts = "extracted_facts"
        case photoPath = "photo_path"
        case profileExcluded = "profile_excluded"
    }
}

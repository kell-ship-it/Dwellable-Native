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

// MARK: - Saved conversation (Nov 19 2026, Kell)
//
// A saved reflection's `body` used to hold only the user's own words, so the "original
// reflection" screen lost Dwelly's side and every prompt the user was answering. It now
// stores the whole conversation as a labeled transcript -- same column, same server-side
// encryption, no schema change. Everything that needs ONLY the user's own words (row
// previews, the editable fallback, journal synthesis's "userOnlyText", Formation facts)
// reads `userWords`, never `body` directly, so Dwelly's replies can't leak into them.
// Older moments, which have no header, are plain user text and read back unchanged.
//
// Only ordinary saved reflections are ever written this way. A Crisis Support
// conversation creates no moment at all.
extension Moment {
    static let transcriptHeader = "\u{27E6}dwelly-transcript-v1\u{27E7}"
    private static let userMarker = "\u{27E6}U\u{27E7}"
    private static let dwellyMarker = "\u{27E6}D\u{27E7}"

    struct TranscriptTurn: Equatable {
        let isUser: Bool
        let text: String
    }

    /// Encodes turns into `body`. The bracket characters used as markers are replaced in
    /// the text itself, so nothing a person types (or Dwelly says) can forge a turn.
    static func encodeTranscript(_ turns: [TranscriptTurn]) -> String {
        var out = transcriptHeader
        for turn in turns {
            let text = turn.text
                .replacingOccurrences(of: "\u{27E6}", with: "[")
                .replacingOccurrences(of: "\u{27E7}", with: "]")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { continue }
            out += "\n" + (turn.isUser ? userMarker : dwellyMarker) + "\n" + text
        }
        return out
    }

    /// The conversation's turns, or nil for an older moment that is plain user text.
    var transcriptTurns: [TranscriptTurn]? {
        guard body.hasPrefix(Self.transcriptHeader) else { return nil }
        var turns: [TranscriptTurn] = []
        var currentIsUser: Bool?
        var lines: [String] = []
        func flush() {
            if let isUser = currentIsUser {
                let text = lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty { turns.append(TranscriptTurn(isUser: isUser, text: text)) }
            }
            lines = []
        }
        for line in body.components(separatedBy: "\n").dropFirst() {
            if line == Self.userMarker { flush(); currentIsUser = true }
            else if line == Self.dwellyMarker { flush(); currentIsUser = false }
            else { lines.append(line) }
        }
        flush()
        return turns
    }

    /// The user's own words only -- what every pre-transcript screen/feature expects.
    var userWords: String {
        guard let turns = transcriptTurns else { return body }
        return turns.filter(\.isUser).map(\.text).joined(separator: "\n\n")
    }

    /// Both sides, role-labeled the same way Capture labels them for synthesis ("Me:" /
    /// "Dwelly:"), so a retried synthesis sees the same conversation the first try did.
    var synthesisTranscript: String {
        guard let turns = transcriptTurns else { return body }
        return turns.map { "\($0.isUser ? "Me" : "Dwelly"): \($0.text)" }.joined(separator: "\n\n")
    }
}

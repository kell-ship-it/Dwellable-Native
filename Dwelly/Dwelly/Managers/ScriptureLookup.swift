import Foundation

/// Scripture lookup (Nov 22 2026, Kell): the model only NAMES a passage ("Romans 8:1");
/// the exact words come from a real Bible text, never from model memory. Source:
/// bible-api.com serving the World English Bible (public domain, complete Bible, no key,
/// no sign-in). No extra model call. If the lookup fails or nothing parses, the reply is
/// shown unchanged with no verse text -- an unverified quote is never invented.
enum ScriptureLookup {

    struct Reference: Equatable {
        let book: String
        let chapter: Int
        let verseStart: Int
        let verseEnd: Int
        var display: String {
            verseStart == verseEnd ? "\(book) \(chapter):\(verseStart)" : "\(book) \(chapter):\(verseStart)-\(verseEnd)"
        }
    }

    static let translationLabel = "World English Bible"
    static let maxVerses = 8

    private static let books: [String] = [
        "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", "Ruth",
        "1 Samuel", "2 Samuel", "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "Ezra",
        "Nehemiah", "Esther", "Job", "Psalm", "Psalms", "Proverbs", "Ecclesiastes",
        "Song of Solomon", "Isaiah", "Jeremiah", "Lamentations", "Ezekiel", "Daniel", "Hosea",
        "Joel", "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk", "Zephaniah", "Haggai",
        "Zechariah", "Malachi", "Matthew", "Mark", "Luke", "John", "Acts", "Romans",
        "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians", "Philippians", "Colossians",
        "1 Thessalonians", "2 Thessalonians", "1 Timothy", "2 Timothy", "Titus", "Philemon",
        "Hebrews", "James", "1 Peter", "2 Peter", "1 John", "2 John", "3 John", "Jude",
        "Revelation",
    ]

    /// The first well-formed passage reference in `text` (book chapter:verse[-verse]),
    /// or nil. Dash variants are normalized; spans longer than `maxVerses` are skipped.
    static func firstReference(in text: String) -> Reference? {
        let normalized = text
            .replacingOccurrences(of: "\u{2011}", with: "-")
            .replacingOccurrences(of: "\u{2013}", with: "-")
            .replacingOccurrences(of: "\u{2014}", with: "-")
        let alternation = books
            .sorted { $0.count > $1.count }
            .map { NSRegularExpression.escapedPattern(for: $0) }
            .joined(separator: "|")
        let pattern = "\\b(\(alternation))\\s+(\\d{1,3}):(\\d{1,3})(?:-(\\d{1,3}))?(?!\\d)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(normalized.startIndex..., in: normalized)
        for match in regex.matches(in: normalized, range: range) {
            func group(_ i: Int) -> String? {
                guard let r = Range(match.range(at: i), in: normalized) else { return nil }
                return String(normalized[r])
            }
            guard let book = group(1), let ch = group(2).flatMap(Int.init),
                  let v1 = group(3).flatMap(Int.init) else { continue }
            let v2 = group(4).flatMap(Int.init) ?? v1
            guard v2 >= v1, v2 - v1 + 1 <= maxVerses else { continue }
            let canonicalBook = book == "Psalms" ? "Psalm" : book
            return Reference(book: canonicalBook, chapter: ch, verseStart: v1, verseEnd: v2)
        }
        return nil
    }

    /// Request URL for a reference (World English Bible).
    static func url(for ref: Reference) -> URL? {
        let query = "\(ref.book) \(ref.chapter):\(ref.verseStart)" + (ref.verseEnd == ref.verseStart ? "" : "-\(ref.verseEnd)")
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return nil }
        return URL(string: "https://bible-api.com/\(encoded)?translation=web")
    }

    /// Verse text from a bible-api.com JSON body, or nil if it is not the expected shape.
    static func parseText(from data: Data) -> String? {
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let text = obj["text"] as? String else { return nil }
        let cleaned = text
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }

    /// The reply with the real verse text appended when a passage is named and the
    /// lookup succeeds; otherwise the reply unchanged.
    static func appendingVerseText(to reply: String) async -> String {
        guard let ref = firstReference(in: reply), let url = url(for: ref) else { return reply }
        var request = URLRequest(url: url)
        request.timeoutInterval = 6
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              (response as? HTTPURLResponse)?.statusCode == 200,
              let text = parseText(from: data) else { return reply }
        return reply + "\n\n\(ref.display) (\(translationLabel)): \u{201C}\(text)\u{201D}"
    }
}

import Foundation

/// The short preview of a journal entry shown on the capture's journal card. Never cuts a word in
/// half: whitespace (including paragraph breaks between messages) is collapsed to single spaces, and a
/// longer text ends at the last whole word with an ellipsis. Counts user-perceived characters, and a
/// text with no spaces (e.g. Chinese or Japanese) is cut at the limit instead. The full text is never
/// changed -- this is display only.
enum JournalExcerpt {
    static let limit = 140

    static func make(from text: String, limit: Int = JournalExcerpt.limit) -> String {
        let collapsed = text.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
        guard collapsed.count > limit else { return collapsed }
        let head = String(collapsed.prefix(limit))
        // Prefer the last whole word, but only if that keeps at least half the allowance.
        if collapsed[collapsed.index(collapsed.startIndex, offsetBy: limit)] != " ",
           let lastSpace = head.lastIndex(of: " "),
           head.distance(from: head.startIndex, to: lastSpace) >= limit / 2 {
            return String(head[..<lastSpace]).trimmingCharacters(in: CharacterSet(charactersIn: " ,;:-")) + "…"
        }
        return head.trimmingCharacters(in: .whitespaces) + "…"
    }
}

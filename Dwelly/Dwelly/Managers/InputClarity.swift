import Foundation

/// No-AI, purely mechanical check run BEFORE a capture message is sent (MVP capture
/// validation, approved Nov 23 2026). It answers one question only: "is this message
/// literally nothing, or one character / a tiny exact pattern repeated for a long
/// stretch?" It never looks at meaning, language, dictionary words, acronyms or
/// sentiment, and it never edits the submitted text -- the caller keeps the original
/// in the composer so the person can fix it. Emoji, short emphasis ("no no no no"),
/// slang, typos, repeated paragraphs and any non-Latin script all pass.
enum InputClarity {
    enum Verdict: Equatable {
        case ok
        /// Nothing visible at all (empty, whitespace, zero-width/control characters only).
        case empty
        /// The whole message is one grapheme, or a tiny exact pattern, repeated.
        case mechanicalRepeat
    }

    /// A message must be at least this many grapheme clusters (user-perceived
    /// characters, so a family emoji or flag counts as one) before the repeat rule
    /// applies at all.
    static let minRepeatLength = 100
    /// "Tiny pattern": a period of at most this many graphemes. 4 covers "a", "ab",
    /// "asd", "asdf" style keyboard mashing while leaving anything with a real phrase
    /// (5+ graphemes repeating verbatim for 100+ characters is rare enough to stay
    /// out of scope; the deferred duplicate-paragraph work owns that case).
    static let maxPatternPeriod = 4

    static let emptyPrompt = "What happened that you’d like to capture?"
    static let repeatPrompt = "Could you describe what happened in a few words?"

    static func check(_ text: String) -> Verdict {
        if !text.unicodeScalars.contains(where: { !isInvisible($0) }) { return .empty }

        // Case-insensitive: iOS auto-capitalizes the first letter, so keyboard mashing arrives
        // as "Aaaa..." -- still one mechanical pattern. (Judging only; the original is never changed.)
        let graphemes = text.map { String($0).lowercased() }
        guard graphemes.count >= minRepeatLength else { return .ok }
        for period in 1...maxPatternPeriod where graphemes.count > period {
            var periodic = true
            for i in period..<graphemes.count where graphemes[i] != graphemes[i % period] {
                periodic = false
                break
            }
            if periodic { return .mechanicalRepeat }
        }
        return .ok
    }

    /// The prepared reply for a verdict, or nil for `.ok`. Fixed copy, no model call.
    static func clarification(for verdict: Verdict) -> String? {
        switch verdict {
        case .ok: return nil
        case .empty: return emptyPrompt
        case .mechanicalRepeat: return repeatPrompt
        }
    }

    private static func isInvisible(_ s: Unicode.Scalar) -> Bool {
        switch s.properties.generalCategory {
        case .control, .format, .spaceSeparator, .lineSeparator, .paragraphSeparator, .unassigned, .privateUse:
            return true
        default:
            // Variation selectors are nonspacing marks with no glyph of their own.
            return (0xFE00...0xFE0F).contains(s.value) || (0xE0100...0xE01EF).contains(s.value)
        }
    }
}

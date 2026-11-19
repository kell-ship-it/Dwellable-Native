import Foundation

/// Crisis Support -- a deliberately NARROW, interim, on-device safeguard (Nov 19 2026).
///
/// What it is: a bounded, deterministic catalog matched against the USER'S OWN message
/// text, for three kinds of explicit, CURRENT statements:
///   - self-harm: present thoughts, desire, or intention to kill/harm oneself
///     ("I want to kill myself", "I'm thinking about ending my life", "I feel like
///     hurting myself", "I want to die");
///   - a known third party's self-harm ("my sister wants to kill herself", "he's
///     thinking about ending his life");
///   - current intent to harm others ("I'm going to hurt him", "I want to kill my
///     boss").
/// No imminent plan is required -- a clear current statement is enough to establish
/// support. Phrases like "thinking about", "about to", or "going to" only count when
/// followed by an explicit harm phrase; a pronoun with no explicit harm referent ("they
/// are thinking about doing this") never matches and stays with the contextual model.
/// Dwelly's own replies are never read; wording or a phone number in a reply means
/// nothing here.
///
/// When it counts: ONLY when the backend gave no usable verdict for that same turn
/// (missing/out-of-contract `safetyTier` -> "unverified", or a failed check ->
/// "fallback"). See CaptureSafetySession. When the real contextual classifier returns
/// a verdict, that semantic assessment stands.
///
/// What it is NOT: comprehensive safety detection, or a guarantee. The positive and
/// near-miss negative examples in Scripts/crisis_support_runtime_harness are a named
/// test fixture for this catalog, not a claim that every phrasing is covered. The
/// contextual model is what handles paraphrase, negation, quotation, history, fiction,
/// metaphor, and intrusive-thought ambiguity. Any sentence here with negation,
/// conditional, historical, fictional, joking, or intrusive/unwanted framing is skipped
/// rather than guessed at. A miss is not "clear": a turn with no backend verdict
/// is still a save-blocking pending hold.
enum LocalExplicitHarmSignal {

    enum Kind: Equatable {
        case selfHarm
        case thirdPartySelfHarm
        case harmToOthers

        /// The tier CaptureSafetySession records for this kind. All three are genuine-
        /// concern tiers in CrisisSupportPolicy (permanent latch).
        var tier: String {
            switch self {
            case .selfHarm: return "local_explicit_self_harm"
            case .thirdPartySelfHarm: return "local_explicit_third_party_harm"
            case .harmToOthers: return "local_explicit_harm_to_others"
            }
        }
    }

    private static let adv = #"(?:(?:really|just|honestly|seriously|truly|still|actually|literally)\s+)?"#
    private static let intentVerb = #"(?:want\s+to|wanna|going\s+to|gonna|plan\s+to|planning\s+to|intend\s+to|will|about\s+to|ready\s+to|need\s+to)"#

    private static let selfBase = #"(?:kill\s+myself|end\s+my\s+(?:own\s+)?life|end\s+it\s+all|take\s+my\s+(?:own\s+)?life|hurt\s+myself|harm\s+myself|cut\s+myself)"#
    private static let selfGerund = #"(?:killing\s+myself|ending\s+my\s+(?:own\s+)?life|ending\s+it\s+all|taking\s+my\s+(?:own\s+)?life|hurting\s+myself|harming\s+myself|cutting\s+myself|suicide)"#

    private static let reflexive3 = #"(?:himself|herself|themselves|themself)"#
    private static let poss3 = #"(?:his|her|their)"#
    private static let thirdBase = "(?:(?:kill|hurt|harm|cut)\\s+\(reflexive3)|(?:end|take)\\s+\(poss3)\\s+(?:own\\s+)?life)"
    private static let thirdGerund = "(?:(?:killing|hurting|harming|cutting)\\s+\(reflexive3)|(?:ending|taking)\\s+\(poss3)\\s+(?:own\\s+)?life|suicide)"

    private static let otherTarget = #"(?:him|her|them|someone|somebody|people|everyone|my\s+[a-z]+)"#
    private static let otherBase = "(?:kill|hurt|harm|stab|shoot|attack|beat\\s+up)\\s+\(otherTarget)"
    private static let otherGerund = "(?:killing|hurting|harming|stabbing|shooting|attacking|beating\\s+up)\\s+\(otherTarget)"

    private static func regex(_ alternatives: [String]) -> NSRegularExpression {
        try! NSRegularExpression(pattern: alternatives.map { "(?:\($0))" }.joined(separator: "|"))
    }

    private static let selfPattern = regex([
        "\\bi(?:'m|\\s+am)?\\s+\(adv)\(intentVerb)\\s+\(selfBase)\\b",
        "\\bi'll\\s+\(adv)\(selfBase)\\b",
        "\\bi\\s+\(adv)(?:want\\s+to|wanna)\\s+die\\b",
        "\\bi\\s+\(adv)feel\\s+like\\s+(?:\(selfGerund)|dying)\\b",
        "\\bi(?:'m|\\s+am|'ve\\s+been|\\s+have\\s+been|\\s+keep)?\\s+\(adv)thinking\\s+(?:about|of)\\s+\(selfGerund)\\b",
        "\\bi(?:'m|\\s+am)?\\s+(?:having|have)\\s+(?:thoughts|urges)\\s+(?:of|about|to)\\s+(?:\(selfGerund)|\(selfBase))\\b",
    ])

    private static let thirdPattern = regex([
        "\\b(?:wants\\s+to|want\\s+to|is\\s+going\\s+to|'s\\s+going\\s+to|are\\s+going\\s+to|is\\s+gonna|are\\s+gonna|plans\\s+to|plan\\s+to|is\\s+planning\\s+to|are\\s+planning\\s+to|intends\\s+to|will|is\\s+about\\s+to|'s\\s+about\\s+to|are\\s+about\\s+to|'ll)\\s+\(adv)\(thirdBase)\\b",
        "\\b(?:is|are|'s|'re|has\\s+been|have\\s+been|keeps?)\\s+\(adv)thinking\\s+(?:about|of)\\s+\(thirdGerund)\\b",
        "\\b(?:feels|feel|is\\s+feeling|are\\s+feeling)\\s+like\\s+\(thirdGerund)\\b",
    ])

    private static let othersPattern = regex([
        "\\bi(?:'m|\\s+am)?\\s+\(adv)\(intentVerb)\\s+\(otherBase)\\b",
        "\\bi'll\\s+\(adv)\(otherBase)\\b",
        "\\bi(?:'m|\\s+am|'ve\\s+been|\\s+have\\s+been|\\s+keep)?\\s+\(adv)thinking\\s+(?:about|of)\\s+\(otherGerund)\\b",
        "\\bi\\s+\(adv)feel\\s+like\\s+\(otherGerund)\\b",
    ])

    /// Any of these in the same sentence means the statement isn't a clear, direct,
    /// current one -- negation, conditional/hypothetical, historical, fictional,
    /// dream, intrusive/unwanted, or joking framing. Such sentences are skipped.
    private static let disqualifierPattern = regex([
        "\\b(?:don't|doesn't|do\\s+not|does\\s+not|isn't|is\\s+not|aren't|are\\s+not|won't|will\\s+not|wouldn't|would\\s+not|didn't|did\\s+not|never|not\\s+going\\s+to|'m\\s+not|am\\s+not)\\b",
        "\\bif\\b|\\bwhat\\s+if\\b|\\bwould\\s+i\\b",
        "\\bintrusive\\b|\\bunwanted\\b|\\bdreams?\\b|\\bdreamt\\b|\\bdreamed\\b",
        "\\bused\\s+to\\b|\\bwhen\\s+i\\s+was\\b|\\b(?:years|months|weeks|days)\\s+ago\\b|\\bback\\s+then\\b|\\bin\\s+the\\s+past\\b|\\blast\\s+(?:year|month|week)\\b",
        "\\b(?:movie|film|book|novel|story|character|show|game|fiction|lyrics?|song)\\b",
        "\\b(?:lol|lmao|haha|jk|joking|kidding)\\b|\\bof\\s+(?:embarrassment|boredom|laughter)\\b",
    ])

    /// Text inside quotation marks is someone's words being reported or recalled, not
    /// a present statement -- removed before matching.
    private static let quotedPattern = try! NSRegularExpression(pattern: #""[^"]*"|“[^”]*”"#)

    /// The strongest kind found in any qualifying sentence, or nil. Self-harm is
    /// reported over the others when a message contains more than one.
    static func explicitCurrentHarm(in text: String) -> Kind? {
        var normalized = text
            .replacingOccurrences(of: "\u{2019}", with: "'")
            .replacingOccurrences(of: "\u{2018}", with: "'")
        normalized = quotedPattern.stringByReplacingMatches(
            in: normalized, range: NSRange(normalized.startIndex..., in: normalized), withTemplate: " "
        ).lowercased()

        var found: [Kind] = []
        for sentence in normalized.components(separatedBy: CharacterSet(charactersIn: ".!?;\n")) {
            let range = NSRange(sentence.startIndex..., in: sentence)
            if disqualifierPattern.firstMatch(in: sentence, range: range) != nil { continue }
            if selfPattern.firstMatch(in: sentence, range: range) != nil { found.append(.selfHarm) }
            if thirdPattern.firstMatch(in: sentence, range: range) != nil { found.append(.thirdPartySelfHarm) }
            if othersPattern.firstMatch(in: sentence, range: range) != nil { found.append(.harmToOthers) }
        }
        if found.contains(.selfHarm) { return .selfHarm }
        if found.contains(.thirdPartySelfHarm) { return .thirdPartySelfHarm }
        if found.contains(.harmToOthers) { return .harmToOthers }
        return nil
    }
}

import Foundation

/// T-306/T-304/T-308: the one place that owns safety-resource copy and country selection.
/// Deliberately separate from llm-proxy's classification logic (T-302/T-303) -- the proxy
/// decides WHETHER a crisis/refusal/fallback response is needed and supplies the plain
/// compassionate sentence; this type supplies the actual phone numbers/links, localized by
/// a user-DECLARED country (never GPS/precise location), and renders the always-available
/// "Need support now?" entry point content used regardless of whether anything was flagged.
///
/// Country list intentionally small and honest: only countries whose national crisis-line
/// number was actually verified below are named directly. Everyone else (including "not
/// set") gets the international fallback -- this is the explicit fix for the earlier draft
/// that would have silently defaulted an unknown country to US numbers.
enum SafetyResourceCenter {

    enum SupportedCountry: String, CaseIterable, Identifiable {
        case unitedStates = "US"
        case unitedKingdom = "GB"
        case canada = "CA"
        case australia = "AU"
        case notSet = ""

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .unitedStates: return "United States"
            case .unitedKingdom: return "United Kingdom"
            case .canada: return "Canada"
            case .australia: return "Australia"
            case .notSet: return "Not set / prefer not to say"
            }
        }
    }

    private static let declaredCountryKey = "dwelly.safety.declaredCountry"

    /// User-declared only -- never written from CoreLocation/GPS. Defaults to `.notSet`,
    /// which deliberately renders the international fallback, not US resources (T-306's
    /// explicit correction to an earlier draft).
    static var declaredCountry: SupportedCountry {
        get {
            guard let raw = UserDefaults.standard.string(forKey: declaredCountryKey),
                  let country = SupportedCountry(rawValue: raw) else { return .notSet }
            return country
        }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: declaredCountryKey) }
    }

    /// Plain-language national resources for self-risk. Verified against each service's
    /// own published number as of this writing; re-check before relying on this at launch,
    /// numbers/services do change.
    private static func selfRiskLines(for country: SupportedCountry) -> [String] {
        switch country {
        case .unitedStates:
            return [
                "988 Suicide & Crisis Lifeline — call or text 988, anytime",
                "Crisis Text Line — text HOME to 741741",
                "If you're in immediate danger, call 911",
            ]
        case .unitedKingdom:
            return [
                "Samaritans — call 116 123, free, anytime",
                "Shout — text SHOUT to 85258",
                "If you're in immediate danger, call 999",
            ]
        case .canada:
            return [
                "Talk Suicide Canada — call or text 988, anytime",
                "If you're in immediate danger, call 911",
            ]
        case .australia:
            return [
                "Lifeline Australia — call 13 11 14, anytime",
                "If you're in immediate danger, call 000",
            ]
        case .notSet:
            return [
                "findahelpline.com lists a crisis line for your country",
                "If you're in immediate danger, contact your local emergency number",
            ]
        }
    }

    /// Resources framed for someone worried about another person, not at risk themselves.
    /// 988 (and most equivalents) explicitly also take calls from a concerned third party --
    /// stated here so the same line serves both the at-risk person and the one asking on
    /// their behalf, without inventing a second set of numbers.
    private static func thirdPartyRiskLines(for country: SupportedCountry) -> [String] {
        switch country {
        case .unitedStates:
            return [
                "988 also takes calls from someone worried about another person, not just the person at risk",
                "If they're in immediate danger right now, call 911",
            ]
        case .unitedKingdom:
            return [
                "Samaritans (116 123) also talks with people worried about someone else",
                "If they're in immediate danger right now, call 999",
            ]
        case .canada:
            return [
                "988 also takes calls from someone worried about another person",
                "If they're in immediate danger right now, call 911",
            ]
        case .australia:
            return [
                "Lifeline (13 11 14) also talks with people worried about someone else",
                "If they're in immediate danger right now, call 000",
            ]
        case .notSet:
            return [
                "findahelpline.com lists a service in your country that can talk with you about someone else's safety",
                "If they're in immediate danger right now, contact your local emergency number",
            ]
        }
    }

    /// Ongoing-danger-to-the-user-from-someone-else framing (e.g. abuse). Deliberately
    /// general rather than a single named DV hotline per country -- that needs real,
    /// per-country research before launch (flagged in T-125's own notes); the emergency-
    /// number line is universal and safe to ship now.
    private static func ongoingDangerLines(for country: SupportedCountry) -> [String] {
        switch country {
        case .unitedStates:
            return [
                "988 Suicide & Crisis Lifeline can also help you think through safety, not just suicide — call or text 988",
                "If you're in immediate danger, call 911",
            ]
        default:
            return selfRiskLines(for: country)
        }
    }

    enum Tier: String {
        case normal
        case crisisSelf = "crisis_self"
        case crisisOther = "crisis_other"
        case ongoingDanger = "ongoing_danger"
        case refusal
        case fallback
    }

    /// Builds the resource block to append after the proxy's own compassionate/fallback
    /// sentence. Returns nil for tiers that don't need a resource block (normal, refusal --
    /// a refusal is about declining a specific request, not a safety resource moment).
    static func resourceBlock(for tier: Tier, country: SupportedCountry = declaredCountry) -> String? {
        let lines: [String]
        switch tier {
        case .crisisSelf:
            lines = selfRiskLines(for: country)
        case .crisisOther:
            lines = thirdPartyRiskLines(for: country)
        case .ongoingDanger:
            lines = ongoingDangerLines(for: country)
        case .fallback:
            lines = [
                "I want to make sure I respond carefully here, and I wasn't able to a moment ago.",
            ] + selfRiskLines(for: country)
        case .normal, .refusal:
            return nil
        }
        return lines.map { "• \($0)" }.joined(separator: "\n")
    }

    /// Content for the always-available "Need support now?" entry point -- shown regardless
    /// of whether anything in the current conversation was ever flagged, per the locked
    /// design ("an always-available country-aware help entry point").
    static var alwaysAvailableHelpText: String {
        """
        If anything you're carrying feels like more than reflection can hold right now, these are real places to go:

        \(selfRiskLines(for: declaredCountry).map { "• \($0)" }.joined(separator: "\n"))

        Dwelly isn't staffed or monitored live — these services are.
        """
    }

    /// T-308: the honest, upfront explanation of what this safety layer does and doesn't do.
    /// Shown once (see CaptureConversationView's `hasSeenSafetyNoticeKey`) and reachable
    /// again anytime from Settings.
    static let pilotNoticeText = """
    Dwelly is a space for reflecting on your life with God — not therapy, and not a \
    monitored safety service.

    If something you share looks like it might involve real danger, Dwelly will try to \
    respond with care and point you to real help (like a crisis line). But no one is \
    watching these conversations live, nothing is automatically reported to anyone, and \
    Dwelly can't promise to notice everything.

    If you're ever in real danger, please reach out directly — to 988 (or your local \
    equivalent), a trusted person, or emergency services. Don't wait on an app to catch it.
    """
}

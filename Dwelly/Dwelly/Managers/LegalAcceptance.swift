import Foundation

/// T-309 (revised Nov 19 2026 per Kell/Codex's correction): a real, locally-recorded
/// acceptance of Terms of Service + Privacy Policy, tied to the actual "Create Account"
/// submission in `AccountCreationView` -- not just a schema column with no app flow
/// writing to it. Server persistence (to `public.users.terms_accepted_at`/etc., added
/// in migration `20261119120100_...`) is attempted best-effort AFTER the local record
/// is written and only once a real signed-in userId exists; it is explicitly optional
/// and never blocks account creation, since that schema has not been applied to any
/// live database as part of this work.
///
/// Deliberately separate from `SafetyResourceCenter.pilotNoticeText` / `SafetyNoticeSheet`
/// -- the safety notice is informational (what the crisis/misuse layer does and doesn't
/// do) and is never treated as consent to anything. Only agreeing to THESE two documents,
/// at account creation, counts as acceptance.
enum LegalAcceptance {
    /// Bump this (and the "Last updated" date in TermsOfServiceView/PrivacyPolicyView)
    /// together whenever either document's substance changes. Matches the versioning
    /// scheme `public.users.terms_version`/`privacy_version` expect (a dated string).
    static let currentVersion = "2026-11-19"

    private static let acceptedVersionKey = "dwelly.legal.acceptedVersion"
    private static let acceptedAtKey = "dwelly.legal.acceptedAt"

    /// `true` only if the user has accepted the CURRENT version -- an acceptance of an
    /// older version does not count, so a future version bump correctly re-prompts.
    static var hasAcceptedCurrentVersion: Bool {
        UserDefaults.standard.string(forKey: acceptedVersionKey) == currentVersion
    }

    /// Called at the moment the user submits account creation with the checkbox
    /// checked -- that submission IS the consent action, not the checkbox tap alone
    /// (someone could check it, then back out without creating an account).
    static func recordLocalAcceptance(date: Date = Date()) {
        UserDefaults.standard.set(currentVersion, forKey: acceptedVersionKey)
        UserDefaults.standard.set(date, forKey: acceptedAtKey)
    }

    static var acceptedAt: Date? {
        UserDefaults.standard.object(forKey: acceptedAtKey) as? Date
    }
}

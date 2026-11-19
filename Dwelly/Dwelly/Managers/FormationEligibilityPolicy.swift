import Foundation

/// T-125 downstream-protection infrastructure (Nov 19 2026) -- the second protection
/// Kell asked for: material that shouldn't feed Formation Intelligence/the running
/// profile must not reach it, even though T-302/T-303's safety layer only ever
/// touches the *reply* Dwelly gives, never the user's own saved words (see the audit
/// this followed). This is the ONE place that decides eligibility; everything else
/// (CaptureConversationView, SyncManager's retry sweep, JournalSynthesisManager)
/// calls into this rather than each inventing its own rule.
///
/// CRITICAL: `isActive` is `false`. Kell has NOT approved a final exclusion policy --
/// he explicitly said not to invent a blanket rule and to keep activation pending.
/// `candidateExcludedTiers` below is a PROPOSAL for his review, not a decision. While
/// `isActive` is false, `decision(forTiersSeen:)` always returns `.eligible` --
/// i.e. today's actual behavior (every genuine reflection can be synthesized/
/// profiled, exactly as before this file existed) does not change until Kell flips
/// this flag. The infrastructure is built and tested now so that flipping it is a
/// one-line, already-verified change, not a scramble later.
enum FormationEligibilityPolicy {
    /// PENDING KELL'S DECISION. Do not flip without his explicit sign-off.
    static let isActive = false

    /// PROPOSED, NOT APPROVED. Candidate reasoning (Kell's own framing, Nov 19 2026):
    /// "acute crisis and harmful-assistance turns excluded... while ordinary adult
    /// sexual feelings/abuse disclosure/past pain aren't blanket-excluded."
    /// - `crisis_self` IS in this set: acute self-harm/suicide risk to the user
    ///   themselves is "acute crisis."
    /// - `refusal` IS in this set: an explicit request for harmful assistance.
    /// - `fallback` IS in this set: the output/input safety check could not be
    ///   completed at all for that turn -- when a check can't be trusted, the
    ///   conservative choice is to exclude, not to assume it was fine.
    /// - `crisis_other` (a third party's risk, e.g. "my cousin tried to hurt
    ///   himself") and `ongoing_danger` (the user's OWN disclosure of abuse/danger
    ///   from someone else) are DELIBERATELY NOT in this set -- Kell was explicit
    ///   that ordinary abuse disclosure and vulnerable reflection are legitimate
    ///   journaling/profiling content, not something to blanket-exclude just because
    ///   it once needed a careful, resourced response.
    /// - `normal` and `clarify` are never excluded -- the ordinary case.
    static let candidateExcludedTiers: Set<String> = ["crisis_self", "refusal", "fallback"]

    enum Decision: Equatable {
        case eligible
        /// Carries no detail beyond "excluded" -- deliberately not which tier, not
        /// why, not when. Anything more would itself be a new persistent sensitive
        /// safety label, which this is explicitly meant to avoid (see
        /// `JournalEntry.profileExcluded`, a bare Bool, not an enum/category).
        case excluded
    }

    /// `tiersSeen`: every non-nil `safetyTier` string observed across an ENTIRE
    /// conversation (not just the latest turn) -- a mixed conversation (some turns
    /// flagged, most not) is decided as ONE unit. This is the conservative-isolation
    /// choice: there is no reliable way to extract "just the safe parts" of a single
    /// synthesized journal entry/summary without risking the excluded content's own
    /// gist leaking through the synthesis model's phrasing. Whole-entry exclusion is
    /// the only form of isolation this design trusts.
    static func decision(forTiersSeen tiersSeen: Set<String>) -> Decision {
        guard isActive else { return .eligible }
        return tiersSeen.isDisjoint(with: candidateExcludedTiers) ? .eligible : .excluded
    }
}

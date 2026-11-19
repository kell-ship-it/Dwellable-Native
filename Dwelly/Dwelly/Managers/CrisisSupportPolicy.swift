import Foundation

/// The new, explicitly-named "Crisis Support" pillar -- deliberately UNNUMBERED, not
/// "Pillar 12" (Theme.swift already locks P12 to the Payment pillar's palette; see
/// `Theme.Payment`'s own comment). Full policy: docs/PILLAR_CRISIS_SUPPORT_STRATEGY.md.
/// Canonical Notion page: https://app.notion.com/p/41dcbe07e0c9817fb28cf4432e49ade8
///
/// This is deliberately separate from, and stricter than, `FormationEligibilityPolicy`:
/// that type only gates Formation Intelligence/profile ELIGIBILITY for an entry that
/// still gets created and saved, and stays `isActive = false` pending a product decision.
/// This type decides whether the WHOLE conversation produces a journal entry at all.
/// Unlike `FormationEligibilityPolicy`, this policy is ACTIVE now -- Kell explicitly
/// authorized engineering for this behavior (Nov 19 2026) once the SYSTEM DESIGN ->
/// VISUAL DESIGN artifact gate was satisfied (Figma board node 8-155, design file
/// jBOzv1vO2C2DSMePqRl4c4 page "Crisis Support" 1214:170).
///
/// Nov 19 2026, revised: a first pass of this policy treated a `Set<String>` of every
/// tier seen, with "fallback" (a genuine check failure/timeout) in the SAME permanently-
/// latching set as `crisis_self`/`crisis_other`/`ongoing_danger`. Kell caught the real
/// problem with that: a technical outage is NOT itself evidence of a genuine current
/// concern, and a `Set` has no notion of "later" -- so a conversation that hit one
/// transient proxy failure early on could never return to ordinary reflection even
/// after every subsequent turn came back clean. This file now takes the full ORDERED
/// sequence of tiers (`CaptureConversationView.safetyTierSequence`, not the unordered
/// `safetyTiersSeen` Set `FormationEligibilityPolicy` reads) and distinguishes:
///   - a PERMANENT latch, once any turn is a genuine current/unresolved concern
///     (`crisis_self`/`crisis_other`/`ongoing_danger`) -- never clears, by design;
///   - a TEMPORARY pending hold, while the most recent unresolved signal is a real
///     check failure (`fallback`) with no real check since -- blocks saving for now,
///     but clears the moment a later turn is actually read as `normal` or `refusal`
///     (both mean the proxy's real classifier DID run and found nothing current).
enum CrisisSupportPolicy {

    /// A genuine current/unresolved concern -- self-risk, third-party-risk disclosure
    /// the user raised, or ongoing danger from someone else. Establishing ANY of these
    /// once latches PERMANENTLY for the rest of the conversation; calming down or
    /// shifting into worship/God-encounter language afterward does not clear it, and
    /// neither does this file pretending a later "normal" turn can reverse a real
    /// latch -- `status(forTierSequence:)` below never un-latches once this fires.
    static let genuineConcernTiers: Set<String> = ["crisis_self", "crisis_other", "ongoing_danger"]

    /// An unverifiable turn -- the proxy's safety check genuinely failed or timed out
    /// (CaptureConversationView's `requestDwellyResponse` catch block). This is NOT
    /// evidence of a real concern by itself, only of a check that couldn't complete --
    /// it creates a TEMPORARY hold, not a latch.
    static let pendingTiers: Set<String> = ["fallback"]

    /// A real, completed safety check that found nothing current -- either "normal"
    /// (no concern) or "refusal" (a B3 misuse request was declined, which is itself
    /// evidence the classifier actually ran, just that what it found was misuse, not a
    /// safety concern about the user or someone they named). Either one resolves an
    /// outstanding pending hold, because both mean a real check ran and came back clean.
    /// A refusal alone is NOT itself a crisis -- but it is also not blind to one: if the
    /// SAME turn's content separately carries a genuine concern, the proxy emits one of
    /// `genuineConcernTiers` instead of (or in addition to, across turns) "refusal", and
    /// that tier -- not this one -- is what the permanent latch keys on. This file only
    /// ever sees the one tier string a turn resolved to, so "refusal" here always means
    /// "misuse only, no concern tier fired for this turn."
    ///
    /// Deliberately does NOT include "fixed_closer_skipped" (onboarding's benign,
    /// deliberate skip of the proxy on its fixed 3rd/closing response) -- that turn was
    /// never actually checked at all, so it cannot resolve a prior unresolved check the
    /// way a real "normal"/"refusal" verdict can. It also never itself creates a pending
    /// hold (it's not in `pendingTiers`) -- skipping the check on purpose isn't the same
    /// as the check failing.
    static let resolvingTiers: Set<String> = ["normal", "refusal"]

    enum Status: Equatable {
        /// No genuine concern has ever been established, and there is no outstanding
        /// unresolved check failure right now -- ordinary reflection proceeds.
        case clear
        /// The most recent unresolved signal is a real check failure, with no real
        /// check since. Blocks saving for NOW (can't rule out a missed concern), but
        /// is NOT permanent -- a later "normal"/"refusal" turn clears it.
        case pendingHold
        /// A genuine current/unresolved concern was established at some point in this
        /// conversation. Permanent for the rest of the conversation, full stop.
        case latched
    }

    /// Walks the tier sequence in order. A genuine-concern tier short-circuits to
    /// `.latched` and nothing after it matters. Otherwise, pending/resolving tiers
    /// toggle an in-progress "unresolved" flag as they're encountered in order --
    /// this is exactly why an ORDERED sequence is required here, not a `Set`: the
    /// same tiers in a different order can mean a different final status (fallback
    /// THEN normal resolves; normal THEN fallback does not).
    static func status(forTierSequence tiers: [String]) -> Status {
        var pending = false
        for tier in tiers {
            if genuineConcernTiers.contains(tier) {
                return .latched
            } else if pendingTiers.contains(tier) {
                pending = true
            } else if resolvingTiers.contains(tier) {
                pending = false
            }
            // Any other tier (e.g. "fixed_closer_skipped") leaves `pending` untouched.
        }
        return pending ? .pendingHold : .clear
    }

    /// Both `.pendingHold` and `.latched` block saving for the whole conversation --
    /// the difference between them is whether that block can still lift later, not
    /// whether it applies right now. Callers that only need "do I block saving right
    /// now" (e.g. CaptureConversationView's save gate) should use this; callers that
    /// need to distinguish temporary-vs-permanent should read `status` directly.
    static func blocksSaving(forTierSequence tiers: [String]) -> Bool {
        status(forTierSequence: tiers) != .clear
    }

    /// Picks the single most relevant tier to source the in-thread resource block from,
    /// when more than one latching/pending tier appeared across the conversation.
    /// Priority: a real self-risk signal outranks ongoing-danger-from-someone-else,
    /// which outranks a third-party-risk disclosure, which outranks a bare unresolved
    /// check failure -- each step down is a real but lower-certainty signal than the
    /// one above it. Takes the plain membership (order doesn't matter for this pick).
    static func primaryResourceTier(forTiersSeen tiersSeen: Set<String>) -> SafetyResourceCenter.Tier? {
        if tiersSeen.contains("crisis_self") { return .crisisSelf }
        if tiersSeen.contains("ongoing_danger") { return .ongoingDanger }
        if tiersSeen.contains("crisis_other") { return .crisisOther }
        if tiersSeen.contains("fallback") { return .fallback }
        return nil
    }
}

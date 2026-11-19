// Crisis Support -- a real, offline, executable test against the actual production
// file (CrisisSupportPolicy.swift), not a reimplementation/mock of its logic. Same
// pattern as Scripts/formation_eligibility_policy_test (T-125) -- this project has no
// registered XCTest target. Run with:
//
//   cd "Dwelly"
//   xcrun swiftc Dwelly/Managers/SafetyResourceCenter.swift Dwelly/Managers/FormationEligibilityPolicy.swift Dwelly/Managers/CrisisSupportPolicy.swift Scripts/crisis_support_policy_test/main.swift -o /tmp/crisis_support_test && /tmp/crisis_support_test
//
// LIMIT, stated plainly: this tests the pure policy decision (CrisisSupportPolicy) for
// real, but does NOT exercise CaptureConversationView's actual save-gating wiring
// (finishWithoutSaving/finishAndSave, the onChange branch, the composer-mount
// conditions, or the real append-order of `safetyTierSequence` as turns actually
// arrive asynchronously) -- there is no XCTest target to host a SwiftUI view/async-
// method test, and this project's APIClient/SyncManager/DwellerProfileManager are not
// structured for dependency-injected testing the way llm-proxy's handler.ts was
// refactored for T-125. That wiring is instead checked with a real `xcodebuild` (type-
// correctness of the actual integration) plus a static source-text check
// (verify_no_save_calls.sh) that reads the real file and confirms finishWithoutSaving()'s
// body contains none of the six save/synthesis/profile/retry calls finishAndSave() makes.
// Neither substitutes for true runtime integration coverage of an actual conversation
// (with real async turn arrival, real Finish timing, a real mid-conversation reassessment)
// reaching Finish -- that would need either an XCTest target or a live run, and this
// session was explicitly told not to interact with live data.

import Foundation

func check(_ cond: Bool, _ label: String) {
    if cond { print("ok   - \(label)") }
    else { print("FAIL - \(label)"); exit(1) }
}

typealias Status = CrisisSupportPolicy.Status

// -- Tier set membership --
check(CrisisSupportPolicy.genuineConcernTiers.contains("crisis_self"), "genuine-concern tiers include crisis_self")
check(CrisisSupportPolicy.genuineConcernTiers.contains("crisis_other"), "genuine-concern tiers include crisis_other")
check(CrisisSupportPolicy.genuineConcernTiers.contains("ongoing_danger"), "genuine-concern tiers include ongoing_danger")
check(!CrisisSupportPolicy.genuineConcernTiers.contains("fallback"), "fallback is NOT a genuine-concern tier -- an outage is not itself evidence of a crisis")
check(!CrisisSupportPolicy.genuineConcernTiers.contains("refusal"), "refusal alone is NOT a genuine-concern tier -- B3 misuse has its own refusal reply, not a support-mode signal")
check(CrisisSupportPolicy.pendingTiers == ["fallback", "unverified"], "pending (temporary-hold) tiers are exactly {fallback, unverified} -- unverified = no recognized verdict in the response")
check(CrisisSupportPolicy.status(forTierSequence: ["unverified"]) == .pendingHold, "a response with no recognized safety verdict is a pending hold, never clear")
check(CrisisSupportPolicy.status(forTierSequence: ["unverified", "normal"]) == .clear, "an unverified turn followed by a real clean check resolves")
check(CrisisSupportPolicy.resolvingTiers == ["normal", "refusal"], "resolving tiers are exactly {normal, refusal} -- both mean a real check actually ran and found nothing current")
check(!CrisisSupportPolicy.resolvingTiers.contains("fixed_closer_skipped"), "fixed_closer_skipped does NOT resolve a pending hold -- it was never actually checked at all")

// -- Clear conversations (never blocks saving) --
check(CrisisSupportPolicy.status(forTierSequence: []) == .clear, "no tiers seen at all -> clear")
check(CrisisSupportPolicy.status(forTierSequence: ["normal"]) == .clear, "all-normal conversation -> clear")
check(CrisisSupportPolicy.status(forTierSequence: ["normal", "refusal"]) == .clear, "a misuse refusal with no accompanying concern tier -> clear")
check(CrisisSupportPolicy.status(forTierSequence: ["normal", "fixed_closer_skipped"]) == .clear, "onboarding's benign fixed-closer skip never blocks saving by itself")

// -- Scenario: outage, then safe reassessment (the exact bug Kell caught) --
check(CrisisSupportPolicy.status(forTierSequence: ["fallback"]) == .pendingHold, "outage: a real check failure alone is a PENDING hold, not a permanent latch")
check(CrisisSupportPolicy.status(forTierSequence: ["fallback", "normal"]) == .clear, "outage then safe reassessment: a later real clean check RESOLVES the pending hold -- ordinary reflection can resume")
check(CrisisSupportPolicy.status(forTierSequence: ["fallback", "refusal"]) == .clear, "outage then a later refusal also resolves the hold -- the proxy ran for real and found misuse, not a concern")
check(CrisisSupportPolicy.status(forTierSequence: ["normal", "fallback"]) == .pendingHold, "order matters: normal THEN fallback still ends pending (the failure is the LAST unresolved signal)")
check(CrisisSupportPolicy.status(forTierSequence: ["fallback", "fixed_closer_skipped"]) == .pendingHold, "a benign proxy skip does NOT resolve an earlier outstanding pending hold -- it was never actually checked")
check(CrisisSupportPolicy.status(forTierSequence: ["fallback", "fallback", "normal"]) == .clear, "repeated outages still resolve once a real clean check finally lands")
check(CrisisSupportPolicy.status(forTierSequence: ["fallback", "normal", "fallback"]) == .pendingHold, "a SECOND outage after a resolved first one re-opens a new pending hold")

// -- Scenario: ambiguous, then false alarm (the classifier resolves ambiguity server-side
// into one tier -- this models the resolved-to-normal outcome, since "ambiguous" never
// appears as its own tier string on this side of the proxy) --
check(CrisisSupportPolicy.status(forTierSequence: ["normal", "normal"]) == .clear, "an ambiguous turn clarified to normal by a follow-up question -> clear, real reflection resumes")

// -- Scenario: actual concern, then calm/God encounter (must NEVER clear) --
check(CrisisSupportPolicy.status(forTierSequence: ["crisis_self"]) == .latched, "self-risk alone -> permanent latch")
check(CrisisSupportPolicy.status(forTierSequence: ["crisis_self", "normal"]) == .latched, "latches through: crisis turn followed by a calm turn stays latched (calming is not a false alarm)")
check(CrisisSupportPolicy.status(forTierSequence: ["crisis_self", "normal", "normal", "normal"]) == .latched, "latches through many subsequent calm turns, however long the calm stretch runs")
check(CrisisSupportPolicy.status(forTierSequence: ["normal", "crisis_other", "normal"]) == .latched, "latches through a mid-conversation third-party disclosure, even if the turns before and after are calm")
check(CrisisSupportPolicy.status(forTierSequence: ["crisis_self", "fallback", "normal"]) == .latched, "once genuinely latched, a LATER outage-then-reassessment sequence does not pretend to clear the real concern")

// -- Scenario: urgent concern even without an exact plan -- this policy only ever sees
// the tier string a turn resolved to, never the underlying content/plan detail, so a
// genuine-concern tier latches the same way regardless of whether the disclosure
// included a specific plan; that nuance is the backend classifier's job (handler.ts's
// Axis A/B read), not something this frontend policy re-derives or could weaken.
check(CrisisSupportPolicy.status(forTierSequence: ["ongoing_danger"]) == .latched, "urgent third-party danger latches on the tier alone, with no plan/detail required at this layer")
check(CrisisSupportPolicy.status(forTierSequence: ["crisis_other"]) == .latched, "a vague-but-urgent third-party disclosure (no exact plan) still latches -- severity of detail is not this policy's concern, the tier already encodes it")

// -- Scenario: a refusal alongside a genuine concern -- each turn's own tier is
// recorded independently; a refusal on one turn never cancels a concern tier seen on
// another turn, and a concern tier is what the latch keys on regardless of order.
check(CrisisSupportPolicy.status(forTierSequence: ["refusal", "crisis_self"]) == .latched, "a misuse refusal followed by a genuine concern still latches -- the refusal doesn't suppress it")
check(CrisisSupportPolicy.status(forTierSequence: ["crisis_self", "refusal"]) == .latched, "a genuine concern followed by an unrelated refusal stays latched -- the refusal doesn't clear it")

// -- blocksSaving matches status != .clear exactly --
check(CrisisSupportPolicy.blocksSaving(forTierSequence: []) == false, "blocksSaving: clear -> false")
check(CrisisSupportPolicy.blocksSaving(forTierSequence: ["fallback"]) == true, "blocksSaving: pendingHold -> true")
check(CrisisSupportPolicy.blocksSaving(forTierSequence: ["crisis_self"]) == true, "blocksSaving: latched -> true")

// -- Excluded derivative: FormationEligibilityPolicy's own candidate set must not be
// confused with this policy's genuine-concern set -- they intentionally differ (this
// session's whole point was that Formation-eligibility alone is NOT a sufficient
// guarantee here).
check(FormationEligibilityPolicy.candidateExcludedTiers != CrisisSupportPolicy.genuineConcernTiers, "CrisisSupportPolicy's genuine-concern set is deliberately NOT the same set as FormationEligibilityPolicy's candidate exclusions")

// -- Primary resource tier selection (priority order for the in-thread resource card) --
check(CrisisSupportPolicy.primaryResourceTier(forTiersSeen: ["crisis_self", "ongoing_danger", "crisis_other"]) == .crisisSelf, "self-risk outranks every other tier for which resource lines to show")
check(CrisisSupportPolicy.primaryResourceTier(forTiersSeen: ["ongoing_danger", "crisis_other"]) == .ongoingDanger, "ongoing danger outranks third-party disclosure")
check(CrisisSupportPolicy.primaryResourceTier(forTiersSeen: ["crisis_other", "fallback"]) == .crisisOther, "third-party disclosure outranks a bare fallback")
check(CrisisSupportPolicy.primaryResourceTier(forTiersSeen: ["fallback"]) == .fallback, "fallback alone still returns a tier so the closure card has real resource lines, not a blank card")
check(CrisisSupportPolicy.primaryResourceTier(forTiersSeen: ["normal"]) == nil, "a clear conversation has no primary resource tier at all")

print("ALL CHECKS PASSED")

// Run: xcrun swiftc -parse-as-library Dwelly/Managers/SafetyResourceCenter.swift Dwelly/Managers/CrisisSupportPolicy.swift Dwelly/Managers/LLMResponse.swift Dwelly/Managers/LocalExplicitHarmSignal.swift Dwelly/Managers/CaptureSafetySession.swift Scripts/final_closer_test/main.swift -o /tmp/fc_t && /tmp/fc_t
import Foundation

@main
struct FinalCloserTest {
    @MainActor static var fails = 0, passes = 0
    @MainActor static func check(_ ok: Bool, _ name: String) { if ok { passes += 1 } else { fails += 1; print("FAIL: \(name)") } }
    @MainActor static func f(_ tier: String, _ closer: String?, _ copy: String) -> String? {
        CaptureSafetySession.onboardingClosingText(recordedTier: tier, closer: closer, fixedCopy: copy)
    }

    @MainActor static func main() {
        let copy = "FIXED HAND-OFF"
        // Marker present + verified normal => the fixed hand-off
        check(f("normal", "onboarding_final", copy) == copy, "normal + marker -> fixed hand-off")
        // Clarifying question on the final turn: tier normal, NO marker => NOT replaced
        check(f("normal", nil, copy) == nil, "normal WITHOUT marker (clarify / old backend) is never replaced by the hand-off")
        check(f("normal", "something_else", copy) == nil, "unknown marker value ignored")
        check(f("normal", "", copy) == nil, "empty marker ignored")
        // Every non-normal tier: never the hand-off, even with a marker (defense in depth)
        for tier in ["crisis_self", "crisis_other", "ongoing_danger", "refusal", "fallback", "unverified", "banana"] {
            check(f(tier, "onboarding_final", copy) == nil, "\(tier) + marker -> no hand-off")
            check(f(tier, nil, copy) == nil, "\(tier) no marker -> no hand-off")
        }
        // Older helper unchanged (still used by the runtime harness)
        check(CaptureSafetySession.onboardingClosingText(recordedTier: "normal", fixedCopy: copy) == copy, "legacy helper unchanged")
        // Safety clarifying question on the final turn => one extra turn, once, only for verified-normal without marker
        let g = CaptureSafetySession.grantsClarifyExtraTurn
        check(g(true, "normal", nil, false) == true, "final turn + clarify (normal, no marker) -> extra turn granted")
        check(g(true, "normal", "onboarding_final", false) == false, "the hand-off itself never grants an extra turn")
        check(g(true, "normal", nil, true) == false, "granted at most once")
        check(g(false, "normal", nil, false) == false, "a clarify on reply 1 or 2 is just a normal reply (no extra turn)")
        for tier in ["crisis_self", "crisis_other", "ongoing_danger", "refusal", "fallback", "unverified"] {
            check(g(true, tier, nil, false) == false, "\(tier) never grants an extra turn (support path / no-save rules apply)")
        }
        print(fails == 0 ? "ALL PASS (\(passes))" : "\(fails) FAILED, \(passes) passed")
        exit(fails == 0 ? 0 : 1)
    }
}

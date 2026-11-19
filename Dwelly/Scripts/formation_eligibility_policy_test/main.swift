// T-125 downstream protection -- a real, offline, executable test against the actual
// production file (not a duplicate/mock of its logic). Run with:
//
//   cd "Dwelly"   (this repo's app subfolder, same level as Dwelly.xcodeproj)
//   xcrun swiftc Dwelly/Managers/FormationEligibilityPolicy.swift Scripts/formation_eligibility_policy_test/main.swift -o /tmp/fep_test && /tmp/fep_test
//
// (Named `main.swift` specifically -- Swift only allows top-level executable
// statements in a file with that exact name when compiling multiple files together
// with `swiftc`; any other filename fails with "expressions are not allowed at the
// top level", confirmed while building this. Not an XCTest case because this
// project has no registered unit-test target -- see docs/T125_SAFETY_ACCEPTANCE_TESTS.md
// for why that wasn't added as part of this work. Compiling this file together with the real
// FormationEligibilityPolicy.swift via `swiftc` and running the result is a genuine
// execution of the real code, not a description of expected behavior.)

import Foundation

func check(_ cond: Bool, _ label: String) {
    if cond { print("ok   - \(label)") }
    else { print("FAIL - \(label)"); exit(1) }
}

check(FormationEligibilityPolicy.isActive == false, "policy is inactive by default (pending Kell's decision)")
check(FormationEligibilityPolicy.decision(forTiersSeen: ["crisis_self"]) == .eligible, "inactive policy: even crisis_self stays eligible until activated")
check(FormationEligibilityPolicy.decision(forTiersSeen: []) == .eligible, "inactive policy: no tiers -> eligible")

check(FormationEligibilityPolicy.candidateExcludedTiers.contains("crisis_self"), "candidate includes crisis_self")
check(FormationEligibilityPolicy.candidateExcludedTiers.contains("refusal"), "candidate includes refusal")
check(FormationEligibilityPolicy.candidateExcludedTiers.contains("fallback"), "candidate includes fallback (unknown/failed checks are conservative)")
check(!FormationEligibilityPolicy.candidateExcludedTiers.contains("crisis_other"), "candidate does NOT include crisis_other (third-party disclosure stays eligible)")
check(!FormationEligibilityPolicy.candidateExcludedTiers.contains("ongoing_danger"), "candidate does NOT include ongoing_danger (abuse disclosure stays eligible)")
check(!FormationEligibilityPolicy.candidateExcludedTiers.contains("normal"), "candidate does NOT include normal")

func wouldExclude(_ tiers: Set<String>) -> Bool {
    !tiers.isDisjoint(with: FormationEligibilityPolicy.candidateExcludedTiers)
}
check(wouldExclude(["crisis_self"]) == true, "if active: a crisis_self turn would exclude")
check(wouldExclude(["refusal"]) == true, "if active: a refusal turn would exclude")
check(wouldExclude(["fallback"]) == true, "if active: a fallback (unchecked) turn would exclude")
check(wouldExclude(["crisis_other"]) == false, "if active: crisis_other ALONE would NOT exclude")
check(wouldExclude(["ongoing_danger"]) == false, "if active: ongoing_danger ALONE would NOT exclude")
check(wouldExclude(["normal", "normal"]) == false, "if active: an all-normal conversation would NOT exclude")
check(wouldExclude(["normal", "normal", "crisis_self", "normal"]) == true, "if active: ONE excluded-tier turn anywhere in a mixed conversation excludes the whole entry")
check(wouldExclude(["ongoing_danger", "normal"]) == false, "if active: a mixed conversation with only ongoing_danger + normal stays eligible")

print("ALL CHECKS PASSED")

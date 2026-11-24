import Foundation
var fails = 0, passes = 0
func check(_ ok: Bool, _ name: String) { if ok { passes += 1 } else { fails += 1; print("FAIL: \(name)") } }

check(CaptureBudget(isOnboarding: true).limit == 30_000, "onboarding limit")
check(CaptureBudget(isOnboarding: false).limit == 100_000, "regular limit")

// Exact vs unknown accounting
var b = CaptureBudget(isOnboarding: true)
b.record(pipelineTokens: 1_200, complete: true, ceilingIfUnknown: 9_999)
check(b.spent == 1_200, "complete total used exactly")
b.record(pipelineTokens: 500, complete: false, ceilingIfUnknown: 1_000)
check(b.spent == 2_700, "partial = reported + ceiling, never just reported")
b.record(pipelineTokens: nil, complete: nil, ceilingIfUnknown: 1_000)
check(b.spent == 3_700, "old backend with no field counts ceiling, not zero")
b.recordUnknown(ceiling: 1_000)
check(b.spent == 4_700, "network failure counts ceiling, not zero")

// Boundary: exactly at limit continues, one over finishes
var c = CaptureBudget(isOnboarding: true)
c.record(pipelineTokens: 20_000, complete: true, ceilingIfUnknown: 0)
check(c.decision(nextTurnCost: 5_000, finishReserve: 5_000) == .continueOrdinary, "exactly at limit continues")
check(c.decision(nextTurnCost: 5_001, finishReserve: 5_000) == .finishNow, "one over finishes")
check(c.decision(nextTurnCost: 0, finishReserve: 10_001) == .finishNow, "reserve alone can trigger finish")

// Finish reserve derives from real sizes and grows with transcript/profile
let small = CaptureBudget.finishReserve(synthesisPrompt: String(repeating: "word ", count: 100), existingProfileSummary: "short", profileInstructionTokens: 200)
let big = CaptureBudget.finishReserve(synthesisPrompt: String(repeating: "word ", count: 5_000), existingProfileSummary: String(repeating: "x", count: 3_000), profileInstructionTokens: 200)
check(big > small, "reserve grows with transcript and profile")
let unknownProfile = CaptureBudget.finishReserve(synthesisPrompt: "a", existingProfileSummary: nil, profileInstructionTokens: 200)
check(unknownProfile >= 200 + CaptureBudget.profileOutputCeiling + CaptureBudget.synthesisOutputCeiling + CaptureBudget.profileOutputCeiling, "unknown profile uses its output ceiling, not zero")
check(small >= CaptureBudget.synthesisOutputCeiling + CaptureBudget.synthesisOutputCeiling + CaptureBudget.profileOutputCeiling, "reserve includes output ceilings")

// Next turn cost counts the transcript twice (classifier + main), plus ceiling and overhead
check(CaptureBudget.nextTurnCost(transcriptTokens: 1_000, newUserTokens: 200, safetyOverhead: 1_300) == 2 * 1_200 + 1_000 + 1_300, "next turn formula")

// Whole pipeline stays within the limit when the policy says continue (simulated growth)
var sim = CaptureBudget(isOnboarding: false)
var transcript = 500, turns = 0
while true {
    let reserve = CaptureBudget.finishReserve(synthesisPrompt: String(repeating: "w", count: transcript * 3), existingProfileSummary: nil, profileInstructionTokens: 200)
    let next = CaptureBudget.nextTurnCost(transcriptTokens: transcript, newUserTokens: 400, safetyOverhead: 1_300)
    if sim.decision(nextTurnCost: next, finishReserve: reserve) == .finishNow {
        check(sim.spent + reserve <= sim.limit, "at finish, reserve still fits")
        break
    }
    sim.record(pipelineTokens: next, complete: true, ceilingIfUnknown: 0) // worst case: full ceiling used
    transcript += 400 + 300
    turns += 1
    if turns > 1000 { check(false, "never finished"); break }
}
check(turns > 5, "regular capture allows a meaningful number of turns (\(turns))")
// Worst-case completion never exceeds limit
let finalReserve = CaptureBudget.finishReserve(synthesisPrompt: String(repeating: "w", count: transcript * 3), existingProfileSummary: nil, profileInstructionTokens: 200)
check(sim.spent + finalReserve <= sim.limit, "spent + finish within limit at boundary")

// Estimator sanity (heuristic only)
check(CaptureBudget.estimateTokens("") == 0, "empty")
check(CaptureBudget.estimateTokens("abc") == 1, "3 ascii = 1 token")
check(CaptureBudget.estimateTokens(String(repeating: "a", count: 3000)) == 1000, "3000 ascii = 1000 (not 3000: old estimator was ~4x over)")
check(CaptureBudget.estimateTokens("我今天很累") == 10, "cjk 2/char")
check(CaptureBudget.estimateTokens("😂") == 2, "emoji 2")
check(CaptureBudget.estimateTokens("hello world") >= 3, "english nonzero")
check(CaptureBudget.estimateTokens("我今天很累") >= 5, "cjk at least one token per char")

// lastRecordedCost tracks the most recent request (used as next-turn safety overhead)
var lr = CaptureBudget(isOnboarding: false)
lr.record(pipelineTokens: 3_000, complete: true, ceilingIfUnknown: 0)
lr.record(pipelineTokens: nil, complete: nil, ceilingIfUnknown: 4_000)
check(lr.lastRecordedCost == 4_000, "last recorded cost is the unknown ceiling, not zero")

// Closing sanitizer
check(BudgetClosing.sanitize("It sounds like the move to a new city is weighing on you.") != nil, "grounded sentence kept")
check(BudgetClosing.sanitize("You're still unsure whether to take the job.") != nil, "uncertainty kept")
check(BudgetClosing.sanitize(nil) == nil, "nil")
check(BudgetClosing.sanitize("   ") == nil, "blank")
check(BudgetClosing.sanitize("Thanks for sharing that with me.") == nil, "gratitude dropped")
check(BudgetClosing.sanitize("Here\u{2019}s what I learned: you feel tired.") == nil, "what-I-learned dropped")
check(BudgetClosing.sanitize("What do you think is next?") == nil, "question dropped")
check(BudgetClosing.sanitize("You feel lost. God has it all worked out now.") == nil, "two sentences dropped, not truncated")
check(BudgetClosing.sanitize("Consider John 3:16 for this.") == nil, "new reference dropped")
check(BudgetClosing.sanitize("Psalm 23 fits here.") == nil, "psalm mention dropped")
check(BudgetClosing.fixedFollowUp == "Here\u{2019}s your journal for this moment. You can start another capture to keep exploring.", "fixed follow-up copy")

print(fails == 0 ? "ALL PASS (\(passes))" : "\(fails) FAILED, \(passes) passed")
exit(fails == 0 ? 0 : 1)

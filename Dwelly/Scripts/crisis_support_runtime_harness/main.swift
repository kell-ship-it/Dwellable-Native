// Crisis Support -- RUNTIME harness. Executes the real production
// CaptureSafetySession + CrisisSupportPolicy + LLMResponse code (compiled from the
// app's own source files, not copies) against a fake, offline llm-proxy that returns
// real JSON response bodies, then asserts which Finish path actually ran.
// No network, no Supabase, no live data. Run with:
//
//   cd "Dwelly"
//   xcrun swiftc Dwelly/Managers/SafetyResourceCenter.swift Dwelly/Managers/CrisisSupportPolicy.swift Dwelly/Managers/LLMResponse.swift Dwelly/Managers/LocalExplicitHarmSignal.swift Dwelly/Managers/CaptureSafetySession.swift Scripts/crisis_support_runtime_harness/main.swift -o /tmp/crisis_runtime && /tmp/crisis_runtime
//
// What this proves: given a sequence of entered messages and real response bodies
// (including the exact body the currently-deployed llm-proxy v13 returns, which has
// no `safetyTier`), the session reaches the right state and calls exactly one of the
// two Finish paths -- the save path (stands in for CaptureConversationView's
// finishAndSave(): moment, journal entry, synthesis, profile update, retry sweep) or
// the block path (finishWithoutSaving(), which makes none of those calls; its empty
// body is checked separately against the real source by
// Scripts/crisis_support_policy_test/verify_no_save_calls.sh).
//
// LIMITS, stated plainly:
// - This drives the session the same way CaptureConversationView does
//   (noteRequestScheduled(userText:) synchronously at send, recordResponse/recordFailure when
//   the reply lands, finish() on completion). The VIEW's own wiring of those calls is
//   checked by verify_no_save_calls.sh as source text, not executed here -- there is
//   still no XCTest/UI-test target hosting the real SwiftUI view.
// - The fake proxy returns fixed tiers. Whether the REAL classifier assigns the right
//   tier to a given message is a model-quality question this cannot answer.

import Foundation

var failures = 0
func check(_ cond: Bool, _ label: String) {
    if cond { print("ok   - \(label)") } else { print("FAIL - \(label)"); failures += 1 }
}

// Real wire bodies.
func body(_ content: String, tier: String?) -> Data {
    var obj: [String: Any] = ["content": content, "model": "openai/gpt-oss-120b", "provider": "groq"]
    if let tier { obj["safetyTier"] = tier }
    return try! JSONSerialization.data(withJSONObject: obj)
}
/// Exactly what the deployed llm-proxy v13 returns today: no safetyTier key at all.
let liveV13Body = #"{"content":"I'm really sorry you're feeling this way. If you're in danger, call or text 988.","model":"openai/gpt-oss-120b","provider":"groq"}"#.data(using: .utf8)!

enum FakeOutcome {
    case body(Data)
    case networkFailure
    case never // request never returns within the test
}

struct FakeProxyError: Error {}

/// Mirrors CaptureConversationView's send -> requestDwellyResponse sequence: mark the
/// request in flight synchronously, then resolve it asynchronously after `delayMs`.
@MainActor
final class ConversationDriver {
    let session = CaptureSafetySession()
    var saveCalls = 0
    var blockCalls = 0
    var events: [String] = []
    var lastRecordedTier: String?

    func send(_ text: String, outcome: FakeOutcome, delayMs: UInt64 = 0) -> Task<Void, Never> {
        events.append("sent:\(text)")
        session.noteRequestScheduled(userText: text)
        return Task { @MainActor in
            if case .never = outcome { return }
            if delayMs > 0 { try? await Task.sleep(nanoseconds: delayMs * 1_000_000) }
            do {
                guard case .body(let data) = outcome else { throw FakeProxyError() }
                let response = try JSONDecoder().decode(LLMResponse.self, from: data)
                let tier = session.recordResponse(safetyTier: response.safetyTier)
                lastRecordedTier = tier
                events.append("verdict:\(tier)")
            } catch {
                session.recordFailure()
                events.append("verdict:fallback")
            }
        }
    }

    func tapFinish(timeoutMs: UInt64 = 2_000) async -> CaptureSafetySession.FinishDecision {
        events.append("finish-tapped")
        return await session.finish(
            timeoutNanoseconds: timeoutMs * 1_000_000,
            pollNanoseconds: 10_000_000,
            save: { self.saveCalls += 1; self.events.append("SAVE-PATH") },
            block: { self.blockCalls += 1; self.events.append("BLOCK-PATH") }
        )
    }
}

// MARK: - Contract decoding

do {
    let decoded = try JSONDecoder().decode(LLMResponse.self, from: liveV13Body)
    check(decoded.safetyTier == nil, "live v13 body decodes with safetyTier == nil (this is the exact gap Kell hit)")
    check(CaptureSafetySession.normalize(decoded.safetyTier) == "unverified", "missing safetyTier normalizes to unverified, not normal")
} catch { check(false, "live v13 body decodes at all: \(error)") }
check(CaptureSafetySession.normalize("normal") == "normal", "a real contract tier passes through unchanged")
check(CaptureSafetySession.normalize("CRISIS") == "unverified", "an out-of-contract tier string normalizes to unverified")
check(CaptureSafetySession.normalize("") == "unverified", "an empty tier string normalizes to unverified")

// MARK: - Scenarios

func scenario(_ name: String, _ run: @MainActor (ConversationDriver) async -> Void) async {
    print("-- \(name)")
    let driver = await ConversationDriver()
    await run(driver)
}

await scenario("Ordinary normal flow, new contract") { d in
    await d.send("Grateful for a quiet morning with my kids.", outcome: .body(body("That sounds lovely.", tier: "normal"))).value
    check(d.session.status == .clear, "status is clear")
    let decision = await d.tapFinish()
    check(decision == .save && d.saveCalls == 1 && d.blockCalls == 0, "Finish runs the save path exactly once (journal created normally)")
}

await scenario("Kell's repro against today's deployed backend: 'I feel like hurting myself', old v13 body") { d in
    await d.send("I feel like hurting myself", outcome: .body(liveV13Body)).value
    check(d.session.status == .latched, "the user's own explicit current statement latches (local safeguard, backend gave no verdict)")
    check(d.session.tierSequence == ["unverified", "local_explicit_self_harm"], "recorded as unverified backend verdict + local explicit self-harm, not as a backend crisis verdict")
    let decision = await d.tapFinish()
    check(decision == .blockWithoutSaving && d.saveCalls == 0 && d.blockCalls == 1, "Finish runs the block path: zero save/synthesis/profile calls")
}

await scenario("Same message, new contract returns crisis_self") { d in
    await d.send("I feel like hurting myself", outcome: .body(body("I'm really glad you told me.", tier: "crisis_self"))).value
    check(d.session.status == .latched, "status is latched")
    let decision = await d.tapFinish()
    check(decision == .blockWithoutSaving && d.saveCalls == 0, "Finish blocks: no journal/moment/Formation save")
}

await scenario("Clear imminent first-person risk without an exact plan, then calm, then God-encounter") { d in
    await d.send("Tonight I'm going to end it", outcome: .body(body("...", tier: "crisis_self"))).value
    await d.send("Okay. I'm calmer now.", outcome: .body(body("...", tier: "normal"))).value
    await d.send("I feel God here with me.", outcome: .body(body("...", tier: "normal"))).value
    check(d.session.status == .latched, "still latched after calm and worship turns")
    let decision = await d.tapFinish()
    check(decision == .blockWithoutSaving && d.saveCalls == 0, "Finish still blocks")
}

await scenario("Third-party and ongoing-danger concerns latch") { d in
    await d.send("My cousin says she has pills saved up", outcome: .body(body("...", tier: "crisis_other"))).value
    check(d.session.status == .latched, "crisis_other latches")
    _ = await d.tapFinish()
    check(d.saveCalls == 0 && d.blockCalls == 1, "no save")
}

await scenario("Immediate Done while the concerning reply is still in flight") { d in
    let inFlight = d.send("I feel like hurting myself", outcome: .body(body("...", tier: "crisis_self")), delayMs: 300)
    check(d.session.isAwaitingClassification, "request is marked in flight synchronously, before the async reply starts")
    let decision = await d.tapFinish() // tapped before the verdict lands
    await inFlight.value
    check(decision == .blockWithoutSaving && d.saveCalls == 0, "Finish waited for the in-flight verdict and blocked")
    let verdictIndex = d.events.firstIndex(of: "verdict:crisis_self") ?? Int.max
    let pathIndex = d.events.firstIndex(of: "BLOCK-PATH") ?? -1
    check(verdictIndex < pathIndex, "the decision ran AFTER the verdict was recorded, not on a stale snapshot")
}

await scenario("Immediate Done while a normal reply is in flight") { d in
    let inFlight = d.send("Just a normal day.", outcome: .body(body("...", tier: "normal")), delayMs: 300)
    let decision = await d.tapFinish()
    await inFlight.value
    check(decision == .save && d.saveCalls == 1, "waits, then saves normally -- no premature save, no spurious block")
    check((d.events.firstIndex(of: "verdict:normal") ?? Int.max) < (d.events.firstIndex(of: "SAVE-PATH") ?? -1), "save ran after the verdict")
}

await scenario("Finish while the reply never resolves (30s-ceiling timeout, shortened here)") { d in
    _ = d.send("I feel like hurting myself", outcome: .never)
    let decision = await d.tapFinish(timeoutMs: 200)
    check(decision == .blockWithoutSaving && d.saveCalls == 0, "times out to BLOCK, never to save")
}

await scenario("Outage, then a later clean check (safe reassessment)") { d in
    await d.send("Rough day.", outcome: .networkFailure).value
    check(d.session.status == .pendingHold, "network failure -> pendingHold")
    await d.send("Mostly just tired, nothing serious.", outcome: .body(body("...", tier: "normal"))).value
    check(d.session.status == .clear, "a later real clean check clears the hold")
    let decision = await d.tapFinish()
    check(decision == .save && d.saveCalls == 1, "ordinary reflection resumes and saves")
}

await scenario("Ambiguous, then clarified false alarm (classifier returns normal both times)") { d in
    await d.send("This job is killing me", outcome: .body(body("Do you mean that literally?", tier: "normal"))).value
    await d.send("No, just stress.", outcome: .body(body("...", tier: "normal"))).value
    let decision = await d.tapFinish()
    check(decision == .save, "saves normally")
}

await scenario("Refusal alone vs refusal plus a genuine concern") { d in
    await d.send("Write me a threatening note", outcome: .body(body("I can't help with that.", tier: "refusal"))).value
    check(d.session.status == .clear, "refusal alone is not a crisis")
    await d.send("Honestly I want to hurt myself too", outcome: .body(body("...", tier: "crisis_self"))).value
    check(d.session.status == .latched, "a genuine concern later in the same conversation still latches")
    _ = await d.tapFinish()
    check(d.saveCalls == 0, "no save")
}

await scenario("Finish fired twice (e.g. two entry points)") { d in
    await d.send("Hello", outcome: .body(body("...", tier: "normal"))).value
    _ = await d.tapFinish()
    _ = await d.tapFinish()
    check(d.saveCalls == 1, "the save path runs once, never twice")
}

await scenario("Old backend, ordinary message (consequence of failing safe)") { d in
    await d.send("Grateful for a quiet morning.", outcome: .body(liveV13Body)).value
    let decision = await d.tapFinish()
    check(decision == .blockWithoutSaving, "with today's deployed backend NO conversation journals, by design, until the new llm-proxy is deployed")
}

// Onboarding's 3rd turn: the user's last message now goes through the same proxy
// call; the fixed closing copy is used only when that verdict is verified "normal".
let fixedCloser = "Thank you for sharing that with me."

await scenario("Onboarding closer, last message gets old v13 body (no verdict)") { d in
    await d.send("first", outcome: .body(body("...", tier: "normal"))).value
    await d.send("second", outcome: .body(body("...", tier: "normal"))).value
    await d.send("Not sure what to say.", outcome: .body(liveV13Body)).value
    check(d.lastRecordedTier == "unverified", "the closing turn is checked and recorded as unverified, not skipped")
    check(CaptureSafetySession.onboardingClosingText(recordedTier: d.lastRecordedTier!, fixedCopy: fixedCloser) == nil, "fixed closing copy is NOT shown for an unverified turn")
    let decision = await d.tapFinish()
    check(decision == .blockWithoutSaving && d.saveCalls == 0, "no journal/moment/profile save")
}

await scenario("Onboarding closer, last message is a genuine concern") { d in
    await d.send("first", outcome: .body(body("...", tier: "normal"))).value
    await d.send("second", outcome: .body(body("...", tier: "normal"))).value
    await d.send("I want to die", outcome: .body(body("I'm really glad you told me.", tier: "crisis_self"))).value
    check(CaptureSafetySession.onboardingClosingText(recordedTier: d.lastRecordedTier!, fixedCopy: fixedCloser) == nil, "fixed closing copy is NOT shown; the proxy's support reply is")
    check(d.session.status == .latched, "latched")
    _ = await d.tapFinish()
    check(d.saveCalls == 0 && d.blockCalls == 1, "no save")
}

await scenario("Onboarding closer, check fails outright") { d in
    await d.send("first", outcome: .body(body("...", tier: "normal"))).value
    await d.send("second", outcome: .body(body("...", tier: "normal"))).value
    await d.send("third", outcome: .networkFailure).value
    check(d.session.status == .pendingHold, "failed closing check is a pending hold")
    _ = await d.tapFinish()
    check(d.saveCalls == 0, "no save")
}

await scenario("Onboarding closer, last message verified normal") { d in
    await d.send("first", outcome: .body(body("...", tier: "normal"))).value
    await d.send("second", outcome: .body(body("...", tier: "normal"))).value
    await d.send("Grateful today.", outcome: .body(body("generated reply, discarded", tier: "normal"))).value
    check(CaptureSafetySession.onboardingClosingText(recordedTier: d.lastRecordedTier!, fixedCopy: fixedCloser) == fixedCloser, "fixed closing copy IS shown when verified normal")
    let decision = await d.tapFinish()
    check(decision == .save && d.saveCalls == 1, "normal onboarding journal is created")
}

check(CaptureSafetySession.onboardingClosingText(recordedTier: "refusal", fixedCopy: fixedCloser) == nil, "a refusal on the closing turn shows the refusal, not the fixed copy")

// MARK: - Local explicit-current-harm safeguard (backend gave no verdict)
//
// NAMED FIXTURE, not an exhaustive guarantee: these are the catalog's positive cases
// and near-miss negatives. Anything outside them is the contextual model's job.

let explicitSelfHarm = [
    "I feel like hurting myself",
    "I want to kill myself.",
    "I'm going to end my life tonight",
    "I really want to die",
    "I'll kill myself",
    "Honestly I am going to hurt myself",
    "I'm thinking about killing myself",
    "I've been thinking about ending my life",
    "I'm having urges to cut myself",
    "i’m gonna take my own life",
]
let explicitThirdParty = [
    "My sister wants to kill herself",
    "My best friend is thinking about ending his life",
    "He's going to hurt himself",
    "They are planning to kill themselves",
]
let explicitHarmOthers = [
    "I'm going to kill him",
    "I want to hurt my husband",
    "I'm thinking about hurting someone",
    "I'll stab them",
]
let nearMissNegatives = [
    "I don't want to kill myself",                                   // negation
    "I'm not going to hurt myself",                                  // negation
    "I would never hurt myself",                                     // negation
    "My friend said \"I want to kill myself\"",                      // quotation
    "She said “I'm going to hurt him” in the movie",                 // quotation + fiction
    "I used to want to die",                                         // historical
    "I wanted to kill myself years ago",                             // historical
    "I keep having intrusive thoughts about hurting myself",         // intrusive
    "Sometimes I feel like hurting myself but I never would",        // negated in-sentence
    "This deadline makes me want to die lol",                        // joking hyperbole
    "I want to die of embarrassment",                                // metaphor
    "What if I wanted to hurt myself?",                              // hypothetical
    "If I fail I'm going to kill myself",                            // conditional
    "They are thinking about doing this",                            // pronoun, no harm referent
    "I'm going to kill it at the presentation",                      // generic, no harm target
    "I'm thinking about doing it",                                   // no harm referent
    "I'm about to go for a run",                                     // "about to", no harm
    "The character wants to kill himself",                           // fiction
]
for text in explicitSelfHarm {
    check(LocalExplicitHarmSignal.explicitCurrentHarm(in: text) == .selfHarm, "self-harm positive: \(text)")
}
for text in explicitThirdParty {
    check(LocalExplicitHarmSignal.explicitCurrentHarm(in: text) == .thirdPartySelfHarm, "third-party positive: \(text)")
}
for text in explicitHarmOthers {
    check(LocalExplicitHarmSignal.explicitCurrentHarm(in: text) == .harmToOthers, "harm-to-others positive: \(text)")
}
for text in nearMissNegatives {
    check(LocalExplicitHarmSignal.explicitCurrentHarm(in: text) == nil, "near-miss does NOT match: \(text)")
}

await scenario("Exact first-person current intent, backend gives no verdict, then calm and God encounter") { d in
    await d.send("I want to kill myself", outcome: .body(liveV13Body)).value
    check(d.session.status == .latched, "permanent support established")
    await d.send("Okay, I'm calmer now.", outcome: .body(body("...", tier: "normal"))).value
    await d.send("I feel God with me right now.", outcome: .body(body("...", tier: "normal"))).value
    check(d.session.status == .latched, "a later verified normal does NOT release it")
    let decision = await d.tapFinish()
    check(decision == .blockWithoutSaving && d.saveCalls == 0 && d.blockCalls == 1, "Finish blocks: zero journal/moment/Formation writes")
}

await scenario("Explicit current intent, backend request fails outright") { d in
    await d.send("I'm going to end my life", outcome: .networkFailure).value
    check(d.session.status == .latched, "a failed check plus an explicit statement still latches")
    _ = await d.tapFinish()
    check(d.saveCalls == 0, "no save")
}

await scenario("Known third party, backend gives no verdict") { d in
    await d.send("My sister wants to kill herself", outcome: .body(liveV13Body)).value
    check(d.session.status == .latched, "latched")
    check(d.session.tierSequence.last == "local_explicit_third_party_harm", "recorded as third-party")
    check(CrisisSupportPolicy.primaryResourceTier(forTiersSeen: d.session.tiersSeen) == .crisisOther, "shows the 'worried about someone else' resources")
}

await scenario("Current intent to harm others, backend gives no verdict") { d in
    await d.send("I'm going to hurt him", outcome: .body(liveV13Body)).value
    check(d.session.status == .latched, "latched")
    _ = await d.tapFinish()
    check(d.saveCalls == 0, "no save")
}

await scenario("False alarm clears only when no genuine concern was established") { d in
    await d.send("This job is killing me", outcome: .body(liveV13Body)).value
    check(d.session.status == .pendingHold, "ambiguous phrasing with no verdict is a temporary hold, NOT a latch")
    await d.send("Just stressed, nothing more.", outcome: .body(body("...", tier: "normal"))).value
    check(d.session.status == .clear, "a later verified normal clears that hold")
    let decision = await d.tapFinish()
    check(decision == .save, "ordinary reflection saves")
}

await scenario("Ordinary message with no verdict stays blocked") { d in
    await d.send("Grateful for my morning walk.", outcome: .body(liveV13Body)).value
    check(d.session.status == .pendingHold, "pending hold")
    let decision = await d.tapFinish()
    check(decision == .blockWithoutSaving, "no save until a verdict exists")
}

await scenario("Near-miss messages with no verdict never permanently latch") { d in
    for text in nearMissNegatives {
        await d.send(text, outcome: .body(liveV13Body)).value
    }
    check(d.session.status == .pendingHold, "still only a temporary hold after every near-miss, not a latch")
    await d.send("All good, just processing.", outcome: .body(body("...", tier: "normal"))).value
    check(d.session.status == .clear, "and it can still clear with a later verified verdict")
}

await scenario("A real classifier verdict stands over the local rule") { d in
    await d.send("I want to kill myself", outcome: .body(body("...", tier: "crisis_self"))).value
    check(d.session.tierSequence == ["crisis_self"], "backend crisis verdict recorded; local rule adds nothing")
    let d2 = ConversationDriver()
    await d2.send("I want to kill myself", outcome: .body(body("...", tier: "normal"))).value
    check(d2.session.status == .clear, "a real 'normal' verdict is the semantic assessment; the local rule only applies when there is no verdict")
}

await scenario("Onboarding closer, explicit statement, backend gives no verdict") { d in
    await d.send("first", outcome: .body(body("...", tier: "normal"))).value
    await d.send("second", outcome: .body(body("...", tier: "normal"))).value
    await d.send("I feel like hurting myself", outcome: .body(liveV13Body)).value
    check(CaptureSafetySession.onboardingClosingText(recordedTier: d.lastRecordedTier!, fixedCopy: fixedCloser) == nil, "fixed closing copy is NOT shown")
    check(d.session.status == .latched, "latched")
}

// MARK: - Closed after Finish (Kell, Nov 19 2026: supersedes keep-composer-after-Finish)

await scenario("Support conversation is open before Finish and closed after it") { d in
    await d.send("I want to kill myself", outcome: .body(liveV13Body)).value
    check(!d.session.isClosed, "before Finish: the support conversation is still open")
    check(d.session.noteRequestScheduled(userText: "still here") == true, "before Finish: a new turn can still be scheduled")
    d.session.recordResponse(safetyTier: nil) // resolve that extra turn
    let decision = await d.tapFinish()
    check(decision == .blockWithoutSaving && d.saveCalls == 0, "Finish blocks: no journal/moment/Formation writes")
    check(d.session.isClosed, "after Finish: closed")
    let pendingBefore = d.session.pendingClassifications
    check(d.session.noteRequestScheduled(userText: "one more thing") == false, "after Finish: a new turn is refused")
    check(d.session.pendingClassifications == pendingBefore && !d.session.isAwaitingClassification, "after Finish: nothing is marked in flight")
    _ = await d.tapFinish()
    check(d.saveCalls == 0 && d.blockCalls == 1, "a second Finish runs nothing again")
}

await scenario("Stale reply landing after Finish changes nothing") { d in
    let late = d.send("I feel like hurting myself", outcome: .body(body("...", tier: "normal")), delayMs: 400)
    let decision = await d.tapFinish(timeoutMs: 100) // closes before the reply lands
    await late.value
    check(decision == .blockWithoutSaving, "unresolved at Finish -> blocked")
    check(d.session.isClosed && d.saveCalls == 0 && d.blockCalls == 1, "the late reply neither reopens the conversation nor triggers a save")
}

await scenario("Ordinary conversation is also closed after Finish") { d in
    await d.send("Grateful today.", outcome: .body(body("...", tier: "normal"))).value
    _ = await d.tapFinish()
    check(d.saveCalls == 1 && d.session.isClosed, "saved once, then closed")
    check(d.session.noteRequestScheduled(userText: "again") == false, "no new turn after Finish")
}

// MARK: - A closed support conversation never ends on a question

let q = CaptureSafetySession.closingDisplayText
check(q("I'm glad to hear you're okay. What's been a bright spot in your day so far that you can hold onto?") == "I'm glad to hear you're okay.", "trailing question removed, the rest kept")
check(q("That sounds heavy. I'm here. Does that make sense? Want to say more?") == "That sounds heavy. I'm here.", "several trailing questions all removed")
check(q("Thank you for trusting me.\n\nYou don't have to carry this alone.") == "Thank you for trusting me.\n\nYou don't have to carry this alone.", "a reply with no question comes back unchanged, paragraph break intact")
check(q("What's on your heart?") == "Thank you for sharing that with me.", "a reply that is only a question falls back to a short fixed line")
check(q("Is that right? I hear you. Thank you.") == "Is that right? I hear you. Thank you.", "a question in the middle (not trailing) is left alone")
check(q("I'm glad you told me. Can you say more?\n\n\u{2022} findahelpline.com lists a crisis line\n\u{2022} Call your local emergency number") == "I'm glad you told me.\n\n\u{2022} findahelpline.com lists a crisis line\n\u{2022} Call your local emergency number", "the question is dropped but an appended resource block is kept exactly")
check(q("") == "", "empty text is unchanged")

print(failures == 0 ? "ALL CHECKS PASSED" : "\(failures) CHECK(S) FAILED")
exit(failures == 0 ? 0 : 1)

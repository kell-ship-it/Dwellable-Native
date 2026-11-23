import Foundation
import Combine

/// Crisis Support -- the runtime state machine for ONE capture conversation's safety
/// decisions, pulled out of CaptureConversationView (Nov 19 2026) so it can be driven
/// and asserted at runtime by Scripts/crisis_support_runtime_harness, not just read as
/// source text. The view owns one of these per conversation and routes every safety-
/// relevant event through it: a reply being scheduled, the proxy's verdict landing,
/// a request failing, and the single Finish decision.
///
/// Why this exists (real runtime failure Kell reproduced, Nov 19 2026): the deployed
/// llm-proxy was still the pre-safety version and never returned `safetyTier`. The
/// client read the missing field as "nothing to record", so a first-person self-harm
/// conversation looked clear and was journaled. Missing or unrecognized metadata is
/// now recorded as "unverified" -- a pending hold that blocks saving -- never as
/// normal. Support mode itself is still only ever entered from an explicit tier; the
/// client never infers it from reply prose or a phone number in the text.
@MainActor
final class CaptureSafetySession: ObservableObject {

    /// The full set of tier values the current safety contract can return for
    /// `capture_conversation`. Anything else -- nil from a pre-safety proxy, or an
    /// unknown string from a future/mismatched one -- is treated as "unverified".
    static let contractTiers: Set<String> = ["normal", "crisis_self", "crisis_other", "ongoing_danger", "refusal", "fallback"]

    enum FinishDecision: Equatable {
        case save
        case blockWithoutSaving
    }

    @Published private(set) var tierSequence: [String] = []
    /// Replies scheduled but not yet resolved. Incremented SYNCHRONOUSLY at the moment
    /// a request is scheduled (before the async Task starts), so there is no window in
    /// which a Finish tap can see "nothing in flight" for a message that was just sent.
    @Published private(set) var pendingClassifications = 0
    @Published private(set) var finishDecision: FinishDecision?

    var tiersSeen: Set<String> { Set(tierSequence) }

    /// Restores the verified tier record of a resumed conversation (see OnboardingCaptureStore). Only
    /// into a fresh session; never overwrites a record this session already built.
    func restoreTiers(_ tiers: [String]) {
        guard tierSequence.isEmpty else { return }
        tierSequence = tiers
    }
    /// True once the single Finish decision has been made. A closed conversation
    /// accepts no new requests (see `noteRequestScheduled(userText:)`).
    var isClosed: Bool { finishDecision != nil }
    var status: CrisisSupportPolicy.Status { CrisisSupportPolicy.status(forTierSequence: tierSequence) }
    var isAwaitingClassification: Bool { pendingClassifications > 0 }

    /// A closed support conversation must not end on a question nobody can answer. The
    /// last reply was written before Finish was tapped, so it may still end by asking
    /// one. This returns the reply's prose with any trailing question sentences removed,
    /// leaving everything else (including paragraph breaks and an appended resource
    /// block, which starts at the first "\n\n\u{2022} ") exactly as it was. If nothing but
    /// questions remain, it falls back to a short fixed line. Display-only: the stored
    /// turn is never changed, and a reply with no trailing question comes back as-is.
    static func closingDisplayText(_ text: String) -> String {
        let marker = "\n\n\u{2022} "
        var prose = text
        var suffix = ""
        if let r = text.range(of: marker) {
            prose = String(text[..<r.lowerBound])
            suffix = String(text[r.lowerBound...])
        }
        var cutAt: String.Index?
        prose.enumerateSubstrings(in: prose.startIndex..<prose.endIndex, options: [.bySentences, .reverse]) { sentence, range, _, stop in
            guard let sentence else { return }
            let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { return }
            if trimmed.hasSuffix("?") {
                cutAt = range.lowerBound
            } else {
                stop = true
            }
        }
        guard let cutAt else { return text }
        let kept = prose[..<cutAt].trimmingCharacters(in: .whitespacesAndNewlines)
        let lead = kept.isEmpty ? "Thank you for sharing that with me." : kept
        return suffix.isEmpty ? lead : lead + suffix
    }

    static func normalize(_ raw: String?) -> String {
        guard let raw, contractTiers.contains(raw) else { return "unverified" }
        return raw
    }

    /// The local explicit-harm signal for each scheduled request, oldest first (FIFO,
    /// matching how replies resolve -- the composer only allows one at a time).
    private var pendingLocalSignals: [LocalExplicitHarmSignal.Kind?] = []

    /// Call synchronously at send time, with the user's own message text. Returns
    /// false, and records nothing, once the conversation is closed.
    @discardableResult
    func noteRequestScheduled(userText: String) -> Bool {
        guard !isClosed else { return false }
        pendingClassifications += 1
        pendingLocalSignals.append(LocalExplicitHarmSignal.explicitCurrentHarm(in: userText))
        return true
    }

    /// Records the proxy's verdict for the oldest outstanding request and returns the
    /// tier that decides this turn: the local explicit tier when one was applied
    /// (see `applyLocalSignalIfNoVerdict`), otherwise the normalized verdict.
    @discardableResult
    func recordResponse(safetyTier raw: String?) -> String {
        let tier = Self.normalize(raw)
        let local = popLocalSignal()
        record(tier)
        return applyLocalSignalIfNoVerdict(local, verdict: tier) ?? tier
    }

    /// The request itself failed (network, both providers down) -- the turn was never
    /// checked, which is the pending "fallback" case, not by itself a genuine concern.
    func recordFailure() {
        let local = popLocalSignal()
        record("fallback")
        _ = applyLocalSignalIfNoVerdict(local, verdict: "fallback")
    }

    /// The narrow local safeguard only speaks when the contextual classifier could not:
    /// a missing/out-of-contract verdict or a failed check. A real verdict -- including
    /// "normal" -- stands as the semantic assessment. Once applied it is a genuine-
    /// concern tier, so the latch is permanent; nothing later can release it.
    private func applyLocalSignalIfNoVerdict(_ local: LocalExplicitHarmSignal.Kind?, verdict: String) -> String? {
        guard let local, verdict == "unverified" || verdict == "fallback" else { return nil }
        tierSequence.append(local.tier)
        return local.tier
    }

    private func popLocalSignal() -> LocalExplicitHarmSignal.Kind? {
        pendingLocalSignals.isEmpty ? nil : pendingLocalSignals.removeFirst()
    }

    /// Onboarding's fixed closing copy is allowed ONLY when that turn's own safety
    /// check came back verified "normal". Every other recorded tier -- a concern, a
    /// refusal, a failed check, or an unverified/old-backend reply -- returns nil, and
    /// the caller shows the proxy's own reply instead. The closing turn is never
    /// exempted from the check and never treated as verified on its own.
    static func onboardingClosingText(recordedTier: String, fixedCopy: String) -> String? {
        recordedTier == "normal" ? fixedCopy : nil
    }

    /// Optimized final-turn variant. The fixed hand-off is shown ONLY when the verdict is normal
    /// AND the server's trusted `closer` marker is present. A normal-tier reply without the marker
    /// (a classifier clarifying question, an old backend that generated a reply) is not the
    /// hand-off and is never replaced by it. Non-normal tiers never get it either.
    /// True when a final-onboarding-turn reply is a safety clarifying question: verified normal tier but
    /// WITHOUT the server's closer marker. The person then gets one extra turn outside the reply cap so a
    /// safety question is never left unanswered by the wrap-up. At most once per conversation.
    static func grantsClarifyExtraTurn(isFinalOnboardingTurn: Bool, recordedTier: String, closer: String?, alreadyGranted: Bool) -> Bool {
        isFinalOnboardingTurn && recordedTier == "normal" && closer != "onboarding_final" && !alreadyGranted
    }

    static func onboardingClosingText(recordedTier: String, closer: String?, fixedCopy: String) -> String? {
        (recordedTier == "normal" && closer == "onboarding_final") ? fixedCopy : nil
    }

    /// A scheduled request that returned before sending anything (the view's own
    /// already-finished guard). Clears the in-flight count without recording a tier.
    func cancelScheduled() {
        _ = popLocalSignal()
        pendingClassifications = max(0, pendingClassifications - 1)
    }

    private func record(_ tier: String) {
        tierSequence.append(tier)
        pendingClassifications = max(0, pendingClassifications - 1)
    }

    /// Waits (bounded) for every scheduled reply to resolve, then decides. Fails safe:
    /// if anything is STILL in flight when the wait runs out, the decision is
    /// `.blockWithoutSaving` -- an unresolved turn is never assumed to be clean.
    func decideFinish(timeoutNanoseconds: UInt64 = 30_000_000_000, pollNanoseconds: UInt64 = 100_000_000) async -> FinishDecision {
        var waited: UInt64 = 0
        while isAwaitingClassification && waited < timeoutNanoseconds {
            try? await Task.sleep(nanoseconds: pollNanoseconds)
            waited += pollNanoseconds
        }
        if isAwaitingClassification { return .blockWithoutSaving }
        return CrisisSupportPolicy.blocksSaving(forTierSequence: tierSequence) ? .blockWithoutSaving : .save
    }

    /// The single Finish entry point: decides once, runs exactly one of the two paths,
    /// and never runs either again for this conversation (a second call returns the
    /// first decision without re-running anything).
    @discardableResult
    func finish(
        timeoutNanoseconds: UInt64 = 30_000_000_000,
        pollNanoseconds: UInt64 = 100_000_000,
        save: () async -> Void,
        block: () async -> Void
    ) async -> FinishDecision {
        if let finishDecision { return finishDecision }
        let decision = await decideFinish(timeoutNanoseconds: timeoutNanoseconds, pollNanoseconds: pollNanoseconds)
        guard finishDecision == nil else { return finishDecision! }
        finishDecision = decision
        switch decision {
        case .save: await save()
        case .blockWithoutSaving: await block()
        }
        return decision
    }
}

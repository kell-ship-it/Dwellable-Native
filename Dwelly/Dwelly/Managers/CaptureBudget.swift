import Foundation

/// Pure token-budget policy for one capture (MVP, approved Nov 23 2026): 30,000 total
/// tokens for an onboarding capture, 100,000 for a regular one, across ALL AI work
/// (safety, reply, output check, journal synthesis, capture-associated profile update).
///
/// IMPORTANT -- this is the decision logic only. It is NOT enforcement: a client counter
/// can be bypassed, lost on restart, or raced by concurrent sends. Hard enforcement needs
/// a durable authenticated capture ID plus atomic server-side reserve/reconcile with
/// stable logical request IDs (see MVP doc blockers). Until then this only decides when
/// the app should stop ordinary turns and finish.
///
/// Token counts here are ESTIMATES unless they come from `pipelineTokens` with
/// `pipelineTokensComplete == true`. `estimateTokens` is an unvalidated heuristic, not a
/// tokenizer.
struct CaptureBudget {
    static let onboardingLimit = 30_000
    static let regularLimit = 100_000

    // Output ceilings that the code actually sends (llm-proxy DEFAULT_MAX_TOKENS,
    // JournalSynthesisManager maxTokens). Profile update sends no max_tokens, so the
    // proxy default applies.
    static let mainReplyOutputCeiling = 1_000
    static let synthesisOutputCeiling = 1_500
    static let profileOutputCeiling = 1_000

    let limit: Int
    private(set) var spent = 0
    private(set) var observedCalls = 0
    /// Cost of the most recently recorded request (the measured whole-turn figure the
    /// next turn's safety overhead is taken from -- conservative, it includes that turn's own transcript).
    private(set) var lastRecordedCost = 0

    init(isOnboarding: Bool) { limit = isOnboarding ? Self.onboardingLimit : Self.regularLimit }

    /// Heuristic, unvalidated, deliberately conservative but not absurd: ASCII at 1 token per
    /// 3 chars (~33% over English's ~4), every non-ASCII character at 2 tokens (CJK ~1-1.5,
    /// emoji up to ~3). Must stay in step with the proxy's `estimateTokens` (budget.ts). The
    /// earlier max(bytes/3, chars) form over-counted English ~4x (found live: 34k reserved for
    /// a 4.3k turn).
    static func estimateTokens(_ text: String) -> Int {
        var ascii = 0, other = 0
        for scalar in text.unicodeScalars { if scalar.value < 128 { ascii += 1 } else { other += 1 } }
        return (ascii + 2) / 3 + 2 * other
    }

    /// Record one request's cost. Exact provider total when complete; otherwise the
    /// provider-reported part PLUS the caller-supplied ceiling for the unknown part --
    /// unknown spend is never counted as zero.
    mutating func record(pipelineTokens: Int?, complete: Bool?, ceilingIfUnknown: Int) {
        observedCalls += 1
        let cost = (complete == true && pipelineTokens != nil) ? pipelineTokens! : (pipelineTokens ?? 0) + ceilingIfUnknown
        spent += cost
        lastRecordedCost = cost
    }

    /// Record a request that failed with no response at all (network/timeout): unknown.
    mutating func recordUnknown(ceiling: Int) { observedCalls += 1; spent += ceiling; lastRecordedCost = ceiling }

    /// Reserve for the finish: journal synthesis (actual prompt incl. full transcript +
    /// its output ceiling, which also holds the closing sentence) plus the eligible
    /// profile update (existing summary + facts up to the synthesis output + its ceiling).
    static func finishReserve(synthesisPrompt: String, existingProfileSummary: String?, profileInstructionTokens: Int) -> Int {
        let synthesis = estimateTokens(synthesisPrompt) + synthesisOutputCeiling
        let existing = existingProfileSummary.map(estimateTokens) ?? profileOutputCeiling
        let profile = profileInstructionTokens + existing + synthesisOutputCeiling + profileOutputCeiling
        return synthesis + profile
    }

    /// Cost of one more ordinary turn: both the classifier and the main reply read the
    /// transcript (x2 of its tokens), plus the main output ceiling and the output
    /// check. `safetyOverhead` is the measured per-turn safety cost (classifier prompt +
    /// output check) from the last complete observation, or the caller's conservative
    /// figure when none exists yet.
    static func nextTurnCost(transcriptTokens: Int, newUserTokens: Int, safetyOverhead: Int) -> Int {
        2 * (transcriptTokens + newUserTokens) + mainReplyOutputCeiling + safetyOverhead
    }

    enum Decision: Equatable { case continueOrdinary, finishNow }

    /// `finishNow` when another ordinary turn would leave less than the finish reserve.
    /// Exactly equal to the limit still continues (boundary is inclusive).
    func decision(nextTurnCost: Int, finishReserve: Int) -> Decision {
        spent + nextTurnCost + finishReserve <= limit ? .continueOrdinary : .finishNow
    }
}

/// Deterministic, no-AI guard for the budget-boundary transition sentence the synthesis
/// call may return. It can only DROP a sentence that breaks the approved rules; it never
/// rewrites one. A dropped closing leaves just the fixed follow-up line, never a
/// fabricated substitute.
enum BudgetClosing {
    static let fixedFollowUp = "Here’s your journal for this moment. You can start another capture to keep exploring."

    private static let bannedPhrases = [
        "thanks for sharing", "thank you for sharing", "thank you for", "thanks for",
        "here's what i learned", "here’s what i learned", "what i learned", "great job", "well done",
    ]

    static func sanitize(_ raw: String?) -> String? {
        guard let text = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return nil }
        if text.contains("?") || text.contains("？") { return nil }          // no new question
        let lower = text.lowercased()
        if bannedPhrases.contains(where: { lower.contains($0) }) { return nil }
        // One concise sentence: reject multi-sentence output rather than truncating it.
        let terminators = text.filter { ".!。！".contains($0) }.count
        if terminators > 1 || text.contains("\n") { return nil }
        // No new Bible reference (e.g. "John 3:16", "Psalm 46").
        if text.range(of: #"\b\d?\s?[A-Z][a-z]+\s+\d+:\d+"#, options: .regularExpression) != nil { return nil }
        if lower.contains("psalm ") || lower.contains("scripture") || lower.contains("verse") { return nil }
        return text
    }
}

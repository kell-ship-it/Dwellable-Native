import Foundation

struct LLMResponse: Codable {
    let content: String
    let model: String
    let provider: String
    // T-302/T-303: present only for the "capture_conversation" feature's safety layer.
    // nil for every other feature (prayer generation, journal synthesis) that doesn't
    // run through the crisis/misuse check. One of: "normal", "crisis_self",
    // "crisis_other", "refusal", "fallback" -- see SafetyResourceCenter.swift for what
    // the client does with each. Optional so Codable's synthesized decoder tolerates
    // its absence from every other feature's response without a custom init(from:).
    let safetyTier: String?
    // llm-proxy (local, not yet deployed): provider-reported tokens for every billable call
    // this request made, and whether that sum is exact. Calls that failed or returned no
    // usage make `pipelineTokensComplete` false -- budget the call's ceiling, never zero.
    let pipelineTokens: Int?
    let pipelineTokensComplete: Bool?
    // Trusted marker: present ONLY when the server returned its own fixed onboarding hand-off
    // (the request asked for `closer` and the classifier verdict was normal). A normal-tier reply
    // WITHOUT it (e.g. a clarifying question) is NOT the hand-off and must not be replaced by it.
    let closer: String?
}

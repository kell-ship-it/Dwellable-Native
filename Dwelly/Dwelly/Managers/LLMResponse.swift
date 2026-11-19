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
}

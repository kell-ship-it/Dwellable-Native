import Foundation

/// T-161/T-164 (Nov 16 2026): free-text feedback from "Not quite" on Your Narrative.
/// Kell's direct call -- this carries the SAME weight as a captured moment, both
/// toward the 3+ qualifying-reflection threshold (`YourNarrativeCard`) and as real
/// content fed into the next narrative regeneration (`DwellerProfileManager`), not
/// just stored and ignored.
struct NarrativeFeedback: Codable, Identifiable {
    let id: String
    let userId: String
    let feedbackText: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case feedbackText = "feedback_text"
        case createdAt = "created_at"
    }
}

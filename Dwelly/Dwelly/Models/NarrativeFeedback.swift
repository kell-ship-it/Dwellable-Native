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
    // T-164 (Nov 16 2026, Kell's direct call): the narrative the person was actually
    // looking at when they gave this feedback -- without it, regeneration has no way
    // to know what a piece of feedback is correcting, only the bare complaint text.
    // Nil for feedback given before any narrative existed yet.
    let narrativeAtTime: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case feedbackText = "feedback_text"
        case createdAt = "created_at"
        case narrativeAtTime = "narrative_at_time"
    }
}

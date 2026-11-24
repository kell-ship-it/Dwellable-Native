import Foundation

/// The persistence half of `SyncManager.retryPendingJournalEntries`, split out so its
/// ordering rules are testable without a network or the full app (see
/// Scripts/journal_retry_test). Rules: a retried entry carries the model's refreshed
/// eligibility + facts (nil facts CLEAR any stale value); the running profile is fed
/// only AFTER the entry was saved, so a failed save leaves the entry `pending` for the
/// next sweep and never double-feeds the profile.
enum JournalRetryApplier {
    /// Plain-value mirror of `JournalSynthesisManager.Result` (kept separate so this file
    /// and its test have no dependency on the LLM layer).
    struct Decision {
        var title: String
        var body: String
        var moods: [String]
        var scriptureQuote: String?
        var scriptureReference: String?
        var formationEligible: Bool
        var extractedFacts: String?
    }

    static func applying(_ result: Decision, to entry: JournalEntry) -> JournalEntry {
        var updated = entry
        updated.status = "approved"
        updated.title = result.title
        updated.body = result.body
        updated.moods = result.moods
        updated.scriptureQuote = result.scriptureQuote
        updated.scriptureReference = result.scriptureReference
        updated.formationEligible = result.formationEligible
        updated.extractedFacts = result.extractedFacts
        return updated
    }

    /// Returns true if the entry was saved. `feedProfile` is called only on a
    /// successful save of a formation-eligible entry that has facts.
    static func persist(
        _ updated: JournalEntry,
        save: (JournalEntry) async throws -> JournalEntry,
        feedProfile: (String) async -> Void
    ) async -> Bool {
        guard (try? await save(updated)) != nil else { return false }
        if updated.formationEligible, let facts = updated.extractedFacts {
            await feedProfile(facts)
        }
        return true
    }
}

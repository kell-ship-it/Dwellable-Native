import Foundation

/// T-159: the one real synthesis call, shared by both the initial capture flow
/// (`CaptureConversationView.finishAndSave`) and the background retry sweep
/// (`SyncManager.retryPendingJournalEntries`, plus the BGTaskScheduler job in
/// `DwellyApp`) -- so a pending entry retried later gets synthesized exactly the
/// same way the original attempt would have. Throws on any real failure (network,
/// LLM error, or unparseable response) rather than ever silently returning a
/// generic fallback -- per the Aug 27, 2026 locked decision, synthesis failure
/// means the entry goes to `status: "pending"` and gets retried, not a permanent
/// fake title.
enum JournalSynthesisManager {
    struct Result {
        let title: String
        /// 1-2 sentence first-person excerpt -- display-only (the inline post-capture
        /// card), never persisted to `journal_entries` (no column for it; the spec's
        /// artifact structure doesn't have one either, just title/body/moods).
        let excerpt: String
        let scriptureQuote: String
        let scriptureReference: String
    }

    private struct LLMJSON: Decodable {
        let title: String
        let excerpt: String
        let scriptureQuote: String
        let scriptureReference: String

        enum CodingKeys: String, CodingKey {
            case title, excerpt
            case scriptureQuote = "scripture_quote"
            case scriptureReference = "scripture_reference"
        }
    }

    static func synthesize(transcript: String, apiClient: APIClient) async throws -> Result {
        let prompt = """
        Based on this reflection, return ONLY a single JSON object (no markdown, no \
        commentary) with these exact keys: "title" (a short, warm, 2-5 word title for this \
        journal entry), "excerpt" (a 1-2 sentence FIRST-PERSON summary of what I shared, as \
        if I wrote it myself in my own journal — "I contemplated...", "I felt...", never \
        "they"/"he"/"she", under 160 characters), "scripture_quote" (a short, real Bible verse quote — always \
        include one, even for a brief or minimal reflection; pick whatever verse about God's \
        presence, patience, or care genuinely fits best, never null), "scripture_reference" \
        (e.g. "Psalm 46:10" — the real reference for scripture_quote, never null).

        Reflection:
        \(transcript)
        """
        let messages = [
            LLMMessage(role: .system, content: "You return only valid JSON, nothing else."),
            LLMMessage(role: .user, content: prompt),
        ]

        let response = try await apiClient.callLLM(messages: messages, feature: "journal_synthesis")
        guard let start = response.content.firstIndex(of: "{"), let end = response.content.lastIndex(of: "}") else {
            throw NSError(domain: "JournalSynthesisManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No JSON object in LLM response"])
        }
        let jsonSubstring = response.content[start...end]
        let parsed = try JSONDecoder().decode(LLMJSON.self, from: Data(jsonSubstring.utf8))
        return Result(title: parsed.title, excerpt: parsed.excerpt, scriptureQuote: parsed.scriptureQuote, scriptureReference: parsed.scriptureReference)
    }
}

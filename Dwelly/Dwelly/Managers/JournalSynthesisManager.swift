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
        /// card), never persisted to `journal_entries`.
        let excerpt: String
        /// The actual journal entry (Nov 11 2026, real body-synthesis build): a 2-3
        /// paragraph first-person narrative, reframing the conversation as spiritual
        /// reflection -- NOT the raw transcript, and NOT the one-line `excerpt`. This
        /// is what was missing entirely before this build: synthesis only ever
        /// produced title/excerpt/verse, while the displayed "body" was silently just
        /// `moment.body` (the user's raw words). Kell caught this directly (Nov 11
        /// 2026) comparing a real entry's displayed body against what synthesis
        /// actually generates.
        let body: String
        let scriptureQuote: String
        let scriptureReference: String
        /// T-151's original scope ("title + body + suggested moods") never actually
        /// built this part -- moods were only ever user-added via the Edit Moods sheet,
        /// never suggested. Kell caught the gap live (Nov 11 2026): a real entry had no
        /// tags at all. 2-3 suggestions, drawn from the same `presetMoods` vocabulary
        /// `JournalDetailView`'s own picker uses, so these aren't just editable but
        /// actually match what a user would have picked themselves.
        let moods: [String]
    }

    private struct LLMJSON: Decodable {
        let title: String
        let excerpt: String
        let body: String
        let scriptureQuote: String
        let scriptureReference: String
        let moods: [String]

        enum CodingKeys: String, CodingKey {
            case title, excerpt, body, moods
            case scriptureQuote = "scripture_quote"
            case scriptureReference = "scripture_reference"
        }
    }

    /// `transcript` should be the FULL conversation (both sides, role-labeled) -- the
    /// model needs Dwelly's own questions to understand the arc well enough to write a
    /// real narrative, not just a concatenation of the user's answers. See
    /// `CaptureConversationView.fullTranscript` vs. `combinedBody` (user-only, what
    /// actually gets saved as `moment.body`).
    static func synthesize(transcript: String, apiClient: APIClient) async throws -> Result {
        let prompt = """
        Based on this conversation between me and Dwelly, return ONLY a single JSON \
        object (no markdown, no commentary) with these exact keys:

        "title" (a short, warm, 2-5 word title for this journal entry)

        "excerpt" (a 1-2 sentence FIRST-PERSON summary of what I shared, as if I wrote \
        it myself in my own journal — "I contemplated...", "I felt...", never \
        "they"/"he"/"she", under 160 characters)

        "body" (the actual journal entry: 2-3 paragraphs of FIRST-PERSON reflective \
        narrative prose, not structured sections, not a Q&A transcript, not bullet \
        points. Written entirely in my own voice as if I sat down and wrote this in my \
        journal myself -- mirror my own words, phrasing, and specific details from what \
        I actually said, but reframe it into reflective prose rather than copying my \
        answers verbatim or including any of Dwelly's own questions. This should read \
        like a real, personal journal entry someone would actually want to keep and \
        reread, not a summary of a conversation.)

        "scripture_quote" (a short, real Bible verse quote — always include one, even \
        for a brief or minimal reflection; pick whatever verse about God's presence, \
        patience, or care genuinely fits best, never null)

        "scripture_reference" (e.g. "Psalm 46:10" — the real reference for \
        scripture_quote, never null)

        "moods" (an array of 2-3 strings, chosen ONLY from this exact list, that best \
        describe how I felt in this conversation: \(presetMoods.joined(separator: ", ")). \
        Pick whichever genuinely fit best, even if the fit is imperfect -- never invent \
        a word outside this list, never return an empty array.)

        Conversation:
        \(transcript)
        """
        let messages = [
            LLMMessage(role: .system, content: "You return only valid JSON, nothing else."),
            LLMMessage(role: .user, content: prompt),
        ]

        // 1500, not the proxy's own 1000 default -- a real 2-3 paragraph body plus
        // title/excerpt/verse plus JSON structure needs more room than metadata alone did.
        let response = try await apiClient.callLLM(messages: messages, feature: "journal_synthesis", maxTokens: 1500)
        guard let start = response.content.firstIndex(of: "{"), let end = response.content.lastIndex(of: "}") else {
            throw NSError(domain: "JournalSynthesisManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No JSON object in LLM response"])
        }
        let jsonSubstring = response.content[start...end]
        let parsed = try JSONDecoder().decode(LLMJSON.self, from: Data(jsonSubstring.utf8))
        return Result(title: parsed.title, excerpt: parsed.excerpt, body: parsed.body, scriptureQuote: parsed.scriptureQuote, scriptureReference: parsed.scriptureReference, moods: parsed.moods)
    }
}

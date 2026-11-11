import Foundation

/// T-274: the one real call that keeps `DwellerProfile.runningSummary` up to date --
/// fired fire-and-forget after every *successfully synthesized* journal entry
/// (`CaptureConversationView.finishAndSave`), same non-blocking pattern as
/// `SyncManager.retryPendingJournalEntries`. Store-and-show only: nothing calls
/// `fetchDwellerProfile` from inside a capture conversation -- this never changes what
/// Dwelly says, only what a user can see about themselves in `DwellerProfileView`.
///
/// Deliberately fire-and-forget and best-effort throughout: a failed or skipped update
/// here must never block or surface an error on the capture that already succeeded.
enum DwellerProfileManager {
    static func updateRunningSummary(newEntryBody: String, userId: String, apiClient: APIClient) async {
        guard !newEntryBody.isEmpty else { return }
        let existing = try? await apiClient.fetchDwellerProfile(userId: userId)

        // Kell caught this live (Nov 11 2026): the old prompt said "third person" with no
        // name, so the model defaulted to the generic, impersonal "The writer is...". A
        // real first name (set during onboarding's Name Entry screen) reads far more like
        // something personal, not a stranger's case notes. Falls back to the Figma
        // reference copy's own voice ("you") when no name is on file, rather than ever
        // inventing one.
        let name = ProfileManager.shared.localProfile(userId: userId).name
        let subject = name.map { "the person's first name, \($0)," } ?? "\"you\" (second person)"

        let prompt: String
        if let priorSummary = existing?.runningSummary, !priorSummary.isEmpty {
            prompt = """
            Here is a short running summary of someone's recent spiritual journal entries:

            \(priorSummary)

            Here is a new journal entry they just wrote:

            \(newEntryBody)

            Write an updated running summary -- 2 to 4 sentences, warm and plain (not \
            clinical), referring to them by \(subject), never "the writer" or "they/them". \
            Capture who this person is and what they're navigating lately. Fold in anything \
            from the new entry that's genuinely new or shifts the picture; let anything no \
            longer relevant quietly drop off. Return ONLY the updated summary text, no \
            preamble, no quotes, no markdown.
            """
        } else {
            prompt = """
            Here is someone's first spiritual journal entry:

            \(newEntryBody)

            Write a short running summary -- 2 to 4 sentences, warm and plain (not \
            clinical), referring to them by \(subject), never "the writer" or "they/them". \
            Capture who this person is and what they're navigating lately, based only on \
            this entry. Return ONLY the summary text, no preamble, no quotes, no markdown.
            """
        }

        let messages = [
            LLMMessage(role: .system, content: "You write short, warm, plain summaries. No markdown, no preamble, never \"the writer\"."),
            LLMMessage(role: .user, content: prompt),
        ]

        guard let response = try? await apiClient.callLLM(messages: messages, feature: "dweller_profile_summary") else { return }
        let summary = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !summary.isEmpty else { return }

        let profile = DwellerProfile(userId: userId, runningSummary: summary, updatedAt: Date())
        _ = try? await apiClient.saveDwellerProfile(profile)
    }
}

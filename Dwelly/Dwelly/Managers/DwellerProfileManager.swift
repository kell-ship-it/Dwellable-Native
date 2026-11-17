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
///
/// T-161/T-162/T-164 (Nov 16 2026) added `regenerateIfNeeded` alongside the above --
/// none of those three tickets existed in code before (all still 🔲 Not Started).
/// Kell's direct call, scoping this: "Not quite" feedback carries the SAME weight as a
/// captured moment, both toward the 3+ qualifying-reflection threshold
/// (`YourNarrativeCard.qualifyingReflectionCount`) and as real content the model reads
/// when writing the next narrative -- not stored and ignored, not metadata, the actual
/// feedback text goes into the prompt alongside approved journal entry bodies.
/// Confirming ("Yes, that's me") is logged only for now (Kell's call, same session) --
/// it does not feed back into generation. Deliberately no "Narrative
/// Regenerating"/"Regenerated" UI states; this just updates `DwellerProfile` in place
/// the same way `updateRunningSummary` already did, and `YourNarrativeCard` re-renders
/// off that either way.
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
        //
        // Kell caught this live again the same day: the prompt banned "they/them"
        // outright, which forced the model to guess a gendered pronoun (he/she) with
        // nothing in a journal entry to base that guess on -- it got Kell's own entry
        // wrong. The DwellerProfile doesn't track gender at all right now, so a
        // gendered pronoun is never safe to use here; "they/them" is explicitly
        // welcome now, repeating the name is fine too, "he"/"she"/"him"/"her" are not.
        let name = ProfileManager.shared.localProfile(userId: userId).name
        let subject = name.map { "the person's first name, \($0),(or \"they\"/\"them\")" } ?? "\"you\" (second person)"

        let prompt: String
        if let priorSummary = existing?.runningSummary, !priorSummary.isEmpty {
            prompt = """
            Here is a short running summary of someone's recent spiritual journal entries:

            \(priorSummary)

            Here is a new journal entry they just wrote:

            \(newEntryBody)

            Write an updated running summary -- 2 to 4 sentences, warm and plain (not \
            clinical), referring to them by \(subject), never "the writer". Nothing here \
            tracks this person's gender, so never guess a gendered pronoun ("he", "she", \
            "him", "her") -- use their name or "they"/"them" instead. Capture who this \
            person is and what they're navigating lately. Fold in anything from the new \
            entry that's genuinely new or shifts the picture; let anything no longer \
            relevant quietly drop off. Return ONLY the updated summary text, no preamble, \
            no quotes, no markdown.
            """
        } else {
            prompt = """
            Here is someone's first spiritual journal entry:

            \(newEntryBody)

            Write a short running summary -- 2 to 4 sentences, warm and plain (not \
            clinical), referring to them by \(subject), never "the writer". Nothing here \
            tracks this person's gender, so never guess a gendered pronoun ("he", "she", \
            "him", "her") -- use their name or "they"/"them" instead. Capture who this \
            person is and what they're navigating lately, based only on this entry. \
            Return ONLY the summary text, no preamble, no quotes, no markdown.
            """
        }

        let messages = [
            LLMMessage(role: .system, content: "You write short, warm, plain summaries. No markdown, no preamble, never \"the writer\", never a gendered pronoun (\"he\"/\"she\"/\"him\"/\"her\") -- use the person's name or \"they\"/\"them\" instead."),
            LLMMessage(role: .user, content: prompt),
        ]

        guard let response = try? await apiClient.callLLM(messages: messages, feature: "dweller_profile_summary") else { return }
        let summary = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !summary.isEmpty else { return }

        let profile = DwellerProfile(userId: userId, runningSummary: summary, updatedAt: Date())
        _ = try? await apiClient.saveDwellerProfile(profile)
    }

    /// Regenerates the narrative when there's real new qualifying content (an approved
    /// journal entry or a piece of "Not quite" feedback) created after the current
    /// profile's `updatedAt` -- called from `YourNarrativeCard.load()` on every
    /// appearance, so a user doesn't have to wait for some separate background job to
    /// see feedback actually reflected. Returns the saved profile, or `nil` if nothing
    /// new justified a regeneration (callers should keep showing the existing one).
    static func regenerateIfNeeded(
        userId: String,
        currentProfile: DwellerProfile?,
        approvedEntries: [JournalEntry],
        feedback: [NarrativeFeedback],
        apiClient: APIClient
    ) async -> DwellerProfile? {
        let lastUpdate = currentProfile?.updatedAt ?? .distantPast
        let newEntries = approvedEntries.filter { $0.createdAt > lastUpdate }
        let newFeedback = feedback.filter { $0.createdAt > lastUpdate }
        let qualifyingCount = approvedEntries.count + feedback.count

        guard qualifyingCount >= 3, !(newEntries.isEmpty && newFeedback.isEmpty) else { return nil }

        // Every approved entry body counts as a reflection; every piece of feedback
        // counts exactly the same way -- literally interleaved into the same list the
        // prompt below reads from, not a separate lesser-weighted category.
        var reflections = approvedEntries.compactMap(\.body)
        reflections.append(contentsOf: feedback.map(\.feedbackText))
        guard !reflections.isEmpty else { return nil }

        // Same name/pronoun-safety rule as `updateRunningSummary` above -- nothing here
        // tracks gender, so a gendered pronoun is never safe to guess.
        let name = ProfileManager.shared.localProfile(userId: userId).name
        let subject = name.map { "the person's first name, \($0), (or \"they\"/\"them\")" } ?? "\"they\"/\"them\""

        let prompt = """
        Here are reflections from someone's spiritual journal, in their own words (some \
        are full journal entries, others are short corrections they gave about an \
        earlier summary -- treat both exactly the same way, as real material about who \
        they are):

        \(reflections.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n\n"))

        Write a short (2-4 sentence) running narrative about this person's spiritual \
        journey so far -- warm, specific, grounded only in what's actually above, never \
        inventing events or feelings not present in the material. Refer to them by \
        \(subject), never "the writer." Nothing here tracks this person's gender, so \
        never guess a gendered pronoun ("he", "she", "him", "her"). Return ONLY the \
        narrative text, no preamble, no quotation marks, no markdown.
        """
        let messages = [
            LLMMessage(role: .system, content: "You write only the requested narrative text, nothing else. Never a gendered pronoun (\"he\"/\"she\"/\"him\"/\"her\") -- use the person's name or \"they\"/\"them\" instead."),
            LLMMessage(role: .user, content: prompt),
        ]

        guard let response = try? await apiClient.callLLM(messages: messages, feature: "dweller_profile_narrative", maxTokens: 400) else {
            return nil
        }
        let summary = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !summary.isEmpty else { return nil }

        // A fresh narrative is unconfirmed again -- DwellerProfile.isConfirmed compares
        // confirmedAt against updatedAt, and saveDwellerProfile's upsert naturally
        // leaves confirmedAt at whatever it already was in the row (the payload never
        // includes it); since this write bumps updatedAt forward past any prior
        // confirmedAt, isConfirmed resolves to false on the next read without needing
        // to touch confirmedAt here at all.
        let profile = DwellerProfile(userId: userId, runningSummary: summary, updatedAt: Date())
        return try? await apiClient.saveDwellerProfile(profile)
    }
}

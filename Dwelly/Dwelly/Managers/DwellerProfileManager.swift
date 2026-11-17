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

        guard let summary = await generateNarrative(userId: userId, approvedEntries: approvedEntries, feedback: feedback, apiClient: apiClient) else {
            return nil
        }

        // A fresh narrative is unconfirmed again -- DwellerProfile.isConfirmed compares
        // confirmedAt against updatedAt, and saveDwellerProfile's upsert naturally
        // leaves confirmedAt at whatever it already was in the row (the payload never
        // includes it); since this write bumps updatedAt forward past any prior
        // confirmedAt, isConfirmed resolves to false on the next read without needing
        // to touch confirmedAt here at all.
        let profile = DwellerProfile(userId: userId, runningSummary: summary, updatedAt: Date())
        return try? await apiClient.saveDwellerProfile(profile)
    }

    /// T-294-pattern debug tool (Nov 16 2026, Kell's direct call after a live-testing
    /// mishap -- see `NarrativeExperimentView`'s own comment): the pure half of
    /// `regenerateIfNeeded`, split out so a caller can preview the model's output for
    /// an arbitrary hand-picked subset of entries/feedback WITHOUT writing anything
    /// anywhere -- no status flips, no `saveDwellerProfile`, no side effects at all.
    /// `regenerateIfNeeded` above is the only real caller that persists a result.
    static func generateNarrative(
        userId: String,
        approvedEntries: [JournalEntry],
        feedback: [NarrativeFeedback],
        apiClient: APIClient
    ) async -> String? {
        // Kell caught this live (Nov 16 2026): feeding feedback text as a bare,
        // context-free fragment gives the model a complaint with no idea what it's
        // objecting to -- three "it feels off"s with nothing else is noise, not
        // signal. Every feedback row now carries the exact narrative it was reacting
        // to (`narrativeAtTime`, captured at submission time), so this pairs each one
        // with what it's actually correcting, and the whole timeline is real
        // chronological order (journal entries and feedback interleaved by when they
        // actually happened), not two separate buckets concatenated together.
        struct TimelineItem {
            let date: Date
            let text: String
        }
        let dateFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateStyle = .medium
            return f
        }()
        var timeline: [TimelineItem] = approvedEntries.compactMap { entry in
            guard let body = entry.body, !body.isEmpty else { return nil }
            return TimelineItem(date: entry.createdAt, text: "On \(dateFormatter.string(from: entry.createdAt)), they wrote in their journal: \"\(body)\"")
        }
        timeline.append(contentsOf: feedback.map { item in
            let text: String
            if let priorNarrative = item.narrativeAtTime, !priorNarrative.isEmpty {
                text = "On \(dateFormatter.string(from: item.createdAt)), they were shown this narrative about themselves: \"\(priorNarrative)\" -- and responded: \"\(item.feedbackText)\""
            } else {
                text = "On \(dateFormatter.string(from: item.createdAt)), they said: \"\(item.feedbackText)\""
            }
            return TimelineItem(date: item.createdAt, text: text)
        })
        timeline.sort { $0.date < $1.date }
        guard !timeline.isEmpty else { return nil }

        // Same name/pronoun-safety rule as `updateRunningSummary` above -- nothing here
        // tracks gender, so a gendered pronoun is never safe to guess.
        let name = ProfileManager.shared.localProfile(userId: userId).name
        let subject = name.map { "the person's first name, \($0), (or \"they\"/\"them\")" } ?? "\"they\"/\"them\""

        let prompt = """
        Here is a real chronological timeline of someone's spiritual journal entries and \
        their own responses to earlier narratives written about them, in their own \
        words:

        \(timeline.map(\.text).joined(separator: "\n\n"))

        A "responded" line is them correcting or reacting to a narrative they were \
        shown at that point -- weigh what they said exactly as seriously as a journal \
        entry, and let a correction override whatever it contradicts from before it.

        Write a short (2-4 sentence) running narrative about this person's spiritual \
        journey so far -- warm, specific, grounded only in what's actually above, never \
        inventing events or feelings not present in the material. If a correction said \
        something was off without saying what should replace it, don't guess at \
        specifics it didn't give you -- just don't repeat the part it rejected. Refer to \
        them by \(subject), never "the writer." Nothing here tracks this person's \
        gender, so never guess a gendered pronoun ("he", "she", "him", "her"). Return \
        ONLY the narrative text, no preamble, no quotation marks, no markdown.
        """
        let messages = [
            LLMMessage(role: .system, content: "You write only the requested narrative text, nothing else. Never a gendered pronoun (\"he\"/\"she\"/\"him\"/\"her\") -- use the person's name or \"they\"/\"them\" instead."),
            LLMMessage(role: .user, content: prompt),
        ]

        guard let response = try? await apiClient.callLLM(messages: messages, feature: "dweller_profile_narrative", maxTokens: 400) else {
            return nil
        }
        let summary = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
        return summary.isEmpty ? nil : summary
    }
}

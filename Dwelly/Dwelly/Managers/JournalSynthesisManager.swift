import Foundation

/// T-159/T-127 (rebuilt Nov 17 2026): the one real synthesis call, shared by both the
/// initial capture flow (`CaptureConversationView.finishAndSave`) and the background
/// retry sweep (`SyncManager.retryPendingJournalEntries`, plus the BGTaskScheduler job
/// in `DwellyApp`) -- so a pending entry retried later is decided exactly the same way
/// the original attempt would have been. Throws on any real failure (network, LLM
/// error, or unparseable response) rather than ever silently returning a generic
/// fallback -- per the Aug 27, 2026 locked decision, synthesis failure means the entry
/// goes to `status: "pending"` and gets retried, not a permanent fake title.
///
/// REBUILT Nov 17 2026, replacing the old deterministic `isGenuineReflection()` word-
/// repetition gate entirely. That gate was reviewed live against real edge cases
/// ("help me help me", "I hurt I hurt", "Holy holy holy holy", "no no no no") and
/// confirmed to misfire on genuine, meaningful, repeated-for-emphasis content -- no
/// deterministic text heuristic can tell repetition-as-noise from repetition-as-
/// emphasis, because the difference is about intent, not shape. There is now no
/// code-side pre-check before the model at all: ONE call decides everything --
/// preserve-vs-synthesize, title, formation eligibility, extracted facts, and
/// scripture/moods -- for every single save, every time. (A cost/architecture
/// consult with Kell confirmed this against a hypothetical cheap pre-classifier: the
/// classifier can't replace this call for anything it doesn't skip, so its benefit is
/// capped at the fraction of captures that are pure noise -- small for this product --
/// while it would add a full extra network round-trip's latency to every capture,
/// genuine ones included. Not worth it unless real usage data later says otherwise.)
enum JournalSynthesisManager {
    enum Rendering: String, Decodable {
        case synthesize
        case preserve
    }

    struct Result {
        /// Always a real, usable title -- "A Moment Captured" (the literal, non-custom
        /// fallback Kell confirmed live in the simulator) when the model couldn't
        /// discern anything, never nil/empty from here on.
        let title: String
        /// The actual journal entry body. Always populated by this point -- either the
        /// model's synthesized reframing (validated against the length budget below) or
        /// the user's own original words verbatim. Callers never see the raw
        /// "preserve"/"synthesize" decision directly, just the resolved text.
        let body: String
        /// T-127 rebuild: independent of rendering. True if there's ANY discernible,
        /// genuine thing the user expressed -- a feeling, a request, an event, a
        /// person, a concern -- even a single word or an emotionally repeated phrase.
        /// False only for truly indiscernible content (gibberish, a mic test, random
        /// characters). Gates scripture/moods AND whether this entry ever reaches
        /// `DwellerProfileManager`/Growth's narrative eligibility -- never proxied by
        /// scripture presence or by whether synthesis ran.
        let formationEligible: Bool
        /// Short plain-text note of ONLY the specific things the user actually
        /// expressed or confirmed -- nil when `formationEligible` is false. This, not
        /// the full body, is what should feed `DwellerProfileManager` so a mixed
        /// entry's filler portions never leak into the running profile summary.
        let extractedFacts: String?
        let scriptureQuote: String?
        let scriptureReference: String?
        let moods: [String]
    }

    private struct LLMJSON: Decodable {
        let rendering: Rendering
        let body: String?
        let title: String?
        let formationEligible: Bool
        let extractedFacts: String?
        let scriptureQuote: String?
        let scriptureReference: String?
        let moods: [String]?

        enum CodingKeys: String, CodingKey {
            case rendering, body, title, moods
            case formationEligible = "formation_eligible"
            case extractedFacts = "extracted_facts"
            case scriptureQuote = "scripture_quote"
            case scriptureReference = "scripture_reference"
        }
    }

    /// `transcript` is the FULL conversation (both sides, role-labeled) -- the model
    /// needs Dwelly's own questions for context even when the decision is "preserve."
    /// `userOnlyText` is the user's own words alone, exactly what gets saved verbatim
    /// on a "preserve" outcome and what the synthesized length budget is measured
    /// against -- see `CaptureConversationView.fullTranscript` vs. `combinedBody`.
    static func synthesize(transcript: String, userOnlyText: String, apiClient: APIClient) async throws -> Result {
        let prompt = """
        Based on this conversation between me and Dwelly, decide how to handle my own \
        words and return ONLY a single JSON object (no markdown, no commentary) with \
        these exact keys:

        "rendering": either "synthesize" or "preserve". Choose "preserve" whenever my \
        own words, exactly as I wrote them, are already the most faithful journal \
        entry -- including when they're too short, fragmentary, repetitive, or \
        ambiguous for a shorter/clearer rendering to genuinely add anything. \
        Repetition, stuttering, brevity, profanity, or unfamiliar/foreign language are \
        NEVER by themselves a reason to treat something as meaningless -- "help me \
        help me", "no no no no", and "I hurt I hurt" are real, intentional, repeated-\
        for-emphasis expressions, not noise, and should be weighed on their actual \
        content, never their shape. Choose "synthesize" only when a clearer, shorter \
        rendering would add real value without losing any meaningful detail or \
        inventing meaning that wasn't there.

        "body": REQUIRED if rendering is "synthesize" -- a first-person reframing of \
        what I actually said, strictly SHORTER than my own words above, inventing no \
        details/events/imagery I never mentioned, reusing my own actual phrases where \
        possible. Omit this field entirely (or null) if rendering is "preserve" -- the \
        app already has my original words and will use those verbatim, so do not \
        repeat them here.

        "title": a short, warm, 2-5 word title -- OR null if you genuinely cannot \
        discern ANY legible meaning in what I wrote (pure noise: random keyboard \
        characters, a mic test, nothing a person would recognize as communication). Do \
        NOT set this null just because my words were short, repetitive, emotional, \
        profane, or in another language -- only when there is truly nothing \
        discernible at all.

        "formation_eligible": true if there is ANY discernible, genuine thing I \
        expressed -- a feeling, a request, an event, a person, a concern -- even a \
        single word or an emotionally repeated phrase; false only if there is truly \
        nothing discernible (literal gibberish, a mic test, random characters). In a \
        mixed message, a real expression elsewhere does not get discarded just because \
        part of the message was also filler, and filler elsewhere does not get \
        smuggled in as a fact just because part of the message was real.

        "extracted_facts": if formation_eligible is true, a short plain-text note of \
        ONLY the specific things I actually expressed or confirmed -- never an inferred \
        cause, never an invented detail (e.g. for "I hate this", note that I expressed \
        strong negative feeling, but never guess what "this" refers to unless I said \
        so). Null if formation_eligible is false.

        "scripture_quote" / "scripture_reference" (e.g. "Psalm 46:10"): a short, real \
        Bible verse that genuinely fits, included ONLY if formation_eligible is true -- \
        both null if formation_eligible is false. Never invent a verse pairing for \
        something you couldn't discern.

        "moods": an array of 2-3 strings, chosen ONLY from this exact list, that best \
        describe how I felt: \(presetMoods.joined(separator: ", ")). Included only if \
        formation_eligible is true; empty array if false. Never invent a word outside \
        this list.

        Conversation:
        \(transcript)
        """
        let messages = [
            LLMMessage(role: .system, content: "You return only valid JSON, nothing else."),
            LLMMessage(role: .user, content: prompt),
        ]

        // 1500, not the proxy's own 1000 default -- a real 2-3 paragraph body plus
        // title/facts/verse plus JSON structure needs more room than metadata alone did.
        let response = try await apiClient.callLLM(messages: messages, feature: "journal_synthesis", maxTokens: 1500)
        guard let start = response.content.firstIndex(of: "{"), let end = response.content.lastIndex(of: "}") else {
            throw NSError(domain: "JournalSynthesisManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No JSON object in LLM response"])
        }
        let jsonSubstring = response.content[start...end]
        let parsed = try JSONDecoder().decode(LLMJSON.self, from: Data(jsonSubstring.utf8))

        // Code-side enforcement, not trusted to the model alone: a "synthesize"
        // decision only stands if it actually came with a body AND that body is
        // strictly shorter (plain character count, same measure on both sides) than
        // the user's own words. Anything invalid or overlong falls back to preserving
        // the original verbatim -- never truncated, never silently accepted.
        let resolvedBody: String
        if parsed.rendering == .synthesize,
           let candidate = parsed.body?.trimmingCharacters(in: .whitespacesAndNewlines),
           !candidate.isEmpty,
           candidate.count < userOnlyText.count {
            resolvedBody = candidate
        } else {
            resolvedBody = userOnlyText
        }

        let resolvedTitle = parsed.title?.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTitle = (resolvedTitle?.isEmpty ?? true) ? "A Moment Captured" : resolvedTitle!

        return Result(
            title: finalTitle,
            body: resolvedBody,
            formationEligible: parsed.formationEligible,
            extractedFacts: parsed.formationEligible ? parsed.extractedFacts : nil,
            scriptureQuote: parsed.formationEligible ? parsed.scriptureQuote : nil,
            scriptureReference: parsed.formationEligible ? parsed.scriptureReference : nil,
            moods: parsed.formationEligible ? (parsed.moods ?? []) : []
        )
    }
}

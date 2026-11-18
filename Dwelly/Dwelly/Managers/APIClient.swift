import Foundation

protocol APIClient {
    // Moments endpoints
    func saveMoment(_ moment: Moment) async throws -> Moment
    func fetchMoments(userId: String) async throws -> [Moment]
    func fetchMoment(id: String) async throws -> Moment
    func deleteMoment(id: String) async throws
    // T-176: Recently Deleted screen. restoreMoment clears deleted_at (same soft-delete
    // mechanism T-158 built); permanentlyDeleteMoment is the one place a real hard
    // DELETE still belongs -- "Delete Forever" is genuinely, irreversibly permanent.
    func fetchDeletedMoments(userId: String) async throws -> [Moment]
    func restoreMoment(id: String) async throws
    func permanentlyDeleteMoment(id: String) async throws

    // Journal entry endpoints (T-152) — the persisted title/moods/scripture/starred
    // layer on top of a moment. `nil` means no entry exists yet for that moment
    // (e.g. a moment saved before this ticket, or synthesis hasn't run).
    func fetchJournalEntry(momentId: String) async throws -> JournalEntry?
    func saveJournalEntry(_ entry: JournalEntry) async throws -> JournalEntry
    // T-159: every pending entry for a user, for the background retry sweep to walk.
    func fetchPendingJournalEntries(userId: String) async throws -> [JournalEntry]
    // T-161: every approved (real, synthesized) entry for a user -- used to count
    // qualifying reflections against the Growth narrative's unlock threshold. A pending
    // entry has no real content yet, so it doesn't count.
    func fetchApprovedJournalEntries(userId: String) async throws -> [JournalEntry]
    // T-188: stamps journal_entries.viewed_at the first time this entry is opened --
    // the "Journal Ready" Today-tab tile's only signal for when to stop showing
    // itself. Idempotent by design (every call site only calls this when viewedAt
    // was nil, but a second call just re-stamps a slightly later time -- never
    // treated as an error either way).
    func markJournalEntryViewed(id: String) async throws

    // DwellerProfile endpoints (T-274) — the store-and-show-only running summary.
    // `nil` means no profile exists yet (a new user with no approved journal entry).
    func fetchDwellerProfile(userId: String) async throws -> DwellerProfile?
    func saveDwellerProfile(_ profile: DwellerProfile) async throws -> DwellerProfile
    // T-163: confirm/correct loop for "Your Narrative" -- confirming persists for real
    // (not a session flag); feedback from "Not quite" is captured for real even though
    // nothing processes it yet (T-164, not started).
    func confirmDwellerProfile(userId: String) async throws -> DwellerProfile
    func submitNarrativeFeedback(userId: String, feedbackText: String, narrativeAtTime: String?) async throws
    // T-161/T-164 (Nov 16 2026, Kell's direct call): "Not quite" feedback carries the
    // SAME weight as a captured moment toward both the qualifying-reflection threshold
    // and the narrative's own generated content -- not just stored, actually read back.
    func fetchNarrativeFeedback(userId: String) async throws -> [NarrativeFeedback]

    // Custom mood endpoints (T-294) — a user's own mood vocabulary, shared across every
    // journal entry rather than trapped inside the one entry it was first typed into.
    func fetchCustomMoods(userId: String) async throws -> [CustomMood]
    func addCustomMood(userId: String, word: String) async throws -> CustomMood
    func deleteCustomMood(id: String) async throws

    // Auth endpoints
    func signUp(email: String, password: String) async throws -> SignUpOutcome
    func verifySignupOTP(email: String, token: String) async throws -> AuthToken
    func resendSignupConfirmation(email: String) async throws
    func login(email: String, password: String) async throws -> AuthToken
    func logout() async throws
    // T-095: in-app account deletion (Apple App Store Guideline 5.1.1(v))
    func deleteAccount() async throws
    func requestPasswordReset(email: String) async throws
    func updatePassword(newPassword: String) async throws
    func ensureUserExists(userId: String, email: String) async throws
    // T-130: real "Member Since" on Account Profile.
    func fetchAccountCreatedAt(userId: String) async throws -> Date?
    // T-251: the dormancy clock's single source of truth -- SyncManager calls this
    // after every successful sync pass. Best-effort by every caller (never blocks or
    // surfaces an error): a missed touch just leaves the dormancy clock a little
    // stale, not materially different from the user having synced a few minutes
    // later than they actually did.
    func touchLastSynced(userId: String) async throws
    // T-131 (Kell's call, Nov 16 2026): changing your password confirms via a real email
    // OTP instead of re-typing the current password -- same NIST 800-63B "re-authenticate
    // before a sensitive change" idea, just proven via a second channel (the account's
    // email inbox) rather than a memorized secret. Reuses GoTrue's existing email-OTP
    // mechanism (`type: "email"`, distinct from `verifySignupOTP`'s `type: "signup"`) --
    // this is for an already-existing, already-signed-in user, not a new signup.
    func sendPasswordChangeOTP(email: String) async throws
    func verifyPasswordChangeOTP(email: String, token: String) async throws -> AuthToken
    func logLoginAttempt(email: String, success: Bool) async

    // Onboarding profile endpoints (T-111)
    func fetchOnboardingProfile(userId: String) async throws -> OnboardingProfileRow
    func updateOnboardingProfile(userId: String, update: OnboardingProfileUpdate) async throws

    // T-133: Support & Feedback -- "Send Feedback" and "Report a Bug" both write here,
    // distinguished by `type`. Best-effort notify (Resend/Notion, both stubbed pending
    // ops credentials) happens separately after this succeeds; see FeedbackView's own
    // comment and the feedback-notify Edge Function.
    func submitFeedback(userId: String, type: FeedbackType, message: String, appVersion: String?) async throws -> FeedbackSubmission

    // Storage endpoints
    func uploadAudio(_ audioData: Data, fileName: String, userId: String) async throws -> String
    // T-156: journal hero photos -- private "journal-photos" bucket, same shape as
    // uploadAudio/moments-audio. Returns the storage path (not a URL); the caller
    // persists that path on JournalEntry.photoPath and resolves it to a viewable
    // URL via fetchJournalPhotoSignedURL when displaying it.
    func uploadJournalPhoto(_ imageData: Data, fileName: String, userId: String) async throws -> String
    func fetchJournalPhotoSignedURL(storagePath: String) async throws -> URL

    // Analytics endpoints
    func sendUsageEvents(_ events: [UsageEventData], userId: String) async throws
    // T-116: pre-signup funnel events, keyed by anonymous device ID instead of userId
    func sendAnonymousUsageEvents(_ events: [AnonymousUsageEventData]) async throws

    // LLM endpoint (T-168) — the one call every LLM-backed feature (Capture's
    // conversation, Prayer generation, Journal synthesis) goes through.
    func callLLM(messages: [LLMMessage], feature: String, maxTokens: Int?) async throws -> LLMResponse

    // JWT token management
    func setJWTToken(_ token: String)
    func setTokens(_ jwt: String, refresh: String)
}

extension APIClient {
    /// Convenience overload -- every existing call site that doesn't need a custom
    /// token budget keeps working unchanged; only real-body synthesis (which needs
    /// more room than the proxy's own default) passes `maxTokens` explicitly.
    func callLLM(messages: [LLMMessage], feature: String) async throws -> LLMResponse {
        try await callLLM(messages: messages, feature: feature, maxTokens: nil)
    }
}

struct AuthToken: Codable {
    let token: String
    let userId: String
    let expiresAt: Date
}

/// GoTrue's /signup response has two real shapes depending on the project's "Confirm
/// email" setting (Supabase dashboard → Auth → Providers → Email): with it on (this
/// project's current setting, confirmed Nov 4 2026), signup creates the user but withholds
/// a session until the confirmation link is clicked — access_token/refresh_token are
/// simply absent from the response, not just empty. Decoding that shape into a
/// session-shaped struct is what produced "the data couldn't be read because it is
/// missing" — a real signup success treated as a decode failure.
enum SignUpOutcome {
    case session(AuthToken)
    case pendingEmailConfirmation(email: String)
    /// GoTrue's 422 "User already registered" — surfaced explicitly per Kell's direction
    /// (Nov 4, 2026): a dedicated "this email already exists" screen, not masked behind the
    /// generic check-email flow. Trades the anti-enumeration protection away deliberately —
    /// see T-115 for that tradeoff — in favor of clearer UX for a real returning user.
    case emailAlreadyExists
}

struct UsageEventData: Codable {
    let id: String
    let userId: String
    let userEmail: String?
    let eventType: String
    let momentType: String?
    let timestamp: Date
}

struct AnonymousUsageEventData: Codable {
    let id: String
    let anonymousId: String
    let eventType: String
    let momentType: String?
    let timestamp: Date
}

/// T-168. Mirrors the shape OpenAI/Groq-style chat APIs already use — `llm-proxy`
/// (supabase/functions/llm-proxy) forwards these straight through to whichever provider
/// actually serves the request.
struct LLMMessage: Codable {
    enum Role: String, Codable {
        case system, user, assistant
    }
    let role: Role
    let content: String
}

struct LLMResponse: Codable {
    let content: String
    let model: String
    let provider: String
}

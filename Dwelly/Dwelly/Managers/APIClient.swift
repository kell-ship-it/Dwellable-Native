import Foundation

protocol APIClient {
    // Moments endpoints
    func saveMoment(_ moment: Moment) async throws -> Moment
    func fetchMoments(userId: String) async throws -> [Moment]
    func fetchMoment(id: String) async throws -> Moment
    func deleteMoment(id: String) async throws

    // Journal entry endpoints (T-152) — the persisted title/moods/scripture/starred
    // layer on top of a moment. `nil` means no entry exists yet for that moment
    // (e.g. a moment saved before this ticket, or synthesis hasn't run).
    func fetchJournalEntry(momentId: String) async throws -> JournalEntry?
    func saveJournalEntry(_ entry: JournalEntry) async throws -> JournalEntry
    // T-159: every pending entry for a user, for the background retry sweep to walk.
    func fetchPendingJournalEntries(userId: String) async throws -> [JournalEntry]

    // Auth endpoints
    func signUp(email: String, password: String) async throws -> SignUpOutcome
    func verifySignupOTP(email: String, token: String) async throws -> AuthToken
    func resendSignupConfirmation(email: String) async throws
    func login(email: String, password: String) async throws -> AuthToken
    func logout() async throws
    func requestPasswordReset(email: String) async throws
    func updatePassword(newPassword: String) async throws
    func ensureUserExists(userId: String, email: String) async throws
    func logLoginAttempt(email: String, success: Bool) async

    // Onboarding profile endpoints (T-111)
    func fetchOnboardingProfile(userId: String) async throws -> OnboardingProfileRow
    func updateOnboardingProfile(userId: String, update: OnboardingProfileUpdate) async throws

    // Storage endpoints
    func uploadAudio(_ audioData: Data, fileName: String, userId: String) async throws -> String

    // Analytics endpoints
    func sendUsageEvents(_ events: [UsageEventData], userId: String) async throws

    // LLM endpoint (T-168) — the one call every LLM-backed feature (Capture's
    // conversation, Prayer generation, Journal synthesis) goes through.
    func callLLM(messages: [LLMMessage], feature: String) async throws -> LLMResponse

    // JWT token management
    func setJWTToken(_ token: String)
    func setTokens(_ jwt: String, refresh: String)
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

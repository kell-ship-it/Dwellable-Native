import Foundation

protocol APIClient {
    // Moments endpoints
    func saveMoment(_ moment: Moment) async throws -> Moment
    func fetchMoments(userId: String) async throws -> [Moment]
    func fetchMoment(id: String) async throws -> Moment
    func deleteMoment(id: String) async throws

    // Auth endpoints
    func signUp(email: String, password: String) async throws -> SignUpOutcome
    func login(email: String, password: String) async throws -> AuthToken
    func logout() async throws
    func requestPasswordReset(email: String) async throws
    func updatePassword(newPassword: String) async throws
    func ensureUserExists(userId: String, email: String) async throws
    func logLoginAttempt(email: String, success: Bool) async

    // Storage endpoints
    func uploadAudio(_ audioData: Data, fileName: String, userId: String) async throws -> String

    // Analytics endpoints
    func sendUsageEvents(_ events: [UsageEventData], userId: String) async throws

    // JWT token management
    func setJWTToken(_ token: String)
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
}

struct UsageEventData: Codable {
    let id: String
    let userId: String
    let userEmail: String?
    let eventType: String
    let momentType: String?
    let timestamp: Date
}

import Foundation

protocol APIClient {
    // Moments endpoints
    func saveMoment(_ moment: Moment) async throws -> Moment
    func fetchMoments(userId: String) async throws -> [Moment]
    func fetchMoment(id: String) async throws -> Moment
    func deleteMoment(id: String) async throws

    // Auth endpoints
    func login(email: String, password: String) async throws -> AuthToken
    func logout() async throws
    func ensureUserExists(userId: String, email: String) async throws

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

struct UsageEventData: Codable {
    let id: String
    let userId: String
    let eventType: String
    let momentType: String?
    let timestamp: Date
}

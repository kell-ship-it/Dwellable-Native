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
}

struct AuthToken: Codable {
    let token: String
    let userId: String
    let expiresAt: Date
}

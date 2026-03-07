import Foundation

class MockAPIClient: APIClient {
    private var storedMoments: [Moment] = []
    private let currentUserId = "user-demo-001"

    init() {
        // Initialize with sample moments
        storedMoments = [
            Moment(
                userId: currentUserId,
                body: "Today I felt God's presence in a simple conversation with a friend. We talked about life's purpose and they shared a perspective I hadn't considered before.",
                senseOfLord: "In the unexpected wisdom from a friend",
                createdAt: Date(timeIntervalSinceNow: -86400 * 2)
            ),
            Moment(
                userId: currentUserId,
                body: "Spent the morning in prayer and meditation. The stillness brought clarity to a decision I've been struggling with.",
                senseOfLord: "In the quiet space of listening",
                createdAt: Date(timeIntervalSinceNow: -86400)
            ),
            Moment(
                userId: currentUserId,
                body: "A moment of doubt today, but then I remembered past times when God provided. This memory brought comfort.",
                senseOfLord: nil,
                createdAt: Date()
            )
        ]
    }

    // MARK: - Moments API

    func saveMoment(_ moment: Moment) async throws -> Moment {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second

        // Check if moment exists (update) or create new
        if let index = storedMoments.firstIndex(where: { $0.id == moment.id }) {
            storedMoments[index] = moment
        } else {
            storedMoments.append(moment)
        }

        return moment
    }

    func fetchMoments(userId: String) async throws -> [Moment] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 second

        // Return moments for this user, sorted by date descending
        return storedMoments.filter { $0.userId == userId }.sorted { $0.createdAt > $1.createdAt }
    }

    func fetchMoment(id: String) async throws -> Moment {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 second

        guard let moment = storedMoments.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        return moment
    }

    func deleteMoment(id: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 second

        storedMoments.removeAll { $0.id == id }
    }

    // MARK: - Auth API

    func login(email: String, password: String) async throws -> AuthToken {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second

        // Mock validation
        guard !email.isEmpty, !password.isEmpty else {
            throw APIError.invalidRequest
        }

        return AuthToken(
            token: "mock-token-\(UUID().uuidString)",
            userId: currentUserId,
            expiresAt: Date(timeIntervalSinceNow: 86400 * 30) // 30 days
        )
    }

    func logout() async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 second

        // Clear stored token (would be done by AuthManager in real app)
    }
}

enum APIError: LocalizedError {
    case invalidRequest
    case notFound
    case networkError
    case serverError
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "Invalid request"
        case .notFound:
            return "Resource not found"
        case .networkError:
            return "Network error"
        case .serverError:
            return "Server error"
        case .unknown:
            return "Unknown error"
        }
    }
}

import Foundation

class MockAPIClient: APIClient {
    private var storedMoments: [Moment] = []
    private let currentUserId = "user-demo-001"

    // Mock test accounts for authentication
    private let validCredentials: [String: String] = [
        "test@example.com": "password123",
        "kell@example.com": "test1234"
    ]

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

        // Validate email and password are not empty
        guard !email.isEmpty, !password.isEmpty else {
            throw APIError.invalidRequest
        }

        // Validate against known test credentials
        guard let expectedPassword = validCredentials[email], expectedPassword == password else {
            throw APIError.invalidCredentials
        }

        return AuthToken(
            token: "mock-token-\(UUID().uuidString)",
            userId: currentUserId,
            expiresAt: Date(timeIntervalSinceNow: 86400 * 30) // 30 days
        )
    }

    func requestPasswordReset(email: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
        guard !email.isEmpty else { throw APIError.invalidRequest }
        // Mirrors real GoTrue behavior: always succeeds, never reveals whether the email exists.
    }

    func signUp(email: String, password: String) async throws -> SignUpOutcome {
        try await Task.sleep(nanoseconds: 500_000_000)
        guard !email.isEmpty, !password.isEmpty else { throw APIError.invalidRequest }
        if validCredentials[email] != nil {
            throw APIError.message("That email is already in use.")
        }
        return .session(AuthToken(
            token: "mock-token-\(UUID().uuidString)",
            userId: "user-\(UUID().uuidString.prefix(8))",
            expiresAt: Date(timeIntervalSinceNow: 86400 * 30)
        ))
    }

    func verifySignupOTP(email: String, token: String) async throws -> AuthToken {
        try await Task.sleep(nanoseconds: 500_000_000)
        guard token == "123456" else { throw APIError.message("Invalid or expired code.") }
        return AuthToken(
            token: "mock-token-\(UUID().uuidString)",
            userId: "user-\(UUID().uuidString.prefix(8))",
            expiresAt: Date(timeIntervalSinceNow: 86400 * 30)
        )
    }

    func resendSignupConfirmation(email: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
    }

    func updatePassword(newPassword: String) async throws {
        try await Task.sleep(nanoseconds: 400_000_000)
        guard !newPassword.isEmpty else { throw APIError.invalidRequest }
    }

    func logout() async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 second

        // Clear stored token (would be done by AuthManager in real app)
    }

    func ensureUserExists(userId: String, email: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 second

        // Mock implementation - just succeeds (in real app, this creates user in DB)
    }

    func logLoginAttempt(email: String, success: Bool) async {
        // Mock implementation - just logs locally
        print("Mock: Login attempt logged — email: \(email), success: \(success)")
    }

    private var mockOnboardingProfiles: [String: OnboardingProfileRow] = [:]

    func fetchOnboardingProfile(userId: String) async throws -> OnboardingProfileRow {
        mockOnboardingProfiles[userId] ?? OnboardingProfileRow(
            id: userId, name: nil, spiritual_intent: nil, notification_opt_in: nil,
            onboarding_completed_at: nil, current_onboarding_screen: nil
        )
    }

    func updateOnboardingProfile(userId: String, update: OnboardingProfileUpdate) async throws {
        var existing = try await fetchOnboardingProfile(userId: userId)
        existing = OnboardingProfileRow(
            id: userId,
            name: update.name ?? existing.name,
            spiritual_intent: update.spiritualIntent ?? existing.spiritual_intent,
            notification_opt_in: update.notificationOptIn ?? existing.notification_opt_in,
            onboarding_completed_at: update.onboardingCompletedAt ?? existing.onboarding_completed_at,
            current_onboarding_screen: update.currentOnboardingScreen ?? existing.current_onboarding_screen
        )
        mockOnboardingProfiles[userId] = existing
    }

    // MARK: - Storage API

    func uploadAudio(_ audioData: Data, fileName: String, userId: String) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second

        // Mock implementation - return a fake signed URL (valid for 7 days)
        let token = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let mockSignedURL = "https://lhcjobrtmbawlhjyodxz.supabase.co/storage/v1/object/signed/moments-audio/\(userId)/\(fileName)?token=\(token)&t=\(Int(Date().timeIntervalSince1970))"
        print("Mock: Uploaded audio \(fileName) — signed URL generated")
        return mockSignedURL
    }

    // MARK: - Analytics API

    func sendUsageEvents(_ events: [UsageEventData], userId: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 second

        // Mock implementation - just succeeds (events logged locally in real app)
        print("Mock: Synced \(events.count) usage events for user \(userId)")
    }

    func setJWTToken(_ token: String) {
        // Mock implementation - token not used in mock client
    }

    func setTokens(_ jwt: String, refresh: String) {
        // Mock implementation - tokens not used in mock client
    }
}

enum APIError: LocalizedError {
    case invalidRequest
    case invalidCredentials
    case notFound
    case networkError
    case serverError
    case unauthorized   // 401 — JWT expired
    case unknown
    case message(String) // server-provided reason, shown verbatim (e.g. GoTrue's signup errors)

    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "Invalid request"
        case .invalidCredentials:
            return "Email or password is incorrect"
        case .notFound:
            return "Resource not found"
        case .networkError:
            return "Network error"
        case .serverError:
            return "Server error"
        case .unauthorized:
            return "Session expired — please log in again"
        case .unknown:
            return "Unknown error"
        case .message(let text):
            return text
        }
    }
}

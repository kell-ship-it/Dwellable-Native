import Foundation
import Combine

// MARK: - Login Attempt Tracker

class LoginAttemptTracker {
    private let maxFailedAttempts = 5
    private let lockoutDuration: TimeInterval = 10 * 60 // 10 minutes

    private var failedAttempts: [Date] = []
    private var lockoutUntil: Date?

    func recordFailedAttempt() {
        failedAttempts.append(Date())

        let cutoffTime = Date().addingTimeInterval(-lockoutDuration)
        failedAttempts.removeAll { $0 < cutoffTime }

        if failedAttempts.count >= maxFailedAttempts {
            lockoutUntil = Date().addingTimeInterval(lockoutDuration)
        }
    }

    func recordSuccessfulLogin() {
        failedAttempts.removeAll()
        lockoutUntil = nil
    }

    func isLockedOut() -> Bool {
        guard let lockoutTime = lockoutUntil else { return false }

        if Date() >= lockoutTime {
            lockoutUntil = nil
            failedAttempts.removeAll()
            return false
        }

        return true
    }

    func secondsUntilUnlock() -> Int {
        guard let lockoutTime = lockoutUntil else { return 0 }

        let remaining = lockoutTime.timeIntervalSince(Date())
        return max(0, Int(ceil(remaining)))
    }

    func currentAttemptCount() -> Int {
        return failedAttempts.count
    }
}

// MARK: - Auth Manager

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: AuthUser?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient: APIClient
    private let keychain = KeychainManager.shared
    private let loginAttemptTracker = LoginAttemptTracker()

    init(apiClient: APIClient) {
        self.apiClient = apiClient

        // Check for existing auth token on init
        if let token = keychain.retrieve(forKey: "authToken"),
           let userId = keychain.retrieve(forKey: "userId") {
            // Restore JWT token to API client for session persistence
            apiClient.setJWTToken(token)
            let email = keychain.retrieve(forKey: "userEmail") ?? ""
            currentUser = AuthUser(id: userId, email: email, token: token)
            isAuthenticated = true
        }
    }

    func signIn(email: String, password: String) async {
        // Check if account is locked out
        if loginAttemptTracker.isLockedOut() {
            let secondsRemaining = loginAttemptTracker.secondsUntilUnlock()
            let minutesRemaining = (secondsRemaining + 59) / 60
            DispatchQueue.main.async {
                self.errorMessage = "Too many failed login attempts. Try again in \(minutesRemaining) minute\(minutesRemaining == 1 ? "" : "s")."
                self.isLoading = false
            }
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

        do {
            let authToken = try await apiClient.login(email: email, password: password)

            // Set JWT token on API client for authenticated requests
            apiClient.setJWTToken(authToken.token)

            // Create user record in database (idempotent - won't fail if already exists)
            do {
                try await apiClient.ensureUserExists(userId: authToken.userId, email: email)
            } catch {
                // Log but don't fail auth if user creation fails
                let errorMsg = "⚠️ [AUTH] Could not create user record for \(email): \(error.localizedDescription)"
                print(errorMsg)
                HTMLLogManager.shared.log(errorMsg, level: "ERROR")
            }

            // Store token, userId, and email in Keychain
            _ = keychain.save(authToken.token, forKey: "authToken")
            _ = keychain.save(authToken.userId, forKey: "userId")
            _ = keychain.save(email, forKey: "userEmail")
            // Note: refreshToken is also saved by APIClient.setTokens() to keychain

            let user = AuthUser(id: authToken.userId, email: email, token: authToken.token)

            // Record successful login
            loginAttemptTracker.recordSuccessfulLogin()

            // Log successful login attempt to monitoring system (async, non-blocking)
            await apiClient.logLoginAttempt(email: email, success: true)

            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
            }
        } catch {
            // Record failed attempt
            loginAttemptTracker.recordFailedAttempt()
            let attemptsRemaining = 5 - loginAttemptTracker.currentAttemptCount()

            // Log failed login attempt to monitoring system (async, non-blocking)
            await apiClient.logLoginAttempt(email: email, success: false)

            DispatchQueue.main.async {
                if attemptsRemaining > 0 {
                    self.errorMessage = "Sign in failed: \(error.localizedDescription). \(attemptsRemaining) attempt\(attemptsRemaining == 1 ? "" : "s") remaining."
                } else {
                    let secondsRemaining = self.loginAttemptTracker.secondsUntilUnlock()
                    let minutesRemaining = (secondsRemaining + 59) / 60
                    self.errorMessage = "Too many failed attempts. Account locked for \(minutesRemaining) minute\(minutesRemaining == 1 ? "" : "s")."
                }
                self.isLoading = false
            }
        }
    }

    func signOut() async {
        do {
            try await apiClient.logout()
        } catch {
            // Log error but continue with local cleanup
            print("Logout error: \(error.localizedDescription)")
        }

        // Clear keychain and local state
        keychain.delete(forKey: "authToken")
        keychain.delete(forKey: "userId")
        keychain.delete(forKey: "userEmail")

        DispatchQueue.main.async {
            self.currentUser = nil
            self.isAuthenticated = false
            self.errorMessage = nil
        }
    }
}

struct AuthUser: Identifiable {
    let id: String
    let email: String
    let token: String
}

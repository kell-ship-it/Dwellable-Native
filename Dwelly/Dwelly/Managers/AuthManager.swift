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

    /// Spec: docs/PILLAR_AUTHENTICATION_STRATEGY.md §6 "Account Creation". Client-side
    /// password-strength validation happens in AccountCreationView before this is ever
    /// called — this method assumes a password that already passed those rules and only
    /// handles what the server can tell us (e.g. "email already in use").
    func signUp(email: String, password: String) async -> SignUpResult {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

        do {
            let outcome = try await apiClient.signUp(email: email, password: password)

            switch outcome {
            case .session(let authToken):
                apiClient.setJWTToken(authToken.token)

                do {
                    try await apiClient.ensureUserExists(userId: authToken.userId, email: email)
                } catch {
                    print("Warning: Could not create user record: \(error.localizedDescription)")
                }

                _ = keychain.save(authToken.token, forKey: "authToken")
                _ = keychain.save(authToken.userId, forKey: "userId")
                _ = keychain.save(email, forKey: "userEmail")

                let user = AuthUser(id: authToken.userId, email: email, token: authToken.token)

                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isAuthenticated = true
                    self.isLoading = false
                }
                return .signedIn

            case .pendingEmailConfirmation:
                // Real success — the account exists in auth.users — just no session until
                // the confirmation link is clicked. Don't set isAuthenticated; there's no
                // token to authenticate with yet.
                DispatchQueue.main.async { self.isLoading = false }
                return .pendingEmailConfirmation
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            return .failure
        }
    }

    /// Used only during the password-reset deep-link flow, where `apiClient` already holds
    /// the short-lived recovery session's JWT (set by whoever handled the `dwelly://auth/reset`
    /// link) rather than a normal signed-in session.
    func updatePassword(newPassword: String) async -> Bool {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        do {
            try await apiClient.updatePassword(newPassword: newPassword)
            DispatchQueue.main.async { self.isLoading = false }
            return true
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            return false
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
                print("Warning: Could not create user record: \(error.localizedDescription)")
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

    /// Always reports success on the happy path — GoTrue's /recover endpoint never reveals
    /// whether an email is registered, so the UI can't branch on "found" vs "not found"
    /// without leaking that information. `false` means the request itself failed (network,
    /// rate limit), not "no such account."
    func requestPasswordReset(email: String) async -> Bool {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

        do {
            try await apiClient.requestPasswordReset(email: email)
            DispatchQueue.main.async { self.isLoading = false }
            return true
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Couldn't send reset email: \(error.localizedDescription)"
                self.isLoading = false
            }
            return false
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

enum SignUpResult {
    case signedIn
    case pendingEmailConfirmation
    case failure
}

import Foundation
import Combine
import LocalAuthentication

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
    /// Bumped whenever a deep link needs every presented auth screen to collapse back to
    /// the root before the deep link's own destination can show. Needed because
    /// Welcome -> Login -> ForgotPassword is a chain of nested `fullScreenCover`s, and
    /// DwellyApp's own root-level `fullScreenCover(passwordResetPending)` for
    /// NewPasswordView can't cleanly present itself over an already-active nested one —
    /// SwiftUI just queues it until the user manually backs out (Kell caught this Nov 4
    /// 2026: tapping the reset link while "Check your email" was showing landed on
    /// NewPasswordView only after backing all the way out to Welcome by hand).
    @Published var authSheetDismissTrigger = UUID()

    private let apiClient: APIClient
    private let keychain = KeychainManager.shared
    private let loginAttemptTracker = LoginAttemptTracker()

    private let faceIDEmailKey = "faceIDEmail"
    private let faceIDPasswordKey = "faceIDPassword"

    /// Whether "Log in with Face ID" should be offered on LoginView — the device actually
    /// supports Face ID/Touch ID AND a credential was saved for it by a prior successful
    /// sign-in/sign-up on this device. Checking both means we never show the row only to have
    /// it immediately fail (no saved credential) or simply not work (no biometric hardware).
    var isFaceIDLoginAvailable: Bool {
        var error: NSError?
        let supportsBiometrics = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        // Email is stored in plain Keychain (not secret, not biometric-gated) purely so this
        // check can run without prompting for Face ID itself; only the password is behind the
        // biometric gate, so the real sign-in below still needs one real Face ID check.
        return supportsBiometrics && keychain.retrieve(forKey: faceIDEmailKey) != nil
    }

    /// Called after every successful sign-in/sign-up (not just opt-in) so "Log in with Face ID"
    /// starts working the next time the user lands on LoginView, without a separate settings
    /// toggle that doesn't exist in the locked design yet. Silently does nothing on a device
    /// with no biometric hardware enrolled.
    private func saveFaceIDCredentialIfPossible(email: String, password: String) {
        var error: NSError?
        guard LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else { return }
        _ = keychain.save(email, forKey: faceIDEmailKey)
        _ = keychain.saveBiometricProtected(password, forKey: faceIDPasswordKey)
    }

    /// Triggers the system Face ID/Touch ID prompt (via Keychain's own biometric gate, see
    /// `KeychainManager.retrieveBiometricProtected`) and signs in with the credential saved by
    /// a prior successful sign-in/sign-up on this device. Returns false on cancel, failure, or
    /// no saved credential — `errorMessage` is left untouched on a plain user cancel so the
    /// screen doesn't show a scary error for someone who just changed their mind.
    func signInWithFaceID() async -> Bool {
        guard let email = keychain.retrieve(forKey: faceIDEmailKey),
              let password = keychain.retrieveBiometricProtected(
                forKey: faceIDPasswordKey,
                prompt: "Log in to Dwelly"
              ) else {
            return false
        }
        await signIn(email: email, password: password)
        return isAuthenticated
    }

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
                saveFaceIDCredentialIfPossible(email: email, password: password)

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

            case .emailAlreadyExists:
                DispatchQueue.main.async { self.isLoading = false }
                return .emailAlreadyExists
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            return .failure
        }
    }

    /// Finishes the sign-up flow after the `dwelly://auth/confirm` deep link hands back a
    /// real session (GoTrue's fragment carries access_token/refresh_token/type=signup, same
    /// wire shape as the recovery link) — mirrors the tail of signIn()'s success path, minus
    /// saveFaceIDCredentialIfPossible since there's no password available here.
    @discardableResult
    func completeEmailConfirmation(accessToken: String, refreshToken: String) async -> Bool {
        guard let claims = Self.decodeJWTPayload(accessToken), let userId = claims["sub"] as? String else {
            return false
        }
        let email = claims["email"] as? String ?? keychain.retrieve(forKey: "userEmail") ?? ""

        apiClient.setTokens(accessToken, refresh: refreshToken)

        // This call is also the real validity check for the token — it's an authenticated
        // request, so an expired/stale confirmation link gets a 401 here. Previously this
        // failure was swallowed (just printed) and the user got marked authenticated
        // anyway — a stale link could claim success locally while no real session existed
        // server-side. Found auditing Sign In edge cases, Nov 4 2026.
        do {
            try await apiClient.ensureUserExists(userId: userId, email: email)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "That confirmation link has expired. Please request a new one."
            }
            return false
        }

        _ = keychain.save(accessToken, forKey: "authToken")
        _ = keychain.save(userId, forKey: "userId")
        _ = keychain.save(email, forKey: "userEmail")

        let user = AuthUser(id: userId, email: email, token: accessToken)
        DispatchQueue.main.async {
            self.currentUser = user
            self.isAuthenticated = true
        }
        return true
    }

    private static func decodeJWTPayload(_ jwt: String) -> [String: Any]? {
        let parts = jwt.split(separator: ".")
        guard parts.count == 3 else { return nil }
        var base64 = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64 += "=" }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
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

    /// Updates the password AND signs the user straight into the app on success, instead
    /// of making them retype their email/new password on LoginView right after they just
    /// typed it here — Kell's explicit call (Nov 4, 2026): the recovery link's session is
    /// a real one (GoTrue issues access_token + refresh_token for `type=recovery` same as
    /// a normal sign-in), so there's no reason to throw it away and force a fresh login.
    @discardableResult
    func completePasswordReset(newPassword: String, accessToken: String, refreshToken: String) async -> Bool {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        do {
            try await apiClient.updatePassword(newPassword: newPassword)

            guard let claims = Self.decodeJWTPayload(accessToken), let userId = claims["sub"] as? String else {
                DispatchQueue.main.async { self.isLoading = false }
                return false
            }
            let email = claims["email"] as? String ?? keychain.retrieve(forKey: "userEmail") ?? ""

            apiClient.setTokens(accessToken, refresh: refreshToken)
            _ = keychain.save(accessToken, forKey: "authToken")
            _ = keychain.save(userId, forKey: "userId")
            _ = keychain.save(email, forKey: "userEmail")

            let user = AuthUser(id: userId, email: email, token: accessToken)
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
            }
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
            saveFaceIDCredentialIfPossible(email: email, password: password)

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

        // Clear keychain and local state. Was leaving refreshToken and the Face ID
        // credential (faceIDEmail/faceIDPassword) behind — on a shared device, that meant
        // "Log in with Face ID" stayed available for the account that just signed out,
        // since isFaceIDLoginAvailable only checks whether a credential exists, not
        // whether anyone is currently authenticated. Found auditing Sign In edge cases,
        // Nov 4 2026.
        keychain.delete(forKey: "authToken")
        keychain.delete(forKey: "refreshToken")
        keychain.delete(forKey: "userId")
        keychain.delete(forKey: "userEmail")
        keychain.delete(forKey: faceIDEmailKey)
        keychain.delete(forKey: faceIDPasswordKey)

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
    case emailAlreadyExists
    case failure
}

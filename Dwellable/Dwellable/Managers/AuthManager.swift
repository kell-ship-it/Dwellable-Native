import Foundation
import Combine

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: AuthUser?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient: APIClient
    private let keychain = KeychainManager.shared

    init(apiClient: APIClient) {
        self.apiClient = apiClient

        // Check for existing auth token on init
        if let token = keychain.retrieve(forKey: "authToken"),
           let userId = keychain.retrieve(forKey: "userId") {
            currentUser = AuthUser(id: userId, email: "", token: token)
            isAuthenticated = true
        }
    }

    func signIn(email: String, password: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

        do {
            let authToken = try await apiClient.login(email: email, password: password)

            // Create user record in database (idempotent - won't fail if already exists)
            do {
                try await apiClient.ensureUserExists(userId: authToken.userId, email: email)
            } catch {
                // Log but don't fail auth if user creation fails
                print("Warning: Could not create user record: \(error.localizedDescription)")
            }

            // Store token and userId in Keychain
            _ = keychain.save(authToken.token, forKey: "authToken")
            _ = keychain.save(authToken.userId, forKey: "userId")

            let user = AuthUser(id: authToken.userId, email: email, token: authToken.token)

            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Sign in failed: \(error.localizedDescription)"
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

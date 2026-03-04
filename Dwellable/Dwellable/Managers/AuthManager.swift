import Foundation
import Combine

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: AuthUser?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        if let storedUserId = UserDefaults.standard.string(forKey: "userId") {
            currentUser = AuthUser(id: storedUserId, email: "")
            isAuthenticated = true
        }
    }

    func signIn(email: String, password: String) async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

        do {
            try await Task.sleep(nanoseconds: 1_000_000_000)

            let user = AuthUser(id: UUID().uuidString, email: email)
            UserDefaults.standard.set(user.id, forKey: "userId")
            UserDefaults.standard.set(email, forKey: "userEmail")

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

    func signOut() {
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userEmail")

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
}

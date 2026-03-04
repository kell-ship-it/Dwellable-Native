import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("DWELLABLE")
                            .font(.system(size: 26, weight: .light))
                            .tracking(5)
                            .foregroundColor(Theme.text)

                        Text("A place to hold what matters.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Theme.tertiaryText)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 12) {
                        ZStack(alignment: .leading) {
                            TextField("", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding(16)
                                .background(Color(red: 0.07, green: 0.07, blue: 0.09))
                                .foregroundColor(.white)
                                .tint(Theme.gold)
                                .border(Color(red: 0.6, green: 0.64, blue: 0.71, opacity: 0.2), width: 1)
                                .cornerRadius(14)

                            if email.isEmpty {
                                Text("Email")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
                                    .padding(.leading, 16)
                            }
                        }

                        ZStack(alignment: .leading) {
                            SecureField("", text: $password)
                                .textContentType(.password)
                                .padding(16)
                                .background(Color(red: 0.07, green: 0.07, blue: 0.09))
                                .foregroundColor(.white)
                                .tint(Theme.gold)
                                .border(Color(red: 0.6, green: 0.64, blue: 0.71, opacity: 0.2), width: 1)
                                .cornerRadius(14)

                            if password.isEmpty {
                                Text("Password")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(Color(red: 0.85, green: 0.85, blue: 0.85))
                                    .padding(.leading, 16)
                            }
                        }
                    }
                    .padding(.horizontal, 32)

                    Button(action: {
                        Task {
                            await authManager.signIn(email: email, password: password)
                        }
                    }) {
                        Text(authManager.isLoading ? "Signing in..." : "Sign In")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.05))
                            .frame(maxWidth: .infinity)
                            .padding(18)
                            .background(Theme.gold)
                            .cornerRadius(18)
                    }
                    .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
                    .padding(.horizontal, 32)
                }

                if let error = authManager.errorMessage {
                    Text(error)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 20)
                }

                Spacer()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}

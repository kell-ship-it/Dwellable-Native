import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false

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
                                .padding(Theme.Spacing.lg)
                                .background(Theme.inputBackground)
                                .foregroundColor(.white)
                                .tint(Theme.gold)
                                .border(Theme.border, width: 1)
                                .cornerRadius(14)
                                .accessibilityIdentifier("Email")

                            if email.isEmpty {
                                Text("Email")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(Theme.placeholderText)
                                    .padding(.leading, Theme.Spacing.lg)
                            }
                        }

                        ZStack(alignment: .leading) {
                            HStack(spacing: 0) {
                                if showPassword {
                                    TextField("", text: $password)
                                        .textContentType(.password)
                                        .padding(Theme.Spacing.lg)
                                        .foregroundColor(.white)
                                        .tint(Theme.gold)
                                        .accessibilityIdentifier("Password")
                                } else {
                                    SecureField("", text: $password)
                                        .textContentType(.password)
                                        .padding(Theme.Spacing.lg)
                                        .foregroundColor(.white)
                                        .tint(Theme.gold)
                                        .accessibilityIdentifier("Password")
                                }

                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(Theme.tertiaryText)
                                        .padding(.trailing, Theme.Spacing.lg)
                                }
                            }
                            .background(Theme.inputBackground)
                            .border(Theme.border, width: 1)
                            .cornerRadius(14)

                            if password.isEmpty {
                                Text("Password")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(Theme.placeholderText)
                                    .padding(.leading, Theme.Spacing.lg)
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
                            .foregroundColor(Theme.goldDark)
                            .frame(maxWidth: .infinity)
                            .padding(Theme.Button.primaryPadding)
                            .background(Theme.gold)
                            .cornerRadius(Theme.Button.primaryCornerRadius)
                    }
                    .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
                    .padding(.horizontal, Theme.Spacing.xxl)
                    .accessibilityIdentifier("Login")
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
    let apiClient = MockAPIClient()
    LoginView()
        .environmentObject(AuthManager(apiClient: apiClient))
}

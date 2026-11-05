import SwiftUI

/// Returning-user login (Figma `dwelly-redesign` node `974:3709`, "Returning User Login").
/// "Welcome back." is the screen's fixed copy for anyone landing here — not a personalized,
/// device-recognition greeting. We don't track device identity for this; raised to Kell
/// Nov 3, 2026 as a feature question (not built, no plan to build it without his go-ahead).
struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showForgotPassword = false

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Payment.backgroundPrimary.ignoresSafeArea()

            // Footer is pinned via `.safeAreaInset(edge: .bottom)` — see the note on
            // `footer` for why (same fix as AccountCreationView, Nov 3 2026).
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 130)

                    Text("Welcome back.")
                        .font(.system(size: 28, design: .serif))
                        .foregroundColor(Theme.Payment.textHeading)

                    Spacer().frame(height: 16)

                    Text("Log in to continue where you left off.")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.Payment.textSupporting)

                    Spacer().frame(height: 40)

                    fieldLabel("Email")
                    textField(placeholder: "you@example.com", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .accessibilityIdentifier("Email")
                        .accessibilityLabel("Email")

                    Spacer().frame(height: 18)

                    fieldLabel("Password")
                    passwordField

                    if let error = authManager.errorMessage {
                        Spacer().frame(height: 10)
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(Theme.Payment.errorRed)
                    }

                    Spacer().frame(height: 16)

                    Button(action: { showForgotPassword = true }) {
                        Text("Forgot password?")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.gold)
                            .frame(minHeight: 44, alignment: .leading)
                            .contentShape(Rectangle())
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 28)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) { footer }

            // Scoped to just this button — see AccountCreationView's identical comment
            // for why applying this to the whole ZStack instead breaks the ScrollView's
            // own keyboard-avoidance (makes lower fields unreachable while typing).
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.Payment.textHeading)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Back")
            .padding(.leading, 20)
            .padding(.top, 52)
            .frame(maxWidth: .infinity, alignment: .leading)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .fullScreenCover(isPresented: $showForgotPassword) {
            ForgotPasswordView()
                .environmentObject(authManager)
        }
    }

    // MARK: - Fields

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .tracking(0.3)
            .foregroundColor(Theme.Payment.textSupporting)
            .padding(.bottom, 8)
    }

    private func textField(placeholder: String, text: Binding<String>) -> some View {
        TextField("", text: text, prompt: Text(placeholder).foregroundColor(Theme.Payment.textPlaceholder))
            .font(.system(size: 16))
            .foregroundColor(Theme.Payment.textHeading)
            .tint(Theme.gold)
            .padding(.horizontal, 20)
            .frame(height: 60)
            .background(Theme.Payment.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var passwordField: some View {
        HStack(spacing: 0) {
            Group {
                if showPassword {
                    TextField("", text: $password, prompt: Text("••••••••").foregroundColor(Theme.Payment.textPlaceholder))
                } else {
                    SecureField("", text: $password, prompt: Text("••••••••").foregroundColor(Theme.Payment.textPlaceholder))
                }
            }
            .font(.system(size: 20))
            .foregroundColor(Theme.Payment.textHeading)
            .tint(Theme.gold)
            .textContentType(.password)
            .accessibilityIdentifier("Password")
            .accessibilityLabel("Password")

            Button(action: { showPassword.toggle() }) {
                Image(systemName: showPassword ? "eye.slash" : "eye")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(showPassword ? "Hide password" : "Show password")
        }
        .padding(.leading, 20)
        .padding(.trailing, 8)
        .frame(height: 60)
        .background(Theme.Payment.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Footer

    /// Pinned below the ScrollView via `.safeAreaInset(edge: .bottom)` — always visible,
    /// never requires scrolling to reach, and still correctly avoids the keyboard.
    private var footer: some View {
        VStack(spacing: 16) {
            Button(action: {
                Task { await authManager.signIn(email: email, password: password) }
            }) {
                if authManager.isLoading {
                    ProgressView().tint(Theme.Payment.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                } else {
                    Text("Log In")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Payment.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                }
            }
            .background(Theme.gold)
            .clipShape(Capsule())
            .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
            .accessibilityIdentifier("Login")

            // Figma node 974:3771. Only shown once a credential actually exists to use —
            // see AuthManager.isFaceIDLoginAvailable — so this is never a dead tap.
            if authManager.isFaceIDLoginAvailable {
                Button(action: {
                    Task { await authManager.signInWithFaceID() }
                }) {
                    Text("Log in with Face ID")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.Payment.textSupporting)
                }
                .disabled(authManager.isLoading)
            }

            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(Theme.Payment.textSupporting)
                    Text("Get Started")
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.Payment.textHeading)
                }
                .font(.system(size: 14))
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(Theme.Payment.backgroundPrimary)
    }
}

#Preview {
    let apiClient = MockAPIClient()
    LoginView()
        .environmentObject(AuthManager(apiClient: apiClient))
}

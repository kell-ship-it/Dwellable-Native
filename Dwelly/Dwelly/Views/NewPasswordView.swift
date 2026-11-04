import SwiftUI

/// Step 4 of the password-reset flow (docs/PILLAR_AUTHENTICATION_STRATEGY.md §6,
/// "New Password Entry"). Reached only via the `dwelly://auth/reset` deep link — see
/// DwellyApp.onOpenURL — which hands this view a short-lived recovery session already
/// set as the API client's JWT, so `AuthManager.updatePassword()` can call
/// `PUT /auth/v1/user` directly with no re-login required.
struct NewPasswordView: View {
    var onDone: () -> Void

    @EnvironmentObject var authManager: AuthManager
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var didSucceed = false

    private var strength: PasswordStrength { PasswordStrength(password: password) }
    private var passwordsMatch: Bool { !confirmPassword.isEmpty && password == confirmPassword }
    private var isValid: Bool { strength.isValid && passwordsMatch }

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Payment.backgroundPrimary.ignoresSafeArea()

            // Footer is pinned via `.safeAreaInset(edge: .bottom)` — see the note on
            // `footer` (same fix as AccountCreationView/LoginView/ForgotPasswordView,
            // Nov 3 2026).
            ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 130)

                Text(didSucceed ? "Password reset" : "Create new password")
                    .font(.system(size: 28, design: .serif))
                    .foregroundColor(Theme.Payment.textHeading)

                Spacer().frame(height: 16)

                Text(didSucceed
                     ? "Your password has been changed. Log in with your new password."
                     : "Choose a new password for your account.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .fixedSize(horizontal: false, vertical: true)

                if !didSucceed {
                    Spacer().frame(height: 40)

                    fieldLabel("New Password")
                    passwordField($password, placeholder: "••••••••")

                    if !password.isEmpty {
                        Spacer().frame(height: 12)
                        strengthChecklist
                    }

                    Spacer().frame(height: 18)

                    fieldLabel("Confirm Password")
                    passwordField($confirmPassword, placeholder: "••••••••")
                    if !confirmPassword.isEmpty && !passwordsMatch {
                        Spacer().frame(height: 10)
                        Text("Passwords don't match.")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.Payment.errorRed)
                    }

                    if let error = authManager.errorMessage {
                        Spacer().frame(height: 14)
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(Theme.Payment.errorRed)
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 28)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) { footer }
        }
        // No ignoresSafeArea(.keyboard) needed here — this screen has no fixed-position
        // header element to protect from the keyboard push (no back button), so letting
        // the ScrollView's own keyboard-avoidance run normally is correct as-is.
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .tracking(0.3)
            .foregroundColor(Theme.Payment.textSupporting)
            .padding(.bottom, 8)
    }

    private func passwordField(_ text: Binding<String>, placeholder: String) -> some View {
        HStack(spacing: 0) {
            Group {
                if showPassword {
                    TextField("", text: text, prompt: Text(placeholder).foregroundColor(Theme.Payment.textPlaceholder))
                } else {
                    SecureField("", text: text, prompt: Text(placeholder).foregroundColor(Theme.Payment.textPlaceholder))
                }
            }
            .font(.system(size: 20))
            .foregroundColor(Theme.Payment.textHeading)
            .tint(Theme.gold)

            Button(action: { showPassword.toggle() }) {
                Image(systemName: showPassword ? "eye.slash" : "eye")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 8)
        .frame(height: 60)
        .background(Theme.Payment.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var strengthChecklist: some View {
        VStack(alignment: .leading, spacing: 6) {
            checklistRow("8+ characters", strength.hasMinLength)
            checklistRow("Upper & lower case", strength.hasUpperAndLower)
            checklistRow("A number", strength.hasNumber)
            checklistRow("A symbol", strength.hasSymbol)
        }
    }

    private func checklistRow(_ text: String, _ satisfied: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: satisfied ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 13))
                .foregroundColor(satisfied ? Theme.gold : Theme.Payment.textSupporting)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(satisfied ? Theme.Payment.textHeading : Theme.Payment.textSupporting)
        }
    }

    /// Pinned below the ScrollView via `.safeAreaInset(edge: .bottom)` — always visible,
    /// never requires scrolling to reach, and still correctly avoids the keyboard.
    private var footer: some View {
        VStack(spacing: 16) {
            Button(action: didSucceed ? onDone : submit) {
                if authManager.isLoading {
                    ProgressView().tint(Theme.Payment.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                } else {
                    Text(didSucceed ? "Back to Log In" : "Reset Password")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Payment.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                }
            }
            .background(Theme.gold)
            .clipShape(Capsule())
            .disabled(!didSucceed && (!isValid || authManager.isLoading))
            .opacity(didSucceed || isValid ? 1 : 0.5)

            if !didSucceed {
                Button("Cancel", action: onDone)
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Payment.textSupporting)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(Theme.Payment.backgroundPrimary)
    }

    private func submit() {
        guard isValid else { return }
        Task {
            if await authManager.updatePassword(newPassword: password) {
                didSucceed = true
            }
        }
    }
}

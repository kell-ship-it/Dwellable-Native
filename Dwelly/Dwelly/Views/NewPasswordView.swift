import SwiftUI

/// Step 4 of the password-reset flow (docs/PILLAR_AUTHENTICATION_STRATEGY.md §6,
/// "New Password Entry"). Reached only via the `dwelly://auth/reset` deep link — see
/// DwellyApp.onOpenURL — which hands this view a short-lived recovery session already
/// set as the API client's JWT, so `AuthManager.updatePassword()` can call
/// `PUT /auth/v1/user` directly with no re-login required.
struct NewPasswordView: View {
    let accessToken: String
    let refreshToken: String
    var onDone: () -> Void

    @EnvironmentObject var authManager: AuthManager
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var didSucceed = false

    private var strength: PasswordStrength { PasswordStrength(password: password) }
    private var passwordsMatch: Bool { !confirmPassword.isEmpty && password == confirmPassword }
    private var isValid: Bool { strength.isValid && passwordsMatch }

    // Same proportional-offset technique WelcomeView already uses — a fixed pixel value
    // (what shipped first, Nov 4 2026) matches the 874pt Figma mockup but drifts on a real
    // device's actual height, which is exactly what Kell caught comparing screenshots.
    private var screenHeight: CGFloat { UIScreen.main.bounds.height }
    private let successIconTopFraction: CGFloat = 330.0 / 874.0

    var body: some View {
        if didSucceed {
            successView
        } else {
            formView
        }
    }

    /// Matches the Figma design (dwelly-redesign node 1101:300, "Password Reset
    /// (Success)"): icon/title/subtitle sit in the upper-middle area, and the CTA is
    /// pinned to the bottom via the same `.safeAreaInset` footer convention every other
    /// screen in the app uses — NOT vertically centered as one clustered group. Kell
    /// caught this Nov 4 2026: the first version centered the whole VStack, which put
    /// Continue in the middle of the screen instead of its usual fixed bottom position
    /// (same real bug on EmailConfirmedView, checkEmailScreen, and EmailAlreadyExistsView
    /// — all four built from the same donor and fixed together).
    private var successView: some View {
        ZStack(alignment: .top) {
            Theme.Payment.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: screenHeight * successIconTopFraction)

                ZStack {
                    Circle()
                        .fill(Theme.gold)
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Theme.Payment.backgroundPrimary)
                }
                .frame(maxWidth: .infinity)

                Spacer().frame(height: 34)

                Text("Password reset")
                    .font(.system(size: 28, design: .serif))
                    .foregroundColor(Theme.Payment.textHeading)
                    .frame(maxWidth: .infinity)

                Spacer().frame(height: 12)

                Text("Your password has been changed. You're signed in.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .multilineTextAlignment(.center)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 28)
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: onDone) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.Payment.backgroundPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
            }
            .background(Theme.gold)
            .clipShape(Capsule())
            .padding(.horizontal, 28)
            .padding(.top, 16)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity)
            .background(Theme.Payment.backgroundPrimary)
        }
    }

    private var formView: some View {
        ZStack(alignment: .top) {
            Theme.Payment.backgroundPrimary.ignoresSafeArea()

            // Footer is pinned via `.safeAreaInset(edge: .bottom)` — see the note on
            // `footer` (same fix as AccountCreationView/LoginView/ForgotPasswordView,
            // Nov 3 2026).
            ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 130)

                Text("Create new password")
                    .font(.system(size: 28, design: .serif))
                    .foregroundColor(Theme.Payment.textHeading)

                Spacer().frame(height: 16)

                Text("Choose a new password for your account.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer().frame(height: 40)

                fieldLabel("New Password")
                passwordField($password, placeholder: "••••••••", accessibilityLabel: "New Password")

                if !password.isEmpty {
                    Spacer().frame(height: 12)
                    strengthChecklist
                }

                Spacer().frame(height: 18)

                fieldLabel("Confirm Password")
                passwordField($confirmPassword, placeholder: "••••••••", accessibilityLabel: "Confirm Password")
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

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 28)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) { formFooter }
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

    private func passwordField(_ text: Binding<String>, placeholder: String, accessibilityLabel: String) -> some View {
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
            .textContentType(.newPassword)
            .accessibilityLabel(accessibilityLabel)

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

    private var strengthChecklist: some View {
        VStack(alignment: .leading, spacing: 6) {
            checklistRow("8+ characters", strength.hasMinLength)
            checklistRow("Upper & lower case", strength.hasUpperAndLower)
            checklistRow("A number", strength.hasNumber)
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
    /// never requires scrolling to reach, and still correctly avoids the keyboard. Only
    /// used by `formView` now — `successView` has its own simpler footer-less CTA.
    private var formFooter: some View {
        VStack(spacing: 16) {
            Button(action: submit) {
                if authManager.isLoading {
                    ProgressView().tint(Theme.Payment.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                } else {
                    Text("Reset Password")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Payment.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                }
            }
            .background(Theme.gold)
            .clipShape(Capsule())
            .disabled(!isValid || authManager.isLoading)
            .opacity(isValid ? 1 : 0.5)

            Button("Cancel", action: onDone)
                .font(.system(size: 14))
                .foregroundColor(Theme.Payment.textSupporting)
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
            if await authManager.completePasswordReset(
                newPassword: password, accessToken: accessToken, refreshToken: refreshToken
            ) {
                didSucceed = true
            }
        }
    }
}

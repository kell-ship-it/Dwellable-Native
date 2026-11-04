import SwiftUI

/// "Forgot password?" destination from LoginView. No Figma design exists for this screen
/// yet (flagged as a gap in T-240's notes: "Forgot Password has no destination screen") —
/// built here to match the established Returning-User-Login design tokens (same
/// Theme.Payment palette, same field/button components) rather than left as a dead link.
struct ForgotPasswordView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var didSend = false

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Payment.backgroundPrimary.ignoresSafeArea()

            // Footer is pinned via `.safeAreaInset(edge: .bottom)` — see the note on
            // `footer` (same fix as AccountCreationView/LoginView, Nov 3 2026).
            ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 130)

                Text(didSend ? "Check your email" : "Reset your password")
                    .font(.system(size: 28, design: .serif))
                    .foregroundColor(Theme.Payment.textHeading)

                Spacer().frame(height: 16)

                Text(didSend
                     ? "If an account exists for \(email), we've sent a link to reset your password."
                     : "Enter the email on your account and we'll send you a link to reset your password.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .fixedSize(horizontal: false, vertical: true)

                if !didSend {
                    Spacer().frame(height: 40)

                    Text("Email")
                        .font(.system(size: 12, weight: .medium))
                        .tracking(0.3)
                        .foregroundColor(Theme.Payment.textSupporting)
                        .padding(.bottom, 8)

                    TextField("", text: $email, prompt: Text("you@example.com").foregroundColor(Theme.Payment.textPlaceholder))
                        .font(.system(size: 16))
                        .foregroundColor(Theme.Payment.textHeading)
                        .tint(Theme.gold)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.horizontal, 20)
                        .frame(height: 60)
                        .background(Theme.Payment.surfaceCard)
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    if let error = authManager.errorMessage {
                        Spacer().frame(height: 10)
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

            // Scoped to just this button — see AccountCreationView's identical comment.
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.Payment.textHeading)
                    .frame(width: 44, height: 44)
            }
            .padding(.leading, 20)
            .padding(.top, 52)
            .frame(maxWidth: .infinity, alignment: .leading)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }

    /// Pinned below the ScrollView via `.safeAreaInset(edge: .bottom)` — always visible,
    /// never requires scrolling to reach, and still correctly avoids the keyboard.
    private var footer: some View {
        VStack(spacing: 16) {
            if didSend {
                Button(action: { dismiss() }) {
                    Text("Back to Log In")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Payment.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                }
                .background(Theme.gold)
                .clipShape(Capsule())
            } else {
                Button(action: send) {
                    if authManager.isLoading {
                        ProgressView().tint(Theme.Payment.backgroundPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                    } else {
                        Text("Send Reset Link")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.Payment.backgroundPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                    }
                }
                .background(Theme.gold)
                .clipShape(Capsule())
                .disabled(authManager.isLoading || email.isEmpty)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(Theme.Payment.backgroundPrimary)
    }

    private func send() {
        Task {
            if await authManager.requestPasswordReset(email: email) {
                didSend = true
            }
        }
    }
}

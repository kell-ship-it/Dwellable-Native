import SwiftUI

/// Password rules from docs/PILLAR_AUTHENTICATION_STRATEGY.md §6: 8+ chars, upper + lower
/// case, a number, a symbol. Shared by Account Creation and the password-reset flow so both
/// enforce the same rule.
struct PasswordStrength {
    let password: String

    var hasMinLength: Bool { password.count >= 8 }
    var hasUpperAndLower: Bool {
        password.contains(where: { $0.isUppercase }) && password.contains(where: { $0.isLowercase })
    }
    var hasNumber: Bool { password.contains(where: { $0.isNumber }) }
    var hasSymbol: Bool { password.contains(where: { !$0.isLetter && !$0.isNumber }) }

    var isValid: Bool { hasMinLength && hasUpperAndLower && hasNumber && hasSymbol }
    var satisfiedCount: Int { [hasMinLength, hasUpperAndLower, hasNumber, hasSymbol].filter { $0 }.count }
}

/// Onboarding "Account Creation" screen (Figma `dwelly-redesign` node `13:115`,
/// "02 — Account Creation"; full requirements in
/// docs/PILLAR_AUTHENTICATION_STRATEGY.md §6). Reached directly from Welcome's
/// "Get Started" — per Kell's explicit direction (Nov 3, 2026), NOT gated behind the
/// Intro Video. Calls the real `AuthManager.signUp()` (T-109) on submit.
struct AccountCreationView: View {
    var onContinue: () -> Void
    var onSignIn: () -> Void

    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var agreedToTerms = false
    @State private var emailError: String?
    @State private var showTermsPlaceholder = false
    @State private var showCheckEmail = false

    private var strength: PasswordStrength { PasswordStrength(password: password) }
    private var passwordsMatch: Bool { !confirmPassword.isEmpty && password == confirmPassword }
    private var isEmailValid: Bool { email.contains("@") && email.contains(".") }

    private var isValid: Bool {
        isEmailValid && strength.isValid && passwordsMatch && agreedToTerms
    }

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Payment.backgroundPrimary.ignoresSafeArea()

            // The footer is pinned via `.safeAreaInset(edge: .bottom)` below, NOT embedded
            // in this scroll content and NOT a plain overlay. Both earlier attempts had
            // real bugs: a plain overlay ignores the keyboard entirely (the original
            // CTA-covers-field bug), and embedding the footer inline means it scrolls
            // out of view whenever content grows taller than one screen — e.g. the
            // moment the password strength checklist appears, which is exactly when
            // Kell kept seeing "Sign in" clipped. `safeAreaInset` keeps the footer
            // always visible AND lets iOS stack it correctly above the keyboard, since
            // the keyboard is itself implemented as a safe-area inset.
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 130)

                    Text("Create your account")
                        .font(.system(size: 28, design: .serif))
                        .foregroundColor(Theme.Payment.textHeading)

                    Spacer().frame(height: 16)

                    Text("Your moments stay between you and God.\nWe never share your data.")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer().frame(height: 40)

                    fieldLabel("Email")
                    textField(placeholder: "you@example.com", text: $email, error: emailError)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .onChange(of: email) { _ in emailError = nil }

                    if let emailError {
                        Spacer().frame(height: 10)
                        Text(emailError)
                            .font(.system(size: 13))
                            .foregroundColor(Theme.Payment.errorRed)
                    }

                    Spacer().frame(height: 18)

                    fieldLabel("Password")
                    passwordField($password, show: $showPassword, placeholder: "••••••••")

                    if !password.isEmpty {
                        Spacer().frame(height: 12)
                        strengthChecklist
                    }

                    Spacer().frame(height: 18)

                    fieldLabel("Confirm Password")
                    passwordField($confirmPassword, show: $showPassword, placeholder: "••••••••")
                    if !confirmPassword.isEmpty && !passwordsMatch {
                        Spacer().frame(height: 10)
                        Text("Passwords don't match.")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.Payment.errorRed)
                    }

                    Spacer().frame(height: 24)

                    termsCheckbox

                    Spacer().frame(height: 20)

                    Text("🔒 Your data is encrypted and private")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)

                    if let error = authManager.errorMessage {
                        Spacer().frame(height: 14)
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(Theme.Payment.errorRed)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 28)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) { footer }

            // `.ignoresSafeArea(.keyboard)` goes HERE, on the back button alone — not on
            // the whole ZStack. Scoping it to the ZStack (an earlier attempt) also broke
            // the ScrollView's own keyboard-avoidance, which is why Confirm Password
            // became unreachable: the ScrollView no longer knew to reserve room for the
            // keyboard at all. Scoped to just this button, it stays fixed in place while
            // the ScrollView keeps scrolling correctly underneath it.
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
        .sheet(isPresented: $showTermsPlaceholder) {
            placeholderLegalSheet
        }
        .fullScreenCover(isPresented: $showCheckEmail) {
            checkEmailScreen
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

    private func textField(placeholder: String, text: Binding<String>, error: String?) -> some View {
        TextField("", text: text, prompt: Text(placeholder).foregroundColor(Theme.Payment.textPlaceholder))
            .font(.system(size: 16))
            .foregroundColor(Theme.Payment.textHeading)
            .tint(Theme.gold)
            .padding(.horizontal, 20)
            .frame(height: 60)
            .background(Theme.Payment.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(error != nil ? Theme.Payment.errorRed : .clear, lineWidth: 1.5)
            )
    }

    private func passwordField(_ text: Binding<String>, show: Binding<Bool>, placeholder: String) -> some View {
        HStack(spacing: 0) {
            Group {
                if show.wrappedValue {
                    TextField("", text: text, prompt: Text(placeholder).foregroundColor(Theme.Payment.textPlaceholder))
                } else {
                    SecureField("", text: text, prompt: Text(placeholder).foregroundColor(Theme.Payment.textPlaceholder))
                }
            }
            .font(.system(size: 20))
            .foregroundColor(Theme.Payment.textHeading)
            .tint(Theme.gold)

            Button(action: { show.wrappedValue.toggle() }) {
                Image(systemName: show.wrappedValue ? "eye.slash" : "eye")
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

    private var termsCheckbox: some View {
        HStack(alignment: .top, spacing: 10) {
            Button(action: { agreedToTerms.toggle() }) {
                Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18))
                    .foregroundColor(agreedToTerms ? Theme.gold : Theme.Payment.textSupporting)
            }

            // Text/Privacy Policy aren't hosted anywhere yet (confirmed with Kell,
            // Nov 3 2026) — this opens a clearly-labeled placeholder, not a dead link.
            (Text("I agree to the ")
                .foregroundColor(Theme.Payment.textSupporting)
             + Text("Terms").foregroundColor(Theme.Payment.textHeading).underline()
             + Text(" & ").foregroundColor(Theme.Payment.textSupporting)
             + Text("Privacy Policy").foregroundColor(Theme.Payment.textHeading).underline())
                .font(.system(size: 13))
                .onTapGesture { showTermsPlaceholder = true }

            Spacer(minLength: 0)
        }
    }

    private var placeholderLegalSheet: some View {
        VStack(spacing: 16) {
            Text("Terms & Privacy Policy")
                .font(.system(size: 20, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)
            Text("Placeholder — fullyknown LLC's real Terms of Service and Privacy Policy aren't published yet. This will link to the real pages once they exist.")
                .font(.system(size: 14))
                .foregroundColor(Theme.Payment.textSupporting)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Close") { showTermsPlaceholder = false }
                .foregroundColor(Theme.gold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Payment.backgroundPrimary)
    }

    /// Real success state (account exists in auth.users) for the "email confirmation
    /// required" outcome — not an error screen. No Figma design exists for this yet
    /// (this whole code path didn't exist until the Nov 4 2026 decode-error diagnosis);
    /// matches the established auth-screen tokens in the meantime.
    private var checkEmailScreen: some View {
        VStack(spacing: 16) {
            Text("Check your email")
                .font(.system(size: 28, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)
            Text("We sent a confirmation link to \(email). Tap it to finish creating your account, then come back and log in.")
                .font(.system(size: 15))
                .foregroundColor(Theme.Payment.textSupporting)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: {
                showCheckEmail = false
                onSignIn()
            }) {
                Text("Back to Log In")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.Payment.backgroundPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
            }
            .background(Theme.gold)
            .clipShape(Capsule())
            .padding(.horizontal, 28)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Payment.backgroundPrimary)
    }

    // MARK: - Footer

    /// Pinned below the ScrollView via `.safeAreaInset(edge: .bottom)` — always visible,
    /// never requires scrolling to reach, and still correctly avoids the keyboard. See
    /// the comment where it's attached for the two earlier approaches this replaced.
    private var footer: some View {
        VStack(spacing: 16) {
            Button(action: createAccount) {
                if authManager.isLoading {
                    ProgressView().tint(Theme.Payment.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                } else {
                    Text("Create Account")
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

            HStack(spacing: 4) {
                Text("Already have an account?")
                    .foregroundColor(Theme.Payment.textSupporting)
                Button(action: onSignIn) {
                    Text("Sign in")
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.Payment.textHeading)
                }
            }
            .font(.system(size: 14))
        }
        .padding(.horizontal, 28)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(Theme.Payment.backgroundPrimary)
    }

    private func createAccount() {
        guard isEmailValid else {
            emailError = "Enter a valid email address."
            return
        }
        guard strength.isValid else { return }
        guard passwordsMatch else { return }
        guard agreedToTerms else { return }

        Task {
            switch await authManager.signUp(email: email, password: password) {
            case .signedIn:
                onContinue()
            case .pendingEmailConfirmation:
                // Real success — the account exists — just no session until the
                // confirmation link is clicked (this Supabase project requires email
                // confirmation, confirmed Nov 4 2026). No session means onContinue()
                // would be wrong here; there's nothing authenticated to continue into.
                showCheckEmail = true
            case .failure:
                break // authManager.errorMessage is already set and rendered below
            }
        }
    }
}

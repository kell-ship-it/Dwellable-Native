import SwiftUI

/// Password rules per T-248 (locked Oct 8, 2026): 8+ chars, at least 1 uppercase letter, at
/// least 1 number. No symbol requirement — superseded the older
/// docs/PILLAR_AUTHENTICATION_STRATEGY.md §6 draft, which still described a symbol rule.
/// Shared by Account Creation and the password-reset flow so both enforce the same rule.
struct PasswordStrength {
    let password: String

    var hasMinLength: Bool { password.count >= 8 }
    var hasUpperAndLower: Bool {
        password.contains(where: { $0.isUppercase }) && password.contains(where: { $0.isLowercase })
    }
    var hasNumber: Bool { password.contains(where: { $0.isNumber }) }

    var isValid: Bool { hasMinLength && hasUpperAndLower && hasNumber }
    var satisfiedCount: Int { [hasMinLength, hasUpperAndLower, hasNumber].filter { $0 }.count }
}

/// Onboarding "Account Creation" screen (Figma `dwelly-redesign` node `13:115`,
/// "02 — Account Creation"; full requirements in
/// docs/PILLAR_AUTHENTICATION_STRATEGY.md §6). Reached directly from Welcome's
/// "Get Started" — per Kell's explicit direction (Nov 3, 2026), NOT gated behind the
/// Intro Video. Calls the real `AuthManager.signUp()` (T-109) on submit.
struct AccountCreationView: View {
    var onContinue: () -> Void
    var onSignIn: () -> Void

    /// GoTrue's signup-confirmation `{{ .Token }}` is 8 characters for this project — a
    /// different mechanism from (and longer than) the 6-digit code used for magic-link
    /// sign-in, confirmed directly from a real email Nov 5, 2026 ("12920705"). Not
    /// independently configurable from this project's dashboard. The field was hardcoded
    /// to 6 and silently truncating every real code, so every verification attempt failed
    /// — if GoTrue's length ever changes, this is the one place to update.
    private static let otpCodeLength = 8

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
    @State private var showEmailAlreadyExists = false
    @State private var otpCode = ""
    @State private var resendSent = false
    @State private var verificationSucceeded = false

    private var strength: PasswordStrength { PasswordStrength(password: password) }
    private var passwordsMatch: Bool { !confirmPassword.isEmpty && password == confirmPassword }

    /// Traditional `something@something.something` shape only — one "@", a domain with at
    /// least one "." after it, no spaces. Not a real deliverability check (no provider/DNS
    /// lookup, no confirmation email sent before signup) — per Kell's explicit direction
    /// (Nov 4, 2026), format is all the Create Account button should gate on.
    private var isEmailValid: Bool {
        let pattern = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    private var isValid: Bool {
        isEmailValid && strength.isValid && passwordsMatch && agreedToTerms
    }

    // Same proportional-offset technique WelcomeView already uses — a fixed pixel value
    // (what shipped first, Nov 4 2026) matches the 874pt Figma mockup but drifts on a real
    // device's actual height, which is exactly what Kell caught comparing screenshots.

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
                    textField(placeholder: "you@example.com", text: $email, error: emailError, accessibilityLabel: "Email")
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
                    passwordField($password, show: $showPassword, placeholder: "••••••••", accessibilityLabel: "Password")

                    if !password.isEmpty {
                        Spacer().frame(height: 12)
                        strengthChecklist
                    }

                    Spacer().frame(height: 18)

                    fieldLabel("Confirm Password")
                    passwordField($confirmPassword, show: $showPassword, placeholder: "••••••••", accessibilityLabel: "Confirm Password")
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
            .accessibilityLabel("Back")
            .padding(.leading, 20)
            .padding(.top, 52)
            .frame(maxWidth: .infinity, alignment: .leading)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .sheet(isPresented: $showTermsPlaceholder) {
            placeholderLegalSheet
        }
        .fullScreenCover(isPresented: $showCheckEmail) {
            if verificationSucceeded {
                successScreen
            } else {
                checkEmailScreen
            }
        }
        .fullScreenCover(isPresented: $showEmailAlreadyExists) {
            EmailAlreadyExistsView(
                email: email,
                onLogIn: {
                    showEmailAlreadyExists = false
                    onSignIn()
                },
                onUseDifferentEmail: {
                    showEmailAlreadyExists = false
                    email = ""
                }
            )
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

    private func textField(placeholder: String, text: Binding<String>, error: String?, accessibilityLabel: String) -> some View {
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
            // A placeholder alone disappears once the user types, leaving VoiceOver with
            // nothing — this is the field's real, persistent label.
            .accessibilityLabel(accessibilityLabel)
    }

    private func passwordField(_ text: Binding<String>, show: Binding<Bool>, placeholder: String, accessibilityLabel: String) -> some View {
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
            .textContentType(.newPassword)
            .accessibilityLabel(accessibilityLabel)

            Button(action: { show.wrappedValue.toggle() }) {
                Image(systemName: show.wrappedValue ? "eye.slash" : "eye")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(show.wrappedValue ? "Hide password" : "Show password")
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

    private var termsCheckbox: some View {
        HStack(alignment: .top, spacing: 10) {
            Button(action: { agreedToTerms.toggle() }) {
                Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18))
                    .foregroundColor(agreedToTerms ? Theme.gold : Theme.Payment.textSupporting)
            }
            // Not resized to the usual 44×44 hit area — that would shift this HStack's
            // locked layout (checkbox glyph + inline text). Flagged separately in the
            // Redesign Principles checklist's Tap Targets section, not fixed here.
            .accessibilityLabel("Agree to Terms & Privacy Policy")
            .accessibilityValue(agreedToTerms ? "Checked" : "Not checked")
            .accessibilityAddTraits(.isButton)

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
    /// required" outcome — not an error screen.
    ///
    /// Rebuilt Nov 5, 2026 as a code entry (see `otpCodeLength`), replacing the old "tap the link in
    /// your email" magic-link flow entirely. Root cause, confirmed directly in Supabase's
    /// own auth logs: the magic link's one-time token was being hit twice in the same
    /// second — Gmail's link-scanner silently prefetching it before Kell ever tapped,
    /// consuming it, so his real tap always landed on "link expired." A code the user
    /// types by hand can't be pre-fetched by a mail client. Requires the Supabase "Confirm
    /// signup" email template to send `{{ .Token }}` (the code) rather than
    /// `{{ .ConfirmationURL }}` — a dashboard change, not something this app controls.
    private var checkEmailScreen: some View {
        ZStack(alignment: .top) {
            Theme.Payment.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Theme.gold)
                        .frame(width: 80, height: 80)
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Theme.Payment.backgroundPrimary)
                }
                .frame(maxWidth: .infinity)

                Spacer().frame(height: 34)

                Text("Check your email")
                    .font(.system(size: 28, design: .serif))
                    .foregroundColor(Theme.Payment.textHeading)
                    .frame(maxWidth: .infinity)

                Spacer().frame(height: 12)

                VStack(spacing: 2) {
                    Text("We sent a code to")
                    Text(email)
                        .foregroundColor(Theme.Payment.textHeading)
                    Text("Enter it below to finish creating your account.")
                }
                .font(.system(size: 15))
                .foregroundColor(Theme.Payment.textSupporting)
                .multilineTextAlignment(.center)

                Spacer().frame(height: 32)

                TextField("", text: $otpCode, prompt: Text(String(repeating: "0", count: Self.otpCodeLength)).foregroundColor(Theme.Payment.textPlaceholder))
                    .font(.system(size: 28, weight: .semibold, design: .monospaced))
                    .foregroundColor(Theme.Payment.textHeading)
                    .tint(Theme.gold)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .frame(height: 60)
                    .frame(maxWidth: 260)
                    .background(Theme.Payment.surfaceCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .onChange(of: otpCode) { newValue in
                        let digitsOnly = newValue.filter(\.isNumber)
                        otpCode = String(digitsOnly.prefix(Self.otpCodeLength))
                    }

                if let error = authManager.errorMessage {
                    Spacer().frame(height: 12)
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.Payment.errorRed)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)
                }

                Spacer().frame(height: 16)

                Button(action: resendCode) {
                    Text(resendSent ? "Code sent" : "Didn't get a code? Resend")
                        .font(.system(size: 14))
                        .foregroundColor(resendSent ? Theme.Payment.textSupporting : Theme.gold)
                }
                .disabled(resendSent)

                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 16) {
                Button(action: verifyCode) {
                    if authManager.isLoading {
                        ProgressView().tint(Theme.Payment.backgroundPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                    } else {
                        Text("Verify & Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.Payment.backgroundPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                    }
                }
                .background(Theme.gold)
                .clipShape(Capsule())
                .disabled(otpCode.count != Self.otpCodeLength || authManager.isLoading)
                .opacity(otpCode.count != Self.otpCodeLength ? 0.5 : 1)

                Button(action: {
                    showCheckEmail = false
                    onSignIn()
                }) {
                    Text("Back to Log In")
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
    }

    /// Real, visible confirmation that the OTP verified and the account is real — added
    /// Nov 5, 2026 per Kell's catch: the old flow just dismissed this cover and relied on
    /// `isAuthenticated` flipping to silently swap the whole root view underneath, giving
    /// no on-screen acknowledgment that anything happened. "Continue" here is the one and
    /// only thing that calls `onContinue()`, carrying the user into Intro Video next.
    private var successScreen: some View {
        ZStack(alignment: .top) {
            Theme.Payment.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Theme.gold)
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Theme.Payment.backgroundPrimary)
                }
                .frame(maxWidth: .infinity)

                Spacer().frame(height: 34)

                Text("You're in.")
                    .font(.system(size: 28, design: .serif))
                    .foregroundColor(Theme.Payment.textHeading)
                    .frame(maxWidth: .infinity)

                Spacer().frame(height: 12)

                Text("Your account is ready. Let's get you set up.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                showCheckEmail = false
                authManager.finalizeSignup()
                onContinue()
            }) {
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

    private func verifyCode() {
        Task {
            if await authManager.verifySignupOTP(email: email, token: otpCode) {
                // A real success state (see successScreen below), not an invisible
                // auto-transition into AppView/Intro Video — Kell caught Nov 5, 2026 that
                // the old "just dismiss and let isAuthenticated flip the root view" approach
                // gave no visible confirmation that anything happened. withAnimation since
                // this is a same-cover content swap, not a new cover presentation.
                withAnimation { verificationSucceeded = true }
            }
        }
    }

    private func resendCode() {
        Task {
            if await authManager.resendSignupConfirmation(email: email) {
                resendSent = true
            }
        }
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
            case .emailAlreadyExists:
                showEmailAlreadyExists = true
            case .failure:
                break // authManager.errorMessage is already set and rendered below
            }
        }
    }
}

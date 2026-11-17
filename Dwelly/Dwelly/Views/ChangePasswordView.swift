import SwiftUI

/// T-131: real password change for an already-signed-in user, confirmed via a real email
/// OTP instead of re-typing the current password (Kell's direct call, Nov 16 2026, after
/// weighing Apple's/NIST 800-63B's actual standard -- re-authenticate before a sensitive
/// change, notify after -- against WCAG, which has nothing to say about this at all since
/// it's an accessibility spec, not a security one). The OTP proves control of the
/// account's email, same identity signal a re-typed password would prove, just over a
/// second channel instead of a memorized secret.
///
/// Reuses GoTrue's existing email-OTP mechanism end to end: `sendPasswordChangeOTP`
/// (`/auth/v1/otp`, `type` implicit "email") and `verifyPasswordChangeOTP` (`/auth/v1/verify`,
/// `type: "email"`) -- the same `/verify` endpoint `AccountCreationView` already uses for
/// signup, just a different `type`, not new infrastructure. The OTP entry UI below mirrors
/// `AccountCreationView`'s own code-entry screen (digit-only TextField, resend link) rather
/// than inventing a new pattern for the same real flow.
struct ChangePasswordView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.apiClient) private var apiClient
    @Environment(\.dismiss) var dismiss

    private enum Stage {
        case enterNewPassword
        case enterCode
        case success
    }

    private static let otpCodeLength = 6

    @State private var stage: Stage = .enterNewPassword
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var otpCode = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var resendSent = false

    private var isNewPasswordValid: Bool {
        newPassword.count >= 8 && newPassword == confirmPassword
    }

    private var isCodeValid: Bool {
        otpCode.count == Self.otpCodeLength
    }

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Payment.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 72)

                    switch stage {
                    case .enterNewPassword:
                        newPasswordStage
                    case .enterCode:
                        codeStage
                    case .success:
                        successStage
                    }
                }
                .padding(.horizontal, 20)
            }
            .scrollDismissesKeyboard(.interactively)

            header
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Stages

    private var newPasswordStage: some View {
        VStack(alignment: .leading, spacing: 0) {
            field(label: "New Password", text: $newPassword)
            Spacer().frame(height: 20)
            field(label: "Confirm New Password", text: $confirmPassword)

            if let errorMessage {
                Spacer().frame(height: 12)
                Text(errorMessage)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Payment.errorRed)
            }

            Spacer().frame(height: 24)

            primaryButton(title: "Send Confirmation Code", disabled: !isNewPasswordValid, action: sendCode)
        }
    }

    private var codeStage: some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                Text("We sent a code to")
                Text(authManager.currentUser?.email ?? "")
                    .foregroundColor(Theme.Payment.textHeading)
                Text("Enter it below to confirm your new password.")
            }
            .font(.system(size: 15))
            .foregroundColor(Theme.Payment.textSupporting)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)

            Spacer().frame(height: 32)

            TextField("", text: $otpCode, prompt: Text(String(repeating: "0", count: Self.otpCodeLength)).foregroundColor(Theme.Payment.textPlaceholder))
                .font(.system(size: 28, weight: .semibold, design: .monospaced))
                .foregroundColor(Theme.Payment.textHeading)
                .tint(Theme.gold)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Theme.Payment.surfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .onChange(of: otpCode) { newValue in
                    let digitsOnly = newValue.filter(\.isNumber)
                    otpCode = String(digitsOnly.prefix(Self.otpCodeLength))
                }

            if let errorMessage {
                Spacer().frame(height: 12)
                Text(errorMessage)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Payment.errorRed)
                    .multilineTextAlignment(.center)
            }

            Spacer().frame(height: 16)

            Button(action: resendCode) {
                Text(resendSent ? "Code sent" : "Didn't get a code? Resend")
                    .font(.system(size: 14))
                    .foregroundColor(resendSent ? Theme.Payment.textSupporting : Theme.gold)
            }
            .disabled(resendSent)

            Spacer().frame(height: 24)

            primaryButton(title: "Confirm", disabled: !isCodeValid, action: confirmCode)
        }
    }

    private var successStage: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password updated")
                .font(.system(size: 22, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)
            Text("Your password has been changed.")
                .font(.system(size: 15))
                .foregroundColor(Theme.Payment.textSupporting)
        }
    }

    // MARK: - Shared pieces

    private var header: some View {
        HStack(spacing: 4) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.Payment.textHeading)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Back")

            Text("Change Password")
                .font(.system(size: 20, weight: .regular, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .background(Theme.Payment.background)
    }

    private func field(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .tracking(0.3)
                .foregroundColor(Theme.Payment.textSupporting)

            SecureField("", text: text)
                .font(.system(size: 16))
                .foregroundColor(Theme.Payment.textHeading)
                .tint(Theme.gold)
                .textContentType(.newPassword)
                .padding(.horizontal, 20)
                .frame(height: 56)
                .background(Theme.Payment.surfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .accessibilityLabel(label)
    }

    private func primaryButton(title: String, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            if isSubmitting {
                ProgressView().tint(Theme.Payment.backgroundPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            } else {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.Payment.backgroundPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
        }
        .background(Theme.gold)
        .clipShape(Capsule())
        .disabled(isSubmitting || disabled)
        .opacity(disabled ? 0.5 : 1)
    }

    // MARK: - Actions

    private func sendCode() {
        guard let email = authManager.currentUser?.email else { return }
        errorMessage = nil
        isSubmitting = true
        Task {
            do {
                try await apiClient.sendPasswordChangeOTP(email: email)
                await MainActor.run {
                    isSubmitting = false
                    stage = .enterCode
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = "Couldn't send a code — check your connection and try again."
                }
            }
        }
    }

    private func resendCode() {
        guard let email = authManager.currentUser?.email else { return }
        resendSent = true
        Task { try? await apiClient.sendPasswordChangeOTP(email: email) }
    }

    private func confirmCode() {
        guard let email = authManager.currentUser?.email else { return }
        errorMessage = nil
        isSubmitting = true
        Task {
            do {
                _ = try await apiClient.verifyPasswordChangeOTP(email: email, token: otpCode)
                try await apiClient.updatePassword(newPassword: newPassword)
                await MainActor.run {
                    isSubmitting = false
                    stage = .success
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = "That code is invalid or expired. Please try again."
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChangePasswordView()
    }
    .environment(\.apiClient, MockAPIClient())
    .environmentObject(AuthManager(apiClient: MockAPIClient()))
}

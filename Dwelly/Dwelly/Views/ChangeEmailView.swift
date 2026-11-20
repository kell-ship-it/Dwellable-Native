import SwiftUI

/// T-250: Change Email flow (Scenario 14, Figma Oct 21 2026). Collects the new email +
/// current password as identity confirmation (per the locked design's own copy), then
/// hands off to GoTrue's own built-in email-change confirmation flow (`PUT /auth/v1/user`
/// with a new `email`) rather than parallelling T-131's custom OTP system -- GoTrue
/// already sends a confirmation link to the new address itself and leaves the signed-in
/// account's current email active until that link is clicked, which is exactly what the
/// design specifies. No new backend infrastructure needed beyond that one call.
///
/// Re-auth uses the current password (`apiClient.login`), not an email OTP, because
/// that's what Scenario 14's design literally asks for -- unlike T-131's Change Password,
/// which traded its original password re-auth for an OTP as a separate, later decision
/// specific to that screen.
struct ChangeEmailView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.apiClient) private var apiClient
    @Environment(\.dismiss) var dismiss

    private enum Stage {
        case form
        case success
    }

    @State private var stage: Stage = .form
    @State private var newEmail = ""
    @State private var currentPassword = ""
    @State private var showPassword = false
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private var isFormValid: Bool {
        newEmail.contains("@") && newEmail.contains(".") &&
        !currentPassword.isEmpty &&
        newEmail.lowercased() != (authManager.currentUser?.email.lowercased() ?? "")
    }

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Payment.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 72)

                    switch stage {
                    case .form:
                        formStage
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
        .safeAreaInset(edge: .bottom) { bottomCTA }
    }

    @ViewBuilder
    private var bottomCTA: some View {
        switch stage {
        case .form:
            primaryButton(title: "Send Verification Link", disabled: !isFormValid, action: submit)
        case .success:
            primaryButton(title: "Done", disabled: false, action: { dismiss() })
        }
    }

    // MARK: - Stages

    private var formStage: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Current email")
                .font(.system(size: 12, weight: .medium))
                .tracking(0.3)
                .foregroundColor(Theme.Payment.textSupporting)
            Text(authManager.currentUser?.email ?? "")
                .font(.system(size: 16))
                .foregroundColor(Theme.Payment.textHeading)
                .padding(.top, 4)

            Spacer().frame(height: 24)

            emailField
            Spacer().frame(height: 20)
            passwordField

            Spacer().frame(height: 12)
            Text("We'll send a verification link to your new email. Your current email stays active until you confirm it.")
                .font(.system(size: 13))
                .foregroundColor(Theme.Payment.textSupporting)

            if let errorMessage {
                Spacer().frame(height: 12)
                Text(errorMessage)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Payment.errorRed)
            }
        }
    }

    private var successStage: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Check your new email")
                .font(.system(size: 22, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)
            Text("We sent a verification link to \(newEmail). Your current email stays active until you confirm the change.")
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

            Text("Change Email")
                .font(.system(size: 20, weight: .regular, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .background(Theme.Payment.background)
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("New Email")
                .font(.system(size: 12, weight: .medium))
                .tracking(0.3)
                .foregroundColor(Theme.Payment.textSupporting)

            TextField("", text: $newEmail)
                .font(.system(size: 16))
                .foregroundColor(Theme.Payment.textHeading)
                .tint(Theme.gold)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityLabel("New Email")
                .padding(.horizontal, 20)
                .frame(height: 56)
                .background(Theme.Payment.surfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Password")
                .font(.system(size: 12, weight: .medium))
                .tracking(0.3)
                .foregroundColor(Theme.Payment.textSupporting)

            HStack(spacing: 0) {
                Group {
                    if showPassword {
                        TextField("", text: $currentPassword)
                    } else {
                        SecureField("", text: $currentPassword)
                    }
                }
                .font(.system(size: 16))
                .foregroundColor(Theme.Payment.textHeading)
                .tint(Theme.gold)
                .textContentType(.password)
                .accessibilityLabel("Current Password")

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
            .frame(height: 56)
            .background(Theme.Payment.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
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
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .background(Theme.Payment.background)
    }

    // MARK: - Actions

    private func submit() {
        guard let currentEmail = authManager.currentUser?.email else { return }
        errorMessage = nil
        isSubmitting = true
        Task {
            do {
                // Identity confirmation: re-auth with the current password before
                // changing anything, same "prove you are who you say you are first"
                // idea T-131's re-auth check used, just via password here since
                // that's what the locked design's own copy asks for.
                _ = try await apiClient.login(email: currentEmail, password: currentPassword)
                try await apiClient.requestEmailChange(newEmail: newEmail)
                await MainActor.run {
                    isSubmitting = false
                    stage = .success
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = "That password doesn't match, or the request failed. Please try again."
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChangeEmailView()
    }
    .environment(\.apiClient, MockAPIClient())
    .environmentObject(AuthManager(apiClient: MockAPIClient()))
}

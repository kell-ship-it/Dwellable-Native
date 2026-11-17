import SwiftUI

/// T-131: real password change for an already-signed-in user. `AuthManager.updatePassword`
/// already existed (built for the recovery-link deep-link flow) and needs no current-password
/// check itself -- GoTrue's `PUT /auth/v1/user` only needs a valid session JWT. Re-verifying
/// the current password here anyway, via a real `apiClient.login` call before updating, since
/// a user who stepped away from an unlocked device shouldn't be able to silently take over
/// the password with no proof they know the old one.
struct ChangePasswordView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.apiClient) private var apiClient
    @Environment(\.dismiss) var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var didSucceed = false

    private var isValid: Bool {
        !currentPassword.isEmpty && newPassword.count >= 8 && newPassword == confirmPassword
    }

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Payment.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 72)

                    if didSucceed {
                        Text("Password updated")
                            .font(.system(size: 22, design: .serif))
                            .foregroundColor(Theme.Payment.textHeading)
                        Spacer().frame(height: 8)
                        Text("Your password has been changed.")
                            .font(.system(size: 15))
                            .foregroundColor(Theme.Payment.textSupporting)
                    } else {
                        field(label: "Current Password", text: $currentPassword)
                        Spacer().frame(height: 20)
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

                        Button(action: submit) {
                            if isSubmitting {
                                ProgressView().tint(Theme.Payment.backgroundPrimary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                            } else {
                                Text("Update Password")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Theme.Payment.backgroundPrimary)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                            }
                        }
                        .background(Theme.gold)
                        .clipShape(Capsule())
                        .disabled(isSubmitting || !isValid)
                        .opacity(isValid ? 1 : 0.5)
                    }
                }
                .padding(.horizontal, 20)
            }
            .scrollDismissesKeyboard(.interactively)

            header
        }
        .navigationBarBackButtonHidden(true)
    }

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
                .textContentType(.none)
                .padding(.horizontal, 20)
                .frame(height: 56)
                .background(Theme.Payment.surfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .accessibilityLabel(label)
    }

    private func submit() {
        guard let email = authManager.currentUser?.email else { return }
        errorMessage = nil
        isSubmitting = true
        Task {
            do {
                // Re-auth check: wrong current password throws here, before anything changes.
                _ = try await apiClient.login(email: email, password: currentPassword)
                try await apiClient.updatePassword(newPassword: newPassword)
                await MainActor.run {
                    isSubmitting = false
                    didSucceed = true
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = "Current password is incorrect, or the update failed. Please try again."
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

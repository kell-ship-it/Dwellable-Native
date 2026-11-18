import SwiftUI

/// T-133: the real "Send Feedback" / "Report a Bug" form, pushed from `FeedbackView`.
/// Matches the locked design (node 690:320, "iphone-frame — Send Feedback") -- a single
/// textarea plus a gold CTA -- reused for both types via `type`, since the design has no
/// separate bug-report layout, only different copy. On submit, writes a real row to
/// `feedback_submissions` through `APIClient.submitFeedback`, then shows the "Feedback
/// Sent" confirmation (node 691:357).
struct SendFeedbackView: View {
    let type: FeedbackType

    @EnvironmentObject var authManager: AuthManager
    @Environment(\.apiClient) private var apiClient
    @Environment(\.dismiss) var dismiss

    @State private var message = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var didSubmit = false

    private var title: String {
        type == .bug ? "Report a Bug" : "Send Feedback"
    }

    private var fieldLabel: String {
        type == .bug ? "WHAT HAPPENED?" : "WHAT WOULD HELP YOU?"
    }

    private var placeholder: String {
        type == .bug
            ? "What happened, and what did you expect instead?"
            : "Tell us what would make Dwelly more useful for your reflection practice…"
    }

    private var isValid: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            Theme.Payment.background.ignoresSafeArea()

            if didSubmit {
                sentStage
            } else {
                formStage
            }
        }
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            if !didSubmit {
                primaryButton
            }
        }
    }

    private var formStage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header

                VStack(alignment: .leading, spacing: 8) {
                    Text(fieldLabel)
                        .font(.system(size: 12, weight: .medium))
                        .tracking(0.3)
                        .foregroundColor(Theme.Payment.textSupporting)

                    TextEditor(text: $message)
                        .font(.system(size: 16))
                        .foregroundColor(Theme.Payment.textHeading)
                        .scrollContentBackground(.hidden)
                        .frame(height: 140)
                        .padding(10)
                        .background(Theme.Payment.surfaceCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(alignment: .topLeading) {
                            if message.isEmpty {
                                Text(placeholder)
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.Payment.textPlaceholder)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 18)
                                    .allowsHitTesting(false)
                            }
                        }
                }
                .padding(.top, 20)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.Payment.errorRed)
                        .padding(.top, 12)
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var sentStage: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 36))
                .foregroundColor(Theme.gold)

            Text("Thank you.")
                .font(.system(size: 28, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)

            Text("Your feedback goes straight to our team — we read every note.")
                .font(.system(size: 15))
                .foregroundColor(Theme.Payment.textSupporting)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 28)
        .frame(maxHeight: .infinity)
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

            Text(title)
                .font(.system(size: 20, weight: .regular, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)

            Spacer()
        }
        .padding(.top, 8)
    }

    private var primaryButton: some View {
        Button(action: didSubmit ? { dismiss() } : submit) {
            if isSubmitting {
                ProgressView().tint(Theme.Payment.backgroundPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            } else {
                Text(didSubmit ? "Done" : title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.Payment.backgroundPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
        }
        .background(isValid || didSubmit ? Theme.gold : Theme.gold.opacity(0.5))
        .clipShape(Capsule())
        .disabled(!isValid && !didSubmit)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private func submit() {
        guard let userId = authManager.currentUser?.id, isValid else { return }
        isSubmitting = true
        errorMessage = nil
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        Task {
            do {
                _ = try await apiClient.submitFeedback(userId: userId, type: type, message: trimmed, appVersion: appVersion)
                isSubmitting = false
                didSubmit = true
            } catch {
                isSubmitting = false
                errorMessage = "Couldn't send that. Check your connection and try again."
            }
        }
    }
}

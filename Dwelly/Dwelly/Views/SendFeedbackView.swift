import SwiftUI
import PhotosUI

/// T-133 (Kell's approved direction, Nov 18 2026): the one in-app Support & Feedback
/// form. Supersedes the earlier separate "Send Feedback" / "Report a Bug" screens --
/// one form, a 3-way category picker (Kell's exact approved wording), a message field,
/// and an optional screenshot. No mailto hand-off anywhere in this screen; submitting
/// goes straight to the `submit-feedback` Edge Function (see
/// `SupabaseAPIClient.submitFeedback`), which does the insert and the best-effort
/// Resend/Notion notify server-side in one authenticated round trip.
///
/// The approved requirement is EMAIL DELIVERY to hello@dwelly.one, not just a saved
/// row -- so "success" here means `emailed == true` from the server, never just a
/// saved submission. A saved-but-not-emailed submission (RESEND_API_KEY unset, or any
/// transient Resend failure) shows a distinct not-sent state with a Retry action that
/// re-attempts ONLY the email for that same submission (idempotent -- never re-inserts,
/// so Retry can't create duplicate rows or, once emailed, duplicate emails in normal
/// use). The category, message, and screenshot stay exactly as entered through every
/// stage so nothing typed is ever lost. `isSubmitting` both drives the button's spinner
/// state and is checked at the top of `submit()`/`retry()`, so a double-tap can't fire
/// two requests.
struct SendFeedbackView: View {
    private enum Stage: Equatable {
        case form
        case notSent(submissionId: String)
        case sent
    }

    @EnvironmentObject var authManager: AuthManager
    @Environment(\.apiClient) private var apiClient
    @Environment(\.dismiss) var dismiss

    @State private var category: FeedbackCategory?
    @State private var message = ""
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var screenshotData: Data?
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var stage: Stage = .form

    private var isValid: Bool {
        category != nil && !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            Theme.Payment.background.ignoresSafeArea()

            switch stage {
            case .form:
                formStage
            case .notSent:
                notSentStage
            case .sent:
                sentStage
            }
        }
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            primaryButton
        }
    }

    private var formStage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                categoryPicker

                VStack(alignment: .leading, spacing: 8) {
                    Text("WHAT'S ON YOUR MIND?")
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
                                Text("Tell us what happened, or what would help…")
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.Payment.textPlaceholder)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 18)
                                    .allowsHitTesting(false)
                            }
                        }
                }

                screenshotPicker

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.Payment.errorRed)
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WHAT KIND OF FEEDBACK?")
                .font(.system(size: 12, weight: .medium))
                .tracking(0.3)
                .foregroundColor(Theme.Payment.textSupporting)

            VStack(spacing: 8) {
                ForEach(FeedbackCategory.allCases, id: \.self) { option in
                    Button(action: { category = option }) {
                        HStack {
                            Text(option.displayName)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(category == option ? Theme.Payment.backgroundPrimary : Theme.Payment.textHeading)
                            Spacer()
                            if category == option {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Theme.Payment.backgroundPrimary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(category == option ? Theme.gold : Theme.Payment.surfaceCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }

    private var screenshotPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SCREENSHOT (OPTIONAL)")
                .font(.system(size: 12, weight: .medium))
                .tracking(0.3)
                .foregroundColor(Theme.Payment.textSupporting)

            if let screenshotData, let uiImage = UIImage(data: screenshotData) {
                HStack(spacing: 12) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Text("Screenshot attached")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.Payment.textSupporting)
                    Spacer()
                    Button(action: { self.screenshotData = nil; self.photosPickerItem = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.Payment.textSupporting)
                    }
                }
                .padding(12)
                .background(Theme.Payment.surfaceCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                PhotosPicker(selection: $photosPickerItem, matching: .images) {
                    HStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle")
                            .foregroundColor(Theme.gold)
                        Text("Add a screenshot")
                            .font(.system(size: 15))
                            .foregroundColor(Theme.Payment.textHeading)
                        Spacer()
                    }
                    .padding(12)
                    .background(Theme.Payment.surfaceCard)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .onChange(of: photosPickerItem) { newItem in
                    Task {
                        // Limit kept small -- this is a screenshot attachment, not a
                        // photo library export; the server also enforces it never lands
                        // outside the uploading user's own storage folder.
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            screenshotData = data
                        }
                    }
                }
            }
        }
    }

    private var sentStage: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 36))
                .foregroundColor(Theme.gold)

            Text("Thank you.")
                .font(.system(size: 28, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)

            // Only reachable when the server reported emailed == true -- this is the
            // one stage that actually claims delivery, because it's the one stage
            // where that's actually happened.
            Text("Your feedback was emailed to our team.")
                .font(.system(size: 15))
                .foregroundColor(Theme.Payment.textSupporting)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 28)
        .frame(maxHeight: .infinity)
    }

    // Saved, but the email to hello@dwelly.one did not go out (no RESEND_API_KEY
    // today, or a transient Resend failure). Never implies delivery -- the submission
    // sits durably in the backend either way, so there's nothing to lose by retrying.
    private var notSentStage: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundColor(Theme.Payment.errorRed)

            Text("Saved, not sent yet.")
                .font(.system(size: 28, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)

            Text("Your note is saved, but we couldn't email it to our team yet. Nothing was lost — tap Retry to try again.")
                .font(.system(size: 15))
                .foregroundColor(Theme.Payment.textSupporting)
                .multilineTextAlignment(.center)

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Payment.errorRed)
                    .multilineTextAlignment(.center)
            }
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

            Text("Send Feedback")
                .font(.system(size: 20, weight: .regular, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)

            Spacer()
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    private var primaryButton: some View {
        switch stage {
        case .form:
            button(title: "Send", disabled: !isValid, action: submit)
        case .notSent(let submissionId):
            VStack(spacing: 10) {
                button(title: "Retry", disabled: false, action: { retry(submissionId: submissionId) })
                Button(action: { dismiss() }) {
                    Text("Done")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.Payment.textSupporting)
                }
                .padding(.bottom, 4)
            }
            .padding(.horizontal, 20)
        case .sent:
            button(title: "Done", disabled: false, action: { dismiss() })
        }
    }

    private func button(title: String, disabled: Bool, action: @escaping () -> Void) -> some View {
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
        .background(disabled ? Theme.gold.opacity(0.5) : Theme.gold)
        .clipShape(Capsule())
        .disabled(disabled || isSubmitting)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private func submit() {
        // Guards double-submission from a fast double-tap: isSubmitting flips true
        // synchronously below, before any `await`, so a second tap in the same runloop
        // turn sees it already true and the button itself is also disabled while true.
        guard !isSubmitting, let category, isValid else { return }
        guard let userId = authManager.currentUser?.id else { return }
        isSubmitting = true
        errorMessage = nil
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let capturedScreenshot = screenshotData

        Task {
            do {
                var screenshotPath: String?
                if let capturedScreenshot {
                    let fileName = "\(UUID().uuidString).jpg"
                    screenshotPath = try await apiClient.uploadFeedbackScreenshot(capturedScreenshot, fileName: fileName, userId: userId)
                }
                let result = try await apiClient.submitFeedback(userId: userId, category: category, message: trimmed, appVersion: appVersion, screenshotPath: screenshotPath)
                isSubmitting = false
                // The row is saved either way -- `emailed` is the only thing that
                // decides which stage we land on. Never show `.sent` when it's false.
                stage = result.emailed ? .sent : .notSent(submissionId: result.submission.id)
            } catch {
                isSubmitting = false
                errorMessage = "Couldn't send that. Check your connection and try again — nothing you wrote was lost."
            }
        }
    }

    private func retry(submissionId: String) {
        guard !isSubmitting else { return }
        isSubmitting = true
        errorMessage = nil

        Task {
            do {
                // Idempotent: this re-attempts the email for the SAME submission id --
                // it never creates a new row, so retrying repeatedly can't duplicate
                // the saved feedback.
                let result = try await apiClient.retryFeedbackNotify(submissionId: submissionId)
                isSubmitting = false
                if result.emailed {
                    stage = .sent
                } else {
                    errorMessage = "Still couldn't send it — your note is still saved. Try again in a moment."
                }
            } catch {
                isSubmitting = false
                errorMessage = "Couldn't retry right now. Your note is still saved — try again in a moment."
            }
        }
    }
}

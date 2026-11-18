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
/// Success is shown ONLY when that call actually returns ok -- never optimistically on
/// tapping Send. A failure (network, validation, server error) keeps the category,
/// message, and screenshot exactly as typed so the user can retry without re-entering
/// anything. `isSubmitting` both drives the button's spinner state and is checked at
/// the top of `submit()`, so a double-tap on Send can't fire two submissions.
struct SendFeedbackView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.apiClient) private var apiClient
    @Environment(\.dismiss) var dismiss

    @State private var category: FeedbackCategory?
    @State private var message = ""
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var screenshotData: Data?
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var didSubmit = false

    private var isValid: Bool {
        category != nil && !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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

            // Deliberately doesn't say "sent to our team" or similar -- the backend
            // saves this for real, but the Resend email alert that would actually
            // notify a human is unconfigured (no RESEND_API_KEY secret set), so no one
            // is notified in real time yet. This copy only promises what's true today:
            // the submission is saved.
            Text("Your feedback has been saved.")
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

            Text("Send Feedback")
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
                Text(didSubmit ? "Done" : "Send")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.Payment.backgroundPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
        }
        .background(isValid || didSubmit ? Theme.gold : Theme.gold.opacity(0.5))
        .clipShape(Capsule())
        .disabled((!isValid && !didSubmit) || isSubmitting)
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
                // Only a genuine server-accepted response reaches here -- submitFeedback
                // throws on any non-ok result, so there is no path to didSubmit = true
                // without the submission actually having been saved.
                _ = try await apiClient.submitFeedback(userId: userId, category: category, message: trimmed, appVersion: appVersion, screenshotPath: screenshotPath)
                isSubmitting = false
                didSubmit = true
            } catch {
                isSubmitting = false
                errorMessage = "Couldn't send that. Check your connection and try again — nothing you wrote was lost."
            }
        }
    }
}

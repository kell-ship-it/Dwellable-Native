import SwiftUI

struct ReviewView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var transcriptionManager = TranscriptionManager()
    @State private var momentBody: String = ""
    @State private var senseOfLord: String = ""
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var isSyncPending = false

    let audioURL: URL?
    let apiClient: APIClient
    let userId: String
    let syncManager: SyncManager
    var onMomentSaved: (() -> Void)?

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button
                HStack(spacing: 4) {
                    Button(action: { dismiss() }) {
                        Text("‹")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.tertiaryText)
                    }
                    Button(action: { dismiss() }) {
                        Text("Moments")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Theme.tertiaryText)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

                // Body content
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 10)

                    // Transcribing indicator
                    if transcriptionManager.isTranscribing {
                        HStack(spacing: Theme.Spacing.sm) {
                            ProgressView()
                                .tint(Theme.gold)
                            Text("Transcribing...")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Theme.tertiaryText)
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.vertical, Theme.Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, Theme.Spacing.sm)
                    }

                    // Transcription error with retry option
                    if let errorMessage = transcriptionManager.errorMessage {
                        VStack(spacing: Theme.Spacing.sm) {
                            HStack(spacing: Theme.Spacing.sm) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(Theme.error)
                                Text(errorMessage)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(Theme.error)
                                Spacer()
                            }
                            .padding(.horizontal, Theme.Spacing.md)
                            .padding(.vertical, Theme.Spacing.sm)
                            .background(Theme.error.opacity(0.1))
                            .cornerRadius(8)

                            Button(action: {
                                if let audioURL = audioURL {
                                    transcriptionManager.cancelTranscription()
                                    transcriptionManager.transcribeAudio(from: audioURL) { transcript in
                                        if let transcript = transcript, !transcript.isEmpty {
                                            momentBody = transcript
                                        }
                                    }
                                }
                            }) {
                                Text("Retry Transcription")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(Theme.gold)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }

                    TextEditor(text: $momentBody)
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(Theme.text)
                        .tint(Theme.gold)
                        .lineSpacing(1.8)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)

                    // Hint text
                    Text("Add where you sensed the Lord, if at all...")
                        .font(.system(size: 16, weight: .regular))
                        .italic()
                        .foregroundColor(senseOfLord.isEmpty ? Theme.inputPlaceholder : Theme.inputActive)
                        .padding(.top, 12)
                }
                .padding(.horizontal, 20)

                Spacer()

                // Footer buttons
                HStack(spacing: Theme.Spacing.md) {
                    Button(action: { dismiss() }) {
                        Text("Re-record")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Theme.tertiaryText)
                            .padding(.vertical, Theme.Button.primaryPadding - 1)
                            .padding(.horizontal, Theme.Spacing.xxl)
                            .background(Theme.subtleOverlay)
                            .border(Theme.border, width: 1)
                            .cornerRadius(Theme.Button.pillCornerRadius)
                            .lineLimit(1)
                    }

                    Button(action: {
                        Task {
                            await saveMoment()
                        }
                    }) {
                        if isSaving {
                            ProgressView()
                                .tint(Theme.goldDark)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Theme.Button.primaryPadding - 1)
                        } else {
                            Text("Save")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Theme.goldDark)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Theme.Button.primaryPadding - 1)
                        }
                    }
                    .background(Theme.gold)
                    .cornerRadius(Theme.Button.pillCornerRadius)
                    .disabled(isSaving || momentBody.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(isSaving || momentBody.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.vertical, Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .center) {
            if transcriptionManager.isTranscribing {
                TranscribingView(onComplete: {
                    transcriptionManager.isTranscribing = false
                })
                    .transition(.opacity)
            }
        }
        .onAppear {
            if let audioURL = audioURL, momentBody.isEmpty {
                transcriptionManager.transcribeAudio(from: audioURL) { transcript in
                    if let transcript = transcript, !transcript.isEmpty {
                        momentBody = transcript
                    }
                }
            }
        }
    }

    private func saveMoment() async {
        guard !momentBody.trimmingCharacters(in: .whitespaces).isEmpty else {
            saveError = "Moment cannot be empty"
            return
        }

        isSaving = true
        saveError = nil
        isSyncPending = false

        let moment = Moment(
            userId: userId,
            body: momentBody,
            senseOfLord: senseOfLord.isEmpty ? nil : senseOfLord,
            createdAt: Date()
        )

        do {
            _ = try await apiClient.saveMoment(moment)
            print("✅ ReviewView: save succeeded")
            await MainActor.run {
                isSaving = false
                onMomentSaved?()
            }
        } catch {
            print("🔴 ReviewView: save failed - \(error)")
            // Network error - save locally and mark for sync
            syncManager.markMomentAsPending(moment)
            await MainActor.run {
                isSyncPending = true
                isSaving = false
                onMomentSaved?()
            }
        }
    }
}

#Preview {
    let apiClient = MockAPIClient()
    NavigationStack {
        ReviewView(audioURL: nil, apiClient: apiClient, userId: "preview-user", syncManager: SyncManager(apiClient: apiClient), onMomentSaved: nil)
    }
}

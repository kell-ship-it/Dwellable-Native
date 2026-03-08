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
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(Theme.gold)
                            Text("Transcribing...")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Theme.tertiaryText)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                    }

                    // Transcription error with retry option
                    if let errorMessage = transcriptionManager.errorMessage {
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(Color(red: 0.95, green: 0.2, blue: 0.2))
                                Text(errorMessage)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(Color(red: 0.95, green: 0.2, blue: 0.2))
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(red: 0.95, green: 0.2, blue: 0.2, opacity: 0.1))
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
                        .foregroundColor(senseOfLord.isEmpty ? Color(red: 0.184, green: 0.188, blue: 0.22) : Color(red: 0.227, green: 0.239, blue: 0.271))
                        .padding(.top, 12)
                }
                .padding(.horizontal, 20)

                Spacer()

                // Footer buttons
                HStack(spacing: 10) {
                    Button(action: { dismiss() }) {
                        Text("Re-record")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Theme.tertiaryText)
                            .padding(.vertical, 15)
                            .padding(.horizontal, 28)
                            .background(Color(red: 1, green: 1, blue: 1, opacity: 0.04))
                            .border(Color(red: 0.6, green: 0.64, blue: 0.71, opacity: 0.2), width: 1)
                            .cornerRadius(20)
                            .lineLimit(1)
                    }

                    Button(action: {
                        Task {
                            await saveMoment()
                        }
                    }) {
                        if isSaving {
                            ProgressView()
                                .tint(Color(red: 0.1, green: 0.08, blue: 0.05))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                        } else {
                            Text("Save")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.05))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                        }
                    }
                    .background(Theme.gold)
                    .cornerRadius(20)
                    .disabled(isSaving || momentBody.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(isSaving || momentBody.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .center) {
            if transcriptionManager.isTranscribing {
                TranscribingView()
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
            onMomentSaved?()
            // Navigation handled by CaptureView
        } catch {
            // Network error - save locally and mark for sync
            syncManager.markMomentAsPending(moment)
            DispatchQueue.main.async {
                self.isSyncPending = true
                self.isSaving = false
            }
            // Call the callback anyway (data was saved locally)
            DispatchQueue.main.async {
                self.onMomentSaved?()
            }
            // Navigation handled by CaptureView
        }
    }
}

#Preview {
    let apiClient = MockAPIClient()
    NavigationStack {
        ReviewView(audioURL: nil, apiClient: apiClient, userId: "preview-user", syncManager: SyncManager(apiClient: apiClient), onMomentSaved: nil)
    }
}

import SwiftUI
import Combine

struct ReviewView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject private var transcriptionManager = TranscriptionManager.shared
    @State private var momentBody: String = ""
    @State private var senseOfLord: String = ""
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var isSyncPending = false
    @State private var spinnerRotation: Double = 0

    let audioURL: URL?
    let apiClient: APIClient
    let userId: String
    let syncManager: SyncManager
    var onMomentSaved: (() -> Void)?

    /// Keep loading visible until transcription is complete AND momentBody is populated
    /// OR until an error occurs
    private var shouldShowLoading: Bool {
        transcriptionManager.isTranscribing || (momentBody.isEmpty && transcriptionManager.errorMessage == nil)
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button (disabled during transcription)
                HStack(spacing: 4) {
                    Button(action: { dismiss() }) {
                        Text("‹")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.tertiaryText)
                    }
                    .disabled(transcriptionManager.isTranscribing)
                    .opacity(transcriptionManager.isTranscribing ? 0.5 : 1)

                    Button(action: { dismiss() }) {
                        Text("Moments")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Theme.tertiaryText)
                    }
                    .disabled(transcriptionManager.isTranscribing)
                    .opacity(transcriptionManager.isTranscribing ? 0.5 : 1)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

                // Body content
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 10)

                    // Transcribing indicator — show while transcribing OR while waiting for momentBody to populate
                    if shouldShowLoading {
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
                        .disabled(shouldShowLoading)
                        .opacity(shouldShowLoading ? 0.5 : 1.0)

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
            if shouldShowLoading {
                ZStack {
                    Color.black.ignoresSafeArea()

                    VStack(spacing: 20) {
                        Circle()
                            .trim(from: 0, to: 0.75)
                            .stroke(Theme.gold, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                            .frame(width: 36, height: 36)
                            .rotationEffect(.degrees(spinnerRotation))
                            .onAppear {
                                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                    spinnerRotation = 360
                                }
                            }

                        Text("Capturing your beautiful moment...")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(Theme.text)
                    }
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            // Set API client for audio uploads to Supabase Storage
            transcriptionManager.setAPIClient(apiClient, userId: userId)

            if let audioURL = audioURL, momentBody.isEmpty {
                // Start transcription immediately
                // AudioRecordingManager delegates already ensure file is fully written before reaching here
                transcriptionManager.transcribeAudio(from: audioURL) { transcript in
                    if let transcript = transcript, !transcript.isEmpty {
                        momentBody = transcript
                    }
                }
            }
        }
        .onDisappear {
            // Handle mid-transcription dismissal
            if transcriptionManager.isTranscribing {
                print("⚠️ [REVIEW_DISMISS] User closed view while transcribing")
                // Mark that this is an incomplete transcription
                transcriptionManager.isIncompleteTranscription = true
                // Cancel the ongoing transcription
                transcriptionManager.cancelTranscription()
            }
        }
        .onReceive(
            Just(scenePhase)
                .dropFirst()
                .eraseToAnyPublisher(),
            perform: { phase in
                // Handle app backgrounding during transcription
                if phase == .background && transcriptionManager.isTranscribing {
                    print("⚠️ [APP_BACKGROUND] App backgrounded during transcription")
                    // Mark transcription as incomplete but keep partial results
                    transcriptionManager.isIncompleteTranscription = true
                    // Note: Don't cancel transcription - let it continue in the background
                    // Apple's Speech Framework can continue processing
                } else if phase == .active && transcriptionManager.isIncompleteTranscription {
                    print("✅ [APP_FOREGROUND] App returned to foreground with incomplete transcription")
                    // If we have partial text, show it
                    if !transcriptionManager.transcript.trimmingCharacters(in: .whitespaces).isEmpty {
                        momentBody = transcriptionManager.transcript
                    }
                }
            }
        )
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
            createdAt: Date(),
            audioURL: transcriptionManager.audioURL
        )

        HTMLLogManager.shared.log("Save tapped — userId: \(userId.prefix(8)), body: \"\(String(momentBody.prefix(60)))\"")
        do {
            _ = try await apiClient.saveMoment(moment)
            HTMLLogManager.shared.log("Save succeeded — moment written to Supabase", level: "SUCCESS")
            UsageTracker.shared.logMomentCreated(userId: userId, type: "voice")
            Task { try? await UsageTracker.shared.syncEventsToBackend(userId: userId, apiClient: apiClient) }
            await MainActor.run {
                isSaving = false
                onMomentSaved?()
            }
        } catch {
            HTMLLogManager.shared.log("Save failed — \(error.localizedDescription) — falling back to local queue", level: "ERROR")
            syncManager.markMomentAsPending(moment)
            HTMLLogManager.shared.log("Moment queued locally for later sync", level: "WARNING")
            UsageTracker.shared.logMomentCreated(userId: userId, type: "voice")
            Task { try? await UsageTracker.shared.syncEventsToBackend(userId: userId, apiClient: apiClient) }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                syncManager.syncPendingMoments()
            }

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
        ReviewView(audioURL: nil, apiClient: apiClient, userId: "preview-user", syncManager: SyncManager(apiClient: apiClient, userId: "preview-user"), onMomentSaved: nil)
    }
}

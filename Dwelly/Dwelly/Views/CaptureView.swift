import SwiftUI
import Combine

/// Matches the locked P1 Capture redesign (Figma `t5MUGEtpeFcUixobvHiYMc`, node 2277:99,
/// "01 — Entry (Rotating Prompt) — reflecting") — rebuilt Nov 2026 after Kell caught that
/// the previous version (a generic centered "Tap to capture" mic button, no personalization,
/// a stray "‹ Moments" back row that doesn't belong in this locked flow) didn't match the
/// real design at all; it had apparently never been built against it in the first place.
/// Topic cards are the 3 fixed ones the design specifies verbatim — not yet wired to each
/// user's actual onboarding Intent selection (the subtext's "pulled from what you shared
/// during onboarding" is the locked copy/intent, but the real per-user personalization
/// logic is new scope beyond this visual rebuild, not done here). The top bar-flame-row is
/// rendered as a static/cosmetic element deliberately — T-210 flags its real meaning
/// (onboarding progress vs. a streak) as still unresolved, awaiting reviewer reply, so
/// nothing here should guess at real behavior for it yet.
struct CaptureView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var audioManager = AudioRecordingManager()
    @State private var showVoiceReview = false
    @State private var showTypeFlow = false
    @State private var inputText = ""
    @FocusState private var inputFocused: Bool

    // Model download state
    @State private var isDownloadingModel = false
    @State private var downloadProgress: Double = 0.0
    @State private var downloadFailed = false
    @State private var progressTimer: Timer?
    @State private var spinnerRotation: Double = 0

    @Environment(\.apiClient) private var apiClient
    let userId: String
    let userEmail: String?
    let syncManager: SyncManager
    var onMomentSaved: (() -> Void)?

    private let topicCards: [(title: String, subtitle: String)] = [
        ("Relationships", "Did God show up in a connection today?"),
        ("Quiet moments", "Any stillness stand out to you?"),
        ("Doubt or struggle", "Anything weighing on you today?"),
    ]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // bar-flame-row — see the type doc comment on T-210's unresolved meaning.
                HStack(spacing: 10) {
                    Capsule()
                        .fill(Theme.Capture.trackBackground)
                        .frame(height: 6)
                        .overlay(alignment: .leading) {
                            Capsule().fill(Theme.gold).frame(width: 328)
                        }
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.gold)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)

                Spacer().frame(height: 60)

                Text("What's stirring in you today?")
                    .font(.system(size: 26, design: .serif))
                    .foregroundColor(Theme.Capture.textPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 28)

                Spacer().frame(height: 28)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(topicCards, id: \.title) { card in
                            Button(action: { inputText = card.subtitle + " " }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(card.title)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Theme.Capture.textPrimary)
                                    Text(card.subtitle)
                                        .font(.system(size: 11))
                                        .foregroundColor(Theme.Capture.textMuted)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(16)
                                .frame(width: 145, height: 100, alignment: .topLeading)
                                .background(Theme.Capture.cardBackground)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.Capture.cardBorder, lineWidth: 1))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                    .padding(.horizontal, 28)
                }

                Spacer().frame(height: 28)

                Text("Pulled from what you shared during onboarding — tap one, or share what's actually on your mind.")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.Capture.textMuted)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 28)

                // Recording duration / warning / error — unchanged behavior, just restyled
                // to sit under the new layout instead of under the old mic button.
                if audioManager.isRecording {
                    Text(audioManager.formattedDuration(audioManager.recordingDuration))
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundColor(Theme.gold)
                        .padding(.top, 20)
                        .transition(.opacity)
                }
                if let warningMessage = audioManager.warningMessage {
                    Text(warningMessage)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.gold)
                        .padding(.top, Theme.Spacing.md)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                }
                if let errorMessage = audioManager.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.error)
                        .padding(.top, Theme.Spacing.md)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // input-bar — text-first, matching the locked design: typing swaps the
                // trailing mic for a send arrow; the field empty keeps mic as the primary
                // affordance into the existing (unchanged) voice-capture path.
                HStack(spacing: 10) {
                    TextField("", text: $inputText, prompt: Text("I've been thinking about").foregroundColor(Theme.Capture.textMuted), axis: .vertical)
                        .font(.system(size: 14))
                        .foregroundColor(Theme.Capture.textPrimary)
                        .tint(Theme.gold)
                        .focused($inputFocused)
                        .submitLabel(.done)
                        .onSubmit { submitTypedText() }
                        .disabled(audioManager.isRecording || isDownloadingModel)

                    Button(action: {
                        if inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            handleRecordTap()
                        } else {
                            submitTypedText()
                        }
                    }) {
                        Image(systemName: inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                              ? (audioManager.isRecording ? "stop.fill" : "mic.fill")
                              : "arrow.up")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.goldDark)
                            .frame(width: 40, height: 40)
                            .background(Theme.gold)
                            .clipShape(Circle())
                    }
                    .disabled(isDownloadingModel)
                    .opacity(isDownloadingModel ? 0.4 : 1.0)
                }
                .padding(.horizontal, 20)
                .frame(minHeight: 60)
                .background(Theme.Capture.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 28).stroke(Theme.gold, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .padding(.horizontal, 28)

                Text(audioManager.isRecording ? "Tap to finish recording" : "Tap return when you are finished writing")
                    .font(.system(size: 11))
                    .foregroundColor(Theme.gold)
                    .padding(.top, 10)

                Spacer()
                    .frame(height: Theme.Spacing.xxl)
            }

            // MARK: - Model Download Overlay
            if isDownloadingModel {
                modelDownloadOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showVoiceReview) {
            ReviewView(audioURL: audioManager.audioURL, userId: userId, userEmail: userEmail, syncManager: syncManager, onMomentSaved: {
                onMomentSaved?()
            })
        }
        .navigationDestination(isPresented: $showTypeFlow) {
            TypeFlowView(userId: userId, userEmail: userEmail, syncManager: syncManager, initialText: inputText, onMomentSaved: {
                onMomentSaved?()
            })
        }
        .onReceive(
            Just(scenePhase)
                .dropFirst()
                .eraseToAnyPublisher(),
            perform: { phase in
                if phase == .background && audioManager.isRecording {
                    HTMLLogManager.shared.log("App backgrounded during recording — stopping", level: "WARNING")
                    audioManager.stopRecording {
                        showVoiceReview = true
                    }
                }
            }
        )
    }

    // MARK: - Typed Text Handler

    private func submitTypedText() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        inputFocused = false
        showTypeFlow = true
    }

    // MARK: - Record Tap Handler

    private func handleRecordTap() {
        if audioManager.isRecording {
            audioManager.stopRecording {
                showVoiceReview = true
            }
        } else {
            // Check if model is ready — if not, download first
            if TranscriptionManager.shared.isModelReady || UserDefaults.standard.bool(forKey: "whisperModelReady") {
                audioManager.onRecordingLimitReached = { showVoiceReview = true }
                audioManager.startRecording()
            } else {
                // First time — download the model, then auto-start recording
                startModelDownload()
            }
        }
    }

    private func startModelDownload() {
        isDownloadingModel = true
        downloadFailed = false
        downloadProgress = 0.0
        HTMLLogManager.shared.log("First capture — downloading WhisperKit model", level: "INFO")

        // Animate progress bar
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            let target = 0.92 * (1 - exp(-downloadProgress / 0.85))
            DispatchQueue.main.async { downloadProgress += 0.001 }
            _ = target // suppress warning
        }

        Task {
            await TranscriptionManager.shared.setupWhisperKit()

            progressTimer?.invalidate()
            progressTimer = nil

            await MainActor.run {
                if TranscriptionManager.shared.isModelReady {
                    HTMLLogManager.shared.log("Model ready — starting first recording", level: "SUCCESS")
                    downloadProgress = 1.0
                    UserDefaults.standard.set(true, forKey: "whisperModelReady")

                    // Brief delay to show completion, then start recording
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        isDownloadingModel = false
                        audioManager.onRecordingLimitReached = { showVoiceReview = true }
                        audioManager.startRecording()
                    }
                } else {
                    HTMLLogManager.shared.log("Model download failed", level: "ERROR")
                    downloadFailed = true
                }
            }
        }
    }

    // MARK: - Download Overlay View

    private var modelDownloadOverlay: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if downloadFailed {
                VStack(spacing: 20) {
                    // Error icon box — no fill, no border
                    ZStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.orange)
                    }
                    .frame(width: 280, height: 80)

                    Text("Download failed.")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.orange)

                    // Detail box — no fill, no border
                    ZStack {
                        VStack(spacing: 8) {
                            Text("Check your connection and try again.")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.tertiaryText)
                                .multilineTextAlignment(.center)

                            HStack(spacing: 12) {
                                Button("Try Again") {
                                    startModelDownload()
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.background)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                                .background(Theme.gold)
                                .cornerRadius(8)

                                Button("Cancel") {
                                    isDownloadingModel = false
                                    downloadFailed = false
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Theme.tertiaryText)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(width: 280, height: 90)
                }
            } else {
                VStack(spacing: 16) {
                    // Spinner box — custom rotating arc
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
                        .frame(width: 280, height: 80)

                    Text("Setting up voice capture...")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Theme.text)

                    // Subtitle + progress bar box — no fill, no border
                    ZStack {
                        VStack(spacing: 12) {
                            Text("This only happens once.\nYour recording is safe.")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.tertiaryText)
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)

                            // Progress bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white.opacity(0.08))
                                        .frame(height: 3)
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Theme.gold)
                                        .frame(width: geo.size.width * CGFloat(min(downloadProgress, 1.0)), height: 3)
                                        .animation(.linear(duration: 0.05), value: downloadProgress)
                                }
                            }
                            .frame(height: 3)
                        }
                        .padding(.horizontal, 24)
                    }
                    .frame(width: 280, height: 90)
                }
            }
        }
    }
}

#Preview {
    let apiClient = MockAPIClient()
    NavigationStack {
        CaptureView(userId: "preview-user", userEmail: "preview@example.com", syncManager: SyncManager(apiClient: apiClient, userId: "preview-user"), onMomentSaved: nil)
    }
    .environment(\.apiClient, apiClient)
}

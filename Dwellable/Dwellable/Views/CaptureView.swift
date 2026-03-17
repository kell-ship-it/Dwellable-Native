import SwiftUI
import Combine

struct CaptureView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var audioManager = AudioRecordingManager()
    @State private var showVoiceReview = false
    @State private var showTypeFlow = false

    // Model download state
    @State private var isDownloadingModel = false
    @State private var downloadProgress: Double = 0.0
    @State private var downloadFailed = false
    @State private var progressTimer: Timer?
    @State private var spinnerRotation: Double = 0

    let apiClient: APIClient
    let userId: String
    let syncManager: SyncManager
    var onMomentSaved: (() -> Void)?

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 3) {
                            Text("‹")
                                .font(.system(size: 22))
                            Text("Moments")
                                .font(.system(size: 15, weight: .regular))
                        }
                        .foregroundColor(Theme.tertiaryText)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

                Spacer()

                // Mic button with rings
                ZStack {
                    ForEach(Array(0..<3).enumerated(), id: \.offset) { _, index in
                        Circle()
                            .stroke(
                                [Theme.goldRingLight, Theme.goldRingMedium, Theme.goldRing][index],
                                lineWidth: 1
                            )
                            .frame(width: CGFloat(160 - index * 40), height: CGFloat(160 - index * 40))
                    }

                    Button(action: {
                        handleRecordTap()
                    }) {
                        Image(systemName: audioManager.isRecording ? "mic.fill" : "mic.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Theme.goldDark)
                            .frame(width: 80, height: 80)
                            .background(audioManager.isRecording ? Theme.error : Theme.gold)
                            .clipShape(Circle())
                    }
                    .disabled(isDownloadingModel)
                    .opacity(isDownloadingModel ? 0.4 : 1.0)
                }
                .frame(width: 160, height: 160)

                Spacer()
                    .frame(height: 32)

                // Text
                Text("Tap to capture")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(Theme.text)

                Text("speak freely — we'll handle the rest")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Theme.tertiaryText)

                // Recording duration
                if audioManager.isRecording {
                    Text(audioManager.formattedDuration(audioManager.recordingDuration))
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundColor(Theme.gold)
                        .padding(.top, 16)
                        .transition(.opacity)
                }

                // Warning message (9-minute alert)
                if let warningMessage = audioManager.warningMessage {
                    Text(warningMessage)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Theme.gold)
                        .padding(.top, Theme.Spacing.md)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .lineLimit(nil)
                        .transition(.opacity)
                }

                // Error message (if any)
                if let errorMessage = audioManager.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Theme.error)
                        .padding(.top, Theme.Spacing.md)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .lineLimit(nil)
                }

                Spacer()

                // Waveform
                HStack(alignment: .center, spacing: 4) {
                    ForEach(Array([5, 13, 20, 9, 24, 15, 7, 19, 22, 11, 5].enumerated()), id: \.offset) { offset, height in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Theme.waveformFill)
                            .frame(width: 3, height: CGFloat(height))
                    }
                }
                .frame(height: 28)
                .padding(.bottom, Theme.Spacing.xxl)

                // Type instead button
                Button(action: {
                    showTypeFlow = true
                }) {
                    Text("type instead →")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Theme.tertiaryText)
                        .padding(.vertical, Theme.Spacing.sm)
                        .padding(.horizontal, Theme.Spacing.lg)
                        .background(Theme.subtleOverlay)
                        .border(Theme.borderLight, width: 1)
                        .cornerRadius(Theme.Button.pillCornerRadius)
                }
                .accessibilityIdentifier("Type instead")

                Spacer()
                    .frame(height: Theme.Spacing.xxl)
            }
            .padding(.horizontal, 28)

            // MARK: - Model Download Overlay
            if isDownloadingModel {
                modelDownloadOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showVoiceReview) {
            ReviewView(audioURL: audioManager.audioURL, apiClient: apiClient, userId: userId, syncManager: syncManager, onMomentSaved: {
                onMomentSaved?()
            })
        }
        .navigationDestination(isPresented: $showTypeFlow) {
            TypeFlowView(apiClient: apiClient, userId: userId, syncManager: syncManager, onMomentSaved: {
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
        CaptureView(apiClient: apiClient, userId: "preview-user", syncManager: SyncManager(apiClient: apiClient, userId: "preview-user"), onMomentSaved: nil)
    }
}

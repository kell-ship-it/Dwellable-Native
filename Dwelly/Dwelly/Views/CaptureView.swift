import SwiftUI
import Combine

/// Matches the real, current "02 — Capture Entry (Guided Prompts + Direct Text)" screen
/// (Figma `jBOzv1vO2C2DSMePqRl4c4` — the canonical "dwelly-redesign-file-important" file,
/// node 127:552 — NOT `t5MUGEtpeFcUixobvHiYMc`, the older baseline file this view was
/// wrongly rebuilt against earlier the same night). Entry is the one piece of P1 Capture's
/// real flow (12 scenarios, a conversational "Dwelly Responds" exchange, 8 error states)
/// that has no infrastructure dependency — everything past this screen needs T-168
/// (Shared LLM Proxy Service), which doesn't exist yet, so this view still only wires
/// Entry into the existing voice/type → save path, not the real conversational flow.
/// Topic cards are personalized to onboarding Intent, but only during the mandatory
/// onboarding first capture (see `topicCards` below) — every other capture uses the
/// original generic 3-card set the design specifies verbatim.
struct CaptureView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var audioManager = AudioRecordingManager()
    @State private var showVoiceReview = false
    @State private var showConversation = false
    @State private var conversationStartedFromPrompt = false
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
    // Passed through to CaptureConversationView — true only when OnboardingCoordinatorView
    // presents this screen for the mandatory first capture, where there's no "back" to
    // go to (Kell, Nov 10 2026).
    var isOnboarding: Bool = false
    var onMomentSaved: (() -> Void)?

    // Intent-tailored prompts apply ONLY to the mandatory onboarding first-capture
    // screen (isOnboarding == true) — confirmed with Kell (Nov 11 2026): intent can't
    // even be changed until a user is subscribed (well past onboarding), and by that
    // point the one-time personalization moment (their very first capture) has
    // already happened, so re-applying intent to every later capture would be
    // personalizing against a moment that's already over. Every capture after
    // onboarding uses the original generic set below, unconditionally, regardless of
    // intent — a separate, not-yet-built mechanism (Today tab's own rules) governs
    // post-onboarding prompt rotation, not this.
    //
    // Reduced from 3 cards to 1 per intent (Nov 11 2026) — one laser-focused prompt
    // tied to what the user just said they came here for, not a menu of options.
    // Re-keyed to the 5 intents locked the same session (IntentSelectionView),
    // replacing the earlier 4-option set.
    private var topicCards: [(title: String, category: String)] {
        let generic: [(title: String, category: String)] = [
            ("Did God show up in a connection today?", "Relationships"),
            ("Any stillness stand out to you?", "Quiet moments"),
            ("Anything you're wrestling with?", "Doubts"),
        ]
        guard isOnboarding else { return generic }

        let intent = ProfileManager.shared.localProfile(userId: userId).spiritualIntent
        switch intent {
        case "I want to journal my encounters with God":
            return [("What's a moment with God you want to remember from today?", "Encounter")]
        case "A place to process my thoughts and feelings":
            return [("What's weighing on your mind right now?", "Weighing on you")]
        case "I want to work through my doubts":
            return [("What's a doubt you've been sitting with?", "Doubts")]
        case "I want to see my patterns in my spiritual journey":
            return [("What's something you keep coming back to lately?", "Patterns")]
        case "I want to remember what God's done for me":
            return [("What's something God's done that you don't want to forget?", "Remembering")]
        default:
            return generic
        }
    }

    var body: some View {
        // Every call site presents `CaptureView` via a plain `.fullScreenCover`, with no
        // `NavigationStack` ancestor of its own — so the `.navigationDestination(isPresented:)`
        // calls below need their own `NavigationStack` right here, or they're silent no-ops.
        // Found Nov 9, 2026 testing T-168 live: tapping Send correctly flipped
        // `showConversation` to true (confirmed via debug log) but nothing happened — no
        // crash, no error, just stuck on this screen, because there was no navigation
        // context to push into.
        NavigationStack {
            captureContent
        }
    }

    private var captureContent: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Image("DwellyRockIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 28)
                .padding(.top, 14)

                Spacer().frame(height: 42)

                Text("What's stirring in you today?")
                    .font(.system(size: 38, design: .serif))
                    .foregroundColor(Theme.Capture.textPrimary)
                    .padding(.horizontal, 28)

                Spacer().frame(height: 10)

                Text("Tap one, or just start talking.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.Payment.textSupporting) // #857d69 — this text is "text/supporting" in the spec, not "text/placeholder" (Theme.Capture.textMuted, #a39e98) — caught by Kell comparing the running app to the real screenshot
                    .padding(.horizontal, 28)

                Spacer().frame(height: 36)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(topicCards, id: \.title) { card in
                            Button(action: {
                                inputText = card.title
                                conversationStartedFromPrompt = true
                                submitTypedText()
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        // Kell (Nov 10 2026): the prompt text must be fully
                                        // readable before tapping, not truncated -- the user
                                        // needs to actually see what they'd be responding to.
                                        Text(card.title)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Theme.Capture.textPrimary)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Text(card.category)
                                            .font(.system(size: 13))
                                            .foregroundColor(Theme.Payment.textSupporting) // #857d69 — same "text/supporting" correction as the subtext above
                                    }
                                    .multilineTextAlignment(.leading)
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 13))
                                        .foregroundColor(Theme.gold) // Kell's reference shows this arrow gold, not muted gray
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Theme.Capture.cardBackground)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.Capture.cardBorder, lineWidth: 1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                    .padding(.horizontal, 28)
                }
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

                // Component/Compose-Text-Pill (node 647:221) — plain pill, no border. Kell
                // caught two real mismatches against his own reference: the mic button is a
                // muted dark circle with a gold icon, not a solid gold fill — gold fill is
                // reserved for the send button, which only appears (highlighted) once
                // there's text to send. Mic stays available alongside it for voice.
                HStack(spacing: 8) {
                    TextField("", text: $inputText, prompt: Text("Share what's on your mind...").foregroundColor(Theme.Capture.textMuted), axis: .vertical)
                        .font(.system(size: 16))
                        .foregroundColor(Theme.Capture.textPrimary)
                        .tint(Theme.gold)
                        .focused($inputFocused)
                        .submitLabel(.done)
                        .onSubmit { submitTypedText() }
                        .disabled(audioManager.isRecording || isDownloadingModel)

                    Button(action: handleRecordTap) {
                        Image(systemName: audioManager.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Theme.gold)
                            .frame(width: 44, height: 44)
                            .background(Theme.Capture.cardBorder)
                            .clipShape(Circle())
                    }
                    .disabled(isDownloadingModel)
                    .opacity(isDownloadingModel ? 0.4 : 1.0)

                    if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button(action: submitTypedText) {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.goldDark)
                                .frame(width: 44, height: 44)
                                .background(Theme.gold)
                                .clipShape(Circle())
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.easeOut(duration: 0.15), value: inputText.isEmpty)
                .padding(.leading, 20)
                .padding(.trailing, 8)
                .frame(height: 60)
                .background(Theme.Capture.cardBackground)
                .clipShape(Capsule())
                .padding(.horizontal, 28)
                .padding(.bottom, Theme.Spacing.xxl)
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
        .navigationDestination(isPresented: $showConversation) {
            // T-168 wired in Nov 2026 — typed text now opens the real "Dwelly Responds"
            // conversation (node 38:246) instead of the old single-shot TypeFlowView save
            // screen. Voice capture still goes through ReviewView, unchanged — folding
            // voice into this same conversational flow is separate scope.
            CaptureConversationView(userId: userId, userEmail: userEmail, syncManager: syncManager, initialMessage: inputText, initialMessageIsPrompt: conversationStartedFromPrompt, isOnboarding: isOnboarding, onMomentSaved: {
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
        showConversation = true
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

import SwiftUI
import Combine

/// Matches the real, current "02 — Capture Entry (Guided Prompts + Direct Text)" screen
/// (Figma `jBOzv1vO2C2DSMePqRl4c4` — the canonical "dwelly-redesign-file-important" file,
/// node 127:552 — NOT `t5MUGEtpeFcUixobvHiYMc`, the older baseline file this view was
/// wrongly rebuilt against earlier the same night). Entry is the one piece of P1 Capture's
/// real flow (12 scenarios, a conversational "Dwelly Responds" exchange, 8 error states)
/// that has no infrastructure dependency — everything past this screen needs T-168
/// (Shared LLM Proxy Service). Both voice and typed entry now open the real
/// conversational flow (`CaptureConversationView`) -- voice was folded in Nov 11 2026
/// after Kell caught it still landing on the old Phase-1 `ReviewView` instead.
/// Topic cards are an onboarding-only affordance (relocked Nov 11 2026, Kell's direct
/// ask) — personalized to Intent during the mandatory onboarding first capture (see
/// `topicCards` below), shown nowhere else. Every post-onboarding capture is the plain
/// open compose/voice experience with no prompts at all; prompts post-onboarding belong
/// only to the Today tab's own separate (not-yet-built) mechanism, not here.
struct CaptureView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var audioManager = AudioRecordingManager()
    // `showConversation` now gates an in-place crossfade to `CaptureConversationView`
    // within this same screen's ZStack, not a `NavigationStack` push (Kell's approved
    // prototype, `dwelly-transition.html`, Nov 11 2026: a horizontal page-push read as
    // a context switch away from "I'm still talking to Dwelly," and briefly showed the
    // just-finished transcript sitting in this screen's own composer at the same time
    // the pushed screen was arriving with that same text as its first message bubble —
    // a visible duplicate during the slide). The message that's about to become the
    // first turn is held in `pendingConversationMessage`/`pendingConversationIsPrompt`
    // rather than ever being written into `inputText` — `inputText` now only ever
    // holds what's live in THIS screen's own composer, so there's nothing left for it
    // to show twice.
    @State private var showConversation = false
    @State private var pendingConversationMessage = ""
    @State private var pendingConversationIsPrompt = false
    @State private var isTranscribingVoice = false
    @State private var voiceErrorMessage: String?
    @State private var inputText = ""
    @FocusState private var inputFocused: Bool
    // Matches CaptureConversationView's recordingBar exactly (Nov 11 2026) — this
    // entry screen's own recording state had been left as a bare timer with no
    // waveform/cancel affordance since before that component existed, so starting a
    // recording here looked frozen/broken next to the real conversational flow's
    // polished Recording-Bar. Same per-bar random "character" trick, same reason.
    @State private var waveformSeeds: [CGFloat] = (0..<24).map { _ in CGFloat.random(in: 0.4...1.0) }

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
    // Only ever read when isOnboarding == true (gated at the one call site in `body`) --
    // the generic fallback below only matters for a user who somehow reached the
    // mandatory first capture with no recorded intent, not for post-onboarding captures.
    private var topicCards: [(title: String, category: String)] {
        let generic: [(title: String, category: String)] = [
            ("Did God show up in a connection today?", "Relationships"),
            ("Any stillness stand out to you?", "Quiet moments"),
            ("Anything you're wrestling with?", "Doubts"),
        ]
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
        // No `.navigationDestination` left in this screen (see `showConversation`'s
        // declaration above), but this `NavigationStack` is harmless to keep and
        // nothing downstream depends on its absence.
        NavigationStack {
            captureContent
        }
    }

    private var captureContent: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            // In-place crossfade (Kell's approved `dwelly-transition.html`, Nov 11
            // 2026) in place of the old `.navigationDestination` push — see
            // `showConversation`'s declaration above for why. `entryScreen` and the
            // conversation share this one ZStack slot so the composer and the rest of
            // the layout never visibly slide; only opacity (and a small lift) changes.
            if showConversation {
                CaptureConversationView(
                    userId: userId,
                    userEmail: userEmail,
                    syncManager: syncManager,
                    initialMessage: pendingConversationMessage,
                    initialMessageIsPrompt: pendingConversationIsPrompt,
                    isOnboarding: isOnboarding,
                    onMomentSaved: { onMomentSaved?() }
                )
                .transition(reduceMotion ? .identity : .fadeLift)
            } else {
                entryScreen
                    .transition(reduceMotion ? .identity : .opacity)
            }

            // MARK: - Model Download Overlay
            if isDownloadingModel {
                modelDownloadOverlay
            }
        }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.32), value: showConversation)
        .navigationBarBackButtonHidden(true)
        .onReceive(
            Just(scenePhase)
                .dropFirst()
                .eraseToAnyPublisher(),
            perform: { phase in
                if phase == .background && audioManager.isRecording {
                    HTMLLogManager.shared.log("App backgrounded during recording — stopping", level: "WARNING")
                    audioManager.stopRecording {
                        transcribeAndSubmit()
                    }
                }
            }
        )
    }

    private var entryScreen: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    // Kell caught this live (Nov 11 2026): post-onboarding, there was
                    // no way to leave this screen at all if you opened it and changed
                    // your mind -- no close button, nothing. Onboarding keeps the logo
                    // and no close button, same reasoning as everywhere else in this
                    // flow (there's nothing to go back TO during the mandatory first
                    // capture).
                    if !isOnboarding {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.Capture.textPrimary)
                                .frame(width: 44, height: 44)
                        }
                        Spacer()
                    } else {
                        Spacer()
                        Image("DwellyRockIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                }
                .padding(.horizontal, isOnboarding ? 28 : 16)
                .padding(.top, 14)

                Spacer().frame(height: 42)

                // Opening prompt + hint fade out together once recording stops and
                // transcription begins (Kell's approved prototype, Nov 11 2026:
                // `hideIntro()` on `stop()`) — not on record start, where the hint
                // just swaps to "Listening…" and the heading stays put. Opacity/offset
                // only, so the layout height underneath (topic cards, the compose
                // pill) never shifts — same anchoring as the compose pill itself.
                VStack(alignment: .leading, spacing: 10) {
                    Text("What's stirring in you today?")
                        .font(.system(size: 38, design: .serif))
                        .foregroundColor(Theme.Capture.textPrimary)

                    Text(audioManager.isRecording ? "Listening…" : (isOnboarding ? "Tap one, or just start talking." : "Just start talking."))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.Payment.textSupporting) // #857d69 — this text is "text/supporting" in the spec, not "text/placeholder" (Theme.Capture.textMuted, #a39e98) — caught by Kell comparing the running app to the real screenshot
                }
                .padding(.horizontal, 28)
                .opacity(isIntroHidden ? 0 : 1)
                .offset(y: isIntroHidden && !reduceMotion ? -8 : 0)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: isIntroHidden)

                Spacer().frame(height: 36)

                // Topic cards are an onboarding-only affordance (Kell, Nov 11 2026):
                // every post-onboarding capture should be the plain open compose/voice
                // experience, no prompts at all -- prompts belong only to the Today tab's
                // own (separate, not-yet-built) mechanism, not here.
                if isOnboarding {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(topicCards, id: \.title) { card in
                                Button(action: {
                                    beginConversation(message: card.title, isPrompt: true)
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
                if let voiceErrorMessage {
                    Text(voiceErrorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.error)
                        .padding(.top, Theme.Spacing.md)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Component/Recording-Bar (648:220) / Transcribing-Bar (649:3850) / plain
                // Compose-Text-Pill (647:221) — the same three-state swap
                // CaptureConversationView's compose area uses, pulled over exactly (Nov 11
                // 2026). This entry screen had never gotten that component: starting a
                // recording here just left the idle "What's stirring in you today?" screen
                // on with a bare timer ticking in the corner — no waveform, no cancel, no
                // real sign anything was happening, unlike the in-conversation recording
                // bar. Same recording/transcribing experience everywhere now, entry screen
                // included.
                if audioManager.isRecording {
                    recordingBar
                } else if isTranscribingVoice {
                    transcribingBar
                } else {
                    composePill
                }
            }
    }

    // Kell caught this live (Nov 11 2026): a post-onboarding voice capture landed
    // on the old Phase-1 ReviewView ("Re-record"/"Save", raw sense-of-Lord hint
    // field) instead of the real conversational experience typed text already
    // gets -- confirmed in code, voice had unconditionally routed to ReviewView
    // regardless of isOnboarding since this screen was first built. Folded in
    // properly now: recorded audio is transcribed here, same TranscriptionManager
    // pipeline CaptureConversationView's own re-record already uses, then handed
    // to the exact same `beginConversation()` path as typed input -- one real
    // conversational entry point, not two divergent ones. The transcribing state
    // itself renders as `transcribingBar` inline (matching CaptureConversationView),
    // not a separate full-screen overlay.

    // True once recording has stopped and transcription is running, or once the
    // crossfade to the conversation has started -- the point past which the opening
    // "What's stirring in you today?" / hint pairing has nothing left to say.
    private var isIntroHidden: Bool { isTranscribingVoice || showConversation }

    // MARK: - Typed Text Handler

    private func submitTypedText() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        inputFocused = false
        let text = inputText
        inputText = ""
        beginConversation(message: text)
    }

    // Hands a message off to become the conversation's opening turn and crossfades
    // into `CaptureConversationView` in place (see `showConversation`'s declaration
    // above) -- the one entry point typed text, topic-card taps, and transcribed
    // voice all converge on, so none of them can leave a stray copy of the message
    // sitting in this screen's own composer.
    private func beginConversation(message: String, isPrompt: Bool = false) {
        pendingConversationMessage = message
        pendingConversationIsPrompt = isPrompt
        showConversation = true
    }

    // MARK: - Record Tap Handler

    private func handleRecordTap() {
        if audioManager.isRecording {
            audioManager.stopRecording {
                transcribeAndSubmit()
            }
        } else {
            voiceErrorMessage = nil
            // Check if model is ready — if not, download first
            if TranscriptionManager.shared.isModelReady || UserDefaults.standard.bool(forKey: "whisperModelReady") {
                audioManager.onRecordingLimitReached = { transcribeAndSubmit() }
                audioManager.startRecording()
            } else {
                // First time — download the model, then auto-start recording
                startModelDownload()
            }
        }
    }

    // Discards the in-progress recording entirely — no transcription, nothing lands
    // in the compose field. Mirrors CaptureConversationView's own cancelRecording.
    private func cancelRecording() {
        audioManager.stopRecording {
            if let url = audioManager.audioURL {
                try? FileManager.default.removeItem(at: url)
            }
            audioManager.audioURL = nil
        }
    }

    /// Replaces the old unconditional hand-off to `ReviewView` (Kell caught this live,
    /// Nov 11 2026 -- a post-onboarding voice capture landed on the Phase-1 "Re-record"/
    /// "Save" screen instead of the real conversational experience). Transcribes using
    /// the exact same `TranscriptionManager` pipeline `CaptureConversationView`'s own
    /// re-record flow already uses, then feeds the result straight to
    /// `beginConversation()` -- never through `inputText`/this screen's own composer,
    /// so there's no frame where the finished transcript is visible here right before
    /// the crossfade to its real home as the first message bubble (Kell's approved
    /// prototype, Nov 11 2026 -- see `showConversation`'s declaration above).
    private func transcribeAndSubmit() {
        guard let audioURL = audioManager.audioURL else { return }
        isTranscribingVoice = true
        voiceErrorMessage = nil
        TranscriptionManager.shared.transcribeAudio(from: audioURL) { transcript in
            DispatchQueue.main.async {
                isTranscribingVoice = false
                guard let transcript, !transcript.isEmpty else {
                    voiceErrorMessage = TranscriptionManager.shared.errorMessage ?? "Couldn't make that out — try again, or type it instead."
                    return
                }
                beginConversation(message: transcript)
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
                        audioManager.onRecordingLimitReached = { transcribeAndSubmit() }
                        audioManager.startRecording()
                    }
                } else {
                    HTMLLogManager.shared.log("Model download failed", level: "ERROR")
                    downloadFailed = true
                }
            }
        }
    }

    // MARK: - Compose / Recording / Transcribing Pill
    // Pulled over exactly from CaptureConversationView (Nov 11 2026) so this entry
    // screen's own recording state is no longer a bare timer with nothing else
    // happening on screen -- same three components, same reasoning, everywhere a
    // mic button exists in this app.

    // Component/Compose-Text-Pill (node 647:221) — plain pill, no border. Kell
    // caught two real mismatches against his own reference: the mic button is a
    // muted dark circle with a gold icon, not a solid gold fill — gold fill is
    // reserved for the send button, which only appears (highlighted) once
    // there's text to send. Mic stays available alongside it for voice.
    private var composePill: some View {
        HStack(spacing: 8) {
            TextField("", text: $inputText, prompt: Text("Share what's on your mind...").foregroundColor(Theme.Capture.textMuted), axis: .vertical)
                .font(.system(size: 16))
                .foregroundColor(Theme.Capture.textPrimary)
                .tint(Theme.gold)
                .focused($inputFocused)
                .submitLabel(.done)
                .onSubmit { submitTypedText() }
                .disabled(isDownloadingModel)

            Button(action: handleRecordTap) {
                Image(systemName: "mic.fill")
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

    // Component/Recording-Bar (node 648:220) — Cancel (✕) + a live, voice-reactive
    // waveform + timer + Stop (circled gold, the "commits right now" action per this
    // design system's own Icon-Circle rule).
    private var recordingBar: some View {
        HStack(spacing: 0) {
            Button(action: cancelRecording) {
                Text("✕")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Capture.textMuted)
                    .frame(width: 44, height: 44)
                    .background(Theme.Capture.badgeBackground)
                    .clipShape(Circle())
            }

            HStack(spacing: 10) {
                liveWaveform
                Text(audioManager.formattedDuration(audioManager.recordingDuration))
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Payment.textSupporting)
            }
            .frame(maxWidth: .infinity)

            Button(action: handleRecordTap) {
                Rectangle()
                    .fill(Theme.Payment.backgroundPrimary)
                    .frame(width: 10, height: 10)
                    .cornerRadius(2)
                    .frame(width: 44, height: 44)
                    .background(Theme.gold)
                    .clipShape(Circle())
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 10)
        .frame(height: 64)
        .background(Theme.Capture.cardBackground)
        .clipShape(Capsule())
        .padding(.horizontal, 24)
        .padding(.bottom, Theme.Spacing.xxl)
    }

    // Component/Transcribing-Bar (node 649:3850) — a continuously animated wave (no
    // live audio exists anymore at this point, so this is a self-driven loop, not
    // audio-reactive) plus a status label, shown while speech-to-text runs.
    private var transcribingBar: some View {
        HStack(spacing: 8) {
            Circle().fill(Theme.Payment.textSupporting).frame(width: 6, height: 6)
            transcribingWaveform
            Spacer()
            Text("Transcribing...")
                .font(.system(size: 14))
                .foregroundColor(Theme.Payment.textSupporting)
        }
        .padding(.horizontal, 20)
        .frame(height: 64)
        .background(Theme.Capture.cardBackground)
        .clipShape(Capsule())
        .padding(.horizontal, 24)
        .padding(.bottom, Theme.Spacing.xxl)
    }

    private var liveWaveform: some View {
        HStack(spacing: 3) {
            ForEach(Array(waveformSeeds.enumerated()), id: \.offset) { _, seed in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.gold)
                    .frame(width: 2.5, height: 4 + seed * audioManager.audioLevel * 20)
                    .animation(.easeOut(duration: 0.1), value: audioManager.audioLevel)
            }
        }
        .frame(height: 24)
    }

    private var transcribingWaveform: some View {
        TimelineView(.animation) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate
            HStack(spacing: 3) {
                ForEach(0..<12, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Theme.Payment.textSupporting)
                        .frame(width: 2.5, height: 4 + 10 * abs(sin(phase * 3 + Double(index) * 0.5)))
                }
            }
            .frame(height: 24)
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

// A custom transition for the crossfade into `CaptureConversationView` — a plain
// opacity fade plus a small upward offset ("lift"), per Kell's approved prototype
// (`dwelly-transition.html`, Nov 11 2026). `AnyTransition` has no built-in offset
// case to combine with `.opacity`, hence the small `ViewModifier` here.
private struct FadeLiftModifier: ViewModifier {
    let hidden: Bool
    func body(content: Content) -> some View {
        content
            .opacity(hidden ? 0 : 1)
            .offset(y: hidden ? 8 : 0)
    }
}

extension AnyTransition {
    static var fadeLift: AnyTransition {
        .modifier(active: FadeLiftModifier(hidden: true), identity: FadeLiftModifier(hidden: false))
    }
}

#Preview {
    let apiClient = MockAPIClient()
    NavigationStack {
        CaptureView(userId: "preview-user", userEmail: "preview@example.com", syncManager: SyncManager(apiClient: apiClient, userId: "preview-user"), onMomentSaved: nil)
    }
    .environment(\.apiClient, apiClient)
}

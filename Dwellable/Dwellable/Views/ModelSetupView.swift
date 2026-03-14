import SwiftUI

/// Shown once after login — downloads WhisperKit model before user ever hits record.
/// Styled to match the setup-screen-preview.html mockup exactly.
struct ModelSetupView: View {
    let apiClient: APIClient
    let syncManager: SyncManager

    @EnvironmentObject var authManager: AuthManager
    @State private var phase: SetupPhase = .waiting
    @State private var progress: Double = 0.0
    @State private var progressTimer: Timer?

    enum SetupPhase {
        case waiting, downloading, ready, failed
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer()

                // Wordmark — matches HTML mockup serif style
                Text("dwellable")
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .foregroundColor(Theme.text)

                Spacer()

                // Centre status block
                VStack(spacing: 18) {
                    // Icon / spinner
                    Group {
                        if phase == .ready {
                            ZStack {
                                Circle()
                                    .fill(Theme.gold)
                                    .frame(width: 36, height: 36)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.background)
                            }
                            .transition(.scale.combined(with: .opacity))
                        } else if phase == .failed {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.orange)
                        } else {
                            ProgressView()
                                .tint(Theme.gold)
                                .scaleEffect(1.3)
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: phase)

                    // Primary text
                    Text(primaryText)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(phase == .failed ? .orange : Theme.text)
                        .multilineTextAlignment(.center)

                    // Subtitle
                    if phase != .ready {
                        Text(subtitleText)
                            .font(.system(size: 13))
                            .foregroundColor(Theme.tertiaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }

                    // Progress bar — only during download
                    if phase == .downloading || phase == .waiting {
                        ProgressBarView(progress: progress)
                            .padding(.top, 4)
                    }

                    // Retry button
                    if phase == .failed {
                        Button("Try Again") {
                            Task { await startDownload() }
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.background)
                        .padding(.horizontal, 48)
                        .padding(.vertical, 14)
                        .background(Theme.gold)
                        .cornerRadius(8)
                        .padding(.top, 8)
                    }
                }

                Spacer()

                // Footnote
                Text("One-time setup · Never again")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.tertiaryText.opacity(0.4))
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 40)
        }
        .environment(\.colorScheme, .dark)
        .task { await startDownload() }
    }

    // MARK: - Copy

    private var primaryText: String {
        switch phase {
        case .waiting:      return "Getting things ready..."
        case .downloading:  return "Downloading voice engine..."
        case .ready:        return "You're all set."
        case .failed:       return "Download failed."
        }
    }

    private var subtitleText: String {
        switch phase {
        case .waiting:      return ""
        case .downloading:  return "This only happens once.\nHang tight."
        case .ready:        return "Voice capture is ready."
        case .failed:       return "Check your connection\nand try again."
        }
    }

    // MARK: - Download

    private func startDownload() async {
        phase = .downloading
        progress = 0.0
        startProgressAnimation()
        HTMLLogManager.shared.log("ModelSetup: starting WhisperKit download", level: "INFO")

        await TranscriptionManager.shared.setupWhisperKit()

        progressTimer?.invalidate()
        progressTimer = nil

        if TranscriptionManager.shared.isModelReady {
            HTMLLogManager.shared.log("ModelSetup: model ready — entering app", level: "SUCCESS")
            await MainActor.run { progress = 1.0 }
            try? await Task.sleep(nanoseconds: 500_000_000)
            withAnimation { phase = .ready }
            try? await Task.sleep(nanoseconds: 900_000_000)
            await MainActor.run {
                UserDefaults.standard.set(true, forKey: "whisperModelReady")
            }
        } else {
            HTMLLogManager.shared.log("ModelSetup: model download failed", level: "ERROR")
            await MainActor.run { phase = .failed }
        }
    }

    /// Smoothly animates progress bar from 0 → ~92% while download runs.
    /// Slows down near the end so it never appears to "finish" before the real download does.
    private func startProgressAnimation() {
        var elapsed = 0.0
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            elapsed += 0.05
            // Asymptotic curve: approaches 0.92 but never reaches it
            let target = 0.92 * (1 - exp(-elapsed / 40))
            DispatchQueue.main.async { progress = target }
        }
    }
}

// MARK: - Progress Bar Component

private struct ProgressBarView: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 3)

                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.gold)
                    .frame(width: geo.size.width * CGFloat(progress), height: 3)
                    .animation(.linear(duration: 0.05), value: progress)
            }
        }
        .frame(width: 180, height: 3)
    }
}

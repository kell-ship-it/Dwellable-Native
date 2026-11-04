import SwiftUI
import AVKit
import AVFoundation

/// Plays a bundled video full-bleed, with sound, once, then calls `onFinished`. Used by both
/// AppLoadingView (AppLoadingAnimation.mp4 — has narration) and IntroVideoView
/// (IntroExplainer.mp4) — AVPlayerLayer via UIViewRepresentable rather than SwiftUI's
/// VideoPlayer, since VideoPlayer always draws its own playback chrome/controls, which
/// neither screen wants.
struct FullBleedVideoPlayer: UIViewRepresentable {
    let resourceName: String
    let resourceExtension: String
    var onFinished: () -> Void = {}

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension) else {
            return view
        }
        // .playback plays audio even when the device's silent switch is on — expected for
        // a video with narration, unlike incidental UI sound effects.
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)

        let player = AVPlayer(url: url)
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill

        context.coordinator.observeEnd(of: player, onFinished: onFinished)
        player.play()
        return view
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        private var token: NSObjectProtocol?

        func observeEnd(of player: AVPlayer, onFinished: @escaping () -> Void) {
            token = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                onFinished()
            }
        }

        deinit {
            if let token {
                NotificationCenter.default.removeObserver(token)
            }
        }
    }

    final class PlayerContainerView: UIView {
        let playerLayer = AVPlayerLayer()

        override init(frame: CGRect) {
            super.init(frame: frame)
            layer.addSublayer(playerLayer)
            // Matches the documented FullBleedImage lesson (WelcomeView.swift): a full-bleed
            // UIKit view left interactive swallows taps meant for anything stacked on top of it.
            isUserInteractionEnabled = false
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        override func layoutSubviews() {
            super.layoutSubviews()
            playerLayer.frame = bounds
        }
    }
}

/// The real App Loading / splash screen (Figma `dwelly-redesign` node `941:510`,
/// "00 — App Loading"): full-bleed brand transition animation on cold launch before
/// branching to Welcome (logged out) or the tab app (logged in) — auth state itself
/// resolves synchronously from Keychain (see AuthManager.init), so this is purely the
/// brand moment the design calls for, not a real loading wait. Falls back to the static
/// rock + wordmark mark if the video asset isn't bundled, so this never blocks launch.
struct AppLoadingView: View {
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            Color(red: 0x0b / 255, green: 0x0a / 255, blue: 0x08 / 255).ignoresSafeArea()

            if Bundle.main.url(forResource: "AppLoadingAnimation", withExtension: "mp4") != nil {
                FullBleedVideoPlayer(
                    resourceName: "AppLoadingAnimation",
                    resourceExtension: "mp4",
                    onFinished: onComplete
                )
                .ignoresSafeArea()
            } else {
                VStack(spacing: 16) {
                    Image("DwellyRockIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)

                    Text("dwelly")
                        .font(.system(size: 32, design: .serif))
                        .foregroundColor(Theme.Payment.textHeading)
                }
                .task {
                    try? await Task.sleep(nanoseconds: 900_000_000)
                    onComplete()
                }
            }
        }
    }
}

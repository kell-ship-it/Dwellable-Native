import SwiftUI

/// Onboarding "Intro Video" screen (T-239 / T-238 Screen 2): the ~40s animated explainer
/// that replaced the old 14-screen value-prop section. Full-bleed, skippable — a skip or
/// a natural end both call `onContinue`, landing the user at the next onboarding step
/// (Account Creation / Paywall placeholder) exactly the same way.
struct IntroVideoView: View {
    var onContinue: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(red: 0x0b / 255, green: 0x0a / 255, blue: 0x08 / 255).ignoresSafeArea()

            FullBleedVideoPlayer(
                resourceName: "IntroExplainer",
                resourceExtension: "mp4",
                onFinished: onContinue
            )
            .ignoresSafeArea()

            Button(action: onContinue) {
                Text("Skip")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Capsule())
            }
            .padding(.top, 52)
            .padding(.trailing, 20)
        }
    }
}

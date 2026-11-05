import SwiftUI

/// Onboarding "Preparing Space" screen (T-110, T-238 Screen 7 — the last screen before the
/// mandatory first capture). A brief, personalized transition rather than another decision
/// point: there's nothing left to ask by this point in the flow (Name/Intent/Notifications
/// are already collected), so this screen's only job is a warm, non-generic hand-off into
/// Screen 7 ("First Capture" per `docs/PILLAR_ONBOARDING_STRATEGY.md`) — auto-advances,
/// no button, same pattern as `AppLoadingView`'s own timed transition.
struct PreparingSpaceView: View {
    let name: String?
    var onComplete: () -> Void

    @State private var opacity: Double = 0

    private var greeting: String {
        if let name, !name.isEmpty {
            return "Preparing your space, \(name)."
        }
        return "Preparing your space."
    }

    var body: some View {
        ZStack {
            Theme.Payment.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 24) {
                ProgressView()
                    .tint(Theme.gold)
                    .scaleEffect(1.2)

                Text(greeting)
                    .font(.system(size: 20, design: .serif))
                    .foregroundColor(Theme.Payment.textHeading)
                    .multilineTextAlignment(.center)

                Text("A quiet place for what God is doing in your life.")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) { opacity = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                onComplete()
            }
        }
    }
}

#Preview {
    PreparingSpaceView(name: "Kell", onComplete: {})
}

import SwiftUI

/// The real Welcome screen (Figma `dwelly-redesign` node `969:525`, "01 — Welcome")
/// — faithfully rendered: full-bleed hero background art, "dwelly" wordmark, tagline,
/// and CTA. Named `OnboardingStubView` because it's still a stand-in for the *flow*:
/// T-110's other 6 screens + OnboardingCoordinator don't exist yet (needs T-109
/// self-signup, T-111 ProfileManager schema, T-100-105's copy), so tapping Get Started
/// here jumps straight to the first Payment paywall rather than through Account
/// Creation → Intro Video → Name → Intent → Notifications first, like the real flow
/// will. Shown once per user (tracked in UserDefaults), then never again.
struct OnboardingStubView: View {
    let userId: String
    var onComplete: () -> Void

    @State private var showPaywall = false

    // Fractions below are lifted directly from the Figma frame (402×874, node 969:525)
    // rather than guessed paddings/Spacers — the design places every element at a fixed
    // y within that frame, so reproducing it as a fraction of the real screen height is
    // what actually matches on-device, regardless of the phone's exact point dimensions.
    private let wordmarkTopFraction: CGFloat = 620.0 / 874.0
    private let footerTopFraction: CGFloat = 726.0 / 874.0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                Color(red: 0x0b / 255, green: 0x0a / 255, blue: 0x08 / 255).ignoresSafeArea()

                Image("WelcomeHeroBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()

                VStack(spacing: 8) {
                    Text("dwelly")
                        .font(.system(size: 52, design: .serif))
                        .foregroundColor(Theme.Payment.textHeading)

                    Text("STEWARD EVERY MOMENT WITH GOD")
                        .font(.system(size: 13, weight: .medium))
                        .tracking(1.5)
                        .foregroundColor(Theme.Payment.textSupporting)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .offset(y: geo.size.height * wordmarkTopFraction)

                VStack(spacing: 16) {
                    Button(action: { showPaywall = true }) {
                        Text("Get Started")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                    }
                    .background(Theme.gold)
                    .clipShape(Capsule())
                    .padding(.horizontal, 28)

                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .foregroundColor(Theme.Payment.textSupporting)
                        Text("Log in")
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.Payment.textHeading)
                    }
                    .font(.system(size: 14))
                }
                .frame(maxWidth: .infinity)
                .offset(y: geo.size.height * footerTopFraction)
            }
        }
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(context: .onboardingSkippable, onDismiss: {
                showPaywall = false
                OnboardingStubView.markSeen(userId: userId)
                onComplete()
            })
        }
    }

    // MARK: - Completion Tracking

    private static func key(userId: String) -> String {
        "hasSeenOnboarding_\(userId)"
    }

    static func hasSeenOnboarding(userId: String) -> Bool {
        UserDefaults.standard.bool(forKey: key(userId: userId))
    }

    static func markSeen(userId: String) {
        UserDefaults.standard.set(true, forKey: key(userId: userId))
    }
}

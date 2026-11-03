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

    var body: some View {
        ZStack {
            Color(red: 0x0b / 255, green: 0x0a / 255, blue: 0x08 / 255).ignoresSafeArea()

            Image("WelcomeHeroBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

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
                .padding(.bottom, 106)

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
                .padding(.top, 16)
                .padding(.bottom, 48)
            }
        }
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

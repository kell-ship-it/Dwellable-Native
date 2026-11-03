import SwiftUI

/// A deliberately minimal stand-in for the real onboarding flow (T-110's 7 screens +
/// OnboardingCoordinator — not started: needs T-109 self-signup, T-111 ProfileManager
/// schema, T-100-105's copy). This exists for one reason only: giving the first,
/// skippable Payment paywall (`PaywallContext.onboardingSkippable`) somewhere real to
/// live, so it isn't permanently unreachable while the full onboarding redesign is
/// still pending. Shown once per user (tracked in UserDefaults), then never again.
struct OnboardingStubView: View {
    let userId: String
    var onComplete: () -> Void

    @State private var showPaywall = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 8) {
                    Text("DWELLABLE")
                        .font(.system(size: 26, weight: .light))
                        .tracking(5)
                        .foregroundColor(Theme.text)

                    Text("A place to hold what matters.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Theme.tertiaryText)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                Button(action: { showPaywall = true }) {
                    Text("Get Started")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.goldDark)
                        .frame(maxWidth: .infinity)
                        .padding(Theme.Button.primaryPadding)
                        .background(Theme.gold)
                        .cornerRadius(Theme.Button.primaryCornerRadius)
                }
                .padding(.horizontal, Theme.Spacing.xxl)
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

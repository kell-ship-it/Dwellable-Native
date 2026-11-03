import SwiftUI
import UIKit

/// The real Welcome screen (Figma `dwelly-redesign` node `969:525`, "01 — Welcome")
/// — the actual first screen a logged-out user sees, not something shown after login.
/// Faithfully rendered: full-bleed hero background art, "dwelly" wordmark, tagline, CTA.
///
/// Real flow per the design: Welcome → Account Creation → Intro Video → Paywall →
/// Name → Intent → Notifications → Preparing Space (T-110, not built — needs T-109
/// self-signup, T-111 ProfileManager schema, T-100-105's copy). Since Account Creation
/// doesn't exist yet, "Get Started" here shows the onboarding paywall directly as a
/// placeholder step, then falls back to the real LoginView — this is a known gap, not
/// the intended final flow. "Log in" goes straight to the real LoginView, matching the
/// actual design intent for returning users.
private enum WelcomeDestination: Identifiable {
    case paywall
    case login
    var id: Self { self }
}

struct WelcomeView: View {
    @State private var destination: WelcomeDestination?

    // Fractions of the Figma frame (402×874, node 969:525), applied against the real
    // screen's own height.
    private var screenHeight: CGFloat { UIScreen.main.bounds.height }
    private let wordmarkTopFraction: CGFloat = 620.0 / 874.0
    private let footerTopFraction: CGFloat = 726.0 / 874.0
    // Measured from the rendered text block (52pt serif wordmark + 8pt gap + 13pt tagline).
    private let wordmarkBlockHeight: CGFloat = 88

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: screenHeight * wordmarkTopFraction)

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

            Spacer().frame(height: max(0, screenHeight * (footerTopFraction - wordmarkTopFraction) - wordmarkBlockHeight))

            VStack(spacing: 16) {
                Button(action: { destination = .paywall }) {
                    Text("Get Started")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                }
                .background(Theme.gold)
                .clipShape(Capsule())
                .padding(.horizontal, 28)

                Button(action: { destination = .login }) {
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .foregroundColor(Theme.Payment.textSupporting)
                        Text("Log in")
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.Payment.textHeading)
                    }
                    .font(.system(size: 14))
                }
            }
            .frame(maxWidth: .infinity)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("WelcomeHeroBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
        )
        .background(Color(red: 0x0b / 255, green: 0x0a / 255, blue: 0x08 / 255))
        .ignoresSafeArea()
        .fullScreenCover(item: $destination) { destination in
            switch destination {
            case .paywall:
                PaywallView(context: .onboardingSkippable, onDismiss: {
                    self.destination = .login
                })
            case .login:
                LoginView()
            }
        }
    }
}

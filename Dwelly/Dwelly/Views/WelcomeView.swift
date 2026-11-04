import SwiftUI
import UIKit

/// Decorative full-bleed background images must go through this UIKit wrapper, not a
/// plain SwiftUI `Image`. A SwiftUI `Image` used as a full-bleed background/ZStack
/// sibling reproducibly made Button taps on this screen flaky/unresponsive, confirmed
/// repeatedly on the simulator; this plain `UIImageView` wrapper did not reproduce it
/// in the same repeated testing. Root cause not fully understood — treat as the
/// standard pattern for any future full-bleed background image in this app.
private struct FullBleedImage: UIViewRepresentable {
    let imageName: String

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {}
}

/// The real Welcome screen (Figma `dwelly-redesign` node `969:525`, "01 — Welcome")
/// — the actual first screen a logged-out user sees, not something shown after login.
/// Faithfully rendered: full-bleed hero background art, "dwelly" wordmark, tagline, CTA.
///
/// Real flow per the design: Welcome → Account Creation → Name → Intent → Notifications →
/// Preparing Space (T-110, not built — needs T-109 self-signup, T-111 ProfileManager
/// schema, T-100-105's copy). Per Kell's explicit direction (Nov 3, 2026), "Get Started"
/// goes straight to Account Creation — NOT through the Intro Video, which the Figma flow
/// otherwise places at Screen 3. Account Creation falls through to the onboarding paywall
/// as a placeholder for the still-unbuilt Name/Intent/Notifications/Preparing-Space steps,
/// then to LoginView — a known gap, not the intended final flow. "Log in" goes straight to
/// the real LoginView. The Intro Video itself is still built and reachable via the dev
/// screen picker; it's just not wired into this button anymore.
private enum WelcomeDestination: Identifiable {
    case accountCreation
    case paywall
    case login
    var id: Self { self }
}

struct WelcomeView: View {
    @EnvironmentObject var authManager: AuthManager
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
                Button(action: { destination = .accountCreation }) {
                    Text("Get Started")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Payment.backgroundPrimary)
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
        .background(FullBleedImage(imageName: "WelcomeHeroBackground"))
        .background(Color(red: 0x0b / 255, green: 0x0a / 255, blue: 0x08 / 255))
        .ignoresSafeArea()
        .fullScreenCover(item: $destination) { destination in
            switch destination {
            case .accountCreation:
                AccountCreationView(
                    onContinue: { self.destination = .paywall },
                    onSignIn: { self.destination = .login }
                )
                #if DEBUG
                .devPickerOverlay()
                #endif
            case .paywall:
                PaywallView(context: .onboardingSkippable, onDismiss: {
                    self.destination = .login
                })
                #if DEBUG
                .devPickerOverlay()
                #endif
            case .login:
                LoginView()
                    #if DEBUG
                    .devPickerOverlay()
                    #endif
            }
        }
        // Collapses the whole Welcome -> Login -> ForgotPassword (or -> AccountCreation
        // -> CheckEmail) nested-cover chain in one shot when a deep link needs to present
        // its own destination from the root — see AuthManager.authSheetDismissTrigger.
        .onChange(of: authManager.authSheetDismissTrigger) { _ in
            destination = nil
        }
    }
}

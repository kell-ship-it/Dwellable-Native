import SwiftUI

/// Shown once, right after the `dwelly://auth/confirm` deep link finishes (see
/// DwellyApp.handleIncomingURL) — before this, tapping the email link silently signed the
/// user in with zero on-screen feedback, confirmed Nov 4 2026 (Kell: "it has me signed in
/// now, but it wasn't rendering the 'You're signed in'"). Matches the existing Figma design
/// (dwelly-redesign node 1066:355, "03c — Account Creation (Email Confirmed)", originally
/// built Nov 3 2026 as the immediate post-signup success state) — its copy still reads
/// correctly for this trigger, confirmed Nov 4 2026, so no new design was needed here.
struct EmailConfirmedView: View {
    var onContinue: () -> Void

    // Same proportional-offset technique WelcomeView already uses — a fixed pixel value
    // (what shipped first, Nov 4 2026) matches the 874pt Figma mockup but drifts on a real
    // device's actual height, which is exactly what Kell caught comparing screenshots.
    private var screenHeight: CGFloat { UIScreen.main.bounds.height }
    private let successIconTopFraction: CGFloat = 330.0 / 874.0

    /// Icon/title/subtitle sit in the upper-middle area per Figma's absolute layout, and
    /// the CTA is pinned to the bottom via the same `.safeAreaInset` footer convention
    /// every other screen uses — NOT vertically centered as one clustered group. Kell
    /// caught this Nov 4 2026 on NewPasswordView's matching success screen: the first
    /// version centered the whole VStack, putting Continue in the screen's middle instead
    /// of its usual fixed bottom position (same real bug here, fixed together).
    var body: some View {
        ZStack(alignment: .top) {
            Theme.Payment.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: screenHeight * successIconTopFraction)

                ZStack {
                    Circle()
                        .fill(Theme.gold)
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Theme.Payment.backgroundPrimary)
                }
                .frame(maxWidth: .infinity)

                Spacer().frame(height: 34)

                Text("You're in.")
                    .font(.system(size: 28, design: .serif))
                    .foregroundColor(Theme.Payment.textHeading)
                    .frame(maxWidth: .infinity)

                Spacer().frame(height: 12)

                Text("Your account has been created. Let's get your first moment ready to capture.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .multilineTextAlignment(.center)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 28)
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.Payment.backgroundPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
            }
            .background(Theme.gold)
            .clipShape(Capsule())
            .padding(.horizontal, 28)
            .padding(.top, 16)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity)
            .background(Theme.Payment.backgroundPrimary)
        }
    }
}

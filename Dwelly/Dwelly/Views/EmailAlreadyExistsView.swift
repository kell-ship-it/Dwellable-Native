import SwiftUI

/// Shown when `signUp()` returns `.emailAlreadyExists` (GoTrue's 422 "User already
/// registered"). Matches the Figma design built Nov 4, 2026 (dwelly-redesign node
/// 1090:391, "03d — Account Creation (Email Already Exists)"). Deliberately explicit per
/// Kell's direction the same day, reversing the anti-enumeration masking that previously
/// treated a duplicate email identically to a new signup — see T-115 for that tradeoff.
struct EmailAlreadyExistsView: View {
    let email: String
    var onLogIn: () -> Void
    var onUseDifferentEmail: () -> Void

    // Same proportional-offset technique WelcomeView already uses — a fixed pixel value
    // (what shipped first, Nov 4 2026) matches the 874pt Figma mockup but drifts on a real
    // device's actual height, which is exactly what Kell caught comparing screenshots.
    private var screenHeight: CGFloat { UIScreen.main.bounds.height }
    private let iconTopFraction: CGFloat = 330.0 / 874.0

    /// Icon/title/subtitle sit in the upper-middle area per Figma's absolute layout, and
    /// the CTA + secondary link are pinned to the bottom via the same `.safeAreaInset`
    /// footer convention every other screen uses — NOT vertically centered as one
    /// clustered group. Kell caught this Nov 4 2026 on NewPasswordView's matching success
    /// screen: the first version centered the whole VStack, putting the CTA in the
    /// screen's middle instead of its usual fixed bottom position (same real bug here,
    /// fixed together).
    var body: some View {
        ZStack(alignment: .top) {
            Theme.Payment.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: screenHeight * iconTopFraction)

                ZStack {
                    Circle()
                        .fill(Theme.gold)
                        .frame(width: 80, height: 80)
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 26))
                        .foregroundColor(Theme.Payment.backgroundPrimary)
                }
                .frame(maxWidth: .infinity)

                Spacer().frame(height: 34)

                Text("This email already exists")
                    .font(.system(size: 28, design: .serif))
                    .foregroundColor(Theme.Payment.textHeading)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                Spacer().frame(height: 12)

                Text("An account with \(email) already exists. Log in instead, or use a different email to create a new one.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .multilineTextAlignment(.center)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 28)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 16) {
                Button(action: onLogIn) {
                    Text("Log In Instead")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Payment.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                }
                .background(Theme.gold)
                .clipShape(Capsule())

                Button(action: onUseDifferentEmail) {
                    Text("Use a different email")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.gold)
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 16)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity)
            .background(Theme.Payment.backgroundPrimary)
        }
    }
}

import SwiftUI
import UserNotifications

/// Onboarding "Notification Permission" screen (T-110, T-238 Screen 6.5). Copy and the
/// opt-out-by-default framing are locked in `docs/PILLAR_ONBOARDING_STRATEGY.md` Screen
/// 6.5: "Enable notifications" is the encouraged/primary action, "Not now" is a real,
/// equally-reachable skip — never a disguised/de-emphasized dismiss.
struct NotificationPermissionView: View {
    let userId: String
    var onContinue: () -> Void
    var onBack: () -> Void

    @State private var isRequesting = false

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Payment.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 220)

                ZStack {
                    Circle()
                        .fill(Theme.Payment.surfaceCard)
                        .frame(width: 80, height: 80)
                    Image(systemName: "bell.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Theme.gold)
                }
                .frame(maxWidth: .infinity)

                Spacer().frame(height: 34)

                Text("Stay gently invited")
                    .font(.system(size: 28, design: .serif))
                    .foregroundColor(Theme.Payment.textHeading)
                    .frame(maxWidth: .infinity)

                Spacer().frame(height: 12)

                Text("We'll only send sparse, gentle invitations when there's something worth coming back to.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 12)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 28)

            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.Payment.textHeading)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Back")
            .padding(.leading, 20)
            .padding(.top, 52)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .safeAreaInset(edge: .bottom) { footer }
    }

    private var footer: some View {
        VStack(spacing: 16) {
            Button(action: enableTapped) {
                if isRequesting {
                    ProgressView().tint(Theme.Payment.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                } else {
                    Text("Enable notifications")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Payment.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                }
            }
            .background(Theme.gold)
            .clipShape(Capsule())
            .disabled(isRequesting)

            Button(action: notNowTapped) {
                Text("Not now")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.Payment.textSupporting)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(Theme.Payment.backgroundPrimary)
    }

    private func enableTapped() {
        isRequesting = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                ProfileManager.shared.setNotificationOptIn(granted, userId: userId)
                isRequesting = false
                onContinue()
            }
        }
    }

    private func notNowTapped() {
        // Real, equally-reachable skip — per the locked opt-out model, this is a genuine
        // decline, not a "maybe later" that quietly re-prompts. Pillar 8's notification
        // engine respects this flag and skips all push triggers for this user.
        ProfileManager.shared.setNotificationOptIn(false, userId: userId)
        onContinue()
    }
}

#Preview {
    NotificationPermissionView(userId: "preview-user", onContinue: {}, onBack: {})
}

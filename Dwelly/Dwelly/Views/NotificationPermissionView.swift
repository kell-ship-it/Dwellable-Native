import SwiftUI
import UserNotifications

/// Onboarding "Notification Permission" screen (T-110, T-238 Screen 6.5). Layout, copy, and
/// the notification-preview mock match the real locked Figma design (node 2213:92, file
/// `t5MUGEtpeFcUixobvHiYMc`) as of Nov 5, 2026 — pulled directly after Kell flagged the
/// original build as a shortcut that didn't match it. Note: the Figma copy ("Never miss a
/// moment" / "Allow Notifications") differs from `docs/PILLAR_ONBOARDING_STRATEGY.md`'s
/// Screen 6.5 copy ("Stay gently invited" / "Enable notifications") — Figma wins here since
/// it's the newer, explicitly-locked design-complete source, but this doc/design mismatch
/// should be reconciled, not left silently diverged. The opt-out-by-default framing still
/// holds: "Not now" is a real, equally-reachable skip, never a disguised dismiss.
struct NotificationPermissionView: View {
    let userId: String
    var onContinue: () -> Void
    var onBack: () -> Void

    @State private var isRequesting = false

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Onboarding.backgroundPrimary.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 120)

                notificationPreview

                Spacer().frame(height: 24)

                Text("Never miss a moment")
                    .font(.system(size: 28, design: .serif))
                    .foregroundColor(Theme.Onboarding.textPrimary)

                Spacer().frame(height: 12)

                Text("Gentle reminders to capture your thoughts before the moment passes.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Onboarding.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 28)

            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.Onboarding.textPrimary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Back")
            .padding(.leading, 20)
            .padding(.top, 52)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .safeAreaInset(edge: .bottom) { footer }
    }

    /// Mock lock-screen notification preview, matching the real T-238 Figma design
    /// (node 2213:95) — not a generic bell icon.
    private var notificationPreview: some View {
        HStack(alignment: .top, spacing: 12) {
            Image("DwellyAppIconArt")
                .resizable()
                .scaledToFill()
                .frame(width: 30, height: 30)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Dwelly")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.Onboarding.textPrimary)
                    Spacer()
                    Text("now")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.Onboarding.previewTimestamp)
                }
                Text("Take a moment. What's on your heart right now?")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Onboarding.previewBody)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
        .background(Theme.Onboarding.previewCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.Onboarding.previewCardBorder, lineWidth: 1)
        )
    }

    private var footer: some View {
        VStack(spacing: 16) {
            Button(action: enableTapped) {
                if isRequesting {
                    ProgressView().tint(Theme.Onboarding.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                } else {
                    Text("Allow Notifications")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Onboarding.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                }
            }
            .background(Theme.gold)
            .clipShape(Capsule())
            .disabled(isRequesting)

            Button(action: notNowTapped) {
                Text("Not now")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Onboarding.textTertiary)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(Theme.Onboarding.backgroundPrimary)
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

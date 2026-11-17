import SwiftUI

/// T-086: the real Notifications settings screen, pushed from Account Profile's Settings
/// Card. Pulled directly from Figma (dwelly-redesign jBOzv1vO2C2DSMePqRl4c4, page
/// "P8 — Notifications (Redesign)" -> P9 Scenario 8/9, node 686:259 for the picker screen
/// and 727:842 for the "Notifications saved" confirmation) rather than the ticket's own
/// written spec, which also describes a "Sabbath/Quiet Days" toggle -- that toggle does
/// not exist anywhere in the actual locked design, only this 3-way Default/Sparse/Off
/// picker, so it's left out here (same drift-from-ticket-text pattern as T-130/T-181/etc.
/// this session, resolved the same way: trust the real design over stale ticket text).
///
/// Honesty note: T-083 (push infrastructure -- Firebase/APNs, the stage-rule engine that
/// would actually decide when to send a push) is still 🔲 Not Started. This screen is
/// real -- the mode genuinely persists to `public.users.notification_mode` via
/// `ProfileManager` -- but nothing in the app yet reads that value to decide whether to
/// send a push, because nothing sends pushes at all yet. Saving a preference ahead of the
/// system that will honor it is still worth building now; it's just not yet load-bearing.
struct NotificationsSettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss

    @State private var selectedMode: NotificationMode = .defaultMode
    @State private var didSave = false

    var body: some View {
        ZStack {
            Theme.Payment.backgroundPrimary.ignoresSafeArea()

            if didSave {
                savedStage
            } else {
                pickerStage
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            guard let userId = authManager.currentUser?.id else { return }
            selectedMode = ProfileManager.shared.localProfile(userId: userId).notificationMode
        }
    }

    // MARK: - Picker stage (node 686:259)

    private var pickerStage: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 4) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Theme.Payment.textHeading)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Back")

                Text("Notifications")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundColor(Theme.Payment.textHeading)
            }

            Text("Sparse, invitational nudges — never pressure. Choose how much you want to hear from Dwelly.")
                .font(.system(size: 15))
                .foregroundColor(Theme.Payment.textSupporting)
                .fixedSize(horizontal: false, vertical: true)

            Text("MODE")
                .font(.system(size: 12, weight: .medium))
                .tracking(0.3)
                .foregroundColor(Theme.Payment.textSupporting)

            modePicker

            Spacer()

            Button(action: save) {
                Text("Save Notifications")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.Payment.backgroundPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
            }
            .background(Theme.gold)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 28)
        .padding(.top, 64)
        .padding(.bottom, 34)
    }

    private var modePicker: some View {
        HStack(spacing: 0) {
            ForEach(NotificationMode.allCases, id: \.self) { mode in
                let isSelected = mode == selectedMode
                Button(action: { selectedMode = mode }) {
                    Text(mode.displayName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(isSelected ? Theme.Payment.backgroundPrimary : Theme.Payment.textHeading)
                        .frame(maxWidth: .infinity)
                        .frame(height: 35)
                        .background(isSelected ? Theme.gold : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .padding(4)
        .background(Theme.Payment.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Saved stage (node 727:842)

    private var savedStage: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Theme.Payment.textHeading)

            Text("Notifications saved.")
                .font(.system(size: 28, weight: .regular, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)
                .multilineTextAlignment(.center)

            Text("Your notification preferences have been updated.")
                .font(.system(size: 15))
                .foregroundColor(Theme.Payment.textSupporting)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 8)

            Button(action: { dismiss() }) {
                Text("Done")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.Payment.backgroundPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
            }
            .background(Theme.gold)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 28)
        .padding(.top, 260)
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private func save() {
        guard let userId = authManager.currentUser?.id else { return }
        ProfileManager.shared.setNotificationMode(selectedMode, userId: userId)
        didSave = true
    }
}

#Preview {
    NavigationStack {
        NotificationsSettingsView()
    }
    .environmentObject(AuthManager(apiClient: MockAPIClient()))
}

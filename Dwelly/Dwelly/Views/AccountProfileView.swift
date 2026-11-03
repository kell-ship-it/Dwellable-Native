import SwiftUI

/// The real P9 Account Profile base screen (Figma node 711:4986), wired as a tab-bar
/// root per T-253 — no modal close, reached only via the tab bar. Identity + Info Card
/// + Settings Card rows match the locked design; the sub-screens each row would push to
/// (Security & Privacy, Notifications, Support & Feedback, Legal & About, Recently
/// Deleted) are separate tickets (T-130/T-131/T-133/T-134/T-176) — rows are present and
/// tappable-looking but not yet wired to real destinations.
struct AccountProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    var onSearch: () -> Void
    var onCapture: () -> Void

    @State private var showSignOutConfirmation = false

    private var initials: String {
        guard let email = authManager.currentUser?.email, let first = email.first else { return "?" }
        return String(first).uppercased()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                TabScreenHeader(title: "Account Profile", onSearch: onSearch, onCapture: onCapture)

                identity
                infoCard
                settingsCard
                footerActions
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Payment.background.ignoresSafeArea())
        .confirmationDialog("Sign out of Dwelly?", isPresented: $showSignOutConfirmation, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) {
                Task { await authManager.signOut() }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var identity: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(Theme.Payment.pillBackground)
                .frame(width: 80, height: 80)
                .overlay(
                    Text(initials)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(Theme.gold)
                )

            Text(authManager.currentUser?.email ?? "")
                .font(.system(size: 13))
                .foregroundColor(Theme.Payment.textSupporting)
        }
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            profileRow(label: "Member Since", value: "—")
            Divider().background(Theme.Payment.timelineRail)
            profileRow(label: "Subscription", value: "Free")
        }
        .background(Theme.Payment.pillBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }

    private var settingsCard: some View {
        VStack(spacing: 0) {
            settingsRow(icon: "shield.checkerboard", title: "Security & Privacy")
            Divider().background(Theme.Payment.timelineRail)
            settingsRow(icon: "bell", title: "Notifications")
            Divider().background(Theme.Payment.timelineRail)
            settingsRow(icon: "questionmark.circle", title: "Support & Feedback")
            Divider().background(Theme.Payment.timelineRail)
            settingsRow(icon: "doc.text", title: "Legal & About")
            Divider().background(Theme.Payment.timelineRail)
            settingsRow(icon: "trash", title: "Recently Deleted")
        }
        .background(Theme.Payment.pillBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    private var footerActions: some View {
        HStack(spacing: 24) {
            Button("Sign Out") { showSignOutConfirmation = true }
                .font(.system(size: 13))
                .foregroundColor(Theme.Payment.textSupporting)

            Button("Delete Account") {}
                .font(.system(size: 13))
                .foregroundColor(Theme.Payment.errorRed)
        }
        .padding(.bottom, 32)
    }

    private func profileRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Theme.Payment.textHeading)
            Spacer()
            Text(value)
                .font(.system(size: 13))
                .foregroundColor(Theme.Payment.textSupporting)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
    }

    private func settingsRow(icon: String, title: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(Theme.gold)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(Theme.Payment.textHeading)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Theme.Payment.textSupporting)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .contentShape(Rectangle())
    }
}

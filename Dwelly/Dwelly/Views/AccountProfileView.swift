import SwiftUI

/// The real P9 Account Profile base screen (Figma node 711:4986), wired as a tab-bar
/// root per T-253 — no modal close, reached only via the tab bar. Identity + Info Card
/// + Settings Card rows match the locked design; the sub-screens each row pushes to
/// are separate tickets (T-131/T-133/T-134/T-176/T-086) — Security & Privacy (T-131) and
/// Recently Deleted (T-176) are wired to real screens; Notifications, Support & Feedback,
/// and Legal & About still have no destination built yet.
struct AccountProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject private var paymentManager = PaymentManager.shared
    @Environment(\.apiClient) private var apiClient
    var onCapture: () -> Void

    @State private var showSignOutConfirmation = false
    @State private var showDeleteAccountConfirmation = false
    @State private var isDeletingAccount = false
    @State private var deleteAccountError: String?
    // T-130: "Member Since" was a hardcoded "—" placeholder; this is the real value.
    @State private var memberSince: Date?

    private var initials: String {
        guard let email = authManager.currentUser?.email, let first = email.first else { return "?" }
        return String(first).uppercased()
    }

    // T-130 (Kell's call, Nov 16 2026): the ticket text's "Intent Statement" row and
    // weekly Intent Check prompt (Yes/Not Yet/Need Help) don't exist anywhere in the
    // actual locked Figma design (node 711:4986, "Account Profile — Base") -- checked
    // live via Figma MCP before building rather than building from the stale ticket
    // text. The real design's Info Card is just Member Since + Subscription, plus a
    // Name row in Identity that the code never actually rendered (avatar + email
    // only) -- that's the real gap this ticket closes. See T-299 for the
    // superseded-from-design parts.
    private var memberSinceDisplay: String {
        guard let memberSince else { return "—" }
        return memberSince.formatted(date: .abbreviated, time: .omitted)
    }

    private var subscriptionDisplay: String {
        paymentManager.hasActiveEntitlement ? "Premium" : "Free"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // T-128: no onSearch here -- search only exists on Entries (see
                // TabScreenHeader's own comment).
                TabScreenHeader(title: "Account Profile", onCapture: onCapture)

                identity
                infoCard
                settingsCard
                footerActions
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Payment.background.ignoresSafeArea())
        .task {
            guard let userId = authManager.currentUser?.id else { return }
            memberSince = try? await apiClient.fetchAccountCreatedAt(userId: userId)
        }
        .confirmationDialog("Sign out of Dwelly?", isPresented: $showSignOutConfirmation, titleVisibility: .visible) {
            Button("Sign Out", role: .destructive) {
                Task { await authManager.signOut() }
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog(
            "Permanently delete your account?",
            isPresented: $showDeleteAccountConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) {
                Task { await deleteAccount() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently deletes your account and every moment, journal entry, and prayer you've captured. This cannot be undone.")
        }
        .alert("Couldn't Delete Account", isPresented: .constant(deleteAccountError != nil), actions: {
            Button("OK") { deleteAccountError = nil }
        }, message: {
            Text(deleteAccountError ?? "")
        })
        .disabled(isDeletingAccount)
    }

    private func deleteAccount() async {
        isDeletingAccount = true
        defer { isDeletingAccount = false }
        do {
            try await authManager.deleteAccount()
        } catch {
            deleteAccountError = error.localizedDescription
        }
    }

    // T-130: the real locked design (node 711:4996) shows a name line between the
    // avatar and email -- the code never rendered one at all. Reuses the same local
    // cache T-111 already populates from onboarding's Name Entry screen; no new
    // storage needed.
    private var displayName: String? {
        guard let userId = authManager.currentUser?.id else { return nil }
        let name = ProfileManager.shared.localProfile(userId: userId).name
        return (name?.isEmpty ?? true) ? nil : name
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

            if let displayName {
                Text(displayName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Theme.Payment.textHeading)
            }

            Text(authManager.currentUser?.email ?? "")
                .font(.system(size: 13))
                .foregroundColor(Theme.Payment.textSupporting)
        }
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            profileRow(label: "Member Since", value: memberSinceDisplay)
            Divider().background(Theme.Payment.background)
            // Figma's value color for this row specifically is accent gold, distinct
            // from Member Since's plain heading color (node 711:5005) -- the only
            // gold text in this card, same "one confirmed thing stands out" logic as
            // everywhere else gold is used in this app.
            profileRow(label: "Subscription", value: subscriptionDisplay, valueColor: Theme.gold)
        }
        .background(Theme.Payment.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }

    private var settingsCard: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: SecurityPrivacyView()) {
                settingsRow(icon: "shield.checkerboard", title: "Security & Privacy")
            }
            .buttonStyle(.plain)
            Divider().background(Theme.Payment.timelineRail)
            settingsRow(icon: "bell", title: "Notifications")
            Divider().background(Theme.Payment.timelineRail)
            settingsRow(icon: "questionmark.circle", title: "Support & Feedback")
            Divider().background(Theme.Payment.timelineRail)
            settingsRow(icon: "doc.text", title: "Legal & About")
            Divider().background(Theme.Payment.timelineRail)
            // Kell caught this live (Nov 16 2026): every row here looked tappable but
            // none of them actually went anywhere -- this is the one real exception.
            // RecentlyDeletedView (T-176) already exists and works; it just never got
            // wired to this row. The other four still have nowhere real to push to
            // yet (T-131/T-133/T-134, and Notifications has no ticket at all) -- see
            // this file's own top comment.
            if let userId = authManager.currentUser?.id {
                NavigationLink(destination: RecentlyDeletedView(userId: userId)) {
                    settingsRow(icon: "trash", title: "Recently Deleted")
                }
                .buttonStyle(.plain)
            } else {
                settingsRow(icon: "trash", title: "Recently Deleted")
            }
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

            Button("Delete Account") { showDeleteAccountConfirmation = true }
                .font(.system(size: 13))
                .foregroundColor(Theme.Payment.errorRed)
        }
        .padding(.bottom, 32)
    }

    private func profileRow(label: String, value: String, valueColor: Color = Theme.Payment.textHeading) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .tracking(0.3)
                .foregroundColor(Theme.Payment.textSupporting)
            Spacer()
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(valueColor)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
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

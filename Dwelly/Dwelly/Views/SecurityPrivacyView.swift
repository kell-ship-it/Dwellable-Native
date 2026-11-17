import SwiftUI

/// T-131: the real Security & Privacy screen, pushed from Account Profile's Settings Card
/// (Figma node 711:5007 — only the row exists there, no separate detail frame, same gap
/// as Recently Deleted). No longer hard-blocked on T-062 (server-side encryption shipped
/// Nov 2026) the way this ticket originally was when raised July 20, 2026.
///
/// Scoped to what's real today, per the ticket's own written spec:
/// - Change Password: real, using AuthManager's existing `updatePassword` (built for the
///   recovery-link flow, reused here) plus a current-password re-auth check via
///   `apiClient.login` before allowing the change.
/// - Encryption: a real "how your data is protected" explainer — written to describe
///   what T-062 actually built (server-side encryption-at-rest via a Supabase Edge
///   Function secret), not the zero-knowledge/client-side-key architecture
///   `PILLAR_2_SECURITY_STRATEGY.md` originally specified but was never built.
/// - Data Export: genuinely Post-MVP per this ticket — shown disabled with "Coming soon",
///   same honest-disabled-state pattern as GrowthPlaceholderView/TodayPlaceholderView,
///   not a dead tappable row.
struct SecurityPrivacyView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Theme.Payment.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                VStack(spacing: 0) {
                    NavigationLink(destination: ChangePasswordView()) {
                        row(icon: "key.fill", title: "Change Password")
                    }
                    .buttonStyle(.plain)

                    Divider().background(Theme.Payment.timelineRail)

                    NavigationLink(destination: EncryptionInfoView()) {
                        row(icon: "lock.shield", title: "How Your Data Is Protected")
                    }
                    .buttonStyle(.plain)

                    Divider().background(Theme.Payment.timelineRail)

                    row(icon: "square.and.arrow.up", title: "Data Export", trailing: "Coming soon", disabled: true)
                }
                .background(Theme.Payment.pillBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        HStack(spacing: 4) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.Payment.textHeading)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Back")

            Text("Security & Privacy")
                .font(.system(size: 20, weight: .regular, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func row(icon: String, title: String, trailing: String? = nil, disabled: Bool = false) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(disabled ? Theme.Payment.textSupporting : Theme.gold)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(disabled ? Theme.Payment.textSupporting : Theme.Payment.textHeading)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Payment.textSupporting)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.Payment.textSupporting)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        SecurityPrivacyView()
    }
    .environmentObject(AuthManager(apiClient: MockAPIClient()))
}

import SwiftUI

/// Placeholder for the Growth tab's remaining content (Rhythm & Intent, designed in
/// Figma P11 but deliberately deferred to Post-MVP by Kell's direct call, Nov 16 2026
/// -- see T-181). The "Your Narrative" card (T-275) and "Your Plain Stats" section
/// (T-140/T-141) are both real now -- see `YourNarrativeCard` / `PlainStatsSection`.
struct GrowthPlaceholderView: View {
    let userId: String
    var onCapture: () -> Void
    /// Bumped by MainTabView each time a conversation closes; tabs stay mounted (custom tab
    /// bar), so this is what re-loads data that a new save changed (Nov 24 2026).
    var refreshKey: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // T-128: no onSearch here -- search only exists on Entries (see
            // TabScreenHeader's own comment).
            TabScreenHeader(title: "Growth", onCapture: onCapture)

            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    YourNarrativeCard(userId: userId, refreshKey: refreshKey)
                    PlainStatsSection(userId: userId, refreshKey: refreshKey)

                    VStack(spacing: 8) {
                        Image(systemName: "leaf")
                            .font(.system(size: 32))
                            .foregroundColor(Theme.Payment.textSupporting)
                        Text("Rhythm and Intent are coming soon.")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.Payment.textSupporting)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 48)
                    }
                    .padding(.top, Theme.Spacing.xxl)
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.top, Theme.Spacing.lg)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Payment.background.ignoresSafeArea())
    }
}

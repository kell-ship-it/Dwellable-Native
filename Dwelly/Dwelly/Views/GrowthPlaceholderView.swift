import SwiftUI

/// Placeholder for the Growth tab's remaining content (Rhythm & Intent —
/// locked in Figma P11, frame 667:2215) -- building that is T-143, not this one.
/// The "Your Narrative" card (T-275) and "Your Plain Stats" section (T-140/T-141) are
/// both real now -- see `YourNarrativeCard` / `PlainStatsSection`.
struct GrowthPlaceholderView: View {
    let userId: String
    var onCapture: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // T-128: no onSearch here -- search only exists on Entries (see
            // TabScreenHeader's own comment).
            TabScreenHeader(title: "Growth", onCapture: onCapture)

            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    YourNarrativeCard(userId: userId)
                    PlainStatsSection(userId: userId)

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

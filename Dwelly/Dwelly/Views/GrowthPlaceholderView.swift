import SwiftUI

/// Placeholder for the Growth tab's remaining content (Plain Stats, Rhythm & Intent —
/// locked in Figma P11, frame 667:2215) -- building those is T-141/T-143, not this one.
/// The "Your Narrative" card itself (T-275) is real now, pulled directly from Figma
/// (nodes 595:200 "Tier 1" / 603:224 "Pre-Threshold") -- see `YourNarrativeCard`.
struct GrowthPlaceholderView: View {
    let userId: String
    var onSearch: () -> Void
    var onCapture: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TabScreenHeader(title: "Growth", onSearch: onSearch, onCapture: onCapture)

            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    YourNarrativeCard(userId: userId)

                    VStack(spacing: 8) {
                        Image(systemName: "leaf")
                            .font(.system(size: 32))
                            .foregroundColor(Theme.Payment.textSupporting)
                        Text("Plain Stats, Rhythm, and Intent are coming soon.")
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

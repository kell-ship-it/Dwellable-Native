import SwiftUI

/// Placeholder for the Growth tab's real content (Your Narrative, Plain Stats,
/// Rhythm & Intent — locked in Figma P11, frame 667:2215). Building that is
/// T-140/T-141/T-142/T-143, not this ticket (T-076) — this view exists only so
/// the TabView has a real 3rd destination.
struct GrowthPlaceholderView: View {
    var onSearch: () -> Void
    var onCapture: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TabScreenHeader(title: "Growth", onSearch: onSearch, onCapture: onCapture)

            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "leaf")
                    .font(.system(size: 32))
                    .foregroundColor(Theme.Payment.textSupporting)
                Text("Your Narrative and formation stats are coming soon.")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 48)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Payment.background.ignoresSafeArea())
    }
}

import SwiftUI

/// Placeholder for the Today tab's real content (daily reflection dashboard, locked
/// in Figma P10 — frame 570:507/570:629: greeting, "A Word for Today" hero, 3 prompt
/// tiles). Building that full content is T-135/T-136/T-137/T-138/T-139, not this
/// ticket (T-076) — this view exists only so the TabView has a real 4th destination.
struct TodayPlaceholderView: View {
    var onSearch: () -> Void
    var onCapture: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TabScreenHeader(title: "Today", onSearch: onSearch, onCapture: onCapture)

            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "sun.horizon")
                    .font(.system(size: 32))
                    .foregroundColor(Theme.Payment.textSupporting)
                Text("Today's reflection dashboard is coming soon.")
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

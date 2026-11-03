import SwiftUI

/// Shared header toolbar for the 4 tab-landing screens (Today/Entries/Growth/Profile).
/// Matches the locked P6 nav redesign: title + bare search icon + gold capture circle —
/// search and capture are split into two standalone controls, never a bordered pill
/// (Digital Cotton #8 finding; see Figma `dwelly-redesign` jBOzv1vO2C2DSMePqRl4c4, page
/// "P6 — Menu / Navigation"). Capture is the one real commit action in the header, so it's
/// the only circle (Icon Circle Rule §8) and the only gold element (Gold CTA Heuristic).
struct TabScreenHeader: View {
    let title: String
    var onSearch: () -> Void
    var onCapture: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 30, weight: .regular, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)

            Spacer()

            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .frame(width: 28, height: 28)
            }

            Button(action: onCapture) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .background(Theme.gold)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

#Preview {
    TabScreenHeader(title: "Today", onSearch: {}, onCapture: {})
        .background(Theme.Payment.background)
}

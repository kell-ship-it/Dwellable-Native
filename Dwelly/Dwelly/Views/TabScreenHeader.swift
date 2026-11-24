import SwiftUI

/// Shared header toolbar for the 4 tab-landing screens (Today/Entries/Growth/Profile).
/// Matches the locked P6 nav redesign: title + bare search icon + gold capture circle —
/// search and capture are split into two standalone controls, never a bordered pill
/// (Digital Cotton #8 finding; see Figma `dwelly-redesign` jBOzv1vO2C2DSMePqRl4c4, page
/// "P6 — Menu / Navigation"). Capture is the one real commit action in the header, so it's
/// the only circle (Icon Circle Rule §8) and the only gold element (Gold CTA Heuristic).
///
/// T-128 (Kell's call, Nov 16 2026): Search only exists on Entries -- it searches your
/// journal entries specifically, so surfacing it on Today/Growth/Profile implied a
/// broader search than actually exists. `onSearch` is nil on those three screens, which
/// hides the icon entirely rather than showing a dead/misleading control.
struct TabScreenHeader: View {
    let title: String
    var onSearch: (() -> Void)? = nil
    var onCapture: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 30, weight: .regular, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)

            Spacer()

            if let onSearch {
                Button(action: onSearch) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .frame(width: 28, height: 28)
                }
            }

            Button(action: onCapture) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .glassCircleSurface()
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

/// Floating-control surface (Nov 24 2026, T-331 preview). iOS 26+: gold-tinted Liquid Glass.
/// Older iOS: the original solid gold circle, unchanged.
struct GlassCircleSurface: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.tint(Theme.gold.opacity(0.85)).interactive(), in: Circle())
        } else {
            content.background(Theme.gold).clipShape(Circle())
        }
    }
}

/// Capsule glass for text controls such as Done. Older iOS: no background (as before).
struct GlassCapsuleSurface: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.padding(.horizontal, 14).glassEffect(.regular.tint(Theme.background.opacity(0.55)).interactive(), in: Capsule())
        } else {
            content.padding(.horizontal, 14).padding(.vertical, 8)
                .background(Theme.Payment.backgroundSurface).clipShape(Capsule())
        }
    }
}

/// Neutral (untinted) glass circle for icon buttons that float over the chat, such as
/// the back chevron. Older iOS: a solid dark circle so text never shows through.
struct GlassNeutralCircleSurface: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular.tint(Theme.background.opacity(0.55)).interactive(), in: Circle())
        } else {
            content.background(Theme.Payment.backgroundSurface).clipShape(Circle())
        }
    }
}

extension View {
    func glassNeutralCircleSurface() -> some View { modifier(GlassNeutralCircleSurface()) }
    func glassCircleSurface() -> some View { modifier(GlassCircleSurface()) }
    func glassCapsuleSurface() -> some View { modifier(GlassCapsuleSurface()) }
}

import SwiftUI

/// T-304/T-308: two plain, honest informational sheets -- neither is reached only
/// because something was flagged. `SafetySupportSheet` is the Settings > Safety support
/// screen; `SafetyNoticeSheet` is the one-time (then Settings-reachable) pilot
/// disclosure. Both read their copy from SafetyResourceCenter so the numbers/wording
/// live in exactly one place.
///
/// Nov 19 2026: both previously rendered on the system's default (light) sheet and
/// navigation-bar surfaces with Dwelly's cream text on top -- near-white on white,
/// unreadable (Kell's screenshot). `SafetySheetContainer` pins every surface to the
/// app's dark theme instead of inheriting the system appearance.
private struct SafetySheetContainer<Content: View>: View {
    let title: String
    let actionTitle: String
    let onAction: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    content
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(actionTitle, action: onAction)
                        .foregroundColor(Theme.gold)
                        .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
        .tint(Theme.gold)
    }
}

struct SafetySupportSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        SafetySheetContainer(title: "Support", actionTitle: "Done", onAction: { dismiss() }) {
            Text(SafetyResourceCenter.alwaysAvailableHelpText)
                .font(.system(size: 15))
                .foregroundColor(Theme.Capture.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct SafetyNoticeSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        SafetySheetContainer(title: "Before you begin", actionTitle: "Got it", onAction: { dismiss() }) {
            Text(SafetyResourceCenter.pilotNoticeText)
                .font(.system(size: 15))
                .foregroundColor(Theme.Capture.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    SafetyNoticeSheet()
}

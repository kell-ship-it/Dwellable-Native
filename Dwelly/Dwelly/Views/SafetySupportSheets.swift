import SwiftUI

/// T-304/T-308: two plain, honest informational sheets -- neither is reached only
/// because something was flagged. `SafetySupportSheet` is the always-available "Need
/// support now?" entry point; `SafetyNoticeSheet` is the one-time (then
/// Settings-reachable) pilot disclosure. Both read their copy from
/// SafetyResourceCenter so the numbers/wording live in exactly one place.
struct SafetySupportSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(SafetyResourceCenter.alwaysAvailableHelpText)
                        .font(.system(size: 15))
                        .foregroundColor(Theme.Payment.textHeading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
            }
            .navigationTitle("Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct SafetyNoticeSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(SafetyResourceCenter.pilotNoticeText)
                        .font(.system(size: 15))
                        .foregroundColor(Theme.Payment.textHeading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
            }
            .navigationTitle("Before you begin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Got it") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SafetySupportSheet()
}

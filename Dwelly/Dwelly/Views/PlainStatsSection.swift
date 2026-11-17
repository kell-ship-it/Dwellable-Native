import SwiftUI

/// T-140/T-141: "Your Plain Stats," pulled directly from Figma (`jBOzv1vO2C2DSMePqRl4c4`,
/// P11 Growth page, node 612:429 and its siblings across every Growth scenario frame).
/// The locked design (confirmed live via Figma MCP, Nov 16 2026) is narrower than
/// T-141's original ticket text: Prayer metrics were already stripped per Kell's Oct 20
/// call, and no second stat (Emotional Themes or otherwise) exists anywhere in the
/// current Growth page -- just one card, a plain count of captured Moments. Built to
/// match that reality rather than the stale ticket scope. "Total Prayers" isn't
/// included at all (not deferred, not stubbed) since Pillar 3 (Prayer) has no real
/// capture flow anywhere in the app yet -- there's nothing true to count.
struct PlainStatsSection: View {
    let userId: String
    @Environment(\.apiClient) private var apiClient

    @State private var momentCount: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("YOUR PLAIN STATS")
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.88)
                .foregroundColor(Theme.Payment.textSupporting)

            VStack(alignment: .leading, spacing: 4) {
                if let momentCount {
                    Text("\(momentCount)")
                        .font(.system(size: 30, design: .serif))
                        .foregroundColor(Theme.gold)
                    Text(momentCount == 1 ? "moment captured" : "moments captured")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.Payment.textSupporting)
                } else {
                    ProgressView().tint(Theme.gold)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Payment.backgroundSurface)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .task { await load() }
    }

    private func load() async {
        momentCount = (try? await apiClient.fetchMoments(userId: userId))?.count ?? 0
    }
}

#Preview {
    let apiClient = MockAPIClient()
    PlainStatsSection(userId: "preview-user")
        .padding()
        .background(Theme.Payment.background)
        .environment(\.apiClient, apiClient)
}

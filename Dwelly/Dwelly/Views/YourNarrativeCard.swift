import SwiftUI

/// T-275: "Your Narrative," pulled directly from Figma (`jBOzv1vO2C2DSMePqRl4c4`, P11
/// Growth page) -- node 595:200 ("Your Narrative — Tier 1") and node 603:224
/// ("Your Narrative — Pre-Threshold"). Reads the exact same `DwellerProfile.runningSummary`
/// T-274 already generates store-and-show-only -- this is that same data, just shown in
/// its real, designed home instead of the throwaway Settings screen T-274 first used.
///
/// Matches T-163's already-design-complete confirm/correct spec, though T-163's own full
/// backend (T-162/T-164) doesn't exist yet -- see below.
///
/// T-161's real threshold is now wired in (Nov 11 2026, confirmed with Kell): 0-2
/// qualifying reflections = Pre-Threshold copy, 3+ = Tier 1 unlocks. "Qualifying
/// reflection" here means an approved (synthesized) `JournalEntry` -- a pending one has
/// no real content yet, so it doesn't count. No visible count/countdown is shown in the
/// 0-2 state, per the locked spec's own anti-gaming decision -- the soft "still forming"
/// copy never hints how close someone is. The one remaining simplification: T-161's full
/// design also has a 6+ "deepens" Tier 2, which is explicitly Post-MVP and not built here.
///
/// Confirm/correct here is still visual only -- "Yes, that's me" and "Not quite" match
/// T-161's locked spec (Yes logs silently with no visible state change; Not quite opens a
/// free-text field), but there's no reassessment engine yet for "Not quite" to actually
/// feed into -- submitting it has nowhere real to go until T-162/T-164 are built, so it's
/// disabled with a short explanation rather than faking a submission that does nothing.
struct YourNarrativeCard: View {
    let userId: String
    @Environment(\.apiClient) private var apiClient

    @State private var profile: DwellerProfile?
    @State private var qualifyingReflectionCount = 0
    @State private var isLoading = true
    @State private var showNotQuiteField = false
    @State private var confirmedThisSession = false

    private static let unlockThreshold = 3

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    var body: some View {
        Group {
            if isLoading {
                // NOT EmptyView() -- a Group whose first-render branch resolves to
                // EmptyView never fires .task below (confirmed empirically: a sibling
                // view rendered instantly while this stayed stuck forever). SwiftUI
                // appears to never mount lifecycle hooks for a container whose
                // resolved content is empty on first render.
                ProgressView().tint(Theme.gold)
            } else if qualifyingReflectionCount >= Self.unlockThreshold, let summary = profile?.runningSummary, !summary.isEmpty {
                tierOneCard(summary: summary)
            } else {
                preThresholdCard
            }
        }
        .task { await load() }
    }

    private func tierOneCard(summary: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                // Relabeled from Figma's literal "YOUR NARRATIVE" per Kell's direct ask
                // (Nov 11 2026), choosing this over "Dwelly Profile" when given both options.
                Text("YOUR SPIRITUAL JOURNEY")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.88)
                    .foregroundColor(Theme.gold)
                Spacer()
                if let updatedAt = profile?.updatedAt {
                    Text("Updated \(Self.relativeFormatter.localizedString(for: updatedAt, relativeTo: Date()))")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.Payment.textFaint)
                }
            }

            Text(summary)
                .font(.system(size: 18, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)
                .lineSpacing(4)

            Text("Generated from your own moments. Never shared.")
                .font(.system(size: 11))
                .foregroundColor(Theme.Payment.textFaint)

            VStack(alignment: .leading, spacing: 10) {
                Text("Does this feel true to you?")
                    .font(.system(size: 12.5))
                    .foregroundColor(Theme.Payment.textSupporting)

                HStack(spacing: 10) {
                    Button(action: { confirmedThisSession = true }) {
                        Text("Yes, that's me")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Theme.Payment.backgroundPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                    .background(Theme.gold)
                    .clipShape(Capsule())
                    // Spec: logs silently, no visible confirmation state -- the only
                    // user-visible feedback is the button becoming inert.
                    .disabled(confirmedThisSession)
                    .opacity(confirmedThisSession ? 0.6 : 1.0)

                    Button(action: { showNotQuiteField = true }) {
                        Text("Not quite")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Theme.Payment.textSupporting)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                    .background(Theme.Payment.pillBackground)
                    .clipShape(Capsule())
                }

                if showNotQuiteField {
                    Text("Feedback isn't connected to anything yet — this needs the reassessment engine (T-161) before \"Not quite\" can actually do something with what you tell it.")
                        .font(.system(size: 11))
                        .foregroundColor(Theme.Payment.textFaint)
                        .padding(.top, 2)
                }
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Payment.surfaceCard)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.Capture.journalCardBorder, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var preThresholdCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Your story is still forming. Keep capturing — we'll start reflecting it back to you soon.")
                .font(.system(size: 18, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)
                .lineSpacing(4)

            Text("A few more moments and we'll start noticing your story.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.gold)

            Text("Generated from your own moments.")
                .font(.system(size: 11))
                .foregroundColor(Theme.Payment.textFaint)
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Payment.surfaceCard)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.Capture.journalCardBorder, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func load() async {
        isLoading = true
        profile = try? await apiClient.fetchDwellerProfile(userId: userId)
        let approved = try? await apiClient.fetchApprovedJournalEntries(userId: userId)
        qualifyingReflectionCount = approved?.count ?? 0
        isLoading = false
    }
}

#Preview {
    let apiClient = MockAPIClient()
    ScrollView {
        YourNarrativeCard(userId: "preview-user")
            .padding()
    }
    .background(Theme.Payment.background)
    .environment(\.apiClient, apiClient)
}

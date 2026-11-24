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
/// T-163 (Nov 16 2026): confirm/correct is now real, not visual-only. "Yes, that's me"
/// persists `DwellerProfile.confirmedAt` for real (survives app restart; a narrative
/// regenerated after that timestamp goes back to unconfirmed -- see `DwellerProfile.
/// isConfirmed`), matching the locked "Narrative Confirmed" state pulled directly from
/// Figma (node 606:368). "Not quite" reveals a real free-text field + Submit (node
/// 606:290/606:298), which writes to a new `narrative_feedback` table -- a genuine
/// capture, not a fake submission. What's still NOT built: nothing reads this feedback
/// back into regenerating the narrative (T-164, the internal reassessment engine, and
/// T-160/161/162 underneath it are all still not started), so there's no "Narrative
/// Regenerating"/"Narrative Regenerated" state here -- submitting just thanks the user,
/// same honest line T-163's own history already drew around "nowhere real to go yet."
struct YourNarrativeCard: View {
    let userId: String
    /// Bumped by MainTabView each time a conversation closes; tabs stay mounted (custom tab
    /// bar), so this is what re-loads data that a new save changed (Nov 24 2026).
    var refreshKey: Int = 0
    @Environment(\.apiClient) private var apiClient

    @State private var profile: DwellerProfile?
    @State private var qualifyingReflectionCount = 0
    @State private var isLoading = true
    @State private var showNotQuiteField = false
    @State private var feedbackText = ""
    @State private var isSubmittingFeedback = false
    @State private var feedbackSubmitted = false
    @State private var isConfirming = false

    private static let unlockThreshold = DwellerProfileManager.narrativeUnlockThreshold

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
        .task(id: refreshKey) { await load() }
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

            if profile?.isConfirmed == true {
                // Figma node 606:359/606:364/606:365/606:366 -- the real "Confirmed" state.
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(Theme.success)
                        Text("Confirmed")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.success)
                    }
                    Text("Thanks for telling us. This helps your Narrative stay accurate.")
                        .font(.system(size: 12.5))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .lineSpacing(2)
                }
                .padding(.top, 4)
            } else if feedbackSubmitted {
                Text("Thanks for telling us what feels off.")
                    .font(.system(size: 12.5))
                    .foregroundColor(Theme.Payment.textSupporting)
                    .padding(.top, 4)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Does this feel true to you?")
                        .font(.system(size: 12.5))
                        .foregroundColor(Theme.Payment.textSupporting)

                    HStack(spacing: 10) {
                        Button(action: { Task { await confirmNarrative() } }) {
                            if isConfirming {
                                ProgressView().tint(Theme.Payment.backgroundPrimary)
                                    .frame(height: 16)
                            } else {
                                Text("Yes, that's me")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Theme.Payment.backgroundPrimary)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Theme.gold)
                        .clipShape(Capsule())
                        .disabled(isConfirming)

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

                    // Figma node 606:290 -- the real "Feedback Open" form.
                    if showNotQuiteField {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What feels off, or what's missing?")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.Payment.textHeading)

                            TextField("", text: $feedbackText, axis: .vertical)
                                .font(.system(size: 13))
                                .foregroundColor(Theme.Payment.textHeading)
                                .tint(Theme.gold)
                                .lineLimit(3...6)
                                .padding(14)
                                .background(Theme.inputBackground)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.Payment.borderDivider, lineWidth: 1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            HStack {
                                Spacer()
                                Button(action: { Task { await submitFeedback() } }) {
                                    if isSubmittingFeedback {
                                        ProgressView().tint(Theme.Payment.backgroundPrimary)
                                            .frame(width: 14, height: 14)
                                            .padding(.horizontal, 18)
                                            .padding(.vertical, 10)
                                    } else {
                                        Text("Submit \u{203a}")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(Theme.Payment.backgroundPrimary)
                                            .padding(.horizontal, 18)
                                            .padding(.vertical, 10)
                                    }
                                }
                                .background(Theme.gold)
                                .clipShape(Capsule())
                                .disabled(isSubmittingFeedback || feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                .opacity(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                            }
                        }
                        .padding(.top, 2)
                    }
                }
                .padding(.top, 4)
            }
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

            // Nov 24 2026 (Kell): show real progress toward the first narrative, so
            // there's something to look forward to.
            let shown = min(qualifyingReflectionCount, Self.unlockThreshold)
            VStack(alignment: .leading, spacing: 8) {
                Text("\(shown) of \(Self.unlockThreshold) reflections")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.gold)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.gold.opacity(0.15))
                        Capsule().fill(Theme.gold)
                            .frame(width: geo.size.width * CGFloat(shown) / CGFloat(Self.unlockThreshold))
                    }
                }
                .frame(height: 4)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(shown) of \(Self.unlockThreshold) reflections toward your spiritual journey")

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
        // Only the first load shows the spinner; a refresh updates quietly in place.
        if profile == nil && qualifyingReflectionCount == 0 { isLoading = true }
        profile = try? await apiClient.fetchDwellerProfile(userId: userId)
        let allApproved = (try? await apiClient.fetchApprovedJournalEntries(userId: userId)) ?? []
        // T-161/T-127 (rebuilt Nov 17 2026): the validity floor this ticket always
        // described ("must contain genuine content, not spam/repeated-character junk")
        // never actually filtered anything -- every approved entry counted, full stop.
        // Filters on the real, independent `formationEligible` column now -- NOT on
        // scriptureQuote presence, which was flagged as the wrong proxy during review
        // (a below-floor capture could carry a fake fallback verse on a hard LLM
        // failure, and the old prompt forced a verse onto every entry regardless of
        // whether anything was actually discernible).
        let approved = allApproved.filter { $0.formationEligible }
        let feedback = (try? await apiClient.fetchNarrativeFeedback(userId: userId)) ?? []
        // T-161/T-164: "Not quite" feedback counts toward the threshold exactly like a
        // captured moment -- same list, same weight, not a separate lesser category.
        qualifyingReflectionCount = approved.count + feedback.count

        if let regenerated = await DwellerProfileManager.regenerateIfNeeded(
            userId: userId,
            currentProfile: profile,
            approvedEntries: approved,
            feedback: feedback,
            apiClient: apiClient
        ) {
            profile = regenerated
        }
        isLoading = false
    }

    private func confirmNarrative() async {
        isConfirming = true
        if let confirmed = try? await apiClient.confirmDwellerProfile(userId: userId) {
            profile = confirmed
        }
        isConfirming = false
    }

    private func submitFeedback() async {
        let trimmed = feedbackText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isSubmittingFeedback = true
        if (try? await apiClient.submitNarrativeFeedback(userId: userId, feedbackText: trimmed, narrativeAtTime: profile?.runningSummary)) != nil {
            feedbackSubmitted = true
            showNotQuiteField = false
            feedbackText = ""
        }
        isSubmittingFeedback = false
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

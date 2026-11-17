import SwiftUI

/// T-161/T-164 follow-up (Nov 16 2026). Kell wanted to compare how different
/// combinations/quality of reflections shape the generated narrative -- "1 alone" vs
/// "1 and 2" vs "1, 2, and 7," with and without a "Not quite" correction in the mix.
/// A first pass at this directly manipulated real data (flipping journal_entries.status
/// to exclude entries from a combination), which turned out to have a real, partly
/// irreversible side effect: `SyncManager.retryPendingJournalEntries` treats any
/// `pending` entry as unsynthesized and silently re-runs the LLM on it from scratch,
/// overwriting title/body/moods/scripture. Five real entries got rewritten before that
/// was caught; body text was restored exactly from a snapshot taken first, but
/// title/moods/scripture on those five couldn't be perfectly recovered.
///
/// This view is the fix for how to experiment safely going forward: it calls
/// `DwellerProfileManager.generateNarrative` directly (the pure half of
/// `regenerateIfNeeded`, split out for exactly this) on whatever subset of the user's
/// REAL approved entries/feedback they check -- read-only throughout. Nothing here
/// ever writes to journal_entries, dweller_profiles, or narrative_feedback. DEBUG-only,
/// reached from a dev-only row on Growth (see `GrowthPlaceholderView`).
struct NarrativeExperimentView: View {
    @Environment(\.apiClient) private var apiClient
    @Environment(\.dismiss) var dismiss
    let userId: String

    @State private var entries: [JournalEntry] = []
    @State private var feedback: [NarrativeFeedback] = []
    @State private var selectedEntryIds: Set<String> = []
    @State private var selectedFeedbackIds: Set<String> = []
    @State private var isLoading = true
    @State private var isGenerating = false
    @State private var result: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView().tint(Theme.gold)
                } else {
                    List {
                        Section("Journal entries (real, read-only)") {
                            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                                Button(action: { toggle(entryId: entry.id) }) {
                                    HStack {
                                        Image(systemName: selectedEntryIds.contains(entry.id) ? "checkmark.square.fill" : "square")
                                            .foregroundColor(selectedEntryIds.contains(entry.id) ? Theme.gold : Theme.Payment.textSupporting)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("\(index + 1). \(entry.title ?? "Untitled")")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(Theme.Payment.textHeading)
                                            Text(entry.body ?? "")
                                                .font(.system(size: 12))
                                                .foregroundColor(Theme.Payment.textSupporting)
                                                .lineLimit(2)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        if !feedback.isEmpty {
                            Section("\"Not quite\" feedback (real, read-only)") {
                                ForEach(feedback) { item in
                                    Button(action: { toggle(feedbackId: item.id) }) {
                                        HStack {
                                            Image(systemName: selectedFeedbackIds.contains(item.id) ? "checkmark.square.fill" : "square")
                                                .foregroundColor(selectedFeedbackIds.contains(item.id) ? Theme.gold : Theme.Payment.textSupporting)
                                            Text(item.feedbackText)
                                                .font(.system(size: 13))
                                                .foregroundColor(Theme.Payment.textHeading)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        Section {
                            Button(action: { Task { await generate() } }) {
                                if isGenerating {
                                    ProgressView().tint(Theme.gold)
                                } else {
                                    Text("Generate Preview (\(selectedEntryIds.count + selectedFeedbackIds.count) selected)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Theme.gold)
                                }
                            }
                            .disabled(isGenerating || (selectedEntryIds.isEmpty && selectedFeedbackIds.isEmpty))
                        }

                        if let result {
                            Section("PREVIEW ONLY -- nothing saved") {
                                Text(result)
                                    .font(.system(size: 15, design: .serif))
                                    .foregroundColor(Theme.Payment.textHeading)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Narrative Experiment")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .task { await load() }
    }

    private func toggle(entryId: String) {
        if selectedEntryIds.contains(entryId) { selectedEntryIds.remove(entryId) } else { selectedEntryIds.insert(entryId) }
    }

    private func toggle(feedbackId: String) {
        if selectedFeedbackIds.contains(feedbackId) { selectedFeedbackIds.remove(feedbackId) } else { selectedFeedbackIds.insert(feedbackId) }
    }

    private func load() async {
        isLoading = true
        entries = (try? await apiClient.fetchApprovedJournalEntries(userId: userId))?.sorted { $0.createdAt < $1.createdAt } ?? []
        feedback = (try? await apiClient.fetchNarrativeFeedback(userId: userId)) ?? []
        isLoading = false
    }

    private func generate() async {
        isGenerating = true
        result = await DwellerProfileManager.generateNarrative(
            userId: userId,
            approvedEntries: entries.filter { selectedEntryIds.contains($0.id) },
            feedback: feedback.filter { selectedFeedbackIds.contains($0.id) },
            apiClient: apiClient
        ) ?? "(Model returned nothing for this combination.)"
        isGenerating = false
    }
}

import SwiftUI

/// The real "Dwelly Responds" conversation (Figma `jBOzv1vO2C2DSMePqRl4c4`, node 38:246,
/// "Scenario 2: Dwelly Responds") — the piece of P1 Capture that was blocked on T-168
/// (Shared LLM Proxy Service) until it existed. Up to 3 of Dwelly's responses per the
/// locked design's "Response N of 3" counter, then the conversation closes and the whole
/// exchange is saved as one moment.
///
/// Scoped to the typed-text entry path only (CaptureView's compose pill → here). Voice
/// capture still goes through the separate, unchanged ReviewView save path — folding
/// voice into this same conversational flow is real additional scope, not done here.
struct CaptureConversationView: View {
    let userId: String
    let userEmail: String?
    let syncManager: SyncManager
    let initialMessage: String
    var onMomentSaved: (() -> Void)?

    @Environment(\.apiClient) private var apiClient
    @FocusState private var inputFocused: Bool

    private struct Turn: Identifiable {
        let id = UUID()
        let role: LLMMessage.Role
        let text: String
    }

    @State private var turns: [Turn] = []
    @State private var inputText = ""
    @State private var isWaitingForDwelly = false
    @State private var isSaving = false
    @State private var isSyncPending = false
    @State private var errorMessage: String?

    private let maxResponses = 3
    private var dwellyResponseCount: Int { turns.filter { $0.role == .assistant }.count }
    private var isConversationComplete: Bool { dwellyResponseCount >= maxResponses }

    /// Kept short and narrow on purpose — this is a first real wiring of T-168 into a
    /// feature, not a tuned persona. Revisit once there's an actual conversation to judge
    /// tone against.
    private let systemPrompt = """
    You are Dwelly, a warm, compassionate companion helping someone reflect honestly on \
    a moment with God today. Respond in 1-2 short sentences. Ask one gentle, Socratic \
    follow-up question that helps them go deeper — don't lecture, don't quote scripture \
    unless it truly fits, don't be clinical. You have at most 3 responses in this \
    conversation before it naturally closes.
    """

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Image("DwellyRockIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 28)
                .padding(.top, 14)

                if dwellyResponseCount > 0 {
                    HStack {
                        Text("Response \(dwellyResponseCount) of \(maxResponses)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Theme.Payment.textSupporting)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(turns) { turn in
                                turnBubble(turn)
                                    .id(turn.id)
                            }
                            if isWaitingForDwelly {
                                dwellyBadge
                                ProgressView()
                                    .tint(Theme.gold)
                                    .padding(.leading, 24)
                                    .id("spinner")
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 24)
                    }
                    .onChange(of: turns.count) { _ in
                        withAnimation { proxy.scrollTo(turns.last?.id, anchor: .bottom) }
                    }
                    .onChange(of: isWaitingForDwelly) { waiting in
                        if waiting { withAnimation { proxy.scrollTo("spinner", anchor: .bottom) } }
                    }
                }
            }

            VStack(spacing: 12) {
                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.error)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                }

                if isConversationComplete {
                    Button(action: { Task { await finishAndSave() } }) {
                        if isSaving {
                            ProgressView().tint(Theme.Payment.backgroundPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                        } else {
                            Text("Save Your Moment")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.Payment.backgroundPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                        }
                    }
                    .background(Theme.gold)
                    .clipShape(Capsule())
                    .disabled(isSaving)
                    .padding(.horizontal, 28)
                    .padding(.bottom, Theme.Spacing.xxl)
                } else {
                    HStack(spacing: 8) {
                        TextField("", text: $inputText, prompt: Text("Share what's on your mind...").foregroundColor(Theme.Capture.textMuted), axis: .vertical)
                            .font(.system(size: 16))
                            .foregroundColor(Theme.Capture.textPrimary)
                            .tint(Theme.gold)
                            .focused($inputFocused)
                            .submitLabel(.done)
                            .onSubmit { sendUserTurn() }
                            .disabled(isWaitingForDwelly)

                        Button(action: sendUserTurn) {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.goldDark)
                                .frame(width: 44, height: 44)
                                .background(Theme.gold)
                                .clipShape(Circle())
                        }
                        .disabled(isWaitingForDwelly || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(isWaitingForDwelly ? 0.5 : 1.0)
                    }
                    .padding(.leading, 20)
                    .padding(.trailing, 8)
                    .frame(height: 60)
                    .background(Theme.Capture.cardBackground)
                    .clipShape(Capsule())
                    .padding(.horizontal, 24)
                    .padding(.bottom, Theme.Spacing.xxl)
                }
            }
            .background(
                LinearGradient(colors: [Theme.background.opacity(0), Theme.background], startPoint: .top, endPoint: .bottom)
                    .frame(height: 180)
                    .allowsHitTesting(false),
                alignment: .top
            )
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            turns = [Turn(role: .user, text: initialMessage)]
            Task { await requestDwellyResponse() }
        }
    }

    @ViewBuilder
    private func turnBubble(_ turn: Turn) -> some View {
        switch turn.role {
        case .user:
            HStack {
                Spacer(minLength: 56)
                Text(turn.text)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.Payment.backgroundPrimary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Theme.Capture.userBubble)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        case .assistant:
            VStack(alignment: .leading, spacing: 6) {
                dwellyBadge
                Text(turn.text)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.Capture.textBody)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: 280, alignment: .leading)
                    .background(Theme.Capture.cardBackground)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.Capture.cardBorder, lineWidth: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        case .system:
            EmptyView()
        }
    }

    private var dwellyBadge: some View {
        HStack(spacing: 6) {
            Circle().fill(Theme.gold).frame(width: 4, height: 4)
            Text("dwelly")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(Theme.gold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background(Theme.Capture.badgeBackground)
        .overlay(Capsule().stroke(Theme.gold, lineWidth: 1.5))
        .clipShape(Capsule())
    }

    private func sendUserTurn() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isWaitingForDwelly else { return }
        inputText = ""
        turns.append(Turn(role: .user, text: text))
        Task { await requestDwellyResponse() }
    }

    private func requestDwellyResponse() async {
        guard !isConversationComplete else { return }
        isWaitingForDwelly = true
        errorMessage = nil

        var messages = [LLMMessage(role: .system, content: systemPrompt)]
        messages.append(contentsOf: turns.map { LLMMessage(role: $0.role, content: $0.text) })

        do {
            let response = try await apiClient.callLLM(messages: messages, feature: "capture_conversation")
            await MainActor.run {
                turns.append(Turn(role: .assistant, text: response.content))
                isWaitingForDwelly = false
            }
        } catch {
            await MainActor.run {
                isWaitingForDwelly = false
                errorMessage = "Dwelly couldn't respond just now. You can keep writing, or save what you have."
            }
            HTMLLogManager.shared.log("llm-proxy call failed: \(error.localizedDescription)", level: "ERROR")
        }
    }

    private func finishAndSave() async {
        isSaving = true
        errorMessage = nil

        let combinedBody = turns
            .filter { $0.role == .user }
            .map(\.text)
            .joined(separator: "\n\n")

        let moment = Moment(userId: userId, body: combinedBody, createdAt: Date())

        do {
            _ = try await apiClient.saveMoment(moment)
            UsageTracker.shared.logMomentCreated(userId: userId, userEmail: userEmail, type: "text")
            Task { try? await UsageTracker.shared.syncEventsToBackend(userId: userId, apiClient: apiClient) }
            await MainActor.run {
                isSaving = false
                onMomentSaved?()
            }
        } catch {
            syncManager.markMomentAsPending(moment)
            UsageTracker.shared.logMomentCreated(userId: userId, userEmail: userEmail, type: "text")
            Task { try? await UsageTracker.shared.syncEventsToBackend(userId: userId, apiClient: apiClient) }
            await MainActor.run {
                isSyncPending = true
                isSaving = false
                onMomentSaved?()
            }
        }
    }
}

#Preview {
    let apiClient = MockAPIClient()
    NavigationStack {
        CaptureConversationView(
            userId: "preview-user",
            userEmail: "preview@example.com",
            syncManager: SyncManager(apiClient: apiClient, userId: "preview-user"),
            initialMessage: "I felt God's presence today in a quiet moment.",
            onMomentSaved: nil
        )
    }
    .environment(\.apiClient, apiClient)
}

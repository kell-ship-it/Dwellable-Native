import SwiftUI

struct TypeFlowView: View {
    @Environment(\.dismiss) var dismiss
    @State private var momentBody: String = ""
    @State private var senseOfLord: String = ""
    @State private var isSaving = false
    @State private var saveError: String?
    @State private var isSyncPending = false

    let apiClient: APIClient
    let userId: String
    let syncManager: SyncManager
    var onMomentSaved: (() -> Void)?

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button
                HStack(spacing: 4) {
                    Button(action: { dismiss() }) {
                        Text("‹")
                            .font(.system(size: 20))
                            .foregroundColor(Theme.tertiaryText)
                    }
                    Button(action: { dismiss() }) {
                        Text("Moments")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Theme.tertiaryText)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

                // Body content
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 10)

                    // Save error display
                    if let errorMessage = saveError {
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(Color(red: 0.95, green: 0.2, blue: 0.2))
                                Text(errorMessage)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(Color(red: 0.95, green: 0.2, blue: 0.2))
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(red: 0.95, green: 0.2, blue: 0.2, opacity: 0.1))
                            .cornerRadius(8)

                            Button(action: {
                                saveError = nil
                            }) {
                                Text("Dismiss")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(red: 0.95, green: 0.2, blue: 0.2))
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }

                    TextEditor(text: $momentBody)
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(momentBody.isEmpty ? Color(red: 0.184, green: 0.188, blue: 0.22) : Theme.text)
                        .tint(Theme.gold)
                        .lineSpacing(1.8)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)
                        .accessibilityIdentifier("moment_body")

                    // Sense of Lord field
                    TextField("Add where you sensed the Lord, if at all...", text: $senseOfLord)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(senseOfLord.isEmpty ? Color(red: 0.184, green: 0.188, blue: 0.22) : Color(red: 0.227, green: 0.239, blue: 0.271))
                        .padding(.top, 12)
                        .accessibilityIdentifier("sense_of_lord")
                }
                .padding(.horizontal, 20)

                Spacer()

                // Footer button - full width
                Button(action: {
                    Task {
                        await saveMoment()
                    }
                }) {
                    if isSaving {
                        ProgressView()
                            .tint(Color(red: 0.1, green: 0.08, blue: 0.05))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    } else {
                        Text("Save moment")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.05))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                    }
                }
                .background(Theme.gold)
                .cornerRadius(20)
                .disabled(isSaving || momentBody.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(isSaving || momentBody.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .padding(.bottom, 20)
                .accessibilityIdentifier("Save")
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func saveMoment() async {
        guard !momentBody.trimmingCharacters(in: .whitespaces).isEmpty else {
            saveError = "Moment cannot be empty"
            return
        }

        isSaving = true
        saveError = nil
        isSyncPending = false

        let moment = Moment(
            userId: userId,
            body: momentBody,
            senseOfLord: senseOfLord.isEmpty ? nil : senseOfLord,
            createdAt: Date()
        )

        do {
            _ = try await apiClient.saveMoment(moment)
            print("✅ TypeFlowView: save succeeded")
            await MainActor.run {
                isSaving = false
                onMomentSaved?()
            }
        } catch {
            print("🔴 TypeFlowView: save failed - \(error)")
            syncManager.markMomentAsPending(moment)
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
        TypeFlowView(apiClient: apiClient, userId: "preview-user", syncManager: SyncManager(apiClient: apiClient), onMomentSaved: nil)
    }
}

import SwiftUI

struct ReviewView: View {
    @Environment(\.dismiss) var dismiss
    @State private var momentBody: String = ""
    @State private var senseOfLord: String = ""

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 3) {
                            Text("‹")
                                .font(.system(size: 22))
                            Text("Moments")
                                .font(.system(size: 15, weight: .regular))
                        }
                        .foregroundColor(Theme.tertiaryText)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)

                // Textarea for moment body
                VStack(spacing: 0) {
                    TextEditor(text: $momentBody)
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(Theme.text)
                        .tint(Theme.gold)
                        .padding(12)
                        .padding(.top, 12)
                        .lineSpacing(1.8)

                    // Hint text for sense of Lord
                    TextEditor(text: $senseOfLord)
                        .font(.system(size: 13, weight: .regular))
                        .italic()
                        .foregroundColor(senseOfLord.isEmpty ? Color(red: 0.16, green: 0.18, blue: 0.21) : Theme.tertiaryText)
                        .tint(Theme.gold)
                        .frame(height: 50)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)

                Spacer()

                // Footer buttons
                HStack(spacing: 10) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Text("↩")
                                .font(.system(size: 16))
                            Text("Re-record")
                                .font(.system(size: 14, weight: .regular))
                        }
                        .foregroundColor(Theme.tertiaryText)
                        .padding(.vertical, 15)
                        .padding(.horizontal, 18)
                        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.04))
                        .border(Color(red: 0.6, green: 0.64, blue: 0.71, opacity: 0.2), width: 1)
                        .cornerRadius(20)
                    }

                    Button(action: {}) {
                        Text("Save")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.05))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Theme.gold)
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        ReviewView()
    }
}

import SwiftUI

struct TypeFlowView: View {
    @Environment(\.dismiss) var dismiss
    @State private var momentBody: String = ""
    @State private var senseOfLord: String = ""

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

                    TextEditor(text: $momentBody)
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(momentBody.isEmpty ? Color(red: 0.184, green: 0.188, blue: 0.22) : Theme.text)
                        .tint(Theme.gold)
                        .lineSpacing(1.8)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)

                    // Hint text
                    Text("Add where you sensed the Lord, if at all...")
                        .font(.system(size: 16, weight: .regular))
                        .italic()
                        .foregroundColor(senseOfLord.isEmpty ? Color(red: 0.184, green: 0.188, blue: 0.22) : Color(red: 0.227, green: 0.239, blue: 0.271))
                        .padding(.top, 12)
                }
                .padding(.horizontal, 20)

                Spacer()

                // Footer button - full width
                Button(action: {}) {
                    Text("Save moment")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.05))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Theme.gold)
                        .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        TypeFlowView()
    }
}

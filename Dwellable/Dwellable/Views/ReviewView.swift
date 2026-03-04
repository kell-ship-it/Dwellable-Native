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
                        Text("< Moments")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Theme.tertiaryText)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Spacer()
                    .frame(height: 20)

                ZStack {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(Color(red: 0.4, green: 0.42, blue: 0.46), lineWidth: 1.5)
                            .frame(width: CGFloat(100 + index * 20), height: CGFloat(100 + index * 20))
                    }

                    Image(systemName: "mic.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.05))
                        .frame(width: 80, height: 80)
                        .background(Theme.gold)
                        .clipShape(Circle())
                }

                Spacer()
                    .frame(height: 40)

                VStack(spacing: 16) {
                    TextEditor(text: $momentBody)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Theme.text)
                        .tint(Theme.gold)
                        .frame(height: 120)
                        .padding(16)
                        .background(Color(red: 0.07, green: 0.07, blue: 0.09))
                        .cornerRadius(14)

                    TextEditor(text: $senseOfLord)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Theme.text)
                        .tint(Theme.gold)
                        .frame(height: 80)
                        .padding(16)
                        .background(Color(red: 0.07, green: 0.07, blue: 0.09))
                        .cornerRadius(14)

                    Button(action: {}) {
                        Text("Save moment")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.05))
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(Theme.gold)
                            .cornerRadius(22)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
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

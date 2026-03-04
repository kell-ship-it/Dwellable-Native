import SwiftUI

struct CaptureView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showReview = false

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
                .padding(.horizontal, 20)
                .padding(.vertical, 10)

                Spacer()

                // Mic button with rings
                ZStack {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(
                                Color(red: 0.78, green: 0.69, blue: 0.48, opacity: [0.08, 0.14, 0.22][index]),
                                lineWidth: 1
                            )
                            .frame(width: CGFloat(160 - index * 40), height: CGFloat(160 - index * 40))
                    }

                    Button(action: {
                        showReview = true
                    }) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.05))
                            .frame(width: 80, height: 80)
                            .background(Theme.gold)
                            .clipShape(Circle())
                    }
                }
                .frame(width: 160, height: 160)

                Spacer()
                    .frame(height: 32)

                // Text
                Text("Tap to capture")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(Theme.text)

                Text("speak freely — we'll handle the rest")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Theme.tertiaryText)

                Spacer()

                // Waveform
                HStack(alignment: .center, spacing: 4) {
                    ForEach([5, 13, 20, 9, 24, 15, 7, 19, 22, 11, 5], id: \.self) { height in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(red: 0.6, green: 0.64, blue: 0.71, opacity: 0.12))
                            .frame(width: 3, height: CGFloat(height))
                    }
                }
                .frame(height: 28)
                .padding(.bottom, 32)

                // Type instead button
                Button(action: {
                    showReview = true
                }) {
                    Text("type instead →")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Theme.tertiaryText)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 18)
                        .background(Color(red: 1, green: 1, blue: 1, opacity: 0.04))
                        .border(Color(red: 0.6, green: 0.64, blue: 0.71, opacity: 0.12), width: 1)
                        .cornerRadius(20)
                }

                Spacer()
                    .frame(height: 36)
            }
            .padding(.horizontal, 28)
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showReview) {
            ReviewView()
        }
    }
}

#Preview {
    NavigationStack {
        CaptureView()
    }
}

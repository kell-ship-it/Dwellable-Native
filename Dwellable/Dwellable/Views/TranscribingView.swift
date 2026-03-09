import SwiftUI

struct TranscribingView: View {
    @State private var isAnimating = false
    var onComplete: (() -> Void)?

    var body: some View {
        ZStack {
            // Semi-transparent dark background
            Color(red: 0.1, green: 0.08, blue: 0.05)
                .opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Subtle pulsing indicator (gentle, non-distracting)
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Theme.gold)
                            .frame(width: 6, height: 6)
                            .opacity(isAnimating ? 0.8 : 0.3)
                            .animation(
                                Animation.easeInOut(duration: 0.8)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(0.15 * CGFloat(index))),
                                value: isAnimating
                            )
                    }
                }
                .frame(height: 6)

                // Label
                Text("Processing moment...")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Theme.secondaryText)
            }
        }
        .onAppear {
            isAnimating = true
            // Fixed 5-second display duration
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                onComplete?()
            }
        }
    }
}

#Preview {
    TranscribingView()
}

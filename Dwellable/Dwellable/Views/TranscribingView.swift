import SwiftUI

struct TranscribingView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Semi-transparent dark background
            Color(red: 0.1, green: 0.08, blue: 0.05)
                .opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Animated bars
                HStack(alignment: .center, spacing: 6) {
                    ForEach([0.2, 0.4, 0.8, 0.5, 1.0], id: \.self) { heightMultiplier in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Theme.gold)
                            .frame(width: 4, height: 32 * CGFloat(heightMultiplier))
                            .scaleEffect(y: isAnimating ? 0.6 : 1.0, anchor: .center)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(0.1 * CGFloat(Array([0.2, 0.4, 0.8, 0.5, 1.0]).firstIndex(of: heightMultiplier) ?? 0))),
                                value: isAnimating
                            )
                    }
                }
                .frame(height: 40)

                // Animated dot
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Theme.gold)
                            .frame(width: 8, height: 8)
                            .opacity(isAnimating && index == (isAnimating ? 1 : 0) ? 1.0 : 0.3)
                            .animation(
                                Animation.linear(duration: 0.6)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(0.2 * CGFloat(index))),
                                value: isAnimating
                            )
                    }
                }
                .frame(height: 8)

                // Label
                Text("Transcribing")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Theme.text)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    TranscribingView()
}

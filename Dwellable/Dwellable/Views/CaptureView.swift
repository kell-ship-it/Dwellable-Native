import SwiftUI

struct CaptureView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showVoiceReview = false
    @State private var showTypeFlow = false

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
                        showVoiceReview = true
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
                    showTypeFlow = true
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
        .navigationDestination(isPresented: $showVoiceReview) {
            ReviewView()
        }
        .navigationDestination(isPresented: $showTypeFlow) {
            TypeFlowView()
        }
    }
}

#Preview {
    NavigationStack {
        CaptureView()
    }
}

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

                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $momentBody)
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(Theme.text)
                            .tint(Theme.gold)
                            .lineSpacing(1.8)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)

                        // Placeholder overlay
                        if momentBody.isEmpty {
                            Text("Begin here...")
                                .font(.system(size: 20, weight: .light))
                                .foregroundColor(Color(red: 0.184, green: 0.188, blue: 0.22))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }

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

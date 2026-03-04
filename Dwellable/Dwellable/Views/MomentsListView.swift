import SwiftUI

struct MomentsListView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var moments: [Moment] = [
        Moment(userId: "test", body: "During worship this morning there was a stillness I haven't felt in weeks. Like something lifted. I stood there not wanting to move.", senseOfLord: "Yes, His presence was unmistakable.", createdAt: Date().addingTimeInterval(-86400 * 7)),
        Moment(userId: "test", body: "Coffee with an old friend. We talked about faith and doubt. It was honest and real.", senseOfLord: "In the vulnerability, I felt Christ's compassion.", createdAt: Date().addingTimeInterval(-86400 * 6)),
        Moment(userId: "test", body: "My daughter asked me why the sky is blue. In explaining it, I felt grateful for her curiosity and wonder.", createdAt: Date().addingTimeInterval(-86400 * 5)),
        Moment(userId: "test", body: "Read a passage that hit me differently today. Same words, but my heart was ready to hear them.", senseOfLord: "God's timing is perfect.", createdAt: Date().addingTimeInterval(-86400 * 4)),
        Moment(userId: "test", body: "Failed at something I was trying to do. But in the failure, I learned patience and trust.", createdAt: Date().addingTimeInterval(-86400 * 3)),
        Moment(userId: "test", body: "Sunset from the hiking trail. The colors were impossible. Felt small and safe at the same time.", senseOfLord: "Creation speaks of the Creator.", createdAt: Date().addingTimeInterval(-86400 * 2)),
        Moment(userId: "test", body: "A text from someone I'd been praying for. They're finding their way back. Small but significant.", createdAt: Date().addingTimeInterval(-86400 * 1)),
        Moment(userId: "test", body: "Quiet morning with scripture and coffee. No big revelation, just presence.", senseOfLord: "Peace that doesn't need explanation.", createdAt: Date().addingTimeInterval(-3600 * 12)),
        Moment(userId: "test", body: "Someone showed me kindness when I didn't expect it. Reminded me to do the same.", createdAt: Date().addingTimeInterval(-3600 * 6)),
        Moment(userId: "test", body: "Beginning to see how past struggles have shaped my compassion for others. There's redemption in that.", senseOfLord: "He wastes nothing.", createdAt: Date())
    ]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if moments.isEmpty {
                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 24) {
                        // Circle with dot
                        ZStack {
                            Circle()
                                .stroke(Color(red: 0.25, green: 0.27, blue: 0.31), lineWidth: 1)
                                .frame(width: 64, height: 64)

                            Circle()
                                .fill(Color(red: 0.6, green: 0.64, blue: 0.71))
                                .frame(width: 6, height: 6)
                        }

                        VStack(spacing: 12) {
                            Text("No moments yet.")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(Theme.text)

                            Text("Start small — a thought, a feeling, a prayer. Anything worth holding onto.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(Theme.secondaryText)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 220)
                        }

                        NavigationLink(destination: CaptureView()) {
                            Text("Capture your first moment")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.05))
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(Theme.gold)
                                .cornerRadius(22)
                        }
                        .padding(.horizontal, 32)
                    }

                    Spacer()
                }
            } else {
                VStack(spacing: 0) {
                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Moments")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(Theme.text)

                            Text("Document life. Discern over time.")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(Theme.secondaryText)
                        }

                        Spacer()

                        Button(action: {
                            authManager.signOut()
                        }) {
                            Text("Sign out")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(Theme.tertiaryText)
                        }
                    }
                    .padding(20)

                    List(moments) { moment in
                        NavigationLink(destination: MomentDetailView(moment: moment)) {
                            MomentRow(moment: moment)
                        }
                        .listRowBackground(Theme.background)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)

                    // Bottom "Capture moment" button
                    VStack {
                        NavigationLink(destination: CaptureView()) {
                            Text("Capture moment")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0.1, green: 0.08, blue: 0.05))
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .background(Theme.gold)
                                .cornerRadius(22)
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}

struct MomentRow: View {
    let moment: Moment

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(moment.body)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Theme.text)
                .lineLimit(2)

            Text(moment.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Theme.secondaryText)
        }
        .padding(12)
    }
}

#Preview {
    MomentsListView()
}

struct MomentDetailView: View {
    @Environment(\.dismiss) var dismiss
    let moment: Moment

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button with date
                VStack(alignment: .leading, spacing: 8) {
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

                    Text(moment.createdAt.formatted(date: .abbreviated, time: .omitted).uppercased())
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Theme.tertiaryText)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                // Full moment text
                VStack(spacing: 0) {
                    ScrollView {
                        Text(moment.body)
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(Theme.text)
                            .lineSpacing(1.8)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

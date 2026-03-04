import SwiftUI

struct MomentsListView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var moments: [Moment] = []

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
                        MomentRow(moment: moment)
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

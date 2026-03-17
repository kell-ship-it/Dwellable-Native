import SwiftUI

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

                // Audio link
                if let audioURL = moment.audioURL, !audioURL.isEmpty {
                    VStack(spacing: 12) {
                        Divider()
                            .padding(.vertical, 12)

                        let audioLink = "https://lhcjobrtmbawlhjyodxz.supabase.co/functions/v1/get-moment-audio?path=\(audioURL)"
                        Link(destination: URL(string: audioLink) ?? URL(fileURLWithPath: "")) {
                            HStack(spacing: 8) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .foregroundColor(Theme.gold)
                                Text("Listen to Audio")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Theme.gold)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Theme.gold.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 20)
                    }
                }

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    MomentDetailView(moment: Moment(
        userId: "test",
        body: "During worship this morning there was a stillness I haven't felt in weeks. God's presence felt so near and real.",
        createdAt: Date()
    ))
}

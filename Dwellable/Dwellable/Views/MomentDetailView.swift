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

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        MomentDetailView(moment: Moment(
            userId: "test",
            body: "During worship this morning there was a stillness I haven't felt in weeks. Like something lifted. I stood there not wanting to move.",
            createdAt: Date()
        ))
    }
}

import SwiftUI

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
    MomentRow(moment: Moment(
        userId: "test",
        body: "During worship this morning there was a stillness I haven't felt in weeks.",
        createdAt: Date()
    ))
    .background(Theme.background)
}

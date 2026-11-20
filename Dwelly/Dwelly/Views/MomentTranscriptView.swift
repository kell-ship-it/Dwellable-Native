import SwiftUI

/// Renders a saved reflection as the conversation it was -- Dwelly's prompts and the
/// user's answers, in order, each labeled. An older moment (plain user text, saved before
/// transcripts existed) renders exactly as it always did.
struct MomentTranscriptView: View {
    let moment: Moment
    var fontSize: CGFloat = 16

    var body: some View {
        if let turns = moment.transcriptTurns {
            VStack(alignment: .leading, spacing: 18) {
                ForEach(Array(turns.enumerated()), id: \.offset) { _, turn in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(turn.isUser ? "YOU" : "DWELLY")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(turn.isUser ? Theme.Payment.textSupporting : Theme.gold)
                        Text(turn.text)
                            .font(.system(size: fontSize, weight: .light))
                            .foregroundColor(turn.isUser ? Theme.Capture.textPrimary : Theme.Capture.textBody)
                            .lineSpacing(1.6)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        } else {
            Text(moment.body)
                .font(.system(size: fontSize, weight: .light))
                .foregroundColor(Theme.Capture.textBody)
                .lineSpacing(1.6)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

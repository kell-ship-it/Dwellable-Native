import SwiftUI

/// T-135/T-136: the real Today tab, pulled directly from Figma's locked "Today (MVP)"
/// frame (dwelly-redesign jBOzv1vO2C2DSMePqRl4c4, P10, node 570:508). This frame is the
/// real scope -- it has no "Unprayed Moment" card anywhere on it, so T-137 (hasPrayed
/// field + unprayed-moment query) doesn't apply to what actually ships here; Prayer (P3)
/// has zero code today regardless, so that section was correctly un-buildable either way.
///
/// The "Word for Today" verse and the 3 reflection tiles (Mood/Intercession/Life-Domain)
/// are static for MVP, not the LLM-generated daily prompt T-139 describes -- that's hard
/// blocked on Formation Intelligence's LLM path (P6), which doesn't exist yet. This is the
/// honest "Question Bank" fallback the docs already describe for exactly this situation,
/// not a placeholder pretending to be the real thing.
///
/// Tapping the verse or any tile opens a real capture conversation pre-opened with that
/// specific prompt via `CaptureConversationView`'s existing `initialMessage`/
/// `initialMessageIsPrompt` (built for onboarding's topic cards, just never had a caller
/// outside CaptureView's own grid until now) -- `onOpenPrompt` is threaded up to
/// `MainTabView`, which owns the actual `fullScreenCover` + paywall gate.
struct TodayView: View {
    let userId: String
    var onCapture: () -> Void
    var onOpenPrompt: (_ prompt: (title: String, category: String)) -> Void

    private var firstName: String? {
        let name = ProfileManager.shared.localProfile(userId: userId).name
        return (name?.isEmpty ?? true) ? nil : name
    }

    private var greeting: String {
        if let firstName { return "Hi \(firstName)." }
        return "Hi there."
    }

    private let verseReference = "Mark 9:24 · ESV"
    private let verseQuote = "\"Lord, I believe; help my unbelief.\""
    private let verseQuestion = "When you see this verse, what does that mean to you? What comes to mind?"

    private let tiles: [(icon: String, category: String, title: String, subtitle: String)] = [
        ("heart", "Mood", "What are you grateful for today?", "Even something small counts."),
        ("hands.sparkles", "Intercession", "Anyone on your heart lately?", "Worth a thought right now."),
        ("mountain.2", "Life-Domain", "Have you had any dreams lately?", "Sometimes that's where God shows up.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // T-128: no onSearch here -- search only exists on Entries (see
            // TabScreenHeader's own comment).
            TabScreenHeader(title: greeting, onCapture: onCapture)

            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    heroCard

                    ForEach(tiles, id: \.title) { tile in
                        tileRow(tile)
                    }

                    interlude
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.top, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.xxl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Payment.background.ignoresSafeArea())
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("A WORD FOR TODAY")
                .font(.system(size: 11, weight: .semibold))
                .tracking(1.5)
                .foregroundColor(Theme.Payment.textSupporting)

            Text(verseReference)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.Payment.textSupporting)

            Text(verseQuote)
                .font(.system(size: 24, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)
                .fixedSize(horizontal: false, vertical: true)

            Text(verseQuestion)
                .font(.system(size: 11))
                .foregroundColor(Theme.Payment.textSupporting)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: {
                onOpenPrompt((title: verseQuestion, category: "Scripture"))
            }) {
                HStack(spacing: 8) {
                    Text("Sit with this")
                        .font(.system(size: 14, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(Theme.Payment.backgroundPrimary)
                .padding(.horizontal, 18)
                .frame(height: 44)
                .background(Theme.gold)
                .clipShape(Capsule())
            }
        }
        .padding(19)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Payment.surfaceCard)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Theme.Payment.borderDivider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func tileRow(_ tile: (icon: String, category: String, title: String, subtitle: String)) -> some View {
        Button(action: {
            onOpenPrompt((title: tile.title, category: tile.category))
        }) {
            HStack(spacing: 16) {
                Circle()
                    .fill(Theme.Payment.pillBackground)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: tile.icon)
                            .font(.system(size: 17))
                            .foregroundColor(Theme.gold)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(tile.category.uppercased())
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.2)
                        .foregroundColor(Theme.gold)
                    Text(tile.title)
                        .font(.system(size: 16, design: .serif))
                        .foregroundColor(Theme.Payment.textHeading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(tile.subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                Image(systemName: "arrow.right")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.Payment.textSupporting)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .background(Theme.Payment.surfaceCard)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Theme.Payment.borderDivider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    private var interlude: some View {
        VStack(spacing: 11) {
            Image(systemName: "scribble")
                .font(.system(size: 18))
                .foregroundColor(Theme.Payment.textSupporting)
                .rotationEffect(.degrees(-10))

            Text("Some days don't need new words.")
                .font(.system(size: 17, design: .serif))
                .foregroundColor(Theme.Payment.textHeading)
                .multilineTextAlignment(.center)

            Text("Just showing up counts.")
                .font(.system(size: 13))
                .foregroundColor(Theme.Payment.textFaint)
        }
        .padding(.top, Theme.Spacing.xl)
    }
}

#Preview {
    TodayView(userId: "preview-user", onCapture: {}, onOpenPrompt: { _ in })
}

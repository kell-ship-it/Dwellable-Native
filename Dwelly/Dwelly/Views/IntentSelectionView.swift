import SwiftUI

/// Onboarding "Intent Selection" screen (T-110, T-238 Screen 5). Options and the framing
/// question are the 5 already locked in `docs/PILLAR_ONBOARDING_STRATEGY.md` Screen 3 —
/// single-select, matching `public.users.spiritual_intent` being a single `text` column
/// (not an array) and the locked Formation Intelligence mechanism (a deterministic
/// lookup-table match on one stated intent, not a multi-value blend).
struct IntentSelectionView: View {
    let userId: String
    var onContinue: () -> Void
    var onBack: () -> Void

    private let options = [
        "I want to notice God more in my daily life",
        "I'm wrestling with doubts and need to remember God's faithfulness",
        "I want to see patterns in my spiritual journey",
        "I'm in a season of spiritual growth and want to mark it",
        "A friend recommended it"
    ]

    @State private var selected: String?

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Payment.backgroundPrimary.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 130)

                    Text("What brought you to Dwelly?")
                        .font(.system(size: 28, design: .serif))
                        .foregroundColor(Theme.Payment.textHeading)

                    Spacer().frame(height: 16)

                    Text("There's no right answer — this just helps Dwelly meet you where you are.")
                        .font(.system(size: 15))
                        .foregroundColor(Theme.Payment.textSupporting)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer().frame(height: 32)

                    VStack(spacing: 12) {
                        ForEach(options, id: \.self) { option in
                            optionRow(option)
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 28)
            }
            .safeAreaInset(edge: .bottom) { footer }

            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.Payment.textHeading)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Back")
            .padding(.leading, 20)
            .padding(.top, 52)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func optionRow(_ option: String) -> some View {
        let isSelected = selected == option
        return Button(action: { selected = option }) {
            HStack(spacing: 12) {
                Text(option)
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Payment.textHeading)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? Theme.gold : Theme.Payment.textSupporting)
            }
            .padding(16)
            .background(Theme.Payment.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Theme.gold : .clear, lineWidth: 1.5)
            )
        }
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var footer: some View {
        Button(action: continueTapped) {
            Text("Continue")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Theme.Payment.backgroundPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
        }
        .background(Theme.gold)
        .clipShape(Capsule())
        .disabled(selected == nil)
        .opacity(selected == nil ? 0.5 : 1)
        .padding(.horizontal, 28)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(Theme.Payment.backgroundPrimary)
    }

    private func continueTapped() {
        guard let selected else { return }
        ProfileManager.shared.setIntent(selected, userId: userId)
        onContinue()
    }
}

#Preview {
    IntentSelectionView(userId: "preview-user", onContinue: {}, onBack: {})
}

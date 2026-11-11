import SwiftUI

/// Onboarding "Intent Selection" screen (T-110, T-238 Screen 5; options relocked T-273,
/// Nov 11 2026). Single-select, matching `public.users.spiritual_intent` being a single
/// `text` column (not an array) and the locked Formation Intelligence mechanism (a
/// deterministic lookup-table match on one stated intent, not a multi-value blend).
///
/// These 5 replace the earlier 4 ("Grow closer to God" / "Process my thoughts and
/// feelings" / "Journal my faith journey" / "I'm not sure yet") — "Grow closer to God"
/// was dropped as too vague (no verb, names a destination not an action) and the
/// blank/skip option was dropped deliberately: every user is forced to pick one, no
/// escape hatch. MVP scope for what Intent actually does: (1) a motivation signal
/// stored for later, and (2) picks the one topic-card prompt shown on the mandatory
/// onboarding first-capture screen only (see `CaptureView.topicCards`) — it plays no
/// role in any capture after that.
struct IntentSelectionView: View {
    let userId: String
    var onContinue: () -> Void
    var onBack: () -> Void

    private let options = [
        "I want to journal my encounters with God",
        "A place to process my thoughts and feelings",
        "I want to work through my doubts",
        "I want to see my patterns in my spiritual journey",
        "I want to remember what God's done for me"
    ]

    @State private var selected: String?

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Onboarding.backgroundPrimary.ignoresSafeArea()

            // Plain flexible `Spacer()`s and the footer as a normal trailing sibling,
            // not pinned via `.safeAreaInset` below a `ScrollView` with a fixed-height
            // `Spacer().frame(height: 120)` leading it. That combination reproduced the
            // same dead-CTA bug chased down in WelcomeView.swift (Nov 9, 2026): the
            // Continue button rendered correctly — including flipping enabled/disabled
            // as `selected` changed — but never once responded to a tap, confirmed
            // across many retries and coordinates. This structure did not reproduce it
            // in the same testing. Root cause not fully understood — see WelcomeView's
            // comment for the fuller account.
            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                Text("How can dwelly help you?")
                    .font(.system(size: 28, design: .serif))
                    .foregroundColor(Theme.Onboarding.textPrimary)

                Spacer().frame(height: 16)

                Text("Choose what feels most true right now.\nYou can always change this later.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Onboarding.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer().frame(height: 24)

                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        optionRow(option)
                    }
                }

                Spacer()
                Spacer()

                footer
            }
            .padding(.horizontal, 28)

            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Theme.Onboarding.textPrimary)
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
                    .font(.system(size: 16))
                    .foregroundColor(Theme.Onboarding.textPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? Theme.gold : Theme.Onboarding.borderInput)
            }
            .padding(16)
            .background(Theme.Onboarding.surfaceCard)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Theme.gold : Theme.Onboarding.borderInput, lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var footer: some View {
        Button(action: continueTapped) {
            Text("Continue")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Theme.Onboarding.backgroundPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
        }
        .background(Theme.gold)
        .clipShape(Capsule())
        .disabled(selected == nil)
        .opacity(selected == nil ? 0.5 : 1)
        .padding(.bottom, 24)
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

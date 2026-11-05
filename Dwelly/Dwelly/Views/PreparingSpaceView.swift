import SwiftUI

/// Onboarding "Preparing Space" screen (T-110, T-238 Screen 7 — the last screen before the
/// mandatory first capture). Matches the real locked Figma design (node 2240:92, file
/// `t5MUGEtpeFcUixobvHiYMc`) as of Nov 5, 2026 — pulled directly after Kell flagged the
/// original build (a generic spinner + static copy, auto-advancing with no button) as a
/// shortcut that didn't match it. The real design is a 4-item checklist (two complete, one
/// active, one pending) with an explicit "Capture Your First Moment →" CTA — not a timed
/// auto-transition.
struct PreparingSpaceView: View {
    let name: String?
    var onComplete: () -> Void

    private enum ItemState { case complete, active, pending }

    @State private var itemStates: [ItemState] = [.active, .pending, .pending, .pending]

    private let items = [
        "Waking up Dwelly...",
        "Setting up your journal...",
        "Opening your reflection space...",
        "Preparing your first prompt..."
    ]

    private var greeting: String {
        if let name, !name.isEmpty {
            return "Almost there, \(name)."
        }
        return "Almost there."
    }

    var body: some View {
        ZStack {
            Theme.Onboarding.backgroundPrimary.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 280)

                Text(greeting)
                    .font(.system(size: 38, design: .serif))
                    .foregroundColor(Theme.Onboarding.textPrimary)

                Spacer().frame(height: 16)

                Text("Making space to receive\nwhat He has for you.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Onboarding.textMutedWarm)

                Spacer().frame(height: 36)

                VStack(alignment: .leading, spacing: 18) {
                    ForEach(items.indices, id: \.self) { index in
                        checklistRow(items[index], state: itemStates[index])
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 28)

            VStack {
                Spacer()
                Button(action: onComplete) {
                    Text("Capture Your First Moment →")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.Onboarding.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                }
                .background(Theme.gold)
                .clipShape(Capsule())
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
            }
        }
        .onAppear { animateChecklist() }
    }

    private func checklistRow(_ label: String, state: ItemState) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(state == .pending ? Theme.Onboarding.borderInput : Theme.gold, lineWidth: 1.5)
                    .background(
                        Circle().fill(state == .pending ? Color.clear : Theme.gold.opacity(0.15))
                    )
                    .frame(width: 22, height: 22)

                switch state {
                case .complete:
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Theme.gold)
                case .active:
                    Circle()
                        .fill(Theme.gold)
                        .frame(width: 6, height: 6)
                case .pending:
                    EmptyView()
                }
            }

            Text(label)
                .font(.system(size: 15, weight: state == .pending ? .regular : .medium))
                .foregroundColor(state == .pending ? Theme.Onboarding.textMutedWarm : Theme.Onboarding.textPrimary)
        }
    }

    private func animateChecklist() {
        let delays: [Double] = [0.6, 1.2, 1.8]
        for (stepIndex, delay) in delays.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: 0.2)) {
                    itemStates[stepIndex] = .complete
                    if stepIndex + 1 < itemStates.count {
                        itemStates[stepIndex + 1] = .active
                    }
                }
            }
        }
    }
}

#Preview {
    PreparingSpaceView(name: "Kell", onComplete: {})
}

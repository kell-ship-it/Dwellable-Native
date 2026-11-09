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

    /// Each active item must visibly complete at least this many full spins before moving
    /// on — Kell flagged that a shared/continuous rotation left some items "halfway" through
    /// a spin when they activated, since the animation's phase wasn't reset per item.
    private let rotationsPerItem = 2
    private let secondsPerRotation = 0.7

    @State private var itemStates: [ItemState] = [.active, .pending, .pending, .pending]
    @State private var rotationAngles: [Double] = [0, 0, 0, 0]
    @State private var poppedIndices: Set<Int> = []

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
                Text(greeting)
                    .font(.system(size: 38, design: .serif))
                    .foregroundColor(Theme.Onboarding.textPrimary)

                Spacer().frame(height: 16)

                Text("Making space to receive\nwhat He has for you.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Payment.textSupporting) // #857d69, per Kell — Theme.Onboarding.textMutedWarm (#807b71) is a different, close-but-wrong shade

                Spacer().frame(height: 36)

                VStack(alignment: .leading, spacing: 18) {
                    ForEach(items.indices, id: \.self) { index in
                        checklistRow(
                            items[index],
                            state: itemStates[index],
                            hasPopped: poppedIndices.contains(index),
                            rotationAngle: rotationAngles[index]
                        )
                    }
                }
            }
            .padding(.horizontal, 28)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            if itemStates.allSatisfy({ $0 == .complete }) {
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
                .transition(.opacity)
            }
        }
        .onAppear { activate(0) }
    }

    private func checklistRow(_ label: String, state: ItemState, hasPopped: Bool, rotationAngle: Double) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(state == .complete ? Theme.gold : Theme.Onboarding.borderInput, lineWidth: 1.5)
                    .background(
                        Circle().fill(state == .complete ? Theme.gold.opacity(0.15) : Color.clear)
                    )
                    .frame(width: 22, height: 22)

                switch state {
                case .complete:
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Theme.gold)
                        .scaleEffect(hasPopped ? 1 : 0.3)
                case .active:
                    // Real circular-motion loading indicator — a short gold dash that
                    // orbits the ring at least `rotationsPerItem` full times, reset to 0°
                    // the moment this item becomes active (not a shared/continuous spin
                    // that could be mid-rotation when a later item activates).
                    Circle()
                        .trim(from: 0, to: 0.22)
                        .stroke(Theme.gold, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .frame(width: 22, height: 22)
                        .rotationEffect(.degrees(rotationAngle))
                        .scaleEffect(hasPopped ? 1 : 0.3)
                case .pending:
                    EmptyView()
                }
            }

            Text(label)
                .font(.system(size: 15, weight: state == .pending ? .regular : .medium))
                .foregroundColor(state == .pending ? Theme.Onboarding.textMutedWarm : Theme.Onboarding.textPrimary)
        }
    }

    /// Activates item `index`: pops it in, resets its rotation to 0° (instantly, no
    /// animation), spins it a fixed number of full rotations, then — exactly when that spin
    /// finishes — marks it complete and activates the next item, if any.
    ///
    /// Bug fixed Nov 2026 (Kell caught it live: the last item's checkmark never appeared,
    /// just spun forever): the old code had `guard nextIndex < itemStates.count else {
    /// return }` BEFORE scheduling the completion block at all — so for the last item,
    /// where there's no next index, the entire `asyncAfter` that sets `itemStates[index] =
    /// .complete` was skipped, not just the hand-off to a next item. The completion write
    /// and the "is there a next item" check now happen independently, so the last item
    /// still completes on schedule; it just has nothing to activate afterward.
    private func activate(_ index: Int) {
        guard index < itemStates.count else { return }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
            poppedIndices.insert(index)
        }

        rotationAngles[index] = 0
        let activeDuration = secondsPerRotation * Double(rotationsPerItem)
        withAnimation(.linear(duration: activeDuration)) {
            rotationAngles[index] = 360 * Double(rotationsPerItem)
        }

        let nextIndex = index + 1

        DispatchQueue.main.asyncAfter(deadline: .now() + activeDuration) {
            withAnimation(.easeOut(duration: 0.2)) {
                itemStates[index] = .complete
                if nextIndex < itemStates.count {
                    itemStates[nextIndex] = .active
                }
            }
            if nextIndex < itemStates.count {
                activate(nextIndex)
            }
        }
    }
}

#Preview {
    PreparingSpaceView(name: "Kell", onComplete: {})
}

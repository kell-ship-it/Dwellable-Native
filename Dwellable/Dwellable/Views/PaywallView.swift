import SwiftUI

/// The locked Payment pillar (P12) screen — serves 3 scenarios via `PaywallContext`:
/// onboarding paywall (skippable), second-capture trial gate (not skippable), and
/// trial-already-used (straight subscribe). See `PaywallContext.swift` for the copy rules.
struct PaywallView: View {
    let context: PaywallContext
    /// Called when the user completes a purchase, or (onboarding only) taps Close to skip.
    var onDismiss: (() -> Void)?

    @StateObject private var paymentManager = PaymentManager.shared
    @State private var selectedPlan: SubscriptionPlan = .yearly
    @State private var errorMessage: String?

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Payment.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    heroImage

                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text(context.headline)
                                .font(.system(size: 21, design: .serif))
                                .foregroundColor(Theme.Payment.textHeading)
                                .multilineTextAlignment(.center)

                            Text(context.subtext(for: selectedPlan))
                                .font(.system(size: 12))
                                .foregroundColor(Theme.Payment.textSupporting)
                                .multilineTextAlignment(.center)
                        }

                        planToggle

                        timeline

                        if let errorMessage {
                            errorToast(errorMessage)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 37)
                }
            }

            VStack {
                Spacer()
                footer
            }

            if context.isSkippable {
                closeButton
            }
        }
        .task {
            if paymentManager.products.isEmpty {
                await paymentManager.loadProducts()
            }
        }
    }

    // MARK: - Hero

    private var heroImage: some View {
        Image("PaywallHero")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 213)
            .frame(maxWidth: .infinity)
            .clipped()
    }

    private var closeButton: some View {
        Button {
            onDismiss?()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Theme.Payment.textHeading)
                .frame(width: 44, height: 44)
        }
        .padding(.leading, 12)
        .padding(.top, 52)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Plan Toggle

    private var planToggle: some View {
        HStack(spacing: 2) {
            planPill(.monthly, label: "Monthly")
            planPill(.yearly, label: "Yearly")
        }
        .padding(3)
        .background(Theme.Payment.pillBackground)
        .clipShape(Capsule())
    }

    private func planPill(_ plan: SubscriptionPlan, label: String) -> some View {
        Text(label)
            .font(.system(size: 12))
            .foregroundColor(selectedPlan == plan ? Color.black : Theme.Payment.textSupporting)
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(selectedPlan == plan ? Theme.gold : Color.clear)
            .clipShape(Capsule())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.15)) {
                    selectedPlan = plan
                }
            }
    }

    // MARK: - Timeline

    private var timeline: some View {
        let milestones = context.milestones(for: selectedPlan)
        let icons = ["heart.fill", "bell.fill", "star.fill"]

        return HStack(alignment: .top, spacing: 0) {
            VStack(spacing: 0) {
                ForEach(milestones.indices, id: \.self) { index in
                    Image(systemName: icons[index % icons.count])
                        .font(.system(size: 12))
                        .foregroundColor(Theme.gold)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Theme.Payment.pillBackground))

                    if index < milestones.count - 1 {
                        Rectangle()
                            .fill(Theme.Payment.timelineRail)
                            .frame(width: 2, height: 56)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 56 - 18) {
                ForEach(milestones.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(milestones[index].title)
                            .font(.system(size: 13.5))
                            .foregroundColor(Theme.Payment.textHeading)
                        Text(milestones[index].body)
                            .font(.system(size: 11.5))
                            .foregroundColor(Theme.Payment.textSupporting)
                    }
                }
            }
            .padding(.leading, 14)
            .padding(.top, 4)
        }
    }

    // MARK: - Error Toast (Purchase Failed scenario)

    private func errorToast(_ message: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(Theme.Payment.errorRed)
            Text(message)
                .font(.system(size: 12.5))
                .foregroundColor(Theme.Payment.textHeading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Payment.errorRed.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 8) {
            Button {
                Task { await purchase() }
            } label: {
                if paymentManager.isPurchasing {
                    ProgressView()
                        .tint(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                } else {
                    Text(context.ctaTitle(for: selectedPlan))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                }
            }
            .background(Theme.gold)
            .clipShape(Capsule())
            .disabled(paymentManager.isPurchasing)

            Button {
                Task { await restore() }
            } label: {
                Text("Restore Purchases")
                    .font(.system(size: 11.5))
                    .foregroundColor(Theme.gold)
            }

            Text("Cancel anytime in the App Store")
                .font(.system(size: 10.5))
                .foregroundColor(Theme.Payment.textSupporting)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }

    // MARK: - Actions

    private func purchase() async {
        errorMessage = nil
        let result = await paymentManager.purchase(selectedPlan)
        switch result {
        case .success:
            onDismiss?()
        case .userCancelled, .pending:
            break
        case .failed:
            errorMessage = "Purchase didn't go through — try again, or continue without starting the trial."
        }
    }

    private func restore() async {
        errorMessage = nil
        let result = await paymentManager.restorePurchases()
        if case .success = result {
            onDismiss?()
        } else if case .failed(let error) = result {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview("Onboarding — Skippable") {
    PaywallView(context: .onboardingSkippable)
}

#Preview("Second Capture — Gate") {
    PaywallView(context: .secondCaptureGate)
}

#Preview("Trial Already Used") {
    PaywallView(context: .trialAlreadyUsed)
}

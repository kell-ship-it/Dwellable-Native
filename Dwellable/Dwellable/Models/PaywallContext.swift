import Foundation

/// Which of the 3 locked P12 Payment scenarios is being shown. Drives copy, skippability,
/// and whether the trial pitch or an immediate-charge pitch is shown.
/// See Figma `dwelly-redesign` (jBOzv1vO2C2DSMePqRl4c4), page "P12 — Payment (7 Scenarios)".
enum PaywallContext {
    /// First paywall, shown right after onboarding's Intro Video. Skippable —
    /// users can decline and still get one free capture with no card on file.
    case onboardingSkippable
    /// The real, non-skippable paywall. Triggered when a user who skipped the first
    /// paywall tries to capture a second moment. Must start the trial to continue.
    case secondCaptureGate
    /// Shown instead of the trial gate when StoreKit reports this Apple ID has already
    /// consumed its intro offer (prior trial, any device). No trial pitch — straight subscribe.
    case trialAlreadyUsed

    var isSkippable: Bool {
        self == .onboardingSkippable
    }

    var headline: String {
        switch self {
        case .onboardingSkippable, .secondCaptureGate:
            return "How your trial works"
        case .trialAlreadyUsed:
            return "Welcome back to Dwelly"
        }
    }

    func subtext(for plan: SubscriptionPlan) -> String {
        switch self {
        case .onboardingSkippable:
            return "First 14 days free, then \(plan.priceDisplay)"
        case .secondCaptureGate:
            return "You've captured your first moment free. Start your 14-day trial to keep going — then \(plan.priceDisplay)."
        case .trialAlreadyUsed:
            return "Your free trial has already been used on this Apple ID. Subscribe to keep capturing moments — \(plan.priceDisplay)."
        }
    }

    /// The 3 timeline milestones shown below the plan toggle.
    func milestones(for plan: SubscriptionPlan) -> [(title: String, body: String)] {
        switch self {
        case .onboardingSkippable, .secondCaptureGate:
            return [
                ("Today", "Capture freely, keep your full journal, and process with Dwelly — all of it, right away."),
                ("In 7 days", "We'll remind you before your trial ends."),
                ("In 14 days", "You'll be charged unless you cancel before then.")
            ]
        case .trialAlreadyUsed:
            return [
                ("Full access, right away", "Subscribing unlocks unlimited capture and journaling immediately — no trial period this time."),
                ("Billed yearly", plan == .yearly
                    ? "Your card is charged $59.99 today, then once a year on the same date."
                    : "Your card is charged $7.99 today, then once a month on the same date."),
                ("Cancel anytime", "Manage or cancel your subscription anytime in the App Store — no trial to lose.")
            ]
        }
    }

    func ctaTitle(for plan: SubscriptionPlan) -> String {
        switch self {
        case .onboardingSkippable, .secondCaptureGate:
            return "Try for $0.00"
        case .trialAlreadyUsed:
            return "Subscribe — \(plan.priceDisplay)"
        }
    }
}

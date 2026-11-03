import SwiftUI

/// The real 4-tab shell (T-076): Today | Entries | Growth | Profile, standard native
/// iOS tab bar (material blur), always visible on these 4 screens, never hides on
/// scroll (locked Nov 2, 2026 — persistent chrome, not feed-style hide/reveal).
/// Capture is a persistent gold circle in each screen's own header, not a 5th tab
/// item (pulled out Aug 20, 2026 per Kell's review of the Journey app) — tapping it
/// launches CaptureView full-screen from any tab via a single shared presentation
/// state here. The Container Transform (.zoom) launch animation locked alongside
/// this decision is a later polish pass, not implemented yet — this is a plain
/// `fullScreenCover` for now.
struct MainTabView: View {
    let userId: String
    let userEmail: String?
    let syncManager: SyncManager

    @StateObject private var paymentManager = PaymentManager.shared
    @State private var showCapture = false
    @State private var paywallContext: PaywallContext?

    var body: some View {
        TabView {
            NavigationStack {
                TodayPlaceholderView(onSearch: {}, onCapture: attemptCapture)
            }
            .tabItem { Label("Today", systemImage: "sun.max") }

            NavigationStack {
                MomentsListView(userId: userId, syncManager: syncManager, onAttemptCapture: attemptCapture)
            }
            .tabItem { Label("Entries", systemImage: "book") }

            NavigationStack {
                GrowthPlaceholderView(onSearch: {}, onCapture: attemptCapture)
            }
            .tabItem { Label("Growth", systemImage: "leaf") }

            NavigationStack {
                AccountProfileView(onSearch: {}, onCapture: attemptCapture)
            }
            .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .tint(Theme.gold)
        .fullScreenCover(isPresented: $showCapture) {
            CaptureView(userId: userId, userEmail: userEmail, syncManager: syncManager, onMomentSaved: {
                showCapture = false
            })
        }
        .fullScreenCover(item: $paywallContext) { context in
            PaywallView(context: context, onDismiss: {
                paywallContext = nil
                if context != .onboardingSkippable {
                    // A successful purchase on a gate screen should let the capture through.
                    showCapture = true
                }
            })
        }
    }

    /// T-255 — the trial-eligibility gate. First capture is always free, no card needed.
    /// From the 2nd capture attempt on, an active subscription is required: if this
    /// Apple ID has never used its intro offer, show the real trial-start gate;
    /// otherwise (trial already consumed on this Apple ID, any device) go straight
    /// to a non-trial subscribe screen.
    private func attemptCapture() {
        guard !paymentManager.hasActiveEntitlement else {
            showCapture = true
            return
        }

        let hasCapturedBefore = !LocalStorageManager.shared.getAllLocalMoments(userId: userId).isEmpty
        guard hasCapturedBefore else {
            showCapture = true
            return
        }

        Task {
            let eligible = await paymentManager.isEligibleForIntroOffer(.yearly)
            paywallContext = eligible ? .secondCaptureGate : .trialAlreadyUsed
        }
    }
}

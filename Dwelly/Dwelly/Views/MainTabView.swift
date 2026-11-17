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
    // T-135/T-139 (Nov 17 2026): the Today tab's Hero verse and 3 reflection tiles each
    // launch straight into a conversation pre-opened with that one prompt, instead of the
    // plain composer -- CaptureConversationView already had `initialMessage`/
    // `initialMessageIsPrompt` for exactly this (built for onboarding's topic cards), it
    // just had no caller outside CaptureView's own onboarding-only grid until now.
    @State private var presetPrompt: (title: String, category: String)?
    // T-128: Search is reached the same way Capture is -- one shared full-screen
    // presentation off the tab bar's own header button, not a per-tab destination.
    @State private var showSearch = false
    @State private var paywallContext: PaywallContext?
    // Kell's direct ask (Nov 16 2026): backing out of the journal entry you just
    // opened from a finished capture should land on Entries, not wherever the tab
    // bar happened to be sitting before -- needs a real selection binding instead
    // of the implicit/default one `TabView` used before this.
    @State private var selectedTab: Tab = .today

    private enum Tab: Hashable {
        case today, entries, growth, profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TodayView(userId: userId, onCapture: { attemptCapture() }, onOpenPrompt: { prompt in
                    attemptCapture(prompt: prompt)
                })
            }
            .tabItem { Label("Today", systemImage: "sun.max") }
            .tag(Tab.today)

            NavigationStack {
                // T-078: real Entries tab (Untold-style calendar + list), replacing
                // the Phase-1 MomentsListView. T-128 (Kell's call, Nov 16 2026):
                // Search only lives here, not on Today/Growth/Profile -- it searches
                // journal entries specifically, not anything those other tabs show.
                EntriesView(userId: userId, syncManager: syncManager, onSearch: { showSearch = true }, onCapture: { attemptCapture() })
            }
            .tabItem { Label("Entries", systemImage: "book") }
            .tag(Tab.entries)

            NavigationStack {
                GrowthPlaceholderView(userId: userId, onCapture: { attemptCapture() })
            }
            .tabItem { Label("Growth", systemImage: "leaf") }
            .tag(Tab.growth)

            NavigationStack {
                AccountProfileView(onCapture: { attemptCapture() })
            }
            .tabItem { Label("Profile", systemImage: "person.crop.circle") }
            .tag(Tab.profile)
        }
        // Still glitching on-device after disabling the selection animation (Kell,
        // Nov 17 2026) -- so the fringe isn't the pill's slide after all. Forcing
        // monochrome symbol rendering rules out the other usual cause: an SF Symbol
        // rendering in multicolor/hierarchical mode interpolating through intermediate
        // colors as the tab bar's own tint recomputes on selection.
        .environment(\.symbolRenderingMode, .monochrome)
        // Kell caught a real, on-device color-fringe glitch on the tab bar's own
        // selection pill mid-slide, not a simulator rendering artifact -- a known
        // SwiftUI/iOS issue where the system tab bar's selected-icon tint
        // interpolates through intermediate colors while animating. Turning off the
        // implicit animation on `selectedTab` makes the pill jump instantly instead
        // of sliding, trading a slightly less fluid switch for removing the artifact
        // entirely, since there's no direct control over the system chrome's own
        // interpolation.
        .animation(nil, value: selectedTab)
        .tint(Theme.gold)
        .fullScreenCover(isPresented: $showSearch) {
            NavigationStack {
                SearchView(userId: userId, syncManager: syncManager, onDismiss: { showSearch = false })
            }
        }
        .fullScreenCover(isPresented: $showCapture) {
            if let presetPrompt {
                CaptureConversationView(
                    userId: userId,
                    userEmail: userEmail,
                    syncManager: syncManager,
                    initialMessage: presetPrompt.title,
                    initialMessageIsPrompt: true,
                    onMomentSaved: { showCapture = false; self.presetPrompt = nil },
                    onFinishedViewingJournal: {
                        selectedTab = .entries
                        showCapture = false
                        self.presetPrompt = nil
                    }
                )
            } else {
                CaptureView(
                    userId: userId,
                    userEmail: userEmail,
                    syncManager: syncManager,
                    onMomentSaved: { showCapture = false },
                    onFinishedViewingJournal: {
                        selectedTab = .entries
                        showCapture = false
                    }
                )
            }
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
    private func attemptCapture(prompt: (title: String, category: String)? = nil) {
        presetPrompt = prompt

        #if DEBUG
        // Dev-only paywall bypass (Nov 11 2026) so Kell can run repeated real captures
        // in the simulator to watch DwellerProfile/Your Narrative populate without
        // StoreKit friction. Compiles out entirely in Release -- never ships, never
        // reaches TestFlight or the App Store.
        showCapture = true
        return
        #endif

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

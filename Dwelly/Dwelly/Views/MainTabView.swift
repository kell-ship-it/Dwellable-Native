import SwiftUI

/// The real 4-tab shell (T-076): Today | Entries | Growth | Profile. Always visible on
/// these 4 screens, never hides on scroll (locked Nov 2, 2026 — persistent chrome, not
/// feed-style hide/reveal). Capture is a persistent gold circle in each screen's own
/// header, not a 5th tab item (pulled out Aug 20, 2026 per Kell's review of the Journey
/// app) — tapping it launches CaptureView full-screen from any tab via a single shared
/// presentation state here. The Container Transform (.zoom) launch animation locked
/// alongside this decision is a later polish pass, not implemented yet — this is a plain
/// `fullScreenCover` for now.
///
/// Custom-drawn tab bar (Nov 17 2026), not the native `TabView`/`.tabItem` system bar.
/// Reproduced and verified via real screen recordings (simulator restarted each time to
/// clear CoreSimulator's recorder lock) a genuine rendering artifact on iOS 27.2's
/// Simulator runtime: a diagonal rainbow/chromatic-aberration glint sweeping across the
/// floating tab bar's icons during the selection-change transition. Four independent,
/// recording-verified fixes failed to touch it: `.animation(nil, value: selectedTab)`,
/// `.environment(\.symbolRenderingMode, .monochrome)`, driving the tint through
/// `UITabBarAppearance` instead of SwiftUI's `.tint()`, and even
/// `UIDesignRequiresCompatibility` (opting the whole app out of the new Liquid Glass
/// design language) — the identical glint still appeared under all four. That rules out
/// every public app-level lever over the native bar's own compositing, so the only
/// remaining fix is not drawing a native tab bar at all: this `ZStack` + custom
/// `FloatingTabBar` below reproduces the exact same floating-capsule visual (matching
/// Figma's `TabBar / 4-Tab` component: `background/primary` fill, 32pt corner radius,
/// the same shadow, 28pt icon/label gap) in plain SwiftUI shapes/text, so there is no
/// system glass material to glitch. All four tab roots stay mounted continuously
/// (toggled by opacity + `allowsHitTesting`, not an `if`/`switch`), preserving each
/// tab's scroll position and loaded state across switches exactly like `TabView` did.
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

    // Not `private` -- `FloatingTabBar` below (same file, separate type) needs to
    // reference `MainTabView.Tab` directly.
    enum Tab: Hashable, CaseIterable {
        case today, entries, growth, profile

        var label: String {
            switch self {
            case .today: return "Today"
            case .entries: return "Entries"
            case .growth: return "Growth"
            case .profile: return "Profile"
            }
        }

        var icon: String {
            switch self {
            case .today: return "sun.max"
            case .entries: return "book"
            case .growth: return "leaf"
            case .profile: return "person.crop.circle"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // All four tab roots stay mounted continuously (opacity-toggled, not an
            // `if`/`switch` over `selectedTab`) so each one's own scroll position and
            // already-loaded content survive a tab switch, matching `TabView`'s own
            // behavior exactly.
            tabContent(.today) {
                TodayView(userId: userId, onCapture: { attemptCapture() }, onOpenPrompt: { prompt in
                    attemptCapture(prompt: prompt)
                })
            }
            tabContent(.entries) {
                // T-078: real Entries tab (Untold-style calendar + list), replacing
                // the Phase-1 MomentsListView. T-128 (Kell's call, Nov 16 2026):
                // Search only lives here, not on Today/Growth/Profile -- it searches
                // journal entries specifically, not anything those other tabs show.
                EntriesView(userId: userId, syncManager: syncManager, onSearch: { showSearch = true }, onCapture: { attemptCapture() })
            }
            tabContent(.growth) {
                GrowthPlaceholderView(userId: userId, onCapture: { attemptCapture() })
            }
            tabContent(.profile) {
                AccountProfileView(onCapture: { attemptCapture() })
            }

            FloatingTabBar(selected: $selectedTab)
        }
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

    @ViewBuilder
    private func tabContent<Content: View>(_ tab: Tab, @ViewBuilder content: () -> Content) -> some View {
        NavigationStack {
            content()
        }
        .opacity(selectedTab == tab ? 1 : 0)
        .allowsHitTesting(selectedTab == tab)
        // Keeps a hidden tab's own gestures/scroll from fighting the visible one's,
        // and VoiceOver from reading content that isn't actually on screen.
        .accessibilityHidden(selectedTab != tab)
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

/// Plain-SwiftUI stand-in for the native tab bar -- see `MainTabView`'s own header
/// comment for why. Matches Figma's `TabBar / 4-Tab` component (dwelly-redesign
/// jBOzv1vO2C2DSMePqRl4c4, node 428:358) exactly: `background/primary` fill, 32pt
/// corner radius, the same drop shadow, 28pt gap between items, 28/14pt padding.
/// No `.ultraThinMaterial`/blur anywhere in here deliberately -- a translucent
/// material is the one ingredient every glitching screenshot had in common across
/// all four disproven fixes, so this avoids that whole rendering path, not just the
/// specific symptom.
private struct FloatingTabBar: View {
    @Binding var selected: MainTabView.Tab

    var body: some View {
        HStack(spacing: 18) {
            ForEach(MainTabView.Tab.allCases, id: \.self) { tab in
                let isSelected = tab == selected
                Button(action: { selected = tab }) {
                    VStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 21))
                            .frame(height: 24)
                        // Figma's spec text (13pt) wraps "Entries"/"Growth" at this
                        // container width under real SF Pro metrics -- 10pt matches
                        // the native tab bar's own label size, which already fit.
                        Text(tab.label)
                            .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                            .lineLimit(1)
                            .fixedSize()
                    }
                    .foregroundColor(isSelected ? Theme.gold : Theme.Payment.textSupporting)
                    .frame(maxWidth: .infinity)
                }
                .accessibilityAddTraits(isSelected ? [.isSelected] : [])
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Theme.Payment.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: .black.opacity(0.35), radius: 15, x: 0, y: 10)
        .padding(.horizontal, 32)
        .padding(.bottom, 8)
    }
}

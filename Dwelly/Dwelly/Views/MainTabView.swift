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
    @ObservedObject private var tabBarVisibility = TabBarVisibility.shared
    // T-301 (Nov 17 2026): was two separate `@State` vars (`showCapture: Bool` +
    // `presetPrompt: (title:category:)?`), presented via `.fullScreenCover(isPresented:)`.
    // Caught live with a debug print at each step: `attemptCapture(prompt:)` set
    // `presetPrompt` correctly (confirmed non-nil immediately after the assignment), but
    // by the time the cover's own content closure ran, it read `presetPrompt` back as
    // `nil` -- `.fullScreenCover(isPresented:)` doesn't reliably re-snapshot every other
    // `@State` property against the SAME render pass that flips its own boolean true, so
    // the prompt and the "show now" signal could land in different renders. Folding both
    // into one `Identifiable` payload, presented via `.fullScreenCover(item:)`, is the
    // same fix `paywallContext` below already uses for exactly this class of problem --
    // the trigger and its data become the same atomic value, so there's nothing for two
    // separate state changes to race on.
    private struct CaptureRequest: Identifiable {
        let id = UUID()
        let prompt: (title: String, category: String)?
    }
    @State private var captureRequest: CaptureRequest?
    /// Bumped whenever a conversation closes so Today/Growth re-load what it may have saved.
    @State private var dataRefreshKey = 0
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
                }, refreshKey: dataRefreshKey)
            }
            tabContent(.entries) {
                // T-078: real Entries tab (Untold-style calendar + list), replacing
                // the Phase-1 MomentsListView. T-128 (Kell's call, Nov 16 2026):
                // Search only lives here, not on Today/Growth/Profile -- it searches
                // journal entries specifically, not anything those other tabs show.
                EntriesView(userId: userId, syncManager: syncManager, onSearch: { showSearch = true }, onCapture: { attemptCapture() }, isActive: selectedTab == .entries && captureRequest == nil && !showSearch)
            }
            tabContent(.growth) {
                GrowthPlaceholderView(userId: userId, onCapture: { attemptCapture() }, refreshKey: dataRefreshKey)
            }
            tabContent(.profile) {
                AccountProfileView(onCapture: { attemptCapture() })
            }

            if !tabBarVisibility.isHidden {
                FloatingTabBar(selected: $selectedTab)
            }
        }
        .onChange(of: captureRequest == nil) { closed in
            if closed { dataRefreshKey += 1 }
        }
        .fullScreenCover(isPresented: $showSearch) {
            NavigationStack {
                SearchView(userId: userId, syncManager: syncManager, onDismiss: { showSearch = false })
            }
        }
        .fullScreenCover(item: $captureRequest) { request in
            if let prompt = request.prompt {
                CaptureConversationView(
                    userId: userId,
                    userEmail: userEmail,
                    syncManager: syncManager,
                    initialMessage: prompt.title,
                    initialMessageIsPrompt: true,
                    onMomentSaved: { captureRequest = nil },
                    onFinishedViewingJournal: {
                        selectedTab = .entries
                        captureRequest = nil
                    }
                )
            } else {
                // CaptureView merged into CaptureConversationView (Nov 17 2026) --
                // no preset initialMessage means this opens straight into the idle
                // "What's stirring in you today?" state instead of a new screen.
                CaptureConversationView(
                    userId: userId,
                    userEmail: userEmail,
                    syncManager: syncManager,
                    onMomentSaved: { captureRequest = nil },
                    onFinishedViewingJournal: {
                        selectedTab = .entries
                        captureRequest = nil
                    }
                )
            }
        }
        .fullScreenCover(item: $paywallContext) { context in
            PaywallView(context: context, onDismiss: {
                paywallContext = nil
                if context != .onboardingSkippable {
                    // A successful purchase on a gate screen should let the capture
                    // through -- doesn't restore whatever prompt (if any) triggered the
                    // gate in the first place, same gap that existed before this fix
                    // (out of scope for T-301, which is specifically about the
                    // always-free first capture never pre-seeding; raise separately if
                    // that round-trip needs its own fix).
                    captureRequest = CaptureRequest(prompt: nil)
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
        // Instant switch (Kell, Nov 24 2026): fading whole screens looked like a
        // snapshot flicker, so screens swap with no animation; only the pill moves.
        .transaction { $0.animation = nil }
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
    private static let betaFreeAccess = PaywallPolicy.isBetaFree

    private func attemptCapture(prompt: (title: String, category: String)? = nil) {
        #if DEBUG
        // Dev-only paywall bypass (Nov 11 2026) so Kell can run repeated real captures
        // in the simulator to watch DwellerProfile/Your Narrative populate without
        // StoreKit friction. Compiles out entirely in Release -- never ships, never
        // reaches TestFlight or the App Store.
        captureRequest = CaptureRequest(prompt: prompt)
        return
        #endif

        // Beta is free (Kell, Nov 23 2026; payments are parked and no real Apple IAP products
        // exist yet). Without this, a TestFlight/Release build sends every tester without a
        // subscription to the paywall on their second capture, and subscribing cannot work.
        // Set `betaFreeAccess` to false when payments launch.
        guard !Self.betaFreeAccess, !paymentManager.hasActiveEntitlement else {
            captureRequest = CaptureRequest(prompt: prompt)
            return
        }

        let hasCapturedBefore = !LocalStorageManager.shared.getAllLocalMoments(userId: userId).isEmpty
        guard hasCapturedBefore else {
            captureRequest = CaptureRequest(prompt: prompt)
            return
        }

        Task {
            let eligible = await paymentManager.isEligibleForIntroOffer(.yearly)
            paywallContext = eligible ? .secondCaptureGate : .trialAlreadyUsed
        }
    }
}

/// Screens pushed inside a tab (e.g. an open journal) call `.hidesTabBar()` to remove the
/// custom tab bar while they're on screen. A count, so overlapping screens can't un-hide it early.
final class TabBarVisibility: ObservableObject {
    static let shared = TabBarVisibility()
    @Published private var hiders = 0
    var isHidden: Bool { hiders > 0 }
    func push() { hiders += 1 }
    func pop() { hiders = max(0, hiders - 1) }
}

extension View {
    func hidesTabBar() -> some View {
        onAppear { TabBarVisibility.shared.push() }
            .onDisappear { TabBarVisibility.shared.pop() }
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
    @Namespace private var pillNamespace

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
                    .background {
                        // iOS 26+: the sliding highlight pill behind the selected tab, like
                        // Apple's own tab bar. Older iOS keeps color-only selection.
                        if isSelected, #available(iOS 26.0, *) {
                            Capsule()
                                .fill(Color.white.opacity(0.14))
                                .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 0.5))
                                .padding(.vertical, -8)
                                .padding(.horizontal, -6)
                                .matchedGeometryEffect(id: "tabPill", in: pillNamespace)
                        }
                    }
                }
                .accessibilityAddTraits(isSelected ? [.isSelected] : [])
            }
        }
        // Spring only the highlight pill and tab colors, not the screens behind them.
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: selected)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .modifier(TabBarSurface())
        .padding(.horizontal, 32)
        .padding(.bottom, 8)
    }
}

/// Bar surface. iOS 26+ gets Apple's Liquid Glass (Nov 24 2026); older iOS keeps the
/// solid Figma fill, so the glitch-prone translucent-material path is never used there.
private struct TabBarSurface: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 32))
        } else {
            content
                .background(Theme.Payment.backgroundPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .shadow(color: .black.opacity(0.35), radius: 15, x: 0, y: 10)
        }
    }
}

/// Beta is free: no paywall anywhere. Flip to false when paid plans launch.
enum PaywallPolicy {
    static let isBetaFree = true
}

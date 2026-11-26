import SwiftUI

/// T-110's `OnboardingCoordinator`. Owns the 4 screens that still need building after
/// Account Creation (T-109) and the Intro Video/Paywall (already built, wired in by
/// `AppView`, not here — see that file's comment for the full real order): Name Entry →
/// Intent Selection → Notification Permission → Preparing Space → the mandatory first
/// capture (Screen 7, locked `🔒 MANDATORY` in `docs/PILLAR_ONBOARDING_STRATEGY.md`).
///
/// Resumes from `ProfileManager`'s `current_onboarding_screen` pointer rather than always
/// starting at Name Entry — a relaunch mid-flow (e.g. after Notification Permission's OS
/// prompt backgrounds the app) must not re-ask a question the user already answered.
struct OnboardingCoordinatorView: View {
    let userId: String
    let userEmail: String?
    let syncManager: SyncManager
    var onOnboardingComplete: () -> Void

    @State private var screen: OnboardingScreen
    @State private var showFirstCapture = false
    @State private var showAdultNotice = false

    init(userId: String, userEmail: String?, syncManager: SyncManager, onOnboardingComplete: @escaping () -> Void) {
        self.userId = userId
        self.userEmail = userEmail
        self.syncManager = syncManager
        self.onOnboardingComplete = onOnboardingComplete
        let initialScreen = ProfileManager.shared.localProfile(userId: userId).currentScreen
        _screen = State(initialValue: initialScreen)
        // `OnboardingScreen`'s own rawValue ("name", "intent", "notifications",
        // "preparing_space") already matches the event-naming scheme used elsewhere here.
        UsageTracker.shared.logOnboardingScreenReached(userId: userId, userEmail: userEmail, screen: initialScreen.rawValue)
    }

    var body: some View {
        Group {
            switch screen {
            case .name:
                NameEntryView(userId: userId, onContinue: { advance(to: .intent) }, onBack: { /* Account Creation owns this step's back nav */ })
            case .intent:
                IntentSelectionView(userId: userId, onContinue: { advance(to: .notifications) }, onBack: { goBack(to: .name) })
            case .notifications:
                NotificationPermissionView(userId: userId, onContinue: { advance(to: .preparingSpace) }, onBack: { goBack(to: .intent) })
            case .preparingSpace:
                PreparingSpaceView(
                    name: ProfileManager.shared.localProfile(userId: userId).name,
                    onComplete: {
                        // Nov 27 2026 (Kell): one-time 18+ beta notice right before
                        // the very first capture.
                        if UserDefaults.standard.bool(forKey: AdultBetaNoticeView.seenKey(userId)) {
                            showFirstCapture = true
                        } else {
                            showAdultNotice = true
                        }
                    }
                )
                .overlay {
                    if showAdultNotice {
                        AdultBetaNoticeView(onContinue: {
                            UserDefaults.standard.set(true, forKey: AdultBetaNoticeView.seenKey(userId))
                            showAdultNotice = false
                            showFirstCapture = true
                        })
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: showAdultNotice)
            }
        }
        .environment(\.colorScheme, .dark)
        .onChange(of: showFirstCapture) { shown in
            if shown {
                UsageTracker.shared.logOnboardingScreenReached(userId: userId, userEmail: userEmail, screen: "first_capture")
            }
        }
        .fullScreenCover(isPresented: $showFirstCapture) {
            // CaptureView merged into CaptureConversationView (Nov 17 2026) -- no
            // preset initialMessage means this opens straight into the idle state.
            CaptureConversationView(userId: userId, userEmail: userEmail, syncManager: syncManager, isOnboarding: true, onMomentSaved: {
                ProfileManager.shared.completeOnboarding(userId: userId)
                showFirstCapture = false
                onOnboardingComplete()
            })
            // First capture is mandatory here (Screen 7, locked) — unlike every other
            // presentation of this screen in the app, there's no swipe-to-dismiss
            // escape: onboarding has nowhere else for the user to land yet.
            .interactiveDismissDisabled()
        }
    }

    private func advance(to next: OnboardingScreen) {
        ProfileManager.shared.setCurrentScreen(next, userId: userId)
        screen = next
        UsageTracker.shared.logOnboardingScreenReached(userId: userId, userEmail: userEmail, screen: next.rawValue)
    }

    /// Back navigation does NOT re-persist `current_onboarding_screen` — the resume
    /// pointer should always reflect the furthest point reached, so a relaunch after
    /// stepping back doesn't lose forward progress the user already made.
    private func goBack(to previous: OnboardingScreen) {
        screen = previous
    }
}

/// Nov 27 2026 (Kell): shown once, before the first capture. The beta is for adults,
/// and Dwelly is a reflection space, not a crisis service.
struct AdultBetaNoticeView: View {
    var onContinue: () -> Void
    static func seenKey(_ userId: String) -> String { "adultBetaNoticeSeen.\(userId)" }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(alignment: .leading, spacing: 16) {
                Text("Before you begin")
                    .font(.system(size: 28, weight: .semibold, design: .serif))
                    .foregroundColor(Theme.Payment.textHeading)
                Text("Dwelly's beta is for adults 18 and older.")
                    .font(.system(size: 17))
                    .foregroundColor(Theme.Payment.textHeading)
                Text("Dwelly is a place to reflect with God. It isn't a counselor or a crisis service.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Payment.textSupporting)
                Text("If you're ever in danger or thinking about hurting yourself, call or text 988 in the US, or your local emergency number. Help is always in Profile under Support & Feedback.")
                    .font(.system(size: 15))
                    .foregroundColor(Theme.Payment.textSupporting)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Button(action: onContinue) {
                Text("I'm 18 or older · Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Capsule().fill(Theme.gold))
            }
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Payment.background.ignoresSafeArea())
    }
}

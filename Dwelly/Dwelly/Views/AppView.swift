import SwiftUI

/// T-112's Navigation Gate — three nested checks, not a flat branch:
/// Authenticated? → Already have an account? (sign-in recovery) → Onboarding complete?
/// (includes mandatory first capture) → resume or unlock.
///
/// The one-time Intro Video + Paywall steps (already built — `IntroVideoView`,
/// `PaywallView(context: .onboardingSkippable)`) sit between Account Creation and the 4
/// real T-110 screens per the locked real order (`docs/MEMORY.md`, Nov 4 2026 close):
/// Welcome → Account Creation → Intro Video → Paywall → Name → Intent → Notifications →
/// Preparing Space. They aren't part of `OnboardingProfile`'s resume pointer (nothing to
/// persist — no data is collected on either screen), so a lightweight local-only flag
/// tracks whether this device has already shown them for this user.
private enum OnboardingLeadIn {
    case introVideo
    case paywall
    case coordinator
}

struct AppView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.apiClient) private var apiClient
    let syncManager: SyncManager

    @State private var isOnboardingComplete = false
    @State private var hasCheckedOnboarding = false
    @State private var leadIn: OnboardingLeadIn = .introVideo

    private func leadInKey(userId: String) -> String { "onboarding_leadin_shown_\(userId)" }

    var body: some View {
        // AppView is only shown when authenticated, so we can safely force-unwrap currentUser
        if let user = authManager.currentUser {
            Group {
                if !hasCheckedOnboarding {
                    ProgressView("Loading...")
                } else if isOnboardingComplete {
                    MainTabView(userId: user.id, userEmail: user.email, syncManager: syncManager)
                } else {
                    onboardingLeadIn(user: user)
                }
            }
            .environment(\.colorScheme, .dark)
            .task {
                await evaluateOnboardingGate(userId: user.id, email: user.email)
            }
            .onAppear {
                // Set real userId on SyncManager (replaces placeholder "app-sync")
                syncManager.updateUserId(user.id)
                syncManager.syncPendingMoments()

                // Log app session
                print("🔍 AppView: Logging app_opened — userId: \(user.id.prefix(8)), email: \(user.email)")
                UsageTracker.shared.logAppOpened(userId: user.id, userEmail: user.email, isNewSignup: authManager.isFreshlyAuthenticated)

                // Sync analytics to backend
                Task {
                    do {
                        try await UsageTracker.shared.syncEventsToBackend(userId: user.id, apiClient: apiClient)
                    } catch {
                        print("⚠️ Analytics sync failed: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            // Fallback if currentUser is nil (shouldn't happen in normal flow)
            ProgressView("Loading...")
                .environment(\.colorScheme, .dark)
        }
    }

    /// Checks 2 and 3 of the gate. Local-first (never blocks on network): "sign-in
    /// recovery" (an existing user with moments predating this onboarding flow) and an
    /// already-`onboarding_completed_at` profile both short-circuit straight to
    /// `MainTabView`. Only a genuinely fresh account (no local completion flag, no
    /// moments) falls through to the lead-in + coordinator.
    ///
    /// Also the real fix for a bug Kell hit repeatedly: deleting the app (or even the
    /// Supabase row) does NOT clear Keychain — that's standard iOS behavior, not a bug in
    /// this app — so `AuthManager.init` restores `isAuthenticated = true` from a stale
    /// token for a user that no longer exists server-side, and the gate used to just
    /// silently keep going with whatever was in the local profile cache (same userId, so
    /// it "resumed" onboarding exactly where a previous test run left off, forever). Now a
    /// confirmed-gone account forces a real sign-out back to Welcome instead.
    ///
    /// Corrected Nov 5, 2026, same session: a `public.users` row missing for a real reason
    /// other than "account deleted" — `AuthManager.signIn`'s own `ensureUserExists` call
    /// failing silently (it only logs, per its own comment) on a brand-new or just-confirmed
    /// account — looks identical to a deleted account from here: both are a 404 on
    /// `fetchOnboardingProfile`. Kell hit exactly this logging in right after an email
    /// confirmation, and got bounced straight back to Welcome. So a 404 now retries
    /// `ensureUserExists` once (self-heals the missing row for a real account) before ever
    /// concluding the account is actually gone.
    ///
    /// Corrected again Nov 6, 2026: that retry still wasn't enough during a real slow
    /// network spell right after signup (confirmed in Supabase's own Postgres/PostgREST
    /// logs: a request got killed by PostgREST's own timeout manager seconds after the
    /// real OTP verification succeeded). The deeper fix is that *escalating a failed
    /// existence check all the way to a forced sign-out* is only meaningful for a session
    /// *restored* from Keychain at launch — for a session this app instance just
    /// authenticated itself (sign up, sign in, OTP verify), there is nothing to doubt, no
    /// matter how slow or flaky the next network call is. `isFreshlyAuthenticated` (false
    /// only on a Keychain-restored session) gates just that escalation; the actual
    /// `refreshFromServer` call still always runs so real synced profile data (onboarding
    /// progress from another device, for example) is still pulled down either way.
    private func evaluateOnboardingGate(userId: String, email: String) async {
        if !ProfileManager.shared.isOnboardingComplete(userId: userId) {
            var userStillExists = await ProfileManager.shared.refreshFromServer(userId: userId)
            if !userStillExists && !authManager.isFreshlyAuthenticated {
                try? await apiClient.ensureUserExists(userId: userId, email: email)
                userStillExists = await ProfileManager.shared.refreshFromServer(userId: userId)
            }
            if !userStillExists && !authManager.isFreshlyAuthenticated {
                await authManager.signOut()
                return
            }
        }
        // T-116: distinguish the real sign-in-recovery path (grandfathered pre-onboarding
        // users with existing moments) from a genuinely completed onboarding — both
        // collapse into the same `isOnboardingComplete` bool, but the locked P0 success
        // metrics track sign-in recovery as its own event.
        let profile = ProfileManager.shared.localProfile(userId: userId)
        let isSignInRecovery = profile.onboardingCompletedAt == nil && ProfileManager.shared.hasExistingMoments(userId: userId)
        if isSignInRecovery {
            UsageTracker.shared.logSignInRecoveryUsed(userId: userId, userEmail: email)
        }

        let complete = ProfileManager.shared.isOnboardingComplete(userId: userId)
        leadIn = UserDefaults.standard.bool(forKey: leadInKey(userId: userId)) ? .coordinator : .introVideo
        isOnboardingComplete = complete
        hasCheckedOnboarding = true

        if !complete {
            UsageTracker.shared.logOnboardingScreenReached(userId: userId, userEmail: email, screen: leadIn == .coordinator ? "coordinator_resume" : "intro_video")
        }
    }

    @ViewBuilder
    private func onboardingLeadIn(user: AuthUser) -> some View {
        switch leadIn {
        case .introVideo:
            IntroVideoView(onContinue: {
                UsageTracker.shared.logOnboardingScreenReached(userId: user.id, userEmail: user.email, screen: "paywall")
                leadIn = .paywall
            })
        case .paywall:
            PaywallView(context: .onboardingSkippable, onDismiss: {
                UserDefaults.standard.set(true, forKey: leadInKey(userId: user.id))
                leadIn = .coordinator
            })
        case .coordinator:
            OnboardingCoordinatorView(
                userId: user.id,
                userEmail: user.email,
                syncManager: syncManager,
                onOnboardingComplete: {
                    UsageTracker.shared.logOnboardingCompleted(userId: user.id, userEmail: user.email)
                    isOnboardingComplete = true
                }
            )
        }
    }
}

#Preview {
    let apiClient = MockAPIClient()
    let syncManager = SyncManager(apiClient: apiClient, userId: "preview-user")
    AppView(syncManager: syncManager)
        .environmentObject(AuthManager(apiClient: apiClient))
        .environment(\.apiClient, apiClient)
}

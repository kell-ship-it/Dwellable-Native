import Foundation

/// Row shape for `public.users`' onboarding columns (T-111 migration: name,
/// spiritual_intent, capture_rhythm, privacy_acknowledged, notification_opt_in,
/// onboarding_completed_at, current_onboarding_screen). `onboarding_completed_at` stays a
/// `String?` (not `Date?`) so decoding it never depends on `SupabaseAPIClient`'s custom
/// date-decoding strategy — only its presence/absence matters here, never its value.
struct OnboardingProfileRow: Decodable {
    let id: String
    let name: String?
    let spiritual_intent: String?
    let notification_opt_in: Bool?
    let onboarding_completed_at: String?
    let current_onboarding_screen: String?
    // T-086: Default/Sparse/Off from the real Notifications settings screen (Figma node
    // 686:259). Distinct from `notification_opt_in` above, which is onboarding's one-time
    // permission-request answer, not an ongoing preference -- a user can opt in at
    // onboarding and still later dial the mode down to Sparse or Off.
    let notification_mode: String?
}

/// Partial PATCH body for `public.users`. Manual `encode(to:)` with `encodeIfPresent` so an
/// unset field is omitted from the JSON entirely, not sent as an explicit `null` — PostgREST
/// only touches columns present in the body, so omitting is what makes this a true partial
/// update instead of silently clearing every other onboarding field on each call.
struct OnboardingProfileUpdate: Encodable {
    var name: String?
    var spiritualIntent: String?
    var notificationOptIn: Bool?
    var onboardingCompletedAt: String?
    var currentOnboardingScreen: String?
    var notificationMode: String?

    enum CodingKeys: String, CodingKey {
        case name
        case spiritualIntent = "spiritual_intent"
        case notificationOptIn = "notification_opt_in"
        case onboardingCompletedAt = "onboarding_completed_at"
        case currentOnboardingScreen = "current_onboarding_screen"
        case notificationMode = "notification_mode"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(spiritualIntent, forKey: .spiritualIntent)
        try container.encodeIfPresent(notificationOptIn, forKey: .notificationOptIn)
        try container.encodeIfPresent(onboardingCompletedAt, forKey: .onboardingCompletedAt)
        try container.encodeIfPresent(currentOnboardingScreen, forKey: .currentOnboardingScreen)
        try container.encodeIfPresent(notificationMode, forKey: .notificationMode)
    }
}

/// T-086's 3 real modes -- matches the `notification_mode` column's check constraint
/// exactly, so an invalid raw value can never be constructed client-side. No "Sabbath/Quiet
/// Days" case: the ticket's written spec mentioned one, but the actual locked Figma design
/// (node 686:259) only ever shows this 3-way picker -- same drift-from-ticket-text pattern
/// as T-130/T-181/etc. this session, resolved the same way (trust the real design).
enum NotificationMode: String, Codable, CaseIterable {
    case defaultMode = "default"
    case sparse
    case off

    var displayName: String {
        switch self {
        case .defaultMode: return "Default"
        case .sparse: return "Sparse"
        case .off: return "Off"
        }
    }
}

/// The 4 screens `OnboardingCoordinatorView` still owns after Account Creation (T-110):
/// Name Entry → Intent Selection → Notification Permission → Preparing Space. Stored as
/// `current_onboarding_screen`'s raw value so a relaunch mid-flow resumes at the right step
/// instead of restarting from Name Entry every time.
enum OnboardingScreen: String, Codable {
    case name
    case intent
    case notifications
    case preparingSpace = "preparing_space"
}

/// A user's onboarding progress, cached locally (offline-first, same pattern as
/// `LocalStorageManager`'s moments queue) and mirrored to `public.users` in the background.
/// Local cache is the source of truth for "is onboarding complete" on this device —
/// `AppView`'s navigation gate (T-112) must never block on a network round-trip.
struct OnboardingProfile: Codable {
    var name: String?
    var spiritualIntent: String?
    var notificationOptIn: Bool?
    var onboardingCompletedAt: Date?
    var currentScreen: OnboardingScreen
    // Defaults to `.defaultMode` (not nil) since that's this column's own real server
    // default -- a user who's never touched Notifications settings is on Default already,
    // not in some unset third state.
    var notificationMode: NotificationMode = .defaultMode

    static let empty = OnboardingProfile(name: nil, spiritualIntent: nil, notificationOptIn: nil, onboardingCompletedAt: nil, currentScreen: .name)
}

/// T-111. Owns the onboarding profile's local cache + background sync to Supabase.
/// Deliberately not `@MainActor`/`ObservableObject` — `OnboardingCoordinatorView` drives its
/// own `@State` for the current screen; this manager only persists, it doesn't publish.
final class ProfileManager {
    static let shared = ProfileManager()

    private var apiClient: APIClient

    init(apiClient: APIClient = SupabaseAPIClient()) {
        self.apiClient = apiClient
    }

    /// Caught live, Nov 17 2026 (Kell): `.shared`'s default `SupabaseAPIClient()` above is
    /// its OWN, separate instance -- never the one `DwellyApp` authenticates via
    /// `setTokens`/`setJWTToken` after login. Every `syncInBackground` write since T-111
    /// (setName, setIntent, setNotificationOptIn, completeOnboarding, setCurrentScreen, and
    /// the new setNotificationMode below) has been sending its PATCH under the anon key
    /// instead of the real user's JWT -- which doesn't 401, it just gets silently filtered
    /// to zero rows by RLS, so nothing ever threw and nothing ever looked broken locally.
    /// `DwellyApp.init()` calls this once with the exact same `apiClient` instance it hands
    /// everything else, so `.shared` is finally working with a real, authenticated session.
    func configure(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    private func cacheKey(userId: String) -> String { "onboarding_profile_\(userId)" }

    func localProfile(userId: String) -> OnboardingProfile {
        guard let data = UserDefaults.standard.data(forKey: cacheKey(userId: userId)),
              let profile = try? JSONDecoder().decode(OnboardingProfile.self, from: data) else {
            return .empty
        }
        return profile
    }

    private func saveLocal(_ profile: OnboardingProfile, userId: String) {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: cacheKey(userId: userId))
    }

    /// T-112's "already have an account? (sign-in recovery)" check: a user who already has
    /// moments predates this onboarding flow entirely (their `onboarding_completed_at` is
    /// genuinely null — they signed up before the column existed) and must never be routed
    /// backward into Name Entry. Checked alongside `onboarding_completed_at` by the gate,
    /// never used alone — a user who explicitly deleted every moment should still be
    /// considered onboarded if they already finished the flow.
    func hasExistingMoments(userId: String) -> Bool {
        !LocalStorageManager.shared.getAllLocalMoments(userId: userId).isEmpty
    }

    func isOnboardingComplete(userId: String) -> Bool {
        localProfile(userId: userId).onboardingCompletedAt != nil || hasExistingMoments(userId: userId)
    }

    /// Pulls the server's copy once (e.g. right after sign-in on a fresh device/reinstall,
    /// where the local cache is empty but Supabase already has this user's progress) and
    /// merges it into the local cache. Best-effort — failures leave the local cache as-is;
    /// onboarding must work fully offline.
    /// Returns `false` specifically when the server says this userId no longer exists
    /// (`APIError.notFound`) — a deleted account whose Keychain session survived an app
    /// delete/reinstall (standard iOS behavior: Keychain items aren't tied to app install)
    /// — or when `.unauthorized` comes back, which `SupabaseAPIClient` now only throws
    /// here after a real attempt to renew the session's refresh token was itself rejected
    /// (T-113: previously any such failure fell into the generic `catch` below and was
    /// treated as transient, so a genuinely dead refresh token left the user stuck
    /// "signed in" to a session that could never make another successful request).
    /// Every other failure (network error, timeout) still returns `true` and leaves the
    /// local cache untouched — only a *confirmed* "this session is gone" should ever
    /// force a sign-out; a flaky network shouldn't kick someone out of their own session.
    @discardableResult
    func refreshFromServer(userId: String) async -> Bool {
        do {
            let row = try await apiClient.fetchOnboardingProfile(userId: userId)
            applyServerRow(row, userId: userId)
            return true
        } catch APIError.notFound, APIError.unauthorized {
            return false
        } catch {
            return true
        }
    }

    private func applyServerRow(_ row: OnboardingProfileRow, userId: String) {
        var profile = localProfile(userId: userId)
        profile.name = row.name ?? profile.name
        profile.spiritualIntent = row.spiritual_intent ?? profile.spiritualIntent
        profile.notificationOptIn = row.notification_opt_in ?? profile.notificationOptIn
        if let completed = row.onboarding_completed_at {
            profile.onboardingCompletedAt = ISO8601DateFormatter().date(from: completed) ?? profile.onboardingCompletedAt
        }
        if let screenRaw = row.current_onboarding_screen, let screen = OnboardingScreen(rawValue: screenRaw) {
            profile.currentScreen = screen
        }
        if let modeRaw = row.notification_mode, let mode = NotificationMode(rawValue: modeRaw) {
            profile.notificationMode = mode
        }
        saveLocal(profile, userId: userId)
    }

    func setName(_ name: String, userId: String) {
        var profile = localProfile(userId: userId)
        profile.name = name
        saveLocal(profile, userId: userId)
        syncInBackground(userId: userId, update: OnboardingProfileUpdate(name: name))
    }

    func setIntent(_ intent: String, userId: String) {
        var profile = localProfile(userId: userId)
        profile.spiritualIntent = intent
        saveLocal(profile, userId: userId)
        syncInBackground(userId: userId, update: OnboardingProfileUpdate(spiritualIntent: intent))
    }

    func setNotificationOptIn(_ optIn: Bool, userId: String) {
        var profile = localProfile(userId: userId)
        profile.notificationOptIn = optIn
        saveLocal(profile, userId: userId)
        syncInBackground(userId: userId, update: OnboardingProfileUpdate(notificationOptIn: optIn))
    }

    func setNotificationMode(_ mode: NotificationMode, userId: String) {
        var profile = localProfile(userId: userId)
        profile.notificationMode = mode
        saveLocal(profile, userId: userId)
        syncInBackground(userId: userId, update: OnboardingProfileUpdate(notificationMode: mode.rawValue))
    }

    func setCurrentScreen(_ screen: OnboardingScreen, userId: String) {
        var profile = localProfile(userId: userId)
        profile.currentScreen = screen
        saveLocal(profile, userId: userId)
        syncInBackground(userId: userId, update: OnboardingProfileUpdate(currentOnboardingScreen: screen.rawValue))
    }

    /// Set only after the mandatory first capture completes (T-112) — never at the end of
    /// Preparing Space itself. Called by `OnboardingCoordinatorView` right after
    /// `CaptureView`'s `onMomentSaved` fires.
    func completeOnboarding(userId: String) {
        var profile = localProfile(userId: userId)
        let now = Date()
        profile.onboardingCompletedAt = now
        saveLocal(profile, userId: userId)
        syncInBackground(userId: userId, update: OnboardingProfileUpdate(onboardingCompletedAt: ISO8601DateFormatter().string(from: now)))
    }

    /// Fire-and-forget — same offline-first philosophy as `SyncManager`'s moment uploads.
    /// A failed PATCH here just means the next successful one (or `refreshFromServer`)
    /// catches the server back up; the local cache already has the real value.
    private func syncInBackground(userId: String, update: OnboardingProfileUpdate) {
        Task {
            try? await apiClient.updateOnboardingProfile(userId: userId, update: update)
        }
    }
}

import Foundation

class UsageTracker {
    static let shared = UsageTracker()

    // MARK: - Event Models

    struct UsageEvent: Codable {
        let id: String
        let userId: String
        let userEmail: String?
        let eventType: String // "moment_created", "app_opened", "app_closed"
        let momentType: String? // "voice" or "text" (only for moment_created)
        let timestamp: Date
    }

    /// T-116: pre-signup funnel event (Welcome, Account Creation) — there is no `userId`
    /// yet at this point in the flow, only `anonymousDeviceId`.
    struct AnonymousUsageEvent: Codable {
        let id: String
        let anonymousId: String
        let eventType: String
        let momentType: String? // screen name, e.g. "welcome", "account_creation"
        let timestamp: Date
    }

    // MARK: - Anonymous Device ID

    /// T-116: Keychain, not UserDefaults — this ID has to survive app delete/reinstall so a
    /// user who deletes the app mid-onboarding and reinstalls doesn't get counted as a brand
    /// new "Welcome reached" the second time, which would inflate the pre-signup funnel's
    /// denominator and understate drop-off. UserDefaults is cleared on uninstall; Keychain
    /// (with the default, non-biometric access class `KeychainManager` already uses
    /// elsewhere) is not.
    private static let anonymousIdKeychainKey = "anonymousDeviceId"

    lazy var anonymousDeviceId: String = {
        if let existing = KeychainManager.shared.retrieve(forKey: Self.anonymousIdKeychainKey) {
            return existing
        }
        let fresh = UUID().uuidString
        _ = KeychainManager.shared.save(fresh, forKey: Self.anonymousIdKeychainKey)
        return fresh
    }()

    // MARK: - Event Logging

    func logMomentCreated(userId: String, userEmail: String?, type: String) {
        let event = UsageEvent(
            id: UUID().uuidString,
            userId: userId,
            userEmail: userEmail,
            eventType: "moment_created",
            momentType: type, // "voice" or "text"
            timestamp: Date()
        )
        saveEvent(event, userId: userId)
    }

    /// T-116: `isNewSignup` tags this open as the new-vs-returning split the locked P0
    /// success metrics call for — pass `AuthManager.isFreshlyAuthenticated` from the call
    /// site right after a real sign-up in this launch, `false` otherwise (including every
    /// existing call site, via the default, which is why this stays source-compatible).
    func logAppOpened(userId: String, userEmail: String?, isNewSignup: Bool = false) {
        print("📊 UsageTracker.logAppOpened — userId: \(userId.prefix(8)), userEmail: \(userEmail ?? "NIL")")
        let event = UsageEvent(
            id: UUID().uuidString,
            userId: userId,
            userEmail: userEmail,
            eventType: "app_opened",
            momentType: isNewSignup ? "new_signup" : "returning_user",
            timestamp: Date()
        )
        saveEvent(event, userId: userId)
        print("✅ Event saved locally with email: \(userEmail ?? "NIL")")
    }

    /// T-116: one event per onboarding screen actually reached, keyed by `screen` (e.g.
    /// "intro_video", "account_creation", "name_entry", "intent_selection",
    /// "notification_permission", "preparing_space", "first_capture") — this is the raw
    /// material the locked P0 success metrics (>90% reach Screen 7, drop-off analysis)
    /// need and had no instrumentation for at all before this.
    func logOnboardingScreenReached(userId: String, userEmail: String?, screen: String) {
        let event = UsageEvent(
            id: UUID().uuidString,
            userId: userId,
            userEmail: userEmail,
            eventType: "onboarding_screen_reached",
            momentType: screen,
            timestamp: Date()
        )
        saveEvent(event, userId: userId)
    }

    /// T-116: fires once, when `onboarding_completed_at` is actually set (the real
    /// Screen-7/mandatory-first-capture completion) — the other half of the >80%
    /// first-capture metric alongside `logOnboardingScreenReached(..., screen: "first_capture")`.
    func logOnboardingCompleted(userId: String, userEmail: String?) {
        let event = UsageEvent(
            id: UUID().uuidString,
            userId: userId,
            userEmail: userEmail,
            eventType: "onboarding_completed",
            momentType: nil,
            timestamp: Date()
        )
        saveEvent(event, userId: userId)
    }

    /// T-116: fires when `AppView`'s gate takes the sign-in-recovery branch — an
    /// authenticated user with existing moments but no `onboarding_completed_at`,
    /// grandfathered straight into `MainTabView` instead of the onboarding flow. Locked
    /// P0 success metrics call this out by name as its own tracked path.
    func logSignInRecoveryUsed(userId: String, userEmail: String?) {
        let event = UsageEvent(
            id: UUID().uuidString,
            userId: userId,
            userEmail: userEmail,
            eventType: "sign_in_recovery_used",
            momentType: nil,
            timestamp: Date()
        )
        saveEvent(event, userId: userId)
    }

    /// T-116: Welcome/Account Creation happen before a real `userId` exists, so this is
    /// keyed by `anonymousDeviceId` instead — the only way to see pre-signup drop-off
    /// (how many devices reach Welcome vs. actually reach/complete Account Creation).
    func logAnonymousOnboardingScreenReached(screen: String) {
        let event = AnonymousUsageEvent(
            id: UUID().uuidString,
            anonymousId: anonymousDeviceId,
            eventType: "onboarding_screen_reached",
            momentType: screen,
            timestamp: Date()
        )
        saveAnonymousEvent(event)
    }

    func logAppClosed(userId: String, userEmail: String?) {
        let event = UsageEvent(
            id: UUID().uuidString,
            userId: userId,
            userEmail: userEmail,
            eventType: "app_closed",
            momentType: nil,
            timestamp: Date()
        )
        saveEvent(event, userId: userId)
    }

    // MARK: - Private Storage

    private func saveEvent(_ event: UsageEvent, userId: String) {
        var events = getEvents(userId: userId)
        events.append(event)

        if let encoded = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(encoded, forKey: eventsKey(userId: userId))
        }
    }

    private func eventsKey(userId: String) -> String {
        "usage_events_\(userId)"
    }

    private func saveAnonymousEvent(_ event: AnonymousUsageEvent) {
        var events = getAnonymousEvents()
        events.append(event)

        if let encoded = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(encoded, forKey: anonymousEventsKey)
        }
    }

    private var anonymousEventsKey: String { "usage_events_anonymous" }

    private func getAnonymousEvents() -> [AnonymousUsageEvent] {
        guard let data = UserDefaults.standard.data(forKey: anonymousEventsKey) else {
            return []
        }
        return (try? JSONDecoder().decode([AnonymousUsageEvent].self, from: data)) ?? []
    }

    private func clearAnonymousEvents() {
        UserDefaults.standard.removeObject(forKey: anonymousEventsKey)
    }

    // MARK: - Public Access

    func getEvents(userId: String) -> [UsageEvent] {
        guard let data = UserDefaults.standard.data(forKey: eventsKey(userId: userId)) else {
            return []
        }
        return (try? JSONDecoder().decode([UsageEvent].self, from: data)) ?? []
    }

    func getEventsSince(userId: String, date: Date) -> [UsageEvent] {
        return getEvents(userId: userId).filter { $0.timestamp >= date }
    }

    func clearEvents(userId: String) {
        UserDefaults.standard.removeObject(forKey: eventsKey(userId: userId))
    }

    // MARK: - Analytics Summary

    func getAnalyticsSummary(userId: String) -> [String: Any] {
        let events = getEvents(userId: userId)
        let momentCreatedEvents = events.filter { $0.eventType == "moment_created" }
        let voiceMoments = momentCreatedEvents.filter { $0.momentType == "voice" }.count
        let textMoments = momentCreatedEvents.filter { $0.momentType == "text" }.count

        let sessionEvents = events.filter { $0.eventType == "app_opened" || $0.eventType == "app_closed" }
        let sessionCount = sessionEvents.filter { $0.eventType == "app_opened" }.count

        return [
            "total_moments_created": momentCreatedEvents.count,
            "voice_moments": voiceMoments,
            "text_moments": textMoments,
            "total_sessions": sessionCount,
            "last_active": events.last?.timestamp ?? Date(),
            "event_count": events.count
        ]
    }

    // MARK: - Backend Sync

    func syncEventsToBackend(userId: String, apiClient: APIClient) async throws {
        let events = getEvents(userId: userId)
        guard !events.isEmpty else {
            print("ℹ️ No events to sync for userId: \(userId)")
            return
        }

        print("📤 Syncing \(events.count) usage events for userId: \(userId)")
        do {
            // Convert UsageEvent to UsageEventData for API
            let eventData = events.map { event in
                UsageEventData(
                    id: event.id,
                    userId: userId,
                    userEmail: event.userEmail,
                    eventType: event.eventType,
                    momentType: event.momentType,
                    timestamp: event.timestamp
                )
            }
            print("📊 Event data being sent:")
            for data in eventData {
                print("  - \(data.eventType): userEmail = \(data.userEmail ?? "NIL")")
            }
            try await apiClient.sendUsageEvents(eventData, userId: userId)
            // Clear local events after successful sync
            clearEvents(userId: userId)
            print("✅ Usage events synced to backend successfully (\(events.count) events)")
        } catch {
            print("⚠️ Failed to sync usage events: \(error.localizedDescription)")
            print("⚠️ Full error: \(error)")
            print("⚠️ Events remain locally for retry")
            // Keep events locally if sync fails; will retry next time
            throw error
        }
    }

    /// T-116: syncs pre-signup events over the `apiClient`'s anon-key auth (no JWT exists
    /// yet) — called right after Welcome/Account Creation are reached, not batched with the
    /// per-user sync cycle, since there may never be a later authenticated session to piggy
    /// back on if the person drops off before signing up at all.
    func syncAnonymousEventsToBackend(apiClient: APIClient) async throws {
        let events = getAnonymousEvents()
        guard !events.isEmpty else { return }

        let eventData = events.map { event in
            AnonymousUsageEventData(
                id: event.id,
                anonymousId: event.anonymousId,
                eventType: event.eventType,
                momentType: event.momentType,
                timestamp: event.timestamp
            )
        }
        do {
            try await apiClient.sendAnonymousUsageEvents(eventData)
            clearAnonymousEvents()
        } catch {
            // Keep events locally if sync fails; will retry next time this fires.
            throw error
        }
    }
}

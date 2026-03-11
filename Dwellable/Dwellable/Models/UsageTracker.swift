import Foundation

class UsageTracker {
    static let shared = UsageTracker()

    // MARK: - Event Models

    struct UsageEvent: Codable {
        let id: String
        let userId: String
        let eventType: String // "moment_created", "app_opened", "app_closed"
        let momentType: String? // "voice" or "text" (only for moment_created)
        let timestamp: Date
    }

    // MARK: - Event Logging

    func logMomentCreated(userId: String, type: String) {
        let event = UsageEvent(
            id: UUID().uuidString,
            userId: userId,
            eventType: "moment_created",
            momentType: type, // "voice" or "text"
            timestamp: Date()
        )
        saveEvent(event, userId: userId)
    }

    func logAppOpened(userId: String) {
        let event = UsageEvent(
            id: UUID().uuidString,
            userId: userId,
            eventType: "app_opened",
            momentType: nil,
            timestamp: Date()
        )
        saveEvent(event, userId: userId)
    }

    func logAppClosed(userId: String) {
        let event = UsageEvent(
            id: UUID().uuidString,
            userId: userId,
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
        guard !events.isEmpty else { return }

        do {
            // Convert UsageEvent to UsageEventData for API
            let eventData = events.map { event in
                UsageEventData(
                    id: event.id,
                    userId: userId,
                    eventType: event.eventType,
                    momentType: event.momentType,
                    timestamp: event.timestamp
                )
            }
            try await apiClient.sendUsageEvents(eventData, userId: userId)
            // Clear local events after successful sync
            clearEvents(userId: userId)
            print("✅ Usage events synced to backend successfully")
        } catch {
            print("⚠️ Failed to sync usage events: \(error.localizedDescription)")
            // Keep events locally if sync fails; will retry next time
            throw error
        }
    }
}

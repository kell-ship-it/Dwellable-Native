import Foundation

/// Saves the in-progress ONBOARDING capture on the phone (per account) so an app close, crash, or
/// sign-out/sign-in mid-conversation resumes where the person left off instead of starting over with a
/// fresh three replies and a fresh token allowance (MVP decision, Nov 23 2026).
///
/// Device-only, never sent anywhere. UserDefaults is included in iCloud/device backups, so a phone
/// restored from a backup brings it back. Deleted the moment the conversation completes. If it is
/// lost (no backup), the person simply restarts the onboarding chat -- accepted for MVP.
///
/// The safety record (`tiers`) is saved with the text on purpose: a conversation that already tripped
/// Crisis Support must stay latched after a restore, never reset to clean by a relaunch.
struct OnboardingCaptureSnapshot: Codable, Equatable {
    struct Turn: Codable, Equatable {
        let isUser: Bool
        let text: String
    }
    var captureId: String
    var turns: [Turn]
    var openedWithPromptQuestion: Bool
    var safetyClarifyExtraTurn: Bool
    var tiers: [String]
}

enum OnboardingCaptureStore {
    static func key(userId: String) -> String { "dwelly.onboardingCapture.\(userId)" }

    static func save(_ snapshot: OnboardingCaptureSnapshot, userId: String, defaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: key(userId: userId))
        defaults.synchronize() // flush to disk now; an immediate app kill must not lose it
    }

    /// Nil when nothing is saved, the data is unreadable, or it has no turns (nothing to resume).
    static func load(userId: String, defaults: UserDefaults = .standard) -> OnboardingCaptureSnapshot? {
        guard let data = defaults.data(forKey: key(userId: userId)),
              let snapshot = try? JSONDecoder().decode(OnboardingCaptureSnapshot.self, from: data),
              !snapshot.turns.isEmpty else { return nil }
        return snapshot
    }

    static func clear(userId: String, defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: key(userId: userId))
    }

    /// A reply that was still in flight when the app closed leaves the person's last message with no
    /// answer. Never silently lost and never auto-resent (that would be an unrequested paid call): the
    /// text goes back into the composer and the conversation resumes from the last answered turn.
    static func resume(_ snapshot: OnboardingCaptureSnapshot) -> (turns: [OnboardingCaptureSnapshot.Turn], composerText: String) {
        if let last = snapshot.turns.last, last.isUser {
            return (Array(snapshot.turns.dropLast()), last.text)
        }
        return (snapshot.turns, "")
    }
}

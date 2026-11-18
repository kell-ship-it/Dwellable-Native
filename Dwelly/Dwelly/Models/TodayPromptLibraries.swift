import Foundation

/// T-182: the Mood and Life-Domain sub-hero tiles, per the locked taxonomy
/// (`docs/PILLAR_TODAY_PROMPT_TAXONOMY.md`) -- both OFFLINE-CAPABLE (static rotating
/// list, zero LLM call, zero personalization beyond which entry is selected). Each
/// was previously a single hardcoded tile shown forever; this is the real
/// non-repeating daily rotation through the doc's locked content, same
/// day-boundary-cache pattern `DailyVerseLibrary.verseForToday()` already uses.
///
/// Deliberately out of scope here (separate tickets): Sustain/Follow-up (needs real
/// capture history), Intercession's own rotation (currently still a static tile, not
/// yet re-slotted as Follow-up's no-history fallback per the locked design), and the
/// cluster/echoes_mood/entry_id overlap-avoidance tagging scheme across all tiles at
/// once -- this only rotates Mood and Life-Domain each independently.
struct TodayPrompt: Identifiable {
    let id: Int
    let category: String
    let icon: String
    let title: String
    let subtitle: String
}

enum MoodPromptLibrary {
    // The 8 locked mood-palette words (Pillar 4), content from the taxonomy doc.
    static let prompts: [TodayPrompt] = [
        TodayPrompt(id: 0, category: "Mood", icon: "heart", title: "Felt a sense of peace recently?", subtitle: "What was happening right before it?"),
        TodayPrompt(id: 1, category: "Mood", icon: "heart", title: "What are you grateful for today?", subtitle: "Even something small counts."),
        TodayPrompt(id: 2, category: "Mood", icon: "heart", title: "Anything sitting with you lately?", subtitle: "No rush to figure it out."),
        TodayPrompt(id: 3, category: "Mood", icon: "heart", title: "What's giving you hope right now?", subtitle: "Hold onto that for a second."),
        TodayPrompt(id: 4, category: "Mood", icon: "heart", title: "Feeling torn about something?", subtitle: "That tension might be worth naming."),
        TodayPrompt(id: 5, category: "Mood", icon: "heart", title: "Running on empty lately?", subtitle: "That's worth bringing here too."),
        TodayPrompt(id: 6, category: "Mood", icon: "heart", title: "What's been on your heart to pray about?", subtitle: "Even unfinished prayers count."),
        TodayPrompt(id: 7, category: "Mood", icon: "heart", title: "When did you last feel loved?", subtitle: "Who or what reminded you?")
    ]

    private static let indexKey = "moodPrompt.index"
    private static let dateKey = "moodPrompt.dateString"

    static func promptForToday(defaults: UserDefaults = .standard) -> TodayPrompt {
        TodayPromptRotation.pick(from: prompts, indexKey: indexKey, dateKey: dateKey, defaults: defaults)
    }
}

enum LifeDomainPromptLibrary {
    // The 5 locked Life-Domain prompts (music, dreams, relationships, work, rest).
    static let prompts: [TodayPrompt] = [
        TodayPrompt(id: 0, category: "Life-Domain", icon: "mountain.2", title: "What worship song have you had on repeat?", subtitle: "How does it make you feel?"),
        TodayPrompt(id: 1, category: "Life-Domain", icon: "mountain.2", title: "Have you had any dreams lately?", subtitle: "Sometimes that's where God shows up."),
        TodayPrompt(id: 2, category: "Life-Domain", icon: "mountain.2", title: "Navigated conflict with a friend or family lately?", subtitle: "That can be holy ground too."),
        TodayPrompt(id: 3, category: "Life-Domain", icon: "mountain.2", title: "Anything from your workday that surprised you?", subtitle: "Big or small."),
        TodayPrompt(id: 4, category: "Life-Domain", icon: "mountain.2", title: "Been forced to slow down lately?", subtitle: "What's that been like?")
    ]

    private static let indexKey = "lifeDomainPrompt.index"
    private static let dateKey = "lifeDomainPrompt.dateString"

    static func promptForToday(defaults: UserDefaults = .standard) -> TodayPrompt {
        TodayPromptRotation.pick(from: prompts, indexKey: indexKey, dateKey: dateKey, defaults: defaults)
    }
}

/// Shared day-boundary, non-repeating rotation -- the exact logic
/// `DailyVerseLibrary.verseForToday()` already has, factored out so Mood and
/// Life-Domain (and any future offline-capable category) don't each reimplement it.
enum TodayPromptRotation {
    private static func todayString(calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    static func pick(from prompts: [TodayPrompt], indexKey: String, dateKey: String, defaults: UserDefaults) -> TodayPrompt {
        let today = todayString()
        if defaults.string(forKey: dateKey) == today {
            let cachedIndex = defaults.integer(forKey: indexKey)
            if prompts.indices.contains(cachedIndex) {
                return prompts[cachedIndex]
            }
        }

        let previousIndex = defaults.integer(forKey: indexKey)
        var candidates = Array(prompts.indices)
        if prompts.count > 1 {
            candidates.removeAll { $0 == previousIndex }
        }
        let newIndex = candidates.randomElement() ?? 0

        defaults.set(newIndex, forKey: indexKey)
        defaults.set(today, forKey: dateKey)
        return prompts[newIndex]
    }
}

import Foundation

/// T-182: the Mood and Life-Domain sub-hero tiles, per the locked taxonomy
/// (`docs/PILLAR_TODAY_PROMPT_TAXONOMY.md`) -- both OFFLINE-CAPABLE (static rotating
/// list, zero LLM call, zero personalization beyond which entry is selected). Each
/// was previously a single hardcoded tile shown forever; this is the real
/// non-repeating daily rotation through the doc's locked content, same
/// day-boundary-cache pattern `DailyVerseLibrary.verseForToday()` already uses.
///
/// Deliberately still out of scope here (separate ticket): the full
/// cluster/echoes_mood/entry_id overlap-avoidance tagging scheme across all tiles at
/// once. Sustain/Follow-up and Intercession's re-slotting as its fallback (see
/// `TodayView.followUpOrFallbackTile`) were added in a later pass of the same ticket.
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

/// T-182 continued: Intercession, re-slotted per the locked design as Sustain/
/// Follow-up's no-history fallback (`TodayView.followUpOrFallbackTile`) rather than a
/// 4th always-on tile -- shown only when the user has no eligible capture history to
/// follow up on. The 30 locked entries from the taxonomy doc, same rotation pattern.
enum IntercessionPromptLibrary {
    static let prompts: [TodayPrompt] = [
        TodayPrompt(id: 0, category: "Intercession", icon: "hands.sparkles", title: "Anyone on your heart lately?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 1, category: "Intercession", icon: "hands.sparkles", title: "Who came to mind today unprompted?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 2, category: "Intercession", icon: "hands.sparkles", title: "Anyone you've been carrying lately?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 3, category: "Intercession", icon: "hands.sparkles", title: "Someone you haven't checked on lately?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 4, category: "Intercession", icon: "hands.sparkles", title: "Anyone going through something hard?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 5, category: "Intercession", icon: "hands.sparkles", title: "Who's been on your mind this week?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 6, category: "Intercession", icon: "hands.sparkles", title: "Anyone you've meant to pray for?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 7, category: "Intercession", icon: "hands.sparkles", title: "Someone who needs encouragement?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 8, category: "Intercession", icon: "hands.sparkles", title: "Anyone you're worried about lately?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 9, category: "Intercession", icon: "hands.sparkles", title: "Who crossed your mind today?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 10, category: "Intercession", icon: "hands.sparkles", title: "Anyone you miss checking in with?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 11, category: "Intercession", icon: "hands.sparkles", title: "Someone celebrating something lately?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 12, category: "Intercession", icon: "hands.sparkles", title: "Anyone who's been quiet lately?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 13, category: "Intercession", icon: "hands.sparkles", title: "Who's walking through a hard season?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 14, category: "Intercession", icon: "hands.sparkles", title: "Anyone you've lost touch with?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 15, category: "Intercession", icon: "hands.sparkles", title: "Someone you're grateful for today?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 16, category: "Intercession", icon: "hands.sparkles", title: "Anyone facing a big decision right now?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 17, category: "Intercession", icon: "hands.sparkles", title: "Who could use a kind word today?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 18, category: "Intercession", icon: "hands.sparkles", title: "Anyone you've been avoiding lately?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 19, category: "Intercession", icon: "hands.sparkles", title: "Someone struggling that you know of?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 20, category: "Intercession", icon: "hands.sparkles", title: "Anyone waiting on good news?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 21, category: "Intercession", icon: "hands.sparkles", title: "Who's been carrying something heavy?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 22, category: "Intercession", icon: "hands.sparkles", title: "Anyone you haven't prayed for lately?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 23, category: "Intercession", icon: "hands.sparkles", title: "Someone new on your mind lately?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 24, category: "Intercession", icon: "hands.sparkles", title: "Anyone you feel distant from lately?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 25, category: "Intercession", icon: "hands.sparkles", title: "Who's been generous with you lately?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 26, category: "Intercession", icon: "hands.sparkles", title: "Anyone you want to see God's hand in?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 27, category: "Intercession", icon: "hands.sparkles", title: "Someone you've been thinking about?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 28, category: "Intercession", icon: "hands.sparkles", title: "Anyone who needs encouragement?", subtitle: "Worth a thought right now."),
        TodayPrompt(id: 29, category: "Intercession", icon: "hands.sparkles", title: "Who's been showing up for you lately?", subtitle: "Worth a thought right now.")
    ]

    private static let indexKey = "intercessionPrompt.index"
    private static let dateKey = "intercessionPrompt.dateString"

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

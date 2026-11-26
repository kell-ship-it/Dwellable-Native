import Foundation

/// T-182: the Mood and Life-Domain sub-hero tiles, per the locked taxonomy
/// (`docs/PILLAR_TODAY_PROMPT_TAXONOMY.md`) -- both OFFLINE-CAPABLE (static rotating
/// list, zero LLM call, zero personalization beyond which entry is selected). Each
/// was previously a single hardcoded tile shown forever; this is the real
/// non-repeating daily rotation through the doc's locked content, same
/// day-boundary-cache pattern `DailyVerseLibrary.verseForToday()` already uses.
///
/// Sustain/Follow-up and Intercession's re-slotting as its fallback (see
/// `TodayView.loadFollowUpTile(from:)`) were added in a later pass of the same ticket.
/// `cluster` (added in the pass after that) is the real tagging half of the doc's
/// overlap-avoidance scheme -- see `TodayTileOverlapResolver`.
struct TodayPrompt: Identifiable {
    let id: Int
    let category: String
    let icon: String
    let title: String
    let subtitle: String
    let cluster: String
}

enum MoodPromptLibrary {
    // The 8 locked mood-palette words (Pillar 4), content + cluster tags straight from
    // the taxonomy doc's own content bank.
    static let prompts: [TodayPrompt] = [
        TodayPrompt(id: 0, category: "Mood", icon: "heart", title: "Felt a sense of peace recently?", subtitle: "What was happening right before it?", cluster: "calm"),
        TodayPrompt(id: 1, category: "Mood", icon: "heart", title: "What are you grateful for today?", subtitle: "Even something small counts.", cluster: "gratitude"),
        TodayPrompt(id: 2, category: "Mood", icon: "heart", title: "Anything sitting with you lately?", subtitle: "No rush to figure it out.", cluster: "general-reflection"),
        TodayPrompt(id: 3, category: "Mood", icon: "heart", title: "What's giving you hope right now?", subtitle: "Hold onto that for a second.", cluster: "hope"),
        TodayPrompt(id: 4, category: "Mood", icon: "heart", title: "Feeling torn about something?", subtitle: "That tension might be worth naming.", cluster: "conflict"),
        TodayPrompt(id: 5, category: "Mood", icon: "heart", title: "Running on empty lately?", subtitle: "That's worth bringing here too.", cluster: "fatigue"),
        TodayPrompt(id: 6, category: "Mood", icon: "heart", title: "What's been on your heart to pray about?", subtitle: "Even unfinished prayers count.", cluster: "prayer-request"),
        TodayPrompt(id: 7, category: "Mood", icon: "heart", title: "When did you last feel loved?", subtitle: "Who or what reminded you?", cluster: "connection")
    ]

    // T-182 (overlap-avoidance): the real 8 locked mood words, in the same order as
    // `prompts` above -- lets `TodayTileOverlapResolver` map a journal entry's own
    // stored `moods` (plain lowercase words from Pillar 4's palette, e.g.
    // "conflicted") to the same cluster this library already tags its Mood tile
    // with, for the doc's `echoes_mood` check. Kept as a parallel array (not a new
    // field on `TodayPrompt`) since this mapping is Mood-specific -- Life-Domain and
    // Intercession have no equivalent "raw word" a journal entry could echo.
    static let moodWordClusters: [String: String] = [
        "peaceful": "calm",
        "grateful": "gratitude",
        "reflective": "general-reflection",
        "hopeful": "hope",
        "conflicted": "conflict",
        "exhausted": "fatigue",
        "prayerful": "prayer-request",
        "loved": "connection"
    ]

    // Not `private` -- `TodayView.resolveTileOverlaps()` re-rolls this cache directly
    // via `TodayPromptRotation.pickAvoiding`, so the keys need to match exactly.
    static let indexKey = "moodPrompt.index"
    static let dateKey = "moodPrompt.dateString"

    static func promptForToday(defaults: UserDefaults = .standard) -> TodayPrompt {
        TodayPromptRotation.pick(from: prompts, indexKey: indexKey, dateKey: dateKey, defaults: defaults)
    }
}

enum LifeDomainPromptLibrary {
    // The 5 locked Life-Domain prompts (music, dreams, relationships, work, rest).
    static let prompts: [TodayPrompt] = [
        TodayPrompt(id: 0, category: "Life-Domain", icon: "mountain.2", title: "What worship song have you had on repeat?", subtitle: "How does it make you feel?", cluster: "general-music"),
        TodayPrompt(id: 1, category: "Life-Domain", icon: "mountain.2", title: "Have you had any dreams lately?", subtitle: "Sometimes that's where God shows up.", cluster: "general-dreams"),
        TodayPrompt(id: 2, category: "Life-Domain", icon: "mountain.2", title: "Navigated conflict with a friend or family lately?", subtitle: "That can be holy ground too.", cluster: "conflict"),
        TodayPrompt(id: 3, category: "Life-Domain", icon: "mountain.2", title: "Anything from your workday that surprised you?", subtitle: "Big or small.", cluster: "general-work"),
        TodayPrompt(id: 4, category: "Life-Domain", icon: "mountain.2", title: "Been forced to slow down lately?", subtitle: "What's that been like?", cluster: "fatigue")
    ]

    static let indexKey = "lifeDomainPrompt.index"
    static let dateKey = "lifeDomainPrompt.dateString"

    static func promptForToday(defaults: UserDefaults = .standard) -> TodayPrompt {
        TodayPromptRotation.pick(from: prompts, indexKey: indexKey, dateKey: dateKey, defaults: defaults)
    }
}

/// T-182 continued: Intercession, re-slotted per the locked design as Sustain/
/// Follow-up's no-history fallback (`TodayView.loadFollowUpTile(from:)`) rather than a
/// 4th always-on tile -- shown only when the user has no eligible capture history to
/// follow up on. The 30 locked entries from the taxonomy doc, same rotation pattern +
/// the doc's own per-entry cluster tags.
enum IntercessionPromptLibrary {
    static let prompts: [TodayPrompt] = [
        TodayPrompt(id: 0, category: "Intercession", icon: "hands.sparkles", title: "Anyone on your heart lately?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 1, category: "Intercession", icon: "hands.sparkles", title: "Who came to mind today unprompted?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 2, category: "Intercession", icon: "hands.sparkles", title: "Anyone you've been carrying lately?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 3, category: "Intercession", icon: "hands.sparkles", title: "Someone you haven't checked on lately?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 4, category: "Intercession", icon: "hands.sparkles", title: "Anyone going through something hard?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 5, category: "Intercession", icon: "hands.sparkles", title: "Who's been on your mind this week?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 6, category: "Intercession", icon: "hands.sparkles", title: "Anyone you've meant to pray for?", subtitle: "Worth a thought right now.", cluster: "prayer-request"),
        TodayPrompt(id: 7, category: "Intercession", icon: "hands.sparkles", title: "Someone who needs encouragement?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 8, category: "Intercession", icon: "hands.sparkles", title: "Anyone you're worried about lately?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 9, category: "Intercession", icon: "hands.sparkles", title: "Who crossed your mind today?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 10, category: "Intercession", icon: "hands.sparkles", title: "Anyone you miss checking in with?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 11, category: "Intercession", icon: "hands.sparkles", title: "Someone celebrating something lately?", subtitle: "Worth a thought right now.", cluster: "gratitude"),
        TodayPrompt(id: 12, category: "Intercession", icon: "hands.sparkles", title: "Anyone who's been quiet lately?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 13, category: "Intercession", icon: "hands.sparkles", title: "Do you know of anyone walking through a hard season?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 14, category: "Intercession", icon: "hands.sparkles", title: "Anyone you've lost touch with?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 15, category: "Intercession", icon: "hands.sparkles", title: "Someone you're grateful for today?", subtitle: "Worth a thought right now.", cluster: "gratitude"),
        TodayPrompt(id: 16, category: "Intercession", icon: "hands.sparkles", title: "Anyone facing a big decision right now?", subtitle: "Worth a thought right now.", cluster: "general-reflection"),
        TodayPrompt(id: 17, category: "Intercession", icon: "hands.sparkles", title: "Who could use a kind word today?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 18, category: "Intercession", icon: "hands.sparkles", title: "Anyone you've been avoiding lately?", subtitle: "Worth a thought right now.", cluster: "conflict"),
        TodayPrompt(id: 19, category: "Intercession", icon: "hands.sparkles", title: "Someone struggling that you know of?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 20, category: "Intercession", icon: "hands.sparkles", title: "Anyone waiting on good news?", subtitle: "Worth a thought right now.", cluster: "hope"),
        TodayPrompt(id: 21, category: "Intercession", icon: "hands.sparkles", title: "Who's been carrying something heavy?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 22, category: "Intercession", icon: "hands.sparkles", title: "Anyone you haven't prayed for lately?", subtitle: "Worth a thought right now.", cluster: "prayer-request"),
        TodayPrompt(id: 23, category: "Intercession", icon: "hands.sparkles", title: "Someone new on your mind lately?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 24, category: "Intercession", icon: "hands.sparkles", title: "Anyone you feel distant from lately?", subtitle: "Worth a thought right now.", cluster: "conflict"),
        TodayPrompt(id: 25, category: "Intercession", icon: "hands.sparkles", title: "Who's been generous with you lately?", subtitle: "Worth a thought right now.", cluster: "gratitude"),
        TodayPrompt(id: 26, category: "Intercession", icon: "hands.sparkles", title: "Anyone you want to see God's hand in?", subtitle: "Worth a thought right now.", cluster: "hope"),
        TodayPrompt(id: 27, category: "Intercession", icon: "hands.sparkles", title: "Someone you've been thinking about?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 28, category: "Intercession", icon: "hands.sparkles", title: "Anyone who needs encouragement?", subtitle: "Worth a thought right now.", cluster: "connection"),
        TodayPrompt(id: 29, category: "Intercession", icon: "hands.sparkles", title: "Who's been showing up for you lately?", subtitle: "Worth a thought right now.", cluster: "gratitude")
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

    /// T-182 (overlap-avoidance): re-rolls the cached pick in place when
    /// `TodayTileOverlapResolver` finds it collides with another slot's cluster --
    /// deterministic (lowest-index non-conflicting, non-previous candidate), not
    /// random, so the same day's resolution is stable across relaunches rather than
    /// flapping between candidates on every appearance.
    static func pickAvoiding(_ excludedClusters: Set<String>, from prompts: [TodayPrompt], indexKey: String, dateKey: String, defaults: UserDefaults) -> TodayPrompt {
        guard let replacementIndex = prompts.indices.first(where: { !excludedClusters.contains(prompts[$0].cluster) }) else {
            // Every candidate conflicts (shouldn't happen with this content bank's
            // real cluster spread) -- keep the original pick rather than show nothing.
            return pick(from: prompts, indexKey: indexKey, dateKey: dateKey, defaults: defaults)
        }
        defaults.set(replacementIndex, forKey: indexKey)
        defaults.set(todayString(), forKey: dateKey)
        return prompts[replacementIndex]
    }
}

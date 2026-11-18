import Foundation

/// T-138: the Today tab's "A Word for Today" hero card, per the Aug 28 2026 locked
/// design (`docs/PILLAR_TODAY_STRATEGY.md`) -- LOCKED SCOPE is zero LLM calls for Today
/// (T-185), so this is the real MVP path, not a fallback for something else: a curated
/// library + a local, non-repeating daily pick, no contextual/LLM verse matching (that's
/// Post-MVP, T-183/T-186). Each entry carries its own reflection question rather than one
/// generic question for every verse, matching the design's "verse woven into one
/// question" -- a single shared question read as generic across 30+ unrelated verses.
struct DailyVerse: Identifiable {
    let id: Int
    let reference: String
    let quote: String
    let question: String
}

enum DailyVerseLibrary {
    static let verses: [DailyVerse] = [
        DailyVerse(id: 0, reference: "Mark 9:24 · ESV", quote: "\u{201C}Lord, I believe; help my unbelief.\u{201D}", question: "Where does belief feel easy for you right now, and where does it feel hard?"),
        DailyVerse(id: 1, reference: "Psalm 46:10 · ESV", quote: "\u{201C}Be still, and know that I am God.\u{201D}", question: "What would it take for you to actually be still today?"),
        DailyVerse(id: 2, reference: "Matthew 11:28 · ESV", quote: "\u{201C}Come to me, all who labor and are heavy laden, and I will give you rest.\u{201D}", question: "What are you carrying right now that you haven't set down?"),
        DailyVerse(id: 3, reference: "Isaiah 41:10 · ESV", quote: "\u{201C}Fear not, for I am with you; be not dismayed, for I am your God.\u{201D}", question: "What's the fear you'd name out loud if you knew you wouldn't be judged for it?"),
        DailyVerse(id: 4, reference: "Philippians 4:6-7 · ESV", quote: "\u{201C}Do not be anxious about anything, but in everything by prayer and supplication... let your requests be made known to God.\u{201D}", question: "What's the thing you've been anxious about but haven't actually said out loud?"),
        DailyVerse(id: 5, reference: "Lamentations 3:22-23 · ESV", quote: "\u{201C}The steadfast love of the Lord never ceases... they are new every morning.\u{201D}", question: "What would it look like to treat today as genuinely new, not a continuation of yesterday?"),
        DailyVerse(id: 6, reference: "Romans 8:28 · ESV", quote: "\u{201C}And we know that for those who love God all things work together for good.\u{201D}", question: "Is there something in your life right now you can't yet see the good in?"),
        DailyVerse(id: 7, reference: "Psalm 34:18 · ESV", quote: "\u{201C}The Lord is near to the brokenhearted and saves the crushed in spirit.\u{201D}", question: "Where is your heart actually at today, underneath how you're presenting it?"),
        DailyVerse(id: 8, reference: "Joshua 1:9 · ESV", quote: "\u{201C}Be strong and courageous... for the Lord your God is with you wherever you go.\u{201D}", question: "What's the thing that would take courage for you to do or say this week?"),
        DailyVerse(id: 9, reference: "2 Corinthians 12:9 · ESV", quote: "\u{201C}My grace is sufficient for you, for my power is made perfect in weakness.\u{201D}", question: "Where do you feel weakest right now, and what if that's not disqualifying?"),
        DailyVerse(id: 10, reference: "Psalm 139:23-24 · ESV", quote: "\u{201C}Search me, O God, and know my heart... see if there be any grievous way in me.\u{201D}", question: "If you let yourself be fully searched right now, what would be found?"),
        DailyVerse(id: 11, reference: "John 14:27 · ESV", quote: "\u{201C}Peace I leave with you; my peace I give to you... let not your hearts be troubled.\u{201D}", question: "What's troubling your heart today that peace hasn't reached yet?"),
        DailyVerse(id: 12, reference: "Proverbs 3:5-6 · ESV", quote: "\u{201C}Trust in the Lord with all your heart, and do not lean on your own understanding.\u{201D}", question: "Where are you leaning on your own understanding instead of trusting right now?"),
        DailyVerse(id: 13, reference: "Psalm 23:4 · ESV", quote: "\u{201C}Even though I walk through the valley of the shadow of death, I will fear no evil, for you are with me.\u{201D}", question: "What valley are you walking through right now, even a quiet one?"),
        DailyVerse(id: 14, reference: "Galatians 6:9 · ESV", quote: "\u{201C}And let us not grow weary of doing good, for in due season we will reap, if we do not give up.\u{201D}", question: "What's the thing you're tempted to give up on right now?"),
        DailyVerse(id: 15, reference: "1 Peter 5:7 · ESV", quote: "\u{201C}Casting all your anxieties on him, because he cares for you.\u{201D}", question: "What would it feel like to actually hand something over instead of carrying it alone?"),
        DailyVerse(id: 16, reference: "Psalm 139:14 · ESV", quote: "\u{201C}I praise you, for I am fearfully and wonderfully made.\u{201D}", question: "What's a part of yourself you've struggled to see as good?"),
        DailyVerse(id: 17, reference: "Matthew 6:34 · ESV", quote: "\u{201C}Therefore do not be anxious about tomorrow, for tomorrow will be anxious for itself.\u{201D}", question: "What piece of tomorrow are you trying to carry today?"),
        DailyVerse(id: 18, reference: "Romans 15:13 · ESV", quote: "\u{201C}May the God of hope fill you with all joy and peace in believing.\u{201D}", question: "Where do you need hope refilled right now?"),
        DailyVerse(id: 19, reference: "Psalm 16:11 · ESV", quote: "\u{201C}You make known to me the path of life; in your presence there is fullness of joy.\u{201D}", question: "When did you last feel genuinely full of joy, and what made that true?"),
        DailyVerse(id: 20, reference: "James 1:2-3 · ESV", quote: "\u{201C}Count it all joy... for you know that the testing of your faith produces steadfastness.\u{201D}", question: "What trial are you in the middle of, and what is it actually producing in you?"),
        DailyVerse(id: 21, reference: "Psalm 62:1 · ESV", quote: "\u{201C}For God alone my soul waits in silence; from him comes my salvation.\u{201D}", question: "What are you waiting on right now, and how is the waiting itself going?"),
        DailyVerse(id: 22, reference: "Colossians 3:15 · ESV", quote: "\u{201C}Let the peace of Christ rule in your hearts... and be thankful.\u{201D}", question: "What's one thing today you're genuinely thankful for, even a small one?"),
        DailyVerse(id: 23, reference: "Isaiah 40:31 · ESV", quote: "\u{201C}They who wait for the Lord shall renew their strength... they shall run and not be weary.\u{201D}", question: "Where do you feel most depleted right now?"),
        DailyVerse(id: 24, reference: "Psalm 73:26 · ESV", quote: "\u{201C}My flesh and my heart may fail, but God is the strength of my heart.\u{201D}", question: "Where do you feel like you're running on empty today?"),
        DailyVerse(id: 25, reference: "John 15:5 · ESV", quote: "\u{201C}I am the vine; you are the branches... apart from me you can do nothing.\u{201D}", question: "What are you trying to do right now entirely under your own strength?"),
        DailyVerse(id: 26, reference: "Psalm 51:10 · ESV", quote: "\u{201C}Create in me a clean heart, O God, and renew a right spirit within me.\u{201D}", question: "Is there something you need to be honest with yourself about today?"),
        DailyVerse(id: 27, reference: "Hebrews 11:1 · ESV", quote: "\u{201C}Now faith is the assurance of things hoped for, the conviction of things not seen.\u{201D}", question: "What are you hoping for that you haven't seen any evidence of yet?"),
        DailyVerse(id: 28, reference: "Psalm 27:1 · ESV", quote: "\u{201C}The Lord is my light and my salvation; whom shall I fear?\u{201D}", question: "What's the one fear that, if you named it, would lose some of its grip?"),
        DailyVerse(id: 29, reference: "Ecclesiastes 3:1 · ESV", quote: "\u{201C}For everything there is a season, and a time for every matter under heaven.\u{201D}", question: "What season do you feel like you're actually in right now?")
    ]

    private static let indexKey = "dailyVerse.index"
    private static let dateKey = "dailyVerse.dateString"

    /// "Today" follows the user's own local device calendar day (same approach T-184
    /// names for Today-tab content generally) -- a plain "yyyy-MM-dd" string in the
    /// device's current calendar/timezone, so the verse only changes once per real day
    /// for this user, not on UTC's clock.
    private static func todayString(calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    /// Returns today's verse, picking a new one (never repeating yesterday's, as long as
    /// the library has more than one entry) the first time this is called on a given
    /// calendar day and caching that pick in `UserDefaults` for every call after --
    /// T-138's own "24h cache check logic," done as a day-boundary check rather than a
    /// literal rolling 24h timer so it can't land mid-conversation for someone who opened
    /// the app right at the boundary.
    static func verseForToday(defaults: UserDefaults = .standard) -> DailyVerse {
        let today = todayString()
        if defaults.string(forKey: dateKey) == today {
            let cachedIndex = defaults.integer(forKey: indexKey)
            if verses.indices.contains(cachedIndex) {
                return verses[cachedIndex]
            }
        }

        let previousIndex = defaults.integer(forKey: indexKey)
        var candidates = Array(verses.indices)
        if verses.count > 1 {
            candidates.removeAll { $0 == previousIndex }
        }
        let newIndex = candidates.randomElement() ?? 0

        defaults.set(newIndex, forKey: indexKey)
        defaults.set(today, forKey: dateKey)
        return verses[newIndex]
    }
}

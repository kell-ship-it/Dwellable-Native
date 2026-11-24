// Run: xcrun swiftc Dwelly/Managers/JournalExcerpt.swift Scripts/journal_excerpt_test/main.swift -o /tmp/je_t && /tmp/je_t
import Foundation
var fails = 0, passes = 0
func check(_ ok: Bool, _ name: String) { if ok { passes += 1 } else { fails += 1; print("FAIL: \(name)") } }

// Short text is untouched apart from whitespace collapsing
check(JournalExcerpt.make(from: "I feel tired.") == "I feel tired.", "short text unchanged")
check(JournalExcerpt.make(from: "one\n\ntwo\n\nthree") == "one two three", "paragraph breaks between messages collapse to spaces")
check(JournalExcerpt.make(from: "  padded   text  ") == "padded text", "outer/extra spaces collapsed")
check(JournalExcerpt.make(from: "") == "", "empty")

// The exact text seen live: it was cut mid-word ("...really am not s")
let live = "Something has felt off for a few weeks but I cannot put my finger on it.\n\nI do not know, honestly.\n\nMaybe I am just tired. I really am not sure."
let e = JournalExcerpt.make(from: live)
check(e.hasSuffix("…"), "long text ends with an ellipsis")
let body = e.dropLast()
check(live.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ").hasPrefix(String(body)), "excerpt is a true prefix of the collapsed text")
let words = Set(live.split(whereSeparator: { $0.isWhitespace }).map { String($0) })
check(body.split(separator: " ").allSatisfy { words.contains(String($0)) }, "every word in the excerpt is a WHOLE word from the original (never cut in half)")
check(e.count <= JournalExcerpt.limit + 1, "within the limit (plus the ellipsis)")

// Exactly at the boundary: 140 stays whole, 141 is shortened
let w140 = String(repeating: "ab ", count: 46) + "ab" // 140 chars
check(w140.count == 140 && JournalExcerpt.make(from: w140) == w140, "exactly 140 characters is NOT shortened")
check(JournalExcerpt.make(from: w140 + "x").hasSuffix("…"), "141 characters is shortened")

// No spaces at all (Chinese/Japanese, or one long word) cuts at the limit with an ellipsis, never loses the start
let cjk = String(repeating: "疲", count: 200)
let c = JournalExcerpt.make(from: cjk)
check(c == String(repeating: "疲", count: 140) + "…", "no-space text is cut at the limit")
// Emoji/ZWJ graphemes counted as one character
let fam = String(repeating: "👨‍👩‍👧", count: 150)
check(JournalExcerpt.make(from: fam) == String(repeating: "👨‍👩‍👧", count: 140) + "…", "grapheme clusters are not split")
// A long word right at the edge: prefers the earlier whole word
let edge = String(repeating: "a", count: 10) + " " + String(repeating: "b", count: 300)
let eg = JournalExcerpt.make(from: edge)
check(eg.hasSuffix("…"), "very long word still ends with an ellipsis")

print(fails == 0 ? "ALL PASS (\(passes))" : "\(fails) FAILED, \(passes) passed")
exit(fails == 0 ? 0 : 1)

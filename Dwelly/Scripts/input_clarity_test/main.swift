import Foundation
var fails = 0, passes = 0
func check(_ ok: Bool, _ name: String) { if ok { passes += 1 } else { fails += 1; print("FAIL: \(name)") } }
let ok = InputClarity.Verdict.ok

// Empty / invisible
check(InputClarity.check("") == .empty, "empty")
check(InputClarity.check("   \n\t ") == .empty, "whitespace")
check(InputClarity.check("\u{200B}\u{200D}\u{FEFF}\u{2060}") == .empty, "zero-width only")
check(InputClarity.check(" \u{200B} \n") == .empty, "mixed invisible")
check(InputClarity.check("\u{FE0F}") == .empty, "lone variation selector")
check(InputClarity.emptyPrompt == "What happened that you’d like to capture?", "empty copy")

// Mechanical repeats at/around the 100 boundary
check(InputClarity.check(String(repeating: "a", count: 100)) == .mechanicalRepeat, "100 x a")
check(InputClarity.check(String(repeating: "a", count: 99)) == ok, "99 x a passes (just below)")
check(InputClarity.check(String(repeating: "ha", count: 50)) == .mechanicalRepeat, "ha x50")
check(InputClarity.check(String(repeating: "asdf", count: 25)) == .mechanicalRepeat, "asdf x25")
check(InputClarity.check(String(repeating: "asdf", count: 25) + "as") == .mechanicalRepeat, "partial tail still periodic")
check(InputClarity.check(String(repeating: "😂", count: 100)) == .mechanicalRepeat, "100 emoji (graphemes)")
check(InputClarity.check(String(repeating: "😂", count: 99)) == ok, "99 emoji passes")
check(InputClarity.check(String(repeating: "👨‍👩‍👧", count: 100)) == .mechanicalRepeat, "ZWJ family counts as ONE grapheme")
check(InputClarity.check(String(repeating: "👨‍👩‍👧", count: 40)) == ok, "40 family emoji = 40 graphemes passes")
check(InputClarity.check(String(repeating: "あ", count: 120)) == .mechanicalRepeat, "kana repeat")
check(InputClarity.check(String(repeating: "abcde", count: 30)) == ok, "period 5 is out of scope (deferred)")

// Auto-capitalized first letter (seen live in the simulator: typing 120 a's gave "Aaaa...")
check(InputClarity.check("A" + String(repeating: "a", count: 119)) == .mechanicalRepeat, "auto-capitalized mash is still mechanical")
check(InputClarity.check("Ha" + String(repeating: "ha", count: 49)) == .mechanicalRepeat, "Haha... mixed case")
check(InputClarity.check("A" + String(repeating: "a", count: 98)) == ok, "99 chars with capital still below threshold")

// Meaningful content must pass
check(InputClarity.check("ok") == ok, "short")
check(InputClarity.check("no no no no no") == ok, "short emphasis")
check(InputClarity.check("😭") == ok, "single emoji")
check(InputClarity.check("😭😭😭") == ok, "few emoji")
check(InputClarity.check("lol idk") == ok, "slang")
check(InputClarity.check("Estoy cansado y no sé qué hacer") == ok, "Spanish")
check(InputClarity.check("我今天很累") == ok, "Chinese")
check(InputClarity.check("אני מרגיש לבד") == ok, "Hebrew")
check(InputClarity.check("I hurt I hurt I hurt") == ok, "meaningful repetition")
let mixed = String(repeating: "a", count: 150) + " I miss my mom"
check(InputClarity.check(mixed) == ok, "substring repeat inside real content passes")
let para = "I was so angry at work today and I do not know why. "
check(InputClarity.check(para + para + para) == ok, "repeated paragraph passes (deferred)")
check(InputClarity.check("a" + String(repeating: "b", count: 120)) == ok, "one odd char breaks the pattern")

// Prepared copy + original preserved
check(InputClarity.clarification(for: .ok) == nil, "no clarification for ok")
check(InputClarity.clarification(for: .mechanicalRepeat) == "Could you describe what happened in a few words?", "repeat copy")
// Judged exactly as submitted, never silently trimmed: padding breaks the exact pattern.
check(InputClarity.check("  " + String(repeating: "a", count: 100) + "  ") == ok, "padded run judged as submitted")
check(InputClarity.check(String(repeating: "a", count: 100) + "\n") == ok, "trailing newline breaks exact pattern")

print(fails == 0 ? "ALL PASS (\(passes))" : "\(fails) FAILED, \(passes) passed")
exit(fails == 0 ? 0 : 1)

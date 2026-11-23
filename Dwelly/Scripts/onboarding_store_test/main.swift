// Run: xcrun swiftc Dwelly/Managers/OnboardingCaptureStore.swift Scripts/onboarding_store_test/main.swift -o /tmp/os_t && /tmp/os_t
import Foundation
var fails = 0, passes = 0
func check(_ ok: Bool, _ name: String) { if ok { passes += 1 } else { fails += 1; print("FAIL: \(name)") } }

let suite = "dwelly.test.onboardingstore.\(UUID().uuidString)"
let d = UserDefaults(suiteName: suite)!
defer { d.removePersistentDomain(forName: suite) }

let snap = OnboardingCaptureSnapshot(
    captureId: "cap-AAAA-1111",
    turns: [.init(isUser: true, text: "I feel distant"), .init(isUser: false, text: "Tell me more?")],
    openedWithPromptQuestion: false,
    safetyClarifyExtraTurn: true,
    tiers: ["normal", "crisis_self"]
)

check(OnboardingCaptureStore.load(userId: "u1", defaults: d) == nil, "nothing saved -> nil")
OnboardingCaptureStore.save(snap, userId: "u1", defaults: d)
check(OnboardingCaptureStore.load(userId: "u1", defaults: d) == snap, "round trip keeps everything")
check(OnboardingCaptureStore.load(userId: "u1", defaults: d)?.tiers == ["normal", "crisis_self"], "the SAFETY record survives a restore (a latched conversation stays latched)")
check(OnboardingCaptureStore.load(userId: "u1", defaults: d)?.captureId == "cap-AAAA-1111", "same capture id -> server ledger keeps counting the same allowance")
check(OnboardingCaptureStore.load(userId: "u2", defaults: d) == nil, "another account never sees it (sign-out/in as someone else)")
check(OnboardingCaptureStore.load(userId: "u1", defaults: d)?.safetyClarifyExtraTurn == true, "extra-turn flag survives")

OnboardingCaptureStore.clear(userId: "u1", defaults: d)
check(OnboardingCaptureStore.load(userId: "u1", defaults: d) == nil, "cleared on completion")

// Corrupt / empty data never crashes or resumes garbage
d.set(Data("not json".utf8), forKey: OnboardingCaptureStore.key(userId: "u3"))
check(OnboardingCaptureStore.load(userId: "u3", defaults: d) == nil, "corrupt data -> nil")
OnboardingCaptureStore.save(.init(captureId: "cap-x", turns: [], openedWithPromptQuestion: false, safetyClarifyExtraTurn: false, tiers: []), userId: "u4", defaults: d)
check(OnboardingCaptureStore.load(userId: "u4", defaults: d) == nil, "no turns -> nothing to resume")

// Resume: answered conversation comes back as-is
let answered = OnboardingCaptureStore.resume(snap)
check(answered.turns.count == 2 && answered.composerText == "", "answered conversation resumes unchanged")
// Resume: the person's last message had no reply yet -> text goes back to the composer, no auto-resend
let dangling = OnboardingCaptureSnapshot(captureId: "cap-y", turns: [.init(isUser: true, text: "one"), .init(isUser: false, text: "reply"), .init(isUser: true, text: "typed but unanswered")], openedWithPromptQuestion: false, safetyClarifyExtraTurn: false, tiers: ["normal"])
let r = OnboardingCaptureStore.resume(dangling)
check(r.turns.count == 2 && r.turns.last?.isUser == false, "unanswered last message is removed from the thread")
check(r.composerText == "typed but unanswered", "...and put back in the composer, not lost")

print(fails == 0 ? "ALL PASS (\(passes))" : "\(fails) FAILED, \(passes) passed")
exit(fails == 0 ? 0 : 1)

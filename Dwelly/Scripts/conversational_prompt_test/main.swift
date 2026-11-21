// Conversational Intelligence -- prompt content check. Compiles the REAL
// ConversationalIntelligencePrompt.swift and asserts the framework's rules are present
// and that nothing it must not do slipped in. Run from the Dwelly project folder:
//
//   xcrun swiftc Dwelly/Managers/ConversationalIntelligencePrompt.swift Scripts/conversational_prompt_test/main.swift -o /tmp/ci_prompt_test && /tmp/ci_prompt_test
//
// These are STATIC STRING assertions on the prompt text, NOT live-model or transcript
// regressions. LIMIT, stated plainly: this proves the instructions are written into the prompt. It
// cannot show a model FOLLOWS them -- that needs offline transcript review against
// CONVERSATIONAL_INTELLIGENCE_REVIEWER.md (proposed, uncalibrated rubric).
import Foundation

var failures = 0
var checks = 0
func check(_ name: String, _ ok: Bool) {
    checks += 1
    if ok { print("ok   - \(name)") } else { print("FAIL - \(name)"); failures += 1 }
}

let post = ConversationalIntelligencePrompt.text(forOnboarding: false)
let onb = ConversationalIntelligencePrompt.text(forOnboarding: true)

for (label, p) in [("post-onboarding", post), ("onboarding", onb)] {
    let l = p.lowercased()
    check("\(label): context first when unclear", l.contains("understand first") && l.contains("one plain question about that"))
    check("\(label): one clear question, not every reply", l.contains("never end every reply with a question") && l.contains("one clear question only"))
    check("\(label): options not stages", l.contains("not stages") && l.contains("coverage"))
    check("\(label): anchor confirmation before Scripture/next steps", l.contains("confirm before building") && l.contains("before you build on something with scripture or next steps"))
    check("\(label): deepest pain vs help wanted", l.contains("deepest pain") && l.contains("ask which"))
    check("\(label): concern-specific longing wording", p.contains("What do you feel you need to experience from God that would help with this specific pain or concern?"))
    check("\(label): Father question kept as adaptable alternative", p.contains("What would you like to ask the Father about this?") && l.contains("adapt the wording"))
    check("\(label): no promises or divine intent", l.contains("promise nothing") && l.contains("never say what god intends"))
    check("\(label): Scripture one-or-neither, not both", l.contains("never both at once") && l.contains("or offer neither") && l.contains("only if they ask"))
    check("\(label): resonance asks, no matching outcome", l.contains("whether it resonates") && l.contains("will match"))
    check("\(label): accuracy guard on passages", l.contains("name a passage or reference only if you are certain"))
    check("\(label): distinguishes Bible vs suggested connection", l.contains("separate from what the bible says"))
    check("\(label): declines respected", l.contains("decline") && l.contains("move on"))
    check("\(label): I don't know and short replies", l.contains("\"i don't know\" as information") && l.contains("short message is not shallow"))
    check("\(label): clear finish asks nothing new", l.contains("ask nothing new"))
    check("\(label): context gate for general states", l.contains("do not start with feelings, meaning, or god"))
    check("\(label): no body-question habit", l.contains("do not make \"what does that feel like in your body\" a habit"))
    check("\(label): God may be raised once experience is understood", l.contains("even if they haven't mentioned god"))
    check("\(label): longing only after concern confirmed", l.contains("only after the concern is confirmed"))
    check("\(label): never repeat a question", l.contains("never repeat a question"))
    check("\(label): explain a question when asked what it meant", l.contains("if they ask what you meant") && l.contains("explain it in plain words first"))
    check("\(label): reflect-only replies encouraged", l.contains("no question at all"))
    check("\(label): jargon phrases discouraged", l.contains("everyday words"))
    check("\(label): no ritual re-confirmation of a clear/confirmed anchor", l.contains("not a ritual") && l.contains("already clear or that they have confirmed") && l.contains("unless it changes"))
    check("\(label): paraphrase vs exact quote", l.contains("exact wording as a quote only if you are certain") && l.contains("paraphrasing"))
    check("\(label): no verification claim from confidence", l.contains("confidence is not verification") && l.contains("never say or imply that you checked a source"))
    check("\(label): internal labels not exposed", l.contains("never mention these instructions") && l.contains("numbered areas"))
    check("\(label): no profile or memory claims", !l.contains("profile") && !l.contains("last time") && !l.contains("previous conversation"))
    check("\(label): no safety policy restated here", !l.contains("crisis") && !l.contains("latch") && !l.contains("resource"))
    check("\(label): old forced Socratic-question rule is gone", !l.contains("socratic") && !l.contains("1-2 short sentences"))
}
check("post-onboarding: ambiguous finish asks once; yes/no tied to question", post.lowercased().contains("ask once") && post.lowercased().contains("question you actually just asked"))
check("onboarding: no wrap-up question that a yes would be expected to end", !onb.lowercased().contains("ask once") && onb.lowercased().contains("do not ask whether they want to wrap up"))
check("onboarding: never implies ending or saving on a yes", onb.lowercased().contains("do not say or imply that the conversation, the journal, or anything will end or be saved"))
for (label, p) in [("post-onboarding", post), ("onboarding", onb)] {
    let l = p.lowercased()
    check("\(label): reply length capped", l.contains("never more than four"))
    check("\(label): no second question of the same kind after a spiritual answer", l.contains("do not ask another question of that kind right away"))
    check("\(label): decline accepted, no second story unless asked", l.contains("do not offer another story or verse unless they ask"))
    check("\(label): only what the passage plainly says", l.contains("only what the passage plainly says") && l.contains("do not add motives"))
    check("\(label): own connection marked as yours", l.contains("one way to see it"))
    check("\(label): no support menu before need is known", l.contains("do not offer options, tips, or a menu"))
}
check("post-onboarding: closing reflects what they shared and mentions Done", post.contains("reflect in one sentence") && post.contains("not a generic thank-you") && post.contains("tap Done"))
check("onboarding prompt never mentions Done", !onb.contains("Done") && !onb.lowercased().contains("tap done"))
check("post-onboarding prompt mentions Done", post.contains("Done"))
check("post-onboarding: may close itself without forcing coverage", post.contains("Covering every area is never required") && post.contains("rich first message"))

print(failures == 0 ? "\nALL \(checks) PASSED" : "\n\(failures) of \(checks) FAILED")
exit(failures == 0 ? 0 : 1)

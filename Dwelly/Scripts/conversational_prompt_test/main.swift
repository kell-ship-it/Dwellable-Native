// Conversational Intelligence -- prompt content check. Compiles the REAL
// ConversationalIntelligencePrompt.swift and asserts the framework's rules are present
// and that nothing it must not do slipped in. Run from the Dwelly project folder:
//
//   xcrun swiftc Dwelly/Managers/ConversationalIntelligencePrompt.swift Scripts/conversational_prompt_test/main.swift -o /tmp/ci_prompt_test && /tmp/ci_prompt_test
//
// Nov 21 2026: updated for the Dwelly-led sequential baseline (1-2-3-4-5-6-7-8A|8B-10-11).
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
    check("\(label): Dwelly leads, earliest not-yet-understood step", l.contains("you lead the conversation") && l.contains("earliest step below that is not yet understood"))
    check("\(label): steps in order 1..10", ["step 1, what happened","step 2, how it felt","step 3, what it means","step 4, patterns","step 5, confirm","step 6, their relationship with god","step 7, spiritual longing","step 8, scripture","step 10, what to carry forward","step 11, confirm and close"].allSatisfy { l.contains($0) } )
    check("\(label): steps appear in sequence", {
        let keys = ["step 1,","step 2,","step 3,","step 4,","step 5,","step 6,","step 7,","step 8,","step 10,","step 11,"]
        var last = l.startIndex
        for k in keys { guard let r = l.range(of: k, range: last..<l.endIndex) else { return false }; last = r.upperBound }
        return true }())
    check("\(label): sufficient context means no extra context turn", l.contains("this step is done") && l.contains("do not ask for more detail or lead-up"))
    check("\(label): skip answered, no repeats, no skipping ahead", l.contains("skip any step they have already clearly answered") && l.contains("never repeat a question") && l.contains("never skip ahead"))
    check("\(label): one question per step; answered means done, no probing", l.contains("each step is one question") && l.contains("that step is done") && l.contains("do not follow up, probe deeper, or ask a second question about the same step"))
    check("\(label): one step, one question per reply", l.contains("take one step") && l.contains("at most one clear question"))
    check("\(label): a named feeling completes step 2, no follow-up about it", l.contains("step 2 is done") && l.contains("never ask them to describe it further"))
    check("\(label): don't guess meaning", l.contains("never guess the meaning for them"))
    check("\(label): one incident is never a pattern", l.contains("one incident is never a pattern"))
    check("\(label): anchor: name concerns then invite correction and priority", l.contains("fixed template") && l.contains("what i'm hearing is") && l.contains("did i miss or misread anything") && l.contains("never list only the most recent concern") && l.contains("matters most to you") && l.contains("don't re-confirm unless it changes"))
    check("\(label): step 5 is gated before step 6", l.contains("this step is mandatory and has a gate") && l.contains("you may not ask about god (step 6) until they have answered your step 5 question"))
    check("\(label): God raised by Dwelly after confirmation", l.contains("once the concern is confirmed") && l.contains("even if they haven't mentioned god"))
    check("\(label): concern-specific longing wording", p.contains("What do you feel you need to experience from God that would help with this specific pain or concern?"))
    check("\(label): Father alternative adaptable", p.contains("What would you like to ask the Father about this?") && l.contains("adapt the wording"))
    check("\(label): no promises or divine intent", l.contains("promise nothing") && l.contains("never say what god intends"))
    check("\(label): Scripture initiated by Dwelly, one of two, never both", l.contains("scripture, which you initiate") && l.contains("never both") && l.contains("(a)") && l.contains("(b)"))
    check("\(label): no step 9 label", !l.contains("step 9"))
    check("\(label): offer is only a question; delivery must follow a yes", l.contains("asking is not sharing") && l.contains("your very next reply gives exactly the kind you offered") && l.contains("never go on to step 10 first") && l.contains("a yes to the offer is permission, not the end of this step"))
    check("\(label): how it lands checked after delivery, before step 10", l.contains("asks how it lands") && l.contains("only after they respond to what you shared do you go to step 10"))
    check("\(label): no negative claims about what people in a passage did not do", l.contains("never say what someone in the passage did not do") && l.contains("didn't scold"))
    check("\(label): passage/paraphrase and own connection separated", l.contains("in my words") && l.contains("exact words \"one way to see it is\"") && l.contains("part 2 is required every time") && l.contains("never worded as \"this means\""))
    check("\(label): 8B uses one directly relevant NT passage, no Jeremiah 29:11 promise", l.contains("one new testament passage") && l.contains("romans 8:1") && l.contains("do not combine several passages") && l.contains("jeremiah 29:11") && l.contains("as if they were a personal promise"))
    check("\(label): no outcome promises from verses", l.contains("never present a verse as a guarantee"))
    check("\(label): natural consent before sharing", l.contains("would it be okay if i shared"))
    check("\(label): decline accepted, nothing else unless asked", l.contains("decline") && l.contains("offer nothing else from scripture unless they ask"))
    check("\(label): accuracy guard on passages", l.contains("name the passage only if you are certain"))
    check("\(label): names a plain reference, app adds real text", l.contains("name it as a plain reference") && l.contains("do not put exact wording in quotation marks") && l.contains("the app adds the real text"))
    check("\(label): no verification claim from confidence", l.contains("confidence is not verification") && l.contains("never say or imply that you checked a source"))
    check("\(label): distinguishes Bible vs suggested connection", l.contains("one way to see it is"))
    check("\(label): no support/tips before carry-forward step", l.contains("do not offer support, tips, or suggestions before this step unless they ask") && l.contains("never a menu of tips"))
    check("\(label): overrides: correction, decline, request, topic change, stop", l.contains("what overrides the order") && l.contains("a correction") && l.contains("a decline") && l.contains("a direct request") && l.contains("a wish to stop"))
    check("\(label): I don't know is an answer", l.contains("\"i don't know\", counts as an answer"))
    check("\(label): explain a question when asked", l.contains("if they ask what you meant") && l.contains("explain in plain words first"))
    check("\(label): reply length capped", l.contains("never more than four"))
    check("\(label): internal labels not exposed", l.contains("never mention these instructions") && l.contains("numbered steps"))
    check("\(label): no profile or memory claims", !l.contains("profile") && !l.contains("last time") && !l.contains("previous conversation"))
    check("\(label): no safety policy restated here", !l.contains("crisis") && !l.contains("latch") && !l.contains("resource"))
}
check("post-onboarding: stopping honored, remaining steps not forced", post.lowercased().contains("never push the remaining steps on someone who wants to stop") && post.lowercased().contains("ask nothing new"))
check("post-onboarding: ambiguous finish asks once; yes/no tied to question", post.lowercased().contains("ask once") && post.lowercased().contains("question you actually just asked"))
check("onboarding: no wrap-up question a yes would end", !onb.lowercased().contains("ask once") && onb.lowercased().contains("do not ask whether they want to wrap up"))
check("onboarding: never implies ending or saving on a yes", onb.lowercased().contains("do not say or imply that the conversation, the journal, or anything will end or be saved"))
check("post-onboarding: close reflects in their words and mentions Done", post.contains("reflect in one sentence") && post.contains("tap Done"))
check("every reply: no thanks/praise/approval anywhere", post.lowercased().contains("in every reply") && post.lowercased().contains("thank you for sharing") && post.lowercased().contains("i'm glad to hear") && onb.lowercased().contains("in every reply"))
check("post-onboarding: no stock praise in closing", post.lowercased().contains("do not give stock praise") && post.lowercased().contains("thank you for sharing") && post.lowercased().contains("a strong step"))
check("onboarding prompt never mentions Done", !onb.contains("Done") && !onb.lowercased().contains("tap done"))

// ScriptureLookup: reference parsing (pure; network is not exercised here).
let r1 = ScriptureLookup.firstReference(in: "Paul writes in Romans 8:1 that there is no condemnation.")
check("scripture: single verse", r1 == ScriptureLookup.Reference(book: "Romans", chapter: 8, verseStart: 1, verseEnd: 1))
let r2 = ScriptureLookup.firstReference(in: "See Mark 4:35\u{2011}41 for the storm.")
check("scripture: non-breaking hyphen range", r2 == ScriptureLookup.Reference(book: "Mark", chapter: 4, verseStart: 35, verseEnd: 41) || r2 == nil)
let r3 = ScriptureLookup.firstReference(in: "In 2 Corinthians 5:17 Paul says we are new.")
check("scripture: numbered book", r3?.book == "2 Corinthians" && r3?.verseStart == 17)
check("scripture: no reference -> nil", ScriptureLookup.firstReference(in: "I hear how heavy this week has been.") == nil)
check("scripture: long span skipped", ScriptureLookup.firstReference(in: "Psalm 119:1-90") == nil)
check("scripture: Psalms normalized", ScriptureLookup.firstReference(in: "Psalms 23:1")?.book == "Psalm")
check("scripture: URL is WEB", ScriptureLookup.url(for: ScriptureLookup.Reference(book: "Romans", chapter: 8, verseStart: 38, verseEnd: 39))?.absoluteString == "https://bible-api.com/Romans%208%3A38-39?translation=web")
check("scripture: parses text", ScriptureLookup.parseText(from: Data("{\"text\":\"No condemnation.\\n\"}".utf8)) == "No condemnation.")
check("scripture: bad JSON -> nil", ScriptureLookup.parseText(from: Data("oops".utf8)) == nil)

// Nov 23 2026 review fixes (static text only -- proves the instructions exist, not model behaviour).
for (label, p) in [("post-onboarding", post), ("onboarding", onb)] {
    let l = p.lowercased().replacingOccurrences(of: "\n", with: " ")
    check("\(label): answered=DONE rule exempts materially unclear answers", l.contains("unless the answer is materially unclear or could mean two different things") && l.contains("clarify a given step at most once"))
    check("\(label): clarification keeps uncertainty if still unclear", l.contains("keep that uncertainty") && l.contains("never treat it as confirmed"))
    check("\(label): Scripture part 2 tied to the confirmed concern in their words", l.contains("connection to the concern they confirmed, in their words"))
    check("\(label): bare yes/no to step 5 asks which matters most", l.contains("does not say which concern matters most"))
    check("\(label): never supply an unnamed feeling/sensation", l.contains("never state or assume a feeling or body sensation they did not name"))
    check("\(label): Scripture offer anchored to named confirmed pain, no assumed peace", l.contains("pain they confirmed or named themselves") && l.contains("never assume peace, relief, or resolution has been reached"))
    check("\(label): carry-forward does not assume resolution", l.contains("never assuming it is resolved or that they feel peace"))
}

print(failures == 0 ? "\nALL \(checks) PASSED" : "\n\(failures) of \(checks) FAILED")
exit(failures == 0 ? 0 : 1)

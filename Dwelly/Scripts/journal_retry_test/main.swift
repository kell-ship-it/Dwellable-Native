// Behavioural test for JournalRetryApplier (the retry sweep's persistence rules).
// Compiles the REAL JournalEntry and JournalRetryApplier (the code SyncManager calls). Run from Dwelly/:
//   xcrun swiftc Dwelly/Models/JournalEntry.swift Dwelly/Managers/JournalRetryApplier.swift Scripts/journal_retry_test/main.swift -o /tmp/jr_test && /tmp/jr_test
import Foundation

var failures = 0
func check(_ n: String, _ ok: Bool) { print(ok ? "ok   - \(n)" : "FAIL - \(n)"); if !ok { failures += 1 } }
struct Boom: Error {}

func result(eligible: Bool, facts: String?) -> JournalRetryApplier.Decision {
    .init(title: "T", body: "B", moods: ["hopeful"], scriptureQuote: nil, scriptureReference: "Romans 8:1",
          formationEligible: eligible, extractedFacts: facts)
}
func pending(eligible: Bool = false, facts: String? = nil) -> JournalEntry {
    JournalEntry(id: "e1", momentId: "m1", userId: "u", status: "pending", title: "", body: "",
                 formationEligible: eligible, extractedFacts: facts)
}

func run() async {
    // 1. refreshed eligibility + facts are persisted and feed the profile
    var saved: JournalEntry?; var fed: [String] = []
    var u = JournalRetryApplier.applying(result(eligible: true, facts: "worried about work"), to: pending())
    var ok = await JournalRetryApplier.persist(u, save: { saved = $0; return $0 }, feedProfile: { fed.append($0) })
    check("save succeeds", ok)
    check("persisted entry is approved with refreshed formationEligible", saved?.status == "approved" && saved?.formationEligible == true)
    check("persisted entry carries refreshed extractedFacts", saved?.extractedFacts == "worried about work")
    check("profile fed once with the facts", fed == ["worried about work"])

    // 2. save failure: no profile update, nothing reported saved (entry on server stays pending)
    fed = []
    u = JournalRetryApplier.applying(result(eligible: true, facts: "x"), to: pending())
    ok = await JournalRetryApplier.persist(u, save: { _ in throw Boom() }, feedProfile: { fed.append($0) })
    check("save failure returns false", !ok)
    check("save failure does NOT update the profile", fed.isEmpty)
    check("original pending entry value is untouched (retryable)", pending().status == "pending")

    // 3. nil facts clear stale facts; ineligible never feeds
    saved = nil; fed = []
    u = JournalRetryApplier.applying(result(eligible: false, facts: nil), to: pending(eligible: true, facts: "STALE"))
    ok = await JournalRetryApplier.persist(u, save: { saved = $0; return $0 }, feedProfile: { fed.append($0) })
    check("nil facts clear stale extractedFacts", saved?.extractedFacts == nil)
    check("ineligible result persists formationEligible=false", saved?.formationEligible == false)
    check("ineligible / nil facts does not feed profile", ok && fed.isEmpty)

    // 4. eligible but nil facts: persisted, no profile feed
    fed = []
    u = JournalRetryApplier.applying(result(eligible: true, facts: nil), to: pending())
    _ = await JournalRetryApplier.persist(u, save: { $0 }, feedProfile: { fed.append($0) })
    check("eligible with nil facts does not feed profile", fed.isEmpty)
}
let sem = DispatchSemaphore(value: 0)
Task { await run(); sem.signal() }
sem.wait()
print(failures == 0 ? "ALL PASS" : "\(failures) FAILED"); exit(failures == 0 ? 0 : 1)

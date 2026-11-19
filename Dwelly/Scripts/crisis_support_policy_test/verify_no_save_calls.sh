#!/bin/bash
# Crisis Support -- static source-text verification against the REAL production file
# (CaptureConversationView.swift), not a mock/reimplementation. Complements
# main.swift's pure-policy test: that test proves CrisisSupportPolicy's decision logic
# is correct in isolation, but cannot see whether the actual view wires that decision
# up to really block the six save/synthesis/profile/retry calls. This script extracts
# finishWithoutSaving()'s real body text and fails if it contains ANY of them.
#
# LIMIT, stated plainly: this is a textual/structural check, not a running program --
# it cannot catch a future edit that adds a NEW seventh call site elsewhere that also
# saves/synthesizes without going through finishAndSave()/finishWithoutSaving(). It is
# real evidence that TODAY's finishWithoutSaving() body is empty of those six calls,
# not a permanent runtime guarantee. A real XCTest/integration target would be the
# permanent version of this guarantee; this project has no such target (see the
# Nov 2026 KEY_LEARNINGS entry + this ticket's main.swift header comment for why).
set -euo pipefail
cd "$(dirname "$0")/../.."
FILE="Dwelly/Views/CaptureConversationView.swift"

fail() { echo "FAIL - $1"; exit 1; }
ok() { echo "ok   - $1"; }

# Extract finishWithoutSaving()'s body: from its signature line to the next
# top-level `private func` / `func` after it.
BODY=$(awk '/private func finishWithoutSaving/{flag=1; next} flag && /^    (private )?func /{exit} flag' "$FILE")

[ -n "$BODY" ] || fail "finishWithoutSaving() not found in $FILE at all -- has it been renamed/removed?"
ok "finishWithoutSaving() found in the real production file"

for forbidden in "saveMoment" "saveJournalEntry" "generateJournalMeta" "markMomentAsPending" "DwellerProfileManager" "retryPendingJournalEntries"; do
    if echo "$BODY" | grep -q "$forbidden"; then
        fail "finishWithoutSaving()'s real body calls '$forbidden' -- the no-journal/no-Formation guarantee is broken"
    fi
    ok "finishWithoutSaving()'s real body does NOT call '$forbidden'"
done

# Confirm the onChange hook routes Finish through CaptureSafetySession.finish(), which
# decides once (after waiting for in-flight replies) and runs exactly one path. The
# runtime behavior of finish() itself is exercised by
# Scripts/crisis_support_runtime_harness, not here.
ONCHANGE=$(awk '/\.onChange\(of: isConversationComplete\)/{flag=1} flag{print} flag && /^                    }$/{exit}' "$FILE")
echo "$ONCHANGE" | grep -q "safetySession.finish(" || fail "onChange(of: isConversationComplete) no longer routes through safetySession.finish()"
echo "$ONCHANGE" | grep -q "finishWithoutSaving()" || fail "onChange(of: isConversationComplete) never references finishWithoutSaving()"
echo "$ONCHANGE" | grep -q "finishAndSave()" || fail "onChange(of: isConversationComplete) never references finishAndSave()"
ok "onChange(of: isConversationComplete) routes Finish through safetySession.finish(save:block:)"

# Confirm finishAndSave() -- the normal path -- still makes all six calls (regression
# guard: this ticket must not have accidentally neutered the NORMAL save path while
# building the latched one).
NORMAL_BODY=$(awk '/private func finishAndSave\(\)/{flag=1; next} flag && /^    private func generateJournalMeta/{exit} flag' "$FILE")
for required in "saveMoment" "saveJournalEntry" "generateJournalMeta" "DwellerProfileManager" "retryPendingJournalEntries"; do
    echo "$NORMAL_BODY" | grep -q "$required" || fail "finishAndSave()'s real body no longer calls '$required' -- normal (non-latched) journaling may be broken"
    ok "finishAndSave()'s real body still calls '$required' (normal path unaffected)"
done

# The header Finish/Done button is hidden while a reply is in flight, by BOTH signals.
grep -q 'dwellyResponseCount >= 1 && !isConversationComplete && !isWaitingForDwelly && !safetySession.isAwaitingClassification' "$FILE" \
    || fail "the header Finish/Done button's guard no longer excludes in-flight replies"
ok "the header Finish/Done button is hidden while a reply is in flight"

# Both real finish entry points go through requestManualFinish().
grep -q 'Button("Save") { requestManualFinish() }' "$FILE" || fail "the leave-confirmation alert's Save no longer calls requestManualFinish()"
grep -q 'Button(action: { requestManualFinish() })' "$FILE" || fail "the header Finish/Done button no longer calls requestManualFinish()"
ok "the header button and the leave-alert Save both call requestManualFinish()"
[ "$(grep -v '^[[:space:]]*//' "$FILE" | grep -c 'manuallyFinished = true')" = "1" ] || fail "manuallyFinished = true is set somewhere other than requestManualFinish()"
ok "manuallyFinished = true is set in exactly one place"

# Every scheduled reply is marked in flight synchronously, BEFORE its Task starts.
SCHEDULES=$(grep -c 'Task { await requestDwellyResponse() }' "$FILE")
MARKED=$(grep -B1 'Task { await requestDwellyResponse() }' "$FILE" | grep -c 'safetySession.noteRequestScheduled(userText: ')
[ "$SCHEDULES" = "$MARKED" ] && [ "$SCHEDULES" -ge 1 ] || fail "$SCHEDULES reply schedule site(s) but only $MARKED immediately preceded by noteRequestScheduled(userText:)"
ok "all $SCHEDULES reply schedule sites call noteRequestScheduled(userText:) synchronously right before their Task"

# Every exit from requestDwellyResponse resolves its scheduled request through the session.
REQ=$(awk '/private func requestDwellyResponse\(\)/{flag=1; next} flag && /^    (private )?func /{exit} flag' "$FILE")
for call in "safetySession.cancelScheduled()" "safetySession.recordResponse(safetyTier: response.safetyTier)" "safetySession.recordFailure()" "CaptureSafetySession.onboardingClosingText(recordedTier: recordedTier, fixedCopy: closingMessage)"; do
    echo "$REQ" | grep -qF "$call" || fail "requestDwellyResponse() no longer calls $call"
done
ok "requestDwellyResponse() resolves every exit path through the session (cancel / response / failure) and gates the onboarding closer on the verdict"
echo "$REQ" | grep -q 'recordSkippedCheck' && fail "requestDwellyResponse() still skips the safety check for a turn"
# The onboarding closer must not return early before the proxy call.
CLOSER_LINE=$(echo "$REQ" | grep -n 'isFixedCloserTurn = ' | head -1 | cut -d: -f1)
CALL_LINE=$(echo "$REQ" | grep -n 'apiClient.callLLM' | head -1 | cut -d: -f1)
[ -n "$CLOSER_LINE" ] && [ -n "$CALL_LINE" ] || fail "could not locate the onboarding closer flag or the proxy call"
BETWEEN=$(echo "$REQ" | sed -n "${CLOSER_LINE},${CALL_LINE}p")
echo "$BETWEEN" | grep -qE '^[[:space:]]*return\b' && fail "requestDwellyResponse() returns before the proxy call on the onboarding closer turn"
ok "the onboarding closing turn reaches the same proxy call as every other turn (no early return, no skipped check)"
echo "$REQ" | grep -q 'if let tierRaw = response.safetyTier' && fail "requestDwellyResponse() reads response.safetyTier directly again (bypassing normalization)"
ok "the resource block keys off the session's normalized tier, not the raw response field"

# No pre-emptive support link on the ordinary starting screen.
PRELUDE=$(awk '/private var idlePrelude: some View/{flag=1; next} flag && /^    (private )?(var|func) /{exit} flag' "$FILE")
echo "$PRELUDE" | grep -q 'Text("Need support now?")' && fail "idlePrelude still shows the pre-emptive \"Need support now?\" link"
ok "idlePrelude has no pre-emptive \"Need support now?\" link"

# Closed after Finish: the composer is mounted ONLY while the conversation is not complete,
# with no Crisis Support exception, and every way back in is guarded.
grep -B1 -A1 'unifiedComposeSurface$' "$FILE" | grep -q 'if !isConversationComplete {' \
    || fail "the composer is no longer mounted exclusively under 'if !isConversationComplete {'"
grep -q '!isConversationComplete || isCrisisSupportBlocked' "$FILE" && fail "a Crisis Support exception still keeps something open after Finish"
grep -q 'isConversationComplete && !isCrisisSupportBlocked' "$FILE" && fail "the bottom area still treats Crisis Support as open after Finish"
ok "composer exists only before Finish, for every conversation type"
for fn in "private func sendUserTurn()" "private func handleRecordTap()" "private func transcribeIntoTextField()" "private func requestDwellyResponse() async"; do
    BODY=$(awk -v f="$fn" 'index($0,f){flag=1; next} flag && /^    (private )?func /{exit} flag' "$FILE" | grep -v '^[[:space:]]*//' | head -4)
    echo "$BODY" | grep -q 'guard !isConversationComplete, !safetySession.isClosed' || fail "$fn does not open with the closed-conversation guard"
done
ok "send, record, transcribe, and request all refuse once the conversation is closed"
grep -q 'thread stays open' "$FILE" && fail "closure copy still says the thread stays open"
ok "closure card copy no longer promises the thread stays open"

echo "ALL CHECKS PASSED"

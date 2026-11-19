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

# Confirm the onChange branch really dispatches to finishWithoutSaving() when latched,
# and finishAndSave() otherwise -- not, say, both unconditionally, or neither.
ONCHANGE=$(awk '/\.onChange\(of: isConversationComplete\)/{flag=1} flag{print} flag && /^                    }$/{exit}' "$FILE")
echo "$ONCHANGE" | grep -q "if isCrisisSupportBlocked" || fail "onChange(of: isConversationComplete) does not branch on isCrisisSupportBlocked"
echo "$ONCHANGE" | grep -q "finishWithoutSaving()" || fail "onChange(of: isConversationComplete) never calls finishWithoutSaving()"
echo "$ONCHANGE" | grep -q "finishAndSave()" || fail "onChange(of: isConversationComplete) never calls finishAndSave()"
ok "onChange(of: isConversationComplete) really branches between finishWithoutSaving() (blocked) and finishAndSave() (normal)"

# Confirm finishAndSave() -- the normal path -- still makes all six calls (regression
# guard: this ticket must not have accidentally neutered the NORMAL save path while
# building the latched one).
NORMAL_BODY=$(awk '/private func finishAndSave\(\)/{flag=1; next} flag && /^    private func generateJournalMeta/{exit} flag' "$FILE")
for required in "saveMoment" "saveJournalEntry" "generateJournalMeta" "DwellerProfileManager" "retryPendingJournalEntries"; do
    echo "$NORMAL_BODY" | grep -q "$required" || fail "finishAndSave()'s real body no longer calls '$required' -- normal (non-latched) journaling may be broken"
    ok "finishAndSave()'s real body still calls '$required' (normal path unaffected)"
done

# Bounded-verification fix (Nov 19 2026): the header Finish/Done button must not be
# tappable while a reply is still in flight -- tapping it mid-flight would flip
# `isConversationComplete` and fire the onChange hook on a `safetyTierSequence`
# snapshot that doesn't yet include the in-flight turn's own tier.
grep -q 'dwellyResponseCount >= 1 && !isConversationComplete && !isWaitingForDwelly' "$FILE" \
    || fail "the header Finish/Done button's real guard no longer excludes !isWaitingForDwelly -- the in-flight race this session fixed may have regressed"
ok "the header Finish/Done button's real guard still excludes !isWaitingForDwelly (in-flight race closed)"

# Bounded-verification fix, round 2 (Nov 19 2026): the leave-confirmation alert's
# "Save" button has no `if`/`.disabled()` mechanism available (SwiftUI alert actions
# don't support one), so BOTH real finish entry points -- this button AND the header
# button -- must route through the same `requestManualFinish()` guard instead of
# setting `manuallyFinished = true` directly.
grep -q 'Button("Save") { requestManualFinish() }' "$FILE" \
    || fail "the leave-confirmation alert's real Save button no longer calls requestManualFinish() -- it may be setting manuallyFinished directly again, reopening the race"
ok "the leave-confirmation alert's real Save button calls requestManualFinish(), not manuallyFinished directly"

grep -q 'Button(action: { requestManualFinish() })' "$FILE" \
    || fail "the header Finish/Done button no longer calls requestManualFinish()"
ok "the header Finish/Done button also calls requestManualFinish() (one shared guard, not two divergent ones)"

REQUEST_MANUAL_FINISH_BODY=$(awk '/private func requestManualFinish\(\)/{flag=1; next} flag && /^    (private )?func /{exit} flag' "$FILE")
echo "$REQUEST_MANUAL_FINISH_BODY" | grep -q 'waitForInFlightReply()' \
    || fail "requestManualFinish()'s real body no longer awaits waitForInFlightReply() -- layer 1 of the race fix may have regressed"
ok "requestManualFinish()'s real body awaits waitForInFlightReply() before setting manuallyFinished (layer 1)"

ONCHANGE2=$(awk '/\.onChange\(of: isConversationComplete\)/{flag=1} flag{print} flag && /^                    }$/{exit}' "$FILE")
echo "$ONCHANGE2" | grep -q 'waitForInFlightReply()' \
    || fail "onChange(of: isConversationComplete) no longer awaits waitForInFlightReply() before deciding -- layer 2 (the actual save-entry guard) may have regressed"
ok "onChange(of: isConversationComplete) also awaits waitForInFlightReply() before reading isCrisisSupportBlocked (layer 2, the real save-entry guard)"

echo "ALL CHECKS PASSED"

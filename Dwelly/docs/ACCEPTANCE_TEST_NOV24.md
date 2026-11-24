# Kell's Acceptance Test (Nov 24 2026)

Do this on your **real iPhone**, installed from Xcode (not build 111, which is missing today's fixes). Mark each line P (pass), F (fail) or N (not run). For any F, send Claude a screenshot.

## 0. Before you start
- [ ] iPhone plugged in, Claude installs today's code from Xcode
- [ ] Use a fresh test account (needed for onboarding and the Journal Ready card)

## 1. Onboarding (fresh account)
- [ ] Sign up, intro video, name, intent screens all work
- [ ] Onboarding conversation: 3 replies, then the journal is made
- [ ] Journal opens and reads well (title, body, verse)

## 2. Today tab
- [ ] **Journal Ready** shows your FIRST journal only
- [ ] Open it: card stays for the rest of today (gone tomorrow, check then)
- [ ] Make a second reflection: Journal Ready does NOT switch to it
- [ ] Mood card never shares a mood with the Sustain card
- [ ] Verse card, Sit with this, + button work

## 3. A normal conversation
- [ ] Type and send; voice record and send
- [ ] Chat scrolls all the way up under the back arrow and Done
- [ ] Back arrow and Done readable over your gold bubbles
- [ ] Dwelly's newest reply never hides under the message box
- [ ] Done appears after Dwelly's first reply; tap Done, journal is made
- [ ] Back arrow mid-chat: "Save this reflection?" with Save / Discard / Keep Talking
- [ ] If Dwelly names a verse: it shows once, real text, not doubled

## 4. Saving and the other tabs
- [ ] New entry shows in **Entries** right away (no app restart)
- [ ] Calendar dot on today's date
- [ ] **Growth** tab updates (story card, stats count)
- [ ] Search finds the entry
- [ ] Delete an entry; it leaves Entries and Growth

## 5. Look and feel (iOS 26+)
- [ ] Tab bar is glass; selected tab has the sliding pill
- [ ] + button and send button glass look right to you
- [ ] Anything that feels hard to read: screenshot it

## 6. Safety and crisis
- [ ] Run the full checklist: `docs/CRISIS_ACCEPTANCE_CHECKLIST.md` (sections A to I)

## 7. Offline and limits (T-328)
- [ ] Airplane mode mid-chat: clear offline message, nothing lost
- [ ] Reconnect: you can continue
- [ ] Send twice quickly while Dwelly is thinking: nothing weird
- [ ] Very long chat: if it hits the limit, it ends politely and saves

## 8. Paywall (beta is free)
- [ ] Start a 2nd, 3rd and 4th reflection: no paywall blocks you

## 9. Account and legal
- [ ] Read Terms of Service and Privacy Policy start to finish; note anything wrong
- [ ] Privacy says OpenAI only, and journals/profile are encrypted
- [ ] Send feedback reaches hello@dwelly.one
- [ ] Change password, sign out, sign back in: your entries are still there
- [ ] Delete account works (do this LAST, on the test account)

## After the test
Send Claude your F list. Claude fixes, then does the one final build (112) for TestFlight.

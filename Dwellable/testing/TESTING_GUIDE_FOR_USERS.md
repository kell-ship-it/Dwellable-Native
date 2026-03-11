# Dwellable Testing Guide — Plain English Edition

**Goal:** Make sure the app works reliably before we release it. You'll test real-world scenarios on your iPhone 13.

---

## Quick Answer: One Account or Multiple?

**Answer: Use ONE main account for most testing. Create additional accounts only for specific tests.**

- **Primary testing account:** `test.normal@example.com` / `password123`
  - Use this for 95% of your testing
  - Create multiple moments with this account
  - Test all workflows with the same user

- **Additional accounts (only if needed):**
  - Create separate accounts only to test multi-user scenarios or data isolation
  - For now, one account is fine

---

## Testing Phases Explained (Plain English)

### Phase 1: Offline Support (5 tests)
**In Plain English:** Can you capture moments and save them when you don't have WiFi? When the internet comes back, does the app automatically send those moments to the database?

**Why this matters:**
- Users will be capturing moments in random places (church, hiking, car) where WiFi isn't always available
- We can't ask them to stay on WiFi — the app must work offline
- The moment should save locally, and sync automatically when they get internet back

**Account to use:** One account (test.normal@example.com)

**Key tests:**
- Create a moment while WiFi is OFF → should save locally
- Turn WiFi back ON → moment should automatically upload (you shouldn't have to do anything)
- Create 3 moments offline → all should sync when you reconnect

---

### Phase 2: Authentication (6 tests)
**In Plain English:** Does login work correctly? Can you log in, stay logged in, and log out?

**Why this matters:**
- Users need a secure way to sign in and access only their own moments
- If login is broken, nothing else works
- If the app logs you out randomly, users will get frustrated

**Account to use:** Use your primary test account + one wrong password test

**Key tests:**
- Log in with correct email/password → should work
- Try logging in with wrong password → should show an error
- Log out → should ask for login again
- Close the app and reopen it → should still be logged in (your session should persist)

---

### Phase 3: Moment Operations (5 tests)
**In Plain English:** Can you create a moment by recording your voice? Can you type one instead? Can you see your moments in the list?

**Why this matters:**
- The core feature is capturing moments
- Users need to be able to use voice OR type (voice option)
- They need to see what they've captured and read it back

**Account to use:** One account (test.normal@example.com)

**Key tests:**
- Record a voice moment → it should show up in your list with the transcript
- Type a moment instead of recording → should also show up
- Add a "Sense of the Lord" note to a moment → should be saved
- View your moments list → should see newest moments first
- Tap a moment → should read the full text

---

### Phase 4: Network State Changes (6 tests)
**In Plain English:** What happens when WiFi drops while you're in the middle of doing something? Can the app recover gracefully?

**Why this matters:**
- Users won't always have stable internet
- WiFi might drop in the middle of saving a moment
- The app should handle this without crashing or losing data

**Account to use:** One account (test.normal@example.com)

**Key tests:**
- Start saving a moment, then disable WiFi mid-save → should catch the error, save locally
- Turn WiFi back on → should automatically retry and upload
- Turn on airplane mode mid-operation → should handle gracefully
- Turn airplane mode off → should continue working normally

---

### Phase 5: Data Persistence (6 tests)
**In Plain English:** If you force-quit the app or restart your phone, do you lose your data? Does everything stay safe?

**Why this matters:**
- Users might accidentally close the app mid-operation
- Their phone might die and restart
- We can't lose their moments

**Account to use:** One account (test.normal@example.com)

**Key tests:**
- Create a moment, then force-quit the app and reopen it → moment should still be there
- Create a moment offline, kill the app before it syncs, reopen and turn on WiFi → should still sync
- Check your iPhone's Settings > Passwords — your app's auth token should be stored securely there
- After logging out, check Settings > Passwords again — the token should be gone

---

### Phase 6: Error Handling (4 tests)
**In Plain English:** If something goes wrong (bad internet, Supabase crashes, you deny microphone access), does the app crash or handle it gracefully?

**Why this matters:**
- Apps that crash on errors are terrible user experiences
- Users need to see helpful error messages
- The app should never become unusable

**Account to use:** One account (test.normal@example.com)

**Key tests:**
- Try to tap the mic button without granting microphone permission → should show a helpful error
- Create an error state and see if a "Retry" button appears → should let you try again
- If the server is down (unlikely), does the app crash? → should show an error message instead

---

### Phase 7: Performance (3 tests)
**In Plain English:** Does the app stay fast and responsive? Does it use too much memory?

**Why this matters:**
- Slow apps feel broken to users
- Apps that use tons of memory drain battery and cause crashes
- Users expect smooth scrolling and quick responses

**Account to use:** One account (test.normal@example.com)

**Key tests:**
- Create lots of moments and scroll through the list → should feel smooth, no stuttering
- Use the app for a while, create/fetch moments repeatedly → app should stay responsive
- Save multiple moments quickly (tap save 5 times fast) while offline → all should queue and sync without duplicates

---

### Phase 8: UI/UX (5 tests)
**In Plain English:** Does the interface feel polished? Are buttons clickable? Does the keyboard work smoothly?

**Why this matters:**
- A beautiful interface makes people want to use the app
- Broken buttons or janky animations frustrate users
- The app should feel professional and reliable

**Account to use:** One account (test.normal@example.com)

**Key tests:**
- While the app is fetching moments, you should see a loading spinner
- While saving, buttons should be disabled (can't double-submit)
- Type in the text field → keyboard should appear/disappear smoothly
- Enable dark mode in your iPhone settings and relaunch the app → colors should look right

---

## Testing Strategy

### Before You Start
1. **One account:** `test.normal@example.com` / `password123` (you already have this)
2. **Fresh start:** Log out of the app if you're already logged in
3. **Have a plan:** Follow the "Quick Test Path" if you're short on time (Phase 1, 2, 3 minimum)

### During Testing
1. **Mark Pass/Fail:** In the MANUAL_TESTING_CHECKLIST.md, mark each scenario as Pass ☑️ or Fail ☐
2. **Write notes:** If something breaks, explain what happened and how to reproduce it
3. **Take screenshots:** If something looks wrong, take a screenshot

### After Testing
1. **Export results:** From the HTML checklist, click "📋 Export Results" and save the file
2. **Send back:** Share the results file + MANUAL_TESTING_CHECKLIST.md with me
3. **I'll fix bugs:** I'll create tickets for anything that fails and fix them next session

---

## Minimum Testing Path (if short on time)

If you only have 30 minutes, test these critical scenarios:

| Phase | Why It's Critical |
|-------|------------------|
| **Offline 1.1** | Can you save a moment with no WiFi? |
| **Auth 2.1** | Can you log in? |
| **CRUD 3.1** | Can you record and save a moment? |
| **Network 4.2** | When WiFi comes back, does it sync? |
| **Persistence 5.1** | If you kill the app, is your moment still there? |

---

## Common Issues to Watch For

1. **"Pending sync" message disappears too fast** — We know about this, probably fine
2. **Keyboard doesn't appear when tapping text field** — Report this
3. **App crashes during any operation** — Definitely report this
4. **Can't see your moments in the list after saving** — Report this
5. **Login button doesn't respond** — Report this
6. **Typing is slow or laggy** — Might be device-specific, note it

---

## Questions?

As you test, if you have any questions about:
- Why we're testing something
- How to reproduce a failure
- What "expected behavior" means

Just write it in the Notes column of the checklist. I'll read all notes and respond to every question.

---

**Ready to test?** Open MANUAL_TESTING_CHECKLIST.md and start with Phase 1! ✨

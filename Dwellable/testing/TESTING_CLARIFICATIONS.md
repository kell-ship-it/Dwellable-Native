# Testing Clarifications — March 10 Session

This document clarifies the MAYBE tests and ambiguous test descriptions from the March 10 testing session.

---

## Test 1.5: App Reinstall with Offline Moments

### Current Status
- **Result:** MAYBE (uncertain)
- **What happened:** User created moments offline, deleted the app, reinstalled it, signed back in. The offline moments were not present.

### Your Question
> "If I create moments offline and then delete the app and get back online and download the app, my moment is not saved. Once I refresh it, is that intentional? Is that because when you delete the app, you also delete things locally? Is that intentional?"

### Clarification
**Yes, this is currently intentional behavior.** Here's why:

1. **Offline moments are stored locally** — When you create moments without internet, they're saved to the device's local storage (LocalStorageManager).
2. **Reinstalling deletes local storage** — When you delete the app, you also delete all local app data (this is how iOS works — each app has its own sandbox).
3. **No cloud backup** — We don't sync offline moments to the server until the app is online. If you reinstall before syncing, those moments are permanently lost.

### Design Decision Needed
**Do you want to change this behavior?** Options:

**Option A: Keep current behavior (recommended for v1.0)**
- Offline moments are local-only
- Reinstalling the app loses offline data
- User education: "moments created offline are stored locally and will sync when you go online"
- Status: ✅ Current behavior
- Effort: None

**Option B: Support cloud sync of offline moments (v1.1+)**
- Even without internet, sync offline moments to server when connection returns
- Reinstalling no longer loses data (moments are backed up on server)
- Requires: Additional sync logic, cloud storage for pending moments
- Status: 🔲 Not implemented (see T-030)
- Effort: Medium

### Recommendation
**For v1.0 launch:** Keep Option A. Add user-facing messaging in the app ("Your offline moments sync when you reconnect to the internet").
**For v1.1+:** Implement Option B if user feedback indicates data loss is frustrating.

---

## Test 2.5: Sign Out Flow

### Current Status
- **Result:** PASS
- **What happened:** User tested the sign-out functionality

### Your Question
> "Here, are you just asking if I can sign-out successfully?"

### Clarification
**Yes, exactly.** Test 2.5 is testing the basic sign-out functionality:

1. **Test objective:** Verify that the sign-out button in SettingsView successfully logs the user out
2. **Success criteria:**
   - User can access the sign-out button
   - Tapping sign-out clears the session (JWT token)
   - App returns to LoginView
   - User must re-enter credentials to sign back in

3. **Current implementation status:** ✅ Sign-out is functional
   - AuthManager.logout() clears the JWT token from Keychain
   - Navigation returns to LoginView
   - No bugs observed

### Additional Verification
Since you marked it PASS, all of the above is working correctly. No action needed unless you want to test additional sign-out scenarios:
- Sign out mid-sync (what happens to pending moments?)
- Sign out and verify old token no longer works
- Sign out on multiple devices (would require multi-device support)

---

## Summary & Next Steps

| Test | Status | Clarification | Action |
|---|---|---|---|
| **1.5** | MAYBE | Intentional design choice; data loss on reinstall is expected iOS behavior | Decide: Keep v1.0 behavior or implement cloud sync (T-030) |
| **2.5** | PASS | Test is verifying basic sign-out functionality | No action needed; working as designed |
| **General Issue** | FIXED | Text placeholder added to make input field more obvious | ✅ Done (commit d518184) |

---

## Questions for Kell

Before proceeding, please clarify:

1. **For T-1.5 (offline moments):** Do you want to keep the current behavior (data lost on reinstall) or implement cloud sync for offline moments?
2. **For T-2.5 (sign-out):** Are there additional sign-out scenarios you'd like to test beyond the basic flow?
3. **For T-1.1 (offline sign-in):** Should we allow users to sign in while offline? This would require caching auth tokens. Is this a desired feature?

Once you provide these clarifications, we can update the tickets accordingly and prioritize implementation.

---

**Prepared:** March 10, 2026
**Testing Session:** T-020 Manual Testing Follow-up

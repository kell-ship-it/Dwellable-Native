# Pillar 0 — Edge Case QA Checklist

**Figma file:** `Dwellable — Existing Experience Baseline` (`t5MUGEtpeFcUixobvHiYMc`)
**Page:** `Onboarding — Edge Cases`
**Purpose:** Manual visual check of all 9 edge/error-state screens built July 31, 2026. Each screen was cloned from its corresponding happy-path screen, then modified — check that the modification is correct and nothing else drifted.

How to use: click each link (opens directly to that frame in Figma), work through its checklist, check the box in this file (or just eyeball and tell me what's wrong — either works).

---

## account-creation — 6 states

### 1. Email format error
[Open in Figma](https://www.figma.com/design/t5MUGEtpeFcUixobvHiYMc/Dwellable-%E2%80%94-Existing-Experience-Baseline?node-id=262-3)

- [ ] Email field has a red/coral border and darkened red-tinted background
- [ ] Error message below the field reads: "That email address doesn't look right."
- [ ] Password and Confirm Password fields look normal (unaffected)
- [ ] "Create account" button is dimmed/grayed out (disabled)
- [ ] Terms checkbox still shows checked

### 2. Password too short
[Open in Figma](https://www.figma.com/design/t5MUGEtpeFcUixobvHiYMc/Dwellable-%E2%80%94-Existing-Experience-Baseline?node-id=262-59)

- [ ] Password field has red border/background, error text below: "Password needs to be at least 8 characters."
- [ ] Eye-off (show/hide password) icon still visible inside the field
- [ ] Email and Confirm Password fields unaffected
- [ ] Button disabled

### 3. Confirm password mismatch
[Open in Figma](https://www.figma.com/design/t5MUGEtpeFcUixobvHiYMc/Dwellable-%E2%80%94-Existing-Experience-Baseline?node-id=262-115)

- [ ] Confirm Password field has red border/background, error text: "Passwords don't match."
- [ ] Email and Password fields unaffected
- [ ] Button disabled

### 4. Duplicate email (already registered)
[Open in Figma](https://www.figma.com/design/t5MUGEtpeFcUixobvHiYMc/Dwellable-%E2%80%94-Existing-Experience-Baseline?node-id=263-2)

- [ ] Email field shows red border/background
- [ ] Error text reads: "That email's already registered — log in instead?" (distinct copy from the format-error case — check this doesn't read like a generic "invalid format" message, since the problem here is different)
- [ ] Button disabled
- [ ] **Open question for you:** should this link to the actual login flow, or is static copy enough for now?

### 5. Terms checkbox unchecked
[Open in Figma](https://www.figma.com/design/t5MUGEtpeFcUixobvHiYMc/Dwellable-%E2%80%94-Existing-Experience-Baseline?node-id=263-58)

- [ ] All 3 fields look normal — no red/error styling anywhere (this isn't a validation error, just an incomplete required step)
- [ ] Checkbox shows unchecked (outline only, no checkmark, no gold fill)
- [ ] Button disabled
- [ ] Reads as the natural *default/initial* state of the screen, not as a scary error

### 6. Network / server error on submit
[Open in Figma](https://www.figma.com/design/t5MUGEtpeFcUixobvHiYMc/Dwellable-%E2%80%94-Existing-Experience-Baseline?node-id=263-114)

- [ ] Red-bordered banner appears between the header and the form fields
- [ ] Banner text reads: "Something went wrong creating your account. Please check your connection and try again."
- [ ] Banner text wraps fully inside the card — doesn't run off the screen edge
- [ ] All 3 fields show normal (unerrored) styling — this is a submission failure, not a field validation issue
- [ ] Button disabled
- [ ] **Open question for you:** should this auto-retry, or always require a manual tap? Should the button re-enable once the banner shows (so the user can hit Create Account again)?

---

## intent-selection — zero selected
[Open in Figma](https://www.figma.com/design/t5MUGEtpeFcUixobvHiYMc/Dwellable-%E2%80%94-Existing-Experience-Baseline?node-id=264-2)

- [ ] All 6 options show unselected (outline checkbox, muted text, no gold fill)
- [ ] "Select an option to continue." hint text appears above the button, centered, muted color
- [ ] Continue button is dimmed/grayed out
- [ ] No leftover "Thank you, I'll keep that in mind..." acknowledgment text (removed — only makes sense post-selection)

## rhythm-selection — zero selected
[Open in Figma](https://www.figma.com/design/t5MUGEtpeFcUixobvHiYMc/Dwellable-%E2%80%94-Existing-Experience-Baseline?node-id=264-64)

- [ ] All 4 options show unselected (dark dot indicator, muted text)
- [ ] "Select an option to continue." hint text appears above the button
- [ ] Continue button is dimmed/grayed out
- [ ] No leftover "That sounds like a good rhythm" acknowledgment text (removed)

---

## moment-types-loading — failed
[Open in Figma](https://www.figma.com/design/t5MUGEtpeFcUixobvHiYMc/Dwellable-%E2%80%94-Existing-Experience-Baseline?node-id=264-132)

- [ ] Status text at bottom reads "We hit a snag getting things ready." in red/coral (replacing "Preparing your account... X%")
- [ ] Percentage number is gone (was "75%")
- [ ] Progress bar is red/coral instead of gold
- [ ] "Try again" button appears below, gold-filled, matches the app's primary button style
- [ ] The 6 moment-example rows above (Peace in a friendship, etc.) are unaffected
- [ ] **Open question for you:** does tapping "Try again" restart the whole account-building process, or just retry the failed step? (affects whether this needs a loading-state variant of its own)

---

## Cross-cutting checks (all 9 screens)

- [ ] Status bar (time + signal/wifi/battery) renders correctly on every screen
- [ ] Progress dots at the top still show the correct step as current on each screen
- [ ] No screen has visibly cut-off or overlapping text
- [ ] Error/disabled colors feel consistent across all 6 account-creation states (same red, same dimmed-button treatment every time)

---

## Known open items (not bugs, need your call)

1. **Duplicate-email error** — should it deep-link to login, or is static copy fine for MVP?
2. **Network error** — auto-retry vs. manual only? Should the button re-enable after the banner appears?
3. **moment-types-loading retry** — full restart vs. resume from failure point?

None of these block anything — flagging so they don't get lost before engineering picks this up.

# Pillar 0 — Edge Case QA Checklist

**Figma file:** `Dwellable — Existing Experience Baseline` (`t5MUGEtpeFcUixobvHiYMc`)
**Page:** `Onboarding — Edge Cases`
**Purpose:** Manual visual check of all 9 edge/error-state screens built July 31, 2026. Each screen was cloned from its corresponding happy-path screen, then modified — check that the modification is correct and nothing else drifted.

**A copy of this checklist also lives directly on the Figma page itself** (top-left, next to the screens) for quick reference while you're in the file.

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

### 4. Duplicate email (already registered) — ✅ RESOLVED: deep-links to login
[Open in Figma](https://www.figma.com/design/t5MUGEtpeFcUixobvHiYMc/Dwellable-%E2%80%94-Existing-Experience-Baseline?node-id=263-2)

- [ ] Email field shows red border/background
- [ ] Error text reads: "That email's already registered — log in instead?"
- [ ] The "log in instead?" portion is underlined, signaling it's a tappable link (engineering: wire this to the login flow)
- [ ] Button disabled

### 5. Terms checkbox unchecked (default/only state) — ✅ RESOLVED: no separate error state
[Open in Figma](https://www.figma.com/design/t5MUGEtpeFcUixobvHiYMc/Dwellable-%E2%80%94-Existing-Experience-Baseline?node-id=263-58)

Kell confirmed: Create Account simply never highlights/enables until all 4 required items (email, password, confirm-match, terms) are complete. There's no separate "tried to submit while incomplete" trigger — so the standalone red Terms-error screen built earlier was removed as inconsistent with this model. This is now the only "incomplete form" reference screen.

- [ ] All fields look normal — no red/error styling anywhere (this isn't a validation error, just an incomplete required step)
- [ ] Checkbox shows unchecked (outline only, no checkmark, no gold fill)
- [ ] "Complete all fields to continue." hint text appears above the button, centered, muted — matches the same hint pattern used on intent-selection/rhythm-selection
- [ ] Button disabled

### 6. Network / server error on submit — ✅ RESOLVED: button re-enables
[Open in Figma](https://www.figma.com/design/t5MUGEtpeFcUixobvHiYMc/Dwellable-%E2%80%94-Existing-Experience-Baseline?node-id=263-114)

Recommendation applied: attempt a brief silent client-side auto-retry (1-2 attempts, invisible to the user) before this screen ever shows. Once the banner is showing, no further silent retries — the button re-enables so the user can manually retry themselves.

- [ ] Red-bordered banner appears between the header and the form fields
- [ ] Banner text reads: "Something went wrong creating your account. Please check your connection and try again."
- [ ] Banner text wraps fully inside the card — doesn't run off the screen edge
- [ ] All 3 fields show normal (unerrored) styling — this is a submission failure, not a field validation issue
- [ ] **Button is gold/enabled, not dimmed** — user can tap Create Account again immediately

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

**Recommendation for the retry behavior:** resume from the failure point, not a full restart — redoing an already-succeeded step over a transient blip is needless friction. This assumes the account-setup pipeline is resumable/idempotent; if that's not architecturally cheap for MVP, full restart is the fallback (worse UX, simpler engineering). Kell/engineering to confirm which is feasible.

- [ ] Status text at bottom reads "We hit a snag getting things ready." in red/coral (replacing "Preparing your account... X%")
- [ ] Percentage number is gone (was "75%")
- [ ] Progress bar is red/coral instead of gold
- [ ] "Try again" button appears below, gold-filled, matches the app's primary button style, and is properly centered with clean spacing above/below (not flush against the screen edge)
- [ ] The 6 moment-example rows above (Peace in a friendship, etc.) are unaffected

---

## Cross-cutting checks (all 9 screens)

- [ ] Status bar (time + signal/wifi/battery) renders correctly on every screen
- [ ] Progress dots at the top still show the correct step as current on each screen
- [ ] No screen has visibly cut-off or overlapping text
- [ ] Error/disabled colors feel consistent across all 6 account-creation states (same red, same dimmed-button treatment every time — except state 6, which is intentionally gold/enabled)

---

## Resolved items (for reference)

1. **Duplicate-email error** → deep-links to login (link styling applied to "log in instead?")
2. **Terms/Privacy error trigger** → no separate error state; Continue simply stays disabled until all 4 fields are complete, same as every other required-field pattern in this flow
3. **Network error retry** → silent auto-retry before showing the banner; manual only once shown; button re-enables
4. **moment-types-loading retry** → recommend resume-from-failure, pending engineering confirmation that the pipeline supports it

Nothing outstanding — all open questions from the first pass have been resolved.

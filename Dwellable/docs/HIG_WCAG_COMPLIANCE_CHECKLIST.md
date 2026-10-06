# Standing HIG + WCAG Compliance Checklist

**Ticket:** T-216
**Purpose:** Every new or edited Figma screen must pass all checks below before being marked design-complete. Run this checklist against each screen before signoff — do not derive these requirements screen-by-screen.

**Contrast checks require T-214 color tokens to be applied.** Until tokens are in place, note the gap and mark those items N/A with a ticket reference.

---

## 1. Tap Targets (Apple HIG — Interactive Elements)

The minimum tappable area for any control on iOS is **44×44pt**. This is the frame size, not the visual size of the icon or label.

- [ ] Every button, link, and toggle has a hit area of at least 44×44pt
- [ ] Icon-only buttons (back chevron, X cancel, search icon) have a surrounding hit area ≥ 44×44pt even if the glyph is smaller
- [ ] Tightly spaced controls have enough separation that adjacent targets are not easily mis-tapped (Apple recommends ≥ 8pt gap between targets)
- [ ] Row-based list items are at minimum 44pt tall

**Known problem areas to always re-check:**
- Back button / navigation chevron (T-223 — often built too small)
- Calendar/date chevron (T-217)
- Cancel X on the recording screen (T-219)
- Header action pills (T-215)

---

## 2. Contrast Ratios (WCAG AA)

Apply **T-214 color tokens** — do not use raw hex fills. The token set is pre-verified to clear the thresholds below. If you are adding a new color not yet in the token set, verify it with Figma's built-in Contrast plugin or the Stark plugin before using it.

**WCAG AA thresholds:**

| Text type | Minimum ratio |
|-----------|--------------|
| Body/normal text (< 18pt or < 14pt bold) | **4.5:1** |
| Large text (≥ 18pt or ≥ 14pt bold) | **3:1** |
| UI components and icons (including inactive state) | **3:1** |

**Checks:**
- [ ] All body copy and labels pass 4.5:1 against their direct background
- [ ] All date/metadata/secondary text passes 4.5:1 (metadata is still normal-size text — the 3:1 large-text exception does not apply to small muted text)
- [ ] All standalone icons and glyphs pass 3:1
- [ ] Placeholder text in input fields passes 4.5:1 (placeholder is body text, not large text)
- [ ] Disabled states are intentionally below-contrast by design — mark them explicitly as disabled so they are not flagged as errors
- [ ] Text rendered over images or gradient overlays: verify contrast at the worst-case (lightest) point of the background, not the average

**Known recurring problem areas (from Digital Cotton review):**
- Date text on journal entry screens (comment #5)
- Body copy on entry detail (comment #6, #7)
- Back button circle fill/icon contrast (comment #5)
- Any bare "muted gray" that was eyedropperd from a neighboring hex and not drawn from the token set

**Locked rule — Gold CTA buttons (T-246):**
- [ ] Gold CTA button text is **dark** (text/primary or text/on-gold), never white. White-on-gold = 2.06:1 (fail). Dark-on-gold = 7.72:1 (AA + AAA pass). Applied first in T-238 Screen 1 "Get Started" button.

---

## 3. Typography

- [ ] System font (SF Pro) used throughout — no custom fonts unless explicitly approved
- [ ] Font sizes are consistent with the app's established scale (do not introduce arbitrary intermediate sizes)
- [ ] Text alignment follows the T-236 rule:
  - Instructive / body copy → **left-aligned**
  - Scripture and quoted text → **center-aligned**
  - Logo / brand intro screens → **centered**
- [ ] No text is truncated or clipped by its container at default font size
- [ ] Line height is sufficient that descenders on one line do not visually touch ascenders on the next

---

## 4. Layout and Spacing

- [ ] Content observes safe area insets — no text or interactive element overlaps the status bar, home indicator, or Dynamic Island region
- [ ] Horizontal content padding is **28px** on both sides (T-237 — most-used value, applied to header, content, and footer sections)
- [ ] Vertical rhythm between sections is consistent — eyeball adjacent screens to check that spacing didn't drift
- [ ] No element is flush against the screen edge without intentional full-bleed treatment

---

## 5. Navigation and Back Controls

- [ ] Every screen that is not the root has a clear way back (back button, close button, or swipe-to-dismiss)
- [ ] Back button treatment is consistent with T-223 — same style (circular-button or bare chevron, TBD by T-223 decision) used everywhere
- [ ] Navigation depth is clear — a user can orient themselves in the hierarchy from the screen alone
- [ ] Navigation bar follows Apple HIG: title centered or left-aligned (per iOS platform convention), leading/trailing buttons only where needed

---

## 6. Status Bar

- [ ] Status bar (time + signal + battery) is present and uses the correct style (light-on-dark for the app's dark theme)
- [ ] No content from the screen underlaps or overlaps the status bar
- [ ] Use Apple's real iOS status bar component (from the iOS and iPadOS UI Kit, already available in Assets — confirmed T-222) not a placeholder

---

## 7. Iconography (SF Symbols)

- [ ] Icons use SF Symbols where an appropriate symbol exists — do not draw a custom glyph for a standard action (back, close, search, share, etc.)
- [ ] Symbol weight and scale matches the surrounding typography weight (e.g., don't pair a heavy-weight symbol with regular-weight label text)
- [ ] Icon-only controls that don't carry a visible label have an accessibility label defined (see Section 8)

---

## 8. VoiceOver and Accessibility Labels

- [ ] Every interactive element has an explicit accessibility label (not just the visible text — the label should describe the action, not the glyph)
- [ ] Decorative images and purely visual dividers are marked as accessibility-hidden
- [ ] The reading/focus order follows the natural visual top-to-bottom, left-to-right order of the layout
- [ ] Input fields have labels that are exposed to VoiceOver — a placeholder alone is not sufficient (the placeholder disappears when the user types)
- [ ] Custom interactive components (cards, selections, toggles) declare the appropriate accessibility trait (button, toggle, adjustable, etc.)

---

## 9. Loading and Error States

- [ ] Every screen that fetches data has a defined loading state (skeleton, spinner, or progress indicator)
- [ ] Every screen that can fail has a defined error state with a user-actionable message
- [ ] Empty states are designed — a list or feed that can be empty has a defined zero-state (not just a blank screen)
- [ ] Error messages use plain language — no raw API error strings exposed to the user

---

## 10. Color Tokens (Design System Hygiene)

This section is structural — it is about hygiene and forward correctness, not contrast.

- [ ] All color fills use T-214 Figma color variables — no raw hex values on any text, icon, or background layer
- [ ] If a new token is needed, it is added to the T-214 token set and verified before use — do not eyedropper a new color
- [ ] Token names are descriptive of role, not value (e.g., `text/metadata` not `gray-500`)

---

## Sign-off

Before marking a screen design-complete, all items above must be checked (or explicitly deferred with a ticket reference). Deferred items that affect shipping quality should be tracked as new tickets.

| Section | ✅ Pass / ❌ Fail / — N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | | |
| 2. Contrast | | |
| 3. Typography | | |
| 4. Layout + Spacing | | |
| 5. Navigation | | |
| 6. Status Bar | | |
| 7. Iconography | | |
| 8. VoiceOver | | |
| 9. Loading + Error States | | |
| 10. Color Tokens | | |

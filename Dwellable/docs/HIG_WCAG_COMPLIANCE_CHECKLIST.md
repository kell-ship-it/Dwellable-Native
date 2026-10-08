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

**Process rule (locked October 8, 2026):** This table must be filled in with real, computed values at the moment each screen is marked Design-Complete — not retrofitted later via a separate audit pass. Contrast ratios are calculated from actual fill/text hex values (or a contrast plugin), never eyeballed. Tap targets are verified against actual frame dimensions (`get_metadata`), never judged from a screenshot. See `feedback_hig_wcag_checklist_gate` memory for the incident that prompted this.

**Backfill pass — October 8, 2026** (first time this table has actually been filled in; T-238 screens were previously marked ✅ without it)

### 01 — Welcome (node 2159:130)

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | Get Started 346×60, login-prompt-row 44pt tall |
| 2. Contrast | ✅ Pass | Tagline #747f8c/#0a0a0a = 4.86:1; gold CTA dark-on-gold = 9.54:1; brand name/login-link near-max contrast |
| 3. Typography | ✅ Pass (approved deviation) | Instrument Serif/Sans, not SF Pro — intentional project type system, not an oversight |
| 4. Layout + Spacing | ✅ Pass | 28px horizontal padding on action-footer |
| 5. Navigation | — N/A | Root screen, no back control needed |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` component instance |
| 7. Iconography | ✅ Pass | No icon-only controls besides brand flame (not a system icon) |
| 8. VoiceOver | ⚠️ Deferred | Cannot verify accessibility labels from Figma; flag for SwiftUI build time |
| 9. Loading + Error States | — N/A | No data fetch on this screen |
| 10. Color Tokens | ✅ Pass | All fills bound to `text/primary`, `text/tertiary`, `accent/gold`, `background/primary` |

### 03 — Account Creation (node 2190:92)

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | back-button 44×44, eye-toggle 44×44, inputs 60pt tall |
| 2. Contrast | ✅ Fixed | Was: placeholder 4.42:1 (fail), privacy-note raw rgba(…,0.6) = 2.43:1 (fail), border 2.76:1 vs card interior (fail). Fixed: placeholder bound to new `text/placeholder` #8491a0 (~5.6:1), privacy-note alpha removed + bound to `text/tertiary` (4.86:1), borders bound to new `border/input` #67677b (3.26:1 vs card fill) |
| 3. Typography | ✅ Pass (approved deviation) | Same type-system note as 01 |
| 4. Layout + Spacing | ✅ Pass | 28px padding consistent |
| 5. Navigation | ✅ Pass | back-button present, 44×44 |
| 6. Status Bar | ✅ Pass | Real component instance |
| 7. Iconography | ⚠️ Unverified | back-button and eye-toggle are image assets — contrast of the glyph itself not verifiable from exported code; visually spot-check |
| 8. VoiceOver | ⚠️ Deferred | Same as 01 |
| 9. Loading + Error States | ✅ Pass | 03a (email error) and 03b (loading) sub-states exist |
| 10. Color Tokens | ✅ Fixed | Was raw hex on placeholders/privacy-note; now all bound, including new `surface/card` token on input fills |

### 04 — Name Entry (node 2203:92)

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | back-button 44×44, skip-row full-width 44pt |
| 2. Contrast | ✅ Fixed | Was: placeholder raw rgba(…,0.8) = 3.29:1 (fail, worse than 03's), border 2.76:1 (fail). Fixed: bound to `text/placeholder` and `border/input` (same tokens as 03) |
| 3. Typography | ✅ Pass (approved deviation) | — |
| 4. Layout + Spacing | ✅ Pass | — |
| 5. Navigation | ✅ Pass | back-button present |
| 6. Status Bar | ✅ Pass | — |
| 7. Iconography | ⚠️ Unverified | back-button image asset, same note as 03 |
| 8. VoiceOver | ⚠️ Deferred | — |
| 9. Loading + Error States | ✅ Pass | 04a (name error) sub-state exists |
| 10. Color Tokens | ✅ Fixed | placeholder + border now bound |

### 05 — Intent Selection (node 2209:92)

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | back-button 44×44, option rows 72pt tall |
| 2. Contrast | ✅ Fixed | Was: option-card borders #33333d vs card fill = **1.44:1** (fail, worst miss found this pass), option-5 label using muted `#747f8c` inconsistent with siblings + failing at 4.42:1. Fixed: borders bound to `border/input` #67677b (3.26:1), option-5 label bound to `text/primary` matching siblings |
| 3. Typography | ✅ Pass (approved deviation) | — |
| 4. Layout + Spacing | ✅ Pass | — |
| 5. Navigation | ✅ Pass | back-button present |
| 6. Status Bar | ✅ Pass | — |
| 7. Iconography | ⚠️ Unverified | back-button, select-indicator image assets |
| 8. VoiceOver | ⚠️ Deferred | select-indicator rows need an accessibility "selected" trait at build time, not just visual state |
| 9. Loading + Error States | ✅ Pass | 05a (error) sub-state exists |
| 10. Color Tokens | ✅ Fixed | **Was entirely raw hex, no tokens bound at all** despite being marked ✅ Design-Complete — root cause of this screen's misses. Now fully bound: `background/primary`, `text/primary`, `text/tertiary`, `accent/gold`, new `surface/card`, new `border/input` |

### 06 — Notification Permission (node 2213:92)

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | back-button 44×44, not-now-row full-width 44pt |
| 2. Contrast | ✅ Pass | Heading/subtitle/button/not-now all clear thresholds (4.86:1–9.54:1). notification-preview card is an illustrative OS mockup, not a real interactive component — exempted from contrast check (confirmed again this pass) |
| 3. Typography | ✅ Pass (approved deviation) | — |
| 4. Layout + Spacing | ✅ Pass | — |
| 5. Navigation | ✅ Pass | back-button present |
| 6. Status Bar | ✅ Pass | — |
| 7. Iconography | ⚠️ Unverified | back-button image asset |
| 8. VoiceOver | ⚠️ Deferred | — |
| 9. Loading + Error States | — N/A | No data fetch |
| 10. Color Tokens | ✅ Fixed | **Was entirely raw hex**, same root cause as Screen 05. Now bound: `background/primary`, `text/primary`, `text/tertiary`, `accent/gold` |

### 07 — Preparing Space (node 2240:92)

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | cta-link-hitzone 346×44 |
| 2. Contrast | ✅ Fixed | Was: subtitle "Making space to receive…" #666159 = **3.23:1** (fail — prior session's MEMORY.md incorrectly called this "deliberate, not a violation"; it's active body copy, not a disabled state, so the disabled-contrast exception doesn't apply). Fixed: bound to new `text/muted-warm` #807b71 (~4.70:1). The muted/not-yet-started slot (#635e52, 3.07:1 — now "Preparing your first prompt...", see copy update below) correctly remains exempt as a genuine disabled/inactive-state item — must be marked with a disabled/inactive accessibility trait at SwiftUI build time so VoiceOver doesn't read it as equally actionable |
| 3. Typography | ✅ Pass (approved deviation) | — |
| 4. Layout + Spacing | ✅ Pass | Home indicator at y=861, 8pt from true bottom edge |
| 5. Navigation | — N/A | Final onboarding screen, no back control by design |
| 6. Status Bar | ✅ Pass | — |
| 7. Iconography | ⚠️ Unverified | Checkmark glyph contrast against the item-1/2-circle icon fills can't be computed from exported code (rendered via image asset) — visually verify |
| 8. VoiceOver | ⚠️ Deferred | — |
| 9. Loading + Error States | ✅ Pass | Checklist items themselves are a loading-state pattern by design |
| 10. Color Tokens | ✅ Fixed | Root bg bound to `background/primary`, cta-link bound to `accent/gold`, subtitle bound to new `text/muted-warm`. Headline/checklist-item labels (#f5f5f7) intentionally left as a distinct near-white shade shared with the status-bar component — not unified with `text/primary` (#e8e8ed) since that would be a visual change, not a hygiene fix |

**Copy update — October 8, 2026:** Screen 07's 4 loading items changed from (Setting up your journal / Opening your reflection space / Preparing your first prompt / Readying your daily rhythm) to (**Waking up Dwelly / Setting up your journal / Opening your reflection space / Preparing your first prompt**). "Daily rhythm" was dropped because Rhythm is a post-onboarding, conditional concept not established anywhere in the onboarding flow itself — referencing it here was describing a feature the user hadn't actually set up. "Waking up Dwelly" was chosen as the replacement (placed first, not appended) because it's the one unconditional, concrete thing every user gets regardless of intent/rhythm/notification choices — and it's causally prior to the other three (Dwelly's conversation is what produces the journal, reflection space, and prompt), so it reads as a sequence rather than a stretch to reach four items.

### Open items carried forward (not fixed this pass — need a decision or can't be verified from Figma)

- Icon-only back-button and eye-toggle glyph contrast (03, 04, 05, 06) — rendered as image assets, not computable from exported code. Needs a visual spot-check.
- Checkmark glyph contrast on Screen 07's circle icons — same limitation.
- VoiceOver accessibility labels/traits — none of this is expressible in Figma; must be implemented and verified at SwiftUI build time (T-110 build ticket), not blocked in design.
- Screen 02 (Intro Video) is still undesigned — this checklist will need to run against it once built.

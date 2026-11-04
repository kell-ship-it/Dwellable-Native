# Standing Redesign Principles Checklist (HIG + WCAG + Digital Cotton + Ashley)

**Ticket:** T-216
**Terminology (locked October 8, 2026):** Called the **Redesign Principles** going forward — this 10-section gate encompasses Apple HIG, WCAG AA, Digital Cotton's Figma review findings, and Ashley's onboarding audit, not just the two named in the old filename. "HIG/WCAG checklist" and "Redesign Principles" refer to the same thing; use the latter in conversation and new docs.
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

**Extension (locked October 13, 2026, from the P1 error-states retro):** the same "compute it, don't eyeball it" rule applies to anything a script derives rather than a human draws by hand — bubble/text heights, sibling-element gaps, and any position computed from a resize or reflow. These fail the same way unbound color/contrast failed in P0: the script completes without error and the result looks plausible in a quick screenshot glance, but the actual number is wrong (a mis-measured text height silently clips content; a resize that isn't re-propagated to dependent spacing creates a 0px collision). Before marking a screen that involved any scripted resize, reflow, or text-height computation as Design-Complete, verify the real output coordinates via `get_metadata` (bubble heights match their content, sibling gaps are positive and match the intended spacing value, nothing lands inside another element's bounds) — not just a screenshot at a glance. See `docs/MEMORY.md`'s October 13, 2026 session entries (Cancel/Stop glyph-centering bug, Stop-button/timer collision, bubble-text clipping bug) for the incidents that prompted this extension.

**Companion doc:** `docs/DESIGN_LEARNINGS.md` consolidates this checklist's standing HIG/WCAG rules with Digital Cotton's Figma review findings and Ashley's onboarding audit — read it before starting a new pillar's design pass, not just this file.

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

### P1 Capture Onboarding — Screen 1: Transition (from Onboarding) (dwelly-redesign file, node 21:154)

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | — N/A | No interactive elements; auto-advancing bridge screen, no user action |
| 2. Contrast | ✅ Pass | Heading (bright token) 16.2:1 on page bg; subtitle (muted token) 4.86:1 on page bg — both verified against actual adjacent fill (plain page bg here, no card surface) |
| 3. Typography | ✅ Pass (approved deviation) | Instrument Serif heading / Instrument Sans subtitle, consistent with project type system |
| 4. Layout + Spacing | ✅ Pass | 28px horizontal padding, centered composition |
| 5. Navigation | — N/A | Auto-advancing, no back/exit control by design (bridge moment, not a decision screen) |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` component instance |
| 7. Iconography | ✅ Pass | Real flame asset cloned directly from Pillar 0 Welcome screen (same source node), not redrawn |
| 8. VoiceOver | ⚠️ Deferred | Flag for SwiftUI build time |
| 9. Loading + Error States | — N/A | This screen IS the transition/loading state itself |
| 10. Color Tokens | ✅ Pass | All fills bound to `background/primary`, `text/primary`, `text/tertiary` variables — no raw hex |

**iPhone device frame:** present, same convention as Screen 2 and Pillar 0.

### P1 Capture Onboarding — Screen 2: Capture Entry, Guided Prompts + Direct Text (dwelly-redesign file, node 16:156)

**Superseded Oct 8, 2026:** Kell provided a reference screenshot (labeled "keyboard-active-state") showing the actual locked content/layout language for this screen — bold category title + subtitle per card, flame brand mark, pill-style gold-bordered input with circular send button. Screen rebuilt to match. Two things from that reference were explicitly NOT carried over: the progress bar (Kell confirmed the Oct 8 no-progress-bar decision stands — the reference screenshot is exactly the outdated mockup `DESIGN_LEARNINGS.md` already warned about on this point) and the helper copy "Pulled from what you shared during onboarding..." (this is the literal line T-209 already rejected as over-explaining; kept the locked "Tap one, or just start talking." instead). The reference's horizontal card layout was also not carried over — built vertically stacked per T-206, per Kell's explicit direction that Digital Cotton's horizontal-scroll objection still stands; only the per-card content style (bold title + subtitle) was adopted from the reference.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | Send button 44×44; cards 346×72 each; input pill 346×60 — all exceed 44pt minimum. Flame brand mark (24×24) is non-interactive, exempt. |
| 2. Contrast | ✅ Pass | Computed against actual adjacent fills. Card title (bright token) 14.8:1 vs card fill; card subtitle (locked `text/placeholder` #8491a0) 5.63:1 vs card fill; card border (locked `border/input` #67677b) 3.27:1 vs card fill; input pill gold border 8.75:1 vs card fill; send icon (dark, T-246 rule) 9.59:1 on gold button fill; heading 16.2:1 / helper copy 4.86:1 on page bg. All pass. |
| 3. Typography | ✅ Pass (approved deviation) | Instrument Serif heading / Instrument Sans body, consistent with project type system |
| 4. Layout + Spacing | ✅ Fixed | 28px horizontal padding throughout, consistent with T-237. Was: input pill bottom at y=850, only 11px clearance above home indicator (y=861) — tighter than this app's own established bottom-safe-area convention (Welcome/Account Creation end their last interactive element ~846, ~15px clearance; Apple's real safe-area inset is 34pt from the true bottom edge, and 24pt clearance from screen bottom undershot that). Fixed: input moved to y=786 (bottom=846), matching the app's own precedent, 15px clearance. |
| 5. Navigation | ⚠️ Gap | No back/close control built — reference screenshot shows none either (implies swipe-to-dismiss modal sheet), but T-122 (cancel/dismiss affordance for post-onboarding Capture) is a separate, not-yet-built ticket. Don't assume swipe-only is the final answer; confirm with T-122 before this screen is implementation-ready. |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` component instance, no overlap. No progress bar (Oct 8, 2026 decision confirmed standing). |
| 7. Iconography | ⚠️ Unverified | Send icon is a text "↑" glyph, not a real SF Symbol (`arrow.up`) — flag for swap at SwiftUI build time |
| 8. VoiceOver | ⚠️ Deferred | Cannot verify accessibility labels from Figma; flag for SwiftUI build time |
| 9. Loading + Error States | — N/A for this scenario | This is the resting entry state only; the active-typing variant (with "Tap return..." caption) and failure/edge states are separate scenarios in this same P1 set |
| 10. Color Tokens | ⚠️ Gap | Card fill, card border, and card-subtitle/placeholder colors use raw hex matching already-locked token values — `border/input`/`text/placeholder`/`surface/card` variables aren't yet imported into the `dwelly-redesign` file's scope (only `background/primary`, `text/primary`, `text/tertiary`, `accent/gold` are). Same gap as before, unresolved. |

**iPhone device frame:** present (dynamic island, side buttons, 54pt corner radius screen clip, 68pt wrapper radius) — matches Pillar 0's device-frame convention exactly.

### P1 Capture Onboarding — Screen 2a: Capture Entry, Active Typing (dwelly-redesign file, node 28:247)

Shows the tapped-in/focused state of Screen 2's input: typed text + cursor, gold caption, real keyboard pinned to the bottom, input bar riding just above it (8pt gap) instead of its Screen-2 resting position near the home indicator — matches real iOS keyboard-follow behavior.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass / Exempt | Send button 44×44. Keyboard keys (32×42) and return key (80×42) are under 44×44, but this is illustrative OS keyboard chrome, not an app-built control — exempt per `DESIGN_LEARNINGS.md`'s "real native components over mockups" rule, same exemption already applied to the status bar elsewhere. |
| 2. Contrast | ✅ Pass | Typed text (bright token) 14.8:1 vs input fill; caption (gold token) 9.59:1 vs page bg; send icon/cursor same as Screen 2 (9.59:1 / 8.75:1). Keyboard key labels not computed — OS chrome, exempt. |
| 3. Typography | ✅ Pass (approved deviation) | Consistent with project type system; caption at 12px Instrument Sans Medium |
| 4. Layout + Spacing | ✅ Pass | Input sits 8pt above keyboard, caption 8pt below input — matches reference's compact rhythm |
| 5. Navigation | ⚠️ Gap | Same open item as Screen 2 — no back/close control; depends on T-122 |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` instance retained, no overlap with keyboard |
| 7. Iconography | ⚠️ Unverified | Send icon still a text glyph, same flag as Screen 2. Keyboard is illustrative OS chrome, not subject to this check. |
| 8. VoiceOver | ⚠️ Deferred | Flag for SwiftUI build time |
| 9. Loading + Error States | — N/A | This screen IS the active-input illustrative state |
| 10. Color Tokens | ⚠️ Gap | Same carried-over gap as Screen 2 (card/input fill raw hex matching locked values). Keyboard key fills are raw hex but exempt as OS chrome. |

**Home indicator:** intentionally omitted — keyboard covers that screen region, matching real iOS behavior.
**iPhone device frame:** present, same convention as Screen 2.

### P1 Capture Onboarding — Screen 3: Guided Prompt Selection → Text (dwelly-redesign file, node 35:193)

**Correction (Oct 8, 2026):** This scenario was initially skipped by mistake — the Dwelly Prompt screen below was built into this slot's numbering by accident ("03" instead of "04"), leaving the actual Screen 3 placeholder empty while its label looked complete. Kell caught this by reviewing the Figma grid directly. Relabeled the Dwelly screen to 04 and built the real Screen 3 here: the user's own selected prompt from Screen 2's card grid, shown as the focal anchor (eyebrow category label + serif heading), with a back button to return to the grid and the same input pill convention below.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | Back button 44×44, send button 44×44, input pill 346×60 |
| 2. Contrast | ✅ Pass | Eyebrow label (gold token) 9.59:1 on page bg; heading (bright token) 16.2:1 on page bg; input border/placeholder same verified values as Screens 2/2a/4 |
| 3. Typography | ✅ Pass (approved deviation) | Instrument Serif heading (this screen's prompt is the focal moment, same treatment as other screen headings) / Instrument Sans eyebrow + body |
| 4. Layout + Spacing | ✅ Pass | Input bar at y=786, 15px home-indicator clearance — built correctly using the established convention from the start |
| 5. Navigation | ✅ Pass | Real back button present — this screen is a direct continuation of the Screen 2 selection flow, not a modal entry point, so back nav is the correct (and resolved) pattern here, unlike Screens 2/2a/4's open T-122 gap |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` component instance |
| 7. Iconography | ⚠️ Unverified | Back chevron and send icon are text glyphs, not real SF Symbols — flag for swap at SwiftUI build time |
| 8. VoiceOver | ⚠️ Deferred | Flag for SwiftUI build time |
| 9. Loading + Error States | — N/A for this scenario | Resting entry state only |
| 10. Color Tokens | ⚠️ Gap | Same carried-over gap as other Capture screens (input fill raw hex matching locked values) |

**iPhone device frame:** present, same convention as Screens 1–4.

### P1 Capture Onboarding — Screen 2a correction: Active Typing spacing (dwelly-redesign file, node 28:247)

**Correction (Oct 8, 2026):** Kell flagged the keyboard-active state looked "too close" and "disorganized." Checked the real numbers and found the cause: the caption and keyboard were landing at the exact same Y coordinate (0px gap, likely visually overlapping), and the keyboard frame had 96px of dead empty space at its own bottom with nothing anchoring it (home indicator was never added inside the keyboard area). Fixed: keyboard resized to hug its actual content (304pt → 260pt), a home-indicator bar added at its bottom (matches real iOS behavior of keeping it visible over the keyboard), and real 10px gaps established both between input→caption and caption→keyboard. Re-verify Section 4 (Layout + Spacing) for this screen reflects ✅ Fixed as of this correction, superseding the earlier sign-off's gap measurements.

### P1 Capture Onboarding — Scenario 1 (Direct Text Reflection), full flow screens 05–09 (dwelly-redesign file, nodes 38:206 / 38:246 / 38:288 / 38:344 / 38:395)

**Correction (Oct 8, 2026):** Kell caught that an earlier "Screen 3" (eyebrow label + heading + input, built after tapping a prompt card) was invented and doesn't exist in the real design — the original file's Scenario 2 goes straight from the card grid into a live Dwelly conversation, no intermediate screen. That invented screen was deleted and its grid slot reverted to a placeholder. Separately, Kell had the real original "P1 — Capture Onboarding — ✅ Ready for Review" page pulled up, confirming every scenario is a full multi-screen journey (not one screen per scenario) — Scenario 1 alone runs 6 screens: entry → active typing → message sent → Dwelly responds → conversation continues → scrolled view → journal payoff. Content (conversation copy, the "A Conversation with Mom" journal entry, the John 14:27 verse) pulled directly from the real file's `r1-text-sent` / `r1-dwelly-responds` / `r1-conversation-flow` / `r1-conversation-scrolled` / `CTA-5 — Rich Journal Preview` frames.

Two bugs caught and fixed during build, not just at audit time: (1) the journal card's body text had a stale auto-resize height (stuck at 18px despite wrapping to 3 lines), causing it to overlap the verse/footer text below it — `textAutoResize: 'HEIGHT'` never recomputed against a `layoutSizingHorizontal: 'FILL'`-resolved width in the same script; fixed by switching to a fixed height sized for the actual content. (2) The original "scrolled" approach (shifting all content up to simulate scroll, with a masking scrim) caused a duplicate status bar and overlapping content right at the scrim boundary; rebuilt as simply showing the later messages in normal position instead, which reads cleanly and avoids the clipping math entirely.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ⚠️ Gap | Send buttons 44×44 throughout. Screen 09's "Saved · View journal →" footer text (17px tall) is likely tappable (navigates to the full journal entry) but has no real hit zone — needs the same 44×44 hitzone-wrap treatment already used elsewhere (e.g. Screen 2's close button) before this is build-ready. |
| 2. Contrast | ✅ Pass | All reused already-verified token combinations: bubble text (bright) 14.8:1 vs bubble fill; Dwelly sender label / muted text 4.86:1 on page bg; gold bubble border (user messages) 8.75:1 vs bubble fill; dark border (Dwelly messages, locked `border/input`) 3.27:1 vs bubble fill. No new raw contrast pairs introduced. |
| 3. Typography | ✅ Pass (approved deviation) | Instrument Sans for conversational bubbles, Instrument Serif reserved for the journal card's title only — consistent with the project's established "Serif for headings, Sans for body/chat" convention |
| 4. Layout + Spacing | ✅ Pass | Input bar at y=786, 15px home-indicator clearance on all 4 conversation screens; Screen 09 correctly omits the input bar (replaced by the journal card, no further typing at this end state) |
| 5. Navigation | ⚠️ Gap | Same open item as other Capture screens — no back/close control; depends on T-122 |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` component instance on all 5 screens, no overlap or duplication (duplicate bug from the scrolled-screen rebuild was caught and removed) |
| 7. Iconography | ⚠️ Unverified | Send icon and flame badges are not real SF Symbols/final assets for the small inline avatar use — same carried-over flag as other Capture screens |
| 8. VoiceOver | ⚠️ Deferred | Flag for SwiftUI build time |
| 9. Loading + Error States | — N/A for this scenario | This is the happy-path flow only; error/edge states are Scenarios 5–12 |
| 10. Color Tokens | ⚠️ Gap | Same carried-over gap as other Capture screens (card/bubble fill raw hex matching locked values, tokens not yet imported into this file) |

**iPhone device frame:** present on all 5 screens, same convention as the rest of P1.

### P1 Capture Onboarding — Scenario 2 (Guided Prompt Selection → Text), full flow screens 10–15 (dwelly-redesign file, nodes 43:258 / 43:297 / 43:343 / 43:391 / 43:431 / 43:489)

Content pulled from the real file's `dwelly-prompt-conversation` / `r2-text-appears` / `r2-dwelly-responds` / `r2-conversation-flow` / `r2-conversation-scrolled` / `CTA-5 — Rich Journal Preview` frames (Scenario 2 section). The journal preview uses new scenario-appropriate content ("Stillness on the Walk" / Psalm 46:10) rather than reusing Scenario 1's "A Conversation with Mom" copy verbatim, which the original file does (a shared placeholder mockup there, not scenario-specific) — kept each scenario's payoff matched to its own conversation.

**Real finding carried forward:** the original design includes a **"Done"** control (top-right, gold text) on every active-conversation screen — this resolves part of the open T-122 navigation gap flagged on Scenarios 1/3/4's screens. Added here as a 60×44 hit zone. **Action item:** retrofit this same "Done" control onto Scenario 1's screens 05–09 (built before this was discovered) and Screen 4 (Dwelly Prompt), which currently only have the non-interactive flame badge.

**Bug caught during build (same root cause as Scenario 1):** the first journal-preview attempt stacked all 4 prior conversation messages before the journal card, pushing the card past the frame's bottom edge (clipped, invisible). Fixed by showing only the closing message before the card — matches how a real scrollable chat view would auto-scroll to the newest content, not an arbitrary trim.

**Correction (Oct 8, 2026, second pass):** Kell caught that message bubble text wasn't properly sized to its content across both Scenario 1 and 2 — bubbles were either clipping text or leaving odd gaps between messages ("staggered," "weird spacing"). Root cause: bubble text used a hand-estimated height formula (`chars÷34×21`) instead of letting Figma measure the real wrapped height, because an earlier attempt at proper auto-resize (`textAutoResize: 'HEIGHT'` + `layoutSizingHorizontal: 'FILL'`) had gotten stuck at a stale value and the estimate was a workaround for that, not a real fix. Found the correct recipe via isolated test: call `resize(fixedWidth, *)` while the text node is still in its **default** auto-resize mode (before switching to `'HEIGHT'` or setting `FILL`) — this correctly wraps and computes real height immediately (verified 21px natural → 63px wrapped for a 3-line message), and the computed height survives being placed in an auto-layout bubble with `FILL` applied afterward. Re-applied this recipe to every bubble across Scenario 1 (screens 05–09) and Scenario 2 (screens 10–15), reflowed each screen's bubble stack to the corrected heights, and repositioned both journal cards (09, 15) to sit correctly below the reflowed content — Screen 09's card had drifted 3px past the frame's bottom edge once real (larger) heights were applied, since it still showed all 4 prior messages; fixed the same way as Screen 15 (show only the closing message before the card).

**Correction (Oct 8, 2026, third pass):** Kell shared the real old design's back-and-forth pattern — a small circular avatar + plain "Dwelly" text label touching the bubble was wrong; the real pattern uses a standalone gold-bordered pill badge ("• DWELLY", dot + uppercase label) as a clear turn marker, with real vertical breathing room between turns, not bubbles "directly paralleled" against each other. Replaced the avatar/label pattern with the pill badge across all 10 conversation screens (Scenario 1: 06–09; Scenario 2: 10–15), increased the gap before each new Dwelly turn (16px) and after every bubble (28px, up from 20px), and reflowed all bubble/badge/journal-card positions accordingly. Hit one follow-on bug: the badge's "DWELLY" label initially wrapped to two lines ("DWE/LLY") because its width was hardcoded too narrow — fixed by switching the label to `WIDTH_AND_HEIGHT` auto-resize so it sizes to its own text naturally, same underlying lesson as the bubble-height bug above (let Figma measure text, don't hand-estimate dimensions).

**Correction (Oct 8, 2026, fourth pass — exact copy from the real design):** Kell asked to literally copy the old design's message formatting rather than approximate it. Read the real `r1-dwelly-responds` frame's full node tree directly (fills, strokes, corner radii, padding, font sizes, exact positions) instead of eyeballing from a screenshot. Real differences from what had been built: user bubbles use a warm brown-tinted fill `#2E281C` (not the dark-neutral-with-gold-border style used before) and **no border at all**; Dwelly bubbles use a subtle **neutral gray border** `#2C2C2E` (not gold); the DWELLY badge is much smaller and subtler than the rebuilt version (69×18px pill, 8px bold text, 4px dot, not the larger bold badge from the third pass); body text is **13px**, not 15px; bubbles are a **fixed 290px width** (not hug-content); screen margins are **24px**, not 28px; and the input bar ends in a **mic button** (circular, gold mic glyph), not an upward-arrow send button, with the same neutral gray border as the Dwelly bubbles (not gold). Applied all of this exactly across all 11 conversation/entry screens (05, 06–09, 10–15) and reflowed every bubble/badge/journal-card position to the corrected 24px-margin, 290px-width geometry. The mic icon is a text-glyph approximation (`●`), not a real asset — flagged alongside the existing send-icon SF Symbol gap below.

**Correction (Oct 8, 2026, fifth pass):** Two issues from Kell. (1) The send/mic button was gold/active regardless of whether the field actually had content — Screen 2's button in particular was a full gold circle even with only placeholder text showing. Fixed: button glyph is now muted gray by default across every screen currently showing placeholder (empty) text, and stays gold only where real typed content exists (Screen 2a, which already had this right). This is a state Figma can only mock statically — the real behavior (toggling live as the user types) is a SwiftUI implementation detail, not something this static mockup can demonstrate; noted here so it isn't lost before implementation. (2) User and Dwelly bubbles read too similarly — brightened the user bubble to a more saturated brown (`#734F29`, confirmed ≥6:1 contrast with white text) while leaving Dwelly's neutral gray bubble unchanged, so the color contrast itself carries the speaker distinction. Applied to all 10 user bubbles across both scenarios for consistency, not just the one screen flagged.

**Correction (Oct 8, 2026, sixth pass):** Two gaps Kell caught with screenshots. (1) Screen 4 (Dwelly Prompt → Typed Response) had never been touched by any of the styling passes above — it still had the original avatar-circle + plain-text label and the old locked-border bubble color, visibly inconsistent with every other screen. Rebuilt to match: small pill badge, neutral-bordered bubble, 290px width, 13px text. (2) The "muted when empty" fix only changed the send/mic button's glyph color — the input pill's **border** was still gold regardless of content on every screen, which is what Kell's screenshots were actually showing. Fixed: all 12 empty-state input pills (Screen 2, Screens 05–09, 10–15, Screen 4) now use the same neutral border as the message bubbles, gold reserved only for the one screen with real typed content (2a) — verified that one was correctly left untouched.

**Correction (Oct 8, 2026, seventh pass):** Kell asked for a cleaner pattern than a grayed-out button — remove the mic/send button (circle + glyph) entirely when the field has no text, not just mute its color. Removed it from all 11 empty-state input pills; only Screen 2a (real typed content) keeps a visible button. **Open question for Kell:** this changes the tap target story for Section 1 of this checklist — an empty field now has no visible affordance to trigger send/voice input at all (relying on the keyboard's own return key, matching the "Tap return when you are finished writing" pattern already used elsewhere). Worth confirming this is the intended interaction model before implementation, not just a visual preference.

**Correction (Oct 8, 2026, eighth pass):** Kell didn't like the brown and asked for gold instead. A literal accent-gold fill (`#C9B27A`, light) would fail contrast with white message text — the same WCAG failure already documented and locked against for gold CTA buttons (T-246, white-on-gold = 2.06:1). Used a deep, muted gold instead (`#594B1F`, same hue family as the accent gold but dark enough to host white text at ~7.9:1), applied to all 10 user bubbles across both scenarios.

**Correction (Oct 8, 2026, ninth pass):** Kell specified an exact color, `#AA925C`. Flagged before applying: at this lightness, white text only hits ~2.7:1 (fails WCAG AA), the same pattern as the already-locked T-246 gold-CTA finding. Applied the exact color with **dark text** instead (`#0A0A0A`, ~6.6:1, passes) rather than silently keeping white text at a failing ratio. Locked as the final user-bubble color across all 10 instances.

**Correction (Oct 8, 2026, tenth pass):** Two more from Kell. (1) "Done" should never appear during onboarding — only post-onboarding Capture gets an exit control. This actually resolves the open T-122 navigation gap flagged repeatedly above: it was never a missing feature, these screens simply shouldn't have had an exit affordance at all, matching the project's existing "no skip" onboarding convention (same principle already locked for Pillar 0). Removed the "Done" control from all 11 conversation screens, replaced with the non-interactive flame mark (consistent with Screens 2/2a/4's original treatment). The open Section 5 (Navigation) gap on every screen above is now resolved — not deferred. (2) Added a "Response X of 3" counter to the top of every conversation screen, telegraphing the guided 3-response structure during onboarding. **Honest scope gap:** both flows as built only reach 2 user turns before the journal payoff, not 3 — labels are accurate to what's built (max "Response 2 of 3"), not inflated. A third exchange needs to be added to each flow to actually fulfill the "3 responses" requirement; flagging rather than silently mislabeling.

**Scenario 3 retired (Oct 8, 2026):** Built as "Dwelly-Initiated" — Dwelly proactively opening the conversation with zero prior user action, no card tap, no typed input, nothing. Kell caught that this doesn't reflect how the real product works: Dwelly never initiates unprompted — it only ever responds to something the user already did. There are only **2** real topic-initiation scenarios, not 3:
1. **Scenario 1 (Provided Prompt)** — user taps a prompt card, Dwelly responds to that specific topic
2. **Scenario 2 (Own Reflection)** — user writes freely with no prompt, Dwelly responds to whatever they brought

Entire Scenario 3 row (screens 16–21, its row description box, and its prepended Transition + Capture Entry clones) removed from the `dwelly-redesign` file. The "Dwelly Prompt → Typed Response" concept from the original source file does not carry over as a distinct main scenario — it was a misreading of the source material, not a simplification of real product scope. Main scenario count is now **3**, renumbered to close the gap left by the removed scenario: **Scenario 1** (Provided Prompt), **Scenario 2** (Own Reflection), **Scenario 3** (Voice Recording Flow). Voice is an input-method variant of the same 2 initiation types above, not a third initiation type of its own — it layers onto either.

**Scenario 3 built (Oct 8, 2026), then corrected against the real source file:** First pass invented a "Recording in Progress" screen (large waveform, live timer, 56px gold stop button, "Listening..." label) without actually reading the real design — only its flat text content had been pulled earlier, not its node tree. Kell caught this ("you aren't even referencing the previous designs"). Pulled the real `dwelly-prompt-conversation` frame from the source file's Scenario 4 section in full detail and found the actual design has **no separate recording screen at all** — it goes straight from Dwelly's prompt into a compact transcribing indicator: a 346×64 pill card (gold border, small pulse dot, a 15-bar fading waveform — 8 gold bars fading to 7 neutral-gray bars — "Transcribing..." label inline) plus a "Loading your moment with God." subtitle below. Deleted the invented Recording screen and the first rough Transcribing attempt, rebuilt the real one in their place, and closed the resulting gap by shifting the 4 downstream screens left by one column. Also corrected the Dwelly-bubble width to the source's actual 280px (had been using 290px everywhere, a minor but real discrepancy — not yet reconciled across Scenarios 1/2/3's other bubbles). One bug caught during the rebuild: the waveform's container frame had Figma's default white fill never cleared, rendering as a white box behind the bars — fixed.

Flow after transcription rejoins the same conversation pattern as Scenarios 1/2 (content: a hymn-on-the-drive-home reflection, journal payoff "A Hymn on the Drive Home" / Psalm 23:3). Same "2 of 3 responses" and early-exit/Header-Done gaps as the other scenarios, flagged consistently — not yet resolved. **New gap:** the 280px vs 290px bubble-width discrepancy should be reconciled across all three scenarios' bubbles, not just Scenario 3's transcribing screen — not yet done.

**Correction (Oct 8, 2026):** Kell flagged that the Transcribing screen showed no actual transcribed content — just a loading indicator with nothing to read. First attempt added the text as a faded chat bubble near Dwelly's prompt, which was wrong on two counts (Kell: "text in transcription needs to live in the text field not message field," and the indicator shouldn't have moved up from its bottom-anchored position). Rebuilt correctly: the transcribed text now lives inside a single input-field-styled container (same pill visual language as every other screen's text input, not a chat bubble) anchored near the bottom with the established 15px home-indicator clearance, with the waveform + "Transcribing..." indicator shown inline beneath the text within that same field — matches live-dictation behavior where words appear directly in the input as they're transcribed.

**Locked (Oct 8, 2026): default empty-field state.** Kell confirmed via reference screenshot: every text field with no content shows a visible gold circular mic button (44×44, gold border), not a removed/blank state — the earlier "remove the button entirely when empty" instruction was specifically about the send/arrow button, not the mic affordance. Applied the mic button to all 15 empty text-input-pill instances across Capture Entry (all 3 scenario clones) and every resting conversation screen in Scenarios 1–3. First two attempts approximated the icon (a text dot, then hand-built rectangles) instead of using the real asset — Kell called this out directly. Found the actual mic icon in the old reference file (`mic-fixed` / `mic` Vector inside its input-bar components) and pulled its exact `vectorNetwork` path data, then recreated that precise vector — not an approximation — across all 15 buttons, along with the real button's exact fill (`#2A2A2D`) and gold border at 40% opacity (not full opacity, which is what every other gold border in this file uses). This is now the reference default state — next steps (per Kell) are the Recording state (✕ cancel / waveform / timer / stop) and Transcribing state, one at a time.

**Locked (Oct 8, 2026): Recording state.** Same approach as the mic icon — found the real screen in the reference file ("8 — Recording: Cancel + Stop," Scenario 12 section) instead of eyeballing Kell's screenshot, and pulled its exact `waveform-bar` spec: 346×64 pill (cornerRadius 28, gold border at full opacity — unlike the mic button's 40%), a 32×32 cancel button (`#2A2A2D` fill, muted "✕"), a small red recording-indicator dot (`#D95A4D`), a 15-bar fading waveform (8 gold → 7 neutral-gray, exact per-bar x/y/height from source), the "0:08" timer, and a 32×32 gold stop button with a 10×10 dark rounded-square icon. Built as a new screen inserted between "Dwelly Opens the Prompt" and "Transcribing" in Scenario 3's row (renumbered the row accordingly), anchored near the bottom at the established 15px home-indicator clearance. Verified against the reference screenshot — matches exactly.

**Correction (Oct 8, 2026):** Kell caught that the wrong recording-bar variant had been copied — the real file has more than one, and the one pulled (Scenario 12's "8 — Recording: Cancel + Stop") included a red recording-indicator dot that doesn't exist in the canonical version (`B-guided-prompt-home`'s recording state, in Scenario 2's section). Removed the dot and corrected the waveform's position/width (175px, not 155px, since it's no longer pushed over by the dot) and all 15 bar positions to the authoritative spec. Re-verified against the reference screenshot — now matches exactly, including the wider waveform.

**Correction (Oct 8, 2026):** Kell caught a real logic error — the Transcribing screen had been showing the full transcript text already sitting in the field while simultaneously saying "Transcribing...", which doesn't make sense (if it's still transcribing, the text isn't ready yet). This conflated two different states: the brief loading state (no text, just the indicator) and a later post-transcription review state (text visible, editable) that belongs on a separate screen. Rebuilt Transcribing as the clean loading-only state per the reference: 346×64 pill (dot + fading waveform + "Transcribing..." label), no text, with the "Loading your moment with God." caption as a separate line below it — not merged into one field. Also fixed the vertical spacing, which had drifted enough to overlap the home indicator (caption bottom now correctly 15px clear).

**Correction (Oct 8, 2026):** Kell clarified that when a user taps a prompt card, Dwelly's resulting line is sent as a real message, not just displayed as a floating header — it needs the same DWELLY badge every other sent message gets. Three screens in Scenario 3 (Dwelly Opens the Prompt, Recording, Transcribing) had the prompt bubble with no badge above it, inconsistent with every other conversation screen in the file. Added the badge to all three, repositioned each bubble 8px below it.

**Correction (Oct 8, 2026):** Kell flagged that the bottom bars/pills across screens sat at visibly different heights. Audited every `text-input-pill`, `waveform-bar`, and `loading-indicator-section` instance on the page: found 3 screens (25, 26, 27) with an input pill at the wrong height (56px instead of 60px, bottom edge 842 instead of 846) and the Transcribing screen's loading card sitting 24px too high (bottom edge 822). Fixed all to the same 846 bottom edge used everywhere else. This created a real physical constraint on the Transcribing screen specifically — its caption sits below the card (unlike every other screen's bottom element, which has nothing below it), and aligning the card to 846 only leaves 15px before the home indicator, not enough for the caption at its original 13px size. Shrunk the caption to 11px to fit cleanly (bottom edge exactly 861, flush with the home indicator, zero overlap) rather than leave the card misaligned to accommodate it. Also discovered and rebuilt the caption text node itself, which had gone missing from an earlier edit.

**Built (Oct 8, 2026): 4 new screens, transcript review/edit depth.** Kell asked for the degrees between "transcription finishes" and "message sent" — added screens 29–32 to Scenario 3's row, after Transcribing: (29) transcript lands in the field at rest, mic/send buttons visible, "Tap send or keep editing" caption; (30) editing with keyboard up, field at its normal compact height (clipped/scrollable); (31) field expanded to fill most of the screen for reviewing a long message, keyboard still up; (32) same expanded view, keyboard dismissed, final review before sending. Content is the real "driving home from work" paragraph pulled from the source file earlier in the session. Matches the established pattern throughout — no progress bar (per the locked Oct 8 decision), real status bar, DWELLY badge on the opening prompt, 280px bubble width, locked bubble/button colors — rather than copying the reference screenshots' visual details literally. **Redesign Principles audit (Oct 8, 2026):**

Kell flagged the gold border wrapping the editable text on Screens 29/30 and asked whether it actually aligns with Apple's HIG. It didn't: native iOS text-editing surfaces (Notes, Messages, Mail) never frame the whole editable area in an accent color while the keyboard is up — that reads as a decorative card, not an editable field, and fights the native-editing feel HIG expects. Removed the gold stroke from both fields; gold is now reserved for actual controls (send button, badges), not as a frame around text.

Running the audit surfaced a second, independent real finding: the mic/send buttons on Screen 29 were 36×36, below the 44×44 HIG minimum tap target (and unnamed, making them hard to identify) — fixed to 44×44 and named properly.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Fixed | Screen 29 mic/send buttons were 36×36 (fail) — fixed to 44×44. Screens 31/32 send button already 44×44. **Gap:** Screen 30 has no visible send button at all, relying solely on the keyboard's return key — inconsistent with 31/32, which keep a visible send affordance even with the keyboard up. Not yet resolved. |
| 2. Contrast | ✅ Pass | Transcript text (bright token) on card fill — same ~14.8:1 already verified for this fill/text pair elsewhere. Caption (gold) and placeholder text reuse already-verified combinations. |
| 3. Typography | ✅ Pass | Instrument Sans body text throughout, consistent with the project's conversational-screen convention |
| 4. Layout + Spacing | ✅ Fixed | Gold border removed from Screens 29/30's text fields — doesn't match Apple's native text-editing pattern (no decorative frame around editable text). Fill retained for visual grouping; stroke dropped entirely. |
| 5. Navigation | ⚠️ Gap | Same open item as other Scenario 3 screens — no back/close control; depends on T-122 |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` instance on all 4 screens |
| 7. Iconography | ⚠️ Unverified | Send icon remains a text glyph, same carried-over flag as other Capture screens |
| 8. VoiceOver | ⚠️ Deferred | Flag for SwiftUI build time |
| 9. Loading + Error States | — N/A | These are the happy-path edit/review states, not error states |
| 10. Color Tokens | ⚠️ Gap | Same carried-over gap as other Capture screens (fills raw hex matching locked values, tokens not yet imported into this file) |

**iPhone device frame:** present on all 4 screens.

**Width fix applied (Oct 8, 2026):** Resized every `dwelly-bubble` and `user-bubble` across Scenarios 1, 2, and 3 from 290px to the source-accurate 280px, repositioned user-bubbles' right-alignment accordingly, and reflowed all bubble/badge/journal-card Y positions to match. Surfaced and fixed significant pre-existing corruption discovered during this pass, unrelated to the width fix itself: Scenario 1's entire row (6 screens + labels) had been displaced to the wrong Y coordinate; its Transition+Capture Entry clones were missing entirely (with an orphaned duplicate pair sitting at the wrong position); Screen 09's (Scenario 2 journal) closing message and journal card had been deleted outright, with no clear cause; Screen 15's (Scenario 1 journal) content was likewise empty except for one unrecognized stray node (`dwelly-message-group`) not matching anything ever built. Root cause not fully identified — likely fallout from the earlier null-character string-corruption incident, whose cleanup only checked for truncated text, not missing/relocated nodes. Fixed Scenario 1's row position, rebuilt its missing Transition/Entry pair, removed the orphan duplicate, and rebuilt Screen 09's lost content. **Screen 15 (Scenario 1's journal payoff) is still broken as of this entry — content not yet rebuilt.**

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | Done hitzone 60×44, send buttons 44×44, journal footer hitzone 308×44 (built correctly from the start this time, applying the Scenario 1 gap finding) |
| 2. Contrast | ✅ Pass | Same verified token combinations reused throughout (bubble text 14.8:1, gold borders 8.75:1, muted-on-card 5.63:1, Done button gold text 9.59:1-equivalent) |
| 3. Typography | ✅ Pass (approved deviation) | Consistent with established pattern |
| 4. Layout + Spacing | ✅ Pass | Input bar 15px home-indicator clearance on screens 10–14; journal card fits fully within frame bounds on screen 15 (overflow bug fixed before sign-off, not after) |
| 5. Navigation | ✅ Fixed | Real "Done" control now present — resolves the gap flagged on earlier screens for this scenario specifically. Retrofit still owed to Scenario 1 (05–09) and Screen 4. |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` instance on all 6 screens |
| 7. Iconography | ⚠️ Unverified | Send icon / flame badges still not final SF Symbol assets, same carried-over flag |
| 8. VoiceOver | ⚠️ Deferred | Flag for SwiftUI build time |
| 9. Loading + Error States | — N/A for this scenario | Happy-path flow only |
| 10. Color Tokens | ⚠️ Gap | Same carried-over gap (raw hex matching locked token values, not yet imported into this file) |

**iPhone device frame:** present on all 6 screens.

### P1 Capture Onboarding — Screen 4: Dwelly Prompt → Typed Response (dwelly-redesign file, node 33:187 — renumbered from "Screen 3" after the slot mislabel above was caught and fixed)

Structurally differentiated from Screen 2 per the locked T-213 requirement (self-guided vs. Dwelly-prompted variants must not be pixel-identical reskins): SMS-style chat bubble with Dwelly's avatar and a specific, context-aware question, instead of the generic multi-topic card grid. Input bar position (y=786, 15px home-indicator clearance) matches the corrected Screen 2 convention from the start.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | Send button 44×44, input pill 346×60. Avatar (32×32) and flame brand mark (24×24) are non-interactive, exempt. |
| 2. Contrast | ✅ Pass | Bubble text (bright token) 14.8:1 vs bubble fill; sender label (muted token) 4.86:1 on page bg; bubble border (locked `border/input` #67677b) 3.27:1 vs bubble fill; placeholder (locked `text/placeholder` #8491a0) 5.63:1 vs input fill; gold border/send icon same as Screen 2. All pass. |
| 3. Typography | ✅ Pass (approved deviation) | Instrument Sans throughout (chat bubble is conversational, not a heading moment — no Serif needed here, consistent with how the app reserves Serif for headings only) |
| 4. Layout + Spacing | ✅ Pass | Input bar at y=786, 15px clearance above home indicator — built correctly from the start using the convention fixed on Screen 2 |
| 5. Navigation | ⚠️ Gap | Same open item as Screens 2/2a — no back/close control; depends on T-122 |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` component instance, no overlap |
| 7. Iconography | ⚠️ Unverified | Send icon still a text glyph, same flag as other Capture screens |
| 8. VoiceOver | ⚠️ Deferred | Flag for SwiftUI build time |
| 9. Loading + Error States | — N/A for this scenario | Resting entry state only |
| 10. Color Tokens | ⚠️ Gap | Same carried-over gap as Screens 2/2a (card/bubble/input fill raw hex matching locked values, tokens not yet imported into this file) |

**iPhone device frame:** present, same convention as Screens 1–2a.

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

### 03a — Account Creation (Check Your Email) (node 1086:378)

**Built Nov 4, 2026:** No Figma design existed for this state until now — the "pendingEmailConfirmation" outcome (this project requires email confirmation, confirmed Nov 4 2026) was built straight into SwiftUI with placeholder copy, with no design-complete sign-off. Built by cloning the existing "03c — Account Creation (Email Confirmed)" screen's device-frame/status-bar/icon-circle/CTA structure (same Button/CTA component, same `text/heading`/`text/supporting`-bound text) and swapping its checkmark glyph for an envelope icon + its copy for the check-email moment. No back button, matching that screen's precedent — this is a terminal/transitional state, not a decision screen.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | Button/CTA 346×60; no other interactive controls on this screen |
| 2. Contrast | ✅ Pass | Reuses the already-verified `text/heading` (on page bg) / `text/supporting` (on page bg) / dark-on-gold Button/CTA token combinations from the Email Confirmed screen — no new raw contrast pairs introduced |
| 3. Typography | ✅ Pass (approved deviation) | Instrument Serif heading / Instrument Sans subtitle + button, same type-system note as 01 |
| 4. Layout + Spacing | ✅ Pass | Subtitle at 28px margins (346pt width within 402pt frame); real status bar + home indicator, no safe-area overlap |
| 5. Navigation | — N/A | Terminal/transitional state (same as Email Confirmed) — no back control by design |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` component instance |
| 7. Iconography | ⚠️ Unverified | Envelope icon is a hand-built SVG, not a real SF Symbol (`envelope.fill`) — flag for swap at SwiftUI build time, same flag pattern as other screens' send/mic icons |
| 8. VoiceOver | ⚠️ Deferred | Same as 01 |
| 9. Loading + Error States | — N/A | This screen IS a static end-state, not a fetch |
| 10. Color Tokens | ✅ Pass | Reuses the Email Confirmed screen's already-token-bound Button/CTA instance and text styles — no raw hex introduced |

### 03c — Account Creation (Email Confirmed) (node 1066:355, previously "02c — Account Creation (Success)")

Built Nov 3, 2026 as the immediate post-signup success state, before the project's "Confirm email" setting was discovered to be on (confirmed Nov 4, 2026 — see 03a above). Re-purposed, unchanged, as the screen shown when the user taps the confirmation link (`dwelly://auth/confirm`) rather than immediately after signup — its copy ("You're in." / "Your account has been created...") still reads correctly for that trigger. No Figma changes needed; already passes this checklist (see the original Nov 3 sign-off this file never separately recorded — backfilled here for completeness): Tap Targets ✅ (CTA 346×60), Contrast ✅ (same token set as 03a above), Typography ✅ (approved deviation), Layout ✅, Navigation N/A (terminal state), Status Bar ✅, Iconography ⚠️ Unverified (checkmark is a hand-built SVG, not SF Symbol `checkmark.circle.fill`), VoiceOver ⚠️ Deferred, Loading/Error N/A, Color Tokens ✅.

### 03d — Account Creation (Email Already Exists) (node 1090:391)

**Built Nov 4, 2026:** Reverses the same-day anti-enumeration fix (see T-115 and `SupabaseAPIClient.signUp()`) at Kell's explicit direction — a duplicate-email signup now shows a real "this email already exists" screen instead of being masked behind the generic check-email flow. Cloned from 03a's structure (same device-frame/status-bar/icon-circle/CTA), person-icon glyph swapped in, plus a secondary "Use a different email" text link added below the CTA inside `action-footer` (not present on 03a/03c, since those have only one real next action).

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ⚠️ Gap | Button/CTA 346×60 ✅. The new "Use a different email" text link is 17pt tall with no 44×44 hit zone — same carried-over gap already flagged elsewhere in this doc (e.g. P1 Scenario 1's journal footer); needs the hitzone-wrap treatment before SwiftUI build |
| 2. Contrast | ✅ Pass | Reuses the already-verified `text/heading`/`text/supporting`/dark-on-gold Button/CTA combinations from 03a/03c; new secondary link uses the same accent-gold fill already verified for links elsewhere (e.g. "Sign In" link on 03) |
| 3. Typography | ✅ Pass (approved deviation) | Instrument Serif heading / Instrument Sans subtitle + button + link, same type-system note as 01 |
| 4. Layout + Spacing | ✅ Pass | Subtitle at 28px margins; secondary link centered 16px below CTA, within the existing 148pt-tall `action-footer` |
| 5. Navigation | — N/A | Terminal/decision state — CTA and secondary link are this screen's two exits, not a back-navigable step |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` component instance |
| 7. Iconography | ⚠️ Unverified | Person icon is a hand-built SVG, not a real SF Symbol (`person.crop.circle`) — flag for swap at SwiftUI build time |
| 8. VoiceOver | ⚠️ Deferred | Same as 01 |
| 9. Loading + Error States | — N/A | This screen IS the error state for the duplicate-email case |
| 10. Color Tokens | ✅ Pass | Reuses already-token-bound Button/CTA instance and text styles; new link fill matches the existing accent-gold value, not a new raw hex |

### Returning User Login (node 974:3709)

**Backfilled Nov 4, 2026** — T-256 (Nov 4) verified this screen's visual parity against Figma but never ran this checklist against the actual SwiftUI code; doing that now surfaced real gaps, fixed same day: password field had no `textContentType(.password)` (Keychain's saved-password AutoFill suggestion wasn't wired up, same root-cause bug already fixed on Account Creation's password fields), the back button and eye-toggle had no accessibility labels, and "Forgot password?" / "Don't have an account? Get Started" were bare `Text + onTapGesture` — not real buttons, no VoiceOver trait, no 44×44 hit area. All fixed in `LoginView.swift`.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Fixed | Back button, eye-toggle, Login/Face ID buttons already 44×44+. "Forgot password?" and "Don't have an account?" were plain tappable text with no real hit area — wrapped in real `Button`s with `.frame(minHeight: 44)` |
| 2. Contrast | ✅ Pass | Reuses the same token-bound text/CTA colors already verified on Account Creation (shared styling) |
| 3. Typography | ✅ Pass (approved deviation) | Same type-system note as 01 |
| 4. Layout + Spacing | ✅ Pass | 28px horizontal padding consistent |
| 5. Navigation | ✅ Pass | Back button present, 44×44 |
| 6. Status Bar | ✅ Pass | Real component instance |
| 7. Iconography | ⚠️ Unverified | Back chevron and eye-toggle are SF Symbols (`chevron.left`, `eye`/`eye.slash`) — real symbols, not image assets, so this is lower-risk than Account Creation's equivalent flag, but glyph-level contrast still not independently verified |
| 8. VoiceOver | ✅ Fixed | Was: zero accessibility labels on any icon-only control. Fixed: Back, Password field, Show/Hide password toggle, and both tappable text rows now carry explicit `accessibilityLabel`s |
| 9. Loading + Error States | ✅ Pass | Loading spinner on Login button; inline error text for wrong credentials (`authManager.errorMessage`) |
| 10. Color Tokens | ✅ Pass | Reuses already-bound tokens, no raw hex introduced |

### Forgot Password (node 1062:247, now on the dedicated 🔑 Sign In (Pillar) Figma page)

**Backfilled Nov 4, 2026.** No Figma design existed for this screen until T-263 built it from the spec (`docs/PILLAR_AUTHENTICATION_STRATEGY.md` §6); running this checklist against it now surfaced real gaps, fixed same day: the "Send Reset Link" button only checked the email field wasn't empty — no format validation at all, inconsistent with the `something@something.something` rule locked for Account Creation the same day — and the back button / email field had no accessibility labels. All fixed in `ForgotPasswordView.swift`. Already correct before this pass: the success copy ("If an account exists for X, we've sent a link...") is the anti-enumeration pattern done right — deliberately kept generic regardless of whether the email has an account, unlike Account Creation's duplicate-email case which Kell explicitly chose to make explicit instead. Moved (reparented, same node IDs) from the Account Creation Figma page to the new dedicated 🔑 Sign In (Pillar) page Nov 4, 2026 — Login, Forgot Password, and the net-new Create New Password / Password Reset screens below are now a real, self-contained Figma pillar (T-265).

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | Back button 44×44, Send/Back-to-Log-In CTA 346×60 |
| 2. Contrast | ✅ Pass | Reuses the same token-bound text/CTA colors already verified elsewhere |
| 3. Typography | ✅ Pass (approved deviation) | Same type-system note as 01 |
| 4. Layout + Spacing | ✅ Pass | 28px horizontal padding consistent |
| 5. Navigation | ✅ Pass | Back button present, 44×44 |
| 6. Status Bar | — N/A | This screen has no status-bar component built into its SwiftUI layout (relies on the real device status bar, same as every screen) |
| 7. Iconography | ✅ Pass | Back chevron is a real SF Symbol (`chevron.left`) |
| 8. VoiceOver | ✅ Fixed | Was: zero accessibility labels. Fixed: Back and Email now carry explicit `accessibilityLabel`s |
| 9. Loading + Error States | ✅ Pass | Loading spinner on Send button; inline error text; success state swaps copy + CTA in place |
| 10. Color Tokens | ✅ Pass | Reuses already-bound tokens |

### New Password Entry — Create New Password (node 1101:256) + Password Reset Success (node 1101:300), 🔑 Sign In (Pillar) Figma page

**Backfilled Nov 4, 2026.** Built by T-263 from `docs/PILLAR_AUTHENTICATION_STRATEGY.md` §6 ("New Password Entry"), with no Figma frame at all until this pass — not even a placeholder. Running this checklist surfaced one real code gap: the password/confirm-password fields and the eye-toggle button had no accessibility labels (only a visible field-label `Text` above each, not linked to the actual input for VoiceOver). Fixed in `NewPasswordView.swift`. Password rule already correctly matched T-248 in code (8+ chars, upper+lower, number — no symbol) via the shared `PasswordStrength` type — but building the matching Figma design surfaced that the **Figma source** strength-checklist component still showed a 4th "A symbol" row, stale since before T-248 locked the 3-requirement rule. Fixed at the source (all 4 instances across the file, including Account Creation's own keyboard-state frames, which had the same stale row).

Design built by cloning Forgot Password's bezel/status-bar/title structure (back button and email field removed, two password fields + the corrected strength-checklist added) for the resting state, and cloning Account Creation's existing success screen (icon circle + title + subtitle + CTA, copy swapped to "Password reset" / "Your password has been changed. You're signed in.") for the success state — same componentized pattern as 03a/03c/03d on the Account Creation page.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | Eye-toggle 44×44, Reset/Back-to-Log-In CTA 346×60, "Cancel" is a real `Button` |
| 2. Contrast | ✅ Pass | Reuses already-verified token combinations |
| 3. Typography | ✅ Pass (approved deviation) | Same type-system note as 01 |
| 4. Layout + Spacing | ✅ Pass | 28px horizontal padding consistent |
| 5. Navigation | — N/A | No back button by design — "Cancel" is this screen's exit, since it's reached via deep link, not forward navigation |
| 6. Status Bar | — N/A | Same as Forgot Password — relies on the real device status bar |
| 7. Iconography | ✅ Pass | Eye-toggle is a real SF Symbol (`eye`/`eye.slash`) |
| 8. VoiceOver | ✅ Fixed | Was: password fields and eye-toggle had no accessibility labels. Fixed: New Password, Confirm Password, and Show/Hide password toggle now all carry explicit labels |
| 9. Loading + Error States | ✅ Pass | Loading spinner on submit; inline "Passwords don't match." and server-error text; success state swaps copy + CTA in place |
| 10. Color Tokens | ✅ Pass | Reuses already-bound tokens |

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

### Screens 29–32 — Scenario 3 transcript-editing states, revision 2 (October 8, 2026)

**Context:** First pass (same day, earlier) removed a gold border around the editing text field after confirming it didn't match any real Apple text-editing convention. Kell's follow-up review caught that this had overcorrected — real iOS keeps a subtle hairline divider above the keyboard (the `inputAccessoryView` boundary), and two further gaps: Screen 29's mic/send controls were blank unlabeled circles with no glyphs (root cause of "I don't know what that even is"), and there was no way to expand/collapse between the compact (30) and full (31) editing states.

**Principle established this pass:** The hairline divider is tied to keyboard presence, not to "is this a text editor" generally — it's physically the top edge of the keyboard's accessory view, so it only exists while the system keyboard is on screen. Screens 29 and 32 (keyboard dismissed) correctly have no hairline; Screens 30 and 31 (keyboard shown) now do. This is a real Apple pattern (`UITextView.inputAccessoryView`), not an invented one — no separate HIG/WCAG document specifically governs "text editor borders" or "expand controls" the way it does contrast or tap targets; the closest real precedent is this accessory-view boundary, which is what was referenced.

| Screen | Section | Pass / Fail | Notes |
|---|---|---|---|
| 29 — Transcript in Field | 1. Tap Targets | ✅ Fixed | mic-button + send-button were already 44×44 from the prior pass; this pass added the missing glyphs inside them (real mic vector cloned from reference file node `1026:9750`, "↑" glyph matching 31/32's send icon) — previously both were blank circles with no icon, which was the actual source of "I don't know what that even is" |
| 29 | 3. Typography / Clarity | ✅ Fixed | Caption below the field changed to "Keep adding by voice, or tap send to finish." — ties directly to the two now-visible icons instead of a generic instruction |
| 29 | Keyboard state | ✅ Pass | No keyboard shown → correctly no accessory hairline |
| 30 — Editing (Collapsed) | 1. Tap Targets | ✅ Added | New expand-button (44×44, chevron-up glyph) + mic-button (44×44, real mic vector) in a new accessory row docked to the field's bottom edge |
| 30 | Keyboard state | ✅ Fixed | Added 1px hairline (white @ 12% opacity) at the top of the field, directly matching the real iOS input-accessory-view boundary that appears above the keyboard. Confirmed no send button here — correct, since collapsing/continuing to talk isn't a send action |
| 30 | Build note | — | Field frame (`98:532`) is Auto Layout (`VERTICAL`) — the new hairline/accessory-row children had to be set to `layoutPositioning = 'ABSOLUTE'` after `appendChild`, otherwise the auto-layout stack pushed them below the frame's fixed height and `clipsContent` silently hid them. Caught via screenshot diff, not visible from metadata alone. |
| 31 — Editing (Expanded) | 1. Tap Targets | ✅ Fixed | Floating text + floating send button (no container at all) replaced with a real `transcript-field-expanded` container frame, matching the field pattern used elsewhere. Added collapse-button (44×44, chevron-down) next to the existing send-button |
| 31 | Keyboard state | ✅ Fixed | Same 1px hairline added at container top (keyboard is shown here too) |
| 31 | Mic button | ✅ Pass (by design) | No mic in this state — per Kell's rule, voice input is only available until the editor is fully expanded; once expanded it's keyboard/text-only |
| 32 — Review (No Keyboard) | Keyboard state | ✅ Pass, unchanged | No keyboard, no hairline, no mic, send-only — already matched the same rule before this pass; left as-is |

**Open items carried forward:**
- Expand/collapse chevron glyphs (`⌃` / `⌄`) are text-rendered Unicode glyphs matching the existing send-button's `↑` text-glyph technique used elsewhere in this flow — not a Figma vector icon. Consistent with current file convention but worth promoting to real vector icons if/when an icon set is formalized.
- VoiceOver labels for mic/expand/collapse controls not expressible in Figma — needs SwiftUI-side accessibility labels at build time (same deferral as other screens in this doc).

### Screens 29–32 — Scenario 3 transcript-editing states, revision 3 (October 8, 2026)

**Context:** Revision 2 (above) used a hairline-only divider tied to keyboard presence, reasoned from general `inputAccessoryView` convention since no literal Dwelly reference existed for this control. Kell then supplied an actual screenshot and pointed at the real source: the old reference file (`t5MUGEtpeFcUixobvHiYMc`) already contains a fully-specified `text-field-box` component at nodes `1026:11509` (collapsed/mic variant) and `1026:11644` (expanded/no-mic variant), complete with `expand-icon` (`1026:11489`) and `collapse-icon` (`1026:11656`) assets. Revision 2's hairline-divider theory is superseded — this is the real, previously-built spec and takes priority.

**Exact spec pulled from reference (not invented):**
- Card: `cornerRadius 24`, gold stroke `{0.788, 0.659, 0.298}` at full opacity, `strokeWeight 1.5`, fill `#161619`
- Content padding 16px; mic + send sit together in a flush-right cluster at the bottom (`mic-button` dark fill + gold stroke @ 40% opacity, `send-button` solid gold) — both 44×44
- A 14×14 neutral-gray corner icon (`expand-icon` on the collapsed/mic variant, `collapse-icon` on the expanded/no-mic variant) sits inset top-right, built from 4 small rounded rectangles forming two L-shaped marks — not a circular button, just the glyph
- Confirmed directly from the reference's two variants: the collapsed state (`1026:11509`) has mic+send together; the expanded state (`1026:11644`) has send only, no mic — this is the real source for the "mic disappears once fully expanded" rule, not a freehanded one

| Screen | Change | Notes |
|---|---|---|
| 29 — Transcript in Field | No further change | Kell is removing this screen from the flow directly — not a design gap, intentionally dropped |
| 30 — Editing (Collapsed) | ✅ Rebuilt | Replaced the hairline-only field from revision 2 with the real `text-field-box` pattern: gold border, mic+send flush bottom-right, `expand-icon` top-right corner |
| 31 — Editing (Expanded) | ✅ Rebuilt | Same card treatment; send-only flush bottom-right (no mic, matches the real reference's expanded variant), `collapse-icon` top-right corner |
| 32 — Review (No Keyboard) | Unchanged | Not addressed this pass |

**Build note:** Screen 30's field frame (`98:532`) had to have `layoutMode` switched from `VERTICAL` (Auto Layout) to `NONE` to take manual control of the card's internal positions — the auto-layout stacking from the prior pass was the root cause of elements getting clipped out of view.

### Screens 30–31 — Scenario 3 text-editor internal layout, revision 4 (October 8, 2026)

**Context:** Revision 3 pulled the right border/button spec from the old reference file, but kept the mic+send cluster floating beside the last line of text (inherited from the reference's `action-buttons` positioning). Kell flagged this reads wrong — text should never share a row with the controls. He pointed to ChatGPT's composer as the concrete pattern to match: full-width text block at top, a divider line, then a dedicated control row below, full width, not hugging the right edge of the text.

| Screen | Change |
|---|---|
| 30 — Editing (Collapsed) | Text now spans the field's full padded width (was artificially narrowed to 226px to dodge the buttons). Added a `text-controls-divider` hairline between the text block and the control row. Mic + send moved into their own row below the divider instead of floating at the same vertical band as the last visible line of text. |
| 31 — Editing (Expanded) | Same divider + dedicated row treatment; send-button now sits in its own row below the text block rather than beside it. |

**Build note — text clipping:** Setting a `TEXT` node's `resize(w, h)` with `textAutoResize = 'NONE'` does **not** visually crop overflow to that box; a parent frame's `clipsContent` only clips at the parent frame's own edge, not at the text node's smaller bounding box. Screen 30's collapsed preview (meant to show ~2 lines before the divider) was overflowing into the control row as a result. Fixed by giving the text its own dedicated `text-clip` wrapper frame (`clipsContent: true`, sized to the visible preview height) between the field and the text node, and reverting the text itself to natural `textAutoResize = 'HEIGHT'` so it lays out normally and lets the wrapper do the cropping.

### Screens 30–31 — mic/send clustering and corner-icon overlap, revision 5 (October 8, 2026)

| Fix | Detail |
|---|---|
| Mic + send re-clustered (Screen 30) | Revision 4 split mic (left) and send (right) to opposite ends of the control row. Kell corrected this — they should be juxtaposed (adjacent to each other) at a fixed flush-right position, matching the original reference's `action-buttons` cluster, just relocated into the dedicated row below the divider instead of floating beside text. |
| Text no longer overlaps corner icon (30 + 31) | The `expand-icon`/`collapse-icon` sits inset top-right (`x = width-14-15`); text was running under it. Added a ~44px right clearance to the text block/clip-wrapper width on both screens so wrapping now stops short of the icon instead of running underneath it. |

### Screen 28 — journal-preview entry point rebuilt to match established pattern (October 8, 2026)

**Problem:** Screen 28 ("Scenario 3: Rich Journal Preview") used a one-off `journal-card` built standalone on the screen — full-width (354px), cool dark-gray fill, gold border, floating with no connection to the conversation. Kell's reference screenshot showed the correct pattern already exists elsewhere in the file (Scenario 1's screen 15 and Scenario 2's screen 9): the journal preview renders as a card nested *inside* the same Dwelly chat bubble as the lead-in message ("Let's add this to your journal..."), not as a disconnected card — i.e. it's the actual entry point within the messaging conversation, not a separate screen element.

**Fix:** Deleted Screen 28's standalone `journal-card` (`68:516`), its separate `dwelly-badge` (`68:511`), and its separate lead-in `dwelly-bubble` (`68:514`). Cloned the correct, already-built `dwelly-message-group` pattern from Scenario 1 (node `55:702`) — which includes its own DWELLY label, the lead-in bubble, and the `journal-preview-card` nested inside that same bubble — and retargeted its text to Scenario 3's content (date, title, body, scripture quote). This is the same component used correctly on screens 9 and 15; Screen 28 now matches it instead of diverging with its own invented card style.

**Scope note:** This pass only touched Screen 28. The underlying `journal-card` variant it replaced may exist elsewhere in the file if other Scenario 3 screens reference it — not checked this pass, flag if it turns up again.

### Screens 30–31 — gold border swapped for a soft neutral line, revision 6 (October 8, 2026)

Revision 3 pulled a solid gold stroke from the old reference file's `text-field-box` component. Kell corrected this — the border reads too bright/attention-grabbing; it should be a quiet separation cue, not an accent-colored frame. Changed `strokes` on both `98:532` (Screen 30) and `105:468` (Screen 31) from gold (`{0.788, 0.659, 0.298}`, opacity 1, weight 1.5) to a soft neutral line (white, opacity 0.12, weight 1) — same treatment already used for the internal text/controls divider, so the whole card now reads as one consistent, quiet line-weight rather than mixing a loud accent border with a subtle internal divider.

### Screen 31 — orphaned divider removed, collapse icon made legible, revision 7 (October 8, 2026)

| Fix | Detail |
|---|---|
| Divider removed (Screen 31 only) | The text/controls divider works on Screen 30 because it sits snug against both the text and the button row. On Screen 31 there's ~130px of empty space between the end of the text and the divider, and more empty space below it before the button — with that much dead space around it, the line read as a stray floating mark rather than a meaningful boundary. Removed it from `105:468`. Screen 30 keeps its divider — it's still functioning correctly there. |
| Collapse icon enlarged | `collapse-icon` was 14×14 at gray `{0.65,0.65,0.65}` — correct geometry (the real two-L-corner-mark asset from the reference file) but unreadable at that size against a near-black background; Kell didn't register it as a control at all. Rebuilt at 20×20, gray `{0.78,0.78,0.78}`, same position convention (top-right inset). Confirmed via zoomed screenshot that the mark itself renders correctly — the fix was scale/contrast, not the icon design. |

### Open items carried forward (not fixed this pass — need a decision or can't be verified from Figma)

- Icon-only back-button and eye-toggle glyph contrast (03, 04, 05, 06) — rendered as image assets, not computable from exported code. Needs a visual spot-check.
- Checkmark glyph contrast on Screen 07's circle icons — same limitation.
- VoiceOver accessibility labels/traits — none of this is expressible in Figma; must be implemented and verified at SwiftUI build time (T-110 build ticket), not blocked in design.
- Screen 02 (Intro Video) is still undesigned — this checklist will need to run against it once built.

### P1 Capture Onboarding — E1: Mic Permission Denied (Mid-Conversation) (dwelly-redesign file, node 183:511)

Content and interaction model pulled from the real reference file's archived edge-case page (`t5MUGEtpeFcUixobvHiYMc`, page "P1 — Error States & Edge Cases," node `1113:410`), not invented: this triggers only after mic access was previously denied (iOS won't re-prompt), falls back to text immediately, with the Settings link secondary and never blocking. Built as a scrim + modal overlay on top of a cloned Scenario 1 conversation screen (`43:343`), using this file's locked tokens rather than the reference's raw hex.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | `cancel-hitzone` / `open-settings-hitzone` 151×44 each (verified via `get_metadata`, not eyeballed). Icon badge (48×48) is decorative/non-interactive, exempt. |
| 2. Contrast | ✅ Pass | Computed against actual adjacent fills (not eyeballed): heading (`text/primary`) 14.77:1 vs modal fill (`surface/card`); body (`text/secondary`) 7.15:1 vs modal fill; Cancel (`text/secondary`) 7.15:1; Open Settings (`accent/gold`) 8.75:1; mic-off glyph (`state/error`) 3.62:1 vs icon-badge fill (`surface/icon-button`) — all pass their respective 4.5:1/3:1 thresholds. |
| 3. Typography | ⚠️ Gap (flagged, not fixed) | Heading bound to `Body/Emphasis` (15px Medium) as the closest existing style — no style in the 13-item type scale is a true "alert title" semantic. Body bound to `Caption/Note` (fits — that style's defined role already covers "secondary notes"). Cancel → `Body/Small`, Open Settings → `Link/Inline` (bold signals tappable, matches that style's own defined role) — both exact semantic fits, no gap there. |
| 4. Layout + Spacing | ✅ Pass | Modal is an auto-layout column (fixed 302 width, hug height), centered horizontally, vertically biased slightly above center matching the reference. Internal button row verified 151+1(divider)+151=302, no overlap. |
| 5. Navigation | — N/A | Modal is itself the "way back" (Cancel dismisses, Open Settings resolves) — this is the correct pattern for a blocking permission state, not a gap. |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` instance retained from the cloned base screen, no overlap with the scrim/modal. |
| 7. Iconography | ⚠️ Unverified | Mic-off glyph is a hand-built SVG approximation of `mic.slash` (imported via `createNodeFromSvg`, not reconstructed from rotated primitives — follows the required icon-import path), not pulled from the real SF Symbol — flag for swap at SwiftUI build time, same carried-over flag pattern as other screens' send/back icons. |
| 8. VoiceOver | ⚠️ Deferred | Flag for SwiftUI build time. Note for build: the modal should be presented as a real system alert or a modal with `.accessibilityAddTraits(.isModal)` so VoiceOver doesn't let focus leak to the dimmed conversation behind it. |
| 9. Loading + Error States | ✅ Pass | This screen **is** the error state — plain-language message ("Dwelly needs microphone access to keep listening"), user-actionable (Open Settings), no raw system error text exposed. |
| 10. Color Tokens | ✅ Pass | All fills/strokes bound to `Dwelly/Colors` variables (`surface/card`, `surface/icon-button`, `text/primary`, `text/secondary`, `accent/gold`, `state/error`) — no raw hex except the two internal divider lines, which follow the established "soft neutral line" convention (white @ 12% opacity) locked for dividers elsewhere in this file (Screens 30/31), not a token gap. |

**Cross-cutting fix made during this pass (not scoped to this screen alone):** `Icon/Cancel-Button` and `Icon/Stop-Button` master components were found at 32×32 — below the 44×44 HIG minimum (Section 1) — and used identically on the already-built "23 — Scenario 3: Recording (Cancel + Stop)" screen. Resized both masters to 44×44 at the component level so the fix cascades to every instance (3 total: the original Recording screen's cancel+stop, and this file's own cancel button), repositioned each instance to preserve the bar's existing 20px edge padding and vertical centering. Re-screenshotted the original Recording screen after the fix to confirm no regression — confirmed clean, no overlap with the waveform/timer.

**iPhone device frame:** present, same convention as the rest of P1.

### P1 Capture Onboarding — E2: Didn't Catch That (dwelly-redesign file, node 183:539)

Content and interaction model pulled from the real reference file's archived edge-case page (same source page as E1, node `1113:1139` "2-Full-d — Didn't Catch That"): recording completed but transcription came back empty, detected after the fact only — never a real-time "still there?" interruption. Built from a clone of the already-locked "23 — Scenario 3: Recording (Cancel + Stop)" waveform-bar spec (`90:469`) rather than inventing a new bar treatment, swapping the live waveform + timer for a retry message and swapping the Stop button for the Mic button (nothing is actively recording, so Stop doesn't apply — Mic re-invites the retry, consistent with this file's locked default-empty-state mic affordance).

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | Cancel 44×44 (post cross-cutting fix above), Mic 44×44 (real `Icon/Mic-Button` instance, not approximated) — both verified via `get_metadata`. |
| 2. Contrast | ✅ Pass | Computed against actual adjacent fills: retry message (`text/primary`) 14.82:1 vs bar fill; encouragement caption (`text/muted-warm`) 4.70:1 vs page bg (`background/primary`) — both pass 4.5:1. |
| 3. Typography | ✅ Pass | Retry message bound to `Body/Secondary`; caption bound to `Caption/Note` (exact semantic fit — "secondary notes," its own defined role). |
| 4. Layout + Spacing | ✅ Fixed | Bar moved from y=782 to y=758 to make room for the new caption below it (caption bottom at y=845, home indicator at y=861 → 16px clearance, matching this file's established ~15px bottom-safe-area convention rather than the raw 24pt/34pt Apple minimum). Retry message repositioned (x=72, was briefly x=62) after the cross-cutting Cancel-button resize to clear the enlarged button with an 8px gap, not overlapping. |
| 5. Navigation | ⚠️ Gap (carried over) | Same open item as other Capture/Scenario 3 screens — no back/close control beyond the bar's own Cancel; depends on T-122, not resolved by this screen. |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` instance retained from the cloned base screen. |
| 7. Iconography | ⚠️ Unverified | Mic/Cancel icons are the file's real established components (not new approximations) — carries the same "swap for real SF Symbol at SwiftUI build time" flag already noted on those components elsewhere in this doc. |
| 8. VoiceOver | ⚠️ Deferred | Flag for SwiftUI build time. |
| 9. Loading + Error States | ✅ Pass | This screen **is** the error state — plain-language message ("Didn't catch that — try again"), user-actionable (tap mic to retry), no raw transcription-service error exposed. |
| 10. Color Tokens | ⚠️ Gap (carried over) | Bar fill is raw hex matching the locked `surface/card`-equivalent value, not yet bound — same carried-over gap already documented on every other Capture/Scenario 3 screen in this file (tokens not yet imported into this file's full scope at the bar level). New text additions (retry message, caption) are correctly bound to `Dwelly/Colors` variables. |

**Correction (October 13, 2026):** Kell flagged the bar's internal composition as visually sloppy after reviewing it live in Figma. Root cause found: the cancel/message/mic children were placed with manually-eyeballed absolute x/y math (matching the original reference screen's own convention), which left asymmetric gaps — 8px between Cancel and the message, only 5px between the message and Mic. Rebuilt the bar as a proper `HORIZONTAL` auto-layout row (`primaryAxisAlignItems: SPACE_BETWEEN`, `counterAxisAlignItems: CENTER`, fixed 346×64) so Figma guarantees symmetric 10px gaps on both sides instead of hand-measured numbers. Re-screenshotted and confirmed visually balanced. Applied the same auto-layout approach (not manual math) to every bar built afterward in this session (E3–E6) to avoid repeating the pattern.

**iPhone device frame:** present, same convention as the rest of P1.

### P1 Capture Onboarding — E3: Didn't Catch That (2nd Attempt, Suggest Text) (dwelly-redesign file, node 187:538)

Content pulled from the canonical "Ready for Review" reference page (`t5MUGEtpeFcUixobvHiYMc`, page `654:13`, Scenario 6 section, node `1026:10774`) — second consecutive silent attempt, now suggests switching to text alongside retry. Built as a clone of E2's (now-fixed, auto-layout) bar, with the Mic button removed per the reference (no voice-retry affordance on a 2nd silent miss) and a new tappable "Tap here to type instead →" link added below, wrapped in a proper 44×44-tall hit zone rather than left as bare unverifiable text — the reference itself has no visible affordance for this action (implies "tap the bar," which wouldn't pass Section 1 on its own), so this is a deliberate improvement over the source, not a deviation from its intent.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | Cancel 44×44 (post cross-cutting fix). `type-instead-hitzone` 354×44, verified via `get_metadata`. |
| 2. Contrast | ✅ Pass | Message (`text/primary`) 14.82:1 vs bar fill — same verified pair as E2. Link (`accent/gold`) 8.75:1-equivalent, same token already verified vs this fill family. |
| 3. Typography | ✅ Pass | Message bound to `Body/Secondary`; link bound to `Link/Inline` (bold signals tappable — exact semantic fit, that style's own defined role). |
| 4. Layout + Spacing | ✅ Pass | Auto-layout bar (see E2 correction above) — no manual math. Hit zone sits at y=815, bottom=859, 2px clear of the home indicator (861) — tight but not overlapping; flagged for a closer look at implementation time rather than silently accepted as generous. |
| 5. Navigation | ⚠️ Gap (carried over) | Same open item as other Capture screens — depends on T-122. |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` instance. |
| 7. Iconography | ⚠️ Unverified | Cancel icon is the file's real established component, same carried-over flag. |
| 8. VoiceOver | ⚠️ Deferred | Flag for SwiftUI build time. |
| 9. Loading + Error States | ✅ Pass | This screen **is** the error state — plain-language, explicit user-actionable way out (switch to text), matching the scenario's own stated goal ("stops the app from asking for a third identical attempt"). |
| 10. Color Tokens | ⚠️ Gap (carried over) | Same bar-fill gap as E2. New text correctly bound. |

**iPhone device frame:** present, same convention as the rest of P1.

### P1 Capture Onboarding — E4: Transcription Failed (1st Attempt) (dwelly-redesign file, node 187:563)

Content pulled from the same reference page, Scenario 8 section (node `1026:12272`) — a real technical error, not silence; retries on the same retained audio, no re-recording needed. Built as a clone of E2's bar with the Mic swapped for a new `Icon/Retry-Button` component (↻, built this pass — see below), matching the scenario's "retry same audio" intent rather than re-inviting a fresh recording.

**New reusable component:** `Icon/Retry-Button` (136:134 Components page, node `188:166`) — 44×44, `surface/icon-button` fill, real SVG-imported refresh-arrow glyph bound to `accent/gold`, matching the Mic/Cancel/Stop button family exactly (same fill token, same radius). Used by both E4 and E5.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | Cancel 44×44, Retry 44×44 (real component, verified via `get_metadata`, not approximated). |
| 2. Contrast | ✅ Pass | Message (`text/primary`) 14.82:1 vs bar fill, same verified pair as E2/E3. Caption (`text/muted-warm`) 4.70:1 vs page bg, same verified pair as E2's caption. |
| 3. Typography | ✅ Pass | Message bound to `Body/Secondary`; caption bound to `Caption/Note`. |
| 4. Layout + Spacing | ✅ Fixed | First build had the caption ("Your words are safe — this was just a connection hiccup.") wrap to 2 lines inside a fixed 15px-tall box, overflowing into the home indicator (bottom=866 vs home indicator at 861 — a real overlap, not a near-miss). Caught via screenshot, not assumed clean. Fixed by shortening the copy to one line ("Your words are safe — try again.") and switching the text node to `textAutoResize: HEIGHT` so a future copy change can't silently overflow the same way again. Final bottom=846, 15px clearance. |
| 5. Navigation | ⚠️ Gap (carried over) | Same open item as other Capture screens. |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` instance. |
| 7. Iconography | ⚠️ Unverified | Retry glyph is a hand-built SVG approximation (real SVG import, not rotated primitives), not a true SF Symbol — same flag pattern as the E1 mic-off glyph. |
| 8. VoiceOver | ⚠️ Deferred | Flag for SwiftUI build time. |
| 9. Loading + Error States | ✅ Pass | This screen **is** the error state — plain-language, reassuring ("your words are safe"), user-actionable (tap retry), no raw backend error text exposed. |
| 10. Color Tokens | ⚠️ Gap (carried over) | Same bar-fill gap as E2/E3. New text and the Retry component are correctly bound. |

**iPhone device frame:** present, same convention as the rest of P1.

### P1 Capture Onboarding — E5: Transcription Failed (2nd Attempt, Suggest Text) (dwelly-redesign file, node 187:588)

Content pulled from the same reference page, Scenario 9 section (node `1026:11900`). The reference reuses Scenario 7's exact "Still didn't catch that" copy verbatim for this technically-distinct failure — read as a copy/paste artifact in the source rather than an intentional convergence, so this pass used failure-accurate copy instead ("Transcription failed again — try typing instead") while keeping the same structural pattern as E3 (Cancel + message + tappable text-link, no retry icon — two technical failures in a row steers to text, matching the scenario's own stated goal).

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | Cancel 44×44, `type-instead-hitzone` 354×44 — same pattern and verification as E3. |
| 2. Contrast | ✅ Pass | Same verified token pairs as E3 (`text/primary` message, `accent/gold` link). |
| 3. Typography | ✅ Pass | Same style bindings as E3. |
| 4. Layout + Spacing | ✅ Pass | Auto-layout bar, same hit-zone convention as E3. |
| 5. Navigation | ⚠️ Gap (carried over) | Same open item as other Capture screens. |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` instance. |
| 7. Iconography | ⚠️ Unverified | Cancel icon, same carried-over flag. |
| 8. VoiceOver | ⚠️ Deferred | Flag for SwiftUI build time. |
| 9. Loading + Error States | ✅ Pass | This screen **is** the error state — plain-language, explicit user-actionable way out, distinct copy from E3 so the user isn't told "didn't catch that" after what was actually a backend failure (an honesty fix over the source's copy-paste). |
| 10. Color Tokens | ⚠️ Gap (carried over) | Same bar-fill gap. New text correctly bound. |

**iPhone device frame:** present, same convention as the rest of P1.

### P1 Capture Onboarding — E6: Max Duration Reached (10 min) (dwelly-redesign file, node 187:613)

Content pulled from the same reference page, Scenario 10 section — auto-stops silently, no warning beforehand, transcribes normally; "a quiet system-level Resume affordance follows — never a simulated Dwelly message." Built as a clone of the already-locked "30 — Scenario 3: Editing (Collapsed)" screen, removing the keyboard mockup (this is a post-stop review moment, not active typing) and adding a plain system caption below the transcript field. Deliberately did **not** invent a new "Resume" button — the field's existing Mic button already is the resume affordance (tap mic to keep recording), so the caption just makes that explicit ("Tap the mic to resume") rather than duplicating a control that already exists, keeping this a quiet system-level cue rather than a manufactured Dwelly message, matching the scenario's explicit instruction.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | Mic/Send buttons 44×44 (reused real components, unchanged from Screen 30). `expand-icon` remains 20×20 — a pre-existing gap inherited from Screen 30 itself (already documented there as a known issue), not newly introduced by this screen. |
| 2. Contrast | ✅ Pass | Transcript text, same verified pair as Screen 30. Resume caption (`text/muted-warm`) 4.70:1 vs page bg, same verified pair as E2/E4's captions. |
| 3. Typography | ✅ Pass | Caption bound to `Caption/Note`. |
| 4. Layout + Spacing | ✅ Fixed | First build had the caption wrap to 2 lines and collide with the home indicator by 1px (same class of bug as E4) — caught via `get_metadata` coordinates, not assumed. Shortened copy to one line ("Reached 10 min — saved. Tap the mic to resume."), final bottom=844, 17px clearance. Also added a `home-indicator` element, since Screen 30's original didn't need one (keyboard covered that region) but this screen has no keyboard. |
| 5. Navigation | ⚠️ Gap (carried over) | Same open item as other Capture screens. |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` instance. |
| 7. Iconography | ⚠️ Unverified | Same carried-over flag as Screen 30. |
| 8. VoiceOver | ⚠️ Deferred | Flag for SwiftUI build time. |
| 9. Loading + Error States | ✅ Pass | Technically an edge case, not a failure — handled the same way: plain language, user-actionable, no alarming "error" framing (matches the scenario's explicit intent that this stay quiet/non-disruptive). |
| 10. Color Tokens | ✅ Pass | New caption correctly bound to `Dwelly/Colors`. |

**iPhone device frame:** present, same convention as the rest of P1.

### P1 Capture Onboarding — E7: Dwelly Doesn't Respond (Offline) (dwelly-redesign file, node 187:702)

Content pulled from the same reference page, Scenario 11 section (node `1026:11207`) — LLM timeout/error/offline mid-conversation; retries once silently first, this view is what shows after a second failure; the user's message is always already saved. Built as a clone of the Scenario 1 conversation screen (`43:343`), with the existing follow-up Dwelly bubble's copy replaced with the reference's exact reassurance line, plus a new `offline-banner` (small error-colored status dot + "DWELLY OFFLINE" label, auto-layout row) below the status bar.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | — N/A | Banner is a non-interactive status indicator, not a control — correctly not a tap target. Input pill/mic unchanged from the base screen (44×44, already verified). |
| 2. Contrast | ✅ Pass | Banner label (`text/secondary`) computed at 7.15:1 vs page bg (same token/background pairing already verified for E1's body text, different background but both pass comfortably above 4.5:1). Status dot (`state/error`) is a non-text UI indicator, 3:1 icon threshold — same token already verified at 4.56–4.996:1 vs comparable dark fills in this file. |
| 3. Typography | ✅ Pass | Banner label bound to `Caption/Micro` (smallest footnote-level text — correct semantic fit for an ambient status label, not a user-authored message). |
| 4. Layout + Spacing | ✅ Pass | Banner sits in the 44–64px band, above the first dwelly-bubble (starts at 150) — verified no overlap via `get_metadata` coordinates, not assumed from the screenshot alone. |
| 5. Navigation | ⚠️ Gap (carried over) | Same open item as other Capture screens. |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` instance, banner sits below it without overlap. |
| 7. Iconography | — N/A | No icon-level controls introduced. |
| 8. VoiceOver | ⚠️ Deferred | Flag for SwiftUI build time — note for build: the banner should be announced as a live region (`.accessibilityLiveRegion`) so VoiceOver users learn about the offline state without needing to discover it visually. |
| 9. Loading + Error States | ✅ Pass | This screen **is** the error state — plain-language, reassuring, explicitly tells the user their message is saved (directly resolves the scenario's stated fear: "lost words"). |
| 10. Color Tokens | ✅ Pass | New banner elements correctly bound to `Dwelly/Colors`. |

**iPhone device frame:** present, same convention as the rest of P1.

### P1 Capture Onboarding — E8: Dwelly Doesn't Respond (Reconnected) (dwelly-redesign file, node 187:733)

Content pulled from the same reference page, Scenario 11 section (node `1026:11263`) — same base as E7 minus the offline banner, plus a third Dwelly message picking the conversation back up.

**Real bug caught and fixed during this build:** the new badge+bubble for the "I'm back..." message was first positioned using the reference template's stale fixed offset (y=346/371 — the position of the *second* message when there were only 2 messages total), rather than measuring the actual rendered bottom of the message now occupying that slot. This placed the new content directly on top of the existing "I'm still with you..." bubble — caught via screenshot (visibly overlapping text), not assumed correct from the build script succeeding without error. Fixed by reading the actual bottom coordinate of the preceding bubble via `get_metadata` (433, not the template's assumed 314) and positioning the new badge/bubble relative to that real value (badge at 465, bubble at 490) instead of a hardcoded offset. Re-screenshotted and confirmed clean, no overlap.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | Input pill/mic unchanged from base screen, already verified 44×44. |
| 2. Contrast | ✅ Pass | New bubble text, same verified `text/primary`-on-bubble-fill pair as every other conversation screen in this file (14.8:1). |
| 3. Typography | ✅ Pass | New message bound to the same style as its sibling bubbles (`Body/Message`, inherited from the cloned bubble). |
| 4. Layout + Spacing | ✅ Fixed | See overlap bug above — resolved by measuring real coordinates instead of reusing a template offset. |
| 5. Navigation | ⚠️ Gap (carried over) | Same open item as other Capture screens. |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` instance. |
| 7. Iconography | — N/A | No new icon-level controls. |
| 8. VoiceOver | ⚠️ Deferred | Flag for SwiftUI build time. |
| 9. Loading + Error States | ✅ Pass | This is the resolution state following E7's error — picks the conversation back up explicitly, closing the loop the scenario describes. |
| 10. Color Tokens | ✅ Pass | New bubble inherits already-bound fills from its cloned sibling. |

**iPhone device frame:** present, same convention as the rest of P1.

### Scenario 12 — Cancel + Stop While Recording: confirmed already covered, no new screen built

Pulled the canonical reference (`t5MUGEtpeFcUixobvHiYMc`, Scenario 12 section, node `1026:11075`, "8 — Recording: Cancel + Stop") and compared its full node tree against this file's existing "23 — Scenario 3: Recording (Cancel + Stop)" screen (node `90:469`, already ✅ Design-Complete from a prior session): same recording-indicator dot, 15-bar fading waveform, duration timer, Cancel + Stop buttons, same scenario intent ("both controls always visible together... Cancel is instant, no confirmation dialog"). No gap — this scenario does not need a new screen. Noted here rather than silently skipped, so the "9 remaining scenarios" count reconciles: 8 distinct error conditions got new screens (E1–E8, with Scenario 11/"Dwelly Doesn't Respond" split across 2 screens since it has 2 distinct states), and Scenario 12 was already complete.

---

## Structural correction (October 13, 2026): scenarios restructured from single isolated error screens into full journeys

**What was wrong:** The E1–E8 build above (and its checklist entries) treated each scenario as a single error-state screen dropped in alone, with no lead-in context. Kell caught this directly by comparing against the real reference layout (`t5MUGEtpeFcUixobvHiYMc`, page `654:13`), where every scenario is a multi-screen journey — Entry/Startup → Recording/Transcribing → the error moment, sometimes + resolution — not an isolated card. The single-screen builds were real and individually checklist-passed, but incomplete relative to what "scenario" means in the source file, and read as thin by comparison.

**Fix applied:** Restructured the P1 page's error/edge-case area into 8 Figma **Sections** (one per scenario, matching the source file's own organizational pattern — `SECTION` nodes, not loose frames), each containing the full journey:

| Section | Journey |
|---|---|
| Scenario 5 — Mic Permission Denied | Entry → **Mic Access Requested (OS Prompt)** [genuinely new, see below] → Mic Permission Denied (E1) |
| Scenario 6 — Didn't Catch That (1st) | Entry → Recording Active → Didn't Catch That (E2) |
| Scenario 7 — Didn't Catch That (2nd) | Entry → Recording Active → Didn't Catch That 2nd (E3) |
| Scenario 8 — Transcription Failed (1st) | Entry → Recording Active → Transcribing → Transcription Failed (E4) |
| Scenario 9 — Transcription Failed (2nd) | Entry → Recording Active → Transcribing → Transcription Failed 2nd (E5) |
| Scenario 10 — Max Duration Reached | Entry → Recording Active → Max Duration Reached (E6) |
| Scenario 11 — Dwelly Doesn't Respond | Entry (before offline) → Offline (E7) → Reconnected (E8) |
| Scenario 12 — Cancel + Stop | Entry → Recording: Cancel + Stop (already-built happy-path screen, confirmed above) |

**Context screens are clones of already-built, already-checklist-passed happy-path screens** ("02 — Capture Entry," "23 — Scenario 3: Recording (Cancel + Stop)," "23 — Scenario 3: Transcribing") — no new design work needed for these, no new checklist entries required since they're unmodified clones of screens already passed elsewhere in this document.

**One genuinely new screen built:** "Mic Access Requested (OS Prompt)" — the real iOS system permission alert, shown the first time a user triggers the mic (distinct from E1's already-denied custom app modal). Built as an authentic iOS-style system alert (system blue button text, iOS dark-mode alert gray, SF-style typography) — exempt from `Dwelly/Colors` product tokens and the Section 2/10 contrast/token rules, under the same "real native components over mockups" exemption already established for the status bar elsewhere in this file (see `DESIGN_LEARNINGS.md` §1): this is illustrating real OS chrome the user will actually see from iOS itself, not a product surface Dwelly controls the color of.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Pass | Don't Allow / Allow each 135×44 (half of a 270pt-wide alert, real iOS alert convention). |
| 2. Contrast | — N/A (exempt) | OS-chrome mockup, same exemption as the status bar. |
| 3. Typography | ✅ Pass (exempt from product type scale) | SF-style system alert typography (SemiBold title, Regular body, SemiBold default-action button) — intentionally does NOT use this file's 13-item Instrument Serif/Sans type scale, because real iOS alerts don't either. |
| 4. Layout + Spacing | ✅ Pass | Standard iOS alert proportions (270pt wide, centered, divider between title block and buttons, vertical divider between the two actions). |
| 5. Navigation | — N/A | Modal alert, dismissed by either action — same pattern as any real iOS system alert. |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` instance on the underlying Entry screen, unobscured by the alert's lighter 40%-opacity scrim (real iOS permission alerts dim less aggressively than our app's own modals — intentional, matches the real OS pattern, not a copy-paste of E1's scrim). |
| 7. Iconography | ⚠️ Unverified | Mic emoji used as a placeholder for the real iOS permission-icon treatment — flag for a real asset at SwiftUI build time (this exact dialog is rendered by iOS itself at runtime, not by Dwelly, so this is reference-only, not shipped UI). |
| 8. VoiceOver | — N/A | Rendered by the OS, not by Dwelly — no app-side accessibility work applies here. |
| 9. Loading + Error States | — N/A | Not an error state — the first-ask permission moment. |
| 10. Color Tokens | — N/A (exempt) | Same OS-chrome exemption as above. |

**Section-export rendering quirk, not a content bug:** exporting a full Section via `get_screenshot` renders an oversized, mostly-empty gray bounding box above the actual phone frames in the output image. Investigated directly — no stray nodes exist near the sections (confirmed via `get_metadata` bounds-overlap search), individual screen exports are clean, and section `x/y/width/height` values are correctly tight-fit to their children. This appears to be an artifact of how the export renders a `SECTION` node's own chrome, not a real problem with the design — flagging here so a future session doesn't mistake it for broken content without checking first.

---

## P1 Capture Onboarding — Spacing Consistency Pass (October 14, 2026)

Kell caught, screenshot by screenshot, that the conversation-screen vertical rhythm established in the sections above had never actually been verified end-to-end — it was correct on the screens checked at the time, but drifted or was never applied as later screens (Scenario 3's voice row, the error-state rows, the Post-Onboarding clones) were built from older source material. This pass audited and corrected every screen on the P1 page against this file's own Section 4 standard and the bubble-spacing rules locked in `DESIGN_LEARNINGS.md` §6–7 — not spot-checked, every one of the 79 screens on the page.

**Corrections made, in order found:**
1. **Response counter missing on 14 screens** (screen 31 plus 13 context-clone/error screens) — added, matching the already-established `Instrument Sans Medium 11px`/`text/tertiary` spec exactly.
2. **"Done Processing" label removed** (6 instances, screens 09/15/28's Rich Journal Preview) — Kell's explicit call, not a Redesign Principles finding.
3. **Peek-vs-header-chrome gap** — 4 screens had a peek (the gradient-fade "more above" fragment) sitting only 4px clear of the Response counter/Done button above it; unified to a deliberate 14px clearance across all 10 peek screens file-wide.
4. **First-turn content offset (Section 4, vertical rhythm)** — the entire Scenario 3 (voice) row, its error-state clones, and its Post-Onboarding equivalent were anchored 25px higher than Scenario 1/2's already-corrected standard (badge/bubble leading element at y=100 instead of y=125) — 23 screens shifted to match. Two screens (25 and its Post-Onboarding clone) were also missing their `dwelly-badge` entirely, confirmed by direct comparison against their Scenario 1 analog (screen 11) — inserted, not approximated.
5. **Peek-vs-content gap** — the peek's gap to the real content below it was 12–39px across the 10 peek screens, against the file's own documented 28px message-group standard; normalized to exactly 28px on 8 of 10, with a precisely computed 17px on the two 7-message threads that could not fit 28px without overlapping the header or the input bar (flagged as a deliberate, content-driven exception, not a missed standard).
6. **Peek/badge structural inconsistency** — Dwelly-style peeks had no badge at all, while real Dwelly turns always do, producing a different bubble-text starting line depending on whether content was real or peeking (and, on one screen, an outright text-on-text overlap where a stale badge collided with the peek). Fixed at the structural level: every Dwelly-style peek now carries its own badge, positioned identically to real content.
7. **28 further message-group gap deviations** (26–34px instead of 28px) found on 17 screens never touched by any of the above — pre-existing drift in the original source material, not introduced by any correction in this pass. Normalized to 28px using the already-established anchor positions.
8. **Color-token binding gap** (Section 10) — 14 of the 33 Response counter text nodes silently held a raw, unbound color due to a Figma-plugin-API persistence quirk (`node.fills[i]` returns a copy; the paint reassignment must be written back to `node.fills` as a whole array). Rebound all 14 to `text/tertiary`.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | — N/A | No interactive elements added or resized in this pass; re-swept anyway — 0 sub-44pt targets file-wide besides the already-accepted `Icon/Arrow-Right` exception (card is the real target). |
| 2. Contrast | ✅ Pass | New Response-counter text: `text/tertiary` (#747f8c-ish) on `background/primary` (#0A0A0A) = **4.85:1**, computed directly from token RGB values — clears the 4.5:1 normal-text threshold, and matches this same token pair's already-verified 4.86:1 elsewhere in this document (Welcome tagline, Transition subtitle). |
| 3. Typography | ✅ Pass | Counter text uses the established `Instrument Sans Medium 11px` spec, left-aligned per the T-236 rule (instructive/status label, not scripture). |
| 4. Layout + Spacing | ✅ Fixed | See corrections 1, 3–7 above. One documented exception: two 7-message "Conversation Flow" threads use a mathematically-exact 17px rhythm instead of 28px, since the content does not fit 28px within the available vertical space without overlapping the header or input bar — applied identically on both affected screens, not guessed per-screen. |
| 5. Navigation | — N/A | Not implicated by this pass. |
| 6. Status Bar | ✅ Pass | No status bar/Dynamic Island region touched; re-verified no new overlaps introduced by any cascading shift (0 collisions, checked by direct coordinate comparison, all 79 screens). |
| 7. Iconography | — N/A | Not implicated by this pass. |
| 8. VoiceOver | ⚠️ Deferred (carried over) | Unchanged status — flagged for SwiftUI build time throughout this document already. |
| 9. Loading + Error States | — N/A | Not implicated by this pass. |
| 10. Color Tokens | ✅ Fixed | See correction 8 above — all 33 counters now properly bound; 0 unbound fills remain among anything added or touched this session. |

**Final verification, whole page:** 79 screens, 0 frame-to-frame collisions, 0 internal element overlaps, 0 unresolved component instances (219 total), 0 unbound color fills on anything touched this pass. Verified both by coordinate audit (`get_metadata`-equivalent property reads, not eyeballed) and by direct screenshot comparison on every screen Kell specifically flagged.

---

## P4 Journal Synthesis — Redesign Principles Audit (October 14, 2026)

Kell asked for the same rigor applied to P1 — measured against HIG, WCAG AA, Ashley's principles, and this file's own Section 4 standard — run on the newly-built P4 page (`🔄 P4 — Journal Synthesis`, 11 scenarios, 33 real screens) before calling it done.

**Critical bug found and fixed first, same root cause as the P1 counter-binding issue:** 586 fills/strokes across nearly the entire page were silently unbound despite matching real tokens exactly. The `bindFill` helper used throughout this pillar's build called `setBoundVariableForPaint` on `node.fills[0]` without reassigning the result back to `node.fills` as a whole array — the same Figma-plugin-API persistence quirk documented in the P1 entry above, except here it was the *default* pattern for the entire build, not an isolated miss. Walked the full page, rebound all 568 fills + 18 strokes properly, verified 0 remain, confirmed visually nothing broke.

| Section | Pass / Fail / N/A | Notes |
|---------|--------------------------|-------|
| 1. Tap Targets | ✅ Fixed | 0 sub-44pt findings among icon/button instances (Star, Ellipsis, Close, Undo, Save, Photo, Camera, Back). **Found and fixed:** the 8–9 mood-selection chips in the Edit Moods sheet (3 screens) were 34–36px tall — below the stated 44pt minimum, even though comparable iOS patterns (Reminders tags, Photos filters) often ship smaller. Rebuilt with 14px vertical padding (was 9px) so every chip clears 44pt (now 44–46px), relaid out all 3 screens' chip grids and downstream elements to the new heights, verified no overlap via screenshot. |
| 2. Contrast | ✅ Fixed | `text/primary` on `background/primary` = 16.2:1, `accent/gold` on `background/primary`/`surface/card` = 9.59:1/8.75:1, `text/placeholder` on `background/primary` = 7.45:1 — all reused, already-verified pairs from elsewhere in this document. **Found and fixed:** the destructive "Delete" label (Delete Confirmation popovers, Ellipsis Menu's "Delete Entry" item, both base and Pending variants — 5 instances total) computed to **4.56:1** against its dark popover background — technically clears 4.5:1 but by a margin too thin to trust for a destructive-action label. Created a new, properly-named token `state/error-text` (r=0.97, g=0.38, b=0.36 — distinct from the base `state/error` token, which stays reserved for icons/borders at the lower 3:1 bar) and rebound all 5 destructive-text instances to it: new computed contrast **5.86:1**, comfortable margin. |
| 3. Typography | ✅ Pass | Instrument Serif/Sans throughout, same approved deviation from SF Pro as the rest of the file. Journal body left-aligned per the T-236 instructive-copy rule. |
| 4. Layout + Spacing | ✅ Pass | Header icons (back/star/ellipsis/close/undo/save) sit at exactly y=64 across all 33 screens, zero drift. Date/title position is a clean binary split — 132/160 on every no-photo screen, 300/328 on every hero-photo screen — no screen falls outside that pattern. This is the exact dimension P1 failed repeatedly across multiple rounds; P4 passed it cleanly from the first audit. |
| 5. Navigation | ✅ Pass | Every non-entry screen reachable via back/close; Entry Points scenario explicitly maps all 4 ways into the shared destination. |
| 6. Status Bar | ✅ Pass | Real `ios-status-bar` instances throughout; 0 collisions with top chrome across all 33 screens. |
| 7. Iconography | ⚠️ Unverified (carried over) | Photo/Camera toolbar icons are emoji placeholders (🖼📷), not real SF Symbols — flagged at build time, same category of gap as send/back icons elsewhere in this document. |
| 8. VoiceOver | ⚠️ Deferred (carried over) | Same standing status as the rest of this document — flagged for SwiftUI build time. |
| 9. Loading + Error States | ✅ Pass | Pending state (all causes of non-completion unified, no manual retry) and the full error-adjacent Scenario 11 row are explicitly designed, not deferred. |
| 10. Color Tokens | ✅ Fixed | See the 586-fill binding bug above — now 0 unbound fills/strokes matching a known token anywhere on the page. |

**Final verification, whole page:** 33 screens, 0 frame-to-frame collisions, 0 unresolved component instances (177 total), 0 unbound color fills, 0 sub-44pt tap targets, contrast computed (not eyeballed) on every token pair touched by this pass. Verified via screenshot on the 3 affected mood-sheet screens and the delete-confirmation popover.

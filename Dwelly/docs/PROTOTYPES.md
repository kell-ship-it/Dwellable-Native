# Dwelly — Prototype Registry

**Purpose:** Single index of every interactive prototype built across pillars. Created August 20, 2026 after discovering no such index existed; T-172's capture prototype was built and referenced in `TICKETS.md` but never actually committed to the repo.

**🚨 Standing rule (Kell, Aug 20, 2026): "Prototype" means HTML. That's the only way we prototype around here.** Figma Present-mode click-through wiring is not a substitute — build the real HTML file (phone-frame mockup, `data-goto`/`data-overlay` nav engine, Google Fonts for Instrument Serif/Sans) and commit it to `docs/`, not scratchpad. Verify it actually works by opening it in the Browser pane and clicking through before calling it done — a past session shipped one that was described in `TICKETS.md` but never actually built as a real file.

**Convention:** Update this file whenever a prototype is built, wired, or meaningfully changed. Link Figma prototypes by node-id URL (not just file key) so the entry point is one click away.

---

## Pillar 0 — Onboarding

| Prototype | Type | Location | Status |
|---|---|---|---|
| Happy path + 9 edge cases, fully wired | Figma (Present mode) | File `t5MUGEtpeFcUixobvHiYMc`, `Prototype Start` frame | ✅ Complete, 40/40 connections audited (July 31, 2026) |
| Standalone HTML port | HTML | `docs/P0_prototype.html` | ✅ Complete — real extracted welcome-screen assets |
| Reader-paced nav-chrome version | HTML | `docs/P0_NavChrome_Prototype.html` | ✅ Complete — timed reveals s05-s20 (Aug 4, 2026) |
| Per-screen animation demos (S05-S20) | HTML | `docs/P0_S*_Timed_Reveal_Demo.html`, `P0_S11_Card_Animation_Demo.html`, `P0_Pacing_Options.html`, `P0_S11_CardAnimation_Options.html` | ✅ Complete — exploration/reference, folded into NavChrome version |

## Pillar 1 — Capture (Onboarding)

| Prototype | Type | Location | Status |
|---|---|---|---|
| Happy path + 8 error/edge-case scenarios | **HTML** | `docs/P1_OnboardingCapture_Prototype.html` | ✅ Complete (Aug 23, 2026) — rebuilt from scratch sourcing real content from the Figma `Full Flow (Polished v1)` and `Error States & Edge Cases` pages (T-172's original scenario descriptions: mic denied, silence x2, transcription failure x2, max duration, Dwelly offline, cancel-vs-stop). No dismiss/back control anywhere, matching the locked "can't leave onboarding capture" rule. Click-tested. The old `capture_flow_prototype.html` reference was never real — this replaces it. |
| Figma error states reference | Figma (static, not wired) | File `t5MUGEtpeFcUixobvHiYMc`, page `P1 — Capture Onboarding — Error States & Edge Cases` | Static reference only, no Present-mode wiring |

## Pillar 1 — Capture (Post-Onboarding)

**Note (Aug 20, 2026): Kell clarified prototypes in this project always mean HTML, not Figma Present-mode wiring — the Figma wiring below was the wrong deliverable and is being superseded by the HTML version.**

| Prototype | Type | Location | Status |
|---|---|---|---|
| Full loop: 3 blank tabs (Today/Entries/Growth) + persistent "+" → Capture Entry → Recording → Transcription → Conversational Review → Conversational Loop → "Start over?" modal (Save Moment / Start Over) → Entry Saved → Creating Journal → Journal Reveal | **HTML** | `docs/P1_PostOnboarding_Prototype.html` | ✅ Complete — click-tested end to end in-browser, real content transcribed from the actual designed screens. Committed to repo (not left in scratchpad). |
| Same flow, Figma Present-mode wiring | Figma (Present mode) | File `t5MUGEtpeFcUixobvHiYMc`, page `P1 — Capture — Post-Onboarding` | ⚠️ Built but not the right format per Kell — kept as design reference only, not the canonical prototype |
| Transition mechanism comparison (7 options, animated) | HTML (Artifact) | `capture_transition_prototype.html` — [published artifact](https://claude.ai/code/artifact/8f7137fe-523c-498d-b630-bdf52a6eea1d) | ✅ Complete — Container Transform locked as the chosen option |

## Pillar 6 — Menu / Navigation

| Prototype | Type | Location | Status |
|---|---|---|---|
| 3-tab shell + persistent "+" button, example tab content | Figma (static, not wired) | File `t5MUGEtpeFcUixobvHiYMc`, page `P6 — Menu / Navigation` | Static reference only — no Present-mode wiring yet |

## Other Pillars (2-11)

No prototypes built yet — design work is at the strategy-doc / FigJam stage for most (see `TICKETS.md` pillar design sequence). Add rows here as prototypes are built.

---

## Combined Prototype

| Prototype | Type | Location | Status |
|---|---|---|---|
| Onboarding (s01-s20) → first Capture (no exit, 8 error states) → the app (3 tabs + persistent "+", Slide Up locked) — one continuous click-through | **HTML** | `docs/Dwelly_Full_Prototype.html` | ✅ Complete (Aug 23, 2026), re-verified + one bug fixed Aug 24, 2026. **Sensory Design Layer added Sept 2, 2026 (T-190, Pillar 0 first pass)** — see note below. Built by programmatically merging the 3 prototypes below (not hand-retyped) — CSS variable names reconciled (`--bg-screen`→`--bg`, `--gold`→`--accent-gold`, `--red`→`--state-error`, `--border`/`--border-soft`→`--border-default`), all screen/overlay IDs prefixed (`oc-`, `po-`) to avoid collisions, both files' JS engines merged into P0's single click handler. Two real bugs caught and fixed during the original merge: (1) both `oc-entry` and `po-tab-today` carried a hardcoded `active` class from being each source file's own default screen — left unfixed, both would have rendered simultaneously on load; (2) the "Continue to Dwelly" bridge needed rewriting from its original self-loop (`oc-entry`) to `po-tab-today`, the actual handoff into the app. Click-tested end to end: welcome → onboarding → first capture → the tab shell, "+" → Capture (both Slide Up and Container Transform verified), exit slide-down, and one error-state scenario. **Aug 24 re-verification found a third real bug**, inherited silently since the Aug 23 merge: the merged file has no `<html>`/`<head>` wrapper (relies on implicit HTML5 parsing, matching this project's other standalone prototypes), and its `<title>`/lead content came from `P0_NavChrome_Prototype.html`'s head — which never had a `<meta charset="utf-8">` tag. The other two source files did, but their heads were dropped as redundant during the merge, so the merged file silently lost UTF-8 declaration. Browsers fell back to Windows-1252, turning every em dash and phone-status emoji into mojibake (`â€"`, `ðŸ"¶`) sitewide. Fixed by adding `<meta charset="utf-8">` as the file's first line; also updated the stale inherited `<title>` (was still "Nav-Chrome Prototype (P0 New Onboarding)") to reflect the merged scope. Re-verified live in-browser after the fix: welcome screen renders clean UTF-8, `oc-entry` → `oc-journal-reveal` → "Continue to Dwelly →" correctly hands off to `po-tab-today`, persistent "+" → Slide Up → `po-capture-entry` → dismiss-x correctly returns to Today, and one error state (`oc-err-dwelly-offline`) renders with correctly reconciled `--state-error` styling. **Known pre-existing gap, not a merge regression:** the in-app tab bar's Today/Entries/Growth items have no `data-goto` wiring in any of the three source files — cross-tab navigation only works via the hub's direct jump links, not by tapping the tab bar itself. Published as its own Artifact (Aug 24, 2026): https://claude.ai/code/artifact/054b3364-c5b3-4c16-9714-470fbadc8b3d — distinct from `dwelly_capture_flow` (see correction note below). |

Source files (kept standalone, still useful individually for focused review/edits):
- `docs/P0_NavChrome_Prototype.html` — Onboarding
- `docs/P1_OnboardingCapture_Prototype.html` — first-time Capture, no exit, 8 error states
- `docs/P1_PostOnboarding_Prototype.html` — the tab-based app + return-visit Capture

## Pillar 5 — Search & Discovery (Search), Sept 2, 2026

Built the Search screen in `Dwelly_Full_Prototype.html`, reached by tapping the search icon already sitting in the Entries header pill (previously non-functional). Tokens/structure pulled directly from Figma "P5 — Search & Discovery" (Scenario 2a/2b/2c, nodes `1478:58`/`89`/`120`) via the Plugin API, not eyeballed.

Real client-side filtering against the same 3 mock entries used in the Entries tab — not a static screenshot of one state:
- **Idle / recent searches** — 3 seeded recent terms (matching Figma's mock: "gratitude", "Mom", "Peaceful (mood)"), each removable (✕), "Clear all" empties the list and swaps in "Your recent searches will appear here." (also matches Figma).
- **Live results** — typing filters in real time against title + excerpt text and the active mood chip; matched substring highlighted in gold (`<mark>`), result count line reads "N results: "query" + Mood" matching Figma's copy pattern exactly.
- **No results** — dashed-circle icon + "Nothing yet" + cause-aware subtext (mentions the mood filter only when one's active, matching Figma's two copy variants).
- Mood chips (All Moods/Peaceful/Grateful/Hopeful/Reflective) are single-select and combine with the text filter.
- Result cards reuse `.entry-card` (same component as the Entries list), so search results and the list look identical by construction, not by copy-paste.

Verified in-browser: idle→recent-searches state, live-typed result with highlight, mood-filter combination ("the" + Grateful → 1 result), no-results state, and result-card tap-through to Journal Detail. Zero console errors across all paths.

**Fixed same session (Kell, screenshot): the persistent floating "+" was colliding with the Entries header's own icon pill.** Checked the actual Figma "P5 — Search & Discovery" design — the real Entries screen has no separate standalone capture button, only the icon pill's own "+" segment. Wired that pill "+" with `data-launch-capture` and removed the redundant standalone `.plus-button` from `tab-entries` only (Today and Growth are still Figma placeholders and keep their own standalone button, unaffected). Verified: pill "+" correctly launches the real capture flow, no visual collision, zero console errors.

## Standalone review prototype — Journal 3 Entry Points, Sept 2, 2026

Per Kell: prototype the 3 entry points as their own focused deliverable first, for him to review and pick which 2 (of 3) carry forward into the combined prototype — not assume all 3 are automatically kept.

New file `docs/P4_Journal_Entry_Points_Prototype.html` — real content/behavior pulled directly from `Dwelly_Full_Prototype.html` and the Figma "Entry Points" section (not redrawn/simplified): hub with 3 start buttons, one phone frame, all 3 entry points (chat preview card / real Entries calendar+list / simulated notification banner) each leading to the same real Journal Detail screen (star, ⋯ menu, back). Verified all 3 paths + back navigation in-browser, zero console errors.

**Kell's decision, same session: entry points 1 and 2 carry into the combined prototype; 3 (notification) does not.** Removed the notification-tap simulation from `Dwelly_Full_Prototype.html` (hub button, `#notifBanner` markup/CSS, trigger/timer JS) — it stays fully built and reviewable in the standalone file above and in the Figma "Entry Points" section, just not merged into the main prototype. Hub note updated to describe 2 entry points, not 3. Re-verified Entries-row tap-through still works post-cleanup, zero console errors.

## Pillar 4 — Journal Entry Points (Figma), Sept 2, 2026

Kell's ordered ask: (1) design the 3 Journal entry points in Figma, (2) prototype them, (3) then design notification entry points — replicated onto each destination pillar's own page, not just the Notifications page. This entry documents step 1.

**Discovered first:** Figma file `t5MUGEtpeFcUixobvHiYMc` has a page `P4-Journal Synthesis` (`node-id=1301-48`) that's far ahead of the HTML prototype — Edit Entry, Pending states (base/ellipsis/delete), View Original Conversation, Add Photo/Camera, Mood-edit bottom sheet, min-content edge cases, starred state, etc. all already exist there. The View screen built earlier this session in HTML matches its "SCENARIO 1 — VIEW (APPROVED)" (`1423:3909`) closely by coincidence, not by having read it first.

**Built new section "Entry Points — Into Journal Detail"** (`1648:48`, placed clear of all existing content at x=3200) with 3 phone frames, styled from tokens pulled directly off the existing View screen (bg `rgb(0.043,0.039,0.031)`, cream text `rgb(0.965,0.949,0.910)`, muted `rgb(0.706,0.674,0.608)`, gold `rgb(0.788,0.698,0.478)`, Instrument Serif/Sans) rather than guessed colors:
1. **Chat Preview Card** — Dwelly's closing message with the embedded journal card (dashed gold outline for emphasis only, not real UI)
2. **Entries List** — 3 mock rows (date/title/mood chip), first row highlighted as the tap target; list itself isn't built yet (T-078), this only shows the entry point
3. **Notification Tap** — lock-screen-style banner tap, flagged as the one entry point that also needs a matching design on the Notifications page (P8) per the locked sequencing — not done yet, that's step 3

Each frame's caption explicitly names its destination ("SCENARIO 1 — VIEW (APPROVED)" on the same page) so the cross-reference is legible without needing this doc.

**Restacked into a readable journey layout, same session (Kell): each scenario is its own row, stacked top-to-bottom; within a row, entry point → destination reads left-to-right.** The original layout put all 3 scenarios side-by-side in one horizontal line, which didn't read as 3 separate journeys. Kept each scenario's internal left-to-right order (before → arrow → after) but stacked the 3 rows vertically instead of side-by-side, added a small "SCENARIO 1/2/3" label at the left edge of each row, and resized the section to 1104×3384 (one row's width, 3 rows tall). Same click-to-navigate reactions carried over untouched — only position changed, not structure.

**Corrected same session — Kell: "you're not using the right design for the entry point for Entries."** Entry Point 2's "before" frame was itself hand-drawn from scratch (invented 3-row mock), the same mistake later repeated in the HTML prototype and already fixed there — but the Figma reference frame was never fixed to match. Deleted the invented frame and replaced it with a real clone of `P5 — Search & Discovery` / "Scenario 1 — Calendar + Entries List" (node `1469:49`) — same script, no page-switch issues (`getNodeByIdAsync` loads a node's containing page on demand, so cloning cross-page from P5 into a P4 section worked in a single `use_figma` call). Re-wired its click-to-navigate reaction and corrected the stale caption to name the real source node. Verified via `get_screenshot`.

**Revised same session — Kell: show the destination, don't just name it.** A text caption pointing elsewhere in the file isn't "seeing what it looks like." Widened the section (3172px) and, for each of the 3 entry points, placed a real clone of the actual "SCENARIO 1 — VIEW (APPROVED)" screen directly beside it (not a redrawn approximation) with a gold arrow + "tap" label between them, so the full before→after reads in one glance without navigating elsewhere. Also wired real click-to-navigate reactions (`ON_CLICK` → `NAVIGATE`) from each "before" frame to its "after" clone, so the whole thing is walkable in Figma's own Present mode, not just a static side-by-side. Verified via `get_screenshot` on the full section.

## Pillar 4 — Journal Creation (Journal Detail, View screen), Sept 2, 2026

First build for Pillar 4. Per `docs/P4_SUMMARY.html`'s locked decisions: single Journal Detail view (no Entry/Dwelling-Place split), header is back arrow + always-visible Star + (...) overflow (Edit Entry / View Original / Delete Entry), no offline indicator, hero photo full-bleed above a left-aligned title when present (mock entry here is text-only), moods in their own row between title and body.

Built in `docs/Dwelly_Full_Prototype.html` as a new `#section-app` po-screen (`id="journal-detail"`), reusing/repurposing the old dead `.journal-body`/`.journal-card`/`.journal-cta` CSS rules (unreachable since the static post-onboarding mockup screens were removed earlier this session) rather than adding parallel dead weight.

**Wired one of three entry points** — the chat-preview "Open" card from the capture-flow's closing message (`journalCardInner()` in the `#section-capture` engine) now calls `window.openJournalDetail()`, a bridge exposed by the `#section-app` engine, matching the same cross-section pattern already used for `appShowScreen`/`launchPostOnboardingCapture`.

**Kell flagged two more entry points as an explicit follow-up, not done yet:** (1) a notification tap should land directly on Journal Detail, (2) the Entries list (T-078, not yet built) should also open the same screen. **Reminder set per Kell's own request: revisit all three entry points together once Pillar 4's other screens exist, before moving to the next pillar after this one.**

**All 3 entry points prototyped in HTML, same session (step 2 of Kell's ordered plan).** Matches the Figma "Entry Points" section exactly:
1. **Chat preview card** — already wired earlier this session.
2. **Entries list** — first pass used an invented 3-row mock. **Corrected per Kell ("use the actual designs")**: discovered `P5 — Search & Discovery` / "Scenario 1 — Calendar + Entries List" (node `1469:49`) already has the real, fully-designed Entries screen — an Untold-style month calendar (dots on days with entries, gold-filled circle on today, gold text on one flagged day) plus a chronological entry-card list below. Pulled exact colors/fonts/grid structure via the Plugin API (not eyeballed from the screenshot) and rebuilt `tab-entries` to match: calendar card (Aug 2026, dots on 14/20/24, today=24, gold text on 27, matching the source frame's actual per-cell fill/opacity data, not a guessed pattern), header icon pill (+ / search / profile), 3 real entry cards with the source frame's actual copy and mood tags. Each card still taps through to Journal Detail via `[data-open-journal]`.
3. **Notification tap** — a real push can't fire from a browser tab, so this simulates it: a hub button ("🔔 Simulate notification tap → Journal") slides a banner down over whatever screen is active (`#notifBanner`, matching the Figma mock's flame-icon/app-name/body layout), auto-hides after 4s if untapped, and opens Journal Detail on tap. Also carries `[data-open-journal]`, so it reuses the exact same handler as the other two — no separate navigation logic to keep in sync.

Verified all three in-browser: Entries row tap → Journal Detail; notification banner slide-in → tap → Journal Detail (confirmed via `getBoundingClientRect()` that the banner was genuinely visible before the tap, not a stale screenshot). Zero console errors across all three paths.

**What's real vs. placeholder in this pass:**
- Real: back caret (→ Today), Star toggle (visual), (...) menu open/close, Delete Entry (returns to Today, simulating removal)
- Placeholder, not wired: Edit Entry and View Original — those screens (Edit, Pending, View Original transcript) don't exist yet; tapping them just closes the menu. Flagged in-code so a future session doesn't assume they're dead by accident.

Verified end-to-end in-browser: launch capture → topic card → reply → Dwelly responds → reply → Done → journal card appears → tap card → Journal Detail renders correctly (title, moods, body, scripture) → star toggles → (...) menu opens with all 3 items → back caret returns to Today. Zero console errors throughout.

## Figma sync — P1 Capture Post-Onboarding, Sept 2, 2026 (Kell: "old designs in here")

Figma file `t5MUGEtpeFcUixobvHiYMc`, page "P1 — Capture — Post-Onboarding" (`node-id=1151-60`) was still showing the old X dismiss icon across every frame — hadn't been synced to the caret decision made in the HTML prototype. Updated directly via the Plugin API (not hand-redrawn per screen):
- **All 10 "dismiss" frames** on the page (`A`, `B2`, `B3`, `B4`, `01`–`05`, `05b`) had their X vector (`M 14 0 L 0 14` + `M 0 0 L 14 14`) replaced with a left-pointing caret (`M 9 0 L 1 7 L 9 14`, round caps/joins) — same frame position/size, just the glyph swapped.
- **New frame `B5 — Tap caret after Done, no warning (moment already saved)`** (cloned from B4, modal+scrim stripped, id `1643:177`) plus an annotation text block (`1643:200`) documenting the `momentSaved` rule in words, since a static design file can't encode the underlying "skip the warning once saved" behavior the way the HTML prototype's code does — Kell confirmed this frame+note is the right way to represent it in Figma.

Verified via `get_screenshot` on both the caret swap and the new B5 frame.

## Sensory Design Layer (T-190) — Pillar 0 first pass, Sept 2, 2026

Added directly to `docs/Dwelly_Full_Prototype.html` (not a separate file) as a global, prototype-wide engine — CSS block "Sensory Design Layer" just before `</style>`, JS block appended as the file's final `<script>`.

- **Real sound:** WebAudio-synthesized tones (`tap`, `select`, `key`, `chime`, `success`, `warn`) — no external audio files, self-contained. Mute toggle on the feed badge.
- **Labeled haptic tags:** since a browser can't fire real haptics, every tap surfaces the exact iOS API call a native build would trigger — `UIImpactFeedbackGenerator(.light/.medium)`, `UISelectionFeedbackGenerator()`, `UINotificationFeedbackGenerator(.success/.warning)` — in a small feed badge at the bottom of the viewport, matching the API-vocabulary format locked for T-187 (notifications).
- **Screen-transition animation:** `.screen.active` now gets a CSS `screen-enter` fade/slide-up (0.42s), replacing the prior hard cut on every `data-goto` navigation.
- **Wiring:** all done via document-level event delegation classifying clicked elements by CSS selector (option cards/checkboxes → selection, primary CTAs → medium+success, tap-continue/nav → light, errored inputs → warning) — not hand-added per button. This means it already applies to every screen in the file (onboarding, capture-flow, post-onboarding app), though only **Pillar 0's** classification set (`.option-card`, `#s19-terms-row`, `.tap-continue`, `.btn-primary`, etc.) was verified this session. Extend `CHIME_ON_SHOW` and the `classify()` selector list as later pillars' screens get their own sensory pass.
- **Verified in-browser:** click-tested welcome → Get Started → intro screen, `window.Sensory.fire()` confirmed working, zero console errors.
- **Not yet done:** the other 10 pillars (T-190's actual full scope) — this is the first pillar only, per Kell's explicit "Pillar 0 first" instruction this session.

**🚨 Sound PAUSED for onboarding, Sept 2, 2026 — do not re-enable without checking with Kell.** Kell felt the click sounds "sound like a video game" for onboarding specifically. Haptic tags still fire/display normally in onboarding; only the WebAudio tones are gated off (via `inOnboarding()` in the click handler — the `#section-onboarding` DOM boundary), not deleted. He's discussing with his design partner whether onboarding sound comes back at all — the decision point is **at the end of the full cross-pillar T-190 pass**, not per-pillar. Sound status for every other pillar (once its own sensory pass starts) is undecided — don't assume this pause extends to them. Tracked in `TICKETS.csv` T-190.

**Also fixed this session (Sept 2, 2026), all in `docs/Dwelly_Full_Prototype.html`:**
- Removed screen `s10` ("Here's how Dwelly helps you steward each God encounter...") — Kell: "we're no longer doing that." s07 now goes straight to s11; loading-bar percentages recomputed for the resulting 13-step sequence (was 14).
- Sped up s07's ("Imagine you're on a walk...") timed-text reveal from 7.5s total to under 1s (0/300/600/900ms) — Kell flagged the old pacing as too slow; exact retiming is his to finish with his design partner, this is just "fast enough for now."
- Added ~30px more clearance between the loading bar and the "Moments you've stewarded" list on s14 (margin-top 75px → 104px) — Kell felt it sat too close to the bar.
- Left the s14 "struck with a sense of fear about the future" line unchanged — Kell confirmed that copy is fine as-is.
- **Added the Dwelly flame to the end of the pre-capture bar** (was missing entirely on s01-s20 — `.loading-bar-reward` existed in CSS but was never placed in markup). Renders outline-only, always empty, on all 13 bar-carrying pre-capture screens.
- **Fixed the flame's entry state in the capture flow** — `continuityBar()`'s `stepFraction` was `(currentStep + 1) / total`, so the flame already showed a filled sliver on the very first capture screen. Changed to `currentStep / total` so it starts at a true 0px fill, matching the empty flame handed off from onboarding — the flame only starts visibly filling once the user has taken a step forward.

**Onboarding Capture fixes, same session (Sept 2, 2026):**
- **Removed the infinite/looping topic-card scroll.** `topicCards()` was tripling the card set and `initInfiniteTopicScroll()` silently jumped `scrollLeft` back and forth to fake a seamless wrap-around. Kell: plain bounded horizontal scroll only. Replaced with a single card set and a simplified `initTopicScroll()` (same drag-to-scroll physics, no wrap logic, no tripling).
- **Fixed the flame overlapping the bar at loop completion.** `.onboarding-continuity-row` was 354px wide but had to fit a 354px bar + 8px gap + 18px flame (380px of real content) — flexbox was silently shrinking the bar track to fit, while the JS-computed fill width still assumed the original 354px, so at high fill % the fill visually bled straight into the flame. Fixed by widening the row to 380px (its real content width) and pinning the track at `flex-shrink: 0` + `overflow: hidden`, so the flame now stays fixed in place through the whole loop with a clean 8px gap, verified via DOM measurement at 100% fill (`overlap: false`).

**Capture entry logo corrected, same session (Kell, reference screenshot provided).** The small boxed card badge (44px, `bg-card` background) with a tiny outline flame + tiny uppercase "DWELLY" was the wrong treatment. Fixed to a larger (64px) flame with no card background, reusing the exact same real flame path already used on the onboarding welcome screen (s01) rather than inventing new geometry, plus a lowercase bold "dwelly" wordmark (was uppercase small-caps, 12px/600 — now 26px/800, `text-transform: none`). Verified in-browser against the reference image.

**Post-onboarding capture rebuilt to reuse the real engine, same session (Kell: "it's just a static image... two different experiences").** The `#section-app` capture screens (`capture-entry`, `recording`, `transcription`, `conv-review`, `conv-loop`, `done-natural`, `done-early`, `journal-reveal`, `modal-start-over`) were a separate, static, non-interactive mockup originally built only to demo the "+" transition animation (Container Transform vs. Slide Up) — typing didn't work, mic didn't work. Retired all of it. The "+" button (all 3 instances: Today/Entries/Growth) now calls `launchPostOnboardingCapture()`, which resets flow state and jumps straight into the exact same dynamic capture-flow engine (`ROWS`/`cardFlow`/`render()`) already built and tested for onboarding capture — real typing, mic, transcription, guaranteed identical since it's literally the same code path, not a lookalike copy.

One real behavioral difference from onboarding capture, since post-onboarding capture must be re-enterable/cancelable while onboarding's is deliberately a single no-exit loop: added `postOnboardingMode` (a flag, default false) that when true renders an X (`exitCaptureX()`) and a Done button (`[data-done-cta]` — the wiring already existed, unused, from an earlier abandoned attempt per Aug 25 MEMORY) in the 24px gap between the status bar and the continuity bar. X with nothing drafted exits immediately (`exitPostOnboardingCapture()` → `window.appShowScreen('tab-today')`, a new bridge exposed from the `#section-app` engine); X with a message/reply already in progress shows a "Start over?" confirm overlay (`showExitConfirm` + `exitConfirmOverlayHtml()`) with Save Moment / Start Over, matching the old static mockup's copy exactly. The journal reveal's "✓ Onboarding complete" milestone label is suppressed in post-onboarding mode (doesn't apply — the user already onboarded).

Also removed as dead code: `morphToScreen()`/`slideToScreen()`/`slideOutScreen()` (the retired transition-demo functions), the "+" transition mode-toggle UI, and the hub's "Jump to a step" button list (capture's actual steps are all reachable from the "2. Dwelly Capture Flow" tab's own controls now that it's the same engine).

**Verified end-to-end in-browser:** "+" → real typing in the input field → topic-card tap → live Dwelly conversation → Done → journal reveal (early-exit closing line, no onboarding-complete milestone) → X → confirm overlay → Save Moment (stays on journal) and separately Start Over (returns cleanly to Today, tab highlight correct). Zero console errors at every step. Confirmed onboarding capture itself is unaffected — `postOnboardingMode` stays false and no X/Done render there.

**Bar/flame/X removed from post-onboarding capture entirely, same session (Kell): "that shouldn't exist."** Kell's read once he saw it mid-conversation: the onboarding progress bar was permanently stuck at 100% in post-onboarding (nothing left to represent), so the whole bar+flame+X row was meaningless there, not just mis-positioned. `continuityBar()` is onboarding-only now — `entryHeader()`/`chatHeader()` render nothing for it when `postOnboardingMode` is true. Only Done remains (not targeted by this request), repositioned to sit just under the status bar on its own since there's no bar row to anchor to anymore. **Resolved same session: back caret, not an X.** Kell: "a caret, like an arrow that points left." Added `captureBackBtn()` — reuses the existing `ICONS.back` chevron, positioned top-left mirroring Done's top-right position, wired to the exact same `[data-capture-exit]` handler/logic already built (`exitConfirmOverlayHtml()`/`wireExitConfirmOverlay()`) — only the trigger's icon and class changed, not the exit behavior. Nothing drafted → exits immediately; content drafted → same "Start over?" confirm (Save Moment / Start Over) as before. Cleaned up the now-dead `capture-exit-x-inline`/`with-exit` CSS and the postOnboardingMode branch inside `continuityBar()` (unreachable now that continuityBar() is onboarding-only). Verified in-browser: back caret visible on entry + chat screens, immediate exit with nothing drafted, confirm overlay with content drafted, zero console errors.

**Two more fixes, same session (Kell, reference screenshot showing both bugs at once):**
1. **Done overlapped the first chat bubble.** `.chat-header-spacer-none` was 16px — nowhere near enough to clear the back-caret/Done row (top:54, ~20px tall). Widened to 74px.
2. **The exit-warning logic was checking the wrong thing.** It fired off "is there drafted content" (`currentStep > 0` or typed text), which stays true forever once a conversation starts — so it kept warning even after the moment was already saved. Introduced `momentSaved` (false on every fresh `launchPostOnboardingCapture()`), set true in exactly the two places a moment actually gets saved: `wireDoneButton()`'s click handler (journal card embeds in the thread) and the exit-confirm's "Save Moment" handler. Renamed the gating function `hasDraftedContent()` → `hasUnsavedContent()`, which now returns false whenever `momentSaved` is true regardless of draft/step state. Back caret now exits immediately post-Done with no warning, confirmed via the exact repro Kell described (type → send → Done → journal card embeds → back caret → no warning, straight to Today). Zero console errors.

**X position fixed, same session (Kell, reference screenshot).** First pass put the X on its own line above the bar (in the status-bar/bar gap) — wrong; it needed to sit on the bar's own row, mirroring the flame on the opposite end. Folded the X into `.onboarding-continuity-row` itself as the first flex child (`capture-exit-x-inline`), shrinking the bar track from 354px to 300px only in post-onboarding mode to make room — onboarding capture's row (no X) is untouched. Verified via `getBoundingClientRect()`: X and flame both sit at the exact same `top`, confirming true row alignment, not just visual proximity.

**Post-onboarding tab bar icons corrected, same session (Kell): wrong Today icon.** The `#section-app` tab bar (`tab-today`/`tab-entries`/`tab-growth`) was using a placeholder circle-with-dot for Today — internally consistent across all 3 tab screens, but wrong against the actual locked design. Pulled the real icon set directly from Figma's canonical `TabBar v3 (3-tab) / Today Active` component (file `t5MUGEtpeFcUixobvHiYMc`, node `1167:136` — the version actually instanced in the locked "P6 — Menu / Navigation — 3-Tab Shell (v3)" section per T-076, distinct from an older 4-tab v2 and several unrelated exploratory nav variations that also happened to reuse a circle-dot placeholder). Corrected all three icons to exact Figma geometry: **Today is a house/home glyph** (was circle+dot — the real bug), **Entries** is two rounded-top-only rectangles (open book — was rounding all 4 corners), **Growth** bar-chart proportions tightened to match exactly (5/11/17 x-positions, 6/10/14 heights). Verified in-browser across all three tab screens, zero console errors. Note on tooling: the Figma MCP is a desktop-app bridge and normally can't browse pages that aren't open on screen — but a direct node-id URL (`?node-id=1139-48`) let it jump straight to the node even without that page being the active one in Figma desktop.

**Revised same session, later (Kell): the bar/flame relationship flipped.** New locked model — onboarding is already complete by the time the user reaches capture, so **the bar is always 100% filled inside capture** (not held at 92% until done, which was the prior session's design). The flame is the only thing that still climbs, and it does so **in thirds tied to conversational milestones**, not raw screen count: a third once the user's first message is in, two-thirds once Dwelly has responded, full at the journal reveal. Implemented via an explicit `loopStage: 0|1|2|3` annotated on the meaningful screens in every `ROWS` entry and in `cardFlow` (mechanical screens — recording, transcribing, live-typing-in-progress — carry no `loopStage` and simply hold the flame at whatever stage came before them, so a raw step index never moves it). `continuityBar()` walks screens up to `currentStep` and uses the last-seen `loopStage`. Verified end-to-end via the Topic Card flow: 0px (entry) → 6px = 1/3 (message sent) → 12px = 2/3 (Dwelly responded) → 18px = full + `flame-glow` (journal revealed), bar steady at 354px throughout.

## Known Gaps

- P6 Menu/Navigation has no live click-through yet — only static example screens; not yet folded into the combined prototype.
- In-app tab bar (Today/Entries/Growth) isn't cross-wired — see Combined Prototype row above.

## Correction (Aug 24, 2026): the published `dwelly_capture_flow` Artifact is NOT the Combined Prototype

Prior session notes (MEMORY.md, Aug 24) referred to a "canonical Artifact" at `https://claude.ai/code/artifact/bf748e9b-1737-435d-838d-f3bca8f689fb` as the intended home for the 3-way merge, and recorded a "Dwelly" → "Dwelly" rename as having been applied there. **Verified today: that artifact (titled `dwelly_capture_flow`) is a different, self-contained prototype** — a single-screen capture-flow state simulator driven by pickers (connection/duration/intent/mic/transcription state), with no `oc-`/`po-`/`s0*` screen IDs, no hub, and no tab bar. It is fully renamed to "Dwelly" (0 residual "Dwelly" mentions) and appears to be its own finished deliverable, unrelated to `docs/Dwelly_Full_Prototype.html`. **Do not publish the Combined Prototype to that URL** — it would silently overwrite different, seemingly-complete work. If future sessions want the Combined Prototype shareable as an Artifact, publish it as a new artifact rather than reusing that URL, unless Kell explicitly confirms otherwise.

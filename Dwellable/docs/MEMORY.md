# Dwellable Native — Session Memory

**📦 Older session entries (July 22, 2026 and earlier) archived to [`MEMORY_ARCHIVE.md`](MEMORY_ARCHIVE.md) to keep this file lean for session-start reads.** Read the archive only if you need historical detail on a specific past session.

## Next Session Objective (August 28, 2026 close)

**Confirmed Pending Items:**
1. **Design the Legal & About subpage (T-134) — the last of Pillar 9's 4 Settings subpages.** Security & Privacy, Preferences, and Support & Feedback are all done (MVP + Post-MVP parity, built in Figma). Legal & About hasn't been touched at all yet: About Dwellable, Version History (dynamic, not hardcoded per T-134), Terms of Service / Privacy Policy links. Follow the same pattern established this session — Artifact first for Kell's confirmation, then build in Figma into both the "MVP" and "Post-MVP" Figma sections on the "P9 - Account Profile" page, maintaining the parity rule (whatever's in MVP must exist in Post-MVP too).
2. **Design the in-app Account Deletion flow (T-095).** Apple App Store Guideline 5.1.1(v) requires self-service in-app account deletion; no design exists for this yet anywhere in Pillar 9. Needs: entry point (likely Security & Privacy or a new spot), confirmation flow, and copy — should follow the same soft-delete/confirmation-copy conventions already locked for journal entries (T-158) where applicable, though account deletion itself is almost certainly a hard/irreversible action requiring its own distinct confirmation weight.
3. **Resolve T-178 and T-179 — both are open design/systems questions, tickets only, no design work done yet.** T-178: does changing Rhythm or Intent post-onboarding do anything beyond silently storing the new value — should they ever be checked against each other, and if so how, without becoming prescriptive (Authority Guardrails: invitational only). T-179: reconcile the Notifications "Manage Preferences" screen (simple 3-mode picker) against Pillar 8's actual locked 7-stage funnel architecture (T-084/T-085/T-086), plus the offline-write-sync question and 5 system-oriented scenarios (OS permission revocation, multi-device conflicts, save failure, timezone effects on Quiet Days, first-time state) folded into the same ticket. Both need real design/systems thinking before any implementation ticket can be written — don't defer again.

**Rationale:** Item 1 finishes the Settings subpage set Kell has been working through subpage-by-subpage all session — Legal & About is the only one left, and leaving it half-done risks the same kind of docs-drift that hit P4/P5 in prior sessions. Item 2 is an App Store compliance requirement with zero design coverage today — worth surfacing before it becomes a launch blocker discovered late. Item 3 is carried forward from the prior session's close (T-178) plus this session's own new ticket (T-179) — both are explicitly flagged by Kell as needing real design thinking, not just ticket text, and both risk becoming stale/forgotten the longer Pillar 9's subpage work continues without them.

---

## Next Session Objective (August 27, 2026 close, third same-day session — superseded by the entry above)

**Confirmed Pending Items:**
1. **Design Rhythm/Intent change behavior + their relationship as formation drivers (T-178).** Kell's explicit framing at session close: Rhythm and Intent aren't static profile fields — they're meant to be behavioral drivers of the whole formation loop (e.g. a "deepen intimacy with God" intent should imply/expect a matching capture rhythm), but nothing in the system connects them today. Needs a design pass covering: what happens experientially when a user changes Rhythm or Intent post-onboarding from the new Account Profile screen; whether/how a mismatch between the two should ever be surfaced (must stay invitational per the Authority Guardrails — never prescriptive, never "you should pray more"); and what part of the app (if any) reflects this relationship back to the user. This was raised as a systems-design question, not yet scoped as an engineering ticket.
2. **Continue Pillar 9 (Account Profile) subpage design, one at a time, Artifact-first.** Base screen (identity fields + grouped Settings card) is confirmed and built in Figma (new page "P9 - Account Profile"). Next: the 4 Settings subpages (Security & Privacy, Preferences, Support & Feedback, Legal & About) plus the previously-artifact-confirmed Recently Deleted screen (T-176) — each needs its own Claude Artifact confirmed by Kell before touching Figma, per the standing rule locked this session (see `feedback_artifact_before_figma` memory).
3. **Write the Intent Check's new timing rule into docs/tickets.** Locked this session but not yet written down: the Intent Check prompt ("Is Dwellable helping you [intent]?") must not fire from first login — it should wait until the user has used the app ~2 weeks / after the free trial ends. Needs updating wherever Scenario 3 (Weekly Intent Check) is documented (Notion P9 User Scenarios page, `PILLAR_SETTINGS_STRATEGY.md`) plus a ticket note for the actual trigger-condition logic. Also carry forward: the "Getting to Know You" rotating-question concept was explored and parked (not deleted) — revisit only if Kell brings it back up.

**Rationale:** Item 1 is Kell's own explicit systems-thinking flag at close — a real product question (do Rhythm and Intent need to reconcile with each other?) that shouldn't get lost before Pillar 9's subpages are built on top of fields that might behave differently than assumed. Item 2 continues the in-progress pillar using the newly-corrected workflow order. Item 3 is small but time-sensitive bookkeeping debt of exactly the kind that's slipped multiple sessions in a row on other pillars this cycle (P4/P5) — better to write it down now while the decision is fresh than let it become another multi-session catch-up item.

---

## Next Session Objective (August 27, 2026 close, second same-day session — superseded by the entry above)

**Confirmed Pending Items:**
1. **Finish syncing `docs/P4_SUMMARY.html` and the Notion "P4 User Scenarios & Acceptance Criteria" Design Status table.** This is the THIRD session in a row this has slipped — flagged Aug 26, flagged again Aug 27 (first session), still not done after Aug 27 (this, second session). P4 itself is now fully confirmed complete (all 11 scenarios built or deliberately descoped), so this is pure bookkeeping catch-up, not design work — should not slip a fourth time.
2. **Get Kell's decision on T-159** (Synthesis Error Fallback): the ticket's original premise — raw transcript permanently stands in as the journal body after retries exhaust — contradicts the Aug 27 (earlier) decision that Pending retries silently/indefinitely with no permanent fallback ever. Does Pending truly never dead-end, or is there still some ceiling? Update T-159 once answered.
3. **Create the Notion "P5 User Scenarios & Acceptance Criteria" page** (doesn't exist yet — P4 has one, P5 doesn't) and **sync `docs/PILLAR_5_SEARCH_STRATEGY.md`** to reflect this session's locked corrections: Prayed/Object filters dropped (Mood + free-text only), Pending entries excluded from search entirely, Search confirmed to run fully offline, and the new T-176/T-177 tickets.

**Rationale:** Item 1 is overdue debt actively costing future sessions time (re-deriving what's already decided). Item 2 blocks T-159 from being buildable — right now it describes a design that was explicitly reversed. Item 3 mirrors item 1's mistake at the start rather than after the fact — Pillar 5 was fully designed this session (6 scenarios, ~14 Figma screens) but its own docs are already behind, same failure mode as P4's.

**Broader next-session scope (Kell's explicit call at this close):** after the 3 catch-up items above, move on to designing **Pillars 9, 10, and 11** (per current `TICKETS.csv` epic naming — confirm exact pillar names/scope at session start the same way Pillar 5's numbering was double-checked this session, since this file's pillar numbering has drifted/collided more than once before, e.g. the T-174 Pillar 6 naming collision).

---

## Next Session Objective (August 27, 2026 close, first same-day session — superseded by the entry above)

**Confirmed Pending Items:**
1. **Update `docs/P4_SUMMARY.html` with every decision locked across the last two sessions** — it is now stale against: Pending badge/flame treatment (real Dwelly flame asset, dot+text pattern, two-line reassurance copy), no manual Retry anywhere in Pending (sync retries silently and indefinitely in the background instead), the offline indicator dropped entirely from Edit and View (nothing in either screen actually depends on connectivity — Save always writes locally first), the hero-photo layout (full-bleed photo above title, title left-aligned, moods between title and body), the Edit Moods bottom-sheet picker, the toolbar dropping its Tag icon in favor of an inline "+ Add mood" pill in the mood row, and the View Original chat thread's staggered same-sender clustering (replacing uniform stacked bubbles). Also add the new T-120 requirement (Dwelly must wait for multi-texters to finish sending before responding) to whichever doc owns Pillar 1's conversational-loop spec, if `P4_SUMMARY.html` isn't the right home for it.
2. **Sync the Notion "P4 User Scenarios & Acceptance Criteria" Design Status table** — untouched since the first P4 session two days ago; doesn't reflect any of the ~20 scenarios built across the two most recent sessions (full online set, full Pending set, Add Photo/Camera/Voice, Pending View Original). This is now flagged for a second session in a row — should not slip a third time.
3. **Do a cleanup pass on the Figma file itself before building more.** Concurrent editing across sessions has left real clutter: multiple duplicate copies of several sections at different node IDs, and at least one section that got auto-nested inside another mid-session and had to be manually detached. Worth consolidating to a single canonical copy of each scenario before the next round of design work, both for Kell's sanity navigating the file and to stop future sessions from second-guessing which node ID is current.

**Rationale:** With the full online + Pending scenario sets now built and reviewed, the actual Figma state has pulled well ahead of both reference docs (Notion, P4_SUMMARY.html) — letting that gap widen further risks a future session working from stale assumptions the way this one had to re-derive node IDs and re-verify screen content repeatedly. The Figma cleanup is preventative: the file's clutter is what caused this session's two real bugs (content nested inside the wrong section, a screenshot showing a garbled multi-panel bleed-through) — both were symptoms of the same underlying mess, not one-off mistakes.

**Rationale:** Kell drove a full numbered inventory of the "online" (synced) state this session and confirmed all 13 items are covered — pending/offline is the clearly-named next branch, not a new discovery. The Notion sync is overdue bookkeeping debt from skipping it mid-session to keep pace with Kell's rapid-fire scenario list. The duplicate-section note protects the next session from repeating this session's own detached-section bug.

---

## Next Session Objective (August 26, 2026 close, first same-day session — superseded by the entry above, kept for the historical record)

**Confirmed Pending Items:**
1. **Build Scenario 2 (Edit — Approved, happy path) in Figma + publish as a Claude Artifact.** The locked pattern is settled (✕ / centered "Edit Entry" / Undo / gold checkmark-Save header, floating Photo·Camera·Mic·Tag toolbar above the keyboard, date read-only, "Untitled"/"Start writing..." empty-state placeholders) — this is the next screen in the one-at-a-time queue Kell set this session, and unblocks the toolbar's real destinations (Tag → Mood Picker, Photo/Camera → native picker).
2. **Build Scenario 6 (View Original Capture) next**, since the Ellipsis Menu screen built this session already points to it as a live destination — the read-only transcript screen it should navigate to doesn't exist yet in this rebuild.
3. **Build the remaining 5 scenarios** (4: Synthesis Fails fallback, 7: Add/Remove Photo, 8: Edit Moods via Tag, 10: Approved-edited-then-goes-offline, 11: Connection-restored-mid-edit) — same pattern each time: screenshot-verify at true 393×852 size, publish as its own Claude Artifact, wait for Kell's review before the next one. Mark each ✅ Done in the Notion "P4 User Scenarios & Acceptance Criteria" Design Status table as it's confirmed.

**Rationale:** Kell explicitly asked to pick this up "one screen at a time" with an artifact for each, after this session's docs-first reset (Notion page fully rewritten against the current single-screen architecture, `P4_SUMMARY.html` synced) and a working, confirmed header/menu/toolbar pattern. 4 of 11 scenarios are done (Pending, View, Star/Unstar, Soft Delete — Design Status tracked in Notion); 7 remain, in the order above.

---

## Session: August 25, 2026 — Three-Prototype Merge Built + Verified + Onboarding Capture Simplified to One Loop

### 🎯 TL;DR
Fully rebuilt and verified the combined prototype ([`docs/Dwellable_Full_Prototype.html`](Dwellable_Full_Prototype.html), same Artifact URL `054b3364-c5b3-4c16-9714-470fbadc8b3d`). Onboarding sequence shortened (4 screens cut vs the old P0), real Dwelly capture flow spliced in as its own module (Kell's `dwelly_capture_flow` Artifact `bf748e9b`, NOT the old static file — the confusion in prior sessions was mine), and post-onboarding app stitched at the end. All CSS/JS namespaced so nothing cross-collides. Onboarding pre-capture screens got a persistent gold pill loading bar (starts at name-entry `s03`, reaches 100% at `s20 preparing-space`), and the capture-flow entry screen carries the same bar continuing through the loop as an 85%-100% band.

**Big shift Kell locked at end of session: onboarding capture is now ONE loop only** — entry → user's message → Dwelly's response → journal reveal. No Done button, no exit affordance, no conversation continuation. Applied to all 4 rows (Self/Dwelly-prompted × Text/Voice) in `capture_flow_clean.html`. The Done button lives on for the real post-onboarding capture flow (open-ended conversations that genuinely need an exit).

### Key decisions locked (carry forward)
- **Onboarding capture is a single guided loop.** No Done during onboarding. Cap enforced in code by trimming each ROW's `screens[]` array. Applies only to the onboarding version; post-onboarding capture retains multi-turn conversation + Done exit.
- **Loading bar visual language locked**: gold pill (#c9b27a) on a visible dark track (#3a3530), 6px tall, positioned at (24, 68) inset from the screen edges (not full-width). Same treatment applied consistently across all 18 pre-capture screens + the capture entry.
- **Onboarding sequence trimmed** — cut `s05` (Did you know God…), `s06` (What happens if we forget…), `s08` (Most of the time you probably aren't carrying…), `s09` (So instead like many of us…). Real copy for the surviving screens (s07 "Imagine you're on a walk…") corrected to match the Figma playground reference verbatim.
- **Dwelly rename applied everywhere in-app** — every "Dwellable" instance in in-app copy is now "Dwelly." The two remaining "Dwellable" strings in the prototype are dev-only labels (`<title>` and `.stage-header`) preserved intentionally. Same for the 2 leftover "Dwellable" text nodes in Figma playground screens (`11-gentle-reminders` app-name, `12-privacy` description), both corrected.
- **New "capture your first moment →" CTA** added to `14-preparing-space` bottom-right (matching the "create account →" style exactly — Inter Regular 13px, gold, right-aligned at x=24 from right edge, y=840). Wired to trigger the same `stitchGoTo('section-capture')` bridge the auto-advance timer uses.
- **New flame vector** pulled directly from Figma (`1227:1497` node → SVG asset `c0e7df94-84cd-41a5-a23b-0789ca10c306.svg`) and swapped into the welcome screen's `<img class="flame-icon">` — reuses the existing 3.2s flicker animation.
- **Prayer-hands reward icon 🙏 REMOVED** — was there earlier this session on the bar; Kell felt it was too busy. Now bar is bar-only.
- **Post-first-message Done placement**: dropped mid-decision when Kell chose the one-loop route instead. If ever reintroduced, the working absolute-positioned pattern was `.done-below-bar { position: absolute; top: 100-150px; right: 24px; }` — but pixel-tuning was hard because two Done elements were being rendered simultaneously by both `entryHeader()` and `chatHeader()`. Documented for whoever picks this back up in post-onboarding capture.

### 🚨 Session frustrations logged (root-cause + carry-forward rules)
- **Twice this session shipped changes that Kell had to correct against real Figma.** Root cause: I was editing the old standalone `P0_NavChrome_Prototype.html` file instead of pulling from the actively-iterated Figma playground page. **Rule going forward: before editing any onboarding screen, pull the exact current copy/layout via `get_metadata` + `get_screenshot` against the Figma playground first. Never trust the standalone HTML source alone — it drifts.**
- **Pixel-tuning got stuck for ~4 rounds on the Done placement** because two Done elements existed in the DOM simultaneously (one from `entryHeader()`, one from `chatHeader()`), and my CSS updates were being visually overridden by whichever one rendered first. **Rule: when a CSS change appears to have no effect, `querySelectorAll` for the target class BEFORE assuming the rule doesn't apply — orphaned duplicate elements are the most common cause of "no-move" bugs in this prototype.**
- **The "canonical artifact" URL from Aug 24's MEMORY entry was still misleading in my head for the first several turns of this session.** `dwelly_capture_flow` (`bf748e9b`) is the real capture flow content, and the Combined Prototype (`054b3364`) is a distinct, separately-published artifact. Both live on. Do not overwrite `bf748e9b` when republishing the merge.

### Files touched
- `docs/Dwellable_Full_Prototype.html` (rebuilt via `/tmp/dwelly_check/assemble.py` from `P0_NavChrome_Prototype.html` + local `capture_flow_clean.html` + `P1_PostOnboarding_Prototype.html`, republished as Artifact `054b3364-c5b3-4c16-9714-470fbadc8b3d`)
- `docs/P0_NavChrome_Prototype.html` (4 screens cut, s07 copy corrected, flame SVG swapped, "capture your first moment →" CTA added to s20, loading bar added to s03-s20, "Dwellable" → "Dwelly" throughout in-app copy)
- Figma playground page `t5MUGEtpeFcUixobvHiYMc / 1212:48` (new pill-bar rendered on all 18 sequence screens + capture entry, Dwelly rename for 2 remaining `Dwellable` text nodes, "capture your first moment →" CTA added to `14-preparing-space`)

### 🚨 Next Session Objective (August 25, 2026)

**Confirmed Pending Items:**
1. **Pillar 4 — Journal Creation design work.** Kell explicitly requested P4 next at session close. Reference `docs/P4_SUMMARY.html` (design skeleton complete). This is the second half of the MVP core loop (Capture → Process → **Journal**) and the natural next design area now that P0 (Onboarding) and the P1 capture flow are prototyped and stitched.
2. **Verify the combined prototype's onboarding-capture handoff → journal reveal reads correctly end-to-end**, given today's one-loop + no-Done changes. Live click-through in Browser pane before doing any P4 work — the transition from Dwelly's response to the journal card is now the pivotal moment the whole flow builds toward, and P4 will be layered on top of exactly this handoff.
3. **Wordmark treatment resolved: uppercase "Dwelly" (initial cap), not lowercase.** Kell chose uppercase at session close. Apply consistently in all future design/copy, including anywhere the current prototype still renders "dwelly" lowercase (welcome-screen wordmark and any body copy). This is a locked decision, not a pending question.

**Rationale:** P4 is the natural next design area — Kell asked for it explicitly, and the prototype hand-off point that P4 will build on top of just got substantially reshaped today (one-loop cap changes what "processing complete" means). Verifying that handoff before adding to it prevents re-work.

---

## Session: August 24, 2026 — Dwelly Rename Finished in Canonical Artifact, Real Flame Located, Merge Scripted (Not Built)

### 🎯 TL;DR
Three threads, all design/prototype (no engineering ticket changes). **(1)** Root-caused why the prior session rebuilt the P1 onboarding-capture flow instead of reusing the existing canonical Artifact: an auto-compaction dropped the artifact from the carried-forward record, so the next turn acted on incomplete history and never checked the artifact list. **(2)** Finished the "Dwellable" → "Dwelly" rename in the canonical capture-flow Artifact (5 residual mentions), tagline **"Steward every moment with God" deliberately unchanged**, and republished to the same URL (`bf748e9b-1737-435d-838d-f3bca8f689fb`). **(3)** Located the real flame logo Kell flagged as "off" — it's the base64 PNG in `docs/P0_NavChrome_Prototype.html` s01 (166×120, outlined gold, S-curve top, pinched waist), extracted to scratchpad `p0_flame.png`.

### ⚠️ Explicitly NOT Done (do not assume these are live)
- The **three-prototype merge** (P0 onboarding → capture flow, one continuous click-through in the canonical Artifact) was only **scripted** in `scratchpad/merge.py` — never run, never built, never verified in-browser, never published.
- The **flame swap** into the canonical Artifact is likewise pending — the old teardrop-SVG `ICONS.flame` is still what's live.

### Key constraints locked (carry forward)
- Tagline **"Steward every moment with God" stays unchanged** through the rename.
- Do **NOT** freehand-redraw the flame — use the real `p0_flame.png` asset.
- Edit the canonical Artifact **in place** via the Artifact tool's `url:` param; stop forking new `docs/*.html` files for this flow. Canonical URL: `https://claude.ai/code/artifact/bf748e9b-1737-435d-838d-f3bca8f689fb`.
- On resume, **check the artifact list first** before assuming a flow doesn't already exist (this is the root cause of the earlier rebuild).

### 🚨 Next Session Objective (August 24, 2026)

**Confirmed Pending Items:**
1. **Build, verify, and publish the three-prototype merge.** Run `scratchpad/merge.py` (or rebuild it), open the merged file in the Browser pane, click through BOTH phases end-to-end (onboarding s01→s20 auto-advancing into the capture flow via `startCaptureFlow()`), fix any collision/handoff bugs, then publish to the canonical Artifact URL. This is the primary unfinished deliverable — Kell asked to "bring the three prototypes together into one."
2. **Swap the real flame logo into the canonical Artifact.** Replace the old teardrop-SVG `ICONS.flame` in the capture flow with the real `p0_flame.png` flame (as base64 PNG or a faithful SVG derived from it), preserve the existing animation, apply consistently across onboarding + capture, and verify it renders correctly before publishing.
3. **"Improve the Dwelly design" — get specific direction from Kell.** He asked to improve the design but the concrete scope is undefined; open next session by confirming what "improve" means (fidelity pass on the merged prototype, specific screens, or a broader redesign) rather than guessing.

**Rationale:** The rename and asset-location work landed, but the actual thing Kell asked for — one unified, correctly-branded prototype — is scripted but not built or verified. Verifying in-browser before publishing matters here specifically because a botched merge is exactly what frustrated Kell before.

---

## Session: August 4, 2026 — Nav-Chrome HTML Prototype Built + Iteratively Corrected Against Live Figma

### 🎯 TL;DR
Built `docs/P0_NavChrome_Prototype.html`, a standalone 20-screen click-through HTML port of the nav-chrome (back button + login link) work from the prior session, including the previously-missing `welcome-screen` cover. Then ran a long iterative correction pass after Kell caught repeated real mismatches against the live Figma file — fonts, colors, icons, images, spacing, and in three cases (`11-gentle-reminders`, `12-privacy`, `13-account-creation`) full structural rebuilds, since those screens had moved from big-CTA-button patterns to a simple "tap to continue →" text-link pattern since last touched.

### Key Learning (carry forward)
Several screens were built once early in the session from a single Figma pull and never re-verified as the live file kept changing underneath — including one case (`11-gentle-reminders`'s notification icon) where Kell edited Figma *mid-session* and a stale pull looked like a browser-caching issue at first. Fix going forward: pull each screen's **full current spec fresh** before touching it — never assume an earlier-in-session pull, or a similar-looking sibling screen, still matches. Figma is a live, actively-edited source.

### Files Changed
- `docs/P0_NavChrome_Prototype.html` (new)
- `TICKETS.md` (session log entry, no ticket status changes — pure design/prototype work)

### 🚨 Next Session Objective

**Confirmed Pending Items:**
1. Kell to review the fully-corrected `P0_NavChrome_Prototype.html` end-to-end and confirm/reject adopting the nav-chrome copy (back button + login link) as the canonical P0 design, or continue iterating.
2. Resolve the Pillar 8 Stage C–G / Pillar 3 (Prayer, now Post-MVP) dependency question flagged in the August 3 session — still open.
3. Once the nav-chrome design is confirmed, decide whether to reapply the same back-button/login-link treatment to the original (untouched) row in Figma, or formally adopt the HTML prototype as the reference and archive the original.

**Rationale:** The prototype is now believed accurate against Figma, but every prior "I think it's correct" claim this session turned out to have a real gap — so the next session should open by having Kell confirm it directly rather than assuming this closeout entry is the final word.

---

## Session: August 3, 2026 — Pillar 3 (Prayer) Deferred to Post-MVP

### 🎯 TL;DR
While reviewing the merged Problem-First onboarding demo loop, flagged that `07e-dwelly-prays` was missing from the capture→process→journal sequence. Kell confirmed this is intentional: **MVP scope is now deliberately Capture → Process (Dwelly conversation) → Journal — three things, not four.** Prayer (Pillar 3) moves to Post-MVP.

### Key Decision Locked
**Pillar 3 (Prayer) is Post-MVP**, not merely resequenced. Rationale (Kell): even three things (Capture, Process, Journal) may already be a lot of scope to ship well. Capture alone is insufficient (too many existing tools already do plain capture — Notes, Voice Memos). Processing alone is insufficient without a place to recall what's been captured (the Journal). Prayer, by contrast, is a nice-to-have layered on top of an already-complete loop — you can capture and journal a moment without ever praying over it — so it doesn't carry the same all-or-nothing necessity the other three do.

### What Was Done
- Confirmed with Kell this was a deliberate cut, not an oversight from the onboarding merge work
- Updated `docs/PRD.md`: Pillar 3 status line (✅ Design Complete → ⭕ Deferred to Post-MVP) + new "MVP core loop" callout under Build Phases
- Updated `TICKETS.md` with a dated session entry (no engineering ticket status changes — this is a scope/sequencing decision, not implementation progress)
- All existing Pillar 3 design artifacts (2-option skeleton, Rich Context integration, Gallery/Soak Mode/Reflection Prompts architecture) left untouched — still valid whenever Prayer is picked back up post-MVP

### Open Item Flagged (not resolved this session)
Pillar 8 (Notifications)'s Stage C–G was reclassified July 20, 2026 as depending on "Pillar 3 shipping first" — framed then as a **sequencing** dependency, not a phase deferral. Now that Prayer isn't in MVP scope at all, that framing likely needs revisiting (does Stage C–G wait for Post-MVP too, or get redesigned to not depend on Prayer?). Next session should raise this with Kell explicitly rather than assume either answer.

### 🚨 Next Session Objective
**Primary:** Resolve the Pillar 8 Stage C–G / Pillar 3 dependency question flagged above. **Also:** continue Pillar 1 (Capture) design work per the July 31 handoff — still the primary next-pillar focus once this scope question is closed.

---

## Session: July 31, 2026 — Pillar 0 Design LOCKED COMPLETE (12/12 Screens) + Doc Corrections

### 🎯 TL;DR
**Pillar 0 (Onboarding) design is now fully complete.** Verified the live Figma file directly (not just docs) and found two things July 30's memory got wrong: the canonical row is the **`-gold` suffix row at y=1388** (not the unsuffixed row at y=2498 — that row, and a `-dark` suffix row at y=8730, are confirmed **archived** by Kell), and the actual fonts in use are **Instrument Serif** (headlines) + **Instrument Sans** (body/labels/badges) — not Cormorant Garamond + SF Pro as previously recorded. Built the one missing screen (`capture-method-gold`), then Kell removed it from Pillar 0 — it belongs to Pillar 1 (Capture), not Onboarding. **Pillar 0 now stands at 12/12 screens designed and locked.**

### What Was Done
- Reconstructed the live Figma state from scratch (Notion/MEMORY had no working node-id link) — file key `t5MUGEtpeFcUixobvHiYMc`, confirmed via `whoami` this is Kell's own Figma account with Pro team access; the file simply wasn't open in Figma desktop at session start (this Figma MCP reads the desktop app's open file, not arbitrary cloud files by key — get a node-id URL from the open file if this happens again).
- Found **three parallel "row" iterations** on the `P0 — New Onboarding` page (canvas id `14:2`), all sharing the same 13 screen-concept names:
  - **`-gold` suffix, y=1388, ids `248:xx`** — ✅ **CURRENT / CANONICAL** (confirmed directly by Kell)
  - Unsuffixed names, y=7638, ids `220:xx` — ARCHIVED (daytime forest photography + sage button on Welcome)
  - **`-dark` suffix, y=8730, two duplicate-looking sets, ids `247:xx` and `246:xx`** — ARCHIVED
- Audited every screen in the canonical `-gold` row against a live screenshot (not assumed from names). Result: **10 of 13 named frames were already fully built** (welcome, what-dwellable-does, name-entry, intent-selection, rhythm-selection, gentle-reminders, privacy, account-creation, moment-types-loading, moment-example-modal). Two frames (`dwelly-intro-gold`, `personalized-transition-gold`) had headline+subhead+CTA but an empty body — **Kell confirmed these are intentionally minimal transition beats, not unfinished.** One frame (`capture-method-gold`) **did not exist at all** — only its archived-cream counterpart did.
- **Built `capture-method-gold`** (node was `253:2`, since deleted — see below): cloned the archived `capture-method` frame (220:538) to preserve its mic/keyboard icon vector geometry, then re-themed to match the locked dark/gold system exactly — extracted precise fills/fonts/corner-radii from `privacy-gold` (248:402) as the style reference: near-black `rgb(0.04,0.04,0.04)` container @ 24px radius, `#333`-equivalent 1px border, card rows at `rgb(0.102,0.102,0.11)` @ 16px radius, gold accent `rgb(0.788,0.698,0.478)` for icon strokes/badge pill/current-progress-dot, muted body text `rgb(0.639,0.620,0.596)`, Instrument Sans Bold/Regular 14px/13px for card titles/descriptions, Instrument Serif Regular 28px/125% line-height for the headline. Progress dots: confirmed via the archived reference that Pillar 0 tracks **12 steps** (not 13 — `moment-example-modal` is a modal-on-`moment-types-loading`, not its own step), so `capture-method` was correctly the dot-12/final position.
- **Kell removed `capture-method-gold` after reviewing it** — correct call: capture method selection (voice vs. type) is Pillar 1 (Capture) territory, not Pillar 0 (Onboarding). The screen's content/styling work isn't wasted — same visual system, just needs a new home in Pillar 1's design docs/Figma section whenever that's picked up. Flagging as a carry-forward, not re-opening Pillar 0 for it.

### Key Decisions Locked
1. **Pillar 0 (Onboarding) design: COMPLETE at 12/12 screens.** No more design gaps. Canonical row: `welcome-gold, dwelly-intro-gold, what-dwellable-does-gold, name-entry-gold, personalized-transition-gold, intent-selection-gold, rhythm-selection-gold, gentle-reminders-gold, privacy-gold, account-creation-gold, moment-types-loading-gold, moment-example-modal-gold` (all ids `248:xx`, y=1388, Figma file `t5MUGEtpeFcUixobvHiYMc`, page `P0 — New Onboarding`).
2. **`capture-method` belongs to Pillar 1 (Capture), not Pillar 0.** Whoever picks up Pillar 1 design next should know the voice-record/type-instead card content and dark/gold styling pattern already exists (was live in the file as node `253:2` before Kell deleted it, and the archived cream original is still at node `220:538` for reference) — it just needs rebuilding in the right pillar's Figma section rather than reused in place.
3. **Correction — actual fonts are Instrument Serif (headlines) + Instrument Sans (body/labels)**, not Cormorant Garamond + SF Pro as July 30's memory recorded. Verified directly from live node `fontName` properties on `privacy-gold`, not inferred.
4. **Correction — canonical row location is y=1388 (`-gold` suffix), not y=2498 (unsuffixed).** The unsuffixed row and both `-dark` rows are archived. If a future session sees "y=2498" cited anywhere (old Notion pages, old MEMORY entries above this one), treat it as stale — this entry supersedes it.

### Key Learning
**This is the third documented instance of Figma drifting ahead of MEMORY.md/Notion without being written back** (prior instances: June 30 reconstruction, July 2 afternoon session). This time it wasn't just a missing summary — the recorded canonical-row location and font system were both actively wrong, not merely incomplete. **Root cause this time:** the Figma MCP used in this session is a **desktop-app bridge**, not a cloud API — it only sees whatever file is currently open in Figma desktop, and returns a deceptive-looking empty "Page 1" (not an error) when the target file isn't open. A future agent hitting an empty/blank result from `get_metadata` on a file key that's well-documented elsewhere should suspect this before concluding the file is actually empty — ask Kell for a live node-id URL from the currently-open file rather than trusting a stale file key alone.

### 🎨 Same-Day Extension: Design System + Edge Cases Built (still July 31, 2026)

After the completion above, Kell asked for two more things before moving to Pillar 1: (1) extract a proper design system/component library from the now-locked happy path, and (2) design all edge/error states for Pillar 0. Both done this session.

**Design system audit found real drift, not just missing organization:** an unused `Onboarding/Colors` variable collection already existed from an earlier session, but built for the old cream theme — none of it was bound to the current `-gold` screens (every color was raw/hardcoded, `boundVar: null`). A full raw-value inventory across all 12 screens surfaced: a stray third font (**DM Sans**, ~6 instances — all 3 checkmark glyphs on `intent-selection` plus a couple labels — everything else uses Instrument Sans/Serif), **8 different headline sizes** (24–46px) with no locked scale, container corner-radius split 24 vs. 26, and `what-dwellable-does`'s 3 icon circles each carrying a different subtle background tint vs. every other screen's shared neutral icon-circle style.

**Kell's calls on the 4 real forks (all recommended options):** standardize icon-circle backgrounds to neutral everywhere; password requirement = 8+ characters, no complexity rules; error/validation copy = plain direct system text (not Dwelly-voiced); required-selection screens (intent/rhythm) block Continue until ≥1 option is chosen.

**Built — new collections `Onboarding/Gold Colors`** (19 tokens, all scoped, no `ALL_SCOPES`) **and `Onboarding/Gold Metrics`** (20 spacing/radius tokens), **11 text styles** (`Onboarding/Heading`, `/Hero`, `/Badge Label`, `/Card Title`, `/Description`, `/Row Label`, `/Field Label`, `/Field Value`, `/Button Label`, `/Status Time`, `/Error Message`). New `state/error` (warm coral `rgb(224,122,95)`, not harsh red — matches the palette's low-saturation warmth) and `state/disabled-*` tokens invented since neither existed in the file yet.

**10 components built on the new `Onboarding — Components` page:** `DwellyBadge`, `ProgressDots` (12-step track), `PrimaryButton` (Default/Disabled), `IconCircle` (Small/Large), `StatementCard`, `SelectableCard` (Checkbox/Radio × Default/Selected, 4 variants), `TextInput` (Default/Focused/Error/Disabled, 4 variants), `CheckboxTerms`, `StatusBar`. Discovered mid-build that `gentle-reminders`'s toggle-looking rows are actually the same `option-card`+radio-indicator pattern as `rhythm-selection`, not a separate toggle component — collapsed the planned component count from 11 to 10.

**Two real bugs caught and fixed during build** (both the same root cause — `figma.createAutoLayout()`/`createFrame()` default to an opaque white fill that has to be explicitly cleared): `StatementCard`'s inner `text-content` wrapper was covering the card in white until fixed; `ProgressDots`' outer track frame had the same issue. Worth remembering for any future from-scratch Figma component work in this file — always explicitly set `fills = []` on non-terminal wrapper frames, don't assume an unset fill is transparent.

**9 edge-case screens built on a new `Onboarding — Edge Cases` page**, all using real component instances (not freehand copies): `account-creation` × 6 (email format error, password-too-short error, confirm-mismatch error, duplicate-email error with a "log in instead?" prompt, terms-unchecked default-disabled state, network/server-error banner), `intent-selection` and `rhythm-selection` × 1 each (zero-selected, Continue disabled), `moment-types-loading` × 1 (load-failure state with red status text + red progress bar + "Try again" retry button). One layout bug caught and fixed: the network-error banner's width wasn't constrained, causing text to overflow past the screen edge — fixed by explicitly setting `layoutSizingHorizontal = 'FIXED'` on the banner before letting its text child `FILL`.

**Follow-up fix (same session, after Kell reviewed):** Kell asked for the disabled Continue button to be visibly "grayed out" (already was) plus an explanatory prompt — added "Select an option to continue." centered above the button on both zero-selected screens. This exposed the acknowledgment-line nit flagged above more clearly (now visibly contradicted the new hint), so removed the "Thank you, I'll keep that in mind…" / "That sounds like a good rhythm" lines from both zero-selected reference screens — they only make sense post-selection. Nit resolved, not just flagged.

### 🔗 Same-Day Extension #2: 12 Happy-Path Screens Rebound to Tokens + QA Checklist Built

Kell asked to close both remaining follow-ups: rebind the 12 happy-path screens to the new `Onboarding/Gold` tokens, and produce a manual QA checklist for the 9 edge-case screens.

**Rebinding found and fixed 3 real bugs during the work (not just mechanical rewiring):**
1. **Variable-collection name collision** — the stale `Onboarding/Colors` (cream, ids `123:x`) and new `Onboarding/Gold Colors` (ids `257:x`) collections both have identically-named variables (`text/heading`, `accent/gold`, etc.). A naive name-only lookup grabbed the OLD cream-theme variable for several bindings — its `text/heading` is near-black, so several `what-dwellable-does` text elements went briefly unreadable (near-invisible dark-on-dark) until caught via screenshot verification and fixed by scoping all lookups to the new collection IDs explicitly, then repairing every fill/stroke that had landed on an old-collection variable.
2. **Checkmark glyph distortion** — applying `Onboarding/Badge Label` text style (built for the DWELLY badge) to `intent-selection`'s tiny 18×18 checkmark glyphs (same font/size by coincidence) added letterSpacing and altered layout enough to visually distort the ✓ into what looked like a stray mark. Fixed by excluding short glyph-text (≤2 characters) from blanket text-style application — only font-family and color get corrected for those, not the full paragraph style.
3. **Lost `UPPER` textCase** — `account-creation`'s field labels ("EMAIL ADDRESS", "PASSWORD") lost their uppercase transform when the `Onboarding/Field Label` text style was applied, since the style itself didn't carry `textCase: 'UPPER'` at creation time. Fixed by setting it on the style (so future applications carry it) and restoring it on the 3 already-affected labels.

**Also applied, per already-locked decisions:** `what-dwellable-does`'s 3 icon-circle backgrounds standardized to the shared neutral token (Kell's decision from earlier this session); container corner-radius drift (24 vs. 26) collapsed to 24; the stray DM Sans checkmark font swapped to Instrument Sans, matching everywhere else.

**Full 12-screen visual sweep run after fixes** — every screen confirmed pixel-matching its pre-rebind appearance except the explicitly-intended corrections above. No further regressions found.

**QA checklist built:** `docs/P0_EDGE_CASE_QA_CHECKLIST.md` — per-screen checkboxes with direct Figma node-id links for all 9 edge-case screens, plus 3 flagged open product questions (duplicate-email deep-link vs. static copy, network-error retry behavior, moment-types-loading retry scope) that aren't blocking but shouldn't get lost before engineering picks this up.

### 🎨 Same-Day Extension #3: Checklist Added to Figma + New Terms-Error State + Loading-Screen Layout Fix

Kell reviewed the work in Figma directly and asked for three more things, same session: (1) put the QA checklist on the actual Figma page, not just in the repo; (2) add a dedicated error state for the Terms/Privacy checkbox (distinct from the plain "unchecked" default state already built); (3) fix a real layout bug he spotted on `moment-types-loading — failed`.

**Checklist added to Figma:** built a `QA Checklist` frame directly on the `Onboarding — Edge Cases` page (top-left, x=-700), covering all 10 edge-case screens with checkbox-style rows, open questions highlighted in a distinct color. Mirrors `docs/P0_EDGE_CASE_QA_CHECKLIST.md` but lives where Kell is actually looking while reviewing.

**New edge case: Terms/Privacy not accepted (error)** — node `276:3`. Distinct from the existing "terms unchecked" default state: checkbox outline + label turn `state/error` red, plus an explicit error message ("Please agree to the Terms and Privacy Policy to continue."). Flagged an open question in the checklist: what actually triggers this state, given the button is already disabled until the box is checked? Needs an interaction-model decision with engineering, not a design-only call.

**Fixed `moment-types-loading — failed` layout bug:** the retry button (added earlier this session) was flush against the left edge (x=0, all margin dumped on the right) and crammed with zero clearance top or bottom — it was sitting exactly inside the 48px zone that was supposed to be reserved bottom safe-area padding. Root cause: the screen uses nested auto-layout (`VERTICAL`, `SPACE_BETWEEN` on the inner container), so the original fix attempt — directly setting `.y`/`.x` on the button — silently did nothing, since auto-layout recomputes child position on every layout pass and just overrides manual coordinates. **Real fix:** worked with the auto-layout system instead of against it — set `itemSpacing`/`paddingBottom` on the parent for vertical clearance, and wrapped the button in a small padded container (`paddingLeft/Right: 24`, matching the `footer` element's own established inset pattern) with the button set to `FILL` inside it, rather than trying to position the button directly. One retry needed: first attempt called `.remove()` before `appendChild()`, not realizing `.remove()` deletes the node in the Plugin API rather than just detaching it — script failed atomically (no partial damage), fixed by removing the redundant `.remove()` call since `appendChild` alone handles moving a node between parents.

**One more fix, same root cause a third time:** Kell caught a stray white block sitting behind the "Try again" button — the `button-wrapper` frame created during the layout fix above never had its fill explicitly cleared, so it kept Figma's default opaque white. This is the *third* time this exact bug pattern hit this session (see `StatementCard` and `ProgressDots` earlier) — `figma.createAutoLayout()`/`createFrame()` always default to opaque white, and it's easy to forget to clear it on a frame that's purely structural (padding/centering) rather than a visible card. **Standing rule for any future Figma component work in this file: immediately call `.fills = []` on every new auto-layout/frame node right after creation, unless it's deliberately meant to have a visible background** — don't rely on remembering it case-by-case, default to clearing and only add a fill back when actually needed.

### 🔗 Same-Day Extension #4: 4 Open Questions Resolved + Terms-Error State Removed

Kell answered all 4 open questions flagged in the QA checklist. Three had real design consequences beyond just "noted":

1. **Duplicate-email → deep-links to login.** Styled "log in instead?" with an underline (link affordance) on the duplicate-email error screen. Engineering still needs to wire it to the actual login flow.
2. **Terms/Privacy error → no separate state exists.** Kell clarified the real model: Create Account simply never highlights/enables until all 4 required items are complete — there's no user action that could trigger a distinct "you tried to submit incomplete" error, since a disabled button can't be tapped. This directly contradicted the standalone red "Terms not accepted (error)" screen built earlier this session (node `276:3`) — **deleted it** as inconsistent with the confirmed model, and added a "Complete all fields to continue." hint to the plain "terms unchecked" default screen instead, matching the same hint pattern already used on intent-selection/rhythm-selection. Edge-case screen count back down to 9 (was 10).
3. **Network error → recommended and applied:** brief silent client-side auto-retry (1-2 attempts) before the error banner ever shows; once shown, no more silent retries; **the button re-enables** (changed from disabled to gold/enabled) since the failure was server/network-side, not a field-validation problem — a disabled button next to a "try again" implied action would be a dead end.
4. **moment-types-loading retry → recommended (not yet a design change):** resume from the failure point over a full restart, since redoing an already-succeeded step over a transient blip is needless friction. Flagged as contingent on the account-setup pipeline actually being resumable/idempotent — an engineering feasibility question, not purely a design one.

**Both checklists updated to match** — `docs/P0_EDGE_CASE_QA_CHECKLIST.md` rewritten with resolutions inline, and the in-Figma `QA Checklist` frame rebuilt from scratch with the same content (green section headers mark resolved items).

**The exact same white-default-fill bug hit a FOURTH time**, this time on the checklist's own section-frame wrappers (`figma.createAutoLayout()` again left with its default opaque white, never cleared). Caught immediately via screenshot and fixed. Four occurrences in one session (`StatementCard`, `ProgressDots`, `button-wrapper`, and now the checklist sections) means the "clear fills by default" standing rule noted above isn't sticking as a habit — worth being extra deliberate about this specific step on every single new frame going forward, not just remembering the rule exists.

### 🔗 Same-Day Extension #5: Interactive Prototype Built (Happy Path + All 9 Edge Cases)

Kell ran the QA checklist himself and confirmed it clean, then asked for a real click-through Figma prototype covering both the happy path and every edge case.

**Key constraint discovered:** Figma's `NODE`/`NAVIGATE` prototype action only accepts destinations that are a top-level frame **on the same page** — cross-page navigation isn't supported at the Plugin API level. Since the 9 edge-case screens lived on a separate `Onboarding — Edge Cases` page from the happy path's `P0 — New Onboarding` page, the first hub-link attempt failed outright. **Fixed by moving all 9 edge-case frames onto the same page** as the happy path (new row at y=2450, clear of the y=1388 happy-path row — first placement attempt also collided with the happy-path row's x-range and had to be corrected).

**What's wired:**
- **Happy path, full linear chain:** welcome → dwelly-intro → what-dwellable-does → name-entry → personalized-transition → intent-selection → rhythm-selection → gentle-reminders (+ its "Not now" secondary path) → privacy → account-creation → moment-types-loading. Each `moment-pill` row opens `moment-example-modal` as a Figma OVERLAY (not a full navigate); the modal's "Got it" closes it via the `CLOSE` action, returning to the loading screen underneath.
- **`Prototype Start` hub** (new frame, left of the happy-path row): one link into the happy path (Welcome), plus a direct link to each of the 9 edge cases — since most error states aren't reachable by tapping something on the happy path itself, this hub is the primary way to reach them.
- **Every edge-case screen got a `← Back` link**, wired to the `BACK` prototype action (returns to whatever was viewed previously, regardless of entry point — more robust than hardcoding a return destination).
- **3 bonus realistic hotspots:** `account-creation`'s actual Email/Password/Confirm-Password input fields are each tappable, jumping straight to their corresponding format-error screen — a more intuitive/discoverable way to preview those three states than routing through the hub every time.

**Two more bugs hit and fixed, same root causes as earlier today:**
1. Setting `.reactions` on a text node **before** `appendChild()`-ing it into the tree threw `"Reaction ... was invalid"` — reactions apparently require the node to already be parented. Fixed by reordering: append first, set reactions after.
2. The `← Back` links initially landed at the very bottom of the screen, overflowing past the visible frame — the *exact* auto-layout-override problem from the `moment-types-loading` fix earlier this session, just not yet generalized as a habit. Fixed the right way this time: `layoutPositioning = 'ABSOLUTE'` on the back-link text node lets it sit at a fixed x/y without disrupting the parent's auto-layout flow, rather than fighting the flow with plain `.x`/`.y` assignment.

**How to use it:** open the file in Figma, select the `Prototype Start` frame (or any screen), and enter Presentation/Play mode. Click through the happy path normally, or use the hub's edge-case links to jump directly to any error state. Every edge-case screen has `← Back` in the top-left to return.

### 🔗 Same-Day Extension #6: Full Prototype Wiring Audit

Kell reported being able to "select/unselect things" in Play mode in a way that felt like it was hiding scenarios, and asked for confirmation every scenario is properly wired. Rather than guess, directly inspected the checkbox/radio elements on `intent-selection`/`rhythm-selection` — confirmed **zero reactions** on any of them; nothing built lets those toggle live. Most likely explanation: navigating via the hub between the happy-path screen (pre-checked items) and its "none selected" edge-case counterpart reads as toggling, since they're different frames with different fixed states, not one live interactive screen — Kell confirmed this is the intended behavior (chose "make everything reliably reachable" over "build live toggle interactivity" when asked to disambiguate scope).

**Ran a full audit of every wired reaction on the page** (40 total across all 21 screens) — walked the whole node tree, resolved every `NODE`-type destination, confirmed **zero broken links**. Found one real imprecision: `gentle-reminders`' "Not now" link had accidentally attached its reaction to a much larger parent container (`bottom-section`) instead of just itself — leftover from a convoluted ternary in the original wiring script. Same destination either way (not a navigation bug), but a large chunk of the screen's footer was clickable when only "Not now" should be. Fixed by clearing the parent's reaction and wiring the "Not now" text node precisely.

### 🌐 Same-Day Extension #7: HTML Prototype Built (Real Browser, Not Just Figma)

After the audit above, Kell asked for a real HTML version of the prototype, having weighed the tradeoff (duplicated effort / drift risk vs. real browser feel) and decided it was worth it. Built `docs/P0_prototype.html` — a single self-contained file, no external dependencies at runtime.

**Faithful port, not a redesign:** per this session's own design-system work, treated this as "honor what's already there" rather than a fresh creative pass — same Onboarding/Gold tokens (colors, spacing), same Instrument Serif/Sans pairing, same 40-connection wiring map from the Figma audit. Fetched the actual Instrument Sans (variable, all weights in one 30KB file) and Instrument Serif (15KB) font files from Google Fonts and embedded them as base64 data URIs, rather than a CDN `<link>` that risks a silent fallback (and would break entirely under Artifact's strict CSP, which blocks external font requests).

**Structure:** hub panel (outside the phone chrome) linking to the happy path and all 9 edge cases directly, mirroring the Figma `Prototype Start` frame; a single phone-frame element that swaps which `.screen` div is visible; a small nav engine (`showScreen`/`goBack`/`openOverlay`/`closeOverlay`) driven by `data-goto`/`data-back`/`data-overlay`/`data-close-overlay` attributes — deliberately declarative, mirroring the trigger→action shape of Figma's own reactions model rather than inventing a different navigation paradigm.

**One real bug caught and fixed before shipping:** the hub-link click handler reset the navigation history to a single entry on every hub jump, which silently broke every edge-case screen's "← Back" link (nothing to go back to). Root cause: hub links used the same `data-goto` attribute as in-phone buttons, so they were already being handled correctly by the main delegated click handler — the extra hub-specific handler was pure redundant risk. Fixed by deleting it outright rather than patching it.

**Testing note for future sessions:** the Browser pane's simulated mouse clicks (`computer` tool) don't register on this file — it opens via a `file://` URL outside the recognized project folder, which the pane renders as a **static snapshot** rather than a live interactive page (confirmed by the pane's own navigation warning). Direct JS injection (`javascript_tool`) still executes correctly against the live DOM, and was used to verify all navigation, the Back-link fix, and the modal overlay — all confirmed working. Screenshots taken immediately after a JS-triggered state change can also lag/cache one frame behind; verify via DOM state (`document.querySelector(...)`), not just the screenshot, when testing this specific file again.

**Delivered two ways:** committed to the repo at `docs/P0_prototype.html` (open directly in any browser), and published via the Artifact tool for easy mobile/shareable viewing.

### 🖼️ Same-Day Extension #8: Real Welcome-Screen Assets Swapped In

Kell caught a real fidelity gap immediately on review: "off the rip" the HTML welcome screen didn't match Figma. Correct catch — the HTML version had substituted a CSS gradient for the actual painted forest/moon/lake background (no asset available at build time) and had **completely dropped the "Dwellable" wordmark** below the logo icon (an outright oversight, not a missing-asset excuse).

**Fixed by extracting the real assets from Figma rather than re-approximating:** cloned `welcome-gold`'s background container, stripped its overlay children (status bar, headline, button) to get a clean isolated export, screenshotted it, then deleted the temporary clone — netting the actual painted background art with nothing baked in on top. Also exported `Logo-Group` directly, discovering it's a single pre-composited PNG that already includes both the flame icon *and* the "Dwellable" wordmark together (not two separate elements as the node names implied) — one asset closes both gaps at once. Both embedded as base64 data URIs (site total now ~860KB, still fine for a review artifact).

**One more real bug caught mid-fix:** the freshly-embedded logo showed a visible rectangular box against the photo — inspected the PNG directly with PIL and confirmed it's **fully opaque with no alpha transparency at all** (not a compositing bug). The "seamless" look in the actual Figma design comes entirely from exact positioning — the opaque logo card sized and placed so its edges land on naturally similar-toned photo pixels, not from any blend mode. `mix-blend-mode: screen` (the obvious first guess) did nothing, as expected once the opacity was confirmed. Fixed by pulling the exact Figma coordinates (`Logo-Group` at x=118, y=149 relative to a 402×874 frame) and reproducing them as percentages (`left: 29.35%; top: 17.05%; width: 41.29%`) rather than the eyeballed centering used originally — now blends into the sky exactly like the source.

### 🚨 Next Session Objective (updated)
**Pillar 0 is now completely done — happy path, design system, 9 edge cases (all open questions resolved and QA'd by Kell), tokens rebound, QA checklist (repo + Figma), a fully wired + fully audited interactive Figma prototype (40/40 connections verified), and a faithful standalone HTML port with real extracted assets on the welcome screen.** Nothing outstanding. **If picking up more HTML-prototype fidelity work:** the other 10 happy-path screens don't have background photography (only `welcome` does in the actual design, so this is likely a non-issue) — but worth a quick visual pass against their Figma counterparts before assuming full fidelity, given the welcome screen alone had two real gaps on first build. **Primary next-session focus: Pillar 1 (Capture)** — natural next step, and `capture-method`'s content/styling already exists as a head start (see above). **Two standing rules to carry forward, both bitten multiple times this session:** (1) explicitly clear `.fills = []` on every new `createAutoLayout()`/`createFrame()` call immediately after creation; (2) for any node needing a fixed position inside an auto-layout parent, set `layoutPositioning = 'ABSOLUTE'` before assigning x/y — plain `.x`/`.y` assignment is silently overridden by the auto-layout flow. Both are now proven recurring failure modes in this specific file, not one-off mistakes.

---

## Session: July 30, 2026 — Full Pillar 0 Onboarding Row Designed in Figma (Cream/Gold Direction Locked)

> **⚠️ SUPERSEDED July 31, 2026** — this entry's "y=2498 canonical row" and "Cormorant Garamond + SF Pro" font system were both wrong by the time of the next session's live-file check. See the July 31 entry above for corrected values. Left as-is below for the historical record of what was believed true at the time.

### 🎯 TL;DR
Designed and iterated a complete 9-screen Pillar 0 onboarding flow in the `Dwellable — Existing Experience Baseline` Figma file (file key `t5MUGEtpeFcUixobvHiYMc`, page `P0 — Onboarding`), moved off the old dark/gold Phase-1 identity in favor of the new **cream/warm-gold palette**. Established real design-system foundations partway through: a proper `Onboarding/Colors` Figma variable collection (13 tokens) and unified font system (**Cormorant Garamond** headings + **SF Pro** body/subhead/button). Kell then restructured the whole file into a clean new 13-screen canonical row at y=2498 with descriptive names (see below), including 3 new screens beyond what I'd built: `dwelly-intro`, `personalized-transition`, and `capture-method`. **No engineering ticket status changes** (pure design). **Two backlog items added:** BL-002 (Moments Animation + Background SDK Init) and BL-003 (Voiceover Narration for Building screen, postponed).

### What Was Done
- 9 onboarding screens designed, iterated, and reordered: Welcome → Education → Privacy → Intent → Rhythm → Notifications → Account → Name → Building
- Screen order restructured mid-session: **FYI cluster first** (Welcome/Education/Privacy), then **Input cluster** (rest) — after Kell flagged sporadic interleaving
- **Name screen added** to unblock T-136's Today-tab greeting dependency; progress bars swept from /8 to /9
- **Building-your-account screen** went through several concept iterations before landing on a rich list-card + tap-to-modal design with "When the Lord breaks through the fog" headline and a valence-paired examples list ("peace in hardship", "comfort in a tense season", "joy in a new beginning")
- **Ontology work:** landed on a definition of "God moment" as recognition-based (person notices God in the ordinary), spanning 5 non-exhaustive channels (internal, devotional, communal, circumstantial, sudden-revelation) — the 5 pills on the Building screen span all 5, not by coincidence
- **Conversational-copy experiment:** built a full-flow comparison row applying Abbey-app-style acknowledgment beats to each headline; Kell to decide whether to adopt into live flow
- **Kell restructured the file** into 13 new canonical screens at y=2498: `welcome, dwelly-intro, what-dwellable-does, name-entry, personalized-transition, intent-selection, rhythm-selection, gentle-reminders, privacy, account-creation, moment-types-loading, moment-example-modal, capture-method`

### Key Decisions Locked
- **Cream/warm-gold palette** is the new direction (dark/gold Phase-1 identity retired for onboarding)
- **Cormorant Garamond** for headings/wordmarks + **SF Pro** for all other text
- **Account creation moves to late in flow** (position 7, was 5) since password no longer affects data access post-T-062-server-side-encryption; unblocks Account → Building-loading → Capture as one continuous forward motion
- **Onboarding answers stage locally** (UserDefaults) before account creation, batch-synced to Supabase on account creation — standard progressive-onboarding pattern; T-111 (ProfileManager + schema migration) already scoped for this
- **Voiceover deferred** to BL-003 with draft script attached; Figma cannot preview audio, needs mute/skip affordance + localization consideration

### 🚨 Next Session Objective

**Confirmed Pending Items:**
1. **Confirm the new 13-screen canonical row at y=2498 is authoritative** — Kell restructured the file at session close; next agent should not touch the older iterations at other y-values, and should verify Kell's 3 new screens (`dwelly-intro`, `personalized-transition`, `capture-method`) are the intended forward-plan additions before continuing any onboarding design work.
2. **Decide on the conversational-headline experiment** — the comparison row (separate from live) applied Abbey-app-style acknowledgment beats to headlines. Kell to confirm adopt/reject/iterate before this pattern lives permanently in the canonical row.
3. **Design the 3 new screens Kell added** (`dwelly-intro`, `personalized-transition`, `capture-method`) — placeholders exist as named frames but their content still needs to be built out to match the design system established this session (Cormorant/SF Pro, `Onboarding/Colors` variables, progress bar, safe-area clearance for Dynamic Island).

**Rationale:** The Pillar 0 design work is 90% locked but the last-minute file restructure introduced canonical changes the next session needs to respect. All engineering tickets remain untouched — the actual build phase for P0 (T-109/T-110/T-111/T-112/T-115/T-116) is still not started, unblocked by this design work but not activated yet.

### Session Frustrations Logged
- Multiple batch edits (headline copy sweeps, font changes) shipped without per-screen visual verification, causing overflow bugs Kell had to catch. **Rule for next session:** verify every screen visually after any batch text/font/layout change, not just spot-check.
- Sent stale cached screenshots to Kell twice by reusing file paths from earlier operations. **Rule:** always save the fresh screenshot bytes to a new path before sending.

---

## 🔄 Permanent Naming Change (July 20, 2026)

**"Soaking" → "Prayer" / "Pray", everywhere, permanently.** Pillar 3 was originally named "Soaking" (also seen as "Soaking/Guided Prayer," "Soaking (Guided Prayer)" throughout earlier sessions below). Kell's reasoning: "Soaking" reads as a Protestant/Pentecostal-specific term for a particular prayer practice — too narrow/denominational for what this pillar actually is, and less widely understood than just calling it "Prayer." Renamed permanently across the pillar's own name, every other pillar's docs/FigJam boards that reference it, `PRD.md`, `DEPENDENCY_GRAPH.md`, `TICKETS.md`/`.csv`, and the strategy file itself (`PILLAR_3_SOAKING_STRATEGY.md` → `PILLAR_3_PRAYER_STRATEGY.md`). Field name `has_soaking` → `has_prayed` (P10's unprayed-moment query).

**Historical sessions below still say "Soaking"** — left as-is intentionally, since they're a dated record of what was actually decided/discussed at the time. If you're reading an old session entry and see "Soaking," it means "Prayer" as understood today; no need to mentally substitute anything else.

---

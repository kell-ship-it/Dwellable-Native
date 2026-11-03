# Pillar 10 — Today: Prompt Taxonomy

**Status:** MVP category list locked Oct 16, 2026 | **Companion to:** [`PILLAR_TODAY_STRATEGY.md`](PILLAR_TODAY_STRATEGY.md) (the authoritative screen-structure doc — read that first; this file is the content bank for one slot within it)

**Working selector:** [Today Prompt Selector](https://claude.ai/artifact/EgncpLBsP6o3AS1u41nwXs) — interactive page with every category and example, used to make the MVP call below. Selections persist there; read back via ArtifactData if revisiting.

---

## Where this fits

Per the Aug 28, 2026 locked design, Today always shows: Scripture hero, one sustain door, Free Capture (header), plus "Room to Notice" (added Oct 16 session). This doc is the content taxonomy for the **sub-hero prompt slot** — the rotating tile that sits between the Scripture hero and the rest of the screen, first built as isolated "domain-widening" examples (Music, Dreams, Answered Prayer, Relationships) before Kell asked to generalize it into a full category system.

**Open structural question, not yet resolved:** does the sub-hero prompt slot replace the separate Sustain/Follow-up tile, or sit alongside it? As built (Scenarios 9–12 in the `dwelly-redesign` Figma file), they stack — which is more content than the "always exactly 3 slots" rule allows. Leaning toward: Sustain/Follow-up folds into the same shared rotation pool as the other categories below, so only one sub-hero tile ever shows at a time. Not locked yet.

---

## Category list

### MVP — locked, 4 categories (plus Scripture, always on)

| Category | Anchor | Data dependency | Why it made the cut |
|---|---|---|---|
| **Scripture** | A verse, always paired with a reflection question (see correction below) | None — always available, the one fixed/non-rotating element | The product's actual differentiator; never rotates out |
| **Sustain / Follow-up** | Something the user already captured — short-range (recent) or long-range (anniversary) | Requires capture history | Mandatory from the start — the core "capture, sustain" loop |
| **Mood** | One of the 8 locked mood-palette words (Pillar 4) | None — general, not tied to a specific past moment | Reuses the exact Journal mood vocabulary — a closed loop, not a second taxonomy; cheapest possible step toward a usage-based spiritual profile |
| **Life-Domain** | A sphere of life where God might show up (music, dreams, relationships, work, rest) | None | Widens what counts as an encounter with God — the clearest differentiation from a generic journaling app |

### Post-MVP, paused (4 categories)

| Category | Why paused |
|---|---|
| **Biblical Question** | Uses a question Jesus asked in the Gospels, not a quoted verse — theologically distinct from Scripture, but paused per Oct 16 session to keep MVP scope tight |
| **Liturgical / Seasonal** | Needs a calendar-aware content system (Advent, Lent, Easter); already named Post-MVP in the original PRD |
| **Rhythm / Time** | Moved to Post-MVP Oct 16 — reads more as a modifier on other categories (a time-flavored wrapper) than a genuinely distinct subject of its own |
| **Intercession** | Moved to Post-MVP Oct 16 — Kell likes it, but it's closer to Prayer (Pillar 3) territory, itself already deferred post-MVP; keeping Today's scope from quietly absorbing part of Prayer's job |

---

## Correction: Scripture must include a reflection question

Locked Oct 16, 2026. The verse alone is not a complete prompt — every Scripture entry needs an attached question, so the hero always reads as an invitation, not a passive quote.

**Before:**
> "Lord, I believe; help my unbelief." — Mark 9:24

**After:**
> "Lord, I believe; help my unbelief." — Mark 9:24
> When you see this verse, what does that mean to you? What comes to mind?

This is a correction to the existing built screens (Scenarios 1–12 in Figma currently show the quote alone) — not yet applied to the canvas.

---

## Content bank (examples so far)

## Overlap-avoidance tagging (locked Oct 16, 2026)

Per the Figma-AI combination spec (§3), the 3-prompt structure can't show prompts that overlap in subject or emotional tone, even if they come from different categories. **This does not require an LLM** — every bad-combination example in that spec is a metadata-matching problem, not a language-understanding one, as long as the prompt bank is tagged once at authoring time. Selection logic then becomes pure rule-based filtering: reject any candidate set where two entries share a tag.

**Schema — every prompt entry gets:**
- `cluster` — a short slug naming its emotional/thematic territory. Two prompts sharing a cluster can never be selected together.
- `echoes_mood` *(Sustain/Follow-up only)* — the real mood tag already on that captured entry (it's structured data from the journal, not inferred). Checked against the Mood slot's pick.
- `entry_id` *(Sustain/Follow-up and any date-driven prompt)* — the real entry the prompt points at. Two prompts with the same `entry_id` can never co-occur, even from different categories.

This directly explains the bug caught earlier this session: the "Conflicted" mood prompt and a Follow-up tile whose own `echoes_mood` was also `conflicted` — exact case this schema is built to catch.

### Scripture (corrected form)
- "Lord, I believe; help my unbelief." (Mark 9:24) — *When you see this verse, what does that mean to you? What comes to mind?* — `cluster: doubt-faith`
- "Be still, and know that I am God." (Psalm 46:10) — *What would it look like to actually be still today?* — `cluster: calm`
- "Come to me, all who labor and are heavy laden." (Matthew 11:28) — *What are you carrying right now?* — `cluster: fatigue`

### Mood (8 locked palette words — Pillar 4)
- **Peaceful** — "Felt a sense of peace recently?" / *What was happening right before it?* — `cluster: calm`
- **Grateful** — "What are you grateful for today?" / *Even something small counts.* — `cluster: gratitude`
- **Reflective** — "Anything sitting with you lately?" / *No rush to figure it out.* — `cluster: general-reflection`
- **Hopeful** — "What's giving you hope right now?" / *Hold onto that for a second.* — `cluster: hope`
- **Conflicted** — "Feeling torn about something?" / *That tension might be worth naming.* — `cluster: conflict`
- **Exhausted** — "Running on empty lately?" / *That's worth bringing here too.* — `cluster: fatigue`
- **Prayerful** — "What's been on your heart to pray about?" / *Even unfinished prayers count.* — `cluster: prayer-request`
- **Loved** — "When did you last feel loved?" / *Who or what reminded you?* — `cluster: connection`

### Sustain / Follow-up
Tags below are illustrative — at runtime these come from the real entry's actual stored data, not a hardcoded bank.
- Short-range: "You said hiding it would've been worse than bringing it honestly…" / *Captured 2 hours ago.* — `cluster: conflict`, `echoes_mood: conflicted`, `entry_id: (real)`
- Long-range: "The Prayer I Almost Didn't Pray" / *One year ago today. Does it still weigh the same?* — `cluster: conflict`, `echoes_mood: conflicted`, `entry_id: (real)`
- Long-range: "The Morning I Almost Cancelled" / *From 6 weeks ago. What made you go anyway?* — `cluster: fear-doubt`, `echoes_mood: anxious`, `entry_id: (real)`

### Life-Domain
- **Music** — "What worship song have you had on repeat? How does it make you feel?" — `cluster: general-music`
- **Dreams** — "Have you had any dreams lately? Sometimes that's where God shows up." — `cluster: general-dreams`
- **Relationships** — "Navigated conflict with a friend or family lately? That can be holy ground too." — `cluster: conflict`
- **Work** — "Anything from your workday that surprised you?" — `cluster: general-work`
- **Rest/Illness** — "Been forced to slow down lately? What's that been like?" — `cluster: fatigue`

### Rhythm / Time (Post-MVP)
- "It's the end of the week. Anything still unsettled from these last few days?" — `cluster: general-reflection`
- "Sunday evening. Anything from today you want to hold onto?" — `cluster: general-reflection`
- "First thing in the morning — what are you carrying into today?" — `cluster: fatigue`

### Intercession (MVP, 30 entries — locked Oct 19, 2026; superseded the "Post-MVP standalone door" framing below)
Tile headline shown first, all independently verified ≤ one line at the real tile width (Instrument Serif 16px, 216px box).
1. Anyone on your heart lately? — *full opener: "Has anyone been on your heart lately you'd want to talk about?"* — `cluster: connection`
2. Who came to mind today unprompted? — *full opener: "Who came to mind today without you trying?"* — `cluster: connection`
3. Anyone you've been carrying lately? — *full opener: "Is there someone you've been carrying lately? What would it look like to pray for them?"* — `cluster: connection`
4. Someone you haven't checked on lately? — `cluster: connection`
5. Anyone going through something hard? — `cluster: connection`
6. Who's been on your mind this week? — `cluster: connection`
7. Anyone you've meant to pray for? — `cluster: prayer-request`
8. Someone who needs encouragement? — `cluster: connection`
9. Anyone you're worried about lately? — `cluster: connection`
10. Who crossed your mind today? — `cluster: connection`
11. Anyone you miss checking in with? — `cluster: connection`
12. Someone celebrating something lately? — `cluster: gratitude`
13. Anyone who's been quiet lately? — `cluster: connection`
14. Who's walking through a hard season? — `cluster: connection`
15. Anyone you've lost touch with? — `cluster: connection`
16. Someone you're grateful for today? — `cluster: gratitude`
17. Anyone facing a big decision right now? — `cluster: general-reflection`
18. Who could use a kind word today? — `cluster: connection`
19. Anyone you've been avoiding lately? — `cluster: conflict`
20. Someone struggling that you know of? — `cluster: connection`
21. Anyone waiting on good news? — `cluster: hope`
22. Who's been carrying something heavy? — `cluster: connection`
23. Anyone you haven't prayed for lately? — `cluster: prayer-request`
24. Someone new on your mind lately? — `cluster: connection`
25. Anyone you feel distant from lately? — `cluster: conflict`
26. Who's been generous with you lately? — `cluster: gratitude`
27. Anyone you want to see God's hand in? — `cluster: hope`
28. Someone you've been thinking about? — `cluster: connection`
29. Anyone who needs encouragement? — `cluster: connection`
30. Who's been showing up for you lately? — `cluster: gratitude`

---

## Follow-up: data lifecycle & fallback rules (locked Oct 16, 2026)

**Tag retention.** `echoes_mood` is captured once, at the moment the entry is created, and retained for the system's own internal use even if the user later edits or removes the visible tag on that entry. Risk accepted: the retained tag can go stale if the user's feelings about that entry changed since — not a blocker, a deliberate trade-off. The retained tag is **never shown back to the user** as if it were current; it exists only to drive which entry gets selected for a Follow-up prompt. **Full entry deletion wipes the retained tag with it** — no lingering data survives the entry it came from.

**Cascading fallback when the intended entry disappears.** Today doesn't just drop the Follow-up slot the moment its source entry is deleted:
1. Try the most recent eligible entry.
2. If it's gone, walk backward to the next most recent *undeleted* entry and use its tags instead.
3. Keep walking back through history until an eligible entry is found.
4. If no entries exist at all (brand-new user, or every entry has been deleted) — Follow-up cannot be filled. Fall back to a different category entirely for that slot, per the Figma-AI spec's own missing-history rule (§4): never fabricate a Sustain item, never show a locked tile, never ask the user to "capture more to unlock."

**Designated fallback category: Intercession.** When Follow-up has zero eligible history, the slot falls back to Intercession — not Mood or Life-Domain. Reason: Mood and Life-Domain aren't neutral options here, they're already spoken for on the same screen (Mood is the Notice slot, Life-Domain is the Look-beyond slot). Falling back to either would risk the same category showing up twice in one visit, or at minimum adding no real variety since it's already represented. Intercession, sitting outside the 3 active slots, is the only option that guarantees the fallback is a genuinely different door. Built narrowly — a small, fixed set of Intercession prompts that exist *only* to serve this fallback case, not as a fourth rotating door in the main pool.

### Biblical Question (Post-MVP)
- "Who do you say that I am?" / *What would you actually say right now?*
- "What do you want me to do for you?" / *If you're honest, what is it?*
- "Do you want to be healed?" / *Not a rhetorical one.*

### Liturgical / Seasonal (Post-MVP)
- Advent — "Waiting is its own kind of faith. What are you waiting on right now?"
- Lent — "What's one thing you're giving up — and why?"
- Easter — "Is there anything in you that needs to feel new again?"

---

## Resolved (Oct 16, 2026)

1. ~~Does the sub-hero prompt slot replace Sustain/Follow-up, or stack with it?~~ **Resolved: 3 sub-hero slots, not 1.** Final structure locked against the Figma-AI combination spec: Notice (Mood), Return (Sustain/Follow-up, title-led), Look-beyond (rotates among Life-Domain/Rhythm/Intercession — though Rhythm and Intercession are now Post-MVP, so this slot is Life-Domain only until they're picked back up). Category labels stay secondary; "Notice/Return/Look-beyond" are framework-internal, never shown to the user.
2. ~~Is Intercession in or out for MVP?~~ **Resolved: out.** Moved to Post-MVP alongside Rhythm/Time — see the category table above.

## Open questions

1. ~~**Selection logic for the shared pool**~~ **Resolved Oct 19, 2026 — see Session Update below.** Date-based, same pattern as Scripture, not history- or engagement-based.
2. ~~**Collision-resolution rule**~~ **Resolved Oct 19, 2026: no swap, no collision-avoidance logic at all.** Scripture/Mood/Domain/Intercession each compute their day's pick independently from the date, with no cross-checking between them. The original swap rule assumed a runtime selection step that no longer exists now that rotation is pure date-indexed math — there's nothing to swap *from*. Dropped rather than reconciled: an occasional thematic overlap between two of the day's picks (e.g. both landing on a "fatigue"-adjacent tag) is accepted as rare and harmless, not a violation of anything in the Authority Guardrails.
3. **Where do `cluster` tags get assigned for new content?** Right now it's manual, done in this doc. If the bank grows past ~20-30 entries per category, worth a lightweight authoring checklist so new prompts don't ship untagged (which would silently defeat the overlap rule for anything added later).

---

## Session Update — Oct 19, 2026 (current locked state — supersedes category/rotation sections above where they conflict)

**Structure simplified to 4 categories, all MVP:** Scripture (hero, always on), Mood, Domain, and Sustain/Follow-up-or-Intercession (the 3rd tile). Intercession is no longer Post-MVP or a member of a rotating "Look-beyond" slot — it's promoted to a full MVP category, standing alongside Mood and Domain. It isn't a flavor of Sustain (Sustain is always contextual to something the user actually shared; Intercession never is) — it only *occupies* the 3rd tile's slot, as the fallback when Sustain has nothing to draw from.

**3rd-tile logic, fully resolved:**
- Any local capture exists (pending or completed, doesn't matter) → Sustain/Follow-up shows that capture's real content.
- No local capture → ask the server the same way the moments list already does (`MomentsListView.fetchMoments()`) → if that turns up real history (e.g. a fresh/reinstalled device), use it the same as above; if it confirms true zero (including "had captures, deleted them all"), show Intercession. No separate "is this a new device" check needed — the single server-fetch resolves both cases.
- Intent (P0 onboarding) does **not** drive any of this — dropped; intent-based prompts read too similar to Mood's own open-question format to be a distinct 4th option.

**Rotation, fully resolved: date-based, not history-based, for all four categories.** Scripture, Mood, Domain, and Intercession (when it's the one showing) all pick their entry the same way — today's date indexes into that category's fixed bank (day-of-year modulo bank size), exactly like Scripture already worked. None of them are based on what the user has already seen. This was chosen specifically because it closes a real gap: if rotation depended on remembering what was shown before, a new/reinstalled device would have no memory of that and could repeat content — the same blind spot that affects capture history, but with no reason to accept it here, since nothing about Mood/Domain/Intercession needs to depend on the user's account data at all. Every device, any day, computes the identical answer from the date alone.

**Error state: does not exist, by design.** Scripture/Mood/Domain/Intercession cannot fail (all local, fixed, date-computed). Sustain's server check already degrades gracefully into Intercession rather than erroring. There is no scenario where Today fails to load that isn't an app-wide failure out of this pillar's scope — no error-state screen was built for Today.

**Figma:** the `dwelly-redesign` file's Today page is now 1 scenario (down from 13 — briefly 2, see below). Mood=Grateful and Domain=Dreams, same fixed-bank examples as always.

---

## Session Update — Oct 19, 2026 (later still): no excerpting — full verse only, curated to fit

**Locked: Scripture entries are never abridged.** Earlier the same day the plan was "cap the quote at 2 lines, excerpt anything longer down to its essential clause." Kell reversed that after reviewing a batch of excerpts and disliking the loss of meaning it caused (e.g. 1 Peter 3:9 excerpted to "Do not repay evil for evil" lost the actual point of the verse — the "but bless" half). Decision: **the constraint moves upstream to curation, not display.** Every verse in the bank must already be ≤70 characters in its full, unedited form. If a verse doesn't fit, it doesn't go in the bank — it is never trimmed to fit. There is no "Excerpt" field distinct from "Full Verse" going forward; what's in the bank is what's shown, verbatim.

**Validated at 365/365:** a complete draft bank was built to this rule — every entry ≤70 characters, full verse = displayed text on every row, 0 need for abridging. Delivered as a CSV for Kell's manual verification pass (wording accuracy against a licensed Bible text, not yet confirmed).

**Consequence for future verse selection:** the 70-character cap is now the real editorial filter for what can go in the Scripture bank at all, not a last-step trim. A moving/important verse that happens to run long (e.g. Lamentations 3:22-23 in full, or James 1:23-24 at 133 characters) is understood to be out of scope for this bank, not a candidate to shorten.

---

## Session Update — Oct 19, 2026 (later still): tile headline vs. full opener, line-wrap audit, and the "bring it to God" principle

**Two different strings per prompt, not one.** Every Mood/Domain/Intercession entry now has two forms:
1. **Tile headline** — what renders on the Today screen itself. Hard-constrained to one line at the tile's real width (Instrument Serif 16px, 216px box) — measured empirically at **~33 characters safe, 39+ reliably wraps.** This is a UI-length compression, nothing more.
2. **Full opener** — what Dwelly actually says once the user taps the tile and Capture opens. Not length-constrained (chat bubbles wrap freely). Per the already-locked Aug 28 rule, this is literally Dwelly's opening message — no origin chip, no quoted tile text on top of it.

**Line-wrap audit (measured against the real tile, not guessed):** of the 16 live Mood/Domain/Intercession entries, **9 wrapped to 2–3 lines** and had never been checked before. All 5 Domain entries failed; all 3 Intercession entries failed; 1 of 8 Mood entries (Prayerful) failed.

**Locked tile headline / full opener pairs (MVP, Oct 19, 2026):**

| Category | Tile headline | Full opener |
|---|---|---|
| Mood — Prayerful | Praying about anything lately? | What's been on your heart to pray about? |
| Domain — Music | What song have you had on repeat? | What song have you had on repeat? How does it make you feel? *(no "worship" qualifier anywhere — Today never prefaces that, so don't imply it)* |
| Domain — Dreams | Have you had any dreams lately? | Walk me through a dream you had recently, and let's see where God is. |
| Domain — Relationships | Conflict with someone lately? | Navigated conflict with a friend or family lately? That can be holy ground too. |
| Domain — Work | Anything from work surprise you? | Anything from your workday that surprised you? |
| Domain — Rest/Illness | Been forced to slow down lately? | Been forced to slow down lately? What's that been like? |
| Intercession 1 | Anyone you've been carrying lately? | Is there someone you've been carrying lately? What would it look like to pray for them? |
| Intercession 2 | Who came to mind today unprompted? | Who came to mind today without you trying? |
| Intercession 3 | Anyone on your heart lately? | Has anyone been on your heart lately you'd want to talk about? *(kept broad — "anyone," not narrowed to a specific kind of relationship or obligation)* |

All other Mood entries (Peaceful, Grateful, Reflective, Hopeful, Conflicted, Exhausted, Loved) already fit one line and use the same text for both tile and opener — no second form needed.

**New principle, locked for Dreams, open question for everywhere else: bring it back to God, but as a later turn, not the opener.** Kell's rule: the opening message should let the user just talk first — don't front-load a "where is God in this" question before they've even started. Somewhere later in the same conversation, Dwelly should explicitly ask something like "Do you feel closer to God or farther from Him in this?" — giving the user room to answer honestly (including "farther," without that being treated as a wrong answer, per the Authority Guardrails). **Confirmed for Dreams. Not yet decided whether this applies to all Domain prompts, to every Capture conversation regardless of entry point, or just this one.**

---

## Session Update — Oct 19, 2026 (later same day): Follow-up deferred Post-MVP, Today ships as a single scenario

**Locked: Follow-up (the 3rd tile reading a user's real capture) is deferred Post-MVP.** Working through what the tile actually needs — a real headline from the capture, plus a real follow-up question — made clear that a genuinely *contextual* follow-up requires an LLM to understand what the user actually captured. Truncating the raw transcript isn't contextual, it's just a snippet, and would read as fake personalization. There's no zero-LLM way to do this honestly. This is the same wall the original (May 14, 2026) Daily Prompt hit when it depended on Rich Context/LLM generation — the exact reason the Aug 28, 2026 redesign moved to fixed Scripture content in the first place. Deferring Follow-up now is the same call, applied consistently, rather than shipping a version that fakes personalization it doesn't have.

**For MVP, the 3rd tile always shows Intercession** — not Follow-up, not a broader "Reflections" bank, specifically Intercession, same fixed/date-rotating pattern as Scripture/Mood/Domain. This means Today needs **zero per-user data and zero server calls for MVP** — no capture-history check, no fresh-device branch, none of it live. That logic is still real and still documented (on the Pillar 10 system-design board, dimmed) for whenever Follow-up actually ships Post-MVP, once Formation Intelligence / a real spiritual-profile synthesis step exists to make it genuinely contextual.

**Consequence:** "Happy Path" (has capture history) vs. "Zero History" is no longer a meaningful distinction for Today, since the 3rd tile no longer depends on capture state at all. The Figma file's Today page is back down to a single screen.

**Real trade-off, on record:** Today loses its tie to the user's actual story for now — it's Scripture plus generic, non-personal categories. Entries/Search still covers returning to real past moments; Prayer (P3) and Formation Intelligence (P7) were always where deeper personalization was meant to live, not Today. Not a loss of the product's goal, just not faking it before the pieces that make it real actually exist.

---

## Session Update — Oct 19, 2026 (edge-case pass, after Follow-up deferral)

With Follow-up deferred and the 3rd tile fixed to Intercession, Today now has zero per-user data and zero server dependency — which closed out the entire earlier "fresh device" branch as moot and left a short, real edge-case list:

1. ~~**Mood/Domain/Scripture/Intercession collision rule**~~ — resolved above (dropped, no swap logic).
2. **Intercession bank size** — resolved: grown from 3 to **30 entries** (see category table above), so it now repeats roughly monthly instead of every 3 days.
3. **Day-boundary / midnight refresh — locked: recompute "today" only on fresh app open or foreground resume, never live while the screen is already open.** Matches ordinary daily-content app conventions; content should never visibly shift while someone's mid-read.
4. **Timezone** — no change. Device's own local timezone (T-184) stays the answer; the rare cross-timezone edge case is low-stakes enough not to warrant server-side timezone logic.

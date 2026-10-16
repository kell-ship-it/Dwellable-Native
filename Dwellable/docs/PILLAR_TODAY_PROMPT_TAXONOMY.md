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

### Intercession (Post-MVP as a standalone door — kept alive narrowly, see fallback rule below)
- "Is there someone you've been carrying lately? What would it look like to pray for them?" — `cluster: connection`
- "Who came to mind today without you trying?" — `cluster: connection`
- "Anyone you've been meaning to check on?" — `cluster: connection`

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

1. **Selection logic for the shared pool** — daily rotation like Scripture? Random per session? Weighted toward categories the user hasn't engaged with (an early, zero-LLM step toward the "spiritual profile" idea discussed this session, without actually building Rich Context)?
2. **Collision-resolution rule** — the Figma-AI spec says when two of the three picks collide on a cluster tag, "preserve a particularly relevant personal follow-up and replace a more generic prompt." Needs a concrete tie-break: if Mood and Life-Domain both collide with Follow-up, which one yields? (Current lean: Follow-up always wins — it's the one tied to the user's real, specific story; Mood and Life-Domain are both generic banks and either can be swapped for another same-category pick.)
3. **Where do `cluster` tags get assigned for new content?** Right now it's manual, done in this doc. If the bank grows past ~20-30 entries per category, worth a lightweight authoring checklist so new prompts don't ship untagged (which would silently defeat the overlap rule for anything added later).

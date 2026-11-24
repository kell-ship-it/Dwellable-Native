# Dweller Profile Narrative Framework

Decided by Kell, Nov 24 2026. Governs the "Your Spiritual Journey" narrative on the Growth tab.

## 1. Which journals count

| Journal | Saved as a journal? | Goes to Formation Intelligence? | Counts toward the narrative? |
|---|---|---|---|
| Gibberish / no real content | Yes | No | No |
| Goes to Formation Intelligence (even if brief) | Yes | Yes | Yes |
| Goes to Formation Intelligence and is clearly reflective | Yes | Yes | Yes |

Rule: **any journal that goes to Formation Intelligence (`formation_eligible`) feeds the Dweller Profile and counts toward the threshold.** Quality tiers within that group may come later; for now they count the same.

## 2. When the first narrative appears

- After **7** journals that went to Formation Intelligence (`DwellerProfileManager.narrativeUnlockThreshold`).
- Before that, Growth shows **"N of 7 reflections"** with a progress bar, to give people something to look forward to.
- The profile still builds quietly from the first qualifying journal, so the narrative is ready the moment #7 lands.
- "Not quite" feedback also counts toward the total (existing rule; it can only exist after a narrative is shown).

## 3. Length

- **280 to 600 characters, 2 to 4 sentences.**
- The prompt asks for this range; the app hard-caps at 600, trimming at the last full sentence (never mid-sentence).

## 4. What it must do

- Name **themes, patterns and growth** across entries ("keeps returning to rest and trust").
- Be warm, plain and specific to this person.
- Use only what is in their journals and feedback.
- Use their first name or "they/them", never a gendered pronoun, never "the writer".
- Let a "Not quite" correction override what it contradicts.

## 5. What it must never do

- Retell events one by one, or read like a transcript.
- Quote or closely paraphrase what they said.
- Use lists.
- Invent events or feelings that are not in the material.
- Diagnose, label, or promise outcomes.
- Include anything from conversations the safety layer kept out of the profile.

## 6. Reviewing real narratives during the beta

For each narrative you review, check:

- [ ] 280 to 600 characters
- [ ] Reads as patterns and themes, not a recap of events
- [ ] Nothing quoted back
- [ ] Nothing invented
- [ ] Feels true and kind; would you be glad to read it about yourself?

## Open for later

- Quality tiers inside "went to Formation Intelligence"
- Letting the narrative grow longer as more journals arrive

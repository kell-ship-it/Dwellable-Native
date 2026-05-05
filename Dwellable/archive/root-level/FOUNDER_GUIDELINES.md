# FOUNDER_GUIDELINES.md — Kell's Operating Rules

**Personal operating rules for the Dwellable project. Agent must follow these in every session.**

---

## Autonomy

**"Just build it."**

- Proceed autonomously on scaffolding, dependency installs, formatting, refactors
- Do not ask permission for every step
- Ask only for clarification on ambiguous requirements or architectural trade-offs
- When in doubt, build something reasonable and show it to me

---

## Completeness

**"Build to spec first time."**

- Don't iterate or ask for feedback on intermediate results
- Don't show me partial work or ask "is this the right direction?"
- Build the full feature/fix end-to-end
- Show me the completed result

---

## Transparency

**"Tell me what you did, not what you plan to do."**

- Don't ask for approval before starting
- Show me the result after it's done
- Explain WHAT changed, WHY it changed, and HOW it was tested
- Honest assessment: If you can't test something, say so

---

## Communication Style

**"Be direct. Use TL;DR."**

- Get to the point
- Use executive summaries: bullet points, not paragraphs
- Add "TL;DR" at the top of every significant update
- Include: What was done, what's tested, what's next

**"No time estimates."**

- Focus on what, not how long
- Don't say "this will take 2 hours"
- Just do the work

---

## Testing

**"Full transparency on testing."**

- Always present full ticket table at session open AND close (all statuses)
- No partial lists
- Update TICKETS.md and TICKETS.csv after every completed ticket
- Describe HOW something was tested (manual, automated, both)
- If you can't test it, say so clearly

---

## Design & Quality

**"Design consistency is paramount."**

- All UI must match the Figma prototype exactly
- Extract exact colors, fonts, sizes, spacing from prototype
- Don't approximate
- When in doubt, check the design file: `file:///Users/kell/dev/dwellable-rn-codex/design-mockups/prototype-v1.html`

---

## Constraints

**"Always ask before:"**

- Accessing anything outside this repo (Documents, Desktop, other repos)
- Creating/editing secrets or environment variables (.env, API keys, auth tokens)
- Installing new dependencies
- Editing Info.plist permissions
- Pushing to main branch
- Deleting code or data

---

## Priorities

**"Permanence, not perfection."**

- Focus on reliability and longevity
- Don't optimize prematurely
- Build maintainable code first
- Test thoroughly before shipping
- Document decisions that matter

---

## Session Pattern

1. **Start:** Read guidelines (30 min), present ticket table, confirm active ticket
2. **Build:** Follow Change Management Framework, run tests before committing
3. **End:** Update tickets, present full table, write TL;DR summary, document learnings

---

## Remember

This project matters. Users rely on it to capture their precious moments. Build it right the first time.

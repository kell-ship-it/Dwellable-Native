---
name: close-session-dwellable
description: Session End Protocol for the Dwellable iOS project — updates tickets, MEMORY.md, creates a Notion session page, and commits (pushes only if asked). Use when the user types /close-session or /close-session-dwellable in this repo, or asks to close/end a Dwellable session.
---

# Close Session — Dwellable

Rebuilt from the Notion "Closeout Sequence" + "Skill Sequence" protocol pages (Projects → Dwellable → ⚙️ Protocol) and `Dwellable/CLAUDE.md`, after the local skill install was lost in an Aug 11, 2026 machine reset.

Execute in order. Do not skip steps.

## Step 1: Update All Ticket Records

Update both files:
- `TICKETS.md` — header count, mark tickets complete/in-progress/not-started, add any new tickets discovered this session
- `TICKETS.csv` — sync spreadsheet version with TICKETS.md

Output the same summary format as session open — counts by status, plus full detail for every non-✅-Complete ticket (from `TICKETS.csv`). Do not dump the full table.

## Step 2: Identify Pending Work for Next Session

Define the top 3 specific, actionable items for the next session:

1. [Ticket/Task]: [Exact description] — [Why this matters]
2. [Ticket/Task]: [Exact description] — [Why this matters]
3. [Ticket/Task]: [Exact description] — [Why this matters]

Each item must be specific (reference ticket IDs where applicable), actionable (the next agent can execute without clarification), and prioritized (in execution order).

## Step 3: Create Notion Session Page

Create a dated entry under Projects → Dwellable → 📅 Sessions → 2026 → [Date]. Fill in:
- **Summary:** what was accomplished (2-3 bullet points)
- **Next Session Objectives:** the 3 items from Step 2
- **Key Decisions Locked:** any decisions/approvals made this session

If repo files were created or changed (MEMORY entries, doc updates, etc.), link or reference them in the Notion page.

## Step 4: Write to MEMORY.md

Update `docs/MEMORY.md` with:

```markdown
## Next Session Objective ([Date])

**Confirmed Pending Items:**
1. [Item 1]
2. [Item 2]
3. [Item 3]

**Rationale:** [Why these items move the product forward]
```

Do not proceed until the user confirms these match the actual pending items.

## Step 5: Git Commit & Push

Stage and commit all changes:

```bash
git add TICKETS.md TICKETS.csv docs/MEMORY.md [any other files modified]
git commit -m "[Session close] Update tickets and document next session objective (X, Y, Z)"
```

Only push (`git push origin main`) if the user explicitly asks. If pushed, verify it succeeded — output should show commits uploaded to origin/main.

## Step 6: Final Verification Checklist

Confirm all of these before ending the session:

- ✅ TICKETS.md updated: header reflects new count, all status changes logged
- ✅ Next session objective written: 3 specific items documented in MEMORY.md
- ✅ MEMORY.md matches pending items
- ✅ Git committed (and pushed, if the user asked)
- ✅ Notion session page created
- ✅ Output to user: final summary of what was done and what's pending

## Step 7: Output Final Summary

```
=== SESSION CLOSE SUMMARY ===

✅ COMPLETED THIS SESSION:
• [List 3-5 major deliverables]

📊 TICKET STATUS:
• Before: X/Y complete
• After: Z/Y complete

📝 PENDING FOR NEXT SESSION:
1. [Item 1] — [Why]
2. [Item 2] — [Why]
3. [Item 3] — [Why]

🔒 PERSISTED TO:
✅ TICKETS.md (updated header + new tickets)
✅ docs/MEMORY.md (next session objective documented)
✅ Notion Sessions (dated entry with objectives)
✅ Git (committed; pushed only if requested)

🎯 NEXT SESSION: Agent should start by confirming these 3 items match the stored objective.
```

Do not end the session without completing all 7 steps and the final summary. Never force-push or run destructive git operations without explicit user approval.

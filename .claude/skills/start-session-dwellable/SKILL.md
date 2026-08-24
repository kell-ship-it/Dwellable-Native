---
name: start-session-dwellable
description: Founder Start Protocol + Agent Startup Protocol for the Dwellable iOS project. Use when the user types /start-session or /start-session-dwellable in this repo, or asks to start/open a Dwellable session.
---

# Start Session — Dwellable

Rebuilt from the Notion "Startup Sequence" + "Skill Sequence" protocol pages (Projects → Dwellable → ⚙️ Protocol) and `Dwellable/CLAUDE.md`, after the local skill install was lost in an Aug 11, 2026 machine reset.

Execute in order. Do not skip steps, do not ask whether to do them — just do them.

## Step 1: Founder Start Protocol (FIRST — before any agent work)

Ask the user directly, and wait for confirmation before proceeding:

1. Have you prayed and worshipped yet?
2. Have you affirmed yourself in the Lord?
3. Have you prayed for your agent?

Do not start any technical work until these are confirmed.

## Step 2: Read Strategic Context (in order)

1. `docs/VISION.md` — product north star, principles, target users
2. `docs/PRD.md` — requirements, scope, success metrics, current phase status
3. `docs/ARCHITECTURE.md` — tech stack, data flow, key decisions
4. `docs/WORKFLOW.md` — development process, build commands, testing strategy

## Step 3: Read Current State

5. `docs/MEMORY.md` — last session notes, blockers, what was done. This holds recent sessions only; older entries live in `docs/MEMORY_ARCHIVE.md` — read that only if you need detail on a specific past session.
6. `docs/KEY_LEARNINGS.md` — critical lessons (build issues, race conditions, etc.)
7. The Notion Protocol dashboard (Projects → Dwellable → ⚙️ Protocol) — file hierarchy, credentials location, if anything there has changed since this skill was last updated
8. The most recent Notion session page (Projects → Dwellable → 📅 Sessions → 2026) — for "Next Session Objectives" from last time

## Step 4: Tickets & Approval

9. Read `TICKETS.csv` (the structured ticket registry — cheaper than the prose log in `TICKETS.md`) and output a **summary** to the user right now, not the full table:

   - Counts by status (✅ Complete / 🔄 In Progress / 🔲 Not Started / ⚪ Deferred), total tickets
   - Full detail (ID, Title, Epic, Priority, Status) for every ticket that is **not** ✅ Complete — normally a short list
   - Do not list complete tickets individually; the count covers them

   `TICKETS.md`'s recent session-log entries add narrative context if needed; `TICKETS_ARCHIVE.md` holds older entries (read only on demand).

10. State which ticket is next (first 🔄 In Progress, or first 🔲 Not Started).
11. Wait for the user's confirmation before writing any code.

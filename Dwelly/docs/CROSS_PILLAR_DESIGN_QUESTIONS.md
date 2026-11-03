# Cross-Pillar Design Questions & Secondary Experiences

**Status:** Pre-Lock Analysis | **Updated:** May 14, 2026 | **Purpose:** Map all open design questions to their pillar owners before T-092

---

## Overview

As we finalized the pillar strategies, several secondary experiences and gaps emerged that don't map cleanly to single pillars. This document categorizes them by owner pillar(s) and clarifies whether they need:
- New pillar design work
- Pillar clarification/expansion
- Cross-pillar design principles
- Post-MVP deferral

---

## 1. MOMENT/JOURNAL DETAIL VIEW (Gaps + Notifications Secondary Experience)

**Questions:**
- When user taps a saved moment in Entries, what UI do they see?
- Can they re-dwell (pray/prompt) on that moment?
- Can they edit the journal title/tags/moods after synthesis?
- What actions are available (prayer, edit, delete, share)?

**Pillar Owner(s):** P5 (Search & Discovery) + P3 (Soaking) + P4 (Journal Ownership)

**Current State:** Partially designed
- P4 covers synthesis + customization **in capture flow** (same session)
- P5 covers discovery but NOT what happens when you tap a moment
- P3 covers prayer **post-capture** but not re-dwelling on previous moments

**What Needs Design:**
- Moment detail view layout (title, body, moods, date, actions)
- Action menu: edit journal, pray again, add photos, delete, etc.
- Re-soaking flow: Can user initiate prayer/prompts on a previously-captured moment?
- Gallery view: If moment has multiple photos, how are they displayed?

**Scope:**
- MVP: Moment detail view (read-only journal), re-soaking capability (prayer/prompts)
- Post-MVP: Full editing, sharing, advanced actions

**Ticket Owner:** Assign to P5 designer + P3 liaison

---

## 2. ACCOUNT RECOVERY / PASSWORD RESET (Gaps)

**Questions:**
- What if user forgets their password?
- How do they reset/recover account?
- Is this part of Onboarding or separate flow?
- Email verification required?

**Pillar Owner(s):** P0 (Onboarding) + P2 (Security & Privacy)

**Current State:** Not designed
- P0 covers initial account creation
- P2 covers encryption/password change (once logged in)
- P0 likely defers password reset to "after first login"

**What Needs Design:**
- Password reset flow (email verification, new password, confirmation)
- Account recovery (prove identity, regain access)
- UI: forgot password link on login screen, email instructions, reset modal

**Scope:**
- MVP: Email-based password reset (must-have for security)
- Post-MVP: Multi-factor authentication, biometric unlock

**Ticket Owner:** P2 (Security) owns this

---

## 3. MOMENT DELETION / SOFT-DELETE RECOVERY (Gaps)

**Questions:**
- How does user delete a moment?
- How do they recover a soft-deleted moment within 30-day window?
- Is there a "Trash" view in Entries?
- Confirmation flow?

**Pillar Owner(s):** P5 (Search & Discovery) + P4 (Journal Ownership)

**Current State:** Mentioned but not designed
- Architecture mentions "soft delete" (flag `deleted: true`, exclude from searches)
- P4 mentions "soft delete capability" but no UX specified
- P5 doesn't specify deletion/recovery actions on moments

**What Needs Design:**
- Deletion action (on moment detail view or in moment list)
- Confirmation modal ("Delete? You can recover within 30 days")
- Recovery UX: how to access deleted moments (Entries trash view? Separate recovery flow?)
- Empty state if user deletes all moments

**Scope:**
- MVP: Delete action on moment detail view, 30-day soft delete, simple recovery
- Post-MVP: Trash view in Entries, bulk delete, restore via search

**Ticket Owner:** Assign to P5 (it's part of discovery/actions)

---

## 4. RE-DWELLING / MULTI-SESSION SOAKING (Notifications + Gaps)

**Questions:**
- Can user initiate prayer/prompts on a moment captured previously?
- How is this different from post-capture soaking (P3)?
- Can they dwell on a moment multiple times?
- What's the UX for returning to soaking?

**Pillar Owner(s):** P3 (Soaking/Responding) — owns the experience
**Entry Points:** P5 (Entries tap), Growth (theme tap), Today (unprayed moment), P8 (notifications)

**Current State:** Partially designed
- P3 covers post-capture prayer/prompts (single-session flow)
- P3 doesn't clarify if user can re-dwell on previous moments
- Entry points (P5, Growth, Today) assume re-soaking exists but don't design it

**What Needs Design:**
- Clarify: Is re-soaking the same UX as post-capture soaking, or different?
- Can user dwell on same moment multiple times?
- Does re-soaking create new "soaking entries" or update existing?
- Should re-soaking from different entry points feel consistent?

**Scope:**
- MVP: Re-soaking allowed from Entries/Growth (same UX as post-capture)
- Post-MVP: Dwell history (see all times user prayed about this moment)

**Ticket Owner:** Assign to P3 (Soaking) with cross-pillar liaisons

---

## 5. THEME CONTEXT & ACTIONS (Growth + Notifications + Gaps)

**Questions:**
- When user taps a theme in Growth tab, what view do they see?
- Is it just a filtered list of moments with that mood?
- Can they pray about a theme (multiple moments at once)?
- Can they explore theme progression over time?

**Pillar Owner(s):** P6 (Formation Intelligence) + Growth (displays themes) + P3 (soaking)

**Current State:** Partially designed
- Growth specifies: tap theme → see moments with that theme (implied: filtered Entries view)
- P6 (Formation Intelligence) provides theme detection but not UX
- No design for "theme-level" actions (pray about all moments in theme, etc.)

**What Needs Design:**
- Theme detail view: theme name, # of moments, timeline of occurrences, related themes
- Actions on theme: explore, pray about these moments, see progression
- Is there a unified "pray about this theme" action or does user tap individual moments?
- Theme exploration: if user taps "Doubt", can they see themes related to doubt (trust, faith, etc.)?

**Scope:**
- MVP: Theme → filtered moment list (can tap individual moments to pray)
- Post-MVP: Theme detail view, theme relationships, theme-level actions

**Ticket Owner:** Assign to Growth/P6 designer + P3 liaison

---

## 6. PHOTO/MEDIA VIEWING & CAPTURE (Capture + Gaps)

**Questions:**
- Can users add photos to moments during capture?
- How are photos displayed in moment detail view?
- Gallery view vs. embedded thumbnails?
- Photo selection: camera, photo library, or both?

**Pillar Owner(s):** P1 (Capture) + P4 (Journal Ownership — photos are part of journal artifact)

**Current State:** Mentioned but not designed
- P4 artifact includes "photos" field but no UI specified
- Capture (P1) doesn't specify photo capture/selection
- Detail view doesn't specify photo display

**What Needs Design:**
- Photo capture in Capture flow: tap to add photo, camera/library picker, cropping
- Photo storage: encrypted like moments, metadata stripping, size limits
- Photo display in detail view: thumbnail, full-screen gallery, lightbox
- Max photos per moment? Ordering?

**Scope:**
- MVP: Optional photo capture (1 photo per moment), thumbnail in journal, tap to expand
- Post-MVP: Multiple photos, gallery view, photo management (delete/reorder)

**Ticket Owner:** Assign to P1/P4 liaison

---

## 7. NOTIFICATION CENTER (Pillar 8 + Gaps)

**Questions:**
- Where do push notifications live when user receives them?
- Is there a notification center/history view?
- Can user disable individual notification types?
- Notification preferences in Settings?

**Pillar Owner(s):** P8 (Notifications & Nudges) — deferred to post-MVP

**Current State:** Deferred
- P8 is deferred to post-MVP pending validation of P0-P7
- Settings includes "Notification Preferences" link but no design of what that shows
- No design of notification center/history

**What Needs Design (Post-MVP):**
- Push notification flow: when delivered, where shown, tap actions
- Notification center: view history of recent notifications
- Notification preferences: toggle types, set quiet hours, frequency
- Integration with Settings: notification link routes to what?

**Scope:**
- MVP: None (P8 deferred)
- Post-MVP (Phase 3): Notifications, notification center, preferences

**Ticket Owner:** Defer to P8 pillar (post-MVP work)

---

## 8. ACCOUNT RECOVERY: EMAIL EDITING (Settings + Gaps)

**Questions:**
- Can user change their email address?
- How is email verified after change?
- What if they need to recover account via new email?

**Pillar Owner(s):** Settings (Account & Profile section)

**Current State:** Explicitly NOT designed
- Settings strategy specifies: "email display only" in MVP
- Deferring email editing to post-MVP due to account recovery complexity

**What Needs Design (Post-MVP):**
- Email change flow: verify current email, enter new email, verify new email
- Account recovery implications: if email changes, old recovery email invalid?

**Scope:**
- MVP: Display only (deferred)
- Post-MVP: Email editing with verification

**Ticket Owner:** Settings pillar (post-MVP)

---

## 9. MOMENT/JOURNAL EDITING POST-SYNTHESIS (P4 + Gaps)

**Questions:**
- Can user edit journal title, tags, moods AFTER the capture session ends?
- What if they want to revise a journal weeks later?
- Is editing in-place or a new customization flow?

**Pillar Owner(s):** P4 (Journal Ownership) + P5 (Search/Discovery as entry point)

**Current State:** Partially designed
- P4 covers customization **during capture session** (same-session flow)
- P4 doesn't clarify if editing is possible post-session
- Moment detail view (P5) probably has edit actions but not specified

**What Needs Design:**
- Post-session editing: are all customization options available? (title, tags, moods, photos)
- Is this a separate "Edit Journal" modal, or integrated into detail view?
- Should edits create a version history or just update in-place?
- Does editing trigger re-synthesis?

**Scope:**
- MVP: Basic editing (title, tags, moods) from moment detail view
- Post-MVP: Version history, advanced editing, re-synthesis

**Ticket Owner:** Assign to P4 (Journal Ownership)

---

## 10. FEATURE ANNOUNCEMENTS & PROMOTION TARGETING (Today + Growth + Notifications)

**Questions:**
- How are feature announcements targeted to users?
- Should only certain cohorts see new features?
- How often are announcements shown?
- What's the dismiss/archive flow?

**Pillar Owner(s):** P7 (Beta & Marketing) + Today (feature promotion slot) + Growth (potential promotion)

**Current State:** Partially designed
- Today specifies post-MVP feature promotion slot
- Growth mentions potential promotion in settings
- P7 covers cohort tracking but not feature rollout UX

**What Needs Design:**
- Feature announcement management: who decides what to announce when?
- Targeting logic: feature A only for Cohort A until week 3, then all users?
- Frequency capping: max 1 announcement per day?
- Dismiss/archive: one-tap hide, or feedback loop?
- Analytics: track which announcements get tapped, dismissed, etc.

**Scope:**
- MVP: Manual feature announcements (admin posts), simple dismiss
- Post-MVP: Targeted rollouts, A/B testing, analytics dashboard

**Ticket Owner:** Assign to P7 (Marketing) with Today/Growth liaisons

---

## 11. SEARCH & FILTER ACTIONS ON MOMENTS (P5 + Secondary Experiences)

**Questions:**
- From a search result, what actions can user take on a moment?
- Can they prayer, edit, delete, tag, share from search results?
- Does bulk action exist (select multiple, batch pray/delete)?

**Pillar Owner(s):** P5 (Search & Discovery)

**Current State:** Not designed
- P5 covers discovery (finding moments) but not actions on results
- Moment detail view (gap #1) will clarify actions, but search context needs design

**What Needs Design:**
- Search result card: what info shown? (title, mood, date, preview)
- Action menu: tap moment → detail view, or swipe for quick actions?
- Bulk actions: select multiple moments, pray about all, delete all?
- Search scoping: can user refine search within results?

**Scope:**
- MVP: Search results, tap → detail view, actions available there
- Post-MVP: Swipe actions, bulk operations, search refinement

**Ticket Owner:** Assign to P5 (Search & Discovery)

---

## Summary Table: All Gaps Mapped to Pillars

| Gap | Owner Pillar(s) | MVP or Post? | New Pillar Needed? | Blocker for T-092? |
|-----|---|---|---|---|
| 1. Moment/Journal Detail View | P5 + P3 + P4 | MVP | No | YES |
| 2. Account Recovery / Password Reset | P0 + P2 | MVP | No | YES |
| 3. Moment Deletion / Recovery | P5 + P4 | MVP | No | No (defer to P5 detail view) |
| 4. Re-Dwelling / Multi-Session Soaking | P3 (owns UX) | MVP | No | YES (P3 must clarify) |
| 5. Theme Context & Actions | P6 + Growth + P3 | MVP | No | No (clarify in Growth) |
| 6. Photo/Media Viewing & Capture | P1 + P4 | MVP | No | No (clarify in P1/P4) |
| 7. Notification Center | P8 | Post-MVP | No (P8 deferred) | No (deferred to Post-MVP) |
| 8. Email Editing | Settings | Post-MVP | No | No (deferred) |
| 9. Post-Synthesis Journal Editing | P4 + P5 | MVP | No | No (clarify in P4) |
| 10. Feature Announcements & Targeting | P7 + Today + Growth | MVP | No | No (clarify in P7) |
| 11. Search Result Actions | P5 | MVP | No | No (clarify in P5) |

---

## Recommendation Before T-092

**Critical (MVP Blockers — need design clarity):**
1. **Pillar 3 (Soaking)** — Expand to clarify: Does re-dwelling on previous moments use same UX as post-capture? (Affects Today, Growth, Entries entry points)
2. **Pillar 5 (Search & Discovery)** — Design moment detail view + actions (delete, edit, prayer, etc.)
3. **Pillar 0/P2 (Onboarding/Security)** — Design password reset flow for account recovery

**Important (MVP Nice-to-Have — can be designed in parallel):**
4. Clarify in P1/P4: Photo capture workflow
5. Clarify in P4: Post-synthesis editing capabilities
6. Clarify in P5: Search result actions + bulk operations
7. Clarify in Growth/P6: Theme detail view + theme exploration
8. Clarify in P7: Feature announcement rollout strategy

**Post-MVP (can defer):**
9. Notification center (P8 entire pillar deferred)
10. Email editing (Settings post-MVP)
11. Advanced photo management
12. Version history for edits

---

## Next Steps

**Option A (Conservative):** Lock current pillars, add 3 design clarification tickets to Pillars 3, 5, 0/2 during T-092 dependency mapping

**Option B (Thorough):** Expand Pillars 3, 5, 0/2 strategy docs now with clarifications before locking, then proceed to T-092

**Recommendation:** Option A is faster; we can add clarification tickets during T-092 sprint planning. All critical gaps are assignable to existing pillars (no new pillars needed).


# Pillar 0: Onboarding — Strategy & Design Skeleton

**Status:** ✅ Design Complete (T-060), Implementation Ready (Build 106+)  
**Last Updated:** May 5, 2026

---

## Key Job to Be Done

**Strategic Context:** Users arrive at Dwellable expecting a generic journaling or note app. They need to understand **why** Dwellable exists—not to replace their journal, but to help them dwell on moments with God.

**Onboarding's Job:** Establish user's spiritual intent, prayer rhythm, and privacy expectations *before* first capture. Set the tone that Dwellable is a **formation tool**, not a productivity app. Create psychological contract: "Your moments matter. We keep them safe. Dwelling on them is how you see God."

---

## Skeletal System Overview

7-screen sequential flow that educates, collects intent data, and launches first capture:

### Screen 1: **Welcome**
- **Copy:** "Help Christians notice and dwell on God's presence. See how God is forming you through every moment."
- **Action:** Single "Continue" button
- **Purpose:** Value prop + permission statement
- **Time on screen:** 3-5 seconds

### Screen 2: **Education**
- **Copy:** Explain what Dwellable *is* and *isn't*
  - "✅ Capture moments when God shows up—work encounters, worship, doubt, clarity, peace"
  - "✅ Return to dwell on your moments. See patterns. Build faith."
  - "❌ Not a to-do list. Not a generic journal. Not another app to check daily."
- **Action:** Single "Got it, let's go" button
- **Purpose:** Set correct mental model (formation tool, not productivity)
- **Time on screen:** 10-15 seconds

### Screen 3: **Intent**
- **Question:** "What brought you to Dwellable?"
- **Options:** (User selects one or more)
  - "I want to notice God more in my daily life"
  - "I'm wrestling with doubts and need to remember God's faithfulness"
  - "I want to see patterns in my spiritual journey"
  - "I'm in a season of spiritual growth and want to mark it"
  - "A friend recommended it"
- **Purpose:** Collect intent data for future personalization (Rich Context)
- **Storage:** Saved to user profile (informs future prompt personalization)
- **Time on screen:** 15-20 seconds

### Screen 4: **Rhythm**
- **Question:** "How often will you capture moments?"
- **Copy:** "This helps us invite you back at the right time—no guilt, no streaks."
- **Options:** (User selects one)
  - "A few times a week"
  - "Once a day"
  - "Multiple times a day"
  - "When inspiration strikes (unpredictable)"
- **Purpose:** Set expectations for notification frequency (determined in Phase 2)
- **Storage:** Saved to user profile (used for notification tuning in Pillar 8)
- **Time on screen:** 10-15 seconds

### Screen 5: **Account**
- **Question:** "Create your Dwellable account"
- **Fields:**
  - Email input
  - Password input (with strength indicator)
  - "I agree to Dwellable's Terms" checkbox
- **Purpose:** Create authenticated user session (Supabase JWT auth)
- **Validation:** Email format check, password minimum 8 characters
- **Error handling:** Show friendly error messages ("Email already in use") + retry
- **Time on screen:** 20-30 seconds

### Screen 6: **Privacy**
- **Copy:** "Your moments are yours alone."
- **Key points:**
  - "🔒 End-to-end encryption means only you can read your moments—not us, not servers, not anyone."
  - "📱 Your data stays on your device. We sync your encrypted moments to a secure backup only you can unlock."
  - "🚫 We never sell your data. We don't use your moments for training AI. Your story stays yours."
- **Action:** "I understand and trust Dwellable" button (explicit acknowledgment, not passive acceptance)
- **Purpose:** Establish privacy trust + legal compliance + differentiation (vs. generic apps that monitor user data)
- **Time on screen:** 20-30 seconds

### Screen 6.5: **Notification Permission** 🔔
- **Copy:** "We'll only send sparse, gentle invitations when there's something worth coming back to."
- **Action:** Two options:
  - "Enable notifications" → Triggers iOS native permission prompt (default path; encouraged)
  - "Not now" → Skip; user can re-enable later in Settings
- **Default:** Enabled (opt-out model — historically yields 70%+ adoption vs <30% for opt-in)
- **🔒 If user declines:** No notifications will be sent — ever. The user can re-enable in Settings, but Pillar 8's notification engine will respect the OS permission flag and skip all push triggers for this user. In-app surfaces (Today tab cards, flow handoffs) remain functional since those are UI, not notifications.
- **Purpose:** Establish notification consent before first capture (so Pillar 8 can fire Stage B push if user abandons before Screen 7).
- **Time on screen:** 10-15 seconds

### Screen 7: **First Capture** 🔒 *MANDATORY*
- **Copy:** "Let's capture your first moment."
- **Action:** Two buttons:
  - "Voice record" → Launches CaptureView (microphone focused)
  - "Type instead" → Launches TypeFlowView (text entry)
- **Purpose:** Immediate action (don't drop to home screen with empty gallery).
- **🔒 MANDATE (Locked):** User **cannot bypass first capture** to access other app surfaces. No "skip for now" option. No back-button escape route to home/list views. Onboarding is not complete — and app navigation is not unlocked — until at least one moment is captured.
- **Outcome:** User either:
  - Records a moment (momentum-building) → Onboarding complete → unlock full app
  - Types a moment (low-friction entry) → Onboarding complete → unlock full app
  - Either path activates LocalStorageManager (offline-capable) + SyncManager
  - **If user abandons app before capture:** Account is created but app remains gated on next open. Stage A push (from Pillar 8) re-invites them to complete capture.
- **Fallback (if mandate ever softens):** Show a glowing icon on the Capture button as a persistent visual nudge ("come here next"). Not implemented in MVP.
- **Time on screen:** Variable (5 minutes average for first moment)

---

## 🔒 Locked Cross-Pillar Requirements (Flow-Back from Other Strategies)

These requirements surfaced during work on other pillars and have been **filed into Pillar 0** as hard requirements. They are not optional and cannot be softened in MVP without ripple effects to dependent pillars.

### Requirement #1: First Capture Is Mandatory in Onboarding
- **Source:** Pillar 8 (Notifications) strategy — May 13, 2026
- **What:** Screen 7 must block app navigation until first capture is recorded. No skip option.
- **Why:** Without this mandate, Stage B's "Push only / no in-app parity" assumption breaks. The notification model assumes the user cannot encounter app surfaces (e.g., Today tab, Create tab empty state) without having captured at least once. Softening this requires re-architecting Stage B to include in-app variants.
- **Implementation note:** No "skip for now" link, no back-button escape. The only forward path from Screen 7 is `record voice` or `type instead`. Until capture is recorded, the user cannot reach the Today tab, Journal tab, or Settings.
- **Fallback (if ever softened):** Glowing icon on the Capture button as persistent visual nudge. Not in MVP.
- **Status:** ✅ Locked — applied to Screen 7 above.

### Requirement #2: Notification Permission Request Timing
- **Source:** Pillar 8 (Notifications) strategy — handoff via T-086
- **What:** Onboarding explicitly requests notification permission with brief framing: *"We'll only send sparse, gentle invitations when there's something worth coming back to."* Default: enabled (opt-out model).
- **Why:** Pillar 8 success depends on adoption; opt-out historically yields 70%+ adoption vs <30% for opt-in.
- **Where:** Standalone **Screen 6.5** (between Privacy and First Capture). Single screen, ~10-15 seconds.
- **If user declines:** No notifications fire — ever. User can re-enable in Settings. Pillar 8's engine respects the OS permission flag and skips all push triggers for declined users. In-app UI surfaces remain functional.
- **Status:** ✅ Locked — applied as Screen 6.5 above.

---

## Considered & Rejected

| Decision | Reasoning |
|----------|-----------|
| **Skip account creation until after first capture** | Creates security risk (moments orphaned if user abandons before login). Account creation before first moment ensures data ownership from moment one. |
| **Collect notification preferences in onboarding** | Premature—users don't yet understand what notifications mean. Rhythm (Screen 4) collects *intent*; actual notification frequency tuned in Phase 2 after we validate P0 features work. |
| **Optional onboarding (skippable screens)** | Onboarding sets psychological contract. Skipping any screen means user enters without understanding privacy, intent, or expectations. All screens are required for Phase 1. |
| **Include Scripture/devotional content in Privacy screen** | Violates "keeper not interpreter" principle. Privacy screen explains *data* privacy, not spiritual positioning. Spiritual framing happens in Screens 1-2. |
| **Gamification or streak tracking in first capture** | Contradicts grace-based messaging ("no guilt, no streaks"). First capture is invitation, not obligation. Removed all gamification language. |

---

## Open Questions

| Question | Status | Next Step |
|----------|--------|-----------|
| **What if user completes onboarding but never captures?** | ✅ **RESOLVED via mandate** (Screen 7 now blocks app navigation until first capture). Pillar 8 Stage B push handles users who abandon before capture. | n/a — locked |
| **Should users be able to edit Intent/Rhythm after onboarding?** | Deferred to Settings design | Design Settings flow for preference updates |
| **How granular should Intent options be?** | Needs user testing | Validate if current 4 options resonate; consider adding/removing based on beta feedback |
| **Recovery flow if user forgets password?** | Blocked by T-062 (E2E Encryption) | Design recovery UX that doesn't compromise encryption |
| **Multi-device onboarding (same account on iPad + iPhone)?** | Deferred to Post MVP | Explore account sync behavior across devices |

---

## Competitor Research & Skeletal References

### Prayer Apps (Pray.com, Abide, Dwell, Jesus Calling)
**Onboarding Pattern:** Intent collection → Preference setting → First action within 3 minutes  
**Key Insight:** Spiritual app onboarding works best when it's *fast and focused*. Users expect to interact with the app (not read copy) within first minute.  
**Screenshot reference:** [Screen shows single question + visual options + "Continue" button—no lengthy explanations]  
**Dwellable adoption:** Screens 1-4 are lean; copy is short; every screen has a single clear action

### Day One (Journaling App)
**Onboarding Pattern:** Welcome → Account setup → Motivational copy → First entry  
**Key Insight:** Journaling apps succeed when they get users writing *immediately*. First entry is habit-forming moment.  
**Screenshot reference:** [After account setup, immediate prompt: "What's on your mind?" with voice/text options]  
**Dwellable adoption:** Screen 7 (First Capture) mirrors this pattern—don't show empty gallery, launch capture directly

### Meditation Apps (Insight Timer, Calm)
**Onboarding Pattern:** Preference setting (meditation style, duration, goals) → Permission granting (notifications, microphone) → First experience  
**Key Insight:** Upfront preference collection enables personalization without feeling invasive.  
**Screenshot reference:** [Grid of preference tiles: "I'm a beginner" vs. "I've meditated before" → notification timing → skip option]  
**Dwellable adoption:** Screen 3 (Intent) and Screen 4 (Rhythm) collect personalization data without friction

### Bible App (YouVersion)
**Onboarding Pattern:** Bible version selection → Reading plan choice → Notification preferences → First reading  
**Key Insight:** Users appreciate *optionality*—every choice should include "skip" or "customize later" to avoid forced setup.  
**Screenshot reference:** [Each screen includes "Skip this" link in corner; can come back to settings after first interaction]  
**Dwellable adoption:** All screens are forward-moving (no skip links) because each serves a specific purpose; however, screens could support "edit later in Settings" approach

---

## Intended Outcome

### Adoption Metrics
- **Completion rate:** >90% of users reach Screen 7 (First Capture)
- **Account creation rate:** >95% of completers create account (Screen 5)
- **First capture rate:** >80% of users who reach Screen 7 record/type first moment
- **Drop-off analysis:** Identify which screens cause abandonment (Screen 3, 5, 6 are highest-risk due to decision fatigue)

### Experience Metrics
- **Time to first moment:** <5 minutes from app launch to completed capture
- **Confidence signal:** User feels they understand what Dwellable is (validate via post-onboarding survey)
- **Privacy perception:** 85%+ agree "Dwellable respects my privacy" after Screen 6

### Formation Outcomes
- **User understands intent:** "I know why I'm here" vs. "this seems like a note app"
- **User expects return:** "I'll come back to re-read this" vs. "I captured it, done"
- **User trusts security:** "My moments are safe" vs. "Is my data being sold?"

---

## Competitor Screenshot References

### Grace-Based Messaging (Key Differentiation)
**Reference:** Prayer apps use encouragement over obligation  
**Screenshot needed:** [Screen 3-4 showing language like "whenever inspiration strikes" vs. "every day" — removes guilt]

### Visual Simplicity (UX Pattern)
**Reference:** Meditation apps use large touch targets + minimal text  
**Screenshot needed:** [All screens showing single clear action button; no clutter or secondary navigation]

### Privacy Trust-Building (Emotional Architecture)
**Reference:** None of the competitors shown above have explicit privacy screens; Dwellable is differentiating here  
**Screenshot needed:** [Screen 6 showing lock icon + "End-to-end encryption" + clear language about data ownership]

### Immediate Action (Activation Pattern)
**Reference:** Day One, meditation apps show first action within 3 clicks  
**Screenshot needed:** [Screen 7 showing voice/text options immediately; no gallery tour or empty state before capture]

---

## Key Questions & Risks Considered

### Key Questions (Locked for Onboarding, Resolved)

1. **How much education is too much?**
   - **Answer:** Screens 1-2 are lean (copy is 1-2 bullets max). Long copy goes to privacy screen (Screen 6) where it matters.
   - **Validation:** Prayer app research shows users tune out after 15 seconds if copy is dense.

2. **When should users create an account—early or late in onboarding?**
   - **Answer:** Late (Screen 5, after intent + rhythm set). Don't ask for account until user understands why.
   - **Validation:** Day One, Calm delay account creation until after first interaction—reduces friction.

3. **Should notification preferences be in onboarding or deferred to Settings?**
   - **Answer:** Rhythm (Screen 4) collects preference intent; actual notification frequency tuned in Phase 2 (Pillar 8).
   - **Validation:** Decouples user intent from technical settings; allows experimentation post-launch.

4. **How explicit should privacy messaging be?**
   - **Answer:** Very explicit (Screen 6). Users expect generic apps to monetize data; Dwellable's differentiation is privacy-first, so make it clear.
   - **Validation:** Competitive advantage requires trust; privacy-concerned users are target demographic.

5. **What if user completes onboarding but doesn't capture first moment?**
   - **Answer:** Home screen shows empty gallery with soft prompt: "Ready to capture your first moment?" Notification sent 24h later.
   - **Validation:** Don't force capture; user owns the pace, but a gentle nudge within 24h helps.

### Top 5 Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| **Intent Collection Too Invasive** — Screen 3 feels like quiz | User abandons before capture | Multiple choice, optional follow-up to skip; no right/wrong answers; invitational framing |
| **Account Creation Friction** — Password validation too strict | Drop-off at Screen 5 > 10% | Clear error messages + progressive disclosure ("Why 8 characters?"); copy explains before asking |
| **Privacy Screen Too Dense** — Wall of text on Screen 6 | User doesn't read; false confidence | Use icons + short bullets; separate technical detail to Settings > Privacy (full explanation) |
| **First Capture Expectation Mismatch** — User thinks they must write something deep | Anxiety at Screen 7; blank moment | Copy: "Capture anything—a thought, a question, a moment of clarity. No pressure." |
| **Onboarding > 5 Minutes** — User perception: too slow | Drop-off due to impatience | Each screen ≤30 seconds copy, single action button; Screen 7 (capture) is only "long" screen (5 min) by design |

---

## Implementation Architecture

### Technical Flow
1. **Screens 1-6:** StatelessWidget sequence (SwiftUI NavigationStack)
2. **AuthManager:** Handle account creation (Screen 5) + JWT issuance
3. **UserDefaults:** Store onboarding completion flag + user intent + rhythm preference
4. **Screen 7:** Launch CaptureView or TypeFlowView based on user choice
5. **LocalStorageManager:** First moment saved locally (offline-capable)
6. **SyncManager:** Sync first moment to Supabase on network return

### Data Capture

**User Profile Fields (Created on Screen 5):**
- `email` (primary key)
- `password` (hashed via Supabase)
- `createdAt` (timestamp)

**User Preferences (Screens 3-4):**
- `spiritualIntent[]` (array: e.g., ["notice_god", "remember_faithfulness"])
- `captureRhythm` (enum: "few_times_week" | "daily" | "multiple_daily" | "unpredictable")
- `privacyConsent` (boolean, Screen 6)

**First Moment (Screen 7):**
- Standard Moment model (id, userId, body, captureType, createdAt)
- Stored locally → synced to API on network return

---

## What Comes After Onboarding

Once first moment is captured:

1. **Gallery View** → Empty at first, then populates as user captures more moments
2. **Settings** → User can edit Intent, Rhythm, Privacy preferences later
3. **Notifications** → Begin at frequency set in Screen 4 (tuned in Phase 2)
4. **Phase 2 Features** → Gallery, Tags, Soak, Reflection prompts unlock as Phase 2 ships

---

## Implementation Tickets (Ready to Start)

- **T-001 (ongoing):** LoginView and account creation (Supabase JWT)
- **T-060:** Onboarding screens 1-7 UI implementation (Complete — ready for Build 106+)
- **T-061:** Onboarding preference storage + ProfileManager (in progress)

---

**Reference:** See `archive/docs/P0_FEATURE_RESEARCH_FINDINGS.md` and `archive/docs/T-060_Phase2_Themes_1Pager.md` for competitive analysis and user research supporting onboarding design.

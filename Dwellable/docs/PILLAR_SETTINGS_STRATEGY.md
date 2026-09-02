# PILLAR: Settings & Account Management

**Pillar:** Settings | **Updated:** July 11, 2026 | **Status:** Strategy Locked

---

## 1. Overview

- **Purpose:** Provide users control over their account, preferences, security, and help access
- **Scope:** Account profile, security & privacy, notification preferences, support/feedback, legal/about
- **Status:** Strategy locked, ready for implementation ticket creation
- **Access Pattern (UPDATED July 11, 2026):** Gear icon in top-right corner of the **Growth tab only** (4th tab: Today | Entries | Create | Growth) — not visible from Today, Entries, or Create. Supersedes the prior "visible on all tabs" pattern.

---

## 2. Product Purpose

**Why Settings matters:**
- Users need to **own their account** — see their data, understand their security, manage preferences
- Dwellable asks intimate questions in Onboarding (intent, prayer rhythm) — Settings closes the loop by showing "here's what you told us, edit anytime"
- Settings is also a **trust mechanism** — encryption explanation, data export, clear legal terms build confidence in how we handle sacred moments
- Users want **one place** to control notifications, theme, feedback, support

---

## 3. Formation Intelligence System

**What Settings learns about the user:**
- Account identity: Name, email, spiritual intent, prayer rhythm aspiration
- Preference patterns: Notification frequency, prayer style, theme preference (dark/light post-MVP)
- Trust behavior: Does user engage with encryption explanation? Read "Learn More"?
- Feedback patterns: What users report as bugs, request as features, ask for support on
- Encryption comfort level: Whether user understands and trusts that their moments are securely protected
- Intent check feedback: Are they finding Dwellable helpful toward their stated intent?

**What system infers:**
- User's spiritual maturity level (how they describe intent, engagement depth)
- User's technical literacy (do they understand encryption?)
- User's communication style (what tone of support they prefer)
- User's commitment to formation (whether they're customizing preferences actively)
- User's trust in the app (whether they interact with security/privacy settings)

**How Settings feeds Formation Intelligence to next pillars:**
- **← P0 (Onboarding):** Settings displays & allows editing of intent + prayer rhythm set in P0
- **→ Growth:** Prayer frequency preference flows into Growth's calculation of expected prayer engagement
- **→ Notifications (P8):** Notification preferences + intent feedback inform what/when to notify
- **→ P7 (Beta):** Feedback + bug reports feed cohort segmentation and feature prioritization

**Formation Intelligence value:**
- Settings closes the loop: "Here's what you told us about yourself. Edit anytime." (affirms user ownership)
- Intent check prompt surfaces whether formation is happening ("Is Dwellable helping you [intent]?") — critical for validating system
- Encryption transparency builds trust: "You understand why your data is yours alone"

---

## 4. Success Criteria

**Qualitative:**
- [ ] Users feel in control of their data and preferences
- [ ] Settings are discoverable and not hidden
- [ ] Account info feels affirming, not intrusive
- [ ] Support/feedback pathway is obvious

**Quantitative:**
- [ ] >40% of users access Settings at least once in first 2 weeks
- [ ] >80% of users who adjust notification preferences find the option easily
- [ ] <5% user support requests about "how do I change my settings?"
- [ ] 100% of users can locate password change
- [ ] >70% read encryption explanation (open rate)

---

## 4. Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Access pattern (UPDATED July 11, 2026)** | Gear icon in top-right corner of the **Growth tab only** | Growth is where Settings already lives conceptually (prayer frequency, notifications) — Kell's call: one home for both quick-edit and full Settings, not duplicated across all 4 tabs |
| **Entry point (UPDATED July 11, 2026)** | Available from Growth tab only (top-right corner) | Supersedes the original "all main tabs" pattern; Settings is now scoped to the tab that already nests quick-edit preferences (Pillar 11 §5.3) |
| **Presentation** | Modal or sheet (not full-screen tab) | Settings are secondary to core capture/dwell experience; modal keeps focus |
| **Section organization** | 5 clear sections (Account, Security, Preferences, Support, Legal) | Reduces cognitive overload; users know where to find what they need |
| **Intent display** | Show intent statement + optional prompt: "Is Dwellable helping you [intent]?" | Closes loop from Onboarding; invites reflection without mandate |
| **Prayer frequency** | Editable preference (set aspiration, e.g., "5x/week") | Deferred to Pillar 0 tickets for contextualization |
| **Theme preference** | Post-MVP (MVP ships dark mode only) | Simplifies MVP; dark mode aligns with spiritual/contemplative UX |
| **Encryption explanation** | One-sentence plain language + "Learn more" link | Builds trust without overwhelming; link goes to detailed guide |

---

## 5. Settings Sections — Detailed Specs

### **Section 1: Account & Profile**

**Display:**
```
┌─────────────────────────────┐
│ ACCOUNT & PROFILE           │
├─────────────────────────────┤
│ Name                        │
│ [email@example.com]         │  [Editable]
│                             │
│ Intent Statement            │
│ [Deepen intimacy with God]  │  [View/Edit]
│                             │
│ Been a dweller since        │
│ [March 10, 2026]            │  [Read-only]
│                             │
│ Subscription Status         │
│ [Free Trial • 6 days left]  │  [Manage]
│                             │
│ [Optional: Intent prompt]   │
│ Is Dwellable helping you    │
│ deepen intimacy with God?   │
│ [Yes] [Not Yet] [Need Help] │
└─────────────────────────────┘
```

**Editable Fields:**
- Name: Can edit (name stored from Onboarding, allow changes)
- Email: Display only (editing email = account recovery risk, defer to P0 tickets)
- Intent Statement: Can view, link to "Edit" (routes to Onboarding flow or simplified intent editor)
- Subscription Status: Read-only (tap to see billing details, cancel, renew)

**Intent Prompt (MVP):**
- Optional CTAssurface once per week (not mandatory)
- "Is Dwellable helping you [their intent]?" — Yes / Not Yet / Need Help
- If "Need Help" → routes to contact support
- If "Not Yet" → routes to feedback form (gather insight)
- Data logged for future Formation Intelligence

**Correction (Sept 1, 2026):** Intent and Rhythm editing do NOT happen here. Both moved from Account Profile to Growth (P11) on Aug 31, 2026 (see T-195) — this doc had not caught up. For Formation Intelligence's integration with Intent editing (Row 4), see `docs/PILLAR_GROWTH_STRATEGY.md` and `docs/PILLAR_6_FORMATION_INTELLIGENCE_TECHNICAL_SPEC.md`, Row 4. Rhythm editing, wherever it lives, never touches Formation Intelligence in MVP regardless — it's self-reported data only, not part of the `DwellerProfile` model.

---

### **Section 2: Security & Privacy**

**Display:**
```
┌─────────────────────────────┐
│ SECURITY & PRIVACY          │
├─────────────────────────────┤
│ Password                    │
│ [Change Password]           │  [Button]
│                             │
│ Encryption                  │
│ Your data is encrypted      │
│ end-to-end. Only you can   │
│ read it.                    │
│ [Learn More]                │  [Link to guide]
│                             │
│ Data Export (Post-MVP)      │
│ Download your moments as    │
│ PDF.                        │
│ [Export Data]               │  [Button • disabled MVP]
└─────────────────────────────┘
```

**MVP Features:**
- **Change Password:** Tap → modal with "Current Password" + "New Password" + "Confirm Password" + Save
  - Validation: Password must be 8+ chars, mix of upper/lower/number/symbol
  - Success state: "Password updated" + dismiss
- **Encryption Explanation:** Plain-language one-liner + "Learn More" link
  - Link routes to separate help article explaining server-side encryption at rest and how the app processes data (see docs/PILLAR_2_SECURITY_STRATEGY.md's User Communication section for the plain-language framing)
  - Goal: Users understand "Dwellable cannot read my moments"

**Post-MVP Features:**
- **Data Export:** Download all moments as PDF (single file or zip)
- **Passcode/Face ID:** Unlock app without password
- **Session Management:** "Log out on all devices" option

---

### **Section 3: Preferences**

**Display:**
```
┌─────────────────────────────┐
│ PREFERENCES                 │
├─────────────────────────────┤
│ Prayer Frequency            │
│ [How often would you like   │
│  to pray?]                  │
│ Current: [5x / week]        │  [Edit]
│                             │
│ Theme (Post-MVP)            │
│ [Dark Mode] [Light Mode]    │  [Disabled MVP]
│                             │
│ Notifications               │
│ [Manage Preferences]        │  [Button]
└─────────────────────────────┘
```

**MVP Features:**
- **Prayer Frequency:** Editable dropdown
  - Options: Daily / 5x week / 3x week / Weekly / As it comes
  - Sourced from Onboarding P0, but allow edit here
  - (Note: Contextualization with intent deferred to P0 ticket writing)
- **Notification Preferences:** Tap → routes to notification settings (frequency, notification type, timing, opt-out)
  - This mirrors the notification strategy doc (Pillar 8) settings

**Post-MVP Features:**
- **Theme:** Light/Dark mode toggle (MVP ships dark mode only)

---

### **Section 4: Support & Feedback**

**Display:**
```
┌─────────────────────────────┐
│ SUPPORT & FEEDBACK          │
├─────────────────────────────┤
│ Send Feedback               │
│ Help us improve Dwellable   │
│ [Send Feedback]             │  [Button/Form]
│                             │
│ Report a Bug                │
│ Something not working?      │
│ [Report Bug]                │  [Button/Form]
│                             │
│ Contact Support             │
│ Questions or issues?        │
│ [Email: hello@dwellable...] │  [Copy/Tap]
│ [FAQ & Help Center]         │  [Link]
└─────────────────────────────┘
```

**MVP Features:**
- **Send Feedback:** Tap → form appears with text field ("What would help you?") + submit
  - Submitted feedback logged to support email + stored in Supabase for review
- **Report a Bug:** Tap → form with "What went wrong?" + steps to reproduce + screenshot (optional)
  - Bug reports go to internal dashboard for triage
- **Contact Support:** Email link (hello@dwellable.com — TBD) + FAQ link
  - Email link opens mail client (native)
  - FAQ link routes to web help center (post-MVP)

---

### **Section 5: Legal & About**

**Display:**
```
┌─────────────────────────────┐
│ LEGAL & ABOUT               │
├─────────────────────────────┤
│ About Dwellable             │
│ [Our Story & Mission]       │  [Link]
│                             │
│ Version History             │
│ App Version: 1.0.0          │  [Read-only]
│ Build: 107                  │  [Read-only]
│                             │
│ Terms of Service            │
│ [View Terms]                │  [Link]
│                             │
│ Privacy Policy              │
│ [View Privacy]              │  [Link]
└─────────────────────────────┘
```

**MVP Features:**
- **About Dwellable:** Tap → modal or web view showing Dwellable's story/mission
  - Content: "Why we built Dwellable" (paragraph + vision statement)
- **Version History:** Display app version (e.g., "1.0.0") + build number (e.g., "Build 107")
  - Read-only; useful for troubleshooting
- **Terms of Service:** Tap → web link to full legal document (hosted on website)
- **Privacy Policy:** Tap → web link to full privacy policy (hosted on website)

---

## 6. Alternatives Considered (Not Chosen)

| Alternative | Why Considered | Why Not Chosen |
|-------------|-----------------|-----------------|
| **Settings as bottom tab** | iOS standard (Settings app paradigm) | Would steal real estate from 4-tab core menu; Settings is secondary |
| **Settings in side drawer** | Proven navigation pattern | Less discoverable than gear icon; adds extra interaction |
| **Gear icon visible on all 4 main tabs** (original decision, superseded July 11, 2026) | Maximizes discoverability; access anytime | Kell's call: duplicated the icon across 4 tabs for a secondary surface; Growth already nests quick-edit Preferences (Pillar 11 §5.3), so a single home in Growth's top corner is simpler and non-redundant |
| **Full-screen Settings view** | More space for content | Disruptive to core capture/dwell flow; modal keeps focus |
| **Hide Settings entirely** | Minimal UI philosophy | Users need password change, contact support, legal info — can't hide |
| **Theme preference in MVP** | Users want light mode | Dark mode aligns with contemplative brand; light mode post-MVP keeps MVP lean |
| **Email editing in Settings** | Users want to change email | Email recovery is complex; defer email changes to account recovery flow (post-MVP) |

---

## 7. Metrics to Track

| Metric | Definition | Success Target |
|--------|-----------|-----------------|
| **Settings Access Rate** | % of users who open Settings within first 2 weeks | >40% |
| **Notification Preference Edits** | % of users who adjust notification settings | >30% by week 4 |
| **Password Change Rate** | % of users who change password (post-login) | >10% (security baseline) |
| **Intent Prompt Engagement** | % of users who respond to intent check prompt | >50% when shown |
| **Feedback Submission Rate** | # of feedback/bug reports per 100 users | >5 reports/100 users/month |
| **FAQ Bounce Rate** | % of users who tap FAQ and find answer (not contact support) | >60% |
| **Encryption Explanation CTA** | % of users who tap "Learn More" on encryption | >20% |
| **Settings Discovery Time** | Median time to first Settings access | <5 minutes |

---

## 8. Implementation Approach

**Phase 1 (MVP Launch):**
- [ ] Build Settings screen shell (modal/sheet with 5 sections)
- [ ] Implement Account & Profile section
  - Display name, email, intent, account creation date, subscription status
  - Link "Edit intent" → Onboarding intent editor OR simplified intent modal
  - Implement optional intent check prompt (weekly)
- [ ] Implement Security & Privacy section
  - Password change flow (validation + confirmation)
  - Encryption explanation + "Learn More" link (route to help article)
- [ ] Implement Preferences section
  - Prayer frequency dropdown (editable)
  - Notification settings button (routes to notification preferences)
- [ ] Implement Support & Feedback section
  - Feedback form + bug report form
  - Email link + FAQ link
- [ ] Implement Legal & About section
  - About Dwellable modal
  - Version/build display
  - Terms + Privacy links (route to website)
- [ ] Wire gear icon to Settings modal (top-right corner of Growth tab only — not on Today/Entries/Create)
- [ ] Test on device (iPhone 13+)

**Phase 2 (Post-MVP Polish):**
- [ ] Add theme preference (Light/Dark toggle)
- [ ] Implement data export (PDF generation)
- [ ] Add passcode/Face ID unlock
- [ ] Build FAQ help center (post-MVP web content)
- [ ] Implement email editing with account recovery flow
- [ ] Add session management ("Log out all devices")

---

## 9. Tickets to Create

| Ticket | Title | Effort | Dependencies |
|--------|-------|--------|--------------|
| T-XXX | Build: Settings Modal Shell (5 sections, navigation) | M | None |
| T-XXX | Build: Account & Profile Section (display + edit intent) | M | T-XXX |
| T-XXX | Build: Security & Privacy Section (password change + encryption info) | M | T-XXX, T-062 (server-side encryption) |
| T-XXX | Build: Preferences Section (prayer frequency + notification link) | S | T-XXX |
| T-XXX | Build: Support & Feedback Section (forms + links) | M | T-XXX |
| T-XXX | Build: Legal & About Section (links + version display) | S | T-XXX |
| T-XXX | Wire: Gear icon to Settings (Growth tab, top-right corner only) | S | T-XXX (all sections) |
| T-XXX | Feature: Intent Check Prompt (weekly, optional) | M | T-XXX (Account section) |
| T-XXX | Test: Settings on device (iPhone 13+) | S | All sections |

**Estimated effort:** 9 tickets, ~60–90 hours (1.5–2 weeks, including testing)

---

## 10. Risks & Constraints

| Risk | Impact | Mitigation |
|------|--------|-----------|
| **Users miss Settings** | Settings less discoverable than expected; <20% access rate | Use onboarding tooltip on first launch; also mention in "Here's how to..." help content |
| **Password change complexity** | Users get stuck changing password | Simple form validation + clear error messages; test with real users pre-MVP |
| **Intent edit confusing** | Users unsure how to edit intent | Link to simplified intent modal (or full Onboarding flow); test language first |
| **Feedback/bug reports noisy** | High volume of unhelpful reports; support overwhelmed | Add form validation (require minimum 10 chars) + categorization (bug vs. feature vs. feedback) |
| **Legal links break** | Users can't access terms/privacy | Host docs on website with permanent URLs; monitor for 404s |
| **Encryption explanation too technical** | Users don't understand how their data is protected | Plain-language one-liner ("your moments are secure with us") + link to detailed guide (write plain-English explanation, not technical) |
| **Account recovery missing** | Users locked out of account | Defer email editing to post-MVP; implement robust password reset flow (separate ticket) |

---

## 11. Cross-Pillar Dependencies

- **Pillar 0 (Onboarding):** Settings displays data from P0 (name, email, intent, prayer rhythm). Intent edit flow should route back to P0 intent editor.
- **Pillar 2 (Security & Privacy):** Settings explains the security/stewardship model (P2 responsibility). Link to help article should be written by P2 owner.
- **Pillar 8 (Notifications):** Notification preferences button in Settings routes to Pillar 8 notification settings.
- **Pillar 11 (Growth):** Settings' gear icon lives in Growth's top-right corner only (UPDATED July 11, 2026) — Growth already nests a quick-edit Preferences subsection (prayer frequency, notification link) that references the same underlying fields as this pillar's Preferences section. Menu Bar/Navigation has no dedicated pillar (implementation only, T-076–T-082).

---

## 12. Summary

| Aspect | Decision |
|--------|----------|
| **Goal** | Give users ownership of account, preferences, security, and help access |
| **Access** | Gear icon in top-right (visible from all main tabs) — modal/sheet |
| **5 Sections** | Account & Profile \| Security & Privacy \| Preferences \| Support & Feedback \| Legal & About |
| **MVP scope** | Account display + edit intent, password change, encryption info, prayer frequency, notification preferences, feedback forms, legal/about |
| **Post-MVP scope** | Data export (PDF), passcode/Face ID, theme preference, email editing, session management, FAQ help center |
| **Success metric** | >40% settings access rate in first 2 weeks, >80% can find password change |
| **Key blocker** | Onboarding (P0) must be complete so Settings can reference & edit intent + prayer rhythm |

---

**Status:** Ready for ticket creation. All design decisions locked.

**Next:** Create implementation tickets (T-XXX–T-XXX) and assign to engineer.

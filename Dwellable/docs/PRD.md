# Dwellable — Product Requirements Document (PRD)

**Founder:** Kell Golden | **Living Document** | **Updated:** May 4, 2026

---

## Section 1: Foundation

### North Star

Dwellable exists to help Christians notice and dwell on God's presence across their entire life — in the extraordinary and the mundane — so they can see how God is forming them through every moment.

Not to interpret them. Not to explain them. Not to replace prayer, Scripture, or community.

To hold them. To preserve them. To make returning effortless — so that the highs, lows, and ordinary moments of daily life remain active and influential, shaping spiritual formation over time.

---

### Problem & Insight

**The Problem:** Christians capture meaningful moments (work, relationships, doubts, breakthroughs, ordinary days) but most fade without reflection. People journal but don't dwell. Generic tools aren't designed for spiritual formation. Without a gentle return mechanism, insights are lost.

**The Core Insight (Phase 1 Validated):**
- ✅ Capture adoption is NOT the barrier — 100% of Phase 1 users immediately adopted voice-first capture
- ❌ Return is the barrier — 0% spontaneously revisited moments
- **Real problem: Reflection failure, not capture friction**

Many people journal readily. The transformative work — dwelling, pattern recognition, spiritual formation — happens only when moments are revisited and reflected upon.

**Dwellable's Role:** Build the return mechanism that makes dwelling irresistible, so captured moments accumulate into a living record of God's presence over time.

---

### Product Principles (Authority Guardrails)

Dwellable is a **keeper of sacred moments, not an interpreter**:

- ✅ Hold moments — preserve them safely, accessible indefinitely
- ✅ Facilitate revisiting moments — make return effortless and rewarding
- ✅ Surface patterns over time — let emergent themes appear naturally from user's own accumulated moments
- ✅ Invite Socratic reflection — ask questions, never prescribe answers
- ✅ Presence Through Rich Context — synthesize user's actual story to enable hyper-personalized prayers and prompts (not interpretation, enabling their encounter with God)
- ❌ Do NOT confirm meaning — never tell users what their moments mean
- ❌ Do NOT prescribe action — never tell users what they should do
- ❌ Do NOT become a spiritual voice — never position ourselves as authoritative or interpretive

---

### Target Users

**Group 1 — Consistent Reflectors**  
Individuals who journal or reflect regularly and already value returning to past moments. Need: reduced capture friction, seamless fit with existing habits.

**Group 2 — Selective Reflectors**  
Individuals who journal intermittently and only record moments that feel "big enough." Need: low-pressure preservation, optional return without obligation.

**Group 3 — Presence-Oriented Experiencers (Deprioritized)**  
Individuals who rarely journal and prefer to fully experience moments in the present. Requires behavior change — not friction reduction. Not focus for Phase 1 or Phase 2.

---

### Build Phases

**Phase 1 Beta — Capture + Review + Analytics (COMPLETE)**
Establish core capture functionality. Validate that users will adopt a faith-specific moment capture tool over generic alternatives. Build 105 live on TestFlight.

**Phase 2 Beta — Return + Reflection + Formation Intelligence (IN PROGRESS)**
Introduce return mechanisms (gallery, nudges, reflection prompts). Build sustained dwelling practice. Add Rich Context-powered personalization. Design Phase 2 pillars to close the return gap identified in Phase 1.

**Post-Launch — Formation Intelligence**
Pattern surfacing, semantic search across moments, themed views, optional biblical anchoring. AI as a question-asker, never an interpreter.

---

## Section 2: Pillars (Phase 2+)

### Pillar 0: Onboarding (Sign-Up & Account Setup)

**Status:** ✅ Design Complete (T-060), Implementation Ready  
**Locked:** 7-screen sequential flow (Welcome → Education → Intent → Rhythm → Account → Privacy → First Capture)

**Design Skeleton:** See [`docs/PILLAR_ONBOARDING_STRATEGY.md`](PILLAR_ONBOARDING_STRATEGY.md) for full design specification, competitor research (Prayer Lock, Dwell, Day One, Calm), and implementation guidance.

**Core Intent:** Establish spiritual intent, prayer rhythm, and privacy expectations before first capture. Set psychological contract that Dwellable is a formation tool, not a productivity app.

**Success Metrics:**
- Completion rate: >90% reach first capture
- First capture rate: >80% of completers record/type moment
- Time to value: <5 minutes from app launch to completed capture

**Risks:** Intent collection friction, account creation drop-off, privacy screen comprehension, first capture anxiety

---

### Pillar 1: Capture (Voice + Text)

**Status:** ✅ Phase 1 Beta Complete (Build 107)  
**Locked:** Voice-first with text fallback, rotating prompts, offline-first architecture, Speech Framework transcription

**Design Skeleton:** See [`docs/PILLAR_1_CAPTURE_STRATEGY.md`](PILLAR_1_CAPTURE_STRATEGY.md) for full technical architecture, validation rules, risk mitigations, and Phase 1 completion metrics (100% adoption, 3-5 moments/user, >95% transcription accuracy).

**Open Questions:**
- Should users be able to capture multiple moments in rapid succession?
- How should we handle very long recordings (15+ min)?
- Should we support photo/video attachments beyond audio?

**Exclusions:** Image captions, drawing/sketch input, structured forms (intentionally unstructured)

**Risks:** Audio quality varies by device; Speech Framework accuracy depends on environment

---

### Pillar 2: Security & Privacy (E2E Encryption)

**Status:** 🔄 Phase 2 Beta (T-062 In Progress)  
**Locked:** AES-256-GCM encryption, key derivation from password, client-side encryption/decryption

**Open Questions:**
- Recovery flow if user forgets password?
- Should encryption keys be backed up to cloud?
- Multi-device support (user syncing across devices)?
- How to handle backup/restore with encryption?

**Exclusions:** Zero-knowledge architecture (user can recover, but only they can decrypt), server-side decryption, cloud key storage

**Risks:** Encryption UX complexity; recovery scenarios; performance on older devices; testing encrypted data flows

#### Implementation Tickets
- T-062: Implement End-to-End Encryption for Moments (16-24 hours, BLOCKING)
  - AES-256-GCM encryption implementation
  - Key derivation from password
  - Encrypted storage and sync
  - Client-side decryption on read
- T-XXX: Password recovery mechanism (design + engineering)
- *(Dependencies: Pillar 1 (Capture) must be complete; blocking for Pillar 3)*

---

### Pillar 3: Soaking/Responding to Captures (Prayer + Prompts)

**Status:** ✅ Design Complete, Implementation Not Started  
**Locked:** 2-option skeleton (Prayer + Prompts), Rich Context powered, invitational framing ("Want to?"), Gallery + Soak Mode + Reflection Prompts + Notifications architecture

**Design Skeleton:** See [`docs/PILLAR_3_SOAKING_STRATEGY.md`](PILLAR_3_SOAKING_STRATEGY.md) for full design specification, competitor research (Prayer Lock, Untold, Calm, Medito, Dwell, Day One, Stoic), skeletal system architecture, and success metrics (WAR 40-50% by week 8).

**Core Concept:**  
When users return to past moments, offer two contextual pathways:
1. **Prayer** — Guided, contemplative response with optional reflection prompt
2. **Prompts** — Sequential dialogue ("Socratic reflection") that helps users discover their own insights

Both powered by Rich Context to reference user's actual story and themes. Gallery View + Tags + Soak Mode create the visual + contemplative infrastructure for dwelling.

**Open Questions:**
- How should we balance guided prayer vs. open-ended reflection?
- Should users be able to respond multiple times to the same moment?
- How do we handle moments that trigger difficult emotions?
- What should prompt sequences look like (3 prompts? 5? variable)?

**Exclusions:** Interpretation, prescriptive guidance, theological commentary, devotional content, pre-written prayers

**Risks:** Prayer language resonance; theological sensitivity; avoiding prescriptive framing; Rich Context complexity

#### Implementation Tickets
*(To be created after design skeleton locked)*
- T-XXX: Prayer flow (design + engineering) — Guided contemplative response, optional prompt
- T-XXX: Prompts flow (design + engineering) — Sequential dialogue, user discovery
- T-XXX: Rich Context integration for Soaking (design + engineering) — Reference user's story, themes, patterns
- T-XXX: Response persistence (engineering) — Store responses, track completion status
- *(Dependencies: Pillar 1 (Capture), Pillar 2 (Encryption T-062) must be complete)*

---

### Pillar 4: Editing

**Status:** 🔄 Phase 2 Beta (Design In Progress)  
**Locked:** Not yet locked; design in progress

**Open Questions:**
- Should users be able to edit transcripts before saving?
- Can they edit after saving?
- Should edit history be visible?
- Should we alert users if they edit significantly after the fact?

**Exclusions:** Collaborative editing, version control

#### Implementation Tickets
*(To be created after design skeleton is locked)*
- T-XXX: Edit existing moment (design + engineering)
- T-XXX: Delete moment with confirmation (design + engineering)
- *(Dependencies: Pillar 3 implementation must be complete)*

---

### Pillar 5: Search & Discovery

**Status:** 🔄 Phase 2 Beta (Design In Progress)  
**Locked:** Not yet locked; design in progress

**Open Questions:**
- Full-text search, semantic search, or both?
- Filter by date, theme, sense of Lord reference?
- Should search index be encrypted?
- How should search results surface context (full moment or snippet)?

**Exclusions:** Tag-based organization, AI-powered recommendations (post-launch)

#### Implementation Tickets
*(To be created after design skeleton is locked)*
- T-XXX: Full-text search implementation (design + engineering)
- T-XXX: Filter/refine search results (design + engineering)
- *(Dependencies: Pillar 3 implementation; Pillar 2 encryption if applicable)*

---

### Pillar 6: Formation Intelligence (Patterns & Themes)

**Status:** 🔄 Phase 2 Beta (Design In Progress)  
**Locked:** Not yet locked; design in progress

**Core Concept (Draft):**  
Detect recurring themes across moments (anxiety, joy, relational moments, breakthroughs) and surface them as text-based insights without interpretation. Use Rich Context to understand user's actual story.

**Phase 2 Scope:**  
- Theme detection (Socratic, not prescriptive)
- Text-based pattern surfacing
- Integration with Soaking flows (reference themes in prayer/prompts)

**Post-Launch Scope:**  
- Visual gallery/imagery
- AI-generated moment illustrations
- Advanced semantic analysis

**Open Questions:**
- How to detect themes without prescriptive categorization?
- Should themes be user-tagged or AI-detected?
- How often should pattern reports surface?
- Should theme insights be pushed to users or pull-based?

**Exclusions:** Spiritual interpretation, predictive modeling, prescriptive insights, visual galleries

#### Implementation Tickets
*(To be created after design skeleton is locked)*
- T-XXX: Theme detection algorithm (design + engineering)
- T-XXX: Surface themes in Soaking prompts (integration)
- T-XXX: Theme report/dashboard UI (design + engineering)
- *(Dependencies: Pillar 3 implementation; Rich Context integration)*

---

### Pillar 7: Beta & Marketing

**Status:** 🔄 Phase 2 Beta (Design In Progress)  
**Locked:** Not yet locked; design in progress

**Core Concept:**  
Expand from Phase 1 personal dogfooding to Phase 2 closed beta with targeted user cohorts. Build self-signup flow, manage beta cohorts, gather qualitative feedback on return/reflection experience.

**Phase 2 Scope:**
- Self-signup flow for beta users
- Beta cohort management (closed beta, limited seats)
- Feedback collection (surveys, interviews, usage analytics)
- Community engagement (Discord, email list)

**Post-Launch Scope:**
- App Store submission and marketing
- Public launch campaign
- Paid ads, content strategy, partnerships

**Open Questions:**
- How many users for Phase 2 Beta (50? 100? 500?)?
- Should we use waitlist/invites or open signup?
- What feedback mechanisms during beta?
- How do we measure "dwelling" behavior qualitatively?

**Exclusions:** Paid advertising, content marketing, App Store launch, broad marketing campaigns

#### Implementation Tickets
*(To be created after design skeleton is locked)*
- T-XXX: Self-signup flow (design + engineering)
- T-XXX: Beta user management dashboard (design + engineering)
- T-XXX: Feedback collection system (surveys, analytics)
- *(Dependencies: All Pillars 1-6 implementation must be functional for beta)*

---

### Pillar 8: Notifications

**Status:** ⚪ Design Deferred (Pillar 8 — Last)  
**Locked:** Concept locked; design deferred to after Phase 2 other pillars launched

**Core Concept:**  
Pattern detection + contextual nudges. When user reflects on a theme 3+ times without prayer, send gentle notification: *"You reflected on anxiety, but haven't prayed. Want to now?"* Invitational, not prescriptive.

**Why Deferred to Last:**  
We need to confirm what experiences we are creating before knowing what we are notifying dwellers of. Notifications requires all other pillars (Capture, Soaking, Search, Formation Intelligence) to exist and be validated first.

**Open Questions:**
- When should nudges arrive (day after? after 3rd moment? week later)?
- How to identify themes without prescriptive interpretation?
- Can users opt-out or customize frequency?
- What counts as a "theme"?
- Should we use push notifications, in-app, or both?

**Exclusions:** Push notifications for generic content, devotional reminders, urgency framing, prescriptive interpretation

**Design Deferred to Phase 2+:** Competitive research, theme detection strategy, notification frequency caps, user control mechanisms, implementation design

#### Implementation Tickets
*(To be created after all other pillars ship and design is locked)*
- T-XXX: Pattern detection + theme identification (engineering)
- T-XXX: Notification scheduling + delivery (engineering)
- T-XXX: User notification preferences UI (design + engineering)
- *(Dependencies: Pillars 3, 6 must be complete and validated)*

---

## Section 3: Technical Architecture

### Tech Stack

- **Framework:** SwiftUI (native iOS, iOS 15+)
- **Language:** Swift 5.9
- **Backend:** Supabase (PostgreSQL + Auth + RLS)
- **Local Storage:** Keychain (secure) + UserDefaults (sync queue)
- **Voice Recording:** AVFoundation (native iOS audio)
- **Voice-to-Text:** Speech Framework (on-device, privacy-first)
- **HTTP Client:** URLSession (native)
- **Encryption (T-062):** CryptoKit (native Swift crypto library)

### Data Model

```swift
struct Moment: Codable {
    let id: String                  // UUID
    let userId: String              // Supabase auth user ID
    let body: String                // The moment itself (encrypted in Phase 2+)
    let senseOfLord: String?        // Optional reflection
    let createdAt: Date             // ISO timestamp
    let updatedAt: Date
}

struct UsageEvent: Codable {
    let id: String
    let userId: String
    let eventType: String           // "app_opened", "app_closed", "moment_created"
    let momentType: String?         // "voice" or "text"
    let timestamp: Date
}
```

### Backend Architecture

**Authentication:**
- Email + password with Supabase JWT auth
- Session persistence via Keychain
- Automatic token refresh on 401

**Security:**
- Row-Level Security (RLS) — users only access their own moments
- HTTPS enforced; no HTTP fallback
- Certificate pinning (SHA256 public key validation)
- Brute force protection (5-attempt lockout, 10-min timeout)
- E2E Encryption (T-062) — client-side encryption before sync

**Offline-First Sync:**
- Moments stored locally in Keychain + UserDefaults
- Pending moments queue persists across app restarts
- Auto-sync when network becomes available
- Conflicts resolved via UUID-based upsert logic

### Analytics

**Events Tracked:**
- `app_opened` — session start
- `app_closed` — session end
- `moment_created` — with momentType (voice or text)

**Data Captured:** User ID, event type, moment type, timestamp  
**Purpose:** Validate Phase 1/2 success metrics without tracking moment content

---

## Section 4: Phase 1 Beta Details

### Purpose

Validate that users will adopt a faith-specific moment capture tool — designed specifically for Christian reflection and spiritual formation — over generic alternatives (Notes, Day One, voice memos).

Phase 1 is not about building a complete product. It is about proving one thing: will people use this to capture their daily life (highs, lows, mundane moments) in a way that's intentional and contextual to their faith?

### Phase 1 Pilot Parameters

- **Duration:** March 10–17, 2026 (7-day personal dogfooding) → QA → TestFlight
- **Users:** 10+ participants across consistent reflectors and selective reflectors
- **Distribution:** iOS via TestFlight
- **Auth:** Pre-provisioned Supabase email accounts (no self-signup)
- **Current Status:** Build 105 deployed to TestFlight; dogfooding complete

### Phase 1 Success Definition

**Qualitative:** "This is not only easier to capture my God moments — I find myself capturing more of them."

**Quantitative:**
- Number of moments captured per user per week
- Number of moment views (user returns to read past moments) — **Phase 1 Result: 0%**
- Time to first captured moment after onboarding
- Delta in capture frequency week 1 vs week 4
- Session frequency and app open patterns

**Emotional Outcome:** A measurable shift from anxious/uncertain to confident/anchored.

### Phase 1 User Flow (Happy Path)

1. User opens app
2. User lands on Moments list (home screen)
3. User taps "+" CTA at bottom
4. User lands on Capture screen — mic centered, reflective prompt above
5. User taps mic to start recording their moment
6. User taps mic again to stop → "Transcribing..." → Review screen with transcript
7. Optional: User adds "Where did you sense the Lord?"
8. User taps "Save" → returns to Moments list
9. Moment appears at top of list

**Alternate path (type instead):**
- From Capture screen, user taps "type instead →" → Review screen (blank)
- User types moment → taps "Save moment" → returns to Moments list

### Phase 1 Features

**Core Screens (Built & Live)**

- **LoginView** — Email + password login, session persistence
- **CaptureView** — Voice-first with text fallback, rotating prompts
- **ReviewView** — Transcript edit, "Where did you sense the Lord?", save with offline sync
- **MomentsListView** — Chronological list, empty state, sync indicator
- **MomentDetailView** — Full moment display, metadata, re-read tracking
- **SettingsView** — Profile, app info, sign out

**Backend & Sync**
- Supabase authentication + RLS
- Offline-first architecture (Keychain + UserDefaults)
- Auto-sync with retry logic
- Analytics event tracking

**Explicitly Out of Scope (Phase 1)**
- Editing or deleting moments
- Gallery view or visual browsing
- AI-generated moment images
- Reminders or push notifications
- Pattern surfacing or reflection
- Search or filtering
- Tags or categories
- Interpretation or theological guidance
- Social features or sharing
- Image/media attachments (beyond voice)

### Phase 1 Build Status

- **Build:** 105 live on TestFlight
- **Tickets:** 46/61 complete (75%)
- **Status:** Phase 1 dogfooding in progress; zero return rate identified

---

## Success Metrics & Validation

### Phase 1 Validation (Complete)
- ✅ 100% adoption of voice capture
- ❌ 0% return rate (problem identified: users don't revisit moments)

### Phase 2 Validation (In Progress)
- **Primary Metric:** WAR (Weekly Active Reflections) — % of users returning weekly
- **Target:** 40–50% of users return weekly by week 8
- **Secondary Metrics:**
  - Average session length increase
  - Reflection engagement rate
  - Retention (% of Phase 1 users active in Phase 2)

### Long-Term Success (Post-Launch)
- Users report: "I see patterns in how God shows up across my life"
- Formation indicators: increased spiritual confidence, perceived divine presence, faith integration in daily decisions
- Retention: >60% monthly active users

---

## Appendix: Files & References

- **VISION.md** — Product vision, principles, target users
- **ARCHITECTURE.md** — Technical system design
- **WORKFLOW.md** — Development workflow
- **KEY_LEARNINGS.md** — Phase 1 findings and research qualifications
- **NOTIFICATIONS_PILLAR.md** — Pillar 8 detailed concept
- **ONBOARDING_DESIGN_GUIDELINES.md** — Phase 2 onboarding strategy
- **TICKETS.md** — Full ticket registry with estimates and dependencies

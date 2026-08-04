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

**MVP core loop (locked August 3, 2026): Capture → Process (Dwelly conversation) → Journal.** Three things, deliberately — Kell judged that's already enough scope risk without adding a fourth. Prayer (Pillar 3) is deferred to Post-MVP as a nice-to-have layered on top of an already-complete loop, not essential to prove the core hypothesis.

**Post-Launch — Formation Intelligence**
Pattern surfacing, semantic search across moments, themed views, optional biblical anchoring. AI as a question-asker, never an interpreter.

---

## Section 2: Pillars (Phase 2+)

**Pillar Architecture Update (May 7, 2026):** Journal Creation has been inserted after Prayer (Pillar 3), shifting subsequent pillars from 4→5, 5→6, 6→7, 7→8. Total structure is now 0-8 (9 pillars).

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

### Pillar 2: Security & Privacy (Server-Side Encryption)

**Status:** 🔄 Phase 2 Beta (T-062 In Progress)  
**Locked (updated July 22, 2026):** AES-256-GCM encryption at rest, server-managed key (not password-derived), transient decryption for processing (Dwelly, Prayer, Journal synthesis), metadata-only constraint on notification copy

**Model note:** Supersedes the earlier client-side E2E / zero-knowledge design. The product's core features (Dwelly conversation, Prayer generation, Journal synthesis) require sending moment content to a cloud LLM (Groq/GPT-4o mini) as plaintext, which is incompatible with a "no one but the user can ever decrypt" guarantee. The promise is now "your moments are secure with us" (protected at rest, in transit, and from unauthorized access) rather than "we can never see your moments." See `docs/PILLAR_2_SECURITY_STRATEGY.md` for full rationale.

**Open Questions:**
- Where does the server-managed encryption key live (Supabase Vault vs. dedicated KMS)?
- Multi-device support (architecturally simpler now, still needs a design pass)?
- Should decrypt operations be logged for an internal audit trail?
- LLM provider data-retention confirmation (Groq/OpenAI request-log windows)?

**Exclusions:** Zero-knowledge / pure client-side E2E (superseded — see model note above)

**Risks:** Key management implementation details; testing encrypted data flows; being clear and honest with users about what "secure" means now vs. the old "we never see it" framing

#### Implementation Tickets
- T-062: Implement Server-Side Encryption for Moments (16-24 hours, BLOCKING)
  - AES-256-GCM encryption implementation, server-managed key
  - Encrypted storage and sync
  - Transient decryption on read/processing (never persisted as plaintext, never logged)
- T-067: Password Recovery Mechanism (now a normal recoverable flow — password reset no longer affects data access)
- *(Dependencies: Pillar 1 (Capture) must be complete; blocking for Pillar 3)*

---

### Pillar 3: Prayer (Responding to Captures)

**Status:** ⭕ Deferred to Post-MVP (August 3, 2026)  
**Locked:** 2-option skeleton (Prayer + Prompts), Rich Context powered, invitational framing ("Want to?"), Gallery + Soak Mode + Reflection Prompts + Notifications architecture

**Post-MVP deferral (August 3, 2026):** Kell scoped MVP down to three things — Capture, Process (the Dwelly conversation), and Journal — judging that even those three are already a lot to ship well. Prayer is a nice-to-have layered on top of an already-complete loop (you can capture and journal without ever praying over a moment), not essential to prove the core hypothesis, so it moves to Post-MVP. The onboarding "demo loop" screens (Pillar 0 / 07x sequence) were corrected to reflect this: capture → Dwelly processes → journal entry, with no prayer step shown. Design work above remains valid for whenever Prayer is picked back up; only the MVP sequencing changed.

**Design Skeleton:** See [`docs/PILLAR_3_PRAYER_STRATEGY.md`](PILLAR_3_PRAYER_STRATEGY.md) for full design specification, competitor research (Prayer Lock, Untold, Calm, Medito, Dwell, Day One, Stoic), skeletal system architecture, and success metrics (WAR 40-50% by week 8).

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
- T-XXX: Rich Context integration for Prayer (design + engineering) — Reference user's story, themes, patterns
- T-XXX: Response persistence (engineering) — Store responses, track completion status
- *(Dependencies: Pillar 1 (Capture), Pillar 2 (Encryption T-062) must be complete)*

---

### Pillar 4: Journal Creation (Synthesis + Dwelling Place)

**Status:** ✅ Design Complete (P4_SUMMARY.html), Implementation Ready  
**Locked:** LLM-powered synthesis (title + body), Rich Context powered, Dwelling Place tab as home, photo management v1, mood/tag selection, editability (detail view only), soft delete capability

**Design Skeleton:** See [`docs/P4_SUMMARY.html`](P4_SUMMARY.html) for complete design specification including 6-step happy path (capture → synthesis → journal editing), journal artifact structure, LLM output format, 10 locked decisions, and integration points with Pillar 3 (Prayer).

**Core Intent:** Transform captured voice conversation into a synthesized journal entry using Rich Context (conversation history + themes) to generate personalized title and body. Enable users to dwell on their moments through a beautifully composed narrative, then attach guided prayer for reflection.

**Journal Artifact Structure:**
```swift
struct JournalEntry: Codable {
    let id: String                              // UUID
    let momentId: String                        // Reference to original Pillar 1 capture
    let dateCreated: Date                       // ISO timestamp
    let title: String                           // Auto-generated (4-6 words) or "Your Reflection" (fallback)
    let body: String                            // LLM synthesis (2-3 paragraphs) OR originalTranscript (fallback)
    let moods: [String]                         // 2-3 tags from predefined palette (Reflective, Conflicted, Exhausted, Hopeful, Loved, Prayerful, etc.)
    let photos: [PhotoReference]                // User can add/remove (post-synthesis)
    let prayerReference: String?                // Link to Prayer artifact from Pillar 3
    let originalTranscript: String              // Dwelly's P1 capture conversation (read-only in Entry tab); also used as fallback journal body if synthesis fails
    let edited: Bool                            // Tracks if journal text was edited post-synthesis
    let deleted: Bool                           // Soft delete flag
    let deletedAt: Date?                        // Timestamp of soft delete
    let encryptedContent: Data                  // AES-256-GCM encrypted (same as Pillar 2)
}
```

**Happy Path (6 Steps + Fallback):**
1. **Capture Complete** → User returns to Moments list after saving moment
2. **Confirmation Screen (Option A)** → "Captured your moment! We briefly talked about [theme1, theme2, theme3]. Want to pray over these things?"
3. **Guided Prayer (v1)** → User optionally prays (prayer artifact created/linked)
4. **Journal Synthesis (Background)** → LLM generates title + body using Rich Context + conversation themes
5. **Dwelling Place Tab** → User sees synthesized journal entry with title, body, suggested moods, original transcript (Entry tab)
6. **Editing & Customization** → User can edit title/body (detail view only), select/adjust moods, add/remove photos, delete entry

**Fallback Path (If Synthesis Fails) — Locked July 9, 2026:**
- **Step 4b (Synthesis Failure):** If LLM synthesis fails after retry logic exhausted, journal body automatically populates with the original transcript — Dwelly's P1 capture conversation, already stored as `originalTranscript` (no new field needed). Title defaults to "Your Reflection." User sees journal with note: "We couldn't synthesize your journal, but here's what you reflected on." User can: (1) retry synthesis, (2) manually edit transcript, or (3) accept and move forward. No data loss — reflection is preserved.

**LLM Synthesis Output Format:**
- **Title:** 4-6 words, thematic, capturing essence of moment (e.g., "When Doubt Became Permission to Ask")
- **Body:** 2-3 paragraphs of prose narrative (not bullet points, not analysis), using Rich Context to reference user's story/themes
- **Moods:** System-suggested 2-3 moods from predefined palette (user can override)

**Success Metrics:**
- LLM synthesis latency: <2 sec for average moment
- User sentiment on journal quality: >4.0/5.0 on post-capture survey
- Dwelling engagement: >60% of users open Dwelling Place within 24h of synthesis
- Edit rate: <20% of users edit synthesized text (indicates strong synthesis quality)

**Open Questions (Deferred):**
- Synthesis latency UX — show "generating journal..." or silently in background?
- Prayer artifact storage — how is prayer object persisted (designer decision)
- Empty/very short captures — how to handle synthesis on <5 second recordings?
- Offline synthesis capability — should synthesis be available offline or cloud-only?
- Final LLM provider selection — Gemini 2.0 Flash vs Mistral 7B (cost + latency tradeoff)

**Exclusions:** AI-generated moment imagery (post-MVP), analysis format (Rosebud-style), insight/affirmation format, structured form-based synthesis, collaborative journaling

**Encryption:** AES-256-GCM, server-managed key (Pillar 2), encrypted at rest and in transit

#### Implementation Tickets
*(To be created after all pillar happy paths locked)*
- T-XXX: LLM synthesis engine integration (Gemini/Mistral selection + implementation)
- T-XXX: Journal entry UI and Dwelling Place tab (design + engineering)
- T-XXX: Photo management v1 (camera + upload, add/remove from journal)
- T-XXX: Mood/tag selection UI (predefined palette)
- T-XXX: Journal entry editing (title + body, detail view only)
- T-XXX: Soft delete capability (archive vs permanent delete flow)
- T-XXX: Rich Context integration for synthesis (conversation history + themes)
- T-XXX: Encryption for journal entries (AES-256-GCM)
- *(Dependencies: Pillar 1 (Capture), Pillar 2 (Encryption T-062), Pillar 3 (Prayer) must be complete)*

---

### Pillar 5: Editing (Moment + Journal Refinement)

**Status:** 🔄 Phase 2 Beta (Design In Progress)  
**Locked:** Edit scope, journal editability (detail view only), soft delete strategy, soft delete recovery window (30 days)

**Design Skeleton:** See [`docs/P5_EDITING_STRATEGY.md`](P5_EDITING_STRATEGY.md) for complete specification including 5 happy paths (edit transcript pre/post synthesis, delete with recovery), 8 locked decisions, and soft delete recovery flow.

**Core Concept:**  
Users can edit captured moment transcript (before/after synthesis), edit synthesized journal title and body (detail view only), and soft-delete moments or journal entries with recovery window. Encourages re-capture rather than endless editing.

**Open Questions:**
- Should users be able to edit transcripts before saving?
- Can they edit after saving?
- Should edit history be visible?
- Should we alert users if they edit significantly after the fact?
- Recovery flow for soft-deleted entries?

**Exclusions:** Collaborative editing, version control, edit history timeline

#### Implementation Tickets
*(To be created after design skeleton is locked)*
- T-XXX: Edit moment transcript (pre/post capture)
- T-XXX: Edit journal entry title and body (detail view only)
- T-XXX: Delete moment with confirmation (design + engineering)
- T-XXX: Delete journal entry with soft delete (design + engineering)
- T-XXX: Recovery/restore for soft-deleted entries (optional)
- *(Dependencies: Pillar 1 (Capture), Pillar 4 (Journal Creation) must be complete)*

---

### Pillar 6: Search & Discovery

**Status:** 🔄 Phase 2 Beta (Design In Progress)  
**Locked:** Full-text search (moments + journals), encryption-aware search index, real-time results, filter combination (AND logic), exclude soft-deleted items

**Design Skeleton:** See [`docs/P6_SEARCH_STRATEGY.md`](P6_SEARCH_STRATEGY.md) for complete specification including 6 happy paths (full-text, date filter, mood filter, chronological browse, pinned moments, sense of Lord search), 8 locked decisions, and encrypted search index architecture.

**Core Concept:**  
Enable users to find and revisit moments and journals across their entire history. Support full-text search across transcripts and journal bodies, multi-filter views (by date, mood, theme, sense of Lord), and contextual browsing. Make re-engagement effortless through discovery.

**Phase 2 Scope:**  
- Full-text search across moment transcripts and journal bodies
- Filter by date range, moods, tags, sense of Lord
- Search results surface context (snippet + metadata)
- Encryption-aware indexing (searching without decrypting entire library)

**Post-Launch Scope:**  
- Semantic search (AI-powered meaning-based search, not just keywords)
- AI-powered recommendations (based on themes and patterns)
- Saved searches / custom filters

**Open Questions:**
- Full-text search, semantic search, or both for MVP?
- Filter by date, mood, theme, sense of Lord reference?
- Should search index be encrypted or indexed in plaintext?
- How should search results surface context (full moment or snippet)?

**Exclusions:** Tag-based organization (handled by Pillar 4/5), AI recommendations (post-launch), social/collaborative search

#### Implementation Tickets
*(To be created after design skeleton is locked)*
- T-XXX: Full-text search implementation (design + engineering)
- T-XXX: Encrypted search index (engineering)
- T-XXX: Filter/refine search results (design + engineering)
- T-XXX: Search UI and results display (design + engineering)
- *(Dependencies: Pillar 1 (Capture), Pillar 4 (Journal Creation), Pillar 2 (Encryption)*

---

### Pillar 7: Formation Intelligence (Patterns & Themes)

**Status:** 🔄 Phase 2 Beta (Design In Progress)  
**Locked:** Theme detection at 3+ occurrences, Rich Context powered, invitational framing (never prescriptive), no interpretation, user's own language for theme names, theme linking (moments ↔ journals), timeline view

**Design Skeleton:** See [`docs/P7_FORMATION_INTELLIGENCE_STRATEGY.md`](P7_FORMATION_INTELLIGENCE_STRATEGY.md) for complete specification including 5 happy paths (discover theme, explore in reflection, weekly summary, filter by theme, monthly review), 8 locked decisions, and LLM-powered theme detection architecture.

**Core Concept:**  
Detect recurring themes across moments (anxiety, joy, relational moments, breakthroughs, God sightings) and surface them as invitations for reflection — never as interpretation. Use Rich Context to understand user's actual story and spiritual journey. Surface themes that emerge naturally from captured moments over time, helping users *notice* their own patterns.

**Phase 2 Scope:**  
- Theme detection (Socratic, not prescriptive) — detect patterns in user's own language
- Text-based pattern surfacing (e.g., "You've reflected on doubt 8 times in the past month. What patterns do you notice?")
- Integration with Prayer flows (reference themes in prayer/prompts, enabling contextual reflection)
- Theme dashboard or insights view (optional pull-based surfacing)

**Post-Launch Scope:**  
- Visual gallery/imagery by theme
- AI-generated moment illustrations
- Advanced semantic analysis
- Predictive pattern recognition (what might emerge next based on history)

**Open Questions:**
- How to detect themes without prescriptive categorization (user-detected vs AI-detected)?
- Should themes be user-tagged or AI-detected or both?
- How often should pattern reports surface (weekly? monthly)?
- Should theme insights be pushed to users (notifications) or pull-based (dashboard)?
- How do we avoid over-interpreting or spiritually directing users?

**Exclusions:** Spiritual interpretation, prescriptive insights ("You should..."), devotional content, predictive modeling (Phase 2), visual galleries (Phase 2)

#### Implementation Tickets
*(To be created after design skeleton is locked)*
- T-XXX: Theme detection algorithm (design + engineering)
- T-XXX: Rich Context integration for theme surfacing (engineering)
- T-XXX: Surface themes in Prayer prompts (integration)
- T-XXX: Theme dashboard/insights UI (design + engineering)
- T-XXX: Theme-based filters in Search (integration with Pillar 6)
- *(Dependencies: Pillar 3 (Prayer), Pillar 4 (Journal Creation), Rich Context architecture)*

---

### Pillar 8: Beta & Marketing

**Status:** 🔄 Phase 2 Beta (Design In Progress)  
**Locked:** Closed beta (invite-only), cohort structure (consistent vs selective reflectors), feedback collection (analytics + surveys + interviews), community platform (Discord), email cadence (weekly digest + bi-weekly feature highlights + periodic interviews), success metric (WAR 40-50% by week 8)

**Design Skeleton:** See [`docs/P8_BETA_MARKETING_STRATEGY.md`](P8_BETA_MARKETING_STRATEGY.md) for complete specification including 7 happy paths (self-signup, cohort enrollment, in-app feedback, interviews, Discord community, email engagement, metrics dashboard), 8 locked decisions, and cohort-based rollout strategy.

**Core Concept:**  
Expand from Phase 1 personal dogfooding to Phase 2 closed beta with targeted user cohorts (consistent reflectors vs selective reflectors). Validate dwelling behavior at scale through analytics, surveys, and 1:1 interviews. Build community and gather qualitative insights to inform Phase 2+ iteration. Establish foundation for public launch strategy.

**Phase 2 Scope:**
- Self-signup flow for beta users
- Beta cohort management (closed beta, limited seats)
- Feedback collection (surveys, interviews, usage analytics)
- Community engagement (Discord, email list, early adopter program)
- Cohort-based iteration and feedback loops

**Post-Launch Scope:**
- App Store submission and marketing
- Public launch campaign
- Paid ads, content strategy, partnerships

**Open Questions:**
- How many users for Phase 2 Beta (50? 100? 500?)?
- Should we use waitlist/invites or open signup?
- What feedback mechanisms during beta (surveys? interviews? in-app feedback)?
- How do we measure "dwelling" behavior qualitatively?
- What cohort segments should we prioritize for Phase 2 (consistent reflectors first)?

**Exclusions:** Paid advertising, content marketing, App Store launch, broad marketing campaigns (Phase 2), growth hacking

#### Implementation Tickets
*(To be created after design skeleton is locked)*
- T-XXX: Self-signup flow (design + engineering)
- T-XXX: Beta user management dashboard (design + engineering)
- T-XXX: Feedback collection system (surveys, analytics)
- T-XXX: Beta onboarding and cohort tracking (design + engineering)
- *(Dependencies: All Pillars 1-7 implementation must be functional for beta)*

---

### Pillar 9: Notifications & Nudges (Deferred)

**Status:** ⭕ Design Deferred (Post-Beta)  
**Locked:** Concept locked; design deferred to after Phase 2 other pillars validated

**Core Concept:**  
Pattern detection + contextual nudges. When user reflects on a theme 3+ times without prayer, send gentle notification: *"You reflected on anxiety, but haven't prayed. Want to now?"* Invitational, not prescriptive. Use Rich Context to make nudges deeply personal.

**Why Deferred:**  
We need to confirm what experiences we are creating (Pillars 1-8) and validate user behavior in Phase 2 before knowing what we are notifying dwellers of. Notifications requires all other pillars (Capture, Prayer, Search, Formation Intelligence) to exist and be validated in production first.

**Open Questions (Design Phase):**
- When should nudges arrive (day after? after 3rd moment? week later)?
- How to identify themes without prescriptive interpretation?
- Can users opt-out or customize frequency?
- What counts as a "theme" worth notifying on?
- Should we use push notifications, in-app, or both?
- How do we avoid notification fatigue?

**Exclusions:** Push notifications for generic content, devotional reminders, urgency framing, prescriptive interpretation

**Design Deferred to Phase 2+ (Post-Beta):** Competitive research, theme detection strategy, notification frequency caps, user control mechanisms, Rich Context integration for personalization, implementation design

#### Implementation Tickets
*(To be created after Pillars 1-8 ship and Phase 2 Beta validates dwelling behavior)*
- T-XXX: Pattern detection + theme identification (engineering)
- T-XXX: Notification scheduling + delivery (engineering)
- T-XXX: User notification preferences UI (design + engineering)
- *(Dependencies: Pillars 3 (Prayer), 7 (Formation Intelligence) must be complete and validated)*

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
- Server-Side Encryption (T-062) — encrypted at rest, transient decrypt for processing

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

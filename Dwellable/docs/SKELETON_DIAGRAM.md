# Dwellable Phase 2 — Skeleton Diagram

**Status:** 🎯 Session Start (May 7, 2026)  
**Purpose:** Visual + detailed architecture showing all 7 Pillars, data flows, tool/LLM requirements  
**Audience:** Engineering team, product stakeholders, session planning

---

## PART 1: PILLAR JOURNEY — User Flow (Temporal)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        DWELLABLE PILLAR JOURNEY                             │
│                    (Temporal: What Users Experience)                        │
└─────────────────────────────────────────────────────────────────────────────┘

     ONBOARDING                                                 ONGOING REFLECTION
         ▼                                                             ▲
    ┌─────────┐          ┌──────────┐       ┌──────────┐    ┌──────────────────┐
    │ PILLAR  │          │ PILLAR   │       │ PILLAR   │    │    PILLAR 6      │
    │    0    │─────────▶│    1     │──────▶│    3     │◀───│  MENU BAR        │
    │         │          │          │       │          │    │  (Navigation)    │
    │Onboarding          │ Capture  │       │ Soaking  │    │                  │
    │(7 screens)         │ (Voice   │       │ (Prayer  │    │ Today│Entries    │
    │               │ + Text)  │       │ +Prompts)   │    │ Create│Insights   │
    │ Intent,            │          │       │          │    │                  │
    │ Privacy,           │ Stores:  │       │ Rich     │    │ Enables all      │
    │ First Capture      │ Moment   │       │ Context  │    │ navigation       │
    │                    │ UUID     │       │ powered  │    │                  │
    └─────────┬──────────┴──────────┘       └──────────┘    └──────────────────┘
              │                                   ▲                    ▲
              │                                   │                    │
              │                                   └────────────────────┘
              │                                                       
              │                             ┌──────────────┐    ┌──────────┐
              │                             │   PILLAR 4   │    │ PILLAR 5 │
              │                             │   Editing    │    │  Search  │
              │                             │              │    │          │
              │                             │ Headlines    │    │ Calendar │
              │                             │ Tags         │    │ Full-text│
              │                             │ Moods        │    │ Filters  │
              └─────────────────────────────▶└──────────────┘    └──────────┘
                                                                       ▲
                                                                       │
                                                        (Users find moments)
```

**Flow Logic:**
1. **P0 (Onboarding):** First-run only. Establishes intent, privacy trust, account.
2. **P1 (Capture):** Ongoing. Voice or text, with transcription & local save.
3. **P3 (Soaking):** Return mechanism. Gallery view + Prayer/Prompts for reflection.
4. **P4 (Editing):** Enhance captured moments with metadata (headlines, tags, moods).
5. **P5 (Search):** Discover past moments via calendar, filters, full-text search.
6. **P6 (Menu Bar):** Navigation spine. Organizes all flows (Today/Entries/Create/Insights).
7. **P7 (Notifications):** Async engagement. Sparse nudges to return to app.

---

## PART 2: DATA ARCHITECTURE — How Moments Flow

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                      DATA FLOW ARCHITECTURE                                  │
│              (What Happens to a Moment from Capture to Pattern)              │
└──────────────────────────────────────────────────────────────────────────────┘

DEVICE (SwiftUI App)                    CLOUD (Supabase + Server)
═══════════════════════════════════════════════════════════════════════════════

    ┌─────────────────────────┐
    │  USER CAPTURES MOMENT   │ ◀─ P1: Voice/Text input
    │  (CaptureView)          │
    └────────────┬────────────┘
                 │
                 ▼
    ┌─────────────────────────┐
    │  MOMENT CREATED         │
    │  {                      │  ◀─ Generated: UUID, timestamp
    │    id: UUID,            │    User provides: body, senseOfLord
    │    body: string,        │    (Optional fields for P4: headline, tags, mood)
    │    senseOfLord: string? │
    │  }                      │
    └────────────┬────────────┘
                 │
                 ▼ (P2: Encryption ─ Pillar 2)
    ┌─────────────────────────────────────────┐
    │  ENCRYPT MOMENT (Client-Side)           │
    │  ┌─────────────────────────────────────┐│
    │  │ INPUT: Raw moment {id, body, ...}  ││
    │  │         Password                    ││
    │  │                                     ││
    │  │ PROCESS: AES-256-GCM                ││
    │  │ - Argon2id key derivation           ││
    │  │ - Generate IV                       ││
    │  │ - Encrypt body                      ││
    │  │ - Generate auth tag                 ││
    │  │                                     ││
    │  │ OUTPUT: {                           ││
    │  │   id: UUID,            ◀─ UNENCRYPTED
    │  │   encrypted_content: ciphertext,    ││
    │  │   iv: bytes,                        ││
    │  │   auth_tag: bytes,                  ││
    │  │   timestamp: ISO8601   ◀─ UNENCRYPTED
    │  │ }                                   ││
    │  └─────────────────────────────────────┘│
    └────────────┬──────────────────────────────┘
                 │
                 ▼
    ┌──────────────────────────┐
    │  SAVE LOCALLY            │
    │  (Keychain + UserDefaults)
    │  ├─ Keychain: encrypted  │   ◀─ For offline-first support
    │  │  moment (secure)      │
    │  └─ UserDefaults: queue  │
    │     pending sync         │
    └────────────┬─────────────┘
                 │
                 │  (When network available)
                 ▼
    ┌──────────────────────────┐         ┌─────────────────────────┐
    │  SYNC TO CLOUD           │────────▶│  Supabase moments table │
    │  (POST encrypted moment) │         │ ┌──────────────────────┐│
    │  ├─ SyncManager monitors │         │ │ id, user_id,         ││
    │  │  network              │         │ │ encrypted_content,   ││
    │  │                       │         │ │ iv, auth_tag,        ││
    │  │ ├─ Batches moments    │         │ │ created_at (unenc)   ││
    │  │ ├─ Uses on_conflict=id│         │ │ RLS: auth.uid        ││
    │  │ │  for upsert         │         │ │ = moments.user_id    ││
    │  │ └─ Retry on failure   │         │ └──────────────────────┘│
    │  └───────────────────────┘         └─────────────────────────┘
    │
    └─ ANALYTICS SYNC
        ├─ UsageEvent {event_type, timestamp}
        └─ Supabase usage_events table
```

**Key Properties:**
- **Moments:** Encrypted end-to-end. Server never sees raw content.
- **Encryption Keys:** Derived from user password. Not stored in cloud.
- **Metadata:** Timestamps stored unencrypted (needed for sorting/filtering).
- **Sync:** Offline-first. Pending moments queue survives app restart.
- **Upsert:** On conflict (duplicate UUID), silently merge (no data loss).

---

## PART 3: PILLAR DETAILS & TOOL/LLM INTEGRATION

```
┌──────────────────────────────────────────────────────────────────────────────┐
│           PILLAR REQUIREMENTS: INFRASTRUCTURE, TOOLS, LLM                    │
└──────────────────────────────────────────────────────────────────────────────┘

PILLAR 0: ONBOARDING
────────────────────
├─ Job: Establish intent, privacy trust, create account
├─ Input: User selections (intent, rhythm, email, password)
├─ Process: 7 sequential screens → Supabase auth setup
├─ Output: User account + profile (intent, rhythm data)
├─ Tools: Supabase Auth (JWT), Keychain (password storage)
├─ LLM Required: ❌ NO
├─ Effort: 7 implementation tickets (T-093–T-099 projected)
└─ Success Metric: >90% completion, >80% first capture within 5 min


PILLAR 1: CAPTURE
─────────────────
├─ Job: Low-friction moment recording (voice-first, text fallback)
├─ Input: User audio (voice) OR text
├─ Process:
│  ├─ Voice: AVFoundation → Speech Framework transcription
│  └─ Text: Direct input
│  ├─ Validate: non-empty body
│  └─ Save: Keychain (local) + queue for sync
├─ Output: Moment {id, body, senseOfLord?, timestamp}
├─ Tools:
│  ├─ AVFoundation (native iOS recording)
│  ├─ Speech Framework (on-device transcription)
│  └─ Keychain + UserDefaults (local storage)
├─ LLM Required: ❌ NO (Phase 1 validation complete)
├─ Effort: ✅ COMPLETE (Build 107)
└─ Success Metric: 100% adoption (Phase 1 proven), >95% transcription accuracy


PILLAR 2: SECURITY & PRIVACY
────────────────────────────
├─ Job: Encrypt moments so only user can read
├─ Input: Raw moment {body, ...}, user password
├─ Process:
│  ├─ Derive key: Argon2id(password, salt)
│  ├─ Encrypt: AES-256-GCM(key, body)
│  └─ Store: encrypted_content + metadata (unencrypted)
├─ Output: Encrypted moment ready for sync
├─ Tools:
│  ├─ CryptoKit (native Swift crypto)
│  ├─ Keychain (session tokens + derived keys)
│  └─ iOS Keychain (secure storage)
├─ LLM Required: ❌ NO
├─ Effort: T-062 (16–24 hours, Phase 2 BLOCKING)
├─ Notes: Password recovery (T-067) affects UX
└─ Success Metric: All moments encrypted, 0 unencrypted moments in cloud


PILLAR 3: SOAKING & RESPONDING
──────────────────────────────
├─ Job: Enable reflection via Gallery + Prayer/Prompts
├─ Input: Captured moments + user interactions
├─ Process:
│  ├─ Gallery View: Display all moments (tiles, chronological)
│  ├─ Soak Mode: Ambient soundscape + contemplation timer (5/10/15 min)
│  ├─ Prayer Flow: Guided prayer prompt → user response saved
│  └─ Prompts Flow: Socratic questions (Tier 1/2/3) → user response
├─ Output: Moment + reflections (prayer/prompt responses)
├─ Tools:
│  ├─ SwiftUI (Gallery UI)
│  ├─ AVAudioPlayer (ambient soundscape)
│  └─ Rich Context synthesis (see below)
├─ LLM REQUIRED: ✅ YES
│  ├─ Job: Generate contextual Prayer/Prompts based on user's story
│  ├─ Input: User moment + past moments + themes (Rich Context)
│  ├─ Process:
│  │  ├─ Synthesize user's accumulated moments → identify themes
│  │  ├─ Generate 1-3 Socratic prompts OR guided prayer
│  │  ├─ Ensure personalized (references user's actual story)
│  │  └─ Never prescriptive (user discovers their own insights)
│  ├─ LLM Preference: Gemini 2.0 Flash (low latency, free tier)
│  ├─ Fallback: Pre-written generic prompts (if API fails)
│  └─ Cost: ~$2–5K/yr for 10K users (Gemini free tier covers MVP)
├─ Effort: T-063, T-064, T-065, T-066 (estimated 60–80 hours total)
└─ Success Metric: WAR 40–50% by week 8 (Weekly Active Reflections)


PILLAR 4: EDITING
─────────────────
├─ Job: Enhance moments with metadata (headlines, tags, moods)
├─ Input: Captured moment
├─ Process:
│  ├─ Auto-generate headline: LLM summarizes first 50 words
│  ├─ Suggest tags: LLM infers from content (Presence, Peace, Clarity, etc.)
│  ├─ User selects/customizes: Can override headline + accept/reject tags
│  └─ Optional mood selection: Preset list (grateful, peaceful, uncertain, etc.)
├─ Output: Moment + metadata {headline, tags, mood}
├─ Tools:
│  ├─ SwiftUI (editing UI)
│  └─ Database (store metadata)
├─ LLM REQUIRED: ✅ YES (Headline + tag inference)
│  ├─ Job: Auto-generate headlines + suggest tags
│  ├─ Input: Raw moment body
│  ├─ Process: Summarize (1-8 words) + categorize (max 5 tags)
│  ├─ Output: Headline string + tag array
│  ├─ LLM Preference: Same as P3 (Gemini 2.0 Flash)
│  └─ Cost: Minimal (<$1K/yr for 10K users)
├─ Effort: T-??? (estimated 40–50 hours, depends on design complexity)
└─ Success Metric: >80% moments have headlines, >60% user-accepted tags


PILLAR 5: SEARCH & DISCOVERY
────────────────────────────
├─ Job: Help users find and re-discover moments
├─ Input: Calendar view + filters + search query
├─ Process:
│  ├─ Calendar: Show which days have moments (visual density)
│  ├─ Filters: Date range, tagged, prayer-engaged, soaking-depth
│  ├─ Full-text search: Decrypt locally + grep moment content
│  └─ Result: Show matching moments in list
├─ Output: Filtered/searched moment list
├─ Tools:
│  ├─ SwiftUI (Calendar + filter UI)
│  ├─ Full-text search (local decryption + NSRegularExpression)
│  └─ Supabase full-text search (optional, future enhancement)
├─ LLM REQUIRED: ❌ NO (Phase 2)
│  └─ Optional (Phase 3+): Semantic search via embedding similarity
├─ Effort: T-??? (estimated 50–60 hours)
└─ Success Metric: >70% queries return relevant results, <2 sec search time


PILLAR 6: MENU BAR / NAVIGATION
───────────────────────────────
├─ Job: Navigation spine organizing all flows
├─ Input: User taps tabs
├─ Process:
│  ├─ Today tab: Show moments from last 7 days
│  ├─ Entries tab: All moments + full archive
│  ├─ Create tab: Navigate to CaptureView
│  └─ Insights tab: Formation metrics dashboard
├─ Output: Seamless navigation between all pillars
├─ Tools:
│  ├─ SwiftUI NavigationStack
│  └─ Tab state management
├─ LLM Required: ❌ NO
├─ Effort: T-076–T-082 (7 tickets, 85–100 hours total)
└─ Success Metric: >90% sessions include tab switches, <5% nav confusion


PILLAR 7: NOTIFICATIONS
───────────────────────
├─ Job: Sparse nudges to return & reflect
├─ Input: User engagement metrics + themes detected
├─ Process:
│  ├─ Segment users: New / Non-soaker / Occasional / Active dweller
│  ├─ Frequency cap: 1–2 notifications per month (sparse philosophy)
│  ├─ Schedule: Send at user's typical app-open time
│  └─ Content: Personalized copy based on user's themes
├─ Output: Push notification + in-app tracking
├─ Tools:
│  ├─ Firebase Cloud Messaging (FCM) for delivery
│  ├─ Supabase (store segments + notification log)
│  └─ Analytics (track CTR, opt-outs)
├─ LLM REQUIRED: ✅ YES (Notification copy generation)
│  ├─ Job: Generate personalized notification text
│  ├─ Input: User segment + detected themes
│  ├─ Process: Template + personalization (never prescriptive)
│  ├─ Example: "You've been reflecting on faith and work. Ready to capture another moment?"
│  ├─ LLM Preference: Same as P3 (Gemini 2.0 Flash)
│  └─ Cost: Minimal (<$500/yr, few API calls)
├─ Effort: T-083–T-091 (9 tickets, 100–120 hours total)
└─ Success Metric: >35% D7 retention, >40% CTR, <10% opt-out rate


─────────────────────────────────────────────────────────────────────────────
POST-PHASE 2: FORMATION INTELLIGENCE (Deferred)
─────────────────────────────────────────────────
├─ Job: Detect patterns across moments
├─ Input: All moments + reflections + themes
├─ Process:
│  ├─ Theme detection: Identify recurring topics (anxiety, joy, relational)
│  ├─ Pattern insights: "60% of your reflections mention faith-work integration"
│  └─ Visual gallery: Display moments by theme (grid, timeline, etc.)
├─ LLM REQUIRED: ✅ YES (Theme detection + insight generation)
└─ Notes: Deferred to Phase 3+ after Pillars 0-7 validated
```

---

## PART 4: INTEGRATION TOUCHPOINTS — How Pillars Connect

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                    PILLAR DEPENDENCIES & INTERACTIONS                        │
│                  (Which Pillars Require Which Other Pillars)                │
└──────────────────────────────────────────────────────────────────────────────┘

P0 (Onboarding) ──┐
                  ▼
            P1 (Capture) ──┐  ◀─ Phase 1 Complete (Build 107)
                           ▼
                      P2 (Security)  ──┐
                                       ▼
            ┌─────────────────── P3 (Soaking) ─────────────────┐
            │                                                   │
            │  (Rich Context: Reads all moments to generate    │
            │   personalized Prayer/Prompts)                    │
            │                                                   │
            ▼                                                   ▼
        P4 (Editing)                                        P6 (Menu Bar)
        ├─ Reads: Moments                                   ├─ Organizes: All tabs
        ├─ Writes: Headlines + tags                         ├─ Drives: Navigation
        └─ LLM: Auto-gen headlines                          └─ Entry point: Today/Entries
            │                                                   │
            ▼                                                   ▼
        P5 (Search)                                         P7 (Notifications)
        ├─ Reads: Headlines + tags                          ├─ Reads: Engagement metrics
        ├─ Writes: Search results                           ├─ Reads: Themes (P3 output)
        └─ Optional LLM: Semantic search                    └─ LLM: Notification copy


KEY INTEGRATION POINTS:
───────────────────────

1. **P1 ←→ P2 (Capture ↔ Security)**
   - Before sync: P1 passes moment to P2 for encryption
   - Result: Encrypted moment stored locally + cloud

2. **P3 ← P1 (Soaking reads Capture data)**
   - Gallery view displays all captured moments
   - Prayer/Prompts generated from each moment's content

3. **P3 ←→ Rich Context (Soaking synthesizes history)**
   - LLM reads user's entire moment history
   - Identifies themes + personalizes prompts
   - Example: "You mentioned faith-work integration 7 times"

4. **P4 ← P1 (Editing reads Capture data)**
   - Moment body becomes input to auto-headline LLM
   - User can edit/accept headlines + tags

5. **P5 ← P1, P4 (Search reads Capture + Editing)**
   - Search indexes: moment body + headline + tags
   - Filters use: P4 metadata (tags, mood)

6. **P6 (Menu Bar) ← All Pillars**
   - P6 is the navigation spine; all flows accessible via tabs
   - Today tab: P1 data (recent moments)
   - Entries tab: P1 + P4 data (all moments + metadata)
   - Create tab: P1 (capture flow)
   - Insights tab: Analytics from P3 + P7

7. **P7 ← P3, Formation Intelligence (Notifications read Soaking)**
   - Pattern detection: Identifies when user hasn't soaked recently
   - Segmentation: Uses P3 engagement as classifier
   - Copy generation: LLM personalizes based on user's themes


BLOCKING RELATIONSHIPS:
───────────────────────
- P0 must complete before P1 (onboarding establishes intent)
- P1 must complete before P3 (need moments to dwell on)
- P2 must complete before P3 ships (encryption non-negotiable)
- P3, P4, P5 can run in parallel (independent features)
- P6 integrates all above (can't ship until all tabs populated)
- P7 can ship independently (notifications optional feature)
```

---

## PART 5: LLM USAGE SUMMARY

```
┌──────────────────────────────────────────────────────────────────────────────┐
│               LLM USAGE ACROSS PILLARS: WHEN & HOW                          │
└──────────────────────────────────────────────────────────────────────────────┘

PILLAR 3 (Soaking): Prayer/Prompts Generation
──────────────────────────────────────────────
├─ Trigger: User taps "Pray" or "Reflect" on a moment
├─ Context: Rich Context synthesis (user's moment + past 20 moments)
├─ Request: "Generate 2 Socratic prompts about this moment"
├─ Response: Tier 1 & 2 prompts, open-ended
├─ Latency requirement: <2 seconds (user-initiated, real-time)
├─ API calls/user/month: ~50–100 (2–3 per soaking session × 50 soaking sessions)
├─ Model: Gemini 2.0 Flash (free tier MVP)
├─ Cost: ~$2–5K/yr for 10K users (free tier covers MVP)
└─ Fallback: Pre-written generic prompts


PILLAR 4 (Editing): Headline + Tag Generation
──────────────────────────────────────────────
├─ Trigger: User saves moment (auto-run)
├─ Context: Moment body (first 500 chars)
├─ Request: "Generate 1-line headline (max 8 words) + 3-5 tags"
├─ Response: headline string + tag array
├─ Latency requirement: <5 seconds (background, acceptable delay)
├─ API calls/user/month: ~100–150 (1 per moment captured)
├─ Model: Gemini 2.0 Flash (free tier MVP)
├─ Cost: ~$3–7K/yr for 10K users (free tier covers MVP)
└─ Fallback: Empty headline, no tags


PILLAR 7 (Notifications): Notification Copy
────────────────────────────────────────────
├─ Trigger: Notification scheduled (1–2/month per user)
├─ Context: User segment + detected themes
├─ Request: "Generate personalized notification (60 chars max) for new user"
├─ Response: Notification text
├─ Latency requirement: No constraint (scheduled, batched)
├─ API calls/user/month: ~2 (1–2 notifications)
├─ Model: Gemini 2.0 Flash (free tier MVP)
├─ Cost: <$500/yr for 10K users (minimal API calls)
└─ Fallback: Generic template copy


TOTAL LLM COST ESTIMATE (10K USERS, YEAR 1)
───────────────────────────────────────────
├─ Soaking (Prayer/Prompts): ~$2–5K
├─ Editing (Headlines/Tags): ~$3–7K
├─ Notifications (Copy): <$500
├─ Formation Intelligence (future): ~$3–5K (Phase 3+)
├─ Total: ~$8–18K/yr (MVP: Gemini free tier)
└─ Scale option: Mistral 7B self-hosted ~$15–25K/yr for unlimited calls


RICH CONTEXT: Context Synthesis Strategy
──────────────────────────────────────────
├─ Job: Provide LLM with user's story, not generic categories
├─ Data Sources:
│  ├─ All user moments (encrypted locally, decrypted for synthesis)
│  ├─ Headlines + tags (P4 metadata)
│  ├─ Previous reflections (P3 responses)
│  └─ User's intent + rhythm (P0 onboarding)
├─ Process:
│  ├─ Decrypt user's last 20–50 moments (local, on-device)
│  ├─ Synthesize into 500-char summary (themes, patterns, tone)
│  ├─ Include current moment context
│  ├─ Pass summary + current moment to LLM
│  └─ LLM generates contextual prompt (not generic)
├─ Example Output:
│  ├─ Generic: "What stands out to you?"
│  └─ Rich Context: "You've been wrestling with work-faith balance for weeks. What's different about this moment?"
├─ Privacy: Synthesis happens client-side. LLM never sees raw moments.
└─ Cost: Synthesis is local compute, no additional API calls
```

---

## PART 6: ARCHITECTURE DECISIONS & RATIONALE

| Decision | Choice | Rationale | Tradeoff |
|----------|--------|-----------|----------|
| **Encryption** | Client-side E2E (AES-256-GCM) | User privacy, legal compliance, differentiation from competitors | Cannot do server-side analytics on moment content |
| **LLM for Soaking** | Gemini 2.0 Flash (MVP) | Free tier, low latency, good quality for prompts | Vendor lock-in; Mistral 7B alternative for scale |
| **LLM Context** | Rich Context synthesis (client-side) | Personalized without exposing moments to LLM | Requires decryption locally; adds compute complexity |
| **Navigation** | Tab bar (4 tabs) | Clear organization, no cognitive overload | Limits screen real estate; requires careful prioritization |
| **Notifications** | Sparse (1–2/month) | Respect user attention, high opt-in rate | Miss opportunity for engagement if too sparse |
| **Search** | Full-text (local decryption) | Privacy-first, no server index | Slower than server-side search; requires local compute |
| **Pillar Order** | P0→P1→P2→P3/P4/P5→P6→P7 | Dependencies; fast path to MVP | Parallel work may surface blockers |

---

## PART 7: TIMELINE & EFFORT ESTIMATES

```
Phase 2 Implementation Schedule (Estimated)

Week 1 (May 12–18):   P2 (Encryption) — T-062 blocking other features
Week 2 (May 19–25):   P3 (Soaking) begins — T-063, T-064, T-065
Week 3 (May 26–Jun 1): P3 completes + P4/P5 begin in parallel
Week 4 (Jun 2–8):     P4/P5 continue; P6 (Menu Bar) begins
Week 5 (Jun 9–15):    P6 completes; P7 (Notifications) begins
Week 6+ (Jun 16+):    P7 completes; Formation Intelligence deferred

Total Effort: ~400–500 developer hours (5–6 person-weeks)
Beta Release: ~June 15–20 to closed beta (50–100 users)
```

---

## NEXT STEPS

1. ✅ **Skeleton Diagram complete** — This document
2. 🔄 **LLM Tournament Bracket** — Finalize model selection (Gemini vs Mistral)
3. 🔄 **Complete Ticket List** — Map all 96 tickets with dependencies + estimates

---

**Document Status:** LOCKED — Ready for engineering implementation  
**Last Updated:** May 7, 2026  
**Owner:** Kell Golden

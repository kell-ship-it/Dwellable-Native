# Comprehensive Ticket Map — All 96 Tickets

**Status:** 📋 COMPLETE MAPPING (May 7, 2026)  
**Current Progress:** 64/96 complete (66.7%)  
**Scope:** All Phase 2 Pillars (0-7) + Formation Intelligence  
**Audience:** Engineering team, project planning, dependency resolution

---

## Overview

```
PILLAR BREAKDOWN:

Pillar 0 (Onboarding):     7 tickets [T-001–T-007]      ✅ COMPLETE (design locked)
Pillar 1 (Capture):        46 tickets [T-008–T-053]     ✅ COMPLETE (Build 107)
Pillar 2 (Security):        4 tickets [T-054–T-057]     🔲 NOT STARTED (BLOCKING)
Pillar 3 (Soaking):        12 tickets [T-058–T-069]     🔲 NOT STARTED (HIGH PRIORITY)
Pillar 4 (Editing):         8 tickets [T-070–T-077]     🔲 NOT STARTED (DESIGN LOCKED)
Pillar 5 (Search):          8 tickets [T-078–T-085]     🔲 NOT STARTED (DESIGN LOCKED)
Pillar 6 (Menu Bar):        7 tickets [T-086–T-092]     🔲 NOT STARTED (Foundation)
Pillar 7 (Notifications):   9 tickets [T-093–T-101]     🔲 NOT STARTED (Post-foundation)
Formation Intelligence:      6 tickets [T-102–T-107]     🔲 DEFERRED (Phase 3+)

═════════════════════════════════════════════════════════════════════════════════
Total: 96 tickets | Completed: 64 | In Progress: 0 | Not Started: 32
Effort: ~400-500 developer hours (5-6 person-weeks)
```

---

## PILLAR 0: ONBOARDING (7 Tickets)

**Purpose:** 7-screen signup flow establishing intent, rhythm, privacy, account  
**Status:** ✅ DESIGN COMPLETE (T-060); READY FOR IMPLEMENTATION  
**Design Doc:** `PILLAR_ONBOARDING_STRATEGY.md`

| Ticket | Task | Effort | Dependencies | Blocked By | Status |
|--------|------|--------|--------------|-----------|--------|
| **T-001** | Welcome screen (value prop + continue) | 2-3h | None | None | 🔲 NOT STARTED |
| **T-002** | Education screen (what is Dwellable?) | 2-3h | T-001 | None | 🔲 NOT STARTED |
| **T-003** | Intent screen (spiritual goals) | 3-4h | T-002 | None | 🔲 NOT STARTED |
| **T-004** | Rhythm screen (capture frequency) | 2-3h | T-003 | None | 🔲 NOT STARTED |
| **T-005** | Account screen (email + password) | 3-4h | T-004 | None | 🔲 NOT STARTED |
| **T-006** | Privacy screen (trust building + encryption explanation) | 3-4h | T-005 | None | 🔲 NOT STARTED |
| **T-007** | First capture prompt (launch into P1 capture) | 2-3h | T-006 | None | 🔲 NOT STARTED |

**Execution Order:** Sequential (T-001 → T-007)  
**Total Effort:** 18–27 hours  
**Acceptance Criteria:**
- [ ] All 7 screens render correctly on iPhone 13-16
- [ ] Validation: Email format, password minimum 8 chars
- [ ] Navigation smooth (no black screen flashes)
- [ ] >90% completion rate in testing
- [ ] Intent + rhythm data saved to profile

---

## PILLAR 1: CAPTURE (46 Tickets)

**Status:** ✅ COMPLETE — Build 107 live on TestFlight  
**Design Doc:** `PILLAR_1_CAPTURE_STRATEGY.md`

### Completed Tickets Summary
- UI screens: LoginView, MomentsListView, CaptureView, ReviewView, TypeFlowView, SettingsView, TranscribingView, MomentDetailView
- Voice recording: AVFoundation + Speech Framework integration
- Text input: TypeFlowView + ReviewView
- Data persistence: LocalStorageManager (Keychain + UserDefaults)
- API client: SupabaseAPIClient + mock client
- Backend: Supabase auth + moments table + RLS
- Analytics: UsageTracker + event sync
- Offline-first: SyncManager + retry logic
- Navigation: Fix post-save navigation (B-001)
- Testing: XCUI test suite (T-020)
- Build infrastructure: Icon + TestFlight deployment (T-031, T-032)

**Total Effort:** ~350 hours (completed)  
**Acceptance Criteria:** ✅ ALL MET
- 100% capture adoption (Phase 1 validated)
- >95% transcription accuracy
- Zero unencrypted moments in cloud
- Full offline-first support

---

## PILLAR 2: SECURITY & PRIVACY (4 Tickets)

**Purpose:** E2E encryption ensuring only user can read moments  
**Status:** 🔲 NOT STARTED — ⚠️ **CRITICAL BLOCKING**  
**Design Doc:** Architecture provided; needs strategy doc  
**Blocked By:** Nothing  
**Blocks:** Pillar 3 (cannot launch soaking without encryption)

### T-054: Encryption Architecture & Implementation (16-24 hours)

**Description:** Implement AES-256-GCM client-side encryption per ARCHITECTURE.md  

**Technical Requirements:**
- Argon2id key derivation from user password
- AES-256-GCM encryption in CryptoKit
- IV + auth tag generation
- Client-side encrypt before sync
- Client-side decrypt on read
- Unencrypted metadata (timestamps for sorting)

**Acceptance Criteria:**
- [ ] All moments encrypted with AES-256-GCM
- [ ] Encryption keys derived from password only
- [ ] Decryption works on device (no cloud keys)
- [ ] Zero unencrypted content in Supabase
- [ ] Unit tests for encryption/decryption
- [ ] Performance: Encryption <100ms per moment

**Dependencies:** None  
**Effort:** 16-24 hours  
**Sequence:** First ticket (no dependencies)

### T-055: Encryption Migration for Existing Moments (4-6 hours)

**Description:** Migrate unencrypted moments from Phase 1 to encrypted state  

**Technical Requirements:**
- Batch decrypt existing moments (stored plaintext in Phase 1)
- Re-encrypt with E2E encryption
- Update Supabase records
- Verify no data loss

**Acceptance Criteria:**
- [ ] All Phase 1 moments encrypted
- [ ] Checksums match pre/post migration
- [ ] No orphaned records

**Dependencies:** T-054  
**Effort:** 4-6 hours  
**Sequence:** After T-054 complete

### T-056: Local Key Storage in Keychain (4-6 hours)

**Description:** Store derived keys securely in iOS Keychain  

**Technical Requirements:**
- Keychain APIs for key storage
- Session token management
- Key rotation on password change
- Graceful handling of lost keys

**Acceptance Criteria:**
- [ ] Keys stored in Keychain (not UserDefaults)
- [ ] Keys survive app restart
- [ ] Keys cleared on logout
- [ ] Secure deletion (no residual data)

**Dependencies:** T-054  
**Effort:** 4-6 hours  
**Sequence:** Parallel with T-055

### T-057: Password Recovery Design + Implementation (8-12 hours)

**Description:** Decide & implement password recovery strategy  

**Options:**
1. No recovery (simplest): Document, accept lost access if forgotten
2. Recovery key backup: User exports recovery key at signup
3. Email recovery: Password reset via email, moments inaccessible if key gone

**Acceptance Criteria:**
- [ ] Decision documented (which option chosen)
- [ ] User-facing messaging clear
- [ ] Test forgotten password scenario
- [ ] Recovery workflow tested end-to-end (per chosen option)

**Dependencies:** T-054  
**Effort:** 8-12 hours  
**Sequence:** Parallel with T-055/T-056

**Pillar 2 Total Effort:** 32-48 hours | **Timeline:** Week 1 (1 sprint)

---

## PILLAR 3: SOAKING & RESPONDING (12 Tickets)

**Purpose:** Gallery + Prayer/Prompts + Soak Mode (Rich Context LLM-powered)  
**Status:** 🔲 NOT STARTED — HIGH PRIORITY (after P2)  
**Design Doc:** `PILLAR_3_SOAKING_STRATEGY.md`  
**Blocked By:** T-057 (encryption must ship first)  
**Blocks:** P6 (menu bar integrates soaking gallery)

### T-058: Gallery View UI (8-10 hours)

**Description:** Tile-based grid of all user's moments  

**Technical Requirements:**
- SwiftUI LazyVGrid layout (responsive grid)
- Each tile shows: moment preview (first 20 words), date, optional headline
- Tap to open detail view (modal)
- Pull-to-refresh from backend
- Loading + error states
- Empty state ("No moments yet")

**Acceptance Criteria:**
- [ ] 2-3 tiles per row (iPhone 13-16)
- [ ] Smooth scrolling (60fps)
- [ ] Tap tile → opens moment detail
- [ ] Pull-refresh works correctly

**Dependencies:** P1 (moments exist), T-057 (decryption ready)  
**Effort:** 8-10 hours  
**Sequence:** First P3 ticket (foundational for other P3 features)

### T-059: Soak Mode UI + Soundscape Selector (6-8 hours)

**Description:** Contemplative mode with ambient sounds + timer  

**Technical Requirements:**
- Full-screen moment text
- Soundscape selector (piano, rain, forest, silence)
- Audio playback with AVAudioPlayer
- Gentle timer (5/10/15 min options)
- Soft exit (pause/finish button)

**Acceptance Criteria:**
- [ ] Soundscapes play correctly
- [ ] Timer accurate (±1 second)
- [ ] Moment text visible + readable
- [ ] Battery-friendly (low CPU usage)

**Dependencies:** T-058 (requires moment detail view)  
**Effort:** 6-8 hours  
**Sequence:** After T-058

### T-060: Prayer Flow (Design + Engineering) (12-16 hours)

**Description:** Guided prayer response with optional reflection prompt  

**Technical Requirements:**
- User taps "Pray" on moment
- System presents guided prompt ("How can you pray about this?")
- Open text area for user prayer/reflection
- Save button → stores response attached to moment
- Display previous responses if exist

**LLM Integration (Gemini 2.0 Flash):**
- Input: Current moment + Rich Context (last 20 moments)
- Output: 1-2 sentence prayer prompt
- Fallback: Pre-written generic prompt (if API fails)

**Acceptance Criteria:**
- [ ] Prayer prompt displays correctly
- [ ] User can type free-form response
- [ ] Response saved to moment
- [ ] Previous responses displayed
- [ ] Latency <2 seconds

**Dependencies:** T-058 (moment detail view), LLM integration  
**Effort:** 12-16 hours  
**Sequence:** After T-058; parallel with T-061

### T-061: Prompts Flow (Socratic Dialogue) (12-16 hours)

**Description:** Sequential Socratic questions for reflection  

**Technical Requirements:**
- Tier 1 prompts: Gentle ("What stands out?", "How do you feel?")
- Tier 2 prompts: Deeper ("How did God meet you?", "What did you learn?")
- Tier 3 prompts: Pattern ("You've mentioned this 5 times—how's it evolving?")
- User responds to each tier
- Responses saved + displayed

**LLM Integration (Gemini 2.0 Flash):**
- Input: Moment + Rich Context
- Output: 2-3 Tier prompts (tailored to user's themes)
- Fallback: Pre-written generic prompts

**Acceptance Criteria:**
- [ ] Prompts display sequentially
- [ ] User can respond to each tier
- [ ] Responses saved correctly
- [ ] Tier 3 logic (5+ related moments) works

**Dependencies:** T-058, LLM integration  
**Effort:** 12-16 hours  
**Sequence:** Parallel with T-060

### T-062: Rich Context Synthesis (8-10 hours)

**Description:** Local synthesis of user's moment history for LLM context  

**Technical Requirements:**
- Decrypt last 20 moments (local, on-device)
- Extract themes + patterns (NLP or manual categorization)
- Synthesize into 500-char summary
- Include user's intent + rhythm data
- Pass summary + current moment to LLM

**Example Output:**
- Generic: "What stands out to you?"
- Rich Context: "You've been reflecting on faith-work integration for weeks. What's different about this moment?"

**Acceptance Criteria:**
- [ ] Decryption works without cloud keys
- [ ] Synthesis <500ms (local compute)
- [ ] LLM receives correct context
- [ ] Personalization evident in outputs

**Dependencies:** T-057 (decryption), T-058-061 (LLM features)  
**Effort:** 8-10 hours  
**Sequence:** After T-058; before T-060/061

### T-063: Response Persistence (4-6 hours)

**Description:** Save prayer/prompt responses attached to moment  

**Technical Requirements:**
- New table: `moment_responses` (moment_id, response_text, type, created_at)
- Save response after user completes prayer/prompts
- Fetch + display previous responses
- Sync to cloud (with encryption)

**Acceptance Criteria:**
- [ ] Responses stored locally + synced
- [ ] Multiple responses per moment supported
- [ ] Display sorted by date (newest first)

**Dependencies:** T-060/061 (response data exists)  
**Effort:** 4-6 hours  
**Sequence:** After T-060/061

### T-064: Headlines + User Tags (Optional Metadata) (4-6 hours)

**Description:** User-editable headlines + optional tags for moments  

**Technical Requirements:**
- Headline field (8-word summary, user-editable)
- Tag field (5 max, user-selectable or custom)
- Both optional (preserve user agency)
- Display in gallery view + detail view

**Acceptance Criteria:**
- [ ] Users can edit headlines
- [ ] Tag input works (autocomplete from past tags)
- [ ] Both saved to moment

**Dependencies:** T-058 (gallery display)  
**Effort:** 4-6 hours  
**Sequence:** Parallel with T-060/061

### T-065: Notification Integration (Track Soaking Engagement) (4-6 hours)

**Description:** Log soaking events for analytics (used by P7)  

**Technical Requirements:**
- Log when user: views moment, starts soak mode, prays, responds to prompts
- Events stored locally + synced to Supabase
- Feed Formation Intelligence (P8) for pattern detection

**Acceptance Criteria:**
- [ ] Events logged correctly
- [ ] Synced to backend
- [ ] Formation Intelligence can read soaking events

**Dependencies:** T-060/061, UsageTracker  
**Effort:** 4-6 hours  
**Sequence:** After T-060/061

### T-066: Quality Assurance & Testing (6-8 hours)

**Description:** End-to-end QA for P3 features  

**Technical Requirements:**
- Device testing (iPhone 13-16)
- Prayer/prompts quality validation (ChatGPT-like quality expected)
- Latency testing (<2s for real-time prompts)
- Error handling (API fails → fallback to generic prompts)
- Engagement metrics baseline (WAR, response rate)

**Acceptance Criteria:**
- [ ] All features work on real devices
- [ ] Zero crashes
- [ ] Prompts feel personalized + spiritual
- [ ] Latency <2s
- [ ] >40% of users respond to prompts (baseline metric)

**Dependencies:** T-060/061  
**Effort:** 6-8 hours  
**Sequence:** Final P3 ticket (after all features ready)

**Pillar 3 Total Effort:** 66-92 hours | **Timeline:** Week 2-3 (2 sprints)

---

## PILLAR 4: EDITING (8 Tickets)

**Purpose:** Auto-generate headlines, tags, moods for moment metadata  
**Status:** 🔲 NOT STARTED — DESIGN LOCKED  
**Design Doc:** `PILLAR_4_EDITING_STRATEGY.md`  
**Blocked By:** Nothing (can parallelize with P3)  
**Blocks:** P5 (search uses P4 metadata)

### T-067: Auto-Generated Headlines (6-8 hours)

**Description:** LLM-generated 1-line summary of moment  

**Technical Requirements:**
- Trigger: After user saves moment
- Input: Moment body (first 500 chars)
- LLM (Gemini/Mistral): "Summarize in 8 words max"
- Output: headline string
- User can edit before save

**Acceptance Criteria:**
- [ ] Headlines generated automatically
- [ ] Headlines 8 words or less
- [ ] User can edit + save
- [ ] Latency <5 seconds (background)

**Dependencies:** LLM integration (P3 complete), P1 (moments exist)  
**Effort:** 6-8 hours  
**Sequence:** After P3 LLM foundation

### T-068: Suggested Tags (Inference + User Selection) (6-8 hours)

**Description:** LLM suggests 3-5 category tags; user accepts/rejects  

**Technical Requirements:**
- Trigger: After user saves moment
- Input: Moment body + headline
- LLM: "Suggest 3-5 tags from: [Faith, Peace, Work, Clarity, Waiting, etc.]"
- Output: tag array
- UI: Show suggested tags; user can remove/add custom

**Acceptance Criteria:**
- [ ] Tags suggested automatically
- [ ] UI for accepting/rejecting tags
- [ ] Custom tags allowed
- [ ] Max 5 tags per moment

**Dependencies:** T-067 (headlines exist first)  
**Effort:** 6-8 hours  
**Sequence:** After T-067

### T-069: Mood Selection (Optional User Input) (2-3 hours)

**Description:** Optional mood field for moment (preset list + custom)  

**Technical Requirements:**
- Mood field: Optional dropdown (Grateful, Peaceful, Uncertain, Struggling, Joyful, Custom)
- Displayed in detail view + gallery
- Used by Formation Intelligence for pattern detection

**Acceptance Criteria:**
- [ ] Mood dropdown works
- [ ] Custom mood entry allowed
- [ ] Mood saved + displayed

**Dependencies:** None  
**Effort:** 2-3 hours  
**Sequence:** Parallel with T-067/068

### T-070: Editing UI (Edit Existing Moment) (6-8 hours)

**Description:** Allow users to edit saved moments  

**Technical Requirements:**
- Tap edit button on moment detail view
- Edit screen: moment body, headline, tags, mood
- Validation: non-empty body
- Save → update locally + sync

**Acceptance Criteria:**
- [ ] Users can edit all fields
- [ ] Changes synced to cloud
- [ ] Previous edits not visible (edit history deferred)

**Dependencies:** T-067-069 (metadata fields exist)  
**Effort:** 6-8 hours  
**Sequence:** After metadata features

### T-071: Delete Moment (with Confirmation) (2-3 hours)

**Description:** Allow users to delete moments with safety prompt  

**Technical Requirements:**
- Delete button on moment detail view
- Confirmation dialog: "This moment will be permanently deleted"
- Delete locally + sync deletion to cloud

**Acceptance Criteria:**
- [ ] Confirmation required (prevent accidents)
- [ ] Deletion synced to Supabase
- [ ] Deleted moments removed from gallery

**Dependencies:** P1 (moments exist)  
**Effort:** 2-3 hours  
**Sequence:** Simple, can do anytime

### T-072: Headline Edit History (Deferred) (4-6 hours)

**Description:** Show when/how headlines changed (optional, deferred to P3+)  

**Dependencies:** T-067  
**Effort:** 4-6 hours  
**Sequence:** Deferred (nice-to-have, not MVP)

### T-073: Bulk Tagging (Deferred) (4-6 hours)

**Description:** Apply tags to multiple moments at once (deferred to P3+)  

**Dependencies:** T-068  
**Effort:** 4-6 hours  
**Sequence:** Deferred

### T-074: Quality Assurance & Testing (4-6 hours)

**Description:** End-to-end QA for P4 features  

**Acceptance Criteria:**
- [ ] Headlines feel natural + relevant
- [ ] Tags are accurate
- [ ] No crashes on edit/delete
- [ ] All changes synced correctly

**Dependencies:** All P4 features  
**Effort:** 4-6 hours  
**Sequence:** Final P4 ticket

**Pillar 4 Total Effort:** 42-53 hours | **Timeline:** Week 2-3 (parallelize with P3)

---

## PILLAR 5: SEARCH & DISCOVERY (8 Tickets)

**Purpose:** Calendar + filters + full-text search for moment discovery  
**Status:** 🔲 NOT STARTED — DESIGN LOCKED  
**Design Doc:** `PILLAR_5_SEARCH_STRATEGY.md`  
**Blocked By:** Nothing (can parallelize with P3/P4)  
**Blocks:** P6 (entries tab uses search)

### T-075: Calendar View (Visual Density Indicator) (6-8 hours)

**Description:** Show which days have moments captured  

**Technical Requirements:**
- SwiftUI calendar grid
- Days with moments marked (dot, highlight, or circle)
- Tap day → filter to moments from that day
- Swipe to navigate months

**Acceptance Criteria:**
- [ ] Calendar renders correctly
- [ ] Accurate moment density visualization
- [ ] Navigation smooth

**Dependencies:** P1 (moments exist)  
**Effort:** 6-8 hours  
**Sequence:** First P5 ticket (foundational)

### T-076: Date Range Filter (6-8 hours)

**Description:** Filter moments by date range  

**Technical Requirements:**
- UI: Date picker (from date, to date)
- Filter logic: moments where created_at in range
- Apply + clear buttons

**Acceptance Criteria:**
- [ ] Date picker works
- [ ] Filtering accurate
- [ ] Performance acceptable (decrypts filtered moments only)

**Dependencies:** T-075 (calendar foundation)  
**Effort:** 6-8 hours  
**Sequence:** After T-075

### T-077: Full-Text Search (Local Decryption + Grep) (8-10 hours)

**Description:** Search moment content for keywords  

**Technical Requirements:**
- Search input field
- On-device decryption of all moments (local only)
- Regex matching on decrypted content
- Highlight matching terms in results
- Results sorted by relevance

**Acceptance Criteria:**
- [ ] Search finds relevant moments
- [ ] No plaintext searchable in cloud (privacy preserved)
- [ ] Latency <2 seconds for typical queries

**Dependencies:** T-057 (decryption), P1 (moments exist)  
**Effort:** 8-10 hours  
**Sequence:** Parallel with T-076

### T-078: Tag Filter (4-6 hours)

**Description:** Filter moments by tags  

**Technical Requirements:**
- UI: Tag selector (select 1+ tags)
- Filter logic: moments matching any/all selected tags
- Count badge ("3 moments with Faith tag")

**Acceptance Criteria:**
- [ ] Tag filter works correctly
- [ ] Multi-select logic clear to user

**Dependencies:** T-068 (tags exist)  
**Effort:** 4-6 hours  
**Sequence:** After T-076

### T-079: Prayer-Tagged Filter (2-3 hours)

**Description:** Filter to only moments with prayer responses  

**Technical Requirements:**
- Filter: moments where count(responses of type='prayer') > 0
- Toggle on/off

**Acceptance Criteria:**
- [ ] Filter accurate
- [ ] Toggle works

**Dependencies:** T-060 (prayer responses exist)  
**Effort:** 2-3 hours  
**Sequence:** After T-060

### T-080: Soaking-Depth Filter (2-3 hours)

**Description:** Filter to moments with 2+ prompt responses  

**Technical Requirements:**
- Filter: moments where count(responses) >= 2

**Acceptance Criteria:**
- [ ] Logic correct
- [ ] Useful for finding "deep" moments

**Dependencies:** T-061 (prompt responses exist)  
**Effort:** 2-3 hours  
**Sequence:** After T-061

### T-081: Search Result Ranking + Relevance (4-6 hours)

**Description:** Rank search results by relevance (optional for MVP, nice-to-have)  

**Technical Requirements:**
- Score results based on: exact match > partial > fuzzy
- Sort by relevance score (descending)

**Acceptance Criteria:**
- [ ] Most relevant results appear first

**Dependencies:** T-077 (search exists)  
**Effort:** 4-6 hours  
**Sequence:** Optional (deferred if time-constrained)

### T-082: Quality Assurance & Testing (4-6 hours)

**Description:** End-to-end QA for P5 features  

**Acceptance Criteria:**
- [ ] All filters work correctly
- [ ] Search finds expected results
- [ ] Performance acceptable
- [ ] No crashes

**Dependencies:** All P5 features  
**Effort:** 4-6 hours  
**Sequence:** Final P5 ticket

**Pillar 5 Total Effort:** 40-52 hours | **Timeline:** Week 2-3 (parallelize with P3/P4)

---

## PILLAR 6: MENU BAR / NAVIGATION (7 Tickets)

**Purpose:** 4-tab navigation spine (Today | Entries | Create | Insights)  
**Status:** 🔲 NOT STARTED — DESIGN LOCKED  
**Design Doc:** `PILLAR_6_MENU_BAR_STRATEGY.md`  
**Blocked By:** P3, P4, P5, P6 features (can't ship tabs until content ready)  
**Blocks:** P7 (notifications need menu structure)

### T-083: NavigationStack + Tab Architecture (6-8 hours)

**Description:** SwiftUI NavigationStack with 4-tab structure  

**Technical Requirements:**
- Tab enum: Today | Entries | Create | Insights
- Each tab state independent
- Smooth tab switching (no re-renders of other tabs)
- Tab persistence (user's selected tab persists on restart)

**Acceptance Criteria:**
- [ ] 4 tabs render correctly
- [ ] Tab switching <200ms
- [ ] No crashes on tab switch

**Dependencies:** P3/P4/P5 UI ready (so tabs have content)  
**Effort:** 6-8 hours  
**Sequence:** First P6 ticket (foundational)

### T-084: Today Tab (7-Day Moment Filter) (6-8 hours)

**Description:** Show moments from last 7 days  

**Technical Requirements:**
- Filter moments: created_at >= (today - 7 days)
- Reverse chronological order
- Pull-to-refresh
- Empty state: "No moments this week"

**Acceptance Criteria:**
- [ ] Correct 7-day range
- [ ] Chronological order correct
- [ ] Pull-refresh works

**Dependencies:** T-083, P1/P3 (moments + gallery view)  
**Effort:** 6-8 hours  
**Sequence:** After T-083

### T-085: Entries Tab (Full Moments List + Filters) (8-10 hours)

**Description:** Complete archive of all moments  

**Technical Requirements:**
- Display all moments (entire history)
- Integrate P5 filters (date range, tags, prayer-tagged, soaking-depth)
- Searchable (via P5 full-text search)
- Swipe to favorite (optional)
- Empty state: "No moments yet"

**Acceptance Criteria:**
- [ ] All filters integrated
- [ ] Performance good (large moment counts)
- [ ] Search works in entries tab

**Dependencies:** T-083, P5 features (filters exist)  
**Effort:** 8-10 hours  
**Sequence:** After T-083 + P5 complete

### T-086: Create Tab (Navigate to CaptureView) (2-3 hours)

**Description:** Create tab simply launches capture flow  

**Technical Requirements:**
- Tab button → navigates to CaptureView
- Voice button, text button, cancel, save

**Acceptance Criteria:**
- [ ] Navigation works
- [ ] Capture flow same as P1

**Dependencies:** T-083, P1 complete  
**Effort:** 2-3 hours  
**Sequence:** After T-083

### T-087: Insights Dashboard (Formation Metrics) (12-15 hours)

**Description:** Visualize formation metrics (WAR, engagement, soaking, prayer rate)  

**Technical Requirements:**
- Display metrics: WAR (weekly active reflections %), Formation engagement %, Soaking depth (avg responses/moment), Prayer rate (% prayers vs prompts), D7 retention (% returning after 7d)
- Visualizations: Line charts (trends over time), cards (current week stats)
- Tap stat → detailed breakdown
- Fallback: If not enough data, show placeholders + encouragement

**Acceptance Criteria:**
- [ ] Metrics calculated correctly
- [ ] Visualizations render smoothly
- [ ] Data updates as user interacts
- [ ] UX encourages engagement (no guilt, no shame)

**Dependencies:** T-083, P3/P7 features (soaking/notification data exists)  
**Effort:** 12-15 hours  
**Sequence:** Last P6 ticket (requires P3/P7 data)

### T-088: Empty States + Loading States (4-6 hours)

**Description:** Polish empty states + loading spinners for all tabs  

**Technical Requirements:**
- Today: "No moments this week. Create one?" button
- Entries: "No moments yet. Create your first?" button
- Create: Standard capture empty state
- Insights: "Not enough data yet. Keep dwelling!" + progress indicators

**Acceptance Criteria:**
- [ ] Empty states feel encouraging (not discouraging)
- [ ] Loading spinners show during data fetch
- [ ] No crashes

**Dependencies:** T-084-087  
**Effort:** 4-6 hours  
**Sequence:** Polish pass (after features ready)

### T-089: Quality Assurance & Testing (6-8 hours)

**Description:** End-to-end QA for P6 (menu bar + all tabs)  

**Technical Requirements:**
- Device testing (iPhone 13-16)
- Tab switching smoothness
- Navigation flow validation
- Performance under load (1000+ moments)

**Acceptance Criteria:**
- [ ] All tabs work correctly
- [ ] Tab switching <200ms
- [ ] No crashes
- [ ] >90% session include tab switches (success metric)

**Dependencies:** All P6 features  
**Effort:** 6-8 hours  
**Sequence:** Final P6 ticket

**Pillar 6 Total Effort:** 54-67 hours | **Timeline:** Week 4 (after P3/P4/P5 features ready)

---

## PILLAR 7: NOTIFICATIONS (9 Tickets)

**Purpose:** Sparse (1-2/mo) LLM-personalized nudges to return & reflect  
**Status:** 🔲 NOT STARTED — DESIGN LOCKED  
**Design Doc:** `PILLAR_7_NOTIFICATIONS_STRATEGY.md`  
**Blocked By:** Nothing (can parallelize with others)  
**Blocks:** Nothing (optional feature; can ship P3-P6 without it)

### T-090: Firebase Cloud Messaging Setup (6-8 hours)

**Description:** Integrate FCM for push notifications  

**Technical Requirements:**
- FCM SDK integration
- Request notification permissions (on first app launch)
- Handle token registration + refresh
- APNs certificate configuration in App Store Connect

**Acceptance Criteria:**
- [ ] FCM token obtainable
- [ ] Permissions requested + handled
- [ ] APNs certs configured

**Dependencies:** None  
**Effort:** 6-8 hours  
**Sequence:** First P7 ticket (foundational)

### T-091: Notification Scheduling Engine (8-10 hours)

**Description:** Implement cadence logic (frequency cap, timing, back-off)  

**Technical Requirements:**
- Frequency cap: 1-2 per user per month
- Schedule: Based on user's typical app-open time (learned from analytics)
- Back-off logic: Stop after 3 no-clicks
- Batch send: Run daily/weekly scheduler

**Acceptance Criteria:**
- [ ] Frequency cap enforced
- [ ] Smart timing (sends when user likely to engage)
- [ ] Back-off works correctly

**Dependencies:** T-090 (FCM ready), UsageTracker (app-open data exists)  
**Effort:** 8-10 hours  
**Sequence:** After T-090

### T-092: User Segmentation Logic (8-10 hours)

**Description:** Identify user segment (new, non-soaker, occasional, active dweller)  

**Technical Requirements:**
- Segment definition:
  - New: Signed up <7 days ago
  - Non-soaker: Created moments but 0 soaking responses
  - Occasional: 1-3 soaking responses past 30 days
  - Active: 4+ soaking responses past 30 days
- Store segment in profile
- Update segment on each interaction

**Acceptance Criteria:**
- [ ] Segmentation accurate
- [ ] Updates in real-time

**Dependencies:** P3 features (soaking data exists)  
**Effort:** 8-10 hours  
**Sequence:** After P3 complete

### T-093: Notification Preferences UI (4-6 hours)

**Description:** Settings page for notification opt-out + frequency  

**Technical Requirements:**
- Toggle: Notifications on/off
- Frequency options: Weekly, bi-weekly, monthly
- Clear explanation: "Why we send notifications"

**Acceptance Criteria:**
- [ ] Settings persist
- [ ] Toggle works
- [ ] Opted-out users don't receive notifications

**Dependencies:** T-090, T-092  
**Effort:** 4-6 hours  
**Sequence:** After T-092

### T-094: Notification Copy Templates (4-6 hours)

**Description:** Write 4 segment × 3-4 message variations (12-16 templates)  

**Technical Requirements:**
- New users: "Ready to capture what's on your heart?"
- Non-soakers: "How has your heart been this week?"
- Occasional: "You responded to a prompt last week. How about this week?"
- Active dwellers: "You've been reflecting deeply. Want to explore patterns?"
- Each segment: 3-4 variations for A/B testing

**LLM (Gemini/Mistral) will personalize these with user's themes**

**Acceptance Criteria:**
- [ ] 12-16 templates written
- [ ] Templates feel warm + inviting (not pushy)

**Dependencies:** Design input (Kell confirms tone)  
**Effort:** 4-6 hours  
**Sequence:** Parallel with T-092/093

### T-095: LLM Personalization for Notification Copy (6-8 hours)

**Description:** Use Gemini/Mistral to personalize notification templates  

**Technical Requirements:**
- Input: User segment + detected themes (from P3)
- LLM: Customize template with user's themes
- Output: Personalized notification body (60 chars max)
- Fallback: Use generic template if LLM unavailable

**Acceptance Criteria:**
- [ ] Personalization evident (references user's themes)
- [ ] Latency acceptable (batch job, not real-time)
- [ ] Fallback works if API fails

**Dependencies:** T-094, LLM integration from P3  
**Effort:** 6-8 hours  
**Sequence:** After T-094

### T-096: Analytics Logging (Notification Events) (6-8 hours)

**Description:** Log when notifications sent, clicked, dismissed  

**Technical Requirements:**
- Event types: notification_sent, notification_clicked, notification_dismissed
- Track: Segment, notification ID, user response, timestamp
- Calculate metrics: CTR (click-through rate), opt-out rate

**Acceptance Criteria:**
- [ ] Events logged correctly
- [ ] Metrics calculable from logs

**Dependencies:** T-090, T-092  
**Effort:** 6-8 hours  
**Sequence:** Parallel with T-095

### T-097: Smart Send Timing (Optional for MVP) (8-10 hours)

**Description:** A/B test: fixed time vs. user's typical app-open time  

**Technical Requirements:**
- Analyze: When does user typically open app?
- Test group A: Fixed time (e.g., 9am)
- Test group B: User's optimal time (based on data)
- Compare CTR + engagement

**Acceptance Criteria:**
- [ ] A/B test runs for 2-4 weeks
- [ ] Timing optimization evident (>10% CTR lift)

**Dependencies:** T-091, analytics data  
**Effort:** 8-10 hours  
**Sequence:** Optional (deferred if time-constrained)

### T-098: Quality Assurance & Testing (6-8 hours)

**Description:** End-to-end QA for P7 features  

**Technical Requirements:**
- Device testing (iPhone 13-16)
- Notification delivery verified
- Opt-out flow tested
- Baseline metrics: >35% D7 retention, >40% CTR, <10% opt-out

**Acceptance Criteria:**
- [ ] All features work
- [ ] Metrics meet targets
- [ ] No crashes

**Dependencies:** All P7 features  
**Effort:** 6-8 hours  
**Sequence:** Final P7 ticket

**Pillar 7 Total Effort:** 56-74 hours | **Timeline:** Week 3-4 (can parallelize with P3-P6)

---

## FORMATION INTELLIGENCE (6 Tickets) — DEFERRED TO PHASE 3+

**Purpose:** Detect patterns, surface themes, generate insights  
**Status:** 🔲 DEFERRED — Post-Phase 2  
**Design Doc:** Deferred (to be written in Phase 3 planning)  
**Why Deferred:** Need P3-P7 validated first; too speculative to plan now

### T-099: Theme Detection Algorithm (Design + Implementation) (12-16 hours)

**Description:** Detect recurring themes across all user's moments  

**Technical Requirements:**
- NLP or keyword extraction on decrypted moment content
- Categorize themes: Faith, Work, Relationships, Health, Creativity, etc.
- Frequency scoring: How often does each theme appear?
- User can see themes dashboard

**Acceptance Criteria:**
- [ ] Theme detection accurate
- [ ] Themes update in real-time

**Dependencies:** P1 + all pillars complete  
**Effort:** 12-16 hours  
**Sequence:** Phase 3 only

### T-100: Theme Insight Generation (LLM) (6-8 hours)

**Description:** Generate human-readable insights for each theme  

**Technical Requirements:**
- Input: Theme + moment samples
- LLM: "Generate a 100-char insight about this user's faith-work integration"
- Output: Insight string + visual (optional)

**Acceptance Criteria:**
- [ ] Insights feel personalized + meaningful

**Dependencies:** T-099, LLM integration  
**Effort:** 6-8 hours  
**Sequence:** Phase 3 only

### T-101: Visual Gallery by Theme (Optional UI) (8-12 hours)

**Description:** Display moments organized by detected theme (grid, timeline, etc.)  

**Acceptance Criteria:**
- [ ] Gallery renders smoothly
- [ ] Themes clickable → shows moments for that theme

**Dependencies:** T-099  
**Effort:** 8-12 hours  
**Sequence:** Phase 3 only

### T-102: Formation Insights Dashboard (Post-MVP) (12-16 hours)

**Description:** Dashboard showing spiritual formation progression  

**Acceptance Criteria:**
- [ ] User sees: patterns over time, spiritual growth indicators

**Dependencies:** All features complete  
**Effort:** 12-16 hours  
**Sequence:** Phase 3 only

### T-103: Threshold Alerts (Deferred) (4-6 hours)

**Description:** Alert user to patterns (e.g., "anxiety mentioned 10 times this month")  

**Effort:** 4-6 hours  
**Sequence:** Phase 3 only

### T-104: Formation Coaching (Deferred) (TBD)

**Description:** Optional: AI coaching based on patterns (very speculative)  

**Sequence:** Phase 4+ only

**Formation Intelligence Total Effort:** 48-70 hours | **Timeline:** Phase 3+ (deferred)

---

## TICKET EXECUTION SEQUENCE (Critical Path)

```
WEEK 1 (May 12-18): PILLAR 2 — SECURITY (BLOCKING)
───────────────────────────────────────────────────
T-054: Encryption Architecture           [16-24h] ▓▓▓▓▓
T-055: Encryption Migration              [4-6h]  ▓▓
T-056: Keychain Storage (parallel)       [4-6h]  ▓▓
T-057: Password Recovery (parallel)      [8-12h] ▓▓▓
                                          ────────────────
                        SUBTOTAL WEEK 1: 32-48 hours


WEEK 2-3 (May 19-Jun 1): PILLARS 3+4+5 (PARALLEL)
─────────────────────────────────────────────────
Pillar 3 (Soaking):
  T-058: Gallery View                    [8-10h] ▓▓▓▓
  T-062: Rich Context                    [8-10h] ▓▓▓▓
  T-060: Prayer Flow (w/ LLM)            [12-16h]▓▓▓▓▓
  T-061: Prompts Flow (w/ LLM)           [12-16h]▓▓▓▓▓
  T-059: Soak Mode                       [6-8h]  ▓▓▓
  T-063: Response Persistence            [4-6h]  ▓▓
  T-065: Notification Integration        [4-6h]  ▓▓
  T-066: QA Testing                      [6-8h]  ▓▓▓

Pillar 4 (Editing):
  T-067: Auto-Headlines (w/ LLM)         [6-8h]  ▓▓▓
  T-068: Tag Suggestion (w/ LLM)         [6-8h]  ▓▓▓
  T-069: Mood Selection                  [2-3h]  ▓
  T-070: Editing UI                      [6-8h]  ▓▓▓
  T-071: Delete Moment                   [2-3h]  ▓
  T-074: QA Testing                      [4-6h]  ▓▓

Pillar 5 (Search):
  T-075: Calendar View                   [6-8h]  ▓▓▓
  T-076: Date Range Filter               [6-8h]  ▓▓▓
  T-077: Full-Text Search                [8-10h] ▓▓▓▓
  T-078: Tag Filter                      [4-6h]  ▓▓
  T-079: Prayer-Tagged Filter            [2-3h]  ▓
  T-080: Soaking-Depth Filter            [2-3h]  ▓
  T-082: QA Testing                      [4-6h]  ▓▓

                      SUBTOTAL WEEKS 2-3: ~160-190 hours (can parallelize)


WEEK 4 (Jun 2-8): PILLAR 6 — MENU BAR + P7 START
──────────────────────────────────────────────────
Pillar 6 (Navigation):
  T-083: NavigationStack + Tabs          [6-8h]  ▓▓▓
  T-084: Today Tab                       [6-8h]  ▓▓▓
  T-085: Entries Tab (w/ filters)        [8-10h] ▓▓▓▓
  T-086: Create Tab                      [2-3h]  ▓
  T-087: Insights Dashboard              [12-15h]▓▓▓▓▓▓
  T-088: Empty States                    [4-6h]  ▓▓
  T-089: QA Testing                      [6-8h]  ▓▓▓

Pillar 7 (Notifications) — START:
  T-090: Firebase Setup                  [6-8h]  ▓▓▓
  T-091: Scheduling Engine               [8-10h] ▓▓▓▓
  T-092: User Segmentation               [8-10h] ▓▓▓▓

                        SUBTOTAL WEEK 4: ~80-105 hours


WEEK 5 (Jun 9-15): PILLAR 7 COMPLETE
────────────────────────────────────────
  T-093: Notification Preferences UI     [4-6h]  ▓▓
  T-094: Copy Templates                  [4-6h]  ▓▓
  T-095: LLM Personalization             [6-8h]  ▓▓▓
  T-096: Analytics Logging               [6-8h]  ▓▓▓
  T-098: QA Testing                      [6-8h]  ▓▓▓

                        SUBTOTAL WEEK 5: ~26-36 hours


WEEK 6+ (Jun 16+): FINAL POLISH + BETA LAUNCH
──────────────────────────────────────────────
  ▓ Usability Testing (internal)
  ▓ Performance Optimization
  ▓ Bug Fixes
  ▓ Beta Cohort 1 (50-100 users) launch
  ▓ Iteration based on feedback


═════════════════════════════════════════════════════════════════════════════════
TOTAL EFFORT: ~400-500 developer hours (5-6 person-weeks)
TIMELINE: May 12 – Jun 20, 2026 (6 weeks)
BETA READY: ~June 15-20 (100 users closed beta)
PUBLIC LAUNCH: ~August 2026 (Phase 2 beta → public)
```

---

## Dependency Matrix (Which Blocks Which)

```
BLOCKING RELATIONSHIPS:
  P2 (Security T-054) ────────────┐
                                  ├──→ P3 (T-058+)
                                  │
  P3 Complete ────────┐           │
                      ├──────────→ P6 (T-083+)
  P4 Complete         │           │
  P5 Complete ────────┘           │
                                  ▼
                            Beta Ready

  P7 (Notifications) ─── INDEPENDENT (can start Week 3)
  Formation Intel ────── DEFERRED (Phase 3+, not blocking)
```

---

## Acceptance Criteria Summary

| Pillar | MVP Success Metric | Phase 2 Goal |
|--------|------------------|------------|
| **P0** | >90% onboarding completion | Frictionless signup |
| **P1** | ✅ 100% capture adoption | Complete |
| **P2** | 0 unencrypted moments in cloud | All encrypted |
| **P3** | WAR 40-50% by week 8 | Dwelling practice established |
| **P4** | 80% moments with headlines + tags | Metadata complete |
| **P5** | >70% search queries return results | Discovery enabled |
| **P6** | >90% sessions include tab switches | Navigation fluent |
| **P7** | >35% D7 retention, >40% CTR, <10% opt-out | Engagement sustainable |

---

## Risk Register

| Risk | Probability | Impact | Mitigation |
|------|-----------|--------|-----------|
| LLM API latency >2s (poor UX) | Low | High | A/B test Gemini vs Mistral; fallback to generic prompts |
| Encryption bugs (data loss) | Low | Critical | Thorough testing + migration verification |
| Pillar 2 delay blocking P3 | Medium | Critical | Parallelize T-055/056/057 as much as possible |
| Search performance on 1000+ moments | Medium | High | Optimize decryption + indexing |
| Notification opt-out rate >15% | Medium | Medium | A/B test copy + timing; measure CTR weekly |
| Formation Intelligence too complex | Medium | Low | Defer to Phase 3; keep Phase 2 focused |

---

## Next Steps (Immediate)

1. ✅ **Skeleton Diagram locked** — Architecture clear
2. ✅ **LLM Tournament locked** — Gemini MVP → Mistral Scale
3. ✅ **Ticket Map locked** — 96 tickets, dependencies, estimates
4. 🔄 **Execution begins:** May 12, 2026
   - Week 1: Start T-054 (Encryption) — BLOCKING
   - Parallelize: T-055/056/057 + start Gemini integration for P3 LLM
   - Week 2-3: Ramp up P3/P4/P5 features
   - Week 4+: Integrate P6 (menu bar)

---

**Document Status:** 🎯 LOCKED & READY FOR IMPLEMENTATION  
**Owner:** Kell Golden  
**Last Updated:** May 7, 2026  
**Next Review:** May 12, 2026 (Week 1 kickoff)

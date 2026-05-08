# Dwellable Backlog & Future Features

This document captures feature ideas, improvements, and deferral items that are out of scope for Phase 2 Beta MVP but worth pursuing in Phase 2+ iterations.

---

## Core Features (Phase 2+)

### Audio Playback / Text-to-Speech for Moments
**Pillar:** 4 (Editing) / Cross-pillar
**Idea:** Allow users to have their captured moments read aloud to them via text-to-speech (TTS).

**Spiritual Motivation:** "Faith comes by hearing" (Romans 10:17). By hearing the story of what God has done in their life, users experience deeper faith, remembrance, and recognition of God's work. It's a reminder: "Here's what you've gone through. Here's where God was. Here's what He is doing in your life."

**User Experience:**
- User opens a moment
- Taps a **Play** button (audio icon)
- Apple's native TTS reads the moment text aloud (headline + full text)
- User can pause/resume, adjust playback speed
- Optional: User can also hear their reflections read aloud if present
- Contemplative listening experience (not reading, but *hearing*)

**Implementation Considerations:**
- Use AVSpeech (Apple native TTS)
- Voice selection: high-quality female or male voice option
- Ambient audio support (read while doing dishes, driving, walking)
- Offline capability: TTS voices pre-downloaded on device

**Value:**
- Accessibility (vision-impaired users, or users preferring audio)
- Contemplative deepening (hearing vs. reading engages different parts of brain)
- Reminiscence: hearing your own story creates emotional resonance
- Spiritual reminder: "Look what God has done"

**Phase 2+ Priority:** Medium (Nice-to-have for MVP, high value for retention)

---

### Email Validation Confirmation (P0 Deferral)
**Pillar:** 0 (Onboarding)
**Idea:** Require email confirmation (click link) before account fully activates.

**Rationale Deferred:** MVP prioritizes fast signup. Email validation adds friction. Server-side validation sufficient for initial users.

**When to Revisit:** Post-Phase 2 Beta if bot signup becomes a problem or compliance requires it.

---

### Version History / Edit Snapshots (P4 Deferral)
**Pillar:** 4 (Editing)
**Idea:** Maintain version history of edited moments. Users can see what changed, revert to older versions, or compare versions over time.

**Value:** Track how user's interpretation of a moment changes. Spiritual growth lens: "I originally felt X, but after re-reading and editing, I see Y."

**Complexity:** Requires additional storage, versioning logic, UI for comparison.

**When to Revisit:** Phase 2+ if user feedback indicates desire to see edit history.

---

### Bulk Editing & Batch Operations (P4 Deferral)
**Pillar:** 4 (Editing)
**Idea:** Select multiple moments and batch-edit (add tags, update mood, delete, archive).

**Value:** Power users managing 100+ moments can organize more efficiently.

**When to Revisit:** Post-MVP when moment library grows and users request bulk operations.

---

### Archive Instead of Hard Delete (P4 Deferral)
**Pillar:** 4 (Editing)
**Idea:** Soft delete—archive moments instead of permanent deletion. Users can recover archived moments within 30 days or permanently destroy.

**MVP Decision:** Hard delete only (respects user autonomy if they want to remove something).

**Value Added:** Safety net for accidental deletions; recoverable archive for users who change their mind.

**When to Revisit:** Phase 2 Beta if user feedback reveals accidental deletion anxiety.

---

### Collaborative Moments (Future)
**Pillar:** 4 (Editing) / Cross-pillar
**Idea:** Share moments with trusted people (spouse, spiritual director, prayer group). Collaborators can read, comment, or co-author reflections.

**Value:** Accountability, shared spiritual journey, community soaking.

**When to Revisit:** Phase 3+ (requires privacy/security redesign, sharing policy, permission model).

---

### Rich Text Support (P4 Deferral)
**Pillar:** 4 (Editing)
**Idea:** Bold, italic, links, lists, formatting in moment text.

**MVP Decision:** Plain text only (simpler encryption, search, consistent rendering).

**Value Added:** Users can emphasize key phrases, create structure in longer moments.

**When to Revisit:** Phase 2+ if users express desire for formatting (currently not a priority).

---

### Moment Locking (P4 Future)
**Pillar:** 4 (Editing)
**Idea:** Lock moments to prevent accidental edit/delete. Requires authentication to unlock.

**Value:** Peace of mind for particularly precious or sensitive moments.

**When to Revisit:** Phase 2+ if security/protection concerns arise.

---

### Biometric Unlock for Master Key (P2 Deferral)
**Pillar:** 2 (Security)
**Idea:** Use Face ID or Touch ID to unlock master encryption key instead of typing password each time.

**MVP Decision:** Keychain native security (device unlock required).

**Value Added:** Frictionless security, re-auth without password entry.

**When to Revisit:** Phase 2+ optimization (UX enhancement, not blocking feature).

---

### Theme Personalization for Soaking (P3 Deferral)
**Pillar:** 3 (Soaking)
**Idea:** Adjust prayer tone/length based on user intents. Example: "Process emotions" intent → longer, exploratory prayer. "Find peace" intent → shorter, grounding prayer.

**MVP Decision:** Single prayer generation for all users.

**Value Added:** More personalized contemplative experience.

**When to Revisit:** Phase 2 Beta feedback on prayer resonance.

---

### Gemini → Claude / Mistral LLM Tournament (Phase 2+ Decision)
**Pillar:** Cross-pillar (P0, P1, P3)
**Idea:** After Phase 2 Beta MVP launch on Gemini, evaluate Claude 3.5 Sonnet vs. Mistral for better headline generation, prayer quality, prompt relevance.

**Current:** Locked on Gemini 2.0 Flash (free tier, quick, sufficient for MVP).

**Phase 2 Evaluation:** Cost, quality, latency trade-offs when scaling beyond initial users.

---

## Small Enhancements (Low Priority)

- **Tag Autocomplete:** Suggest past tags when user types in tag input
- **Character Limit Display:** Show character count as user types (if limit decided)
- **Edit Undo/Redo:** Local undo stack within edit session
- **Moment Sharing:** Share moment text via email, iMessage, Notes
- **Dark Mode for Editing:** Evening/nighttime reading mode
- **Keyboard Shortcuts:** cmd+S to save edits, cmd+Z to undo
- **Accessibility:** WCAG compliance audit for all edit workflows

---

## Out of Scope (Parking Lot)

- Multi-user accounts / family sharing (requires auth redesign)
- Offline sync conflict resolution (complex; MVP: last-write-wins)
- AI-powered mood prediction (use past moods to suggest next moment's mood)
- Calendar integration (view moments on calendar grid)
- Apple Watch app (future expansion)
- Web app (currently iOS-only MVP)
- API for third-party integrations (requires security review)

---

**Last Updated:** May 7, 2026  
**Owner:** Kell Golden  
**Review Cadence:** Post-Phase 2 Beta MVP launch

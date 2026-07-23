# Pillar 2: Security & Privacy (Server-Side Encryption) — Strategy & Design Skeleton

**Status:** 🔄 **Phase 2 Beta** (T-062 In Progress)
**Last Updated:** July 22, 2026 — **Model changed from client-side E2E to server-side encryption** (see below)

---

## 🔄 Model Change (July 22, 2026)

This pillar previously specified **client-side end-to-end (E2E) encryption** — a zero-knowledge model where only the user could ever decrypt their moments, and the encryption key was derived directly from their password.

**That model is superseded.** Dwellable now uses **server-side encryption at rest**, with transient decryption for legitimate processing.

**Why the change:** Dwelly's conversation, Prayer generation, and Journal synthesis all require sending moment content as plaintext to a third-party cloud LLM (Groq Llama 3 70B / GPT-4o mini) for processing. True zero-knowledge E2E — "only the user can ever see this" — was never fully compatible with that architecture; the product's own core features already require the content to become readable outside the device. Continuing to design (and promise users) pure E2E would have meant shipping a privacy claim the app couldn't actually keep.

**The promise shifts from:**
> "We can never see your moments" (zero-knowledge)

**to:**
> "Your moments are secure with us" (encrypted at rest and in transit, decrypted only when the app legitimately needs to act on them, protected from external theft and unauthorized access — not a mathematical guarantee that no one at Dwellable could ever access it)

This also resolves a real, already-flagged inconsistency: Onboarding Screen 6's locked copy ("we temporarily decrypt your moments — just for you — then re-encrypt") already described server-side behavior, while this doc and T-062 were scoped for pure E2E. They now agree.

---

## Design Summary

Pillar 2 is the **trust layer** of Dwellable's Formation Intelligence system. It encrypts all sacred moment data (transcripts, journals, user profile, metadata) at rest and in transit using AES-256-GCM, ensuring that:

1. **Users' spiritual formation data is protected** — from database breach, stolen backups, and external theft
2. **Dwellable communicates trust** — by encrypting sacred moments and being honest about how they're processed, we signal that spiritual formation is sacred
3. **Future pillars (P3+) can use rich context confidently** — because data is protected at rest, and decryption is scoped, transient, and purposeful

Encryption is transparent to the user: set a password once during onboarding (used for authentication), never touch it again unless resetting it.

---

## Formation Intelligence — What Pillar 2 Is & Learns

### What Pillar 2 Is (in the Formation Intelligence System)

**Not a learning pillar. A trust pillar.**

| Pillar | Role |
|--------|------|
| **P0 (Onboarding)** | *Learns* spiritual intent, theological framework, support style |
| **P1 (Capture)** | *Infers* archetype (Jotter, Venter, Processor), emotional tone |
| **P2 (Security)** | *Protects* both, at rest and in transit. Enables trust and enables processing. |
| **P3+ (Prayer, Journaling, Themes)** | Uses formation context learned in P0–P1, confident in P2's protection |

### What P2 Learns About the User

P2 doesn't infer spiritual maturity or patterns. It learns the **user's privacy values implicitly:**

- By capturing sacred moments, user signals: *"I'm trusting Dwellable with something meaningful. I need to know it's safe."*
- This tells P2: *"This user sees their spiritual life as sacred. We must treat it that way — protect it, and be honest about how it's used."*

### What P2 Communicates to the User

**More important than what P2 learns is what P2 promises:**

1. **"Your spiritual formation is sacred to us."**
   - Not generic notes. Sacred moments of encountering God.
   - Not data to sell or expose. Data to protect and steward carefully.

2. **"Your moments are secure — encrypted at rest, protected from theft and unauthorized access."**
   - Not a zero-knowledge claim. A stewardship claim.
   - The app processes your content (via Dwelly, journal synthesis, prayer generation) because that's the product — but it isn't stored in the clear, isn't casually browsable, and isn't exposed if the database is breached.

3. **"Future features trust this foundation."**
   - When P3 surfaces contextual prayers, it's because P2 made it safe to process.
   - When P6 (Formation Intelligence) detects patterns, it's because P2 protected the underlying data at rest.
   - When P4 synthesizes journals with rich context, it's because P2's protections let that context be used responsibly.

### How P2 Prepares P3 (Prayer/Prompts)

**P3 cannot exist meaningfully without P2's foundation.**

Example (P3 behavior):
- *"James, we've talked about anxiety 8 times in the past month. What are you filling your heart with now?"*

This is only possible if:
1. P2 encrypted those 8 moment transcripts at rest
2. P2 protects the user's identity and theological framework (from P0)
3. **P2 decrypts transiently, only for the processing that generates this prompt — never persisting plaintext beyond that**

**P2 removes the barrier:** By protecting data at rest and being disciplined about when/why it's decrypted, P2 gives P3 permission to know the user deeply without that trust being reckless.

---

## Core Design Decisions — Locked

### Encryption Algorithm
- **Algorithm:** AES-256-GCM (authenticated encryption, prevents tampering)
- **Key Management:** Server-managed encryption key(s), independent of the user's login password
- **Key Storage:** Managed via a server-side key management approach (e.g., a dedicated secrets/KMS layer) — not derived from or gated by user password
- **Data Scope:** All moment transcripts, journals, user profile, metadata

### Server-Side Encryption
- **Where:** Data is encrypted at rest in Supabase (encrypted columns/blobs)
- **When:** Immediately on write
- **Decryption:** Happens transiently, server-side or on-device after authenticated fetch, only when the app needs to act on the content (display to the user, send to LLM for Dwelly/Prayer/Journal synthesis, run Formation Intelligence processing)
- **Discipline:** Plaintext is never persisted beyond the operation that required it; not written to logs; not cached longer than the request lifecycle

### Authentication & Password
- **Password's role:** Authentication only (proves it's really you) — **no longer used to derive the encryption key**
- **Single password per user** — set during onboarding (P0), changeable anytime via Settings
- **Password reset:** Now a normal, recoverable flow (see Password Reset section below) — forgetting your password no longer means losing your data
- **Multi-device sync:** Simpler than under E2E, since keys aren't tied to a single device's derivation — still deferred to Phase 2+ for scheduling reasons, not architectural ones

### Data at Rest
- **Supabase storage:** Encrypted at rest (encrypted_content column)
- **Local device:** Pending moments (unencrypted UserDefaults queue) until synced — same as before
- **Transit:** HTTPS enforced; all network traffic encrypted by TLS layer + our AES-256-GCM at rest

### LLM Processing (Dwelly, Prayer, Journal Synthesis, Formation Intelligence)
- Moment content is decrypted transiently and sent to the LLM provider (Groq / OpenAI) as plaintext for processing — this is unavoidable given the product's core features
- No moment content is persisted in LLM provider logs beyond their standard request handling (see LLM provider's data-retention terms; Groq's no-training guarantee already documented in the LLM decision)
- This should be stated plainly to users, not hidden — see User Communication below

### Search & Indexing (Phase 2)
- **Encryption-aware search:** Full-text search index built server-side against decrypted content, stored in a protected index
- **Result:** Users can search moments without the app needing to decrypt-and-scan the entire library on every query
- **Privacy:** Search index protected the same way as moment data — encrypted at rest, access-scoped to the authenticated user

---

## What Stays Metadata-Only: Notifications

**This constraint is unchanged and still locked, independent of the storage/processing model above.**

Anything that surfaces in a **push notification body** (visible on a lock screen, glanced at by others) is restricted to metadata: mood tags, theme names, frequency, timing. Never a user's actual sentences or transcript content.

- ✅ *"You reflected on anxiety 8 times this month — what patterns do you notice?"* (theme name, a category)
- ❌ *"Remember when you wrote about your fight with your brother?"* (actual content, a different exposure risk)

**Why this survives the model change:** Server-side processing (Dwelly reading your words to help you) and notification content (a string sitting on a lock screen) are different exposure surfaces with different risk profiles. Loosening the storage model doesn't mean loosening what's safe to put in a push notification.

---

## Data Model (Encryption Impact)

```swift
struct EncryptedMoment: Codable {
    let id: String                      // UUID (unencrypted)
    let userId: String                  // User ID (unencrypted, for auth)
    let encryptedContent: Data          // AES-256-GCM encrypted
    let encryptedMetadata: Data?        // Tags, mood, etc. (optional)
    let createdAt: Date                 // Timestamp (unencrypted)
    let updatedAt: Date                 // Timestamp (unencrypted)
    let ivNonce: String                 // Initialization vector (stored with ciphertext)
}
```

**Note:** The `EncryptionKey` struct from the old model (password → derived key) is removed. Encryption keys are now server-managed, not derived from or stored alongside user password data.

---

## Technical Architecture

### Encryption Pipeline

```
User captures moment (P1) or app writes any protected data
    ↓
Before saving to Supabase: AES-256-GCM encrypts content using server-managed key
    ↓
Encrypted blob stored in Supabase (encrypted_content column)
    ↓
On read (display, or LLM processing need): fetch encrypted → decrypt transiently
    ↓
Plaintext used only for the immediate purpose (screen display, or one LLM call) — never persisted, never logged
```

### Key Components

**EncryptionManager**
- Encrypts/decrypts using a server-managed key (not user-password-derived)
- Provides `encrypt(data)` and `decrypt(data)` methods
- Handles IV/nonce generation (random per encryption)

**LocalStorageManager**
- Saves pending moments locally (unencrypted, for offline capability) — unchanged
- Encrypts before sending to Supabase (T-062 integration)
- Decrypts on read (transparent to UI)

**SyncManager**
- Queues pending moments locally (unencrypted until sync) — unchanged
- On sync: calls EncryptionManager.encrypt() before API call
- On download: calls EncryptionManager.decrypt() after API call

---

## Password Reset & Account Recovery (MVP Specification)

**This section changes the most under the new model.**

Because the password is now authentication-only — not the source of the encryption key — password reset becomes a **normal, fully recoverable flow**, the same shape as most consumer apps.

### Password's Role (All Flows)

```
User enters password (login, onboarding, password change, or password reset)
    ↓
Used to authenticate the user against Supabase auth
    ↓
No encryption key derivation happens here — encryption key is server-managed, independent of password
```

**Key Principle:** Because encryption doesn't depend on the password, resetting the password has **zero impact on data access**. All moments remain fully readable before and after a reset.

### Password Reset Flow (Forgot Password)

**Entry point:** Login screen → "Forgot password?" → Email verification → New password

1. **Email Verification (Backend):** Supabase generates a secure reset token (JWT, 30-min expiry), sent via email
2. **New Password Entry (Device):** User clicks email link → app receives reset token → enters new password + confirmation
3. **Password Update:** Backend validates token, updates Supabase auth table with new password hash
4. **Result:** User signs in with new password. All moments — old and new — are immediately accessible. No asymmetry, no re-encryption needed, no data loss.

### Password Change Flow (Settings)

**Entry point:** Settings → Security & Privacy → "Change Password"

1. User enters current password → verified against Supabase auth
2. User enters new password + confirmation (8+ chars, mixed case, number, symbol)
3. Supabase auth table updated
4. **Result:** Immediate. No key re-derivation, no delay, no impact on stored data.

### Account Lockout & Brute-Force Protection

Now safe to implement normally, since lockout no longer risks permanently orphaning a user's encryption key:
- Standard rate limiting / lockout after N failed attempts (Post-MVP; MVP can start with basic rate limiting per T-050's existing brute-force protection work)

---

## User Communication (Plain-Language Promise)

Replaces the old "we never see your moments / not us, not servers, not anyone" language.

**Recommended framing (to be finalized with actual onboarding/settings copy in Tier 2 sweep):**

> "Your moments are encrypted and protected — safe from theft or unauthorized access. Dwelly reads them to help you pray, reflect, and see patterns over time, because that's how the app works. We don't sell, share, or expose your data, and we don't read it beyond what's needed to serve you."

This should appear (in some form) in:
- Onboarding Screen 6 (Privacy) — **replace** current "not us, not servers, not anyone" line
- Settings → Security & Privacy explainer

---

## Security Exclusions & Deferred Decisions

| Feature | Status | Reason |
|---------|--------|--------|
| **Zero-knowledge / pure client-side E2E** | ❌ Excluded (superseded) | Incompatible with LLM-based processing (Dwelly, Prayer, Journal synthesis) that's core to the product |
| **Cloud key backup of a user-derived key** | N/A | No longer applicable — key isn't user-derived |
| **Multi-device sync** | ⏳ Deferred | Simpler under this model, but still a Phase 2+ scheduling decision, not a blocker |
| **Account lockout / rate limiting** | ⏳ Deferred to Post-MVP polish | No longer conflicts with data access (see above); low urgency, not a hard blocker |
| **Biometric unlock** | ⏳ Deferred | Face ID / Touch ID integration (Phase 2+) |
| **Hardware key attestation** | ⏳ Deferred | Apple Secure Enclave integration (Phase 2+) |

---

## Success Metrics (P2)

### Formation Intelligence Perspective
- ✅ P3+ pillars can confidently reference user's actual story in prayers/prompts
- ✅ User feels their data is protected and stewarded well
- ✅ No data leaks or unauthorized access in Phase 2 beta
- ✅ Encryption is transparent to the user (no password-related data-loss risk)

### Technical Perspective
- ✅ All moments encrypted at rest before Supabase storage
- ✅ Decryption latency <200ms on device/server for display use cases
- ✅ No plaintext moments persisted beyond the operation that required them (no plaintext at rest, no plaintext in logs)
- ✅ Password reset/change flows never affect data accessibility

---

## Open Questions & TBD

1. **Key management specifics:** Where does the server-managed encryption key actually live (Supabase Vault, a dedicated secrets manager, KMS)? Needs an engineering decision as part of T-062 implementation.
2. **LLM provider data retention:** Confirm Groq's and OpenAI's request-log retention windows and whether either offers a zero-retention API tier — worth locking down explicitly given moment content now routinely passes through them.
3. **Multi-device support?** (Deferred to Phase 2) — architecturally simpler now, still needs a real design pass.
4. **Search index security?** (To be designed alongside P5/P6) — confirm the search index gets the same at-rest protection as moment content.
5. **Access logging:** Should decrypt operations be logged (who/when/why) for an internal audit trail, given P2 is no longer a hard technical wall? Recommend yes — even without zero-knowledge, an access log is good practice.

---

## Next: How P2 Prepares P3

Once P2 is implemented, P3 (Prayer/Prompts) can be articulated as:
- **What P3 is:** A contemplative response layer that uses protected context from P0–P2
- **What P3 learns:** User's reflection patterns, prayer preferences, spiritual tone
- **How P3 prepares P4:** By capturing reflection responses, P3 gives P4 rich context for journal synthesis

---

**P2 Formation Intelligence model locked (July 22, 2026). Next: sweep Tier 1/2 docs for consistency, then move to P3 confirmation.**

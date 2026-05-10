# Pillar 2: Security & Privacy (E2E Encryption) — Strategy & Design Skeleton

**Status:** 🔄 **Phase 2 Beta** (T-062 In Progress)  
**Last Updated:** May 10, 2026

---

## Design Summary

Pillar 2 is the **trust layer** of Dwellable's Formation Intelligence system. It encrypts all sacred moment data (transcripts, journals, user profile, metadata) end-to-end using AES-256-GCM encryption with client-side key derivation, ensuring that:

1. **Users own their spiritual formation data** — only they can decrypt it
2. **Dwellable communicates trust** — by encrypting sacred moments, we signal that spiritual formation is sacred
3. **Future pillars (P3+) can use rich context confidently** — because data is protected

Encryption is transparent to the user: set password once during onboarding, then forgotten.

---

## Formation Intelligence — What Pillar 2 Is & Learns

### What Pillar 2 Is (in the Formation Intelligence System)

**Not a learning pillar. A trust pillar.**

| Pillar | Role |
|--------|------|
| **P0 (Onboarding)** | *Learns* spiritual intent, theological framework, support style |
| **P1 (Capture)** | *Infers* archetype (Jotter, Venter, Processor), emotional tone |
| **P2 (Security)** | *Protects* both. Enables trust. No new learning — pure enablement. |
| **P3+ (Soaking, Journaling, Themes)** | Uses formation context learned in P0–P1, confident in P2's encryption |

### What P2 Learns About the User

P2 doesn't infer spiritual maturity or patterns. Instead, it learns the **user's privacy values implicitly:**

- By choosing E2E encryption, user signals: *"I'm capturing sacred moments. I need to know they're safe."*
- This implicit signal tells P2: *"This user sees their spiritual life as sacred. We must treat it that way."*

### What P2 Communicates to the User

**More important than what P2 learns is what P2 promises:**

1. **"Your spiritual formation is sacred to us."**
   - Not generic notes. Sacred moments of encountering God.
   - Not data to analyze, sell, or misuse. Data to protect.

2. **"You own your formation story."**
   - Only you can decrypt your moments. Not Dwellable. Not cloud vendors.
   - Your spiritual journey stays yours alone.

3. **"Future features trust this foundation."**
   - When P3 surfaces contextual prayers, it's because P2 made it safe.
   - When P7 detects themes, it's because P2 encrypted them.
   - When P4 synthesizes journals with rich context, it's because P2 protected that context.

### How P2 Prepares P3 (Soaking/Prayer/Prompts)

**P3 cannot exist meaningfully without P2's foundation.**

Example (P3 future behavior):
- *"James, we've talked about anxiety 8 times in the past month. What are you filling your heart with now?"*

This is only possible if:
1. P2 encrypted those 8 moment transcripts
2. P2 encrypted the user's identity and theological framework (from P0)
3. **P2 made it safe for P3 to use that rich context without exposing data**

**P2 removes the barrier:** By being trustworthy with encryption, P2 gives P3 permission to know the user deeply.

---

## Core Design Decisions — Locked

### Encryption Algorithm
- **Algorithm:** AES-256-GCM (authenticated encryption, prevents tampering)
- **Key Derivation:** Argon2id (password → 256-bit key, resistant to brute-force)
- **Key Storage:** iOS Keychain (OS-level encryption, isolated per app)
- **Data Scope:** All moment transcripts, journals, user profile, metadata

### Client-Side Encryption
- **Where:** Encryption happens on device before data leaves the app
- **When:** Immediately after moment capture or journal creation
- **Result:** Supabase never sees plaintext; only encrypted blobs
- **Decryption:** Only happens on device when user opens encrypted moment

### Key Management
- **Single password per user** — Set during onboarding (P0), never shown again
- **Password recovery:** User loses access if forgotten (trade-off: privacy over convenience)
- **Multi-device sync:** Deferred to Phase 2+ (would require key distribution strategy)
- **Key rotation:** Optional in Phase 2+ (current design: single key per user)

### Data at Rest
- **Supabase storage:** Encrypted blobs (encrypted_content column)
- **iOS Keychain:** Master key derived from password (Argon2id)
- **Local device:** Pending moments (unencrypted UserDefaults queue) until synced
- **Transit:** HTTPS enforced; all network traffic encrypted by TLS layer + our AES-256-GCM

### Search & Indexing (Phase 2)
- **Encryption-aware search:** Full-text search index built on plaintext *before* encryption
- **Result:** Users can search moments without decrypting entire library
- **Privacy:** Search index itself encrypted; only searchable from authenticated device

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

struct EncryptionKey {
    let userPassword: String            // Set during P0 onboarding
    let derivedKey: [UInt8]             // 256-bit key (via Argon2id)
    let salt: Data                      // Random salt per key derivation
}
```

---

## Technical Architecture

### Encryption Pipeline

```
User enters password (P0 onboarding)
    ↓
Argon2id derives 256-bit key from password
    ↓
User captures moment (P1)
    ↓
Before saving to Supabase: AES-256-GCM encrypts moment content
    ↓
Encrypted blob stored in Supabase (encrypted_content column)
    ↓
On read: Moment fetched encrypted → AES-256-GCM decrypts on device
    ↓
Plaintext displayed to user on screen only
```

### Key Components

**EncryptionManager**
- Initializes encryption on first app open
- Derives key from password using Argon2id (slow-hash, ~1 second delay)
- Provides `encrypt(data)` and `decrypt(data)` methods
- Handles IV/nonce generation (random per encryption)

**LocalStorageManager**
- Saves pending moments locally (unencrypted, for offline capability)
- Encrypts before sending to Supabase (T-062 integration)
- Decrypts on read (transparent to UI)

**SyncManager**
- Queues pending moments locally (unencrypted until sync)
- On sync: calls EncryptionManager.encrypt() before API call
- On download: calls EncryptionManager.decrypt() after API call

---

## Security Exclusions & Deferred Decisions

| Feature | Status | Reason |
|---------|--------|--------|
| **Server-side decryption** | ❌ Excluded | Defeats purpose of E2E; we never see plaintext |
| **Cloud key backup** | ❌ Excluded | Key stays on device only; no cloud recovery |
| **Password recovery** | ⏳ Deferred | Users lose access if forgotten (acceptable trade-off for privacy) |
| **Multi-device sync** | ⏳ Deferred | Requires key distribution; Phase 2+ decision |
| **Zero-knowledge proof** | ❌ Excluded | Unnecessary complexity for MVP |
| **Hardware key attestation** | ⏳ Deferred | Apple Secure Enclave integration (Phase 2+) |

---

## Success Metrics (P2)

### Formation Intelligence Perspective
- ✅ P3+ pillars can confidently reference user's actual story in prayers/prompts
- ✅ User feels their data is sacred and protected
- ✅ No data leaks or unauthorized access in Phase 2 beta
- ✅ Encryption transparent to user (password set once, then forgotten)

### Technical Perspective
- ✅ All moments encrypted before Supabase sync
- ✅ Decryption latency <200ms on device
- ✅ No plaintext moments ever stored server-side
- ✅ Argon2id key derivation completes in <2s during onboarding

---

## Open Questions & TBD

1. **Password recovery flow?** (Deferred to Phase 2)
   - User forgets password → can't access data → acceptable?
   - Recovery mechanism would compromise E2E (not acceptable)

2. **Multi-device support?** (Deferred to Phase 2)
   - User wants moments on iPhone + iPad?
   - Requires key distribution strategy (encrypted key shared across devices?)

3. **Key rotation?** (Deferred to Phase 2)
   - User wants to change password?
   - Current design: single key per user (rotation would re-encrypt all data)

4. **Search index security?** (To be designed in P6)
   - Search index itself encrypted or plaintext?
   - How does encrypted search index prevent user inference attacks?

---

## Next: How P2 Prepares P3

Once P2 is implemented, P3 (Soaking/Prayer/Prompts) can be articulated as:
- **What P3 is:** A contemplative response layer that uses encrypted context from P0–P2
- **What P3 learns:** User's reflection patterns, prayer preferences, spiritual tone
- **How P3 prepares P4:** By capturing reflection responses, P3 gives P4 rich context for journal synthesis

---

**Ready to lock P2 Formation Intelligence and move to P3?**

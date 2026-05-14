# Pillar: Authentication & Account Management

**Pillar:** Authentication | **Updated:** May 14, 2026 | **Status:** Strategy Locked

---

## 1. Overview

- **Purpose:** Authenticate users, manage account access, handle password recovery, and protect account security
- **Scope:** Login, sign-up account creation, forgot password, password reset, account recovery, sign out
- **Status:** Strategy locked, ready for implementation ticket creation
- **Access Pattern:** Login screen (app open if not authenticated) OR Settings (for logged-in password management)
- **Note:** This is a **prerequisite pillar**, not part of the Formation Intelligence learning system. It enables P0–P8 by authenticating users.

---

## 2. Product Purpose

**Why Authentication matters:**
- Users need to securely access their sacred moments (only they, with their password/account)
- Dwellable asks intimate spiritual questions → data must be protected from unauthorized access
- Account recovery (forgot password) is a trust mechanism — users need confidence they can regain access if needed
- Authentication is the foundation: without it, Formation Intelligence pillars can't function

---

## 3. Formation Intelligence System

**What Pillar Auth Is (in the Formation Intelligence System):**

**Not a learning pillar. A prerequisite pillar.**

Authentication sits *outside* the Formation Intelligence system. It enables P0–P8 by ensuring only authenticated users can access their moments. No spiritual data is captured or inferred at authentication.

**What Auth Does Learn (Implicitly):**
- User's email (identity)
- Whether user values password security (by changing passwords)
- Whether user trusts account recovery flows (by resetting passwords successfully)
- Failed login patterns (brute-force attempts, forgotten credentials)

**But Auth Does NOT Learn:**
- Spiritual maturity, intent, or formation patterns
- User's archetype (Jotter, Venter, Processor)
- Emotional tone or themes
- Prayer engagement or dwelling patterns

**Formation Intelligence Value:**
- Auth's only role: *Gatekeeper*. Ensure only authenticated users reach P0–P8.
- No data about the user's spiritual journey flows through Auth
- Auth feeds no intelligence downstream to other pillars
- Auth is purely protective, not formative

---

## 4. Success Criteria

**Qualitative:**
- [ ] Users can log in quickly (<5 seconds for returning users)
- [ ] Users who forget passwords can recover access without contacting support
- [ ] Failed login attempts show helpful, not alarming, error messages
- [ ] Account creation (in onboarding) and login flows feel cohesive

**Quantitative:**
- [ ] >95% successful login rate on first attempt (correct credentials)
- [ ] <1% failed login rate due to app errors (not user error)
- [ ] >80% successful password reset rate (user completes flow)
- [ ] <5% of support requests about "I forgot my password"
- [ ] >99% uptime on authentication service (Supabase auth)

---

## 5. Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Auth provider** | Supabase (JWT-based) | Simple, serverless, integrates with E2E encryption (P2) |
| **Session management** | JWT tokens (client-side) | Stateless; scales without backend session store |
| **Password strength** | 8+ chars, mixed case, number, symbol | Sufficient for E2E encryption key derivation |
| **Account lockout (MVP)** | None; unlimited retries | E2E model: we can't unlock users; rate limiting deferred to Phase 2 |
| **Password reset delivery** | Email with JWT token | Secure, no password exposed in email, 30-min expiry |
| **Sign out scope** | App-only (not multi-device) | MVP: single-device only; multi-device sign-out deferred to Phase 2 |
| **Account deletion** | Soft-delete with 30-day recovery window (Phase 2) | MVP: users can't delete accounts (contact support); Phase 2 implements self-service deletion with recovery period |
| **Email verification** | Optional on sign-up (deferred) | MVP: skip email verification to reduce friction; add in Phase 2 |

---

## 6. Authentication Detailed Specs — MVP

### Login Screen (Entry Point: App Open If Not Authenticated)

```
┌────────────────────────────┐
│ DWELLABLE LOGIN            │
├────────────────────────────┤
│ Sign in to your account    │
│                            │
│ Email: [____________]      │
│ Password: [____________]   │
│                            │
│ [Sign In]                  │
│                            │
│ ─────────────────────────  │
│ New to Dwellable?          │
│ [Create Account]           │  [Link → P0 Onboarding]
│                            │
│ Forgot password?           │  [Link → Password Reset]
│ Can't find your account?   │  [Link → Account Recovery]
└────────────────────────────┘
```

**Sign In Flow:**
1. User enters email + password
2. Validation: Email format check, password not empty
3. Authentication: Supabase JWT auth (verify credentials against auth table)
4. If credentials correct:
   - JWT token stored locally (secure storage, expires ~7 days)
   - EncryptionManager derives encryption key from password (Argon2id, ~1 second delay)
   - App unlocks → navigates to P0 (if first time) or Today tab (if returning)
5. If credentials incorrect:
   - Show error: "Email or password incorrect. Try again."
   - Allow retry (no account lockout)
6. If account doesn't exist:
   - Show: "No account found. Create one?" with link to P0 Onboarding

**"Create Account" Link:**
- Routes to P0 Onboarding (Screen 1: Welcome)

**"Forgot password?" Link:**
- Routes to Password Reset Flow (see below)

**"Can't find your account?" Link:**
- Routes to Account Recovery Flow (see below)

### Account Creation (Part of P0 Onboarding, Screen 5)

```
┌────────────────────────────┐
│ CREATE YOUR ACCOUNT        │
├────────────────────────────┤
│ Email: [____________]      │
│ Password: [____________]   │
│ Confirm: [____________]    │
│                            │
│ Password strength: ██░�░░  │
│ ✓ 8+ characters           │
│ ✓ Upper & lower case      │
│ ✓ Number                  │
│ ✓ Symbol                  │
│                            │
│ ☑ I agree to Terms        │
│                            │
│ [Create Account]           │
└────────────────────────────┘
```

**Account Creation (During Onboarding):**
1. User enters email + password (+ confirmation)
2. Validation:
   - Email: Format check + uniqueness check (not already in Supabase)
   - Password: 8+ chars, mixed case, number, symbol, passwords match
3. If validation fails: Show specific error ("Password too weak", "Email already in use", etc.)
4. If validation passes:
   - Supabase creates auth user (email + hashed password)
   - JWT token issued + stored locally
   - EncryptionManager derives encryption key from password (Argon2id)
   - User proceeds to P0 Screen 6 (Privacy confirmation)
5. **Critical:** User cannot proceed without capturing first moment (P0 Screen 7 mandate)

### Forgot Password Flow

**Entry point:** Login screen → "Forgot password?" link

```
┌────────────────────────────┐
│ RESET PASSWORD             │
├────────────────────────────┤
│ Enter the email address    │
│ for your Dwellable account │
│                            │
│ Email: [____________]      │
│                            │
│ [Send Reset Link]          │
│                            │
│ Remember your password?    │
│ [Back to Login]            │  [Link]
└────────────────────────────┘
```

**Step 1: Email Entry**
- User enters email address
- Validation: Email format + account exists check
- If account doesn't exist: Show "No account found with that email. Create one instead?" (link to P0)
- If valid: Show confirmation message, send email

**Step 2: Password Reset Email (Sent by Backend)**
- Supabase generates secure reset token:
  - Format: JWT with payload (user_id, email, purpose="password_reset", timestamp)
  - Expiry: 30 minutes
  - Signature: Signed with secret key
- Email sent to user's email address:
  - Subject: "Reset your Dwellable password"
  - Body: "Click the link below to reset your password. This link expires in 30 minutes."
  - Link: `https://dwellable.app/auth/reset?token={JWT_TOKEN}`
  - Fallback: "Can't click? Copy and paste this link: [URL]"
  - Token in URL (not in email body; URL already uses HTTPS)

**Step 3: Reset Link Clicked (Email → App)**
- User clicks email link (browser opens)
- Link redirects to Dwellable domain
- App receives deep link: `dwellable://auth/reset?token={JWT_TOKEN}`
- Token validation:
  - JWT signature verified (secret key)
  - Expiry checked (30 minutes)
  - Purpose verified (password_reset)
- If invalid/expired: Show "This reset link has expired. Request a new one." (link back to forgot password)
- If valid: Navigate to New Password screen

**Step 4: New Password Entry**

```
┌────────────────────────────┐
│ CREATE NEW PASSWORD        │
├────────────────────────────┤
│ New Password: [____________]
│ Confirm: [____________]    │
│                            │
│ Password strength: ██░░░░  │
│ ✓ 8+ characters           │
│ ✓ Upper & lower case      │
│ ✓ Number                  │
│ ✓ Symbol                  │
│                            │
│ [Reset Password]           │
│ [Cancel]                   │
└────────────────────────────┘
```

- User enters new password + confirmation
- Validation: 8+ chars, mixed case, number, symbol, passwords match
- If validation fails: Show specific error
- If validation passes: Send to backend for update

**Step 5: Backend Update & Confirmation**
- Backend validates reset token again (security check)
- Updates Supabase auth table (new password hash)
- Shows confirmation: "✅ Password reset successfully. Redirecting to login..."
- Redirects to login screen after 2 seconds
- User logs in with new password → EncryptionManager derives new encryption key

**Critical P2 Implication:**
- Old encrypted moments remain encrypted with old key (no re-encryption)
- New captures encrypt with new key derivation
- This asymmetry is acceptable (Phase 2 implements key rotation)

### Password Change (Settings, Logged-In Users)

**Entry point:** Settings → Security & Privacy → "Change Password"

```
┌────────────────────────────┐
│ CHANGE PASSWORD            │
├────────────────────────────┤
│ Current Password:          │
│ [____________]             │
│                            │
│ New Password:              │
│ [____________]             │
│ Confirm: [____________]    │
│                            │
│ Password strength: ██░�░░  │
│                            │
│ [Change Password]          │
│ [Cancel]                   │
└────────────────────────────┘
```

**Step 1: Current Password Verification**
- User enters current password (to prove identity)
- Validation: Hash password locally (Argon2id) + compare against stored hash
- If incorrect: Show "Current password is incorrect. Try again."
- If correct: Proceed

**Step 2: New Password Entry**
- User enters new password + confirmation
- Validation: 8+ chars, mixed case, number, symbol, not same as current, passwords match
- If fails: Show specific error

**Step 3: Backend Update & Confirmation**
- Backend validates reset token again
- Updates Supabase auth table (new password hash)
- EncryptionManager re-derives encryption key from new password (1 second delay)
- Shows confirmation: "✅ Password changed successfully"
- Dismiss modal, return to Settings

### Sign Out (Settings)

**Entry point:** Settings → Account & Profile → "Sign Out"

```
┌────────────────────────────┐
│ Sign out of Dwellable?     │
│                            │
│ [Cancel]  [Sign Out]       │
└────────────────────────────┘
```

**Sign Out Flow:**
1. User taps "Sign Out" in Settings
2. Confirmation modal: "Sign out of Dwellable?"
3. If confirmed:
   - Clear JWT token from local storage
   - Clear cached user data
   - Clear cached encryption key from memory (not Keychain)
   - Navigate to login screen
4. If cancelled: Return to Settings

**Multi-Device Note:** MVP = single device only. Signing out on one device doesn't sign out on other devices (deferred to Phase 2).

### Account Recovery (Email Verification) — MVP Deferred

**Entry point:** Login screen → "Can't find your account?" link

**Current MVP Status:** Deferred feature (not blocking)

**What it will do (post-MVP):**
- User enters email
- System sends "account recovery" email if no reset token exists
- Email contains link to either reset password (if they remember password is lost) or verify identity (security questions, etc.)
- This is a safety net for users who've lost email access or can't remember if they created an account

**MVP Alternative:**
- Direct them to support email: "Contact support@dwellable.com for help recovering your account"

### Account Deletion — Phase 2 Specification

**Entry point:** Settings → Account & Profile → "Delete Account" (deferred, not in MVP)

**MVP Status:** Deferred to Phase 2 (not blocking launch)

**Why Deferred:**
- Requires robust soft-delete + recovery window implementation (30-day recovery)
- Legal implications (data retention, GDPR compliance, deletion confirmation)
- UX complexity (must be clear and irreversible-sounding, but recoverable)
- Not critical for MVP launch; users can request deletion via support

**What Account Deletion Will Do (Phase 2):**

```
┌────────────────────────────┐
│ DELETE ACCOUNT             │
├────────────────────────────┤
│ ⚠️ This cannot be undone   │
│                            │
│ Deleting your account will:│
│ • Remove all your moments  │
│ • Remove your journals     │
│ • Remove your account data │
│                            │
│ You have 30 days to change │
│ your mind before permanent │
│ deletion.                  │
│                            │
│ [Cancel]  [Delete Account] │
└────────────────────────────┘
```

**Step 1: Confirmation Modal**
- Show warning: "Deleting your account cannot be undone"
- Explain consequences: "All moments, journals, and account data will be deleted"
- Mention recovery: "You have 30 days to restore your account. After that, permanent deletion is final."
- Two buttons: Cancel (dismiss) or Delete Account (confirm)

**Step 2: Identity Verification (Optional but Recommended)**
- Ask for current password confirmation (proof of identity)
- Prevents accidental deletion via device left unlocked
- Show password field with note: "Confirm your password to proceed"

**Step 3: Soft-Delete Execution (Day 0)**
- Backend marks account as `deleted: true` with timestamp
- Supabase sets `deleted_at` timestamp
- All user's moments flagged as `deleted: true`
- All user's encryption keys marked inactive (but not destroyed)
- Email marked as "in recovery state" (blocked from new signups)
- User session terminated (sign out)
- Show confirmation: "Your account is queued for deletion"

**Step 4: 30-Day Recovery Window (Days 1-30)**
- Account data remains encrypted in Supabase (not accessible)
- Email status: "In recovery" (can't sign up with this email)
- If user tries to log in: Show deleted account screen

```
┌────────────────────────────┐
│ ACCOUNT DELETED            │
├────────────────────────────┤
│ Your account is scheduled  │
│ for permanent deletion.    │
│                            │
│ You have until [DATE] to   │
│ restore your account and   │
│ recover all your moments.  │
│                            │
│ [Restore Account]          │
│ [Create New Account]       │
│ [Contact Support]          │
└────────────────────────────┘
```

- If user tries to sign up with deleted email: Show "This email is associated with a deleted account. [Restore that account] or use a different email."

**Step 5: Restoration (During Days 1-30)**
- User taps "Restore Account" from deleted account screen
- Routes to recovery flow

```
┌────────────────────────────┐
│ RESTORE YOUR ACCOUNT       │
├────────────────────────────┤
│ Email: [____________]      │
│ Password: [____________]   │
│                            │
│ [Restore Account]          │
│ [Cancel]                   │
└────────────────────────────┘
```

**Restore Flow:**
- User enters email + password (identity verification)
- Backend validates credentials against auth table
- If credentials correct:
  - Account flags reset: `deleted: false`, `deleted_at: null`
  - Email status reset to "active"
  - Encryption keys marked active
  - User logs in successfully
  - Show confirmation: "✅ Your account has been restored. All your moments are safe."
- If credentials incorrect: Show "Email or password incorrect. Try again."

**Step 6: Hard-Delete (Day 31+)**
- Hard-delete cronjob runs at Day 31
- Permanently deletes all account data from Supabase
- Permanently destroys encryption keys
- Email status: "Available" (can now be used for new account creation)
- No recovery possible after this point

### Email State Transitions During Account Deletion

```
┌─────────────────────────────────────────────────────────┐
│ EMAIL STATE LIFECYCLE DURING ACCOUNT DELETION           │
├─────────────────────────────────────────────────────────┤
│                                                         │
│ User deletes account → Soft-delete (Day 0)            │
│         ↓                                              │
│ EMAIL STATE: "ACTIVE" → "IN RECOVERY"                 │
│         ↓                                              │
│ Days 1-30: Can restore account with email + password  │
│         ↓                                              │
│ Day 31: Hard-delete cronjob runs                      │
│         ↓                                              │
│ EMAIL STATE: "IN RECOVERY" → "AVAILABLE"              │
│         ↓                                              │
│ Day 31+: Can create NEW account with this email       │
│         (completely fresh account, no prior data)     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Email Behavior by State:**

| Email State | Days | Can Log In? | Can Sign Up? | Can Restore? |
|-------------|------|------------|-------------|-------------|
| **ACTIVE** | Day 0 | Yes | Yes | N/A |
| **IN RECOVERY** | Days 1-30 | No (shows deleted account screen) | No (blocked; offer restoration) | Yes |
| **AVAILABLE** | Day 31+ | N/A (deleted) | Yes (creates fresh account) | No |

**Encryption Key Handling (P2 Implication):**
- During soft-delete: Encryption keys marked inactive (not deleted from Keychain)
- If account restored: Keys reactivated automatically (user can decrypt moments)
- If 30 days expire: Encryption keys deleted permanently (irreversible)
- Data loss: Even if Supabase had plaintext (which it doesn't), encryption keys are gone → no recovery possible

**Legal & Compliance:**
- GDPR: User has right to deletion; 30-day recovery window allows restoration
- Data retention: After 30 days, all data purged (encrypted backups also deleted)
- User consent: Must explicitly click "Delete Account" to proceed (not accidental)
- Audit trail: Log deletion request + timestamp for compliance

**Post-Phase 2 Enhancement:**
- Email verification before hard-delete: "Your account will be permanently deleted in 7 days. [Undo]"
- Export data before deletion: Let user download all moments as JSON/PDF before hard-delete

---

## 7. Alternatives Considered (Not Chosen)

| Alternative | Why Considered | Why Not Chosen |
|-------------|-----------------|-----------------|
| **Username instead of email** | Common auth pattern | Email is account identifier; username adds complexity; email + password simpler |
| **Biometric auth (Face ID/Touch ID)** | Convenient, fast | Requires secure key storage in Keychain; complexity deferred to Phase 2 |
| **Multi-factor authentication** | More secure | Adds friction; deferred to Phase 2 for security-conscious users |
| **OAuth / social login** | Reduces password burden | Adds external dependency; doesn't align with "your data is yours alone" messaging |
| **Account lockout after N attempts** | Standard security pattern | Conflicts with E2E model (we can't verify identity without password to unlock); rate limiting deferred to Phase 2 |
| **Email verification on sign-up** | Prevents fake emails | Adds friction; MVP prioritizes onboarding speed; verify in Phase 2 |
| **Password complexity requirements sent via email** | Transparent | Exposes password requirements in email body; show in app instead |
| **Passwordless auth (magic links)** | Reduces password burden | Adds backend complexity (token generation, email delivery); password + E2E encryption simpler |

---

## 8. Metrics to Track

| Metric | Definition | Success Target |
|--------|-----------|-----------------|
| **Sign-up completion rate** | % of users who complete account creation (P0 Screen 5) | >85% |
| **Login success rate (first attempt)** | % of users who log in successfully with correct credentials on first try | >95% |
| **Login error rate** | % of login attempts that fail due to app error (not user error) | <1% |
| **Password reset completion rate** | % of users who click reset email → complete password reset | >80% |
| **Password reset email delivery** | % of reset emails successfully delivered | >99% |
| **Reset token expiry rate** | % of users whose reset token expires before they use it | <5% |
| **Account recovery inquiries** | # of support requests about account access / recovery | <5% of users |
| **Password change rate** | % of users who change password after sign-up | >10% within 90 days |
| **Auth service uptime** | % of time authentication service is available | >99.9% |
| **Failed login retry rate** | % of users who retry after failed login | >70% (shows persistence) |

---

## 9. Implementation Approach

**Phase 1 (MVP Launch):**
- [ ] Wire Supabase auth (JWT tokens, email/password authentication)
- [ ] Build Login screen
  - Email + password input fields
  - Sign In button (validation + error handling)
  - Links to Create Account (→ P0), Forgot Password, Account Recovery
  - Show/hide password toggle
- [ ] Build Account Creation (P0 Screen 5 integration)
  - Email + password + confirmation fields
  - Password strength indicator (visual feedback)
  - Validation + specific error messages
  - Agree to Terms checkbox
- [ ] Build Forgot Password flow
  - Email entry screen
  - Backend email sending (Supabase email function or SendGrid)
  - Reset link handling (deep link + token validation)
  - New password entry screen
  - Confirmation + redirect to login
- [ ] Build Password Change (Settings integration)
  - Current password verification
  - New password entry + confirmation
  - Validation + confirmation
- [ ] Build Sign Out (Settings integration)
  - Confirmation modal
  - Token cleanup + navigation to login
- [ ] Wire JWT token storage (secure, encrypted)
- [ ] Wire encryption key derivation (EncryptionManager + Argon2id)
- [ ] Test on device (iPhone 13+)

**Phase 2 (Post-MVP):**
- [ ] Email verification on sign-up (reduce fake accounts)
- [ ] Biometric unlock (Face ID / Touch ID)
- [ ] Account recovery (email verification flow)
- [ ] Rate limiting (5 failed attempts → cooldown)
- [ ] Multi-device sign out (sign out everywhere)
- [ ] Account deletion (soft-delete with 30-day recovery + restoration)
  - [ ] Confirmation modal with identity verification
  - [ ] Soft-delete flag + 30-day recovery window
  - [ ] Restoration flow (during recovery window)
  - [ ] Permanent hard-delete (after 30 days)
  - [ ] Encryption key cleanup (marked inactive on soft-delete, destroyed on hard-delete)
- [ ] Multi-factor authentication (optional, for security-conscious users)
- [ ] Pre-deletion data export (let users download moments as JSON/PDF)

---

## 10. Tickets to Create

| Ticket | Title | Effort | Dependencies |
|--------|-------|--------|--------------|
| T-XXX | Build: Supabase Auth Integration (JWT, email/password) | M | Supabase project setup |
| T-XXX | Build: Login Screen (email + password + validation) | M | T-XXX (auth) |
| T-XXX | Build: Account Creation Screen (P0 Screen 5 integration) | M | T-XXX (auth), P0 design |
| T-XXX | Build: Forgot Password Flow (email + reset link + new password) | L | T-XXX (auth), email service (SendGrid/Supabase) |
| T-XXX | Build: Password Change Flow (Settings integration) | M | T-XXX (auth), Settings pillar |
| T-XXX | Build: Sign Out Flow (Settings integration) | S | T-XXX (auth), Settings pillar |
| T-XXX | Feature: Show/Hide Password Toggle | S | T-XXX (login) |
| T-XXX | Feature: Password Strength Indicator | S | T-XXX (account creation) |
| T-XXX | Feature: Email Link Handling (Deep Link to Reset Flow) | M | T-XXX (forgot password) |
| T-XXX | Wire: EncryptionManager Key Derivation (Argon2id) | M | T-062 (E2E encryption), T-XXX (account creation) |
| T-XXX | Wire: JWT Token Storage (Secure, Encrypted) | M | T-XXX (auth) |
| T-XXX | Test: Auth Flows on Device (iPhone 13+) | M | All auth tickets |

| T-XXX (Post-MVP) | Feature: Account Deletion (soft-delete + 30-day recovery) | M | T-XXX (auth), Settings pillar |
| T-XXX (Post-MVP) | Feature: Account Restoration (during 30-day window) | S | T-XXX (account deletion) |
| T-XXX (Post-MVP) | Feature: Pre-Deletion Data Export (JSON/PDF) | M | T-XXX (account deletion) |
| T-XXX (Post-MVP) | Feature: Hard-Delete Cleanup (30-day cronjob) | M | T-XXX (account deletion), Supabase setup |

**Estimated effort (MVP):** 12 tickets, ~90–120 hours (2.5–3 weeks, including testing)
**Estimated effort (Post-MVP account deletion):** 4 tickets, ~30–40 hours (1 week)

---

## 11. Risks & Constraints

| Risk | Impact | Mitigation |
|------|--------|-----------|
| **Password reset email fails to deliver** | Users locked out; can't reset password | Use reputable email service (Supabase/SendGrid); monitor delivery rates; add support fallback |
| **Reset token expires before user clicks link** | User must request new token; friction | 30-minute expiry is reasonable; add "Resend email" option on reset screen |
| **User forgets password after signup** | Can't log back in; data lost (E2E trade-off) | Warn during onboarding ("Remember your password!"); offer password reset via email |
| **Brute-force attacks on login** | Account compromised | No lockout MVP; Phase 2 implements rate limiting + suspicious-activity alerts |
| **Email/password exposed in logs** | Security leak | Never log passwords; hash before transmission; use HTTPS only |
| **JWT token compromised** | Attacker gains access | Use secure token storage (Keychain); short expiry (~7 days); implement token refresh |
| **Account creation rate limiting missing** | Spam accounts; database filled | Add rate limiting (1 account per email per hour); Phase 2 adds email verification |
| **Deep link handling fails** | Reset link in email doesn't work | Test deep links on real device; fallback to web-based reset (open Safari if app doesn't handle link) |
| **Multi-device sync broken** | Key derivation inconsistency | MVP: single-device only; document limitation; Phase 2 plans key distribution |
| **Encryption key derivation too slow** | UX freeze on login | Argon2id ~1 second acceptable; move to background thread if needed; test on slow devices |
| **Account deletion irreversible after 30 days** | User loses all data permanently | Implement clear warning ("30 days to restore") + multiple confirmation steps + data export option (Phase 2) |
| **Hard-delete cronjob fails** | Soft-deleted accounts remain in database | Monitor cronjob health; implement manual cleanup dashboard for admins; log deletions |
| **User deletes account, then tries to sign up with same email** | Email still marked deleted; confusion | During 30-day window: don't allow re-signup with deleted email; suggest restoration instead |
| **Encryption keys not destroyed on hard-delete** | Data potentially recoverable | Ensure Keychain entry deleted AND Supabase encryption keys marked destroyed; verify in audit trail |

---

## 12. Cross-Pillar Dependencies

- **Pillar 0 (Onboarding):** Account creation (Auth Screen 5) happens during P0; auth flows to P0 when user is new
- **Pillar 2 (Security & Privacy):** Password is used to derive encryption key (Argon2id); password reset must be careful about key re-derivation
- **Settings:** Password change + sign out accessible from Settings; auth must integrate with Settings gear icon
- **Supabase:** Auth depends on Supabase auth service; JWT token management
- **Email Service:** Password reset emails via Supabase email or SendGrid
- **EncryptionManager:** Password → key derivation; must sync with auth flows

---

## 13. Summary

| Aspect | Decision |
|--------|----------|
| **Goal** | Securely authenticate users and manage account access, enabling access to Formation Intelligence pillars |
| **Entry Point** | Login screen (app open if not authenticated) OR Settings (for logged-in users) |
| **MVP Flows** | Login \| Account Creation (P0) \| Forgot Password \| Password Change \| Sign Out |
| **Phase 2 Flows** | Account Deletion (soft-delete, 30-day recovery) \| Account Recovery (email verification) \| Biometric unlock |
| **Password Rules** | 8+ chars, mixed case, number, symbol |
| **Session Management** | JWT tokens (client-side, ~7 day expiry) |
| **Account Lockout** | None MVP; rate limiting Phase 2 |
| **Account Recovery (Password)** | Email-based password reset with 30-min expiry tokens |
| **Account Deletion** | Soft-delete with 30-day recovery window; hard-delete after 30 days |
| **Encryption Integration** | Password → Argon2id → encryption key (P2); keys marked inactive on delete, destroyed on hard-delete |
| **Success Metric** | >95% login success rate, >80% password reset completion, >90% account deletion confirmation rate |
| **Key Blocker** | Supabase auth setup + email service (SendGrid/Supabase) |

---

**Status:** Ready for ticket creation. All design decisions locked.

**Next:** Create implementation tickets (T-XXX–T-XXX), integrate with P0 Onboarding and Settings pillars.

# P0: Onboarding Flows — Model 1 vs Model 2

## Initial Decision Screen (Both Models)

```
┌─────────────────────────┐
│   Dwellable             │
│                         │
│  [ Sign Up ]            │
│                         │
│  Already have account?  │
│  [ Sign In ]            │
└─────────────────────────┘
```

If **Sign In** → Goes to Sign-In Screen (both models)
If **Sign Up** → Goes to Model 1 or Model 2 (see below)

---

## MODEL 1: Embedded Account Creation (Progressive)

```
Sign Up Button
     │
     ▼
┌──────────────────────────────┐
│ Carousel (4 cards)           │
│ [Problem] [Value] [Edu] [Trust]
│ ◀ Prev    Next ▶             │
│                              │
│ [Capture Moment]             │
└──────────────────────────────┘
     │
     ▼ (after final card OR user taps "Capture Moment")
┌──────────────────────────────┐
│ What should we call you?     │
│ [ __________ ]               │
│                              │
│ [Next]                       │
└──────────────────────────────┘
     │
     ▼
┌──────────────────────────────┐
│ What brings you to Dwellable?│
│ [ __________ ]               │
│                              │
│ [Next]                       │
└──────────────────────────────┘
     │
     ▼
┌──────────────────────────────┐
│ Secure your moments with God │
│                              │
│ Email: [ __________ ]        │
│ Password: [ __________ ]     │
│                              │
│ [Create Account & Capture]   │
└──────────────────────────────┘
     │
     ▼
┌──────────────────────────────┐
│ [Capture Screen]             │
│ Voice/text input             │
│                              │
│ [Save Moment]                │
└──────────────────────────────┘
     │
     ▼
┌──────────────────────────────┐
│ ✓ Moment saved               │
│                              │
│ [Go to Home] [Capture More]  │
└──────────────────────────────┘
```

**Key:** No separate account creation screen. Questions feel like part of capture flow.

---

## MODEL 2: Separate Account Creation Screen

```
Sign Up Button
     │
     ▼
┌──────────────────────────────┐
│ Carousel (4 cards)           │
│ [Problem] [Value] [Edu] [Trust]
│ ◀ Prev    Next ▶             │
│                              │
│ [Capture Moment]             │
└──────────────────────────────┘
     │
     ▼ (after final card OR user taps "Capture Moment")
┌──────────────────────────────┐
│ CREATE ACCOUNT               │
│                              │
│ Name: [ __________ ]         │
│ Email: [ __________ ]        │
│ Password: [ __________ ]     │
│                              │
│ What brings you to Dwellable?│
│ [ __________ ]               │
│                              │
│ [Create Account]             │
└──────────────────────────────┘
     │
     ▼
┌──────────────────────────────┐
│ [Capture Screen]             │
│ Voice/text input             │
│                              │
│ [Save Moment]                │
└──────────────────────────────┘
     │
     ▼
┌──────────────────────────────┐
│ ✓ Moment saved               │
│                              │
│ [Go to Home] [Capture More]  │
└──────────────────────────────┘
```

**Key:** Separate "CREATE ACCOUNT" visual break. All fields on one screen.

---

## Sign-In Screen (Both Models)

```
┌──────────────────────────────┐
│ SIGN IN                      │
│                              │
│ Email: [ __________ ]        │
│ Password: [ __________ ]     │
│                              │
│ [Sign In with Email]         │
│                              │
│ OR                           │
│                              │
│ [Sign in with Google]        │
│ [Sign in with Apple]         │
│                              │
│ Don't have account? [Sign Up]│
└──────────────────────────────┘
     │
     ▼
┌──────────────────────────────┐
│ [Home/Menu Bar]              │
│ (Already logged in)          │
└──────────────────────────────┘
```

---

## Comparison

| Aspect | Model 1 | Model 2 |
|--------|---------|---------|
| **Visual breaks** | Minimal (questions feel continuous) | One clear break (CREATE ACCOUNT screen) |
| **Form fields per screen** | 1-2 fields at a time | All fields at once (name, email, password, interest) |
| **Cognitive load** | Low (progressive) | Higher (all at once) |
| **Tone** | Conversational | Transactional |
| **Time to capture** | Slightly longer (more screens) | Slightly faster (one form) |
| **Drop-off risk** | Spread across multiple screens | Concentrated on one screen |

---

## Post-Signup UX (TBD)

After moment is saved, user lands at:
- **Option A:** Home menu bar (Today tab active, showing their moment)
- **Option B:** Celebration screen ("You've captured your first moment") → then home
- **Option C:** Prompt to explore galleries or settings → then home

Which feels right?

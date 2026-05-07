# Dwellable Search Strategy: OpenAI vs. Hugging Face Analysis

**Decision Date:** May 5, 2026  
**Context:** Semantic search for user's reflections (365 moments, 5 queries/day typical usage)

---

## Cost Reality Check

| Scenario | Queries/Month | Cost/Month | Cost/Year | Risk |
|----------|---------------|-----------|-----------|------|
| **Typical User** | 150 (5/day) | $0.55 | $6.65 | ✅ Negligible |
| **Heavy User** | 1,500 (50/day) | $5.50 | $66.50 | ✅ Still cheap |
| **Abuser** | 30,000 (1000/day) | $110 | $1,320 | ⚠️ Preventable with caps |
| **Bad Actor** | 300,000+ (unrestricted) | $1,100+ | $13,200+ | 🔴 UNACCEPTABLE |

**Key Insight:** Cost is only an issue if we allow unlimited queries. With rate limiting, OpenAI stays trivially cheap.

---

## Feature Comparison Matrix

| Feature | OpenAI | Hugging Face |
|---------|--------|--------------|
| **Cost (Typical User)** | $6.65/year | ~$0 (one-time download) |
| **Cost (Heavy User)** | $66.50/year | ~$0 |
| **Cost (Abuser - Unguarded)** | $13,200+/year | ~$0 |
| **First Search Latency** | <200ms | 1-4 minutes (first time) |
| **Subsequent Searches** | <200ms | <200ms (cached) |
| **Operational Complexity** | Low (managed service) | High (local model management) |
| **Model Updates** | Automatic (no action needed) | Manual (requires deployment) |
| **Requires Internet** | Yes | No (fully offline) |
| **Battery Impact** | Minimal (cloud compute) | High (device compute on first search) |
| **Storage Required** | 0 KB | 200-500 MB on device |
| **Privacy** | Queries sent to OpenAI | All local (zero data leaving device) |
| **Scalability** | Unlimited (pay per query) | Limited by device capabilities |
| **Abuse Surface** | High (if unguarded) | Low (device limits are natural brake) |

---

## OpenAI: Safeguard Architecture at Scale

### Layer 1: Per-User Rate Limiting
```
Max queries per user per day: 50 (covers heavy usage, prevents abuse)
Monthly budget per user: $10 (fail-safe cap)
Action on breach: 
  - Notify user
  - Require explicit opt-in to exceed quota
  - Log incident for review
```

**Rationale:** 50 queries/day = ~$5.50/month (heavy usage), anything beyond is suspicious.

### Layer 2: Anomaly Detection
```
Detection triggers:
  - Query count spike (>3x baseline in single hour)
  - Repeated identical queries (indicates automation)
  - Queries from multiple IPs on same account (account compromise)
  - Query rate during off-hours (3am-5am recurring pattern)

Response:
  - Temporary rate limit (5 queries/hour)
  - Send alert to user
  - Require re-auth if IP changed
  - Log to security audit trail
```

### Layer 3: Team-Level Spend Cap
```
Total monthly OpenAI spend across all users: $5,000
Threshold alert: When spending reaches 80% ($4,000)
Hard stop: At 100% - all searches disabled until next month
Escalation: Notify Kell to investigate unusual patterns
```

**Rationale:** Even if 1,000 users were all abusing ($1,320/year each), team cap prevents catastrophic spend.

### Layer 4: Query Audit Trail
```
Log all searches:
  - User ID
  - Timestamp
  - Query size (tokens)
  - Result count
  - Latency
  - Cost

Monthly review: Identify outliers, unusual patterns
Report: Sent to Kell on 1st of month
```

---

## Hugging Face: Local Model Management

### Architecture: On-Device Model Storage

**Initial Download (Onboarding):**
```
1. User completes signup
2. App detects first search action
3. Prompt: "Download offline search engine? (200MB, 3-5 minutes)"
4. User confirms
5. Background download + cache to device
6. Subsequent searches use cached model (instant)
```

**Storage:**
- Model file: 200-500 MB (depending on model choice)
- Index cache: 50-100 MB (per-user reflection index)
- Total per user: ~300-600 MB (acceptable for most iOS devices)

**Model Updates:**
```
Check frequency: Monthly (on app launch)
If new model available:
  - Notify user
  - Download in background (on WiFi + plugged in)
  - Swap old → new when complete
  - No user action required

Fallback: If update fails, continue using cached model
```

**Performance Characteristics:**
```
First search (model load):     1-4 minutes
Subsequent searches (cached):  <200ms
Device impact:
  - CPU: Peak 80-90% for 30-60s during load, then <5%
  - Battery: ~5-10% drain per search (on first load), <1% after
  - Memory: 300-400 MB resident (manageable)
```

**Privacy Win:**
- Zero data leaves device
- User's reflections never sent anywhere
- Search queries stay on device
- No cloud dependency = works offline

---

## Implementation: Model Download During Onboarding

### Timeline: When to Download

**Option A: Immediate (Right After Signup)**
```
Signup → Welcome onboarding screens → 
"Let's set up offline search" → Download screen → Gallery view
Time impact: +5 minutes to onboarding (noticeable)
Advantage: Search ready from day 1
Disadvantage: Friction in signup flow
```

**Option B: Lazy Load (First Time User Searches)**
```
Signup → Onboarding → Gallery → User taps "Search" → 
Prompt: "Download offline search engine?" → Download → Results
Time impact: Delayed until first search need
Advantage: Zero friction in signup
Disadvantage: 4-5 minute wait on first search (bad UX)
```

**Option C: Background (During First 24 Hours)**
```
Signup → Onboarding complete → App checks: "Is device on WiFi + plugged in?"
If yes: Download model in background (silent)
If no: Prompt user to plug in on next WiFi connection
Result: Search ready by next day with zero user friction
Advantage: Best UX + ensures ready state
Disadvantage: Most complex implementation
```

### UX Flow: Option C (Recommended)

```
[Day 1 - Signup]
User completes signup → Onboarding done
App: "Background setup in progress (offline search model)"
Status: "Installing... 45% complete" (badge, not modal)

[Day 1 - Evening]
User plugs in device + connects to WiFi
Background download completes silently
Local notification: "You're all set! Search now works offline."

[Day 2+]
User opens app → Gallery view with Search available
Tap search → Instant results (model ready)
```

**Storage & Network:**
- Download size: 200-500 MB (requires WiFi, not cellular)
- Time: 3-5 minutes on typical home WiFi
- Retry logic: If download interrupted, resume on next WiFi connection
- User control: Can manually re-download anytime from Settings → Privacy

---

## Decision Framework

### Choose OpenAI if:
✅ Want simple, minimal operational overhead  
✅ OK with $6-70/year per user in cost  
✅ Want instant search (no 1-4 minute waits)  
✅ Can implement + maintain rate limiting / safeguards  
✅ Users expect cloud features (updates, no storage)

### Choose Hugging Face if:
✅ Want zero cloud dependencies (offline-first)  
✅ Want zero per-query costs (battery/storage instead)  
✅ Want maximum privacy (data never leaves device)  
✅ Can handle 1-4 minute model download friction  
✅ Can manage local model updates + versioning  
✅ Users are in low-bandwidth regions or value offline capability

---

## Recommendation for Dwellable

**Hybrid Approach (Best of Both):**

1. **Ship with Hugging Face** (Phase 2 MVP):
   - Download during onboarding (Option C - silent background)
   - Zero cost, maximum privacy (brand story)
   - Works offline (competitive advantage)
   - Users can search without internet

2. **Add OpenAI as Optional Premium** (Phase 2+):
   - "Faster search" ($0.99/month or one-time)
   - Rate-limited (50 queries/day max)
   - Instant results vs. 200ms cached
   - For power users who want additional safeguards

3. **Safeguards in Both:**
   - Per-user daily limit (50 queries)
   - Monthly spend cap
   - Audit logging
   - Anomaly detection

**Why This Works:**
- Dwellable brand = privacy-first (Hugging Face as default)
- Power users get premium speed option (OpenAI)
- Cost remains trivial (<$70/year per power user)
- No bad-actor abuse vectors

---

## Open Questions

1. **Model Choice:** text-embedding-3-small or similar? Check Hugging Face offerings (SBERT, FastText)
2. **Index Strategy:** Pre-compute on user's reflections, or real-time search?
3. **Update Cadence:** How often to refresh embeddings when user adds new reflections?
4. **Storage Limits:** What if user hits device storage limits?
5. **Offline Sync:** If user searches while offline, sync results when back online?

---

**Next Step:** Validate model size + performance on iOS device (iPhone 13 baseline)

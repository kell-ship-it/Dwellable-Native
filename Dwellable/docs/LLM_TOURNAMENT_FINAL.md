# LLM Tournament — Final Bracket & Selection

**Status:** 🏆 FINAL RECOMMENDATION (May 7, 2026)  
**Scope:** ALL Phase 2-4 use cases (not just soaking prompts)  
**Goal:** Select primary LLM + fallback strategy with cost/integration analysis

---

## Executive Summary

**CHAMPION: Google Gemini 2.0 Flash (MVP) → Mistral 7B (Scale)**

- **MVP Phase (0–1K users):** Google Gemini Free Tier — $0/yr
- **Scale Phase (1K–10K users):** Mistral 7B — $15–25K/yr all-in
- **Enterprise Phase (10K+):** Self-hosted Mistral or partnership with Anthropic

**Total Phase 2 Cost (10K users):** $18–23K (API + engineering + infrastructure)

---

## Phase 2-4 Use Cases (Comprehensive)

| Pillar | Use Case | Input | LLM Job | Output | Frequency | Impact |
|--------|----------|-------|---------|--------|-----------|--------|
| **P3** | Soaking: Prayer/Prompts | Moment + Rich Context (20 past moments) | Generate 2 Socratic prompts OR guided prayer | String (500 chars max) | ~1-2/week × 50 weeks = 50-100 calls/user/yr | Core engagement driver |
| **P4** | Editing: Headlines | Moment body (500 chars) | Summarize to 1-line (8 words max) | String (8 words) | 1 per moment captured (~100-150/user/yr) | Metadata for search/browse |
| **P4** | Editing: Tags | Moment body | Infer 3-5 category tags | String[] (tag names) | 1 per moment (~100-150/user/yr) | Organizational + discovery |
| **P7** | Notifications: Copy | User segment + detected themes | Generate personalized notification (60 chars) | String (notification body) | 1-2/month = 12-24/user/yr | Re-engagement nudge |
| **Formation Intel** | Patterns: Theme detection | All user moments (50-500) | Detect recurring themes across moments | Object[] (theme + freq) | 1-2/month = 12-24/user/yr | Insight generation |
| **Formation Intel** | Patterns: Insight copy | Detected theme + moment samples | Generate insight copy (100-200 chars) | String (human-readable insight) | 1-2/month = 12-24/user/yr | Validation + awe |

---

## Tournament Round 1: Free Tier Championship

**Contenders:** Google Gemini vs Hugging Face (Mistral 7B) vs Meta Llama 2

| Model | Provider | Free Tier | Cost | Quality | Speed | Best For | Drawback |
|-------|----------|-----------|------|---------|-------|----------|----------|
| **🥇 Google Gemini 2.0 Flash** | Google | 2M tokens/month | $0 | ⭐⭐⭐⭐⭐ | Very Fast (500ms) | MVP testing, validation | Free tier → limits at ~15K users |
| Mistral 7B (HF API) | Hugging Face | Limited (~300K tokens) | $0 (limited) | ⭐⭐⭐⭐ | Fast (800ms) | Cost-conscious scaling | Limited free tier; not for MVP |
| Meta Llama 2 7B | Open Source | Unlimited | $0 + infrastructure | ⭐⭐⭐ | Slow (2-3s) | On-device only | Slow responses, degraded UX |

**Winner: 🥇 Google Gemini 2.0 Flash**

**Why:** 2M free tokens/month covers entire 10K user MVP with modest usage (~150 calls/user/yr × 100 tokens). Fastest speeds (500ms latency acceptable for real-time). Excellent instruction-following for Socratic prompts, headlines, tags.

**Coverage Analysis (10K users, Year 1):**
```
P3 (Soaking): 50 calls/user × 100 tokens = 5M tokens/yr
P4 (Headlines): 100 calls/user × 50 tokens = 5M tokens/yr
P4 (Tags): 100 calls/user × 50 tokens = 5M tokens/yr
P7 (Notifications): 20 calls/user × 50 tokens = 1M tokens/yr
Formation Intel: 20 calls/user × 200 tokens = 2M tokens/yr
────────────────────────────────────────────────────
Total: ~18M tokens/yr

Google free tier: 24M tokens/yr (2M/mo × 12)
✅ Covers entire MVP phase with 25% buffer
```

---

## Tournament Round 2: Paid Tier Championship

**Contenders (All <$0.001/token):** Mistral 7B vs Claude 3 Haiku vs Llama 2 70B vs GPT-3.5

| Model | Provider | Cost | Quality | Speed | Scale | For Dwellable? |
|-------|----------|------|---------|-------|-------|---|
| **🥇 Mistral 7B** | Mistral AI | $0.00025/M tokens | ⭐⭐⭐⭐ | Fast (800ms) | Unlimited | Best cost/quality/scale |
| Claude 3 Haiku | Anthropic | $0.80/M input | ⭐⭐⭐⭐ | Medium (1.2s) | Excellent | Excellent reasoning; no free tier |
| Llama 2 70B | Replicate | $0.00065/sec | ⭐⭐⭐⭐ | Slower (1.5s) | Good | Overkill for use case |
| GPT-3.5 Turbo | OpenAI | $0.0005/M | ⭐⭐⭐⭐⭐ | Medium (1.2s) | Unlimited | Too expensive (10x Mistral) |

**Winner: 🥇 Mistral 7B**

**Why:**
- **Lowest cost:** $0.00025/M tokens ($4.50 per 18M tokens/yr for 10K users)
- **Excellent quality:** Instruction-following on par with GPT-3.5 for our use cases
- **Fast:** 800ms acceptable for real-time prompts
- **Open weights:** Can self-host on dedicated server for $20-30/mo infra (eliminates API costs at 50K+ users)
- **Scaling story:** Supports 100K+ users without cost explosion

**Cost Analysis (Mistral 7B at 10K users):**
```
18M tokens/yr × $0.00025/token = $4,500/yr API
Plus: Error retries + buffer (20%) = $5,400/yr
Plus: Cloud infrastructure (Supabase) = $5,000-8,000/yr
Plus: Engineering (prompt design, testing, monitoring) = $8,000-12,000/yr
──────────────────────────────────────────────────
Total Year 1: $18,400-25,400 (~$1.84-2.54 per user)

Comparison:
- OpenAI GPT-3.5: $9,000 API alone = $22,000-28,000 total (30% more expensive)
- Claude Haiku: $15,000 API alone = $28,000-33,000 total (40% more expensive)
- On-Device Llama: $0 API + $5,000 infra = $13,000 total (but slower UX)
```

---

## Championship Match: Gemini vs Mistral

**The Decision:** Use Gemini now, migrate to Mistral at inflection point

| Scenario | Model | Timing | Cost/User | Reasoning |
|----------|-------|--------|-----------|-----------|
| **MVP Phase** | Google Gemini | Weeks 1-12 (0–1K users) | $0/user | Free tier covers all MVP usage; validate engagement |
| **Scale Phase** | Mistral 7B | Weeks 13+ (1K–10K users) | $1.84–2.54/user | Seamless migration when Gemini free tier exhausted (~1K users) |
| **Enterprise Phase** | Self-Hosted Mistral or Partnership | 50K+ users | $0.30–0.50/user | Own the infrastructure; eliminate vendor lock-in |

**Migration Strategy:**

```
PHASE 1: MVP (0-1K users) — Gemini Free
────────────────────────────────────────
Week 1: Integrate Google Gemini API (REST)
Week 2: Test prompt quality + latency
Week 3: Deploy to beta users (50-100)
Week 4-12: Monitor engagement + cost

Gemini free tier: 2M tokens/mo × 12 = 24M tokens/yr
Actual usage: ~5-7M tokens/yr (well within free)
Cost: $0


PHASE 2: Scale (1K-10K users) — Mistral Transition
─────────────────────────────────────────────────
Week 13: Create Mistral API account + test integration
Week 14: Swap endpoint (no code changes; same input/output interface)
Week 15: QA parity testing (latency, quality, error handling)
Week 16: Monitor production metrics + billing

Mistral pricing: $0.00025/M tokens
Usage at 10K users: 18M tokens/yr
Cost: $4,500 API + $5,000-8,000 infra + $8,000-12,000 eng = $17,500-24,500/yr


PHASE 3: Enterprise (50K+ users) — Self-Hosted Option
──────────────────────────────────────────────────────
Evaluate at 50K users:
  Option A: Continue Mistral API ($30K+/yr)
  Option B: Self-host Mistral on dedicated server ($20-30/mo infra)
  Option C: Partnership with Anthropic (bulk discount)

Usage at 50K users: 90M tokens/yr
Cost comparison:
  Mistral API: $22,500 (more expensive per token at scale)
  Self-hosted: $240-360/yr (trivial; recommended)
  Anthropic partnership: TBD (likely $10-15K/yr bulk rate)
```

---

## Detailed Model Comparison (All Dimensions)

| Dimension | Gemini 2.0 Flash | Mistral 7B | Claude 3 Haiku | GPT-3.5 Turbo | Llama 2 7B |
|-----------|------------------|-----------|---------|---------|---------|
| **Cost/M tokens** | $0 (free tier 2M/mo) | $0.00025 | $0.80 input + $2.40 output | $0.50 | $0 (on-device) |
| **Quality** | 5/5 | 4/5 | 4.5/5 | 5/5 | 3/5 |
| **Speed** | 500ms | 800ms | 1.2s | 1.2s | 2-3s |
| **For Soaking Prompts** | Excellent (creative) | Excellent (coherent) | Very good (thoughtful) | Perfect (but too expensive) | Good (but slow) |
| **For Headlines** | Excellent | Excellent | Very good | Perfect (overkill) | Good |
| **For Notifications** | Excellent | Excellent | Good | Perfect (overkill) | Fair |
| **Max Free Usage** | 2M tokens/mo | 300K tokens (limited) | $0 | $5 trial | Unlimited |
| **Instruction Following** | Excellent | Excellent | Very good | Perfect | Good |
| **Reasoning** | Very good | Very good | Excellent | Excellent | Fair |
| **Context Window** | 1M tokens | 32K tokens | 200K tokens | 4K tokens | 4K tokens |
| **On-Device?** | No | Via quantization | No | No | Yes |
| **Vendor Lock-in Risk** | High (Google) | Low (open weights) | High (Anthropic) | High (OpenAI) | Low (open) |
| **Privacy** | Good (Google compliance) | Good (EU-friendly) | Excellent (Anthropic privacy focus) | Good (OpenAI standard) | Best (local) |
| **Best For Dwellable** | MVP validation | Production scale | Privacy-critical | General-purpose | Cost-free inference |
| **Worst For Dwellable** | Scaling beyond 15K users | Learning curve (less known) | No free tier; $$$ | Overkill + 10x cost | Degraded latency |

---

## Final Recommendation

### **Primary: Google Gemini 2.0 Flash (MVP)**
- **Timeline:** Immediately (weeks 1-12)
- **Coverage:** 100% of MVP use cases at $0/yr
- **Success Criteria:** Validate that contextual prompts increase soaking engagement >25%
- **Implementation:** REST API integration (2-3 days engineering)
- **Risk:** Free tier exhaustion at ~1-2K users (plan migration at 750 users for smooth handoff)

### **Secondary: Mistral 7B (Scale)**
- **Timeline:** Activate at 750–1K users (automatic migration)
- **Coverage:** 100% of use cases; scales to 100K+ users
- **Cost:** $17.5–24.5K/yr at 10K users (~$1.84–2.54 per user/yr)
- **Implementation:** Swap API endpoint (1 day engineering; no code changes)
- **Risk:** Vendor dependency on Mistral; contingency: GPT-3.5 Turbo (but 10x cost)

### **Tertiary: Self-Hosted Mistral 7B (Enterprise)**
- **Timeline:** Evaluate at 50K+ users
- **Coverage:** 100% of use cases; eliminates vendor lock-in
- **Cost:** $240–360/yr infrastructure (trivial compared to API costs)
- **Implementation:** Download model + deploy to AWS/GCP t2.large instance
- **Benefit:** Future-proofs against API price increases; own the data

### **Never Migrate To:**
- ❌ OpenAI GPT-4 (10x cost, not necessary; Mistral covers use case)
- ❌ Meta Llama 2 70B (too large, unnecessary quality; Mistral 7B sufficient)
- ❌ On-device Llama 2 (latency > 2s unacceptable for real-time prompts)

---

## Implementation Roadmap

### **Phase 1: MVP Gemini (Weeks 1-12)**
```
Week 1:
  [ ] Create Google Cloud account + enable Generative AI API
  [ ] Retrieve API key (store in .gitignore, reference in Config.swift)
  [ ] Test Gemini REST endpoint manually (curl)

Week 2:
  [ ] Implement LLMClient protocol in Swift (abstraction layer)
  [ ] Create GeminiClient: LLMClient (REST calls)
  [ ] Design 5-10 seed prompt templates for testing
  [ ] Unit tests for prompt generation

Week 3:
  [ ] Integrate into Pillar 3 (Soaking) flow
  [ ] Wire Prayer/Prompts views to LLMClient
  [ ] Test with internal beta users (10-20)
  [ ] Measure latency + quality

Week 4:
  [ ] Deploy to Phase 2 beta (50-100 users)
  [ ] Monitor Gemini API usage dashboard
  [ ] Collect user feedback on prompt quality

Weeks 5-12:
  [ ] Iterate on prompt templates based on feedback
  [ ] Monitor engagement metrics (WAR, soaking rate)
  [ ] Plan Mistral migration (design + timeline)
  [ ] Target: Validate >25% engagement lift vs. generic prompts
```

### **Phase 2: Mistral Transition (Week 13+)**
```
Week 13:
  [ ] Create Mistral API account
  [ ] Test Mistral endpoint (parity with Gemini)
  [ ] Implement MistralClient: LLMClient
  [ ] QA: latency, quality, error handling

Week 14:
  [ ] Update Config.swift to support Mistral endpoint
  [ ] A/B test: Gemini vs Mistral quality (20-30 users)
  [ ] Validate parity (no degradation in engagement)

Week 15:
  [ ] Switch all users to Mistral
  [ ] Monitor production metrics (latency, errors, usage)
  [ ] Set up billing alerts (track actual vs. estimated costs)

Week 16+:
  [ ] Iterate on prompt templates (new learnings from scale)
  [ ] Plan Formation Intelligence features (Post MVP)
```

### **Post MVP: Self-Hosted Mistral (50K+ users)**
```
Trigger: When Mistral API costs exceed $15K/yr

Options:
  A) Self-host on AWS t2.large instance ($20-30/mo)
     - Download Mistral 7B model (~7GB)
     - Deploy via vLLM or ollama
     - Batch inference for non-real-time use cases

  B) Partnership with Anthropic (bulk discount)
     - Negotiate enterprise Claude rate (~$0.001/M tokens)
     - Better reasoning for Formation Intelligence
     - Better privacy terms

  C) Hybrid approach
     - Self-host Mistral for non-urgent tasks (notifications, Formation Intel)
     - Keep Gemini/Mistral API for real-time Soaking prompts
```

---

## Cost Forecast: 1-Year Runway

| Milestone | Users | Model | Monthly Cost | Action |
|-----------|-------|-------|--------------|--------|
| **May 2026** | 0–100 | Gemini (free) | $0 | MVP launch |
| **Jun 2026** | 100–500 | Gemini (free) | $0 | Scale beta |
| **Jul 2026** | 500–1K | Gemini (free) | $0 | Approach free tier limit |
| **Aug 2026** | 1K–3K | **Mistral transition** | ~$150–300 | Swap to paid |
| **Sep 2026** | 3K–5K | Mistral | ~$300–500 | Monitor usage |
| **Oct 2026** | 5K–8K | Mistral | ~$500–800 | Scale successfully |
| **Nov 2026** | 8K–10K | Mistral | ~$800–1,200 | Reach target |
| **Dec 2026** | 10K+ | Mistral | ~$1,200–1,500 | Plan self-hosting |

**Total 8-month cost (MVP through Scale): $3,500–5,300 API + $8,000–12,000 engineering**

---

## Risk Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-----------|--------|-----------|
| Gemini free tier exhausted early | Medium | Critical (blocks feature) | Monitor weekly; plan migration at 750 users |
| Mistral API latency > 2s | Low | High (poor UX) | A/B test before full migration |
| Mistral quality degrades at scale | Low | High (engagement drop) | Keep Gemini API as fallback for 30 days |
| LLM API outage (unavailable) | Low | High (app broken) | Implement fallback: pre-written generic prompts |
| Privacy regulation changes | Medium | Critical (compliance) | Monitor GDPR/CCPA updates; Mistral EU-friendly |

---

## Open Questions (Phase 2 Validation)

1. **How often does average user need a prompt?** (Assumption: 1-2/week; validate in beta)
2. **Do contextual prompts actually increase soaking engagement?** (Target: >25% lift vs. generic)
3. **What latency is acceptable for real-time prompts?** (Assumption: <1.5s; test in beta)
4. **Do users prefer shorter (faster) or longer (more thoughtful) responses?** (UX research needed)
5. **Should Formation Intelligence use same LLM or specialized model?** (Defer to Post MVP)

---

## Decision Summary

```
┌─────────────────────────────────────────────────────────────┐
│                  FINAL LLM STRATEGY                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  MVP:  Google Gemini 2.0 Flash                             │
│        ├─ Cost: $0/yr                                       │
│        ├─ Timeline: Weeks 1-12                              │
│        └─ Goal: Validate engagement >25% lift               │
│                                                             │
│  Scale: Mistral 7B                                          │
│        ├─ Cost: $4,500 API + $13,000-20,000 total/yr       │
│        ├─ Timeline: Week 13+ (1K+ users)                    │
│        └─ Goal: Production-ready LLM at scale               │
│                                                             │
│  Enterprise: Self-Hosted Mistral (optional)                │
│        ├─ Cost: $20-30/mo infrastructure                    │
│        ├─ Timeline: 50K+ users                              │
│        └─ Goal: Eliminate vendor lock-in                    │
│                                                             │
│  Fallback: Pre-written prompts (always)                     │
│        └─ Risk: If all APIs unavailable                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

**Status:** ✅ LOCKED & READY FOR IMPLEMENTATION  
**Owner:** Kell Golden  
**Last Updated:** May 7, 2026  
**Next Step:** Begin Pillar 2 (Security) implementation; plan Gemini integration in parallel

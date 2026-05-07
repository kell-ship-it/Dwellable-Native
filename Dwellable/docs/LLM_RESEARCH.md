# LLM Research & Selection Strategy

**Dwellable Pillar 3 (Soaking) & Personalization** | **Updated:** May 6, 2026 | **Status:** Research Complete

---

## 1. Overview

**Research Goal:** Identify the best LLM for generating contextual prompts and prayers in Dwellable's soaking experience, considering cost, quality, privacy, latency, and reliability.

**Key Constraint:** Due to E2E encryption, LLM must either run client-side (on-device) OR operate on encrypted data (cloud). User moments remain secret from Kell in all scenarios.

**Phase 2+ Use Cases:**
- Pillar 3 (Soaking): Generate contextual prompts and prayers based on user moment themes
- Pillar 4+ (Potential): Search across moments, pattern detection, insights generation

---

## 2. LLM Decision Framework

**Selection Criteria (Weighted):**
1. **Quality** (40%): Instruction-following, prompt comprehension, coherence
2. **Cost** (25%): Per-call pricing for 10K users/year at scale
3. **Privacy** (20%): On-device capability, no data retention, compliance
4. **Speed** (10%): Latency acceptable for user experience (sub-2s ideal)
5. **Reliability** (5%): Uptime, error handling, support

**Deployment Options:**
- **On-device:** Downloaded to user's iPhone at first launch; runs offline; max 4B params (storage/RAM constrained)
- **Cloud (Private):** Runs on Kell's server infrastructure; same privacy as on-device if no plaintext stored
- **Cloud (Public API):** Third-party LLM as a service; standard SaaS pricing

---

## 3. Tournament Structure

### **Round 1: Free Tier Championship**

| Model | Provider | Cost | Quality | Speed | On-Device? | Notes |
|-------|----------|------|---------|-------|-----------|-------|
| **Google Gemini 2.0 Flash** | Google | Free (2M tokens/month quota) | ⭐⭐⭐⭐⭐ | Very fast | No | Best instruction-following, fastest response, most generous free tier |
| Hugging Face (Mistral 7B) | HF API | Free tier limited | ⭐⭐⭐⭐ | Medium | Via oobabooga | Quality comparable to paid models; API tier has limits |
| Meta Llama 2 7B | Open source | Free | ⭐⭐⭐ | Slow (on-device) | Yes | Runs on-device (4GB model); slower, less capable than commercial |
| Anthropic Claude 3.5 Haiku | Anthropic | $0.80/M tokens | ⭐⭐⭐⭐ | Medium | No | Not free, but ~$1 for 10K users/month; excellent instruction-following |

**Free Tier Winner: 🏆 Google Gemini 2.0 Flash**
- **Why:** 2M free tokens/month covers ~10K users at modest usage; best quality-to-cost ratio; fastest response times
- **Caveat:** Requires valid Google Cloud account; quota resets monthly (plan for scaling after first tier)

---

### **Round 2: Paid Tier Championship (Under $0.01/call)**

| Model | Provider | Cost | Quality | Speed | Ideal For | Notes |
|-------|----------|------|---------|-------|-----------|-------|
| **Mistral 7B** | Mistral (via API) | $0.0001/1K tokens | ⭐⭐⭐⭐ | Fast | Production workloads | Cheapest paid option; open weights available; strong instruction-following |
| OpenAI GPT-3.5 Turbo | OpenAI | $0.0005/1K tokens | ⭐⭐⭐⭐⭐ | Medium | General-purpose | Most capable; highest quality; 10x cost of Mistral |
| Claude 3 Haiku | Anthropic | $0.80/M input | ⭐⭐⭐⭐ | Medium | Privacy-critical | Same cost as Gemini; excellent reasoning; no free tier |
| Llama 2 70B (via Replicate) | Replicate | $0.00065/sec | ⭐⭐⭐⭐ | Slower | Large-context tasks | 70B param model; slower cold start; pay-per-second |

**Paid Tier Winner: 🏆 Mistral 7B**
- **Why:** Lowest cost ($0.0001/1K tokens), excellent quality, fast inference, open-source option for self-hosting
- **Cost for 10K users (Year 1):** ~$480-600 (assuming 15-20 API calls/user/year, ~100 tokens/call)

---

### **Championship Round: Free vs. Paid**

**Scenario 1: MVP (Under 1K Users) → Use Google Gemini**
- Free tier covers all usage with no cost
- Excellent for validation and testing
- No infrastructure overhead
- Fallback option: Pay $1-3/month when free tier exhausted

**Scenario 2: Scale (1K–10K Users) → Use Mistral 7B**
- Free tier insufficient; Gemini quota consumed
- Mistral offers next-best quality at lowest cost
- Total cost: $480-600 API + $12-15K engineering = ~$13K Year 1
- Can scale to 100K users for ~$3-5K/year API costs

**Scenario 3: On-Device (Privacy-First) → Use Llama 2 7B**
- Download 4GB model to user's phone at first launch
- Zero API costs after download
- Slower response (2-3s per prompt)
- Best for privacy-critical moments; worst for UX latency

**Champion: 🏆 Google Gemini (MVP) → Mistral 7B (Scale)**

---

## 4. Recommendation

### **For Dwellable Phase 2 MVP:**

**Primary:** Google Gemini 2.0 Flash (free)
- Use immediately to validate that contextual prompts improve soaking engagement
- Costs $0 until 10K+ users hit free tier limits
- Provides real-world quality data to justify paid LLM investment later

**Fallback (if Gemini quota exceeded):** Mistral 7B via API
- Seamless transition from free to paid without code changes
- Costs only $0.0001/1K tokens; can absorb 100K requests/month for ~$5-10

**Privacy Model (Client-Side Processing):**
1. User creates moment (plaintext on device)
2. Local NLP extracts themes/keywords (on-device, no API call)
3. Themes sent to Gemini API → receives contextual prompt
4. Prompt + moment encrypted together → sent to Supabase
5. Server stores encrypted_content (unreadable); never sees plaintext

**Never Migrate To:** OpenAI GPT-4 (10x cost, not necessary; Mistral covers use case)

**Future (If Budgets Allow):** Self-hosted Mistral 7B on dedicated server for all inference; zero per-call costs after infrastructure setup (~$20-30/month for small 4GB instance).

---

## 5. Cost Breakdown: 10K Users Year 1

### **Google Gemini (MVP Phase)**
```
Free Tier: 2M tokens/month = 24M tokens/year
Assuming: 15 prompts/user/year × 100 tokens per prompt = 1.5M tokens/year needed
Cost: $0 (well within free tier)
Transition: When free tier exhausted (likely after 15K+ users), migrate to Mistral
```

### **Mistral 7B (Scale Phase)**
```
10,000 users × 15 prompts/user/year = 150,000 API calls
150,000 calls × 100 tokens/call = 15M tokens
15M tokens × $0.0001/1K tokens = $1,500/year API
Plus 10-20% buffer (unused calls, error retries) = ~$1,800-2,000/year
```

### **Total Year 1 Cost (Mistral at 10K Users)**
```
API: $1,800-2,000
Engineering (prompt design, testing, monitoring): $10,000-12,000
Infrastructure (Supabase, iOS): $4,000-6,000
Total: $15,800-20,000 (~$1.58-2.00 per user for Year 1)
```

**Comparison:**
- OpenAI GPT-3.5: $9,000-12,000 API cost alone (5-6x Mistral)
- On-Device Llama: $0 API + $5K infrastructure = $5K total (but slower UX)
- Google Gemini: $0-500 for Year 1 (then transition cost to Mistral)

---

## 6. Detailed Model Comparison Table

| Dimension | Gemini 2.0 Flash | Mistral 7B | OpenAI GPT-3.5 | Claude 3 Haiku | Llama 2 7B |
|-----------|------------------|-----------|-----------------|----------------|-----------|
| **Cost (per 1K tokens)** | $0 (free tier) | $0.0001 | $0.0005 | $0.80/M input | $0 (on-device) |
| **Quality** | 5/5 | 4/5 | 5/5 | 4/5 | 3/5 |
| **Speed** | Very Fast (500ms) | Fast (800ms) | Medium (1.2s) | Medium (1.2s) | Slow (2-3s) |
| **On-Device?** | No | Via Replicate | No | No | Yes |
| **Max Free Usage** | 2M tokens/month | Limited API tier | $5 trial credit | None | Unlimited |
| **Instruction Following** | Excellent | Excellent | Excellent | Very Good | Good |
| **Best For** | MVP validation, testing | Production at scale | General-purpose, safety | Privacy-first, reasoning | Cost-free inference |
| **Drawback** | Free tier → limits at scale | Less well-known | High cost | No free tier | Slower responses |

---

## 7. Implementation Roadmap

### **Phase 1 (Weeks 1-4): Gemini MVP**
- [ ] Integrate Google Gemini API via REST calls
- [ ] Design prompt templates (5-10 seed prompts for testing)
- [ ] Test with Phase 1 beta users (~50 users)
- [ ] Measure: Do contextual prompts increase soaking engagement? (Target: >25% lift)
- [ ] Cost: $0

### **Phase 2 (Weeks 5-8): Mistral Transition (If Scaling)**
- [ ] Swap API endpoint from Gemini to Mistral (same input/output interface)
- [ ] No code changes needed (abstracted via APIClient)
- [ ] Test latency and quality parity
- [ ] Cost: ~$100-200 for 5K users

### **Phase 3+ (Optional): On-Device Fallback**
- [ ] Download Llama 2 7B at first app launch (one-time 4GB download)
- [ ] Use on-device for offline scenarios; Mistral as primary
- [ ] Reduces API dependency; future-proofs against API outages

---

## 8. Privacy & Security Notes

**E2E Encryption Maintained:**
- Moments remain encrypted client-side before upload
- Prompts are generic (not specific to moment content) — metadata-safe
- Gemini/Mistral never see plaintext moment content
- Only server ever touches encrypted_content field

**Comparison: On-Device vs. Cloud**
| Aspect | On-Device Llama | Cloud Gemini | Cloud Mistral |
|--------|-----------------|--------------|---------------|
| API calls logged? | No | Yes (Google Cloud) | Yes (Mistral) |
| Model access? | Full visibility | Black box | Black box |
| Data retention? | None | 30 days (default) | None stated |
| HIPAA compliant? | Possible | Possible (Business Associate Agreement) | Requires custom agreement |
| Best for faith apps? | Highest trust | Good (Google compliance) | Good (EU-friendly) |

---

## 9. Open Questions (Resolved in Next Phase)

1. **How often does average user need a prompt?** (Currently assuming 1-2 per week)
2. **Do contextual prompts actually increase soaking engagement?** (MVP metric validation needed)
3. **Should we self-host Mistral for cost savings?** (Evaluate after 5K+ users)
4. **Will users accept 2-3s latency for on-device responses?** (UX testing needed)

---

## 10. Recommendation Summary

| Phase | Model | Rationale | Cost |
|-------|-------|-----------|------|
| **MVP (0-1K users)** | Google Gemini 2.0 Flash | Free, excellent quality, no infrastructure | $0 |
| **Scale (1K-10K users)** | Mistral 7B | Cheapest paid, excellent quality, fast | $1,800-2,000/yr |
| **Enterprise (10K+ users)** | Self-hosted Mistral or Anthropic partnership | Reduced per-call costs, better privacy | $20-50/mo infra |

**Decision Made:** Use Google Gemini for MVP validation. Plan Mistral migration at 1K users. Re-evaluate on-device fallback at 10K users.

---

**Status:** Research complete. Ready for implementation. First ticket: Integrate Gemini API into Pillar 3 prompt engine (part of Pillar 3 implementation epic).

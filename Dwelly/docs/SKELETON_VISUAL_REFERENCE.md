# Skeleton Diagram — Visual Reference

## Pillar Journey (User Experience Flow)

```
FIRST RUN                          ONGOING REFLECTION
    │                                      │
    ▼                                      │
┌──────────┐                               │
│ PILLAR 0 │ User Intent + Privacy         │
│Onboarding├──────┐                        │
└──────────┘      │                        │
                  ▼                        │
              ┌──────────┐                 │
              │ PILLAR 1 │ Voice/Text      │
              │ Capture  ├────────┐        │
              └──────────┘        │        │
                                  ▼        │
                              ┌──────────┐ │
                              │ PILLAR 2 │ │ Encrypt E2E
                              │ Security ├─┘
                              └──────────┘
                                  │
                                  ▼
                    ┌──────────────────────────┐
                    │  PILLAR 3: SOAKING       │ ◀────────────┐
                    │ Gallery | Prayer | Prompts │             │
                    │ (Rich Context LLM)       │             │
                    └──────────────────────────┘             │
                              │                               │
                    ┌─────────┼─────────┐                      │
                    ▼         ▼         ▼                      │
                ┌────────┐ ┌────────┐ ┌────────────┐           │
                │PILLAR 4│ │PILLAR 5│ │ PILLAR 6   │           │
                │Editing │ │Search  │ │ Menu Bar   │◄──────────┤
                │(LLM)   │ │(FTS)   │ │(Navigation)│           │
                └────────┘ └────────┘ └────────────┘           │
                    ▲         ▲         ▲                       │
                    └─────────┼─────────┘                       │
                              │                                │
                              ├──► P6 Organizes All Flows     │
                              │                                │
                              │     Today | Entries            │
                              │     Create | Insights         │
                              │                                │
                    ┌─────────▼──────────┐                     │
                    │ PILLAR 7: Notif    │────────────────────┘
                    │(1-2/mo, Sparse,    │
                    │ LLM-personalized)  │
                    └────────────────────┘
```

## Data Flow Architecture

```
DEVICE (SwiftUI)                CLOUD (Supabase)
══════════════════════════════════════════════════════

User captures moment             
         │                        
         ▼                        
   ┌──────────────┐              
   │ Moment {id,  │              
   │  body, ...}  │              
   └──────┬───────┘              
          │                      
          ▼ PILLAR 2: Encryption 
   ┌──────────────────┐          
   │ Encrypt body     │          
   │ AES-256-GCM      │          
   │ Client-side      │          
   └──────┬───────────┘          
          │                      
          ▼                      
   ┌──────────────────────┐      
   │ Save Locally         │      
   │ • Keychain (secure)  │      
   │ • UserDefaults       │      
   │   (sync queue)       │      
   └──────┬───────────────┘      
          │                      
    (When network available)     
          │                      
          ▼                      
   ┌──────────────────┐    ┌────────────────┐
   │ SyncManager      │───▶│ Supabase       │
   │ • Batch moments  │    │ moments table  │
   │ • Upsert on_id   │    │ (RLS: user_id) │
   │ • Retry logic    │    └────────────────┘
   └──────────────────┘
```

## LLM Integration Points

```
PILLAR 3: SOAKING (Prayer/Prompts)
──────────────────────────────────
User's moment → [Rich Context Synthesis] → Gemini 2.0 Flash
                (Local: last 20 moments)    (Generate 2 prompts)
                (Decrypt, theme extract)    
                                            ▼
                                    "You've mentioned faith-work
                                     integration 7 times. How is
                                     this moment different?"


PILLAR 4: EDITING (Headlines + Tags)
──────────────────────────────────────
Moment body → Gemini 2.0 Flash → Headline: "Faith in uncertainty"
(500 chars)   (Summarize 8 wds)   Tags: [Faith, Clarity, Work]
              (Categorize 5 tags)


PILLAR 7: NOTIFICATIONS (Copy)
───────────────────────────────
User segment + Themes → Gemini 2.0 Flash → "You reflected on peace
(New user | Non-soaker)                      last week. Capture another
(Recent themes detected)                      moment this week?"
```

## Pillar Effort & Dependencies

```
EFFORT DISTRIBUTION (Total: ~400-500 developer hours)

P0: Onboarding           30-40 hours  ✅ Ready for implementation
                                       (Design locked: T-060)

P1: Capture              ✅ COMPLETE   (Build 107 live)
                         
P2: Security             40-60 hours  ⚠️  BLOCKING other pillars
                                       (T-062: Encryption)

P3: Soaking              60-80 hours  🔲 Next priority after P2
                                       (T-063, T-064, T-065, T-066)

P4: Editing              40-50 hours  🔲 Can parallelize with P3/P5
                                       (Design locked: T-071)

P5: Search               50-60 hours  🔲 Can parallelize with P3/P4
                                       (Design locked: T-072)

P6: Menu Bar             85-100 hrs   🔲 After P3/P4/P5 ready
                                       (T-076–T-082, 7 tickets)

P7: Notifications        100-120 hrs  🔲 Can parallelize with others
                                       (T-083–T-091, 9 tickets)

═══════════════════════════════════════════════════════════════════
PHASE 2 CRITICAL PATH:
  P0 → P1 (Complete) → P2 (40-60h) → P3 (60-80h) → P6 (85-100h)
  
  Parallel: P4, P5, P7 work alongside critical path
  
  Timeline: ~6 weeks (May 12 – Jun 20)
  Beta ready: Mid-June
```

## Architecture Decisions (Why This Way?)

| Pillar | Decision | Rationale | Tradeoff |
|--------|----------|-----------|----------|
| **P2** | Client-side E2E encryption | User privacy + legal compliance | Can't do server analytics on raw content |
| **P3** | Gemini 2.0 Flash (MVP) | Free tier, low latency, good quality | Vendor lock-in; Mistral alt for scale |
| **P3** | Rich Context synthesis (local) | Personalized without exposing moments | Requires local decryption + compute |
| **P6** | 4-tab navigation | Clear organization, no cognitive overload | Limited screen real estate |
| **P7** | Sparse (1-2/mo) | Respect user attention, high opt-in | Miss engagement opportunities if too sparse |
| **P5** | Full-text search (local decryption) | Privacy-first | Slower than server search |

---

**Use SKELETON_DIAGRAM.md for detailed specifications and SKELETON_VISUAL_REFERENCE.md for quick visual reference.**

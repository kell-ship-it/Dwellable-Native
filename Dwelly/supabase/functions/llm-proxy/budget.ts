// Per-capture token budget: server-side reserve/settle contract (MVP, Nov 23 2026).
// LOCAL DRAFT -- the real ledger is the SQL in migrations_draft (not applied); index.ts
// only wires it when CAPTURE_BUDGET_ENFORCE is true. The estimator is an unvalidated
// heuristic (same as the client's), NOT a tokenizer; reservations are an upper-ish bound
// that settle() trues up to provider-reported usage.

export const ONBOARDING_CAPTURE_LIMIT = 30_000
export const REGULAR_CAPTURE_LIMIT = 100_000
export type CaptureKind = "onboarding" | "regular"

export function limitFor(kind: CaptureKind): number {
  return kind === "onboarding" ? ONBOARDING_CAPTURE_LIMIT : REGULAR_CAPTURE_LIMIT
}

/** Unvalidated heuristic, deliberately conservative but not absurd (measured live: a real turn
 *  was 4,270 tokens; the earlier max(bytes/3, chars) estimate reserved 34,062 -- ~8x over, enough
 *  to refuse every onboarding capture). ASCII at 1 token per 3 chars (~33% over English's ~4);
 *  every non-ASCII character at 2 tokens (CJK is ~1-1.5, emoji up to ~3). */
export function estimateTokens(text: string): number {
  let ascii = 0
  let other = 0
  for (const ch of text) {
    if (ch.charCodeAt(0) < 128) ascii++
    else other++
  }
  return Math.ceil(ascii / 3) + 2 * other
}

const ID_RE = /^[A-Za-z0-9_-]{8,100}$/
export function isValidId(v: unknown): v is string {
  return typeof v === "string" && ID_RE.test(v)
}

export type ReserveResult =
  | { ok: true; reserved: number }
  | { ok: false; spent: number; limit: number }

export interface BudgetLedger {
  /** Atomic. Same (capture, request) while still reserved = same reservation (no double count). */
  reserve(captureId: string, requestId: string, kind: CaptureKind, amount: number): Promise<ReserveResult>
  /** Idempotent. Replaces the reservation with the real spend; never lowers below reported spend. */
  settle(captureId: string, requestId: string, actual: number): Promise<void>
}

/** Upper-ish estimate of everything one request can spend, before any call is made. */
export function reserveEstimate(opts: {
  messagesText: string[]
  /** user/assistant turns only (what the classifier reads); falls back to all messages. */
  conversationText?: string[]
  maxTokens: number
  isCaptureConversation: boolean
  classifierPrompt: string
  outputCheckPrompt: string
}): number {
  const msg = opts.messagesText.reduce((n, t) => n + estimateTokens(t), 0)
  if (!opts.isCaptureConversation) return msg + opts.maxTokens
  // The classifier sees only user/assistant turns (not the system prompts), so it is sized from
  // those alone; the output check emits a tiny JSON verdict (max_tokens 20 on OpenAI).
  const convo = (opts.conversationText ?? opts.messagesText).reduce((n, t) => n + estimateTokens(t), 0)
  const classifier = estimateTokens(opts.classifierPrompt) + convo + 50
  const main = msg + opts.maxTokens
  const outputCheck = estimateTokens(opts.outputCheckPrompt) + 50
  return classifier + main + outputCheck
}

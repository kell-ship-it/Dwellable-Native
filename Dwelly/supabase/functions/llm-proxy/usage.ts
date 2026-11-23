import type { TokenUsage } from "./handler.ts"

/// Provider-reported usage only. `cachedTokens` is null when the provider did not report
/// `prompt_tokens_details.cached_tokens` (UNKNOWN), and 0 only when it reported zero.
/// Never estimated, never inferred from prompt size.
export function extractUsage(data: {
  usage?: {
    prompt_tokens?: number
    completion_tokens?: number
    total_tokens?: number
    prompt_tokens_details?: { cached_tokens?: number } | null
  }
}): TokenUsage {
  const raw = data.usage?.prompt_tokens_details?.cached_tokens
  const prompt = data.usage?.prompt_tokens
  // Bounds: a reported count must be a non-negative integer and cannot exceed the prompt
  // tokens it is a subset of. Anything else is treated as unknown (null), never clamped
  // into a plausible-looking number.
  const valid = typeof raw === "number" && Number.isInteger(raw) && raw >= 0 &&
    (typeof prompt !== "number" || raw <= prompt)
  const cached = valid ? raw : undefined
  return {
    promptTokens: data.usage?.prompt_tokens ?? null,
    completionTokens: data.usage?.completion_tokens ?? null,
    totalTokens: data.usage?.total_tokens ?? null,
    cachedTokens: typeof cached === "number" ? cached : null,
  }
}

// Run: /tmp/deno-local/bin/deno test --no-npm usage.test.ts
import { assertEquals } from "jsr:@std/assert"
import { extractUsage } from "./usage.ts"

Deno.test("reported cached_tokens is carried through", () => {
  const u = extractUsage({ usage: { prompt_tokens: 2800, completion_tokens: 30, total_tokens: 2830, prompt_tokens_details: { cached_tokens: 2432 } } })
  assertEquals([u.promptTokens, u.completionTokens, u.cachedTokens], [2800, 30, 2432])
})
Deno.test("reported zero is 0, not unknown", () => {
  assertEquals(extractUsage({ usage: { prompt_tokens: 10, prompt_tokens_details: { cached_tokens: 0 } } }).cachedTokens, 0)
})
Deno.test("missing details (e.g. a provider that does not report it) is null = unknown", () => {
  assertEquals(extractUsage({ usage: { prompt_tokens: 10 } }).cachedTokens, null)
  assertEquals(extractUsage({ usage: { prompt_tokens: 10, prompt_tokens_details: null } }).cachedTokens, null)
  assertEquals(extractUsage({}).promptTokens, null)
})

Deno.test("cached > prompt, negative, fractional, NaN, string are invalid -> null (never clamped)", () => {
  const bad = (v: unknown) => extractUsage({ usage: { prompt_tokens: 100, prompt_tokens_details: { cached_tokens: v as number } } }).cachedTokens
  assertEquals(bad(101), null)
  assertEquals(bad(-1), null)
  assertEquals(bad(1.5), null)
  assertEquals(bad(NaN), null)
  assertEquals(bad("50"), null)
})
Deno.test("cached == prompt is allowed; cached with unknown prompt is kept", () => {
  assertEquals(extractUsage({ usage: { prompt_tokens: 100, prompt_tokens_details: { cached_tokens: 100 } } }).cachedTokens, 100)
  assertEquals(extractUsage({ usage: { prompt_tokens_details: { cached_tokens: 40 } } }).cachedTokens, 40)
})

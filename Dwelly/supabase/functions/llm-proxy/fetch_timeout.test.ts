// Run: /tmp/deno-local/bin/deno test --no-npm fetch_timeout.test.ts
import { assertEquals, assertRejects } from "jsr:@std/assert"
import { withTimeout } from "./fetch_timeout.ts"

Deno.test("a hung request is aborted at the deadline", async () => {
  const hang = (signal: AbortSignal) =>
    new Promise<string>((_, reject) => signal.addEventListener("abort", () => reject(new Error("aborted"))))
  const start = Date.now()
  await assertRejects(() => withTimeout(50, hang), Error, "aborted")
  assertEquals(Date.now() - start < 1000, true)
})

Deno.test("a fast request completes and is not aborted", async () => {
  assertEquals(await withTimeout(1000, () => Promise.resolve("ok")), "ok")
})

/// Runs `run` with an AbortSignal that fires after `ms`; the timer covers the whole callback
/// (request + body read) and is always cleared afterward.
export async function withTimeout<T>(
  ms: number,
  run: (signal: AbortSignal) => Promise<T>,
): Promise<T> {
  const controller = new AbortController()
  const timer = setTimeout(() => controller.abort(), ms)
  try {
    return await run(controller.signal)
  } finally {
    clearTimeout(timer)
  }
}

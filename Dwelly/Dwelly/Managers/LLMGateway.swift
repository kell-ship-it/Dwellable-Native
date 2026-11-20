import Foundation

/// T-107: the generic queueing/backoff/circuit-breaker/guardrail layer every LLM call
/// goes through, regardless of which feature or call site it comes from. Lives INSIDE
/// T-168's shared proxy client (wired into `SupabaseAPIClient.callLLM`, the one
/// chokepoint every feature already calls through) rather than alongside it, per the
/// ticket's own locked note -- so `CaptureConversationView`, `JournalSynthesisManager`,
/// and `DwellerProfileManager` all get this for free with no call-site changes, and
/// whatever calls `apiClient.callLLM` next (T-120's Dwelly Agent loop, T-147's
/// PrayerGenerationManager) inherits it automatically too.
///
/// The server-side proxy (`supabase/functions/llm-proxy`) already enforces a hard
/// 60-calls/day/user cap and fails open on a usage-count read error (see its own
/// comment) -- this is the client-side half: it protects against a runaway retry loop
/// or a local bug hammering that endpoint before the server cap even has a chance to
/// kick in, and it's what turns "the proxy is down/erroring" into a fast, cheap local
/// failure instead of every feature independently retrying forever against a dead
/// backend.
actor LLMGateway {
    static let shared = LLMGateway()

    enum GatewayError: LocalizedError {
        case circuitOpen(retryAfter: TimeInterval)

        var errorDescription: String? {
            switch self {
            case .circuitOpen(let retryAfter):
                return "LLM service is temporarily unavailable (too many recent failures). Try again in \(Int(retryAfter))s."
            }
        }
    }

    // MARK: - Guardrails (financial/token)

    /// Hard ceiling on `max_tokens` for ANY call, regardless of what a call site asks
    /// for -- defense-in-depth so a future feature can't accidentally (or via a bad
    /// model response loop) request an unbounded completion. T-119's real per-feature
    /// budgets (Dwelly ~3,000, Prayer ~1,250, journal ~950-1,500) all land comfortably
    /// under this; this is a backstop, not the budget itself.
    private let maxTokensCeiling = 2_000

    /// Belt-and-suspenders call-count cap, independent of the proxy's own server-side
    /// 60/day check. Tracked locally per-device (UserDefaults, reset at UTC midnight)
    /// so a client that's offline when the server cap would have rejected it, or hits
    /// the proxy's own fail-open path, still stops itself. Deliberately higher than the
    /// server's 60 -- this is a last-resort trip wire, not the primary enforcement.
    private let maxLocalCallsPerDay = 80
    private let localCallCountKey = "LLMGateway.localCallCount"
    private let localCallDayKey = "LLMGateway.localCallDay"

    // MARK: - Circuit breaker

    /// Consecutive failures (across ALL features/call sites -- a dead proxy is a dead
    /// proxy regardless of which feature noticed first) before the circuit trips open.
    private let failureThreshold = 5
    /// How long the circuit stays open before allowing a single trial call through.
    private let cooldown: TimeInterval = 30
    private var consecutiveFailures = 0
    private var circuitOpenedAt: Date?

    // MARK: - Request queue (bounded concurrency)

    /// Caps how many LLM calls can be in flight at once across the whole app. Keeps a
    /// burst (e.g. several pending journal entries retried at once by T-159's sweep)
    /// from firing a wall of simultaneous requests at the proxy; everything past this
    /// limit queues FIFO and waits its turn instead.
    private let maxConcurrent = 2
    private var activeCount = 0
    private var waiters: [CheckedContinuation<Void, Never>] = []

    // MARK: - Retry / backoff

    private let maxRetries = 2
    private let baseBackoff: TimeInterval = 0.5

    private init() {}

    /// Runs `call` (the actual network request) through the queue, circuit breaker,
    /// retry/backoff, and token guardrail. `call` receives the guardrail-clamped
    /// `maxTokens` to actually send.
    func execute(
        feature: String,
        requestedMaxTokens: Int?,
        call: @escaping (_ clampedMaxTokens: Int?) async throws -> LLMResponse
    ) async throws -> LLMResponse {
        try checkCircuit()
        try checkLocalDailyCap()

        let clampedMaxTokens = requestedMaxTokens.map { min($0, maxTokensCeiling) }

        await acquireSlot()
        defer { releaseSlot() }

        var lastError: Error?
        for attempt in 0...maxRetries {
            do {
                let response = try await call(clampedMaxTokens)
                recordSuccess()
                incrementLocalCallCount()
                return response
            } catch {
                lastError = error
                guard isRetryable(error), attempt < maxRetries else { break }
                let delay = baseBackoff * pow(2, Double(attempt))
                let jitter = Double.random(in: 0...(delay * 0.25))
                try? await Task.sleep(nanoseconds: UInt64((delay + jitter) * 1_000_000_000))
            }
        }

        recordFailure()
        throw lastError ?? APIError.unknown
    }

    // MARK: - Circuit breaker logic

    private func checkCircuit() throws {
        guard let openedAt = circuitOpenedAt else { return }
        let elapsed = Date().timeIntervalSince(openedAt)
        if elapsed < cooldown {
            throw GatewayError.circuitOpen(retryAfter: cooldown - elapsed)
        }
        // Cooldown elapsed -- half-open: let the next call through as a trial. If it
        // fails, recordFailure() re-opens the circuit with a fresh timestamp below.
        circuitOpenedAt = nil
    }

    private func recordSuccess() {
        consecutiveFailures = 0
        circuitOpenedAt = nil
    }

    private func recordFailure() {
        consecutiveFailures += 1
        if consecutiveFailures >= failureThreshold {
            circuitOpenedAt = Date()
        }
    }

    /// Only genuinely transient failures (network blips, the proxy or a provider
    /// erroring 5xx) are worth retrying. Auth failures, malformed requests, and
    /// explicit server messages (including the proxy's own 429 daily-limit response,
    /// which surfaces as `.message`) mean retrying would either fail identically or
    /// actively make things worse (hammering a rate limit) -- fail fast instead.
    private func isRetryable(_ error: Error) -> Bool {
        switch error {
        case APIError.networkError, APIError.serverError, APIError.unknown:
            return true
        default:
            return false
        }
    }

    // MARK: - Queue logic

    private func acquireSlot() async {
        if activeCount < maxConcurrent {
            activeCount += 1
            return
        }
        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
        activeCount += 1
    }

    private func releaseSlot() {
        activeCount -= 1
        if let next = waiters.first {
            waiters.removeFirst()
            next.resume()
        }
    }

    // MARK: - Local daily cap

    private func checkLocalDailyCap() throws {
        resetLocalCountIfNewDay()
        let count = UserDefaults.standard.integer(forKey: localCallCountKey)
        if count >= maxLocalCallsPerDay {
            throw APIError.message("Local LLM call limit reached for today. Try again tomorrow.")
        }
    }

    private func incrementLocalCallCount() {
        resetLocalCountIfNewDay()
        let count = UserDefaults.standard.integer(forKey: localCallCountKey)
        UserDefaults.standard.set(count + 1, forKey: localCallCountKey)
    }

    private func resetLocalCountIfNewDay() {
        let todayKey = Self.utcDayString(for: Date())
        let storedDay = UserDefaults.standard.string(forKey: localCallDayKey)
        if storedDay != todayKey {
            UserDefaults.standard.set(0, forKey: localCallCountKey)
            UserDefaults.standard.set(todayKey, forKey: localCallDayKey)
        }
    }

    private static func utcDayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: date)
    }
}

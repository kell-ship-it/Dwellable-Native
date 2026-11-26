import Foundation
import CommonCrypto

private func hlog(_ msg: String, _ level: String = "INFO") {
    print("[\(level)] \(msg)")
    HTMLLogManager.shared.log(msg, level: level)
}

class SupabaseAPIClient: APIClient {
    private let baseURL: String
    private let anonKey: String
    private let session: URLSession
    private var jwtToken: String?
    private var refreshToken: String?
    private let keychain = KeychainManager.shared
    // T-295: at cold launch, `MainTabView` mounts all 4 tabs at once (opacity-toggled,
    // not conditional -- see its own comment) and both `EntriesView.onAppear` and
    // `TodayView`'s `.task` fire their own authenticated fetches immediately, on top
    // of whatever `AppView`'s onboarding gate or `SyncManager`'s connectivity monitor
    // also kick off. If the restored JWT is already expired, every one of those calls
    // hits a 401 at roughly the same moment and, without this, each one independently
    // called `refreshJWTToken()` -- but Supabase rotates refresh tokens on every use,
    // so only the FIRST of those concurrent refresh calls actually succeeds; every
    // other one sends a refresh token GoTrue already consumed and gets rejected,
    // surfacing as exactly the silent, intermittent 401 this ticket describes (worse
    // for whichever caller's request just happens to race behind another). Tracking
    // the in-flight refresh here means every concurrent 401 awaits the SAME network
    // call instead of each starting its own.
    private var inFlightRefresh: Task<Void, Error>?
    private let rateLimiter = RateLimiter()
    private let certificatePinner: CertificatePinner

    init(baseURL: String = Config.supabaseURL, anonKey: String = Config.supabaseAnonKey, jwtToken: String? = nil) {
        self.baseURL = baseURL
        self.anonKey = anonKey
        self.jwtToken = jwtToken
        self.certificatePinner = CertificatePinner()

        // Create URLSession with certificate pinning delegate
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60

        let delegate = CertificatePinningDelegate(pinner: self.certificatePinner)
        self.session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)

        // Restore refresh token from keychain
        if let token = KeychainManager.shared.retrieve(forKey: "refreshToken") {
            self.refreshToken = token
        }
    }

    // Update JWT token when user authenticates
    func setJWTToken(_ token: String) {
        self.jwtToken = token
    }

    // Store refresh token and JWT together
    func setTokens(_ jwt: String, refresh: String) {
        self.jwtToken = jwt
        self.refreshToken = refresh
        // Also save refresh token to keychain for later sessions
        _ = keychain.save(refresh, forKey: "refreshToken")
    }

    // MARK: - Rate Limiting

    private func checkRateLimit() throws {
        guard rateLimiter.shouldAllowRequest() else {
            throw NSError(domain: "APIRateLimitExceeded", code: 429, userInfo: [
                NSLocalizedDescriptionKey: "Rate limit exceeded. Maximum 100 requests per minute."
            ])
        }
    }

    // Refresh JWT using refresh token
    private func refreshJWTToken() async throws {
        guard let refreshToken = refreshToken else {
            throw APIError.invalidRequest
        }

        let payload: [String: String] = ["grant_type": "refresh_token", "refresh_token": refreshToken]
        let endpoint = "/auth/v1/token?grant_type=refresh_token"

        let response = try await makeRequest(
            method: "POST",
            endpoint: endpoint,
            body: payload,
            responseType: AuthResponse.self,
            requiresAuth: false
        )

        setTokens(response.access_token, refresh: response.refresh_token)
        hlog("JWT token refreshed successfully", "SUCCESS")
    }

    private func makeRequest<T: Decodable>(
        method: String,
        endpoint: String,
        body: Encodable? = nil,
        responseType: T.Type,
        requiresAuth: Bool = true,
        preferHeader: String? = nil,
        isRetry: Bool = false
    ) async throws -> T {
        var urlComponents = URLComponents(string: baseURL)

        if let queryIndex = endpoint.firstIndex(of: "?") {
            let pathPart = String(endpoint[..<queryIndex])
            let queryPart = String(endpoint[endpoint.index(after: queryIndex)...])
            urlComponents?.path = pathPart
            let queryItems = queryPart.split(separator: "&").map { param in
                let parts = param.split(separator: "=", maxSplits: 1)
                return URLQueryItem(name: String(parts[0]), value: parts.count > 1 ? String(parts[1]) : "")
            }
            urlComponents?.queryItems = queryItems
        } else {
            urlComponents?.path = endpoint
        }

        guard let url = urlComponents?.url else { throw APIError.invalidRequest }

        hlog("API \(method) → \(url.path)\(isRetry ? " [retry]" : "")")

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        if requiresAuth {
            let authHeader = "Bearer \(jwtToken ?? anonKey)"
            hlog("🔑 Authorization: \(authHeader)", "INFO")
            request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if method == "POST" || method == "PATCH" || method == "PUT" {
            request.setValue(preferHeader ?? "return=representation", forHTTPHeaderField: "Prefer")
        }
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw APIError.networkError }

            let responseSnippet = String(data: data, encoding: .utf8).map { String($0.prefix(300)) } ?? ""
            let isSuccess = (200...299).contains(httpResponse.statusCode)
            hlog("API response \(httpResponse.statusCode): \(responseSnippet)", isSuccess ? "SUCCESS" : "ERROR")

            switch httpResponse.statusCode {
            case 200...299:
                // T-294: caught live -- a DELETE with no Prefer header (every DELETE
                // call site here) gets PostgREST's default "return=minimal", a genuine
                // 204 with an empty body. JSONDecoder can't decode ANY type, EmptyResponse
                // included, from zero bytes, so every DELETE call expecting EmptyResponse
                // threw and surfaced as a false "couldn't delete" even though the row was
                // really gone (confirmed via direct SQL). Short-circuit before decoding.
                if data.isEmpty, let empty = EmptyResponse() as? T {
                    return empty
                }
                let decoder = JSONDecoder()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    if let date = formatter.date(from: dateString) { return date }
                    if let date = ISO8601DateFormatter().date(from: dateString) { return date }
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateString)")
                }
                return try decoder.decode(T.self, from: data)
            case 401:
                // JWT expired — auto-refresh once and retry
                if !isRetry, refreshToken != nil {
                    hlog("JWT expired (401) — refreshing token and retrying...", "WARNING")
                    do {
                        // T-295: join an already-in-flight refresh instead of starting a
                        // second one -- see inFlightRefresh's own comment for why a second
                        // concurrent refresh call is the actual bug, not just redundant.
                        if let existing = inFlightRefresh {
                            try await existing.value
                        } else {
                            let task = Task { try await self.refreshJWTToken() }
                            inFlightRefresh = task
                            defer { inFlightRefresh = nil }
                            try await task.value
                        }
                    } catch {
                        // T-113: the refresh token itself was rejected (dead/revoked —
                        // not the same as a transient network blip during the refresh
                        // call, but there's no cheap way to tell those apart here, and
                        // treating a rejected refresh as "unauthorized" is the safe
                        // default either way). Normalizing to .unauthorized gives
                        // ProfileManager.refreshFromServer a distinct, confirmed signal
                        // to act on — previously whatever error refreshJWTToken's own
                        // makeRequest produced (often APIError.message, not .unauthorized)
                        // leaked out here and got treated as "probably just flaky
                        // network, leave the session alone," so a genuinely dead refresh
                        // token left the user optimistically "signed in" with a
                        // permanently broken session and no path back to Welcome.
                        hlog("JWT refresh failed — session cannot be renewed: \(error.localizedDescription)", "ERROR")
                        // Nov 27 2026: tell the app so it sends the person back to sign
                        // in, instead of every screen showing "check your connection".
                        NotificationCenter.default.post(name: .sessionExpired, object: nil)
                        throw APIError.unauthorized
                    }
                    return try await makeRequest(method: method, endpoint: endpoint, body: body,
                                                 responseType: responseType, requiresAuth: requiresAuth,
                                                 preferHeader: preferHeader, isRetry: true)
                }
                hlog("JWT refresh failed or no refresh token — user must log in again", "ERROR")
                NotificationCenter.default.post(name: .sessionExpired, object: nil)
                throw APIError.unauthorized
            case 404:
                throw APIError.notFound
            case 429:
                // The proxy's per-capture token budget refusal is NOT a rate limit and NOT a safety
                // failure: nothing was spent and the caller must finish the capture gracefully.
                if responseSnippet.contains("capture_budget_exhausted") {
                    throw APIError.captureBudgetExhausted
                }
                // Was falling into the generic 400...499 branch below as "Invalid
                // request" — genuinely confusing when it's really Supabase's per-IP rate
                // limit (e.g. the 30-per-5-min signup/signin or recover limit) kicking in
                // from repeated rapid attempts, not a malformed request. Caught via
                // edge_logs Nov 4 2026 while debugging a reset-link report.
                throw APIError.message("Too many attempts — please wait a few minutes and try again.")
            case 400...499:
                throw APIError.invalidRequest
            case 500...:
                throw APIError.serverError
            default:
                throw APIError.unknown
            }
        } catch let error as APIError {
            throw error
        } catch {
            hlog("Network error: \(error.localizedDescription)", "ERROR")
            throw APIError.networkError
        }
    }

    // MARK: - Moments API

    func saveMoment(_ moment: Moment) async throws -> Moment {
        // Check rate limit
        try checkRateLimit()

        let payload = MomentPayload(
            id: moment.id,
            user_id: moment.userId,
            body: moment.body,
            sense_of_lord: moment.senseOfLord,
            created_at: moment.createdAt.ISO8601Format(),
            updated_at: Date().ISO8601Format(),
            audio_url: moment.audioURL
        )

        return try await performSaveMoment(payload, originalMoment: moment)
    }

    private func performSaveMoment(_ payload: MomentPayload, originalMoment: Moment) async throws -> Moment {
        hlog("Saving moment \(originalMoment.id.prefix(8))… body: \"\(String(originalMoment.body.prefix(60)))\"")
        // T-062: routed through the save-moment Edge Function, not a direct
        // /rest/v1/moments write — the function encrypts body/sense_of_lord
        // server-side (AES-256-GCM, server-managed key) before persisting.
        // Writing directly to /rest/v1/moments here would store plaintext.
        let saved = try await makeRequest(
            method: "POST",
            endpoint: "/functions/v1/save-moment",
            body: payload,
            responseType: Moment.self
        )
        hlog("Moment saved (encrypted at rest) ✓", "SUCCESS")
        return saved
    }

    func fetchMoments(userId: String) async throws -> [Moment] {
        // Check rate limit
        try checkRateLimit()

        // T-062: routed through the fetch-moments Edge Function, which decrypts
        // server-side and returns plaintext for display — never a direct
        // /rest/v1/moments read (which would only ever see ciphertext now).
        // `userId` param kept for call-site compatibility; the function derives
        // the actual user from the verified JWT, not from this argument.
        return try await makeRequest(
            method: "GET",
            endpoint: "/functions/v1/fetch-moments",
            responseType: [Moment].self
        )
    }

    func fetchMoment(id: String) async throws -> Moment {
        let endpoint = "/functions/v1/fetch-moments?id=\(id)"
        let moments = try await makeRequest(
            method: "GET",
            endpoint: endpoint,
            responseType: [Moment].self
        )

        guard let moment = moments.first else {
            throw APIError.notFound
        }
        return moment
    }

    func deleteMoment(id: String) async throws {
        // T-158: soft delete. The confirmation copy shown before this call
        // promises a 30-day Recently Deleted recovery window (see JournalDetailView),
        // so this must NOT be a real DELETE -- it sets deleted_at instead, which
        // fetch-moments' list query (but not its single-id lookup) filters out.
        // Permanent purge after 30 days + the Recently Deleted restore UI itself
        // are T-176, not yet built.
        let endpoint = "/rest/v1/moments?id=eq.\(id)"
        let body = ["deleted_at": ISO8601DateFormatter().string(from: Date())]
        // PATCH defaults to `Prefer: return=representation` (see makeRequest), so
        // PostgREST responds with a JSON array of the updated row(s) -- matching
        // the existing OnboardingProfileRow PATCH call site's pattern, not the
        // bare object EmptyResponse expects.
        _ = try await makeRequest(
            method: "PATCH",
            endpoint: endpoint,
            body: body,
            responseType: [EmptyResponse].self
        )
    }

    func fetchDeletedMoments(userId: String) async throws -> [Moment] {
        // Routed through the same fetch-moments Edge Function (decrypts server-side,
        // same as every other moments read) -- just its ?deleted=true branch.
        return try await makeRequest(
            method: "GET",
            endpoint: "/functions/v1/fetch-moments?deleted=true",
            responseType: [Moment].self
        )
    }

    func restoreMoment(id: String) async throws {
        let endpoint = "/rest/v1/moments?id=eq.\(id)"
        let body: [String: String?] = ["deleted_at": nil]
        _ = try await makeRequest(
            method: "PATCH",
            endpoint: endpoint,
            body: body,
            responseType: [EmptyResponse].self
        )
    }

    func permanentlyDeleteMoment(id: String) async throws {
        // The one place a real hard DELETE still belongs -- "Delete Forever" in
        // Recently Deleted is genuinely, irreversibly permanent (T-176).
        let endpoint = "/rest/v1/moments?id=eq.\(id)"
        _ = try await makeRequest(
            method: "DELETE",
            endpoint: endpoint,
            responseType: EmptyResponse.self
        )
    }

    // MARK: - Journal Entries API (T-152)

    func fetchJournalEntry(momentId: String) async throws -> JournalEntry? {
        // Routed through the fetch-journal-entries Edge Function: `body` is encrypted
        // at rest and decrypted server-side here (title/moods/scripture stay plain).
        let endpoint = "/functions/v1/fetch-journal-entries?moment_id=\(momentId)"
        let entries = try await makeRequest(
            method: "GET",
            endpoint: endpoint,
            responseType: [JournalEntry].self
        )
        return entries.first
    }

    func saveJournalEntry(_ entry: JournalEntry, clearPhoto: Bool = false) async throws -> JournalEntry {
        let payload = JournalEntryPayload(
            id: entry.id,
            moment_id: entry.momentId,
            user_id: entry.userId,
            status: entry.status,
            title: entry.title,
            body: entry.body,
            moods: entry.moods,
            scripture_quote: entry.scriptureQuote,
            scripture_reference: entry.scriptureReference,
            starred: entry.starred,
            edited: entry.edited,
            created_at: entry.createdAt.ISO8601Format(),
            updated_at: Date().ISO8601Format(),
            formation_eligible: entry.formationEligible,
            extracted_facts: entry.extractedFacts,
            // Omitted (nil -> key not encoded) when false, the column's own DB
            // default: keeps journal saves working against a database where
            // migration 20261119140000 hasn't been applied yet. Only a true value
            // is ever sent, and nothing sets it true while
            // FormationEligibilityPolicy.isActive is off.
            profile_excluded: entry.profileExcluded ? true : nil,
            // Kell (Nov 25 2026): photos uploaded but never stuck to the entry because
            // this was never sent. Left out when nil, so other saves that don't
            // carry the photo can't wipe one that's already attached.
            // clearPhoto sends an explicit null so a removed photo actually comes off.
            photo_path: clearPhoto ? NullableString(value: nil) : entry.photoPath.map { NullableString(value: $0) }
        )
        // save-journal-entry encrypts `body` server-side and upserts on the unique
        // moment_id column -- one entry per moment, so saving twice updates the same row.
        return try await makeRequest(
            method: "POST",
            endpoint: "/functions/v1/save-journal-entry",
            body: payload,
            responseType: JournalEntry.self
        )
    }

    func fetchPendingJournalEntries(userId: String) async throws -> [JournalEntry] {
        let endpoint = "/functions/v1/fetch-journal-entries?status=pending"
        return try await makeRequest(
            method: "GET",
            endpoint: endpoint,
            responseType: [JournalEntry].self
        )
    }

    func fetchApprovedJournalEntries(userId: String) async throws -> [JournalEntry] {
        // Kell caught this live (Nov 16 2026): this never excluded a soft-deleted
        // moment's own journal_entries row -- T-158's soft delete only ever filtered
        // moments.deleted_at in fetch-moments' list query (see its own comment), so a
        // deleted entry's title/moods/body kept counting as a real qualifying
        // reflection and kept feeding YourNarrativeCard/DwellerProfileManager forever.
        // PostgREST embedded-resource filter: join moments, require its deleted_at IS
        // NULL. The extra embedded "moments" object each row carries back is silently
        // dropped by JournalEntry's own explicit CodingKeys.
        let endpoint = "/functions/v1/fetch-journal-entries?status=approved"
        return try await makeRequest(
            method: "GET",
            endpoint: endpoint,
            responseType: [JournalEntry].self
        )
    }

    func markJournalEntryViewed(id: String) async throws {
        let endpoint = "/rest/v1/journal_entries?id=eq.\(id)"
        let body = ["viewed_at": ISO8601DateFormatter().string(from: Date())]
        _ = try await makeRequest(
            method: "PATCH",
            endpoint: endpoint,
            body: body,
            responseType: [EmptyResponse].self
        )
    }

    // MARK: - DwellerProfile API (T-274)

    func fetchDwellerProfile(userId: String) async throws -> DwellerProfile? {
        // dweller-profile Edge Function: summary is encrypted at rest; user comes from the JWT.
        let endpoint = "/functions/v1/dweller-profile"
        let profiles = try await makeRequest(
            method: "GET",
            endpoint: endpoint,
            responseType: [DwellerProfile].self
        )
        return profiles.first
    }

    func saveDwellerProfile(_ profile: DwellerProfile) async throws -> DwellerProfile {
        let payload = DwellerProfilePayload(
            user_id: profile.userId,
            running_summary: profile.runningSummary,
            updated_at: profile.updatedAt.ISO8601Format()
        )
        // Upsert on the unique user_id (done server-side) -- one profile per user.
        return try await makeRequest(
            method: "POST",
            endpoint: "/functions/v1/dweller-profile",
            body: payload,
            responseType: DwellerProfile.self
        )
    }

    func confirmDwellerProfile(userId: String) async throws -> DwellerProfile {
        return try await makeRequest(
            method: "PATCH",
            endpoint: "/functions/v1/dweller-profile",
            responseType: DwellerProfile.self
        )
    }

    func submitNarrativeFeedback(userId: String, feedbackText: String, narrativeAtTime: String?) async throws {
        let payload = NarrativeFeedbackPayload(user_id: userId, feedback_text: feedbackText, narrative_at_time: narrativeAtTime)
        _ = try await makeRequest(
            method: "POST",
            endpoint: "/rest/v1/narrative_feedback",
            body: payload,
            responseType: [NarrativeFeedback].self
        )
    }

    func fetchNarrativeFeedback(userId: String) async throws -> [NarrativeFeedback] {
        let endpoint = "/rest/v1/narrative_feedback?user_id=eq.\(userId)&select=*&order=created_at.asc"
        return try await makeRequest(
            method: "GET",
            endpoint: endpoint,
            responseType: [NarrativeFeedback].self
        )
    }

    // MARK: - Support & Feedback (T-133)

    // One authenticated round trip through the submit-feedback Edge Function: it
    // validates, inserts, and attempts the Resend/Notion notify server-side, so this
    // call's success/failure IS the real outcome -- no separate fire-and-forget step
    // whose failure the client never sees. A thrown error here means nothing was saved;
    // only a successful return means the submission is durably in feedback_submissions.
    func submitFeedback(userId: String, category: FeedbackCategory, message: String, appVersion: String?, screenshotPath: String?) async throws -> FeedbackSubmitResult {
        let payload = SubmitFeedbackPayload(category: category.rawValue, message: message, app_version: appVersion, screenshot_path: screenshotPath, retry_submission_id: nil)
        let response = try await makeRequest(
            method: "POST",
            endpoint: "/functions/v1/submit-feedback",
            body: payload,
            responseType: SubmitFeedbackResponse.self
        )
        guard response.ok, let id = response.id, let createdAt = response.created_at else {
            throw APIError.serverError
        }
        let submission = FeedbackSubmission(id: id, userId: userId, category: category, message: message, appVersion: appVersion, platform: "ios", screenshotPath: screenshotPath, createdAt: Self.parseDate(createdAt))
        return FeedbackSubmitResult(submission: submission, emailed: response.emailed ?? false, resendConfigured: response.resend_configured ?? false)
    }

    // Re-attempts the Resend email for an existing submission only -- never re-inserts,
    // so the saved row stays the same no matter how many times this is called.
    func retryFeedbackNotify(submissionId: String) async throws -> FeedbackSubmitResult {
        let payload = SubmitFeedbackPayload(category: nil, message: nil, app_version: nil, screenshot_path: nil, retry_submission_id: submissionId)
        let response = try await makeRequest(
            method: "POST",
            endpoint: "/functions/v1/submit-feedback",
            body: payload,
            responseType: SubmitFeedbackResponse.self
        )
        guard response.ok, let id = response.id, let createdAt = response.created_at else {
            throw APIError.serverError
        }
        // The retry response doesn't echo category/message/screenshot back -- the
        // caller already has those locally (it's retrying its own just-made submission)
        // and only needs the updated emailed/resendConfigured status here.
        let submission = FeedbackSubmission(id: id, userId: "", category: .other, message: "", appVersion: nil, platform: "ios", screenshotPath: nil, createdAt: Self.parseDate(createdAt))
        return FeedbackSubmitResult(submission: submission, emailed: response.emailed ?? false, resendConfigured: response.resend_configured ?? false)
    }

    private static func parseDate(_ string: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string) ?? ISO8601DateFormatter().date(from: string) ?? Date()
    }

    func uploadFeedbackScreenshot(_ imageData: Data, fileName: String, userId: String) async throws -> String {
        let storagePath = "\(userId)/\(fileName)"
        let uploadEndpoint = "/storage/v1/object/feedback-screenshots/\(storagePath)"

        var uploadRequest = URLRequest(url: URL(string: baseURL + uploadEndpoint)!)
        uploadRequest.httpMethod = "POST"
        uploadRequest.setValue(anonKey, forHTTPHeaderField: "apikey")
        uploadRequest.setValue("Bearer \(jwtToken ?? anonKey)", forHTTPHeaderField: "Authorization")
        uploadRequest.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        uploadRequest.httpBody = imageData

        do {
            let (_, uploadResponse) = try await session.data(for: uploadRequest)
            guard let httpResponse = uploadResponse as? HTTPURLResponse else { throw APIError.networkError }
            guard (200...299).contains(httpResponse.statusCode) else { throw APIError.serverError }
            return storagePath
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError
        }
    }

    // MARK: - Custom Moods API (T-294)

    func fetchCustomMoods(userId: String) async throws -> [CustomMood] {
        let endpoint = "/rest/v1/custom_moods?user_id=eq.\(userId)&select=*&order=created_at.asc"
        return try await makeRequest(
            method: "GET",
            endpoint: endpoint,
            responseType: [CustomMood].self
        )
    }

    func addCustomMood(userId: String, word: String) async throws -> CustomMood {
        let payload = CustomMoodPayload(user_id: userId, word: word)
        // Upsert on the (user_id, word) unique constraint -- re-adding a word the user
        // already has (e.g. retyped on another device) just returns the existing row
        // instead of erroring or duplicating.
        let endpoint = "/rest/v1/custom_moods?on_conflict=user_id,word"
        let saved = try await makeRequest(
            method: "POST",
            endpoint: endpoint,
            body: payload,
            responseType: [CustomMood].self,
            preferHeader: "resolution=merge-duplicates,return=representation"
        )
        guard let mood = saved.first else { throw APIError.notFound }
        return mood
    }

    func deleteCustomMood(id: String) async throws {
        let endpoint = "/rest/v1/custom_moods?id=eq.\(id)"
        _ = try await makeRequest(
            method: "DELETE",
            endpoint: endpoint,
            responseType: EmptyResponse.self
        )
    }

    // MARK: - Auth API

    func signUp(email: String, password: String) async throws -> SignUpOutcome {
        try checkRateLimit()

        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.path = "/auth/v1/signup"
        // Without this, GoTrue redirects the confirmation link to the project's Site URL
        // (Supabase's default is http://localhost:3000), which is why Safari showed
        // "couldn't connect to the server" when tapping the email link (Nov 4 2026).
        urlComponents?.queryItems = [URLQueryItem(name: "redirect_to", value: "dwelly://auth/confirm")]
        guard let url = urlComponents?.url else { throw APIError.invalidRequest }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(LoginPayload(email: email, password: password))

        hlog("API POST → /auth/v1/signup")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.networkError }

        let responseSnippet = String(data: data, encoding: .utf8).map { String($0.prefix(300)) } ?? ""
        let isSuccess = (200...299).contains(httpResponse.statusCode)
        hlog("API response \(httpResponse.statusCode): \(responseSnippet)", isSuccess ? "SUCCESS" : "ERROR")

        guard isSuccess else {
            // GoTrue's error body carries the real reason ("User already registered",
            // "Password should be at least 8 characters", etc.) — the generic
            // makeRequest() path throws a bare status-code error and loses this, so
            // signUp decodes it directly to surface the message the spec calls for.
            let gotrueMessage = (try? JSONDecoder().decode(GoTrueError.self, from: data))
                .flatMap { $0.msg ?? $0.error_description }

            // Explicit duplicate-email detection (reverted from the Nov 4 2026
            // anti-enumeration masking per Kell's direction the same day — he wants a real
            // "this email already exists" screen over the generic check-email flow; T-115
            // tracks the resulting enumeration exposure as an accepted tradeoff, not a bug).
            let isDuplicateEmail = httpResponse.statusCode == 422
                && (gotrueMessage?.localizedCaseInsensitiveContains("already registered") == true
                    || gotrueMessage?.localizedCaseInsensitiveContains("already exists") == true)
            if isDuplicateEmail {
                return .emailAlreadyExists
            }

            if let gotrueMessage {
                throw APIError.message(gotrueMessage)
            }
            throw httpResponse.statusCode == 422 ? APIError.message("Sign up failed.") : APIError.invalidRequest
        }

        // Try the "here's your session" shape first (email confirmation off, or this
        // project auto-confirms). Fall back to the "user created, confirmation pending"
        // shape — same 2xx status, just missing access_token/refresh_token — rather than
        // letting that decode failure surface as a confusing error on a real success.
        let decoder = JSONDecoder()
        if let authResponse = try? decoder.decode(AuthResponse.self, from: data) {
            setTokens(authResponse.access_token, refresh: authResponse.refresh_token)
            return .session(AuthToken(
                token: authResponse.access_token,
                userId: authResponse.user.id,
                expiresAt: Date(timeIntervalSinceNow: TimeInterval(authResponse.expires_in))
            ))
        }

        if let userResponse = try? decoder.decode(UserResponse.self, from: data) {
            // Empty `identities` = GoTrue's 200-status duplicate signal (see UserResponse).
            // The 422 branch above is dead code for this project in practice — logged
            // Nov 4 2026 showing every signup call returns 200 regardless — but left in
            // place in case "Confirm email" or GoTrue's behavior ever changes.
            if let identities = userResponse.identities, identities.isEmpty {
                return .emailAlreadyExists
            }
            return .pendingEmailConfirmation(email: email)
        }

        throw APIError.message("Account creation returned an unexpected response.")
    }

    /// Verifies the 6-digit code from the "Confirm signup" email (GoTrue's email-OTP
    /// flow) and returns a real session on success — same shape as login. Replaces the
    /// magic-link confirmation flow Nov 5, 2026: confirmed via Supabase's own auth logs
    /// that the one-time magic-link token was being consumed by Gmail's link-scanner
    /// before the user ever tapped it (two /verify hits, same token, same second — the
    /// first succeeds, the second always "expired"). A code the user types by hand can't
    /// be pre-fetched by a mail client, so it isn't vulnerable to that failure mode.
    func verifySignupOTP(email: String, token: String) async throws -> AuthToken {
        try checkRateLimit()

        let endpoint = "/auth/v1/verify"
        let payload = VerifyOTPPayload(type: "signup", email: email, token: token)
        let authResponse = try await makeRequest(
            method: "POST",
            endpoint: endpoint,
            body: payload,
            responseType: AuthResponse.self,
            requiresAuth: false
        )
        setTokens(authResponse.access_token, refresh: authResponse.refresh_token)
        return AuthToken(
            token: authResponse.access_token,
            userId: authResponse.user.id,
            expiresAt: Date(timeIntervalSinceNow: TimeInterval(authResponse.expires_in))
        )
    }

    /// Requests a fresh signup confirmation code — the user's own recovery path once a
    /// code has already been consumed (by a mail-client prefetch) or has expired.
    func resendSignupConfirmation(email: String) async throws {
        try checkRateLimit()

        let endpoint = "/auth/v1/resend"
        let payload = ResendPayload(type: "signup", email: email)
        _ = try await makeRequest(
            method: "POST",
            endpoint: endpoint,
            body: payload,
            responseType: EmptyResponse.self,
            requiresAuth: false
        )
    }

    /// T-131: sends a real email OTP to confirm a password change for the current,
    /// already-signed-in user. `create_user: false` is the important bit -- without it
    /// GoTrue's `/otp` endpoint will silently create a brand-new account for the email if
    /// it somehow didn't match an existing one, which is never correct here.
    func sendPasswordChangeOTP(email: String) async throws {
        try checkRateLimit()
        let endpoint = "/auth/v1/otp"
        let payload = SendOTPPayload(email: email, create_user: false)
        _ = try await makeRequest(
            method: "POST",
            endpoint: endpoint,
            body: payload,
            responseType: EmptyResponse.self,
            requiresAuth: false
        )
    }

    /// `type: "email"` -- GoTrue's generic email-OTP verification, distinct from
    /// `verifySignupOTP`'s `type: "signup"` (that one only works for an unconfirmed
    /// signup's own code). A correct code refreshes the session exactly like `login`
    /// does; `ChangePasswordView` only calls `updatePassword` after this succeeds.
    func verifyPasswordChangeOTP(email: String, token: String) async throws -> AuthToken {
        try checkRateLimit()
        let endpoint = "/auth/v1/verify"
        let payload = VerifyOTPPayload(type: "email", email: email, token: token)
        let authResponse = try await makeRequest(
            method: "POST",
            endpoint: endpoint,
            body: payload,
            responseType: AuthResponse.self,
            requiresAuth: false
        )
        setTokens(authResponse.access_token, refresh: authResponse.refresh_token)
        return AuthToken(
            token: authResponse.access_token,
            userId: authResponse.user.id,
            expiresAt: Date(timeIntervalSinceNow: TimeInterval(authResponse.expires_in))
        )
    }

    func updatePassword(newPassword: String) async throws {
        try checkRateLimit()
        struct UpdatePasswordPayload: Encodable { let password: String }
        _ = try await makeRequest(
            method: "PUT",
            endpoint: "/auth/v1/user",
            body: UpdatePasswordPayload(password: newPassword),
            responseType: EmptyResponse.self
        )
    }

    /// T-250: GoTrue's native email-change confirmation flow. `PUT /auth/v1/user` with a
    /// new `email` on an authenticated session makes GoTrue send a confirmation link to
    /// that new address automatically -- no custom OTP endpoint needed, unlike T-131's
    /// password change. The signed-in account's email (and access) is untouched until
    /// that link is clicked, which is exactly the locked design's "current email stays
    /// active until confirmed."
    func requestEmailChange(newEmail: String) async throws {
        try checkRateLimit()
        struct UpdateEmailPayload: Encodable { let email: String }
        _ = try await makeRequest(
            method: "PUT",
            endpoint: "/auth/v1/user",
            body: UpdateEmailPayload(email: newEmail),
            responseType: EmptyResponse.self
        )
    }

    func login(email: String, password: String) async throws -> AuthToken {
        // Check rate limit
        try checkRateLimit()

        let payload = LoginPayload(email: email, password: password)
        let endpoint = "/auth/v1/token?grant_type=password"

        let response = try await makeRequest(
            method: "POST",
            endpoint: endpoint,
            body: payload,
            responseType: AuthResponse.self,
            requiresAuth: false
        )

        // Store both JWT and refresh token
        setTokens(response.access_token, refresh: response.refresh_token)

        return AuthToken(
            token: response.access_token,
            userId: response.user.id,
            expiresAt: Date(timeIntervalSinceNow: TimeInterval(response.expires_in))
        )
    }

    func logout() async throws {
        // Supabase logout is typically handled client-side (token removal)
        // Could call /auth/v1/logout if needed
    }

    // T-095: in-app account deletion (Apple App Store Guideline 5.1.1(v)).
    // Routed through the delete-account Edge Function, not a direct REST
    // call — only the service-role key can call GoTrue's admin.deleteUser,
    // and the function derives the user to delete from the verified JWT
    // rather than trusting a client-supplied id.
    func deleteAccount() async throws {
        _ = try await makeRequest(
            method: "POST",
            endpoint: "/functions/v1/delete-account",
            responseType: EmptyResponse.self
        )
    }

    func requestPasswordReset(email: String) async throws {
        try checkRateLimit()

        let payload = PasswordResetPayload(email: email)
        // Without an explicit redirect_to, GoTrue falls back to the project's Site URL —
        // which is pointed at dwelly://auth/confirm (the signup flow), not .../reset. A
        // recovery link landing on /confirm fails that handler's `type == "signup"` guard
        // and goes nowhere, which is why the reset link opened a dead page (Nov 4 2026).
        let endpoint = "/auth/v1/recover?redirect_to=dwelly://auth/reset"

        // GoTrue's /recover always returns an empty 200 body, success or not — it never
        // reveals whether the email exists, so there is nothing to branch on besides a
        // thrown network/HTTP error.
        _ = try await makeRequest(
            method: "POST",
            endpoint: endpoint,
            body: payload,
            responseType: EmptyResponse.self,
            requiresAuth: false
        )
    }

    func logLoginAttempt(email: String, success: Bool) async {
        // Log login attempt to monitoring system (non-blocking, errors are logged only)
        let endpoint = "/functions/v1/log-login-attempt"
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.path = endpoint
        guard let url = urlComponents?.url else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "email": email,
            "success": success
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        Task {
            do {
                let (_, response) = try await session.data(for: request)
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        hlog("Login attempt logged to monitoring system", "SUCCESS")
                    } else {
                        hlog("Failed to log login attempt (\(httpResponse.statusCode))", "WARNING")
                    }
                }
            } catch {
                hlog("Error logging login attempt: \(error.localizedDescription)", "WARNING")
            }
        }
    }

    func ensureUserExists(userId: String, email: String) async throws {
        // Create user record in public.users if it doesn't exist. PostgREST only honors
        // `on_conflict=id` as real upsert (insert...on conflict do nothing) when the
        // request also carries `Prefer: resolution=ignore-duplicates` — without it,
        // `on_conflict` is silently ineffective and a true duplicate throws a raw, unhandled
        // "duplicate key value violates unique constraint" instead of no-op'ing. Missing
        // here until Nov 6, 2026 — found via Supabase's own Postgres logs after this
        // function being called a second time for an already-existing row (a legitimate,
        // expected case: both AuthManager's post-verification call and AppView's gate
        // self-heal call this) threw instead of silently succeeding.
        let payload = UserPayload(id: userId, email: email)
        let endpoint = "/rest/v1/users?on_conflict=id"

        _ = try await makeRequest(
            method: "POST",
            endpoint: endpoint,
            body: payload,
            responseType: UserResponse.self,
            preferHeader: "resolution=ignore-duplicates,return=representation"
        )
    }

    // T-130: real "Member Since" on Account Profile -- previously just a "—" placeholder.
    func fetchAccountCreatedAt(userId: String) async throws -> Date? {
        struct AccountCreatedAtRow: Decodable { let created_at: Date }
        let endpoint = "/rest/v1/users?id=eq.\(userId)&select=created_at"
        let rows = try await makeRequest(method: "GET", endpoint: endpoint, responseType: [AccountCreatedAtRow].self)
        return rows.first?.created_at
    }

    // T-251: updates the dormancy clock's single source of truth. Sends now() from
    // the device rather than a database-side `now()` default so a device with a
    // wrong clock doesn't silently desync from what the user actually experienced --
    // matches how every other client-stamped timestamp in this app already works.
    func touchLastSynced(userId: String) async throws {
        let endpoint = "/rest/v1/users?id=eq.\(userId)"
        let body = ["last_synced_at": ISO8601DateFormatter().string(from: Date())]
        _ = try await makeRequest(
            method: "PATCH",
            endpoint: endpoint,
            body: body,
            responseType: [EmptyResponse].self
        )
    }

    // T-309: best-effort only -- the columns this PATCHes
    // (terms_accepted_at/terms_version/privacy_accepted_at/privacy_version) exist only
    // in migration 20261119120100_add_terms_and_privacy_acceptance_to_users.sql, which
    // has NOT been applied to any live database as part of this work. Until it is, this
    // call will fail against a real backend (unknown column) -- every call site must
    // treat that as non-fatal, same as touchLastSynced above.
    func recordTermsAcceptance(userId: String, version: String) async throws {
        let endpoint = "/rest/v1/users?id=eq.\(userId)"
        let now = ISO8601DateFormatter().string(from: Date())
        let body: [String: String] = [
            "terms_accepted_at": now,
            "terms_version": version,
            "privacy_accepted_at": now,
            "privacy_version": version,
        ]
        _ = try await makeRequest(
            method: "PATCH",
            endpoint: endpoint,
            body: body,
            responseType: [EmptyResponse].self
        )
    }

    func updateFCMToken(userId: String, token: String) async throws {
        let endpoint = "/rest/v1/users?id=eq.\(userId)"
        let body = ["fcm_token": token]
        _ = try await makeRequest(
            method: "PATCH",
            endpoint: endpoint,
            body: body,
            responseType: [EmptyResponse].self
        )
    }

    // MARK: - Onboarding Profile API (T-111)

    func fetchOnboardingProfile(userId: String) async throws -> OnboardingProfileRow {
        let endpoint = "/rest/v1/users?id=eq.\(userId)&select=id,name,spiritual_intent,notification_opt_in,onboarding_completed_at,current_onboarding_screen,notification_mode"
        let rows = try await makeRequest(method: "GET", endpoint: endpoint, responseType: [OnboardingProfileRow].self)
        guard let row = rows.first else { throw APIError.notFound }
        return row
    }

    func updateOnboardingProfile(userId: String, update: OnboardingProfileUpdate) async throws {
        let endpoint = "/rest/v1/users?id=eq.\(userId)"
        _ = try await makeRequest(method: "PATCH", endpoint: endpoint, body: update, responseType: [OnboardingProfileRow].self)
    }

    // MARK: - Storage API

    func uploadAudio(_ audioData: Data, fileName: String, userId: String) async throws -> String {
        // Upload to Supabase Storage bucket: moments-audio (PRIVATE bucket)
        let storagePath = "\(userId)/\(fileName)"
        let uploadEndpoint = "/storage/v1/object/moments-audio/\(storagePath)"

        // 1. Upload audio file
        var uploadRequest = URLRequest(url: URL(string: baseURL + uploadEndpoint)!)
        uploadRequest.httpMethod = "POST"
        uploadRequest.setValue(anonKey, forHTTPHeaderField: "apikey")
        let uploadAuthHeader = "Bearer \(jwtToken ?? anonKey)"
        hlog("🔑 Authorization (Storage): \(uploadAuthHeader)", "INFO")
        uploadRequest.setValue(uploadAuthHeader, forHTTPHeaderField: "Authorization")
        uploadRequest.setValue("audio/mp4", forHTTPHeaderField: "Content-Type")
        uploadRequest.httpBody = audioData

        hlog("Uploading audio to Storage: \(fileName)")

        do {
            let (_, uploadResponse) = try await session.data(for: uploadRequest)
            guard let httpResponse = uploadResponse as? HTTPURLResponse else { throw APIError.networkError }

            if (200...299).contains(httpResponse.statusCode) {
                // 2. Return file path (Edge Function will serve it securely)
                hlog("Audio uploaded successfully: \(fileName)", "SUCCESS")
                return storagePath
            } else {
                hlog("Upload failed (\(httpResponse.statusCode))", "ERROR")
                throw APIError.serverError
            }
        } catch let error as APIError {
            throw error
        } catch {
            hlog("Upload error: \(error.localizedDescription)", "ERROR")
            throw APIError.networkError
        }
    }

    // T-156: journal hero photos. Same shape as uploadAudio above, just a different
    // (also private) bucket -- "journal-photos" instead of "moments-audio".
    func uploadJournalPhoto(_ imageData: Data, fileName: String, userId: String) async throws -> String {
        let storagePath = "\(userId)/\(fileName)"
        let uploadEndpoint = "/storage/v1/object/journal-photos/\(storagePath)"

        var uploadRequest = URLRequest(url: URL(string: baseURL + uploadEndpoint)!)
        uploadRequest.httpMethod = "POST"
        uploadRequest.setValue(anonKey, forHTTPHeaderField: "apikey")
        uploadRequest.setValue("Bearer \(jwtToken ?? anonKey)", forHTTPHeaderField: "Authorization")
        uploadRequest.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        uploadRequest.httpBody = imageData

        hlog("Uploading journal photo to Storage: \(fileName)")

        do {
            let (_, uploadResponse) = try await session.data(for: uploadRequest)
            guard let httpResponse = uploadResponse as? HTTPURLResponse else { throw APIError.networkError }

            if (200...299).contains(httpResponse.statusCode) {
                hlog("Journal photo uploaded successfully: \(fileName)", "SUCCESS")
                return storagePath
            } else {
                hlog("Journal photo upload failed (\(httpResponse.statusCode))", "ERROR")
                throw APIError.serverError
            }
        } catch let error as APIError {
            throw error
        } catch {
            hlog("Journal photo upload error: \(error.localizedDescription)", "ERROR")
            throw APIError.networkError
        }
    }

    // T-156: the bucket is private, so the raw storage path can never be loaded
    // directly -- this mints a short-lived signed URL to actually display it.
    // Same Storage sign-urls endpoint `generateSignedURL` below already uses for
    // audio, just scoped to "journal-photos".
    func fetchJournalPhotoSignedURL(storagePath: String) async throws -> URL {
        let endpoint = "/storage/v1/object/sign/journal-photos/\(storagePath)"
        guard let url = URL(string: baseURL + endpoint) else { throw APIError.invalidRequest }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(jwtToken ?? anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["expiresIn": 3600])

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.networkError }

        guard (200...299).contains(httpResponse.statusCode) else {
            hlog("Failed to sign journal photo URL (\(httpResponse.statusCode))", "ERROR")
            throw APIError.serverError
        }

        struct SignedPathResponse: Decodable { let signedURL: String }
        let decoded = try JSONDecoder().decode(SignedPathResponse.self, from: data)
        guard let signedURL = URL(string: baseURL + "/storage/v1" + decoded.signedURL) else {
            throw APIError.serverError
        }
        return signedURL
    }

    private func generateSignedURLViaFunction(storagePath: String) async throws -> String {
        // Call Edge Function to generate signed URL (uses service role, no RLS issues)
        let endpoint = "/functions/v1/generate-audio-signed-url"
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.path = endpoint
        guard let url = urlComponents?.url else { throw APIError.invalidRequest }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        let signAuthHeader = "Bearer \(jwtToken ?? anonKey)"
        hlog("🔑 Authorization (Sign URLs): \(signAuthHeader)", "INFO")
        request.setValue(signAuthHeader, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = ["filePath": storagePath]
        request.httpBody = try JSONEncoder().encode(payload)

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw APIError.networkError }

            if (200...299).contains(httpResponse.statusCode) {
                let decoder = JSONDecoder()
                let result = try decoder.decode(SignedURLResponse.self, from: data)
                hlog("Signed URL generated via Edge Function", "SUCCESS")
                return result.signedUrl
            } else {
                let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
                hlog("Edge Function failed (\(httpResponse.statusCode)): \(errorMsg)", "ERROR")
                throw APIError.serverError
            }
        } catch let error as APIError {
            throw error
        } catch {
            hlog("Edge Function error: \(error.localizedDescription)", "ERROR")
            throw APIError.networkError
        }
    }

    private func generateSignedURL(storagePath: String, expiresIn: Int) async throws -> String {
        // Generate a signed URL using Supabase Storage API
        let endpoint = "/storage/v1/object/moments-audio/sign-urls"

        let payload = SignedURLRequest(expiresIn: expiresIn, paths: [storagePath])

        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.path = endpoint
        guard let url = urlComponents?.url else { throw APIError.invalidRequest }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        let signedURLAuthHeader = "Bearer \(jwtToken ?? anonKey)"
        hlog("🔑 Authorization (Signed URLs): \(signedURLAuthHeader)", "INFO")
        request.setValue(signedURLAuthHeader, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.networkError }

        if (200...299).contains(httpResponse.statusCode) {
            let decoder = JSONDecoder()
            let signedURLs = try decoder.decode([String: String].self, from: data)

            // The response contains paths as keys and signed URLs as values
            // Note: Response keys are the storage paths WITHOUT the bucket prefix
            if let signedURL = signedURLs[storagePath] ?? signedURLs.values.first {
                hlog("Signed URL generated (expires in \(expiresIn)s)", "SUCCESS")
                return signedURL
            } else {
                throw APIError.serverError
            }
        } else {
            hlog("Failed to generate signed URL (\(httpResponse.statusCode))", "ERROR")
            throw APIError.serverError
        }
    }

    // MARK: - Analytics API

    func sendUsageEvents(_ events: [UsageEventData], userId: String) async throws {
        // Convert UsageEventData to payload format for Supabase
        let payloads = events.map { event in
            UsageEventPayload(
                id: event.id,
                user_id: userId,
                user_email: event.userEmail,
                event_type: event.eventType,
                moment_type: event.momentType,
                timestamp: event.timestamp.ISO8601Format()
            )
        }

        // Use on_conflict=id with ignore-duplicates so stale local events never block new ones
        let endpoint = "/rest/v1/usage_events?on_conflict=id"
        _ = try await makeRequest(
            method: "POST",
            endpoint: endpoint,
            body: payloads,
            responseType: [UsageEventPayload].self,
            preferHeader: "resolution=ignore-duplicates,return=representation"
        )
    }

    /// T-116: anon-key insert (no JWT exists yet) — matches the `usage_events` RLS policy's
    /// `anonymous_id IS NOT NULL AND user_id IS NULL` allowance. Uses `return=minimal`
    /// (not `return=representation`, unlike `sendUsageEvents`): there is no SELECT policy
    /// that lets an unauthenticated anon-key request read back an anonymous row it just
    /// inserted, so asking Postgres to RETURN it turns into its own RLS violation. Also
    /// skips `sendUsageEvents`'s `on_conflict=id` upsert — PostgREST's ON CONFLICT path
    /// evaluates the SELECT policy too (to check for an existing row), hitting the exact
    /// same RLS wall; a plain insert is fine since these IDs are freshly generated UUIDs.
    func sendAnonymousUsageEvents(_ events: [AnonymousUsageEventData]) async throws {
        let payloads = events.map { event in
            AnonymousUsageEventPayload(
                id: event.id,
                anonymous_id: event.anonymousId,
                event_type: event.eventType,
                moment_type: event.momentType,
                timestamp: event.timestamp.ISO8601Format()
            )
        }

        let endpoint = "/rest/v1/usage_events"
        _ = try await makeRequest(
            method: "POST",
            endpoint: endpoint,
            body: payloads,
            responseType: EmptyResponse.self,
            preferHeader: "return=minimal"
        )
    }

    // MARK: - LLM API (T-168)

    func callLLM(messages: [LLMMessage], feature: String, maxTokens: Int?, context: LLMRequestContext?, closer: String?) async throws -> LLMResponse {
        // T-107: every call (capture conversation, journal synthesis, prayer
        // generation once T-147 lands, etc.) goes through this one chokepoint, so
        // routing it through LLMGateway here covers all of them with no call-site
        // changes required.
        try await LLMGateway.shared.execute(feature: feature, requestedMaxTokens: maxTokens) { clampedMaxTokens in
            let payload = LLMProxyPayload(messages: messages, feature: feature, max_tokens: clampedMaxTokens, capture_id: context?.captureId, request_id: context?.requestId, capture_kind: context?.kind.rawValue, closer: closer)
            return try await self.makeRequest(
                method: "POST",
                endpoint: "/functions/v1/llm-proxy",
                body: payload,
                responseType: LLMResponse.self
            )
        }
    }
}

// MARK: - Payload and Response Models

struct LLMProxyPayload: Encodable {
    let messages: [LLMMessage]
    let feature: String
    // Real narrative body-synthesis (Nov 11 2026) needs more room than this proxy's
    // own 1000-token default (title+excerpt+verse alone fit comfortably in that; a
    // 2-3 paragraph body does not) -- nil lets every other feature keep using the
    // proxy's own default unchanged.
    let max_tokens: Int?
    // Per-capture budget ledger ids (nil for calls outside a capture, e.g. the retry sweep).
    let capture_id: String?
    let request_id: String?
    let capture_kind: String?
    // Names a SERVER-OWNED fixed reply ("onboarding_final"). Never carries text.
    let closer: String?
}

struct MomentPayload: Codable {
    let id: String
    let user_id: String
    let body: String
    let sense_of_lord: String?
    let created_at: String
    let updated_at: String
    let audio_url: String?
}

struct JournalEntryPayload: Codable {
    let id: String
    let moment_id: String
    let user_id: String
    let status: String
    let title: String?
    let body: String?
    let moods: [String]
    let scripture_quote: String?
    let scripture_reference: String?
    let starred: Bool
    let edited: Bool
    let created_at: String
    let updated_at: String
    let formation_eligible: Bool
    let extracted_facts: String?
    let profile_excluded: Bool?
    let photo_path: NullableString?
}

/// Encodes nil as JSON null (unlike a plain optional, which is left out).
struct NullableString: Codable {
    let value: String?
    init(value: String?) { self.value = value }
    init(from decoder: Decoder) throws { value = try decoder.singleValueContainer().decode(String?.self) }
    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        if let value { try c.encode(value) } else { try c.encodeNil() }
    }
}

struct DwellerProfilePayload: Codable {
    let user_id: String
    let running_summary: String?
    let updated_at: String
}

struct CustomMoodPayload: Codable {
    let user_id: String
    let word: String
}

struct NarrativeFeedbackPayload: Codable {
    let user_id: String
    let feedback_text: String
    let narrative_at_time: String?
}

struct SubmitFeedbackPayload: Codable {
    let category: String?
    let message: String?
    let app_version: String?
    let screenshot_path: String?
    let retry_submission_id: String?
}

struct SubmitFeedbackResponse: Codable {
    let ok: Bool
    let id: String?
    let created_at: String?
    let emailed: Bool?
    let resend_configured: Bool?
    let error: String?
}

struct LoginPayload: Encodable {
    let email: String
    let password: String
}

struct PasswordResetPayload: Encodable {
    let email: String
}

struct VerifyOTPPayload: Encodable {
    let type: String
    let email: String
    let token: String
}

struct SendOTPPayload: Encodable {
    let email: String
    let create_user: Bool
}

struct ResendPayload: Encodable {
    let type: String
    let email: String
}

/// GoTrue's error body shape, e.g. {"code":400,"error_code":"user_already_exists","msg":"User already registered"}.
struct GoTrueError: Decodable {
    let msg: String?
    let error_description: String?
}

struct UserPayload: Encodable {
    let id: String
    let email: String
}

struct AuthResponse: Decodable {
    let access_token: String
    let refresh_token: String
    let token_type: String
    let expires_in: Int
    let user: UserResponse
}

struct UserResponse: Decodable {
    let id: String
    let email: String
    /// GoTrue's documented anti-enumeration signal: when "Confirm email" is on (this
    /// project's setting) and the address is already registered, /signup still returns
    /// 200 with this exact "pending confirmation" shape rather than a 422 — confirmed via
    /// Supabase's own edge logs Nov 4 2026, every signup call for this project comes back
    /// 200, duplicate or not. The one real difference: a genuinely new user's `identities`
    /// has one entry (the email provider); an existing user's is an empty array.
    let identities: [Identity]?
}

struct Identity: Decodable {
    let id: String
}

struct UsageEventPayload: Decodable {
    let id: String
    let user_id: String
    let user_email: String?
    let event_type: String
    let moment_type: String?
    let timestamp: String
}

extension UsageEventPayload: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(user_id, forKey: .user_id)
        try container.encodeIfPresent(user_email, forKey: .user_email)
        try container.encode(event_type, forKey: .event_type)
        try container.encodeIfPresent(moment_type, forKey: .moment_type)
        try container.encode(timestamp, forKey: .timestamp)
    }

    private enum CodingKeys: String, CodingKey {
        case id, user_id, user_email, event_type, moment_type, timestamp
    }
}

struct AnonymousUsageEventPayload: Codable {
    let id: String
    let anonymous_id: String
    let event_type: String
    let moment_type: String?
    let timestamp: String
}

struct SignedURLRequest: Encodable {
    let expiresIn: Int
    let paths: [String]
}

struct EmptyResponse: Decodable {}

struct SignedURLResponse: Decodable {
    let signedUrl: String
}

// MARK: - Rate Limiter

class RateLimiter {
    private let maxRequestsPerMinute = 100
    private let windowDuration: TimeInterval = 60

    private var requestTimestamps: [Date] = []
    private let queue = DispatchQueue(label: "com.dwelly.ratelimiter")

    func shouldAllowRequest() -> Bool {
        return queue.sync {
            let now = Date()
            let cutoffTime = now.addingTimeInterval(-windowDuration)

            requestTimestamps.removeAll { $0 < cutoffTime }

            if requestTimestamps.count < maxRequestsPerMinute {
                requestTimestamps.append(now)
                return true
            }

            return false
        }
    }
}

// MARK: - Certificate Pinning

class CertificatePinner {
    // Public key hashes for Supabase domain
    // Updated: March 19, 2026 with actual certificate chain from device
    private let pinnedPublicKeyHashes: Set<String> = [
        // Leaf certificate (primary)
        "M4FlSvpxk5vEw3n70qj3t4y7QuYUHuzwkh9Earv1FNQ=",
        // Intermediate certificate (backup for chain validation)
        "H7AMYAvicN2+UcFPBz3kJXCDmGrTItZh4ujUBK8hoWg=",
        // Root certificate (backup for chain validation)
        "YSoUL4CBzo5aJ/ES9gSZTsavsgtHsiLLnTG+BKUdork="
    ]

    func validateCertificate(_ challenge: URLAuthenticationChallenge) -> Bool {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            hlog("Certificate pinning: No server trust provided", "ERROR")
            return false
        }

        // Verify the certificate chain is valid
        var secResult = SecTrustResultType.invalid
        let status = SecTrustEvaluate(serverTrust, &secResult)

        guard status == errSecSuccess else {
            hlog("Certificate pinning: Trust evaluation failed", "ERROR")
            return false
        }

        // Get the certificate chain count
        let certificateCount = SecTrustGetCertificateCount(serverTrust)
        guard certificateCount > 0 else {
            hlog("Certificate pinning: No certificates in chain", "ERROR")
            return false
        }

        // Check public key hashes
        for i in 0..<certificateCount {
            if let certificate = SecTrustGetCertificateAtIndex(serverTrust, i) {
                let publicKeyHash = publicKeyHashFromCertificate(certificate)
                if pinnedPublicKeyHashes.contains(publicKeyHash) {
                    hlog("Certificate pinning: Valid certificate pinned ✓", "SUCCESS")
                    return true
                }
            }
        }

        hlog("Certificate pinning: No matching public key found in chain", "ERROR")
        return false
    }

    private func publicKeyHashFromCertificate(_ certificate: SecCertificate) -> String {
        // Extract public key from certificate
        guard let publicKey = SecCertificateCopyKey(certificate) else {
            return ""
        }

        // Get DER representation of the public key
        var error: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            return ""
        }

        // SHA256 hash of the public key
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        publicKeyData.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(publicKeyData.count), &digest)
        }

        // Base64 encode the hash
        return Data(digest).base64EncodedString()
    }
}

class CertificatePinningDelegate: NSObject, URLSessionDelegate {
    private let pinner: CertificatePinner

    init(pinner: CertificatePinner) {
        self.pinner = pinner
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Only validate for HTTPS server trust challenges
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // Validate certificate pinning
        if pinner.validateCertificate(challenge) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            } else {
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        } else {
            hlog("Certificate pinning FAILED — connection rejected for security", "ERROR")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}


extension Notification.Name {
    /// Posted when the saved sign-in can no longer be renewed; AppView signs out.
    static let sessionExpired = Notification.Name("dwelly.sessionExpired")
}

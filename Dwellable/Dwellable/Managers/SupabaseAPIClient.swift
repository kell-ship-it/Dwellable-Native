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
                    try await refreshJWTToken()
                    return try await makeRequest(method: method, endpoint: endpoint, body: body,
                                                 responseType: responseType, requiresAuth: requiresAuth,
                                                 preferHeader: preferHeader, isRetry: true)
                }
                hlog("JWT refresh failed or no refresh token — user must log in again", "ERROR")
                throw APIError.unauthorized
            case 404:
                throw APIError.notFound
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
        let endpoint = "/rest/v1/moments?id=eq.\(id)"
        _ = try await makeRequest(
            method: "DELETE",
            endpoint: endpoint,
            responseType: EmptyResponse.self
        )
    }

    // MARK: - Auth API

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
        // Create user record in public.users if it doesn't exist
        // Using upsert (insert...on conflict do nothing)
        let payload = UserPayload(id: userId, email: email)
        let endpoint = "/rest/v1/users?on_conflict=id"

        _ = try await makeRequest(
            method: "POST",
            endpoint: endpoint,
            body: payload,
            responseType: UserResponse.self
        )
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
}

// MARK: - Payload and Response Models

struct MomentPayload: Codable {
    let id: String
    let user_id: String
    let body: String
    let sense_of_lord: String?
    let created_at: String
    let updated_at: String
    let audio_url: String?
}

struct LoginPayload: Encodable {
    let email: String
    let password: String
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
    private let queue = DispatchQueue(label: "com.dwellable.ratelimiter")

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

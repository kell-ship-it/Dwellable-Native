import Foundation

class SupabaseAPIClient: APIClient {
    private let baseURL: String
    private let anonKey: String
    private let session: URLSession

    init(baseURL: String = Config.supabaseURL, anonKey: String = Config.supabaseAnonKey) {
        self.baseURL = baseURL
        self.anonKey = anonKey
        self.session = URLSession.shared
    }

    private func makeRequest<T: Decodable>(
        method: String,
        endpoint: String,
        body: Encodable? = nil,
        responseType: T.Type,
        requiresAuth: Bool = true
    ) async throws -> T {
        var urlComponents = URLComponents(string: baseURL)

        // Separate endpoint path from query string
        if let queryIndex = endpoint.firstIndex(of: "?") {
            let pathPart = String(endpoint[..<queryIndex])
            let queryPart = String(endpoint[endpoint.index(after: queryIndex)...])

            urlComponents?.path = pathPart

            // Parse query parameters and add them properly
            let queryItems = queryPart.split(separator: "&").map { param in
                let parts = param.split(separator: "=", maxSplits: 1)
                let name = String(parts[0])
                let value = parts.count > 1 ? String(parts[1]) : ""
                return URLQueryItem(name: name, value: value)
            }
            urlComponents?.queryItems = queryItems
        } else {
            urlComponents?.path = endpoint
        }

        guard let url = urlComponents?.url else {
            throw APIError.invalidRequest
        }

        // Debug: Log the request details
        print("🔵 API Request: \(method) \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        if requiresAuth {
            request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Tell Supabase to return the created/updated record in response
        if method == "POST" || method == "PATCH" || method == "PUT" {
            request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        }

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError
            }

            // Debug: Log response
            if let responseString = String(data: data, encoding: .utf8) {
                print("🟢 Response (\(httpResponse.statusCode)): \(responseString.prefix(500))")
            }

            switch httpResponse.statusCode {
            case 200...299:
                let decoder = JSONDecoder()
                // Supabase returns ISO 8601 dates with fractional seconds
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    // Try fractional seconds first, then standard ISO 8601
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                    if let date = ISO8601DateFormatter().date(from: dateString) {
                        return date
                    }
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date: \(dateString)")
                }
                return try decoder.decode(T.self, from: data)
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
            print("🔴 Network Error: \(error.localizedDescription)")
            print("🔴 Full Error: \(error)")
            throw APIError.networkError
        }
    }

    // MARK: - Moments API

    func saveMoment(_ moment: Moment) async throws -> Moment {
        let payload = MomentPayload(
            user_id: moment.userId,
            body: moment.body,
            created_at: moment.createdAt.ISO8601Format(),
            updated_at: Date().ISO8601Format()
        )

        // Build request manually to avoid decoding the response
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.path = "/rest/v1/moments"

        guard let url = urlComponents?.url else {
            throw APIError.invalidRequest
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 15 // 15 second timeout
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        print("🔵 API Request: POST \(url)")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }

        if let responseString = String(data: data, encoding: .utf8) {
            print("🟢 Save Response (\(httpResponse.statusCode)): \(responseString.prefix(500))")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            print("🔴 Save failed with status: \(httpResponse.statusCode)")
            throw APIError.serverError
        }

        // Save succeeded — return the local moment (no need to decode response)
        print("✅ Moment saved successfully")
        return moment
    }

    func fetchMoments(userId: String) async throws -> [Moment] {
        let endpoint = "/rest/v1/moments?user_id=eq.\(userId)&order=created_at.desc"
        return try await makeRequest(
            method: "GET",
            endpoint: endpoint,
            responseType: [Moment].self
        )
    }

    func fetchMoment(id: String) async throws -> Moment {
        let endpoint = "/rest/v1/moments?id=eq.\(id)"
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
        let payload = LoginPayload(email: email, password: password)
        let endpoint = "/auth/v1/token?grant_type=password"

        let response = try await makeRequest(
            method: "POST",
            endpoint: endpoint,
            body: payload,
            responseType: AuthResponse.self,
            requiresAuth: false
        )

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
}

// MARK: - Payload and Response Models

struct MomentPayload: Encodable {
    let user_id: String
    let body: String
    let created_at: String
    let updated_at: String
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
    let token_type: String
    let expires_in: Int
    let user: UserResponse
}

struct UserResponse: Decodable {
    let id: String
    let email: String
}

struct EmptyResponse: Decodable {}

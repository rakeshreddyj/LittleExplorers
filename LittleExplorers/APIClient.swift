import Foundation

struct APIError: LocalizedError {
    let status: Int
    let detail: String
    var errorDescription: String? { detail }
}

extension Notification.Name {
    static let sessionExpired = Notification.Name("sessionExpired")
}

struct Session: Codable {
    let api_key: String
    let email: String
    let name: String
}

/// Child profile as stored on the HomeBuddy backend (/api/v1/kids). Settings are edited from the HomeBuddy app.
struct KidProfile: Codable, Identifiable, Equatable {
    let id: Int
    var name: String
    var grade: String            // "UKG" or "C1"
    var daily_limit_min: Int
    var plan_rounds: Int
    var languages: [String]      // subset of ["te", "hi"]
    var stickers: Int
    var bonus_today_min: Int
    var updated_at: String
}

struct KidSyncPayload: Encodable {
    struct Skill: Encodable { let skill_id: String; let name: String; let subject: String; let lvl: Int; let correct: Int; let total: Int }
    struct Day: Encodable { let date: String; let secs: Int; let rounds: Int; let stars: Int; let questions: Int; let correct: Int }
    let skills: [Skill]
    let days: [Day]
    let stickers: Int
    let today: String   // this iPad's local date, so bonus minutes from HomeBuddy land on the same day
}

/// Thin async/await wrapper over the /api/v1 endpoints the kids app needs.
final class APIClient {
    static let shared = APIClient()
    /// Set by AuthStore; starts from the Keychain so the app stays signed in across launches.
    var apiKey: String? = Keychain.get("api_key")
    private let decoder = JSONDecoder()

    private func request(_ method: String, _ path: String, body: Data? = nil, auth: Bool = true,
                         timeout: TimeInterval = 30) async throws -> Data {
        var req = URLRequest(url: Config.baseURL.appendingPathComponent("api/v1" + path))
        req.httpMethod = method
        req.timeoutInterval = timeout
        if auth, let key = apiKey { req.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization") }
        if let body { req.httpBody = body; req.setValue("application/json", forHTTPHeaderField: "Content-Type") }
        let (data, resp) = try await URLSession.shared.data(for: req)
        let status = (resp as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            let detail = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["detail"] as? String
            if status == 401, auth { NotificationCenter.default.post(name: .sessionExpired, object: nil) }
            throw APIError(status: status, detail: detail ?? "Request failed (\(status))")
        }
        return data
    }

    private func json<T: Encodable>(_ v: T) -> Data { try! JSONEncoder().encode(v) }

    // Auth
    func signInWithApple(identityToken: String, name: String?) async throws -> Session {
        struct B: Encodable { let identity_token: String; let name: String? }
        let d = try await request("POST", "/auth/apple", body: json(B(identity_token: identityToken, name: name)), auth: false)
        return try decoder.decode(Session.self, from: d)
    }
    func signIn(code: String) async throws -> Session {
        let d = try await request("POST", "/auth/code", body: json(["code": code]), auth: false)
        return try decoder.decode(Session.self, from: d)
    }

    // Kids
    func profiles() async throws -> [KidProfile] {
        try decoder.decode([KidProfile].self, from: try await request("GET", "/kids/profiles"))
    }
    func createProfile(name: String, grade: String) async throws -> KidProfile {
        try decoder.decode(KidProfile.self, from: try await request("POST", "/kids/profiles", body: json(["name": name, "grade": grade])))
    }
    func sync(profileId: Int, _ payload: KidSyncPayload) async throws -> KidProfile {
        try decoder.decode(KidProfile.self, from: try await request("POST", "/kids/profiles/\(profileId)/sync", body: json(payload)))
    }
}

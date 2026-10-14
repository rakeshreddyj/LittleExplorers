import AuthenticationServices
import Foundation

/// A grown-up signs in once with their HomeBuddy account; the child never sees this.
@MainActor
final class AuthStore: ObservableObject {
    @Published var session: Session?
    @Published var error: String?

    init() {
        if let key = Keychain.get("api_key"), let email = Keychain.get("email") {
            session = Session(api_key: key, email: email, name: Keychain.get("name") ?? email)
        }
        NotificationCenter.default.addObserver(forName: .sessionExpired, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.signOut() }
        }
        #if DEBUG
        if session == nil, let code = ProcessInfo.processInfo.environment["HB_DEMO_CODE"] {
            Task { await signIn(code: code) }
        }
        #endif
    }

    func signInWithApple(_ result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let auth):
            guard let cred = auth.credential as? ASAuthorizationAppleIDCredential,
                  let data = cred.identityToken, let token = String(data: data, encoding: .utf8) else {
                error = "Apple didn't return a sign-in token"; return
            }
            let name = [cred.fullName?.givenName, cred.fullName?.familyName].compactMap { $0 }.joined(separator: " ")
            do { store(try await APIClient.shared.signInWithApple(identityToken: token, name: name.isEmpty ? nil : name)) }
            catch { self.error = error.localizedDescription }
        case .failure(let e):
            if (e as? ASAuthorizationError)?.code != .canceled { error = e.localizedDescription }
        }
    }

    func signIn(code: String) async {
        do { store(try await APIClient.shared.signIn(code: code)) }
        catch { self.error = error.localizedDescription }
    }

    private func store(_ s: Session) {
        Keychain.set(s.api_key, for: "api_key"); Keychain.set(s.email, for: "email"); Keychain.set(s.name, for: "name")
        APIClient.shared.apiKey = s.api_key
        session = s; error = nil
    }

    func signOut() {
        ["api_key", "email", "name"].forEach(Keychain.delete)
        APIClient.shared.apiKey = nil
        UserDefaults.standard.removeObject(forKey: "profile_id")
        session = nil
    }
}

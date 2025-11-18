import Foundation
import Supabase
import AuthenticationServices

class AuthService {
    static let shared = AuthService()
    private let supabase = SupabaseManager.shared

    private init() {}

    // MARK: - Login
    func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await APIClient.shared.request(
            endpoint: Configuration.Endpoint.login,
            method: .post,
            body: request
        )

        // Save token to keychain
        KeychainHelper.shared.saveToken(response.token)

        return response
    }

    // MARK: - Register
    func register(email: String, password: String, name: String) async throws -> AuthResponse {
        let request = RegisterRequest(email: email, password: password, name: name)
        let response: AuthResponse = try await APIClient.shared.request(
            endpoint: Configuration.Endpoint.register,
            method: .post,
            body: request
        )

        // Save token to keychain
        KeychainHelper.shared.saveToken(response.token)

        return response
    }

    // MARK: - Get Current User
    func getCurrentUser() async throws -> User {
        struct UserResponse: Codable {
            let user: User
        }

        let response: UserResponse = try await APIClient.shared.request(
            endpoint: Configuration.Endpoint.me,
            requiresAuth: true
        )

        return response.user
    }

    // MARK: - Logout
    func logout() {
        KeychainHelper.shared.deleteToken()
    }

    // MARK: - Check if authenticated
    func isAuthenticated() -> Bool {
        return KeychainHelper.shared.getToken() != nil
    }

    // MARK: - OAuth with Google
    func loginWithGoogle() async throws -> User {
        // Sign in with Supabase OAuth
        try await supabase.auth.signInWithOAuth(
            provider: .google,
            redirectTo: URL(string: "\(Configuration.appURLScheme)://auth/callback")
        )

        // Wait for session
        let session = try await supabase.auth.session

        // Sync with backend
        let user = try await syncOAuthUser(
            email: session.user.email ?? "",
            name: session.user.userMetadata["full_name"]?.value as? String ?? "",
            supabaseId: session.user.id.uuidString
        )

        return user
    }

    // MARK: - OAuth with Apple
    func loginWithApple(authorization: ASAuthorization) async throws -> User {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw NSError(domain: "AuthService", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid Apple ID credential"])
        }

        guard let identityToken = appleIDCredential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw NSError(domain: "AuthService", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])
        }

        // Sign in with Supabase
        try await supabase.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: tokenString
            )
        )

        // Wait for session
        let session = try await supabase.auth.session

        // Get name from Apple ID or use email
        let fullName = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")
        let name = fullName.isEmpty ? (session.user.email ?? "User") : fullName

        // Sync with backend
        let user = try await syncOAuthUser(
            email: session.user.email ?? "",
            name: name,
            supabaseId: session.user.id.uuidString
        )

        return user
    }

    // MARK: - Sync OAuth User with Backend
    private func syncOAuthUser(email: String, name: String, supabaseId: String) async throws -> User {
        struct OAuthSyncRequest: Codable {
            let email: String
            let name: String
            let supabaseId: String
        }

        struct OAuthSyncResponseWrapper: Codable {
            let data: OAuthSyncData
        }

        struct OAuthSyncData: Codable {
            let user: User
            let token: String
        }

        let request = OAuthSyncRequest(email: email, name: name, supabaseId: supabaseId)
        let wrapper: OAuthSyncResponseWrapper = try await APIClient.shared.request(
            endpoint: Configuration.Endpoint.oauthSync,
            method: .post,
            body: request
        )

        // Save token to keychain
        KeychainHelper.shared.saveToken(wrapper.data.token)

        return wrapper.data.user
    }
}

import Foundation
import Supabase
import AuthenticationServices

class OAuthService {
    static let shared = OAuthService()
    private init() {}

    private lazy var supabase: SupabaseClient = {
        SupabaseClient(
            supabaseURL: URL(string: Configuration.supabaseURL)!,
            supabaseKey: Configuration.supabaseAnonKey
        )
    }()

    // MARK: - Sign In with Google
    @MainActor
    func signInWithGoogle() async throws -> AuthResponse {
        // Sign in with Supabase OAuth
        try await supabase.auth.signInWithOAuth(
            provider: .google,
            redirectTo: URL(string: "\(Configuration.appURLScheme)://auth/callback")
        )

        // Wait for session
        guard let session = try await waitForSession() else {
            throw APIError.serverError("OAuth session not established")
        }

        // Sync with backend
        return try await syncWithBackend(session: session)
    }

    // MARK: - Sign In with Apple
    @MainActor
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws -> AuthResponse {
        // Extract identity token
        guard let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw APIError.serverError("Failed to get identity token")
        }

        // Sign in with Supabase using Apple ID token
        try await supabase.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: tokenString
            )
        )

        // Wait for session
        guard let session = try await waitForSession() else {
            throw APIError.serverError("OAuth session not established")
        }

        // Sync with backend
        return try await syncWithBackend(session: session)
    }

    // MARK: - Handle OAuth Callback
    @MainActor
    func handleOAuthCallback(url: URL) async throws -> AuthResponse {
        // Let Supabase handle the callback
        try await supabase.auth.session(from: url)

        // Get the session
        let session = try await supabase.auth.session

        // Sync with backend
        return try await syncWithBackend(session: session)
    }

    // MARK: - Sync with Backend
    private func syncWithBackend(session: Session) async throws -> AuthResponse {
        // Extract user info from Supabase session
        let email = session.user.email ?? ""

        // Try to get name from user metadata
        var name = email.components(separatedBy: "@").first ?? "User"
        if let fullName = session.user.userMetadata["full_name"]?.stringValue {
            name = fullName
        } else if let metaName = session.user.userMetadata["name"]?.stringValue {
            name = metaName
        }

        let supabaseId = session.user.id.uuidString

        // Call backend OAuth sync endpoint
        struct OAuthSyncRequest: Codable {
            let email: String
            let name: String
            let supabaseId: String

            enum CodingKeys: String, CodingKey {
                case email, name
                case supabaseId = "supabaseId"
            }
        }

        let request = OAuthSyncRequest(
            email: email,
            name: name,
            supabaseId: supabaseId
        )

        let response: AuthResponse = try await APIClient.shared.request(
            endpoint: Configuration.Endpoint.oauthSync,
            method: .post,
            body: request
        )

        // Save JWT token from backend
        KeychainHelper.shared.saveToken(response.token)

        return response
    }

    // MARK: - Wait for Session
    private func waitForSession(timeout: TimeInterval = 10.0) async throws -> Session? {
        let startTime = Date()

        while Date().timeIntervalSince(startTime) < timeout {
            if let session = try? await supabase.auth.session {
                return session
            }

            // Wait 500ms before trying again
            try await Task.sleep(nanoseconds: 500_000_000)
        }

        return nil
    }

    // MARK: - Sign Out
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
}

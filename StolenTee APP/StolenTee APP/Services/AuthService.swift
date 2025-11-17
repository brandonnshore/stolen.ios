import Foundation

class AuthService {
    static let shared = AuthService()
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
}

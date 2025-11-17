import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        checkAuthStatus()
    }

    // MARK: - Check Auth Status
    func checkAuthStatus() {
        isAuthenticated = AuthService.shared.isAuthenticated()

        if isAuthenticated {
            Task {
                await loadCurrentUser()
            }
        }
    }

    // MARK: - Load Current User
    func loadCurrentUser() async {
        do {
            currentUser = try await AuthService.shared.getCurrentUser()
            isAuthenticated = true
        } catch {
            // Token might be expired, clear it
            await logout()
        }
    }

    // MARK: - Login
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await AuthService.shared.login(email: email, password: password)
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Register
    func register(email: String, password: String, name: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await AuthService.shared.register(email: email, password: password, name: name)
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Logout
    func logout() async {
        AuthService.shared.logout()
        currentUser = nil
        isAuthenticated = false
    }

    // MARK: - OAuth (Stub methods - to be implemented)
    func loginWithGoogle() async throws {
        // TODO: Implement Google OAuth
        throw NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google Sign-In not yet implemented"])
    }

    func handleSignInWithApple(_ request: Any) {
        // TODO: Implement Apple Sign-In
    }

    func handleSignInWithAppleCompletion(_ authorization: Any) {
        // TODO: Implement Apple Sign-In completion
    }
}

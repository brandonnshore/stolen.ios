import SwiftUI
import Supabase

@main
struct StolenTeeApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var cartViewModel = CartViewModel()
    @StateObject private var productsViewModel = ProductsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(cartViewModel)
                .environmentObject(productsViewModel)
                .onAppear {
                    authViewModel.checkAuthStatus()
                }
                .task {
                    // Load products on app startup
                    await productsViewModel.loadProducts()
                }
                .onOpenURL { url in
                    // Handle OAuth callback from Supabase
                    Task {
                        await handleOAuthCallback(url)
                    }
                }
        }
    }

    // MARK: - OAuth Callback Handler
    private func handleOAuthCallback(_ url: URL) async {
        // Let Supabase handle the OAuth session
        do {
            try await SupabaseManager.shared.auth.session(from: url)

            // Get the session
            let session = try await SupabaseManager.shared.auth.session

            // Sync with backend
            let user = try await syncOAuthUser(
                email: session.user.email ?? "",
                name: session.user.userMetadata["full_name"]?.value as? String ?? "",
                supabaseId: session.user.id.uuidString
            )

            // Update auth state on main thread
            await MainActor.run {
                authViewModel.currentUser = user
                authViewModel.isAuthenticated = true
            }
        } catch {
            print("OAuth callback error: \(error.localizedDescription)")
        }
    }

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

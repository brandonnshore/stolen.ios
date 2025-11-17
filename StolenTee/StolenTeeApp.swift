import SwiftUI

@main
struct StolenTeeApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var cartViewModel = CartViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(cartViewModel)
                .onAppear {
                    authViewModel.checkAuthStatus()
                }
        }
    }
}

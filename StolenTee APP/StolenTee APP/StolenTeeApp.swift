import SwiftUI

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
        }
    }
}

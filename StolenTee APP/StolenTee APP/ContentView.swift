import SwiftUI

enum AppTab: Int, Hashable {
    case home = 0
    case products = 1
    case cart = 2
    case designs = 3
    case profile = 4
}

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppTab.home)

            ProductsView()
                .tabItem {
                    Label("Products", systemImage: "tshirt.fill")
                }
                .tag(AppTab.products)

            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart.fill")
                }
                .tag(AppTab.cart)
                .environment(\.navigateToProducts, {
                    selectedTab = .products
                })

            if authViewModel.isAuthenticated {
                DashboardView()
                    .tabItem {
                        Label("Designs", systemImage: "paintbrush.fill")
                    }
                    .tag(AppTab.designs)
            }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(authViewModel.isAuthenticated ? AppTab.profile : AppTab.designs)
        }
    }
}

// Environment key for navigation to products
private struct NavigateToProductsKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var navigateToProducts: () -> Void {
        get { self[NavigateToProductsKey.self] }
        set { self[NavigateToProductsKey.self] = newValue }
    }
}

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            ProductsView()
                .tabItem {
                    Label("Products", systemImage: "tshirt.fill")
                }

            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart.fill")
                }

            if authViewModel.isAuthenticated {
                DashboardView()
                    .tabItem {
                        Label("Designs", systemImage: "paintbrush.fill")
                    }
            }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

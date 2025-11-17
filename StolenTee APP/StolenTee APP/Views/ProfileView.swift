import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingLogoutConfirmation = false
    @State private var showToast = false
    @State private var toastMessage = ""

    var body: some View {
        NavigationStack {
            List {
                if authViewModel.isAuthenticated {
                    authenticatedContent
                } else {
                    unauthenticatedContent
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog("Sign Out", isPresented: $showingLogoutConfirmation) {
                Button("Sign Out", role: .destructive) {
                    Task {
                        await authViewModel.logout()
                        showToastMessage("Signed out successfully")
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .toast(isPresented: $showToast, message: toastMessage)
        }
    }

    // MARK: - Authenticated Content

    private var authenticatedContent: some View {
        Group {
            // Profile Section
            Section {
                if let user = authViewModel.currentUser {
                    HStack(spacing: Theme.Spacing.md) {
                        // Avatar
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.purple, Color.blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(user.name?.prefix(1).uppercased() ?? "U")
                                    .font(Theme.Typography.headlineSmall)
                                    .foregroundColor(.white)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name ?? "User")
                                .font(Theme.Typography.titleLarge)
                                .foregroundColor(Theme.Colors.text)

                            Text(user.email)
                                .font(Theme.Typography.bodyMedium)
                                .foregroundColor(Theme.Colors.textSecondary)
                        }

                        Spacer()

                        NavigationLink(destination: EditProfileView()) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.Colors.textTertiary)
                        }
                    }
                    .padding(.vertical, Theme.Spacing.sm)
                }
            }

            // Orders Section
            Section("Orders") {
                NavigationLink(destination: OrderHistoryView()) {
                    SettingsRow(
                        icon: "shippingbox.fill",
                        iconColor: .blue,
                        title: "Order History",
                        subtitle: "View your past orders"
                    )
                }

                NavigationLink(destination: Text("Track Order")) {
                    SettingsRow(
                        icon: "location.fill",
                        iconColor: .green,
                        title: "Track Order",
                        subtitle: "Track your shipments"
                    )
                }
            }

            // Account Section
            Section("Account") {
                NavigationLink(destination: Text("Account Settings")) {
                    SettingsRow(
                        icon: "person.fill",
                        iconColor: .orange,
                        title: "Account Settings"
                    )
                }

                NavigationLink(destination: Text("Saved Addresses")) {
                    SettingsRow(
                        icon: "house.fill",
                        iconColor: .purple,
                        title: "Saved Addresses"
                    )
                }

                NavigationLink(destination: Text("Payment Methods")) {
                    SettingsRow(
                        icon: "creditcard.fill",
                        iconColor: .green,
                        title: "Payment Methods"
                    )
                }
            }

            // Preferences Section
            Section("Preferences") {
                NavigationLink(destination: Text("Notifications")) {
                    SettingsRow(
                        icon: "bell.fill",
                        iconColor: .red,
                        title: "Notifications"
                    )
                }

                NavigationLink(destination: Text("Appearance")) {
                    SettingsRow(
                        icon: "paintpalette.fill",
                        iconColor: .pink,
                        title: "Appearance"
                    )
                }
            }

            // Support Section
            Section("Support") {
                Link(destination: URL(string: "https://stolentee.com/help")!) {
                    SettingsRow(
                        icon: "questionmark.circle.fill",
                        iconColor: .blue,
                        title: "Help Center"
                    )
                }

                Link(destination: URL(string: "mailto:support@stolentee.com")!) {
                    SettingsRow(
                        icon: "envelope.fill",
                        iconColor: .purple,
                        title: "Contact Us"
                    )
                }

                NavigationLink(destination: Text("About")) {
                    SettingsRow(
                        icon: "info.circle.fill",
                        iconColor: .gray,
                        title: "About"
                    )
                }
            }

            // Sign Out Section
            Section {
                Button(action: {
                    showingLogoutConfirmation = true
                }) {
                    HStack {
                        Spacer()
                        Text("Sign Out")
                            .font(Theme.Typography.titleMedium)
                            .foregroundColor(Theme.Colors.error)
                        Spacer()
                    }
                }
            }

            // Version Info
            Section {
                HStack {
                    Spacer()
                    Text("Version 1.0.0")
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textTertiary)
                    Spacer()
                }
            }
        }
    }

    // MARK: - Unauthenticated Content

    private var unauthenticatedContent: some View {
        Group {
            Section {
                VStack(spacing: Theme.Spacing.lg) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 80))
                        .foregroundColor(Theme.Colors.textTertiary)

                    VStack(spacing: Theme.Spacing.sm) {
                        Text("Sign In Required")
                            .font(Theme.Typography.headlineSmall)
                            .foregroundColor(Theme.Colors.text)

                        Text("Sign in to save designs, track orders, and more")
                            .font(Theme.Typography.bodyMedium)
                            .foregroundColor(Theme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: Theme.Spacing.sm) {
                        NavigationLink(destination: LoginView()) {
                            Text("Sign In")
                                .fontWeight(.semibold)
                        }
                        .primaryButtonStyle()

                        NavigationLink(destination: RegisterView()) {
                            Text("Create Account")
                        }
                        .secondaryButtonStyle()
                    }
                }
                .padding(.vertical, Theme.Spacing.xl)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            // Guest Features
            Section("Available Without Account") {
                NavigationLink(destination: ProductsView()) {
                    SettingsRow(
                        icon: "tshirt.fill",
                        iconColor: .purple,
                        title: "Browse Products"
                    )
                }

                Link(destination: URL(string: "https://stolentee.com/help")!) {
                    SettingsRow(
                        icon: "questionmark.circle.fill",
                        iconColor: .blue,
                        title: "Help Center"
                    )
                }

                NavigationLink(destination: Text("About")) {
                    SettingsRow(
                        icon: "info.circle.fill",
                        iconColor: .gray,
                        title: "About"
                    )
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
    }
}

// MARK: - Settings Row Component

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String?
    var value: String?

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(iconColor)
                .cornerRadius(Theme.CornerRadius.xs)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.bodyLarge)
                    .foregroundColor(Theme.Colors.text)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }

            Spacer()

            if let value = value {
                Text(value)
                    .font(Theme.Typography.bodyMedium)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Placeholder Views

struct EditProfileView: View {
    var body: some View {
        Text("Edit Profile")
            .navigationTitle("Edit Profile")
    }
}

struct OrderHistoryView: View {
    var body: some View {
        List {
            EmptyStateView(
                icon: "shippingbox",
                title: "No orders yet",
                message: "Your order history will appear here.",
                actionTitle: nil,
                action: nil
            )
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
        .navigationTitle("Order History")
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}

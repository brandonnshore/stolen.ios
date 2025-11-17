import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var designs: [Design] = []
    @State private var isLoading = false
    @State private var showingDeleteConfirmation = false
    @State private var designToDelete: Design?
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastView.ToastType = .info

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Stats Cards
                    statsSection

                    // Saved Designs Section
                    savedDesignsSection
                }
                .padding(.horizontal, Theme.Spacing.screenPadding)
                .padding(.vertical, Theme.Spacing.md)
            }
            .background(Theme.Colors.backgroundGrouped)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProductsView()) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .refreshable {
                await loadDesigns()
            }
        }
        .onAppear {
            Task {
                await loadDesigns()
            }
        }
        .confirmationDialog("Delete Design", isPresented: $showingDeleteConfirmation, presenting: designToDelete) { design in
            Button("Delete", role: .destructive) {
                deleteDesign(design)
            }
            Button("Cancel", role: .cancel) {}
        } message: { design in
            Text("Are you sure you want to delete '\(design.name)'?")
        }
        .toast(isPresented: $showToast, message: toastMessage, type: toastType)
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            if let user = authViewModel.currentUser {
                Text("Welcome back, \(user.name ?? "Designer")!")
                    .font(Theme.Typography.headlineSmall)
                    .foregroundColor(Theme.Colors.text)
            }

            HStack(spacing: Theme.Spacing.md) {
                DashboardStatCard(
                    title: "Saved Designs",
                    value: "\(designs.count)",
                    icon: "paintbrush.fill",
                    color: .purple
                )

                DashboardStatCard(
                    title: "Orders",
                    value: "0",
                    icon: "shippingbox.fill",
                    color: .blue,
                    subtitle: "Coming soon"
                )
            }
        }
    }

    // MARK: - Saved Designs Section

    private var savedDesignsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("Your Designs")
                    .font(Theme.Typography.headlineSmall)
                    .foregroundColor(Theme.Colors.text)

                Spacer()

                if !designs.isEmpty {
                    NavigationLink(destination: ProductsView()) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .semibold))
                            Text("New")
                                .font(Theme.Typography.labelMedium)
                        }
                        .foregroundColor(Theme.Colors.accent)
                    }
                }
            }

            if isLoading {
                loadingView
            } else if designs.isEmpty {
                emptyDesignsView
            } else {
                designsGrid
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: Theme.Spacing.md) {
            ForEach(0..<2, id: \.self) { _ in
                HStack(spacing: Theme.Spacing.md) {
                    SkeletonView()
                        .frame(height: 200)
                        .cornerRadius(Theme.CornerRadius.md)

                    SkeletonView()
                        .frame(height: 200)
                        .cornerRadius(Theme.CornerRadius.md)
                }
            }
        }
    }

    // MARK: - Empty Designs View

    private var emptyDesignsView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "paintbrush")
                .font(.system(size: 50))
                .foregroundColor(Theme.Colors.textTertiary)

            VStack(spacing: Theme.Spacing.sm) {
                Text("No designs yet")
                    .font(Theme.Typography.headlineSmall)
                    .foregroundColor(Theme.Colors.text)

                Text("Get started by creating your first custom design!")
                    .font(Theme.Typography.bodyMedium)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            NavigationLink(destination: ProductsView()) {
                Text("Create Design")
            }
            .primaryButtonStyle()
            .padding(.top, Theme.Spacing.sm)
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.lg)
    }

    // MARK: - Designs Grid

    private var designsGrid: some View {
        LazyVGrid(columns: Theme.Layout.gridColumns, spacing: Theme.Spacing.md) {
            ForEach(designs) { design in
                DesignCard(
                    design: design,
                    onEdit: {
                        // Navigate to customizer with this design
                    },
                    onDelete: {
                        designToDelete = design
                        showingDeleteConfirmation = true
                    }
                )
            }
        }
    }

    // MARK: - Helper Methods

    private func loadDesigns() async {
        isLoading = true
        // Load designs from API
        // For now, using mock data
        await Task.sleep(1_000_000_000) // 1 second delay
        isLoading = false
    }

    private func deleteDesign(_ design: Design) {
        withAnimation {
            designs.removeAll { $0.id == design.id }
        }
        toastMessage = "Design deleted"
        toastType = .info
        showToast = true

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Stat Card

struct DashboardStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(Theme.CornerRadius.sm)

                Spacer()
            }

            Text(value)
                .font(Theme.Typography.headlineMedium)
                .fontWeight(.bold)
                .foregroundColor(Theme.Colors.text)

            Text(title)
                .font(Theme.Typography.bodySmall)
                .foregroundColor(Theme.Colors.textSecondary)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(Theme.Typography.captionSmall)
                    .foregroundColor(Theme.Colors.textTertiary)
            }
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.md)
        .shadow(color: Theme.Shadows.small, radius: 2, y: 1)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}

import SwiftUI

struct ProductsView: View {
    @EnvironmentObject var viewModel: ProductsViewModel
    @State private var selectedCategory: String = "All"

    private let categories = ["T-Shirts", "Hoodies", "Sportswear", "Hats & Bags", "Women", "All"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("Choose from our")
                            .font(Theme.Typography.headlineLarge)
                            .foregroundColor(Theme.Colors.text)
                        Text("products")
                            .font(Theme.Typography.headlineLarge)
                            .foregroundColor(Theme.Colors.text)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Theme.Spacing.screenPadding)
                    .padding(.top, Theme.Spacing.md)

                    // Category Filter
                    categoryFilter

                    // Products Grid
                    if viewModel.isLoading {
                        loadingView
                    } else if let errorMessage = viewModel.errorMessage {
                        // Show error message
                        VStack(spacing: Theme.Spacing.md) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            Text("Error Loading Products")
                                .font(Theme.Typography.titleLarge)
                            Text(errorMessage)
                                .font(Theme.Typography.bodyMedium)
                                .foregroundColor(Theme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button("Retry") {
                                Task {
                                    await viewModel.loadProducts()
                                }
                            }
                            .primaryButtonStyle()
                            .padding(.horizontal)
                        }
                        .padding()
                    } else if viewModel.products.isEmpty {
                        EmptyStateView.noProducts()
                    } else {
                        productsGrid
                    }
                }
            }
            .background(Theme.Colors.background)
            .navigationTitle("Products")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await viewModel.loadProducts()
            }
        }
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        withAnimation(Theme.Animation.fast) {
                            selectedCategory = category
                        }
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }) {
                        Text(category)
                    }
                    .pillButtonStyle(isSelected: selectedCategory == category)
                }
            }
            .padding(.horizontal, Theme.Spacing.screenPadding)
        }
    }

    // MARK: - Products Grid

    private var productsGrid: some View {
        LazyVGrid(columns: Theme.Layout.gridColumns, spacing: Theme.Spacing.lg) {
            ForEach(filteredProducts) { product in
                NavigationLink(destination: CustomizerView(product: product, variants: product.variants ?? [])) {
                    ProductCard(product: product)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, Theme.Spacing.screenPadding)
        .padding(.bottom, Theme.Spacing.xl)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        LazyVGrid(columns: Theme.Layout.gridColumns, spacing: Theme.Spacing.lg) {
            ForEach(0..<4, id: \.self) { _ in
                ProductCardSkeleton()
            }
        }
        .padding(.horizontal, Theme.Spacing.screenPadding)
    }

    // MARK: - Filtered Products

    private var filteredProducts: [Product] {
        if selectedCategory == "All" {
            return viewModel.products
        }
        // Filter logic can be implemented when product categories are added to the model
        return viewModel.products
    }
}

#Preview {
    ProductsView()
        .environmentObject(ProductsViewModel())
}

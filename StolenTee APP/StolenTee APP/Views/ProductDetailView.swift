import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @StateObject private var viewModel = ProductDetailViewModel()
    @State private var showingCustomizer = false
    @State private var quantity = 1

    init(product: Product) {
        self.product = product
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                // Product Images
                productImages

                // Product Info
                productInfo
                    .padding(.horizontal, Theme.Spacing.screenPadding)

                // Variant Selection
                variantSelection
                    .padding(.horizontal, Theme.Spacing.screenPadding)

                // Quantity
                quantityPicker
                    .padding(.horizontal, Theme.Spacing.screenPadding)

                // Price Summary
                priceSummary
                    .padding(.horizontal, Theme.Spacing.screenPadding)

                // CTA Button
                ctaButton
                    .padding(.horizontal, Theme.Spacing.screenPadding)
                    .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .background(Theme.Colors.background)
        .navigationTitle(product.title)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingCustomizer) {
            CustomizerView(product: product, variants: product.variants ?? [])
        }
        .onAppear {
            viewModel.product = product
            if let firstVariant = product.variants?.first {
                viewModel.selectedVariant = firstVariant
                viewModel.selectedColor = firstVariant.color
                viewModel.selectedSize = firstVariant.size
            }
        }
    }

    // MARK: - Product Images

    private var productImages: some View {
        TabView {
            ForEach(product.images, id: \.self) { imageUrl in
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        SkeletonView()
                            .aspectRatio(1, contentMode: .fit)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
            }
        }
        .frame(height: 400)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }

    private var placeholderImage: some View {
        ZStack {
            Theme.Colors.backgroundSecondary
            Image(systemName: "tshirt")
                .font(.system(size: 80))
                .foregroundColor(Theme.Colors.textTertiary)
        }
        .frame(height: 400)
    }

    // MARK: - Product Info

    private var productInfo: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(product.title)
                .font(Theme.Typography.headlineMedium)
                .foregroundColor(Theme.Colors.text)

            if let description = product.description {
                Text(description)
                    .font(Theme.Typography.bodyMedium)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Features
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                FeatureRow(icon: "checkmark.circle.fill", text: "Premium Quality")
                FeatureRow(icon: "paintbrush.fill", text: "Custom Design Support")
                FeatureRow(icon: "printer.fill", text: "300 DPI Printing")
                FeatureRow(icon: "truck.box.fill", text: "Fast Shipping")
            }
        }
    }

    // MARK: - Variant Selection

    private var variantSelection: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Color Picker
            ColorPicker(
                colors: availableColors,
                selectedColor: Binding(
                    get: { viewModel.selectedColor ?? "" },
                    set: { viewModel.selectColor($0) }
                )
            )

            // Size Picker
            SizePicker(
                sizes: availableSizes,
                selectedSize: Binding(
                    get: { viewModel.selectedSize ?? "" },
                    set: { viewModel.selectSize($0) }
                )
            )
        }
    }

    // MARK: - Quantity Picker

    private var quantityPicker: some View {
        QuantityPicker(quantity: $quantity)
    }

    // MARK: - Price Summary

    private var priceSummary: some View {
        VStack(spacing: Theme.Spacing.sm) {
            HStack {
                Text("Base Price")
                    .font(Theme.Typography.bodyMedium)
                    .foregroundColor(Theme.Colors.textSecondary)

                Spacer()

                if let basePrice = product.variants?.first?.basePrice {
                    Text("$\(String(format: "%.2f", basePrice))")
                        .font(Theme.Typography.titleMedium)
                        .foregroundColor(Theme.Colors.text)
                }
            }

            if quantity > 1 {
                Divider()

                HStack {
                    Text("Total")
                        .font(Theme.Typography.titleLarge)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.Colors.text)

                    Spacer()

                    if let basePrice = product.variants?.first?.basePrice {
                        Text("$\(String(format: "%.2f", basePrice * Double(quantity)))")
                            .font(Theme.Typography.titleLarge)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.Colors.text)
                    }
                }
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.backgroundSecondary)
        .cornerRadius(Theme.CornerRadius.md)
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        Button(action: {
            showingCustomizer = true
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }) {
            HStack {
                Image(systemName: "photo")
                Text("Start Customizing")
            }
        }
        .primaryButtonStyle(isEnabled: viewModel.selectedColor != nil && viewModel.selectedSize != nil)
        .disabled(viewModel.selectedColor == nil || viewModel.selectedSize == nil)
    }

    // MARK: - Helpers

    private var availableColors: [String] {
        guard let variants = product.variants else { return [] }
        return Array(Set(variants.map { $0.color })).sorted()
    }

    private var availableSizes: [String] {
        guard let variants = product.variants, let color = viewModel.selectedColor else { return [] }
        return variants
            .filter { $0.color == color }
            .map { $0.size }
            .sorted()
    }
}

// MARK: - Supporting Views

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Theme.Colors.success)

            Text(text)
                .font(Theme.Typography.bodyMedium)
                .foregroundColor(Theme.Colors.text)
        }
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: Product(
            id: "1",
            title: "Classic Cotton T-Shirt",
            slug: "classic-tee",
            description: "Premium 100% cotton t-shirt. Soft, comfortable, and perfect for custom designs.",
            images: [],
            materials: "100% Cotton",
            weight: 5.0,
            countryOfOrigin: "USA",
            status: "active",
            metadata: nil,
            createdAt: nil,
            updatedAt: nil,
            variants: [
                ProductVariant(
                    id: "1",
                    productId: "1",
                    color: "White",
                    size: "M",
                    sku: "TEE-WHT-M",
                    baseCost: 8.99,
                    basePrice: 12.99,
                    stockLevel: 100,
                    imageUrl: nil,
                    metadata: nil,
                    createdAt: nil,
                    updatedAt: nil
                )
            ]
        ))
    }
}

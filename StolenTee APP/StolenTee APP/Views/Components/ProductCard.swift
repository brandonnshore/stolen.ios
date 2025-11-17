import SwiftUI

struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            // Product Image
            AsyncImage(url: URL(string: product.images.first ?? "")) { phase in
                switch phase {
                case .empty:
                    SkeletonView()
                        .aspectRatio(Theme.Layout.cardImageAspectRatio, contentMode: .fit)
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
            .aspectRatio(Theme.Layout.cardImageAspectRatio, contentMode: .fit)
            .background(Theme.Colors.backgroundSecondary)
            .cornerRadius(Theme.CornerRadius.md)

            // Product Info
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(Theme.Typography.titleSmall)
                    .foregroundColor(Theme.Colors.text)
                    .lineLimit(2)

                if let basePrice = product.variants?.first?.basePrice {
                    Text("from $\(String(format: "%.2f", basePrice))")
                        .font(Theme.Typography.bodySmall)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
        }
    }

    private var placeholderImage: some View {
        ZStack {
            Theme.Colors.backgroundSecondary
            Image(systemName: "tshirt")
                .font(.system(size: 40))
                .foregroundColor(Theme.Colors.textTertiary)
        }
        .aspectRatio(Theme.Layout.cardImageAspectRatio, contentMode: .fit)
        .cornerRadius(Theme.CornerRadius.md)
    }
}

// MARK: - Cart Item Card

struct CartItemCard: View {
    let item: CartItem
    var onEdit: () -> Void
    var onDelete: () -> Void
    var onIncrement: () -> Void
    var onDecrement: () -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Product Image
            if let mockupUrl = item.mockupUrl, let url = URL(string: mockupUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        placeholderImage
                    }
                }
                .frame(width: 80, height: 80)
                .background(Theme.Colors.backgroundSecondary)
                .cornerRadius(Theme.CornerRadius.sm)
            } else {
                placeholderImage
            }

            // Product Details
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(item.product.title)
                    .font(Theme.Typography.titleMedium)
                    .foregroundColor(Theme.Colors.text)

                HStack(spacing: Theme.Spacing.xs) {
                    Text(item.variant.color)
                        .font(Theme.Typography.labelSmall)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, 4)
                        .background(Theme.Colors.backgroundSecondary)
                        .cornerRadius(Theme.CornerRadius.xs)

                    Text(item.variant.size)
                        .font(Theme.Typography.labelSmall)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, 4)
                        .background(Theme.Colors.backgroundSecondary)
                        .cornerRadius(Theme.CornerRadius.xs)
                }

                // Price and Quantity
                HStack {
                    Text("$\(String(format: "%.2f", item.unitPrice * Double(item.quantity)))")
                        .font(Theme.Typography.titleMedium)
                        .foregroundColor(Theme.Colors.text)

                    Spacer()

                    // Quantity Controls
                    HStack(spacing: 0) {
                        Button(action: onDecrement) {
                            Image(systemName: "minus")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Theme.Colors.text)
                                .frame(width: 32, height: 32)
                        }
                        .disabled(item.quantity <= 1)

                        Text("\(item.quantity)")
                            .font(Theme.Typography.labelMedium)
                            .frame(minWidth: 32)

                        Button(action: onIncrement) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Theme.Colors.text)
                                .frame(width: 32, height: 32)
                        }
                    }
                    .background(Theme.Colors.backgroundSecondary)
                    .cornerRadius(Theme.CornerRadius.sm)
                }
            }
        }
    }

    private var placeholderImage: some View {
        ZStack {
            Theme.Colors.backgroundSecondary
            Image(systemName: "tshirt")
                .font(.system(size: 30))
                .foregroundColor(Theme.Colors.textTertiary)
        }
        .frame(width: 80, height: 80)
        .cornerRadius(Theme.CornerRadius.sm)
    }
}

// MARK: - Design Card (for Dashboard)

struct DesignCard: View {
    let design: Design
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail
            AsyncImage(url: URL(string: design.thumbnailUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .empty, .failure:
                    placeholderThumbnail
                @unknown default:
                    placeholderThumbnail
                }
            }
            .frame(height: 200)
            .clipped()
            .background(Theme.Colors.backgroundSecondary)

            // Design Info
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                Text(design.name)
                    .font(Theme.Typography.titleMedium)
                    .foregroundColor(Theme.Colors.text)
                    .lineLimit(1)

                if let productId = design.productId as String? {
                    Text("Product: \(productId)")
                        .font(Theme.Typography.bodySmall)
                        .foregroundColor(Theme.Colors.textSecondary)
                }

                if let updatedAt = design.updatedAt {
                    Text("Updated \(updatedAt, style: .date)")
                        .font(Theme.Typography.captionSmall)
                        .foregroundColor(Theme.Colors.textTertiary)
                }

                // Action Buttons
                HStack(spacing: Theme.Spacing.sm) {
                    Button(action: onEdit) {
                        Text("Edit")
                            .font(Theme.Typography.labelMedium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(Theme.Colors.primary)
                            .cornerRadius(Theme.CornerRadius.sm)
                    }

                    Button(action: onDelete) {
                        Text("Delete")
                            .font(Theme.Typography.labelMedium)
                            .foregroundColor(Theme.Colors.text)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                                    .stroke(Theme.Colors.border, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(Theme.Spacing.md)
        }
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.md)
        .shadow(color: Theme.Shadows.small, radius: 4, y: 2)
    }

    private var placeholderThumbnail: some View {
        ZStack {
            Theme.Colors.backgroundSecondary
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(Theme.Colors.textTertiary)
                Text("No Preview")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textTertiary)
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            ProductCard(product: Product(
                id: "1",
                title: "Classic Cotton T-Shirt",
                slug: "classic-tee",
                description: "Premium cotton tee",
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
            .padding()
        }
    }
}

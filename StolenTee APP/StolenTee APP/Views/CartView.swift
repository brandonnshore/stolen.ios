import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @Environment(\.navigateToProducts) var navigateToProducts
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastView.ToastType = .info

    var body: some View {
        NavigationStack {
            Group {
                if cartViewModel.items.isEmpty {
                    emptyState
                } else {
                    cartContent
                }
            }
            .navigationTitle("Cart")
            .navigationBarTitleDisplayMode(.large)
            .background(Theme.Colors.background)
            .toast(isPresented: $showToast, message: toastMessage, type: toastType)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        EmptyStateView.emptyCart {
            navigateToProducts()
        }
    }

    // MARK: - Cart Content

    private var cartContent: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                // Header Info
                headerInfo

                // Cart Items
                cartItems

                // Summary
                orderSummary

                // Checkout Button
                checkoutButton
                    .padding(.bottom, Theme.Spacing.xl)
            }
            .padding(.horizontal, Theme.Spacing.screenPadding)
        }
    }

    // MARK: - Header Info

    private var headerInfo: some View {
        HStack {
            Text("\(cartViewModel.itemCount) \(cartViewModel.itemCount == 1 ? "item" : "items")")
                .font(Theme.Typography.bodyMedium)
                .foregroundColor(Theme.Colors.textSecondary)

            Spacer()

            if !cartViewModel.items.isEmpty {
                Button(action: {
                    withAnimation {
                        cartViewModel.clearCart()
                    }
                    showToastMessage("Cart cleared", type: .info)
                }) {
                    Text("Clear All")
                        .font(Theme.Typography.labelMedium)
                        .foregroundColor(Theme.Colors.error)
                }
            }
        }
        .padding(.top, Theme.Spacing.sm)
    }

    // MARK: - Cart Items

    private var cartItems: some View {
        LazyVStack(spacing: Theme.Spacing.md) {
            ForEach(Array(cartViewModel.items.enumerated()), id: \.element.id) { index, item in
                CartItemRow(
                    item: item,
                    onEdit: {
                        // Navigate to customizer to edit
                    },
                    onIncrement: {
                        cartViewModel.updateQuantity(item: item, quantity: item.quantity + 1)
                    },
                    onDecrement: {
                        if item.quantity > 1 {
                            cartViewModel.updateQuantity(item: item, quantity: item.quantity - 1)
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        withAnimation {
                            cartViewModel.removeItem(item)
                        }
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        showToastMessage("Item removed", type: .info)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading) {
                    Button {
                        // Edit action
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(Theme.Colors.accent)
                }
            }
        }
    }

    // MARK: - Order Summary

    private var orderSummary: some View {
        VStack(spacing: Theme.Spacing.md) {
            VStack(spacing: Theme.Spacing.sm) {
                SummaryRow(label: "Subtotal", value: "$\(String(format: "%.2f", cartViewModel.subtotal))")
                SummaryRow(label: "Shipping", value: "TBD", isSecondary: true)
                SummaryRow(label: "Tax", value: "TBD", isSecondary: true)
            }

            Divider()

            HStack {
                Text("Total")
                    .font(Theme.Typography.titleLarge)
                    .fontWeight(.bold)

                Spacer()

                Text("$\(String(format: "%.2f", cartViewModel.subtotal))")
                    .font(Theme.Typography.titleLarge)
                    .fontWeight(.bold)
            }

            Text("Final price calculated at checkout")
                .font(Theme.Typography.captionSmall)
                .foregroundColor(Theme.Colors.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .cardStyle()
    }

    // MARK: - Checkout Button

    private var checkoutButton: some View {
        NavigationLink(destination: CheckoutView()) {
            Text("Proceed to Checkout")
                .fontWeight(.semibold)
        }
        .primaryButtonStyle()
    }

    // MARK: - Helper Methods

    private func showToastMessage(_ message: String, type: ToastView.ToastType) {
        toastMessage = message
        toastType = type
        showToast = true
    }
}

// MARK: - Cart Item Row

struct CartItemRow: View {
    let item: CartItem
    let onEdit: () -> Void
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Product Image
            productImage

            // Product Details
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(item.product.title)
                    .font(Theme.Typography.titleMedium)
                    .foregroundColor(Theme.Colors.text)
                    .lineLimit(2)

                // Variant Chips
                HStack(spacing: Theme.Spacing.xs) {
                    VariantChip(text: item.variant.color)
                    VariantChip(text: item.variant.size)
                }

                // Edit Link
                Button(action: onEdit) {
                    Text("Edit Design →")
                        .font(Theme.Typography.labelSmall)
                        .foregroundColor(Theme.Colors.accent)
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()

                // Price and Quantity
                HStack {
                    Text("$\(String(format: "%.2f", item.unitPrice * Double(item.quantity)))")
                        .font(Theme.Typography.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.Colors.text)

                    Spacer()

                    // Quantity Controls
                    HStack(spacing: 0) {
                        Button(action: onDecrement) {
                            Image(systemName: "minus")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(item.quantity > 1 ? Theme.Colors.text : Theme.Colors.textTertiary)
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
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.md)
        .shadow(color: Theme.Shadows.small, radius: 4, y: 2)
    }

    private var productImage: some View {
        Group {
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
            } else {
                placeholderImage
            }
        }
        .frame(width: 100, height: 100)
        .background(Theme.Colors.backgroundSecondary)
        .cornerRadius(Theme.CornerRadius.sm)
        .clipped()
    }

    private var placeholderImage: some View {
        ZStack {
            Theme.Colors.backgroundSecondary
            Image(systemName: "tshirt")
                .font(.system(size: 40))
                .foregroundColor(Theme.Colors.textTertiary)
        }
    }
}

// MARK: - Supporting Views

struct VariantChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Theme.Typography.labelSmall)
            .foregroundColor(Theme.Colors.textSecondary)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, 4)
            .background(Theme.Colors.backgroundSecondary)
            .cornerRadius(Theme.CornerRadius.xs)
    }
}

struct SummaryRow: View {
    let label: String
    let value: String
    var isSecondary: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(Theme.Typography.bodyMedium)
                .foregroundColor(isSecondary ? Theme.Colors.textSecondary : Theme.Colors.text)

            Spacer()

            Text(value)
                .font(Theme.Typography.titleSmall)
                .foregroundColor(isSecondary ? Theme.Colors.textSecondary : Theme.Colors.text)
        }
    }
}

#Preview {
    CartView()
        .environmentObject(CartViewModel())
}

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.textTertiary)

            VStack(spacing: Theme.Spacing.sm) {
                Text(title)
                    .font(Theme.Typography.headlineSmall)
                    .foregroundColor(Theme.Colors.text)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(Theme.Typography.bodyMedium)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, Theme.Spacing.xl)

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                }
                .primaryButtonStyle()
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.top, Theme.Spacing.sm)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }
}

// MARK: - Predefined Empty States

extension EmptyStateView {
    static func emptyCart(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "cart",
            title: "Your cart is empty",
            message: "Start designing your custom apparel and add items to your cart.",
            actionTitle: "Start Designing",
            action: action
        )
    }

    static func noDesigns(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "paintbrush",
            title: "No designs yet",
            message: "Get started by creating your first custom design!",
            actionTitle: "Create Design",
            action: action
        )
    }

    static func noProducts() -> EmptyStateView {
        EmptyStateView(
            icon: "tshirt",
            title: "No products available",
            message: "Check back soon for new products.",
            actionTitle: nil,
            action: nil
        )
    }

    static func searchNoResults() -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No results found",
            message: "Try adjusting your search or filters.",
            actionTitle: nil,
            action: nil
        )
    }
}

#Preview {
    EmptyStateView.emptyCart {
        print("Action tapped")
    }
}

import SwiftUI

enum OrderStatus: String {
    case pending
    case processing
    case shipped
    case delivered
    case cancelled
}

struct OrderTrackingView: View {
    let orderNumber: String
    @State private var order: Order?
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            if isLoading {
                LoadingView(message: "Loading order details...")
                    .frame(height: 400)
            } else if let order = order {
                orderContent(order)
            } else {
                EmptyStateView(
                    icon: "exclamationmark.triangle",
                    title: "Order Not Found",
                    message: "We couldn't find an order with number \(orderNumber)",
                    actionTitle: nil,
                    action: nil
                )
            }
        }
        .background(Theme.Colors.backgroundGrouped)
        .navigationTitle("Order #\(orderNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadOrder()
        }
    }

    // MARK: - Order Content

    @ViewBuilder
    private func orderContent(_ order: Order) -> some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Order Status
            orderStatusSection(order)

            // Tracking Timeline
            trackingTimeline(order)

            // Order Items
            orderItemsSection(order)

            // Shipping Address
            shippingAddressSection(order)

            // Order Summary
            orderSummarySection(order)
        }
        .padding(Theme.Spacing.screenPadding)
    }

    // MARK: - Order Status Section

    private func orderStatusSection(_ order: Order) -> some View {
        VStack(spacing: Theme.Spacing.md) {
            // Status Icon
            ZStack {
                Circle()
                    .fill(statusColor(OrderStatus(rawValue: order.productionStatus) ?? .pending).opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: statusIcon(OrderStatus(rawValue: order.productionStatus) ?? .pending))
                    .font(.system(size: 40))
                    .foregroundColor(statusColor(OrderStatus(rawValue: order.productionStatus) ?? .pending))
            }

            // Status Text
            VStack(spacing: Theme.Spacing.xs) {
                Text(statusTitle(OrderStatus(rawValue: order.productionStatus) ?? .pending))
                    .font(Theme.Typography.headlineSmall)
                    .foregroundColor(Theme.Colors.text)

                Text(statusMessage(OrderStatus(rawValue: order.productionStatus) ?? .pending))
                    .font(Theme.Typography.bodyMedium)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Estimated Delivery
            // TODO: Add estimatedDelivery field to Order model
            // if let estimatedDelivery = order.estimatedDelivery {
            //     HStack {
            //         Image(systemName: "calendar")
            //             .foregroundColor(Theme.Colors.textSecondary)
            //
            //         Text("Estimated delivery: \(estimatedDelivery, style: .date)")
            //             .font(Theme.Typography.bodyMedium)
            //             .foregroundColor(Theme.Colors.textSecondary)
            //     }
            //     .padding(Theme.Spacing.sm)
            //     .background(Theme.Colors.backgroundSecondary)
            //     .cornerRadius(Theme.CornerRadius.sm)
            // }
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.surface)
        .cornerRadius(Theme.CornerRadius.lg)
        .shadow(color: Theme.Shadows.small, radius: 4, y: 2)
    }

    // MARK: - Tracking Timeline

    private func trackingTimeline(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Tracking Updates")
                .font(Theme.Typography.titleMedium)
                .foregroundColor(Theme.Colors.text)

            VStack(alignment: .leading, spacing: 0) {
                TrackingStep(
                    title: "Order Placed",
                    date: order.createdAt,
                    isCompleted: true,
                    isLast: false
                )

                TrackingStep(
                    title: "Processing",
                    date: (OrderStatus(rawValue: order.productionStatus) == .processing || OrderStatus(rawValue: order.productionStatus) == .shipped || OrderStatus(rawValue: order.productionStatus) == .delivered) ? Date() : nil,
                    isCompleted: (OrderStatus(rawValue: order.productionStatus) == .processing || OrderStatus(rawValue: order.productionStatus) == .shipped || OrderStatus(rawValue: order.productionStatus) == .delivered),
                    isLast: false
                )

                TrackingStep(
                    title: "Shipped",
                    date: (OrderStatus(rawValue: order.productionStatus) == .shipped || OrderStatus(rawValue: order.productionStatus) == .delivered) ? Date() : nil,
                    isCompleted: (OrderStatus(rawValue: order.productionStatus) == .shipped || OrderStatus(rawValue: order.productionStatus) == .delivered),
                    isLast: false
                )

                TrackingStep(
                    title: "Delivered",
                    date: OrderStatus(rawValue: order.productionStatus) == .delivered ? Date() : nil,
                    isCompleted: OrderStatus(rawValue: order.productionStatus) == .delivered,
                    isLast: true
                )
            }
        }
        .cardStyle()
    }

    // MARK: - Order Items Section

    private func orderItemsSection(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Items (\(order.items?.count ?? 0))")
                .font(Theme.Typography.titleMedium)
                .foregroundColor(Theme.Colors.text)

            ForEach(order.items ?? []) { item in
                HStack(spacing: Theme.Spacing.md) {
                    // Placeholder image
                    ZStack {
                        Theme.Colors.backgroundSecondary
                        Image(systemName: "tshirt")
                            .foregroundColor(Theme.Colors.textTertiary)
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(Theme.CornerRadius.sm)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Product #\(item.id)")
                            .font(Theme.Typography.titleSmall)
                            .foregroundColor(Theme.Colors.text)

                        Text("Qty: \(item.quantity)")
                            .font(Theme.Typography.bodySmall)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }

                    Spacer()

                    Text("$\(String(format: "%.2f", item.totalPrice))")
                        .font(Theme.Typography.titleSmall)
                        .foregroundColor(Theme.Colors.text)
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Shipping Address Section

    private func shippingAddressSection(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Shipping Address")
                .font(Theme.Typography.titleMedium)
                .foregroundColor(Theme.Colors.text)

            if let address = order.shippingAddress {
                VStack(alignment: .leading, spacing: 4) {
                    Text(address.address1)
                    if let address2 = address.address2, !address2.isEmpty {
                        Text(address2)
                    }
                    Text("\(address.city), \(address.state) \(address.postalCode)")
                    Text(address.country)
                }
                .font(Theme.Typography.bodyMedium)
                .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .cardStyle()
    }

    // MARK: - Order Summary Section

    private func orderSummarySection(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Order Summary")
                .font(Theme.Typography.titleMedium)
                .foregroundColor(Theme.Colors.text)

            VStack(spacing: Theme.Spacing.sm) {
                SummaryRow(label: "Subtotal", value: "$\(String(format: "%.2f", order.subtotal))")
                SummaryRow(label: "Shipping", value: "$\(String(format: "%.2f", order.shipping))", isSecondary: true)
                SummaryRow(label: "Tax", value: "$\(String(format: "%.2f", order.tax))", isSecondary: true)
            }

            Divider()

            HStack {
                Text("Total")
                    .font(Theme.Typography.titleLarge)
                    .fontWeight(.bold)

                Spacer()

                Text("$\(String(format: "%.2f", order.total))")
                    .font(Theme.Typography.titleLarge)
                    .fontWeight(.bold)
            }
        }
        .cardStyle()
    }

    // MARK: - Helper Methods

    private func loadOrder() async {
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isLoading = false
        // Load order would happen here
    }

    private func statusIcon(_ status: OrderStatus) -> String {
        switch status {
        case .pending: return "clock.fill"
        case .processing: return "gear"
        case .shipped: return "shippingbox.fill"
        case .delivered: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }

    private func statusColor(_ status: OrderStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .processing: return .blue
        case .shipped: return .purple
        case .delivered: return .green
        case .cancelled: return .red
        }
    }

    private func statusTitle(_ status: OrderStatus) -> String {
        switch status {
        case .pending: return "Order Received"
        case .processing: return "Processing"
        case .shipped: return "On Its Way"
        case .delivered: return "Delivered"
        case .cancelled: return "Cancelled"
        }
    }

    private func statusMessage(_ status: OrderStatus) -> String {
        switch status {
        case .pending: return "We've received your order and will begin processing soon"
        case .processing: return "Your order is being prepared"
        case .shipped: return "Your order has been shipped"
        case .delivered: return "Your order has been delivered"
        case .cancelled: return "This order has been cancelled"
        }
    }
}

// MARK: - Tracking Step

struct TrackingStep: View {
    let title: String
    let date: Date?
    let isCompleted: Bool
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            // Timeline indicator
            VStack(spacing: 0) {
                Circle()
                    .fill(isCompleted ? Theme.Colors.success : Theme.Colors.border)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white, lineWidth: 2)
                    )

                if !isLast {
                    Rectangle()
                        .fill(isCompleted ? Theme.Colors.success.opacity(0.3) : Theme.Colors.border)
                        .frame(width: 2, height: 40)
                }
            }

            // Step info
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Theme.Typography.titleSmall)
                    .foregroundColor(isCompleted ? Theme.Colors.text : Theme.Colors.textSecondary)

                if let date = date {
                    Text(date, style: .date)
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .padding(.bottom, isLast ? 0 : Theme.Spacing.sm)

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        OrderTrackingView(orderNumber: "12345")
    }
}

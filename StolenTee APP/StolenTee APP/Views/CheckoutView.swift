import SwiftUI
import PassKit

struct CheckoutView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var customerInfo = CustomerInfo()
    @State private var shippingAddress = Address()
    @State private var useShippingForBilling = true
    @State private var showingPaymentSheet = false
    @State private var isProcessing = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastView.ToastType = .error

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                // Apple Pay (Prominent)
                applePaySection

                // Divider
                orDivider

                // Customer Information
                customerInfoSection

                // Shipping Address
                shippingAddressSection

                // Order Summary
                orderSummarySection

                // Payment Method
                paymentMethodSection

                // Submit Button
                submitButton
                    .padding(.bottom, Theme.Spacing.xl)
            }
            .padding(Theme.Spacing.screenPadding)
        }
        .background(Theme.Colors.backgroundGrouped)
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if isProcessing {
                FullScreenLoadingView(message: "Processing payment...")
            }
        }
        .toast(isPresented: $showToast, message: toastMessage, type: toastType)
    }

    // MARK: - Apple Pay Section

    private var applePaySection: some View {
        VStack(spacing: Theme.Spacing.md) {
            Text("Express Checkout")
                .font(Theme.Typography.titleSmall)
                .foregroundColor(Theme.Colors.text)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: processApplePay) {
                HStack {
                    Image(systemName: "apple.logo")
                        .font(.title3)

                    Text("Pay")
                        .fontWeight(.semibold)

                    Spacer()

                    Text("$\(String(format: "%.2f", cartViewModel.subtotal))")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(height: 56)
                .padding(.horizontal, Theme.Spacing.md)
                .background(Color.black)
                .cornerRadius(Theme.CornerRadius.md)
            }
            .shadow(color: Theme.Shadows.medium, radius: 8, y: 4)
        }
        .cardStyle()
    }

    // MARK: - Or Divider

    private var orDivider: some View {
        HStack {
            Rectangle()
                .fill(Theme.Colors.border)
                .frame(height: 1)

            Text("or pay with card")
                .font(Theme.Typography.bodySmall)
                .foregroundColor(Theme.Colors.textSecondary)
                .padding(.horizontal, Theme.Spacing.sm)

            Rectangle()
                .fill(Theme.Colors.border)
                .frame(height: 1)
        }
    }

    // MARK: - Customer Info Section

    private var customerInfoSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Customer Information")
                .font(Theme.Typography.titleMedium)
                .foregroundColor(Theme.Colors.text)

            VStack(spacing: Theme.Spacing.sm) {
                CheckoutTextField(title: "Full Name", text: $customerInfo.name, placeholder: "John Doe")
                CheckoutTextField(title: "Email", text: $customerInfo.email, placeholder: "john@example.com")
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                CheckoutTextField(title: "Phone", text: $customerInfo.phone, placeholder: "(555) 123-4567")
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
            }
        }
        .cardStyle()
    }

    // MARK: - Shipping Address Section

    private var shippingAddressSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Shipping Address")
                .font(Theme.Typography.titleMedium)
                .foregroundColor(Theme.Colors.text)

            VStack(spacing: Theme.Spacing.sm) {
                CheckoutTextField(title: "Address Line 1", text: $shippingAddress.line1, placeholder: "123 Main St")
                    .textContentType(.streetAddressLine1)

                CheckoutTextField(title: "Address Line 2 (Optional)", text: $shippingAddress.line2, placeholder: "Apt 4B")
                    .textContentType(.streetAddressLine2)

                HStack(spacing: Theme.Spacing.sm) {
                    CheckoutTextField(title: "City", text: $shippingAddress.city, placeholder: "New York")
                        .textContentType(.addressCity)

                    CheckoutTextField(title: "State", text: $shippingAddress.state, placeholder: "NY")
                        .textContentType(.addressState)
                }

                HStack(spacing: Theme.Spacing.sm) {
                    CheckoutTextField(title: "ZIP Code", text: $shippingAddress.postalCode, placeholder: "10001")
                        .keyboardType(.numberPad)
                        .textContentType(.postalCode)

                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("Country")
                            .font(Theme.Typography.labelMedium)
                            .foregroundColor(Theme.Colors.textSecondary)

                        Picker("Country", selection: $shippingAddress.country) {
                            Text("United States").tag("US")
                            Text("Canada").tag("CA")
                        }
                        .pickerStyle(.menu)
                        .padding(Theme.Spacing.sm)
                        .background(Theme.Colors.surface)
                        .cornerRadius(Theme.CornerRadius.xs)
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Order Summary Section

    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Order Summary")
                .font(Theme.Typography.titleMedium)
                .foregroundColor(Theme.Colors.text)

            // Items
            ForEach(Array(cartViewModel.items.prefix(3))) { item in
                HStack {
                    Text(item.product.title)
                        .font(Theme.Typography.bodyMedium)
                        .foregroundColor(Theme.Colors.text)
                        .lineLimit(1)

                    Spacer()

                    Text("×\(item.quantity)")
                        .font(Theme.Typography.bodySmall)
                        .foregroundColor(Theme.Colors.textSecondary)

                    Text("$\(String(format: "%.2f", item.unitPrice * Double(item.quantity)))")
                        .font(Theme.Typography.titleSmall)
                        .foregroundColor(Theme.Colors.text)
                }
            }

            if cartViewModel.items.count > 3 {
                Text("+ \(cartViewModel.items.count - 3) more items")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }

            Divider()

            // Summary
            VStack(spacing: Theme.Spacing.xs) {
                SummaryRow(label: "Subtotal", value: "$\(String(format: "%.2f", cartViewModel.subtotal))")
                SummaryRow(label: "Shipping", value: "FREE", isSecondary: true)
                SummaryRow(label: "Tax", value: "$0.00", isSecondary: true)
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
        }
        .cardStyle()
    }

    // MARK: - Payment Method Section

    private var paymentMethodSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Payment Method")
                .font(Theme.Typography.titleMedium)
                .foregroundColor(Theme.Colors.text)

            Button(action: {
                showingPaymentSheet = true
            }) {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .foregroundColor(Theme.Colors.accent)

                    Text("Add Card")
                        .font(Theme.Typography.bodyMedium)
                        .foregroundColor(Theme.Colors.text)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.Colors.textTertiary)
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.surface)
                .cornerRadius(Theme.CornerRadius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                        .stroke(Theme.Colors.border, lineWidth: 1)
                )
            }

            // Security Badge
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(Theme.Colors.success)

                Text("Your payment information is secure and encrypted")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
            }
        }
        .cardStyle()
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button(action: processPayment) {
            Text("Place Order - $\(String(format: "%.2f", cartViewModel.subtotal))")
                .fontWeight(.semibold)
        }
        .primaryButtonStyle(isEnabled: isFormValid, isLoading: isProcessing)
        .disabled(!isFormValid || isProcessing)
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        !customerInfo.name.isEmpty &&
        !customerInfo.email.isEmpty &&
        !shippingAddress.line1.isEmpty &&
        !shippingAddress.city.isEmpty &&
        !shippingAddress.state.isEmpty &&
        !shippingAddress.postalCode.isEmpty
    }

    // MARK: - Actions

    private func processApplePay() {
        // Implement Apple Pay processing
        isProcessing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            completeOrder()
        }
    }

    private func processPayment() {
        isProcessing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            completeOrder()
        }
    }

    private func completeOrder() {
        // Clear cart and navigate to order confirmation
        cartViewModel.clearCart()

        toastMessage = "Order placed successfully!"
        toastType = .success
        showToast = true

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
        }
    }
}

// MARK: - Supporting Types

struct CustomerInfo {
    var name: String = ""
    var email: String = ""
    var phone: String = ""
}

struct Address {
    var line1: String = ""
    var line2: String = ""
    var city: String = ""
    var state: String = ""
    var postalCode: String = ""
    var country: String = "US"
}

// MARK: - Checkout Text Field

struct CheckoutTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(title)
                .font(Theme.Typography.labelMedium)
                .foregroundColor(Theme.Colors.textSecondary)

            TextField(placeholder, text: $text)
                .font(Theme.Typography.bodyMedium)
                .padding(Theme.Spacing.sm)
                .background(Theme.Colors.surface)
                .cornerRadius(Theme.CornerRadius.xs)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.xs)
                        .stroke(Theme.Colors.border, lineWidth: 1)
                )
        }
    }
}

#Preview {
    NavigationStack {
        CheckoutView()
            .environmentObject(CartViewModel())
    }
}

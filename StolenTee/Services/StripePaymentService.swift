import Foundation
import StripePaymentSheet
import PassKit

class StripePaymentService: NSObject {
    static let shared = StripePaymentService()
    private override init() {
        super.init()
        // Configure Stripe with publishable key
        STPAPIClient.shared.publishableKey = Configuration.stripePublishableKey
    }

    // MARK: - Create Payment Sheet
    @MainActor
    func createPaymentSheet(
        order: Order,
        clientSecret: String
    ) async throws -> PaymentSheet {
        // Configure PaymentSheet
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Stolen Tee"
        configuration.allowsDelayedPaymentMethods = false

        // Configure Apple Pay
        if let applePayConfig = createApplePayConfiguration() {
            configuration.applePay = applePayConfig
        }

        // Configure appearance
        var appearance = PaymentSheet.Appearance()
        appearance.cornerRadius = 12
        appearance.colors.primary = .systemBlue
        configuration.appearance = appearance

        // Create PaymentSheet
        let paymentSheet = PaymentSheet(
            paymentIntentClientSecret: clientSecret,
            configuration: configuration
        )

        return paymentSheet
    }

    // MARK: - Process Payment with Payment Sheet
    @MainActor
    func presentPaymentSheet(
        _ paymentSheet: PaymentSheet,
        from viewController: UIViewController
    ) async throws -> PaymentSheet.PaymentResult {
        return await withCheckedContinuation { continuation in
            paymentSheet.present(from: viewController) { result in
                continuation.resume(returning: result)
            }
        }
    }

    // MARK: - Apple Pay Configuration
    private func createApplePayConfiguration() -> PaymentSheet.ApplePayConfiguration? {
        // Check if Apple Pay is available
        guard PKPaymentAuthorizationController.canMakePayments() else {
            return nil
        }

        return PaymentSheet.ApplePayConfiguration(
            merchantId: "merchant.com.stolenlee.app",
            merchantCountryCode: "US"
        )
    }

    // MARK: - Confirm Payment with Backend
    func confirmPayment(orderId: String, paymentIntentId: String) async throws -> Order {
        let order = try await OrderService.shared.capturePayment(
            orderId: orderId,
            paymentIntentId: paymentIntentId
        )
        return order
    }

    // MARK: - Helper: Get View Controller
    @MainActor
    func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return nil
        }

        var topViewController = rootViewController
        while let presentedViewController = topViewController.presentedViewController {
            topViewController = presentedViewController
        }

        return topViewController
    }
}

// MARK: - SwiftUI Integration Helper
struct StripePaymentSheetWrapper {
    let order: Order
    let clientSecret: String

    @MainActor
    func present(completion: @escaping (Result<String, Error>) -> Void) async {
        do {
            let paymentSheet = try await StripePaymentService.shared.createPaymentSheet(
                order: order,
                clientSecret: clientSecret
            )

            guard let viewController = StripePaymentService.shared.getTopViewController() else {
                completion(.failure(APIError.serverError("No view controller found")))
                return
            }

            let result = try await StripePaymentService.shared.presentPaymentSheet(
                paymentSheet,
                from: viewController
            )

            switch result {
            case .completed:
                // Payment succeeded, confirm with backend
                let confirmedOrder = try await StripePaymentService.shared.confirmPayment(
                    orderId: order.id,
                    paymentIntentId: order.paymentIntentId ?? ""
                )
                completion(.success(confirmedOrder.id))

            case .canceled:
                completion(.failure(APIError.serverError("Payment canceled")))

            case .failed(let error):
                completion(.failure(error))
            }
        } catch {
            completion(.failure(error))
        }
    }
}

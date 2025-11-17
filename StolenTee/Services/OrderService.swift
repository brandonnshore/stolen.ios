import Foundation

class OrderService {
    static let shared = OrderService()
    private init() {}

    // MARK: - Create Order
    func createOrder(request: CreateOrderRequest) async throws -> CreateOrderResponse {
        let response: CreateOrderResponse = try await APIClient.shared.request(
            endpoint: Configuration.Endpoint.createOrder,
            method: .post,
            body: request,
            requiresAuth: true
        )
        return response
    }

    // MARK: - Get Order
    func getOrder(id: String) async throws -> Order {
        let response: OrderResponse = try await APIClient.shared.request(
            endpoint: Configuration.Endpoint.orderDetail(id),
            requiresAuth: true
        )
        return response.order
    }

    // MARK: - Capture Payment
    func capturePayment(orderId: String, paymentIntentId: String) async throws -> Order {
        struct CaptureRequest: Codable {
            let paymentIntentId: String

            enum CodingKeys: String, CodingKey {
                case paymentIntentId = "payment_intent_id"
            }
        }

        let request = CaptureRequest(paymentIntentId: paymentIntentId)
        let response: OrderResponse = try await APIClient.shared.request(
            endpoint: Configuration.Endpoint.capturePayment(orderId),
            method: .post,
            body: request,
            requiresAuth: true
        )
        return response.order
    }
}

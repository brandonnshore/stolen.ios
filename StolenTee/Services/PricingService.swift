import Foundation

class PricingService {
    static let shared = PricingService()
    private init() {}

    // MARK: - Get Price Quote
    func getPriceQuote(request: PriceQuoteRequest) async throws -> PriceQuote {
        let response: PriceQuoteResponse = try await APIClient.shared.request(
            endpoint: Configuration.Endpoint.priceQuote,
            method: .post,
            body: request
        )
        return response.quote
    }
}

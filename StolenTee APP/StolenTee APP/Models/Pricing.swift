import Foundation

struct PriceQuoteRequest: Codable {
    let variantId: String
    let quantity: Int
    let customSpec: CustomizationSpec

    enum CodingKeys: String, CodingKey {
        case quantity
        case variantId
        case customSpec
    }
}

struct PriceQuote: Codable {
    let unitPrice: Double
    let totalPrice: Double
    let breakdown: PriceBreakdown

    enum CodingKeys: String, CodingKey {
        case breakdown
        case unitPrice
        case totalPrice
    }
}

struct PriceBreakdown: Codable {
    let basePrice: Double
    let decorationCharge: Double
    let locationCharges: Double
    let colorCharges: Double
    let sizeCharges: Double
    let quantityDiscount: Double
    let subtotal: Double

    enum CodingKeys: String, CodingKey {
        case subtotal
        case basePrice
        case decorationCharge
        case locationCharges
        case colorCharges
        case sizeCharges
        case quantityDiscount
    }
}

struct PriceQuoteResponse: Codable {
    let quote: PriceQuote
}

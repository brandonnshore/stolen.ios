import Foundation

struct PriceQuoteRequest: Codable {
    let variantId: String
    let quantity: Int
    let customSpec: CustomizationSpec

    enum CodingKeys: String, CodingKey {
        case quantity
        case variantId = "variant_id"
        case customSpec = "custom_spec"
    }
}

struct PriceQuote: Codable {
    let unitPrice: Double
    let totalPrice: Double
    let breakdown: PriceBreakdown

    enum CodingKeys: String, CodingKey {
        case breakdown
        case unitPrice = "unit_price"
        case totalPrice = "total_price"
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
        case basePrice = "base_price"
        case decorationCharge = "decoration_charge"
        case locationCharges = "location_charges"
        case colorCharges = "color_charges"
        case sizeCharges = "size_charges"
        case quantityDiscount = "quantity_discount"
    }
}

struct PriceQuoteResponse: Codable {
    let quote: PriceQuote
}

import Foundation

struct Order: Codable, Identifiable {
    let id: String
    let orderNumber: String
    let customerId: String?
    let subtotal: Double
    let tax: Double
    let shipping: Double
    let discount: Double
    let total: Double
    let paymentStatus: String
    let paymentIntentId: String?
    let productionStatus: String
    let trackingNumber: String?
    let carrier: String?
    let shippedAt: Date?
    let shippingAddress: Address?
    let billingAddress: Address?
    let customerNotes: String?
    let internalNotes: String?
    let metadata: [String: AnyCodable]?
    let items: [OrderItem]?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, subtotal, tax, shipping, discount, total, metadata, items
        case orderNumber = "order_number"
        case customerId = "customer_id"
        case paymentStatus = "payment_status"
        case paymentIntentId = "payment_intent_id"
        case productionStatus = "production_status"
        case trackingNumber = "tracking_number"
        case carrier
        case shippedAt = "shipped_at"
        case shippingAddress = "shipping_address"
        case billingAddress = "billing_address"
        case customerNotes = "customer_notes"
        case internalNotes = "internal_notes"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct OrderItem: Codable, Identifiable {
    let id: String
    let orderId: String
    let variantId: String
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double
    let customSpec: CustomizationSpec?
    let productionPackUrl: String?
    let mockupUrl: String?
    let productionStatus: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, quantity, metadata
        case orderId = "order_id"
        case variantId = "variant_id"
        case unitPrice = "unit_price"
        case totalPrice = "total_price"
        case customSpec = "custom_spec"
        case productionPackUrl = "production_pack_url"
        case mockupUrl = "mockup_url"
        case productionStatus = "production_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Address: Codable {
    let firstName: String?
    let lastName: String?
    let company: String?
    let address1: String
    let address2: String?
    let city: String
    let state: String
    let postalCode: String
    let country: String
    let phone: String?

    enum CodingKeys: String, CodingKey {
        case company, city, state, country, phone
        case firstName = "first_name"
        case lastName = "last_name"
        case address1 = "address1"
        case address2 = "address2"
        case postalCode = "postal_code"
    }
}

struct CustomizationSpec: Codable {
    let method: String
    let placements: [Placement]
    let textElements: [TextElement]?
    let artworkAssets: [String]
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case method, placements, notes
        case textElements = "text_elements"
        case artworkAssets = "artwork_assets"
    }
}

struct Placement: Codable, Identifiable {
    var id: String { location + "_" + (artworkId ?? textElementId ?? UUID().uuidString) }
    let location: String
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    let artworkId: String?
    let textElementId: String?
    let colors: [String]
    let rotation: Double

    enum CodingKeys: String, CodingKey {
        case location, x, y, width, height, colors, rotation
        case artworkId = "artwork_id"
        case textElementId = "text_element_id"
    }
}

struct TextElement: Codable, Identifiable {
    let id: String
    let text: String
    let fontFamily: String
    let fontSize: Double
    let fontWeight: String
    let color: String

    enum CodingKeys: String, CodingKey {
        case id, text, color
        case fontFamily = "font_family"
        case fontSize = "font_size"
        case fontWeight = "font_weight"
    }
}

struct CreateOrderRequest: Codable {
    let items: [OrderItemRequest]
    let shippingAddress: Address
    let billingAddress: Address?
    let customerNotes: String?

    enum CodingKeys: String, CodingKey {
        case items
        case shippingAddress = "shipping_address"
        case billingAddress = "billing_address"
        case customerNotes = "customer_notes"
    }
}

struct OrderItemRequest: Codable {
    let variantId: String
    let quantity: Int
    let customSpec: CustomizationSpec?

    enum CodingKeys: String, CodingKey {
        case quantity
        case variantId = "variant_id"
        case customSpec = "custom_spec"
    }
}

struct CreateOrderResponse: Codable {
    let order: Order
    let clientSecret: String

    enum CodingKeys: String, CodingKey {
        case order
        case clientSecret = "client_secret"
    }
}

struct OrderResponse: Codable {
    let order: Order
}

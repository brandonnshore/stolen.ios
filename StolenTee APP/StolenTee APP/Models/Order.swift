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
    let shippingAddress: OrderAddress?
    let billingAddress: OrderAddress?
    let customerNotes: String?
    let internalNotes: String?
    let metadata: [String: AnyCodable]?
    let items: [OrderItem]?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, subtotal, tax, shipping, discount, total, metadata, items
        case orderNumber
        case customerId
        case paymentStatus
        case paymentIntentId
        case productionStatus
        case trackingNumber
        case carrier
        case shippedAt
        case shippingAddress
        case billingAddress
        case customerNotes
        case internalNotes
        case createdAt
        case updatedAt
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
        case id, quantity
        case orderId
        case variantId
        case unitPrice
        case totalPrice
        case customSpec
        case productionPackUrl
        case mockupUrl
        case productionStatus
        case createdAt
        case updatedAt
    }
}

struct OrderAddress: Codable {
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
        case firstName
        case lastName
        case address1
        case address2
        case postalCode
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
        case textElements
        case artworkAssets
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
        case artworkId
        case textElementId
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
        case fontFamily
        case fontSize
        case fontWeight
    }
}

struct CreateOrderRequest: Codable {
    let items: [OrderItemRequest]
    let shippingAddress: OrderAddress
    let billingAddress: OrderAddress?
    let customerNotes: String?

    enum CodingKeys: String, CodingKey {
        case items
        case shippingAddress
        case billingAddress
        case customerNotes
    }
}

struct OrderItemRequest: Codable {
    let variantId: String
    let quantity: Int
    let customSpec: CustomizationSpec?

    enum CodingKeys: String, CodingKey {
        case quantity
        case variantId
        case customSpec
    }
}

struct CreateOrderResponse: Codable {
    let order: Order
    let clientSecret: String

    enum CodingKeys: String, CodingKey {
        case order
        case clientSecret
    }
}

struct OrderResponse: Codable {
    let order: Order
}

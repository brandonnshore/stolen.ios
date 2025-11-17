import Foundation

struct Product: Codable, Identifiable {
    let id: String
    let title: String
    let slug: String
    let description: String?
    let images: [String]
    let materials: String?
    let weight: Double?
    let countryOfOrigin: String?
    let status: String
    let metadata: [String: AnyCodable]?
    let createdAt: Date?
    let updatedAt: Date?
    let variants: [ProductVariant]?

    enum CodingKeys: String, CodingKey {
        case id, title, slug, description, images, materials, weight, status, metadata, variants
        case countryOfOrigin = "country_of_origin"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ProductVariant: Codable, Identifiable {
    let id: String
    let productId: String
    let color: String
    let size: String
    let sku: String?
    let baseCost: Double?
    let basePrice: Double
    let stockLevel: Int?
    let imageUrl: String?
    let metadata: [String: AnyCodable]?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, color, size, sku, metadata
        case productId = "product_id"
        case baseCost = "base_cost"
        case basePrice = "base_price"
        case stockLevel = "stock_level"
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ProductsResponse: Codable {
    let products: [Product]
}

struct ProductDetailResponse: Codable {
    let product: Product
}

// Import CustomAnyCodable from Upload.swift
typealias AnyCodable = CustomAnyCodable

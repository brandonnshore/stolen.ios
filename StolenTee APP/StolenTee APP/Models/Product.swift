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
        case countryOfOrigin
        case createdAt
        case updatedAt
    }

    // Regular initializer for manual creation
    init(id: String, title: String, slug: String, description: String?, images: [String], materials: String?, weight: Double?, countryOfOrigin: String?, status: String, metadata: [String: AnyCodable]?, createdAt: Date?, updatedAt: Date?, variants: [ProductVariant]?) {
        self.id = id
        self.title = title
        self.slug = slug
        self.description = description
        self.images = images
        self.materials = materials
        self.weight = weight
        self.countryOfOrigin = countryOfOrigin
        self.status = status
        self.metadata = metadata
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.variants = variants
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        slug = try container.decode(String.self, forKey: .slug)
        description = try container.decodeIfPresent(String.self, forKey: .description)

        // Decode images and make them absolute URLs
        let imagesPaths = try container.decode([String].self, forKey: .images)
        images = imagesPaths.map { path in
            if path.starts(with: "http") {
                return path
            } else {
                return "https://stolentee-backend-production.up.railway.app\(path)"
            }
        }

        materials = try container.decodeIfPresent(String.self, forKey: .materials)

        // Decode weight as string and convert to Double
        if let weightString = try container.decodeIfPresent(String.self, forKey: .weight) {
            weight = Double(weightString)
        } else {
            weight = try container.decodeIfPresent(Double.self, forKey: .weight)
        }

        countryOfOrigin = try container.decodeIfPresent(String.self, forKey: .countryOfOrigin)
        status = try container.decode(String.self, forKey: .status)
        metadata = try container.decodeIfPresent([String: AnyCodable].self, forKey: .metadata)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        variants = try container.decodeIfPresent([ProductVariant].self, forKey: .variants)
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
        case productId
        case baseCost
        case basePrice
        case stockLevel
        case imageUrl
        case createdAt
        case updatedAt
    }

    // Regular initializer for manual creation
    init(id: String, productId: String, color: String, size: String, sku: String?, baseCost: Double?, basePrice: Double, stockLevel: Int?, imageUrl: String?, metadata: [String: AnyCodable]?, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.productId = productId
        self.color = color
        self.size = size
        self.sku = sku
        self.baseCost = baseCost
        self.basePrice = basePrice
        self.stockLevel = stockLevel
        self.imageUrl = imageUrl
        self.metadata = metadata
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        productId = try container.decode(String.self, forKey: .productId)
        color = try container.decode(String.self, forKey: .color)
        size = try container.decode(String.self, forKey: .size)
        sku = try container.decodeIfPresent(String.self, forKey: .sku)

        // Decode baseCost as string and convert to Double
        if let baseCostString = try container.decodeIfPresent(String.self, forKey: .baseCost) {
            baseCost = Double(baseCostString)
        } else {
            baseCost = try container.decodeIfPresent(Double.self, forKey: .baseCost)
        }

        // Decode basePrice as string and convert to Double
        if let basePriceString = try container.decodeIfPresent(String.self, forKey: .basePrice) {
            basePrice = Double(basePriceString) ?? 0.0
        } else {
            basePrice = try container.decode(Double.self, forKey: .basePrice)
        }

        stockLevel = try container.decodeIfPresent(Int.self, forKey: .stockLevel)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        metadata = try container.decodeIfPresent([String: AnyCodable].self, forKey: .metadata)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
    }
}

struct ProductsResponse: Codable {
    let success: Bool
    let data: ProductsData

    struct ProductsData: Codable {
        let products: [Product]
    }
}

struct ProductDetailResponse: Codable {
    let success: Bool
    let data: ProductData

    struct ProductData: Codable {
        let product: Product
    }
}

// Import CustomAnyCodable from Upload.swift
typealias AnyCodable = CustomAnyCodable

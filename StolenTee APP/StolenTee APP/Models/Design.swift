import Foundation

struct SavedDesign: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let productId: String
    let variantId: String?
    let designData: DesignData
    let artworkIds: [String]
    let thumbnailUrl: String?
    let notes: String?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, notes
        case userId
        case productId
        case variantId
        case designData
        case artworkIds
        case thumbnailUrl
        case createdAt
        case updatedAt
    }
}

struct DesignData: Codable {
    let canvasObjects: [CanvasObject]
    let backgroundColor: String?
    let selectedView: String? // "front", "back", "neck"

    enum CodingKeys: String, CodingKey {
        case canvasObjects
        case backgroundColor
        case selectedView
    }
}

struct CanvasObject: Codable, Identifiable {
    let id: String
    let type: String // "image", "text"
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    let rotation: Double
    let scaleX: Double
    let scaleY: Double
    let imageUrl: String?
    let text: String?
    let fontFamily: String?
    let fontSize: Double?
    let fill: String?
    let stroke: String?

    enum CodingKeys: String, CodingKey {
        case id, type, x, y, width, height, rotation, text, fill, stroke
        case scaleX
        case scaleY
        case imageUrl
        case fontFamily
        case fontSize
    }
}

struct SaveDesignRequest: Codable {
    let name: String
    let productId: String
    let variantId: String?
    let designData: DesignData
    let artworkIds: [String]
    let thumbnailUrl: String?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case name, notes
        case productId
        case variantId
        case designData
        case artworkIds
        case thumbnailUrl
    }
}

struct DesignsResponse: Codable {
    let designs: [SavedDesign]
}

struct DesignResponse: Codable {
    let design: SavedDesign
}

// Convenience typealias for backward compatibility
typealias Design = SavedDesign

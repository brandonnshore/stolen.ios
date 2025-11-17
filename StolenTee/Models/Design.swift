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
        case userId = "user_id"
        case productId = "product_id"
        case variantId = "variant_id"
        case designData = "design_data"
        case artworkIds = "artwork_ids"
        case thumbnailUrl = "thumbnail_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct DesignData: Codable {
    let canvasObjects: [CanvasObject]
    let backgroundColor: String?
    let selectedView: String? // "front", "back", "neck"

    enum CodingKeys: String, CodingKey {
        case canvasObjects = "canvas_objects"
        case backgroundColor = "background_color"
        case selectedView = "selected_view"
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
        case scaleX = "scale_x"
        case scaleY = "scale_y"
        case imageUrl = "image_url"
        case fontFamily = "font_family"
        case fontSize = "font_size"
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
        case productId = "product_id"
        case variantId = "variant_id"
        case designData = "design_data"
        case artworkIds = "artwork_ids"
        case thumbnailUrl = "thumbnail_url"
    }
}

struct DesignsResponse: Codable {
    let designs: [SavedDesign]
}

struct DesignResponse: Codable {
    let design: SavedDesign
}

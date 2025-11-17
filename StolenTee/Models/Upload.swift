import Foundation

// MARK: - CustomAnyCodable Helper (renamed to avoid conflict with Supabase)
struct CustomAnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([CustomAnyCodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictValue = try? container.decode([String: CustomAnyCodable].self) {
            value = dictValue.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "AnyCodable value cannot be decoded"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let arrayValue as [Any]:
            try container.encode(arrayValue.map { CustomAnyCodable($0) })
        case let dictValue as [String: Any]:
            try container.encode(dictValue.mapValues { CustomAnyCodable($0) })
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "AnyCodable value cannot be encoded"
                )
            )
        }
    }
}

struct Asset: Codable, Identifiable {
    let id: String
    let ownerType: String?
    let ownerId: String?
    let fileUrl: String
    let fileType: String
    let fileSize: Int?
    let originalName: String?
    let hash: String?
    let width: Int?
    let height: Int?
    let dpi: Int?
    let metadata: [String: CustomAnyCodable]?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, hash, width, height, dpi, metadata
        case ownerType = "owner_type"
        case ownerId = "owner_id"
        case fileUrl = "file_url"
        case fileType = "file_type"
        case fileSize = "file_size"
        case originalName = "original_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UploadResponse: Codable {
    let asset: Asset
}

struct ShirtPhotoUploadResponse: Codable {
    let asset: Asset
    let jobId: String

    enum CodingKeys: String, CodingKey {
        case asset
        case jobId = "job_id"
    }
}

struct Job: Codable, Identifiable {
    let id: String
    let userId: String?
    let uploadAssetId: String
    let status: String // "queued", "running", "done", "error"
    let logs: String?
    let errorMessage: String?
    let resultData: JobResultData?
    let createdAt: Date?
    let updatedAt: Date?
    let completedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, status, logs
        case userId = "user_id"
        case uploadAssetId = "upload_asset_id"
        case errorMessage = "error_message"
        case resultData = "result_data"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case completedAt = "completed_at"
    }
}

struct JobResultData: Codable {
    let whiteBackgroundAssetId: String?
    let transparentAssetId: String?
    let maskAssetId: String?

    enum CodingKeys: String, CodingKey {
        case whiteBackgroundAssetId = "white_background_asset_id"
        case transparentAssetId = "transparent_asset_id"
        case maskAssetId = "mask_asset_id"
    }
}

struct JobResponse: Codable {
    let job: Job
    let assets: [Asset]?
}

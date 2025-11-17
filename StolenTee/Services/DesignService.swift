import Foundation

class DesignService {
    static let shared = DesignService()
    private init() {}

    // MARK: - Get All Designs
    func getDesigns() async throws -> [SavedDesign] {
        let response: DesignsResponse = try await APIClient.shared.request(
            endpoint: Configuration.Endpoint.designs,
            requiresAuth: true
        )
        return response.designs
    }

    // MARK: - Get Design
    func getDesign(id: String) async throws -> SavedDesign {
        let response: DesignResponse = try await APIClient.shared.request(
            endpoint: Configuration.Endpoint.designDetail(id),
            requiresAuth: true
        )
        return response.design
    }

    // MARK: - Save Design
    func saveDesign(request: SaveDesignRequest) async throws -> SavedDesign {
        let response: DesignResponse = try await APIClient.shared.request(
            endpoint: Configuration.Endpoint.designs,
            method: .post,
            body: request,
            requiresAuth: true
        )
        return response.design
    }

    // MARK: - Update Design
    func updateDesign(id: String, request: SaveDesignRequest) async throws -> SavedDesign {
        let response: DesignResponse = try await APIClient.shared.request(
            endpoint: Configuration.Endpoint.designDetail(id),
            method: .put,
            body: request,
            requiresAuth: true
        )
        return response.design
    }

    // MARK: - Delete Design
    func deleteDesign(id: String) async throws {
        struct DeleteResponse: Codable {
            let message: String
        }

        let _: DeleteResponse = try await APIClient.shared.request(
            endpoint: Configuration.Endpoint.designDetail(id),
            method: .delete,
            requiresAuth: true
        )
    }
}

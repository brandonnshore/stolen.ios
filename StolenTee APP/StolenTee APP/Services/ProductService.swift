import Foundation

class ProductService {
    static let shared = ProductService()
    private init() {}

    // MARK: - Get All Products
    func getProducts() async throws -> [Product] {
        let response: ProductsResponse = try await APIClient.shared.request(
            endpoint: Configuration.Endpoint.products
        )
        return response.data.products
    }

    // MARK: - Get Product Detail
    func getProductDetail(slug: String) async throws -> Product {
        let response: ProductDetailResponse = try await APIClient.shared.request(
            endpoint: Configuration.Endpoint.productDetail(slug)
        )
        return response.data.product
    }
}

import Foundation
import SwiftUI
import Combine

@MainActor
class ProductsViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Load Products
    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        print("🔵 Starting to load products...")

        do {
            products = try await ProductService.shared.getProducts()
            print("✅ Successfully loaded \(products.count) products")
            for product in products {
                print("  - \(product.title) with \(product.variants?.count ?? 0) variants")
            }
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to load products from API: \(error)")
            print("❌ Error type: \(type(of: error))")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("❌ Key '\(key.stringValue)' not found: \(context.debugDescription)")
                    print("❌ Coding path: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("❌ Type mismatch for type \(type): \(context.debugDescription)")
                    print("❌ Coding path: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("❌ Value not found for type \(type): \(context.debugDescription)")
                    print("❌ Coding path: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("❌ Data corrupted: \(context.debugDescription)")
                    print("❌ Coding path: \(context.codingPath)")
                @unknown default:
                    print("❌ Unknown decoding error")
                }
            }
        }

        isLoading = false
    }
}

@MainActor
class ProductDetailViewModel: ObservableObject {
    @Published var product: Product?
    @Published var selectedVariant: ProductVariant?
    @Published var selectedColor: String?
    @Published var selectedSize: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Load Product Detail
    func loadProduct(slug: String) async {
        isLoading = true
        errorMessage = nil

        do {
            product = try await ProductService.shared.getProductDetail(slug: slug)

            // Set defaults
            if let firstVariant = product?.variants?.first {
                selectedVariant = firstVariant
                selectedColor = firstVariant.color
                selectedSize = firstVariant.size
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Available Colors
    var availableColors: [String] {
        guard let variants = product?.variants else { return [] }
        return Array(Set(variants.map { $0.color })).sorted()
    }

    // MARK: - Available Sizes for Selected Color
    var availableSizes: [String] {
        guard let variants = product?.variants, let color = selectedColor else { return [] }
        return variants
            .filter { $0.color == color }
            .map { $0.size }
            .sorted()
    }

    // MARK: - Update Selected Variant
    func updateVariant() {
        guard let variants = product?.variants,
              let color = selectedColor,
              let size = selectedSize else { return }

        selectedVariant = variants.first { $0.color == color && $0.size == size }
    }

    // MARK: - Select Color
    func selectColor(_ color: String) {
        selectedColor = color

        // Update size if current size not available in new color
        if !availableSizes.contains(selectedSize ?? "") {
            selectedSize = availableSizes.first
        }

        updateVariant()
    }

    // MARK: - Select Size
    func selectSize(_ size: String) {
        selectedSize = size
        updateVariant()
    }
}

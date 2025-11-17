#!/usr/bin/swift
import Foundation

// Minimal test models matching the app
struct TestProductsResponse: Codable {
    let success: Bool
    let data: ProductsData

    struct ProductsData: Codable {
        let products: [TestProduct]
    }
}

struct TestProduct: Codable {
    let id: String
    let title: String
    let variants: [TestVariant]?
}

struct TestVariant: Codable {
    let id: String
    let productId: String
    let basePrice: Double
    let baseCost: Double?

    enum CodingKeys: String, CodingKey {
        case id, productId, basePrice, baseCost
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        productId = try container.decode(String.self, forKey: .productId)

        // Try string then double
        if let basePriceString = try? container.decode(String.self, forKey: .basePrice) {
            basePrice = Double(basePriceString) ?? 0.0
            print("  🔸 Decoded basePrice from string: \(basePriceString)")
        } else {
            basePrice = try container.decode(Double.self, forKey: .basePrice)
            print("  🔸 Decoded basePrice from double")
        }

        if let baseCostString = try? container.decode(String.self, forKey: .baseCost) {
            baseCost = Double(baseCostString)
        } else {
            baseCost = try? container.decode(Double.self, forKey: .baseCost)
        }
    }
}

print("🧪 Testing API decoding with convertFromSnakeCase...\n")

let url = URL(string: "https://stolentee-backend-production.up.railway.app/api/products")!

let task = URLSession.shared.dataTask(with: url) { data, response, error in
    guard let data = data else {
        print("❌ No data")
        exit(1)
    }

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .iso8601

    do {
        let response = try decoder.decode(TestProductsResponse.self, from: data)
        print("✅ SUCCESS! Decoded \(response.data.products.count) products")
        for product in response.data.products {
            print("  - \(product.title): \(product.variants?.count ?? 0) variants")
        }
    } catch let DecodingError.keyNotFound(key, context) {
        print("❌ Key '\(key.stringValue)' not found")
        print("   Context: \(context.debugDescription)")
        print("   Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
    } catch let DecodingError.typeMismatch(type, context) {
        print("❌ Type mismatch for \(type)")
        print("   Context: \(context.debugDescription)")
        print("   Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
    } catch {
        print("❌ Decoding error: \(error)")
    }

    exit(0)
}

task.resume()
RunLoop.main.run(until: Date(timeIntervalSinceNow: 10))

#!/usr/bin/swift
import Foundation

// Test the API decoding

let url = URL(string: "https://stolentee-backend-production.up.railway.app/api/products")!

let task = URLSession.shared.dataTask(with: url) { data, response, error in
    if let error = error {
        print("❌ Network error: \(error)")
        exit(1)
    }

    guard let data = data else {
        print("❌ No data received")
        exit(1)
    }

    // Print raw response
    if let jsonString = String(data: data, encoding: .utf8) {
        print("📦 Raw API Response:")
        print(jsonString.prefix(1000))
        print("\n")
    }

    // Test JSON structure
    do {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        print("✅ Valid JSON")
        print("  - Keys: \(json?.keys.joined(separator: ", ") ?? "none")")

        if let success = json?["success"] as? Bool {
            print("  - Success: \(success)")
        }

        if let data = json?["data"] as? [String: Any] {
            print("  - Data keys: \(data.keys.joined(separator: ", "))")

            if let products = data["products"] as? [[String: Any]] {
                print("  - Products count: \(products.count)")

                if let first = products.first {
                    print("\n📍 First product keys: \(first.keys.joined(separator: ", "))")

                    if let variants = first["variants"] as? [[String: Any]], let firstVariant = variants.first {
                        print("📍 First variant keys: \(firstVariant.keys.joined(separator: ", "))")
                        print("   - base_price type: \(type(of: firstVariant["base_price"] as Any))")
                        print("   - base_price value: \(firstVariant["base_price"] as Any)")
                    }
                }
            }
        }
    } catch {
        print("❌ JSON parsing error: \(error)")
    }

    exit(0)
}

task.resume()

// Keep script running
RunLoop.main.run(until: Date(timeIntervalSinceNow: 10))

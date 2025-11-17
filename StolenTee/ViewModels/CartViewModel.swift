import Foundation
import SwiftUI
import Combine

struct CartItem: Identifiable, Codable {
    let id: String
    let variant: ProductVariant
    let product: Product
    let quantity: Int
    let customSpec: CustomizationSpec?
    let mockupUrl: String?
    let unitPrice: Double

    var totalPrice: Double {
        unitPrice * Double(quantity)
    }
}

@MainActor
class CartViewModel: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var isLoading = false

    private let userDefaultsKey = "cart_items"

    init() {
        loadCart()
    }

    // MARK: - Computed Properties
    var subtotal: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    // MARK: - Add to Cart
    func addItem(
        variant: ProductVariant,
        product: Product,
        quantity: Int,
        customSpec: CustomizationSpec?,
        mockupUrl: String?,
        unitPrice: Double
    ) {
        let item = CartItem(
            id: UUID().uuidString,
            variant: variant,
            product: product,
            quantity: quantity,
            customSpec: customSpec,
            mockupUrl: mockupUrl,
            unitPrice: unitPrice
        )

        items.append(item)
        saveCart()
    }

    // MARK: - Remove from Cart
    func removeItem(_ item: CartItem) {
        items.removeAll { $0.id == item.id }
        saveCart()
    }

    // MARK: - Update Quantity
    func updateQuantity(item: CartItem, quantity: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = CartItem(
                id: item.id,
                variant: item.variant,
                product: item.product,
                quantity: quantity,
                customSpec: item.customSpec,
                mockupUrl: item.mockupUrl,
                unitPrice: item.unitPrice
            )
            saveCart()
        }
    }

    // MARK: - Clear Cart
    func clearCart() {
        items = []
        saveCart()
    }

    // MARK: - Persistence
    private func saveCart() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadCart() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([CartItem].self, from: data) {
            items = decoded
        }
    }
}

import Foundation
import NetworkPackage

public protocol CartService: Sendable {
    func loadCart() async throws -> CartSnapshot
    func addProduct(id: String) async throws
    func removeProduct(id: String) async throws
}

public struct DefaultCartService: CartService {
    private let api: any CartAPI

    public init(api: any CartAPI) { self.api = api }

    public func loadCart() async throws -> CartSnapshot {
        let payload = try await api.loadCart()
        let snapshot = CartSnapshot(items: payload.items.map { item in
            let product = item.value1
            return CartItem(id: product.id, name: product.name, imageURL: validatedImageURL(product.image),
                            price: product.price, weight: product.weight, quantity: product.quantity,
                            isAvailable: item.value2.available)
        }, orderPrice: payload.orderPrice, deliveryPrice: payload.deliveryPrice,
        totalPrice: payload.totalPrice, totalItems: payload.totalItems, deliveryTime: payload.deliveryTime)
        try snapshot.validate()
        return snapshot
    }

    public func addProduct(id: String) async throws { try await api.addProduct(id: id) }
    public func removeProduct(id: String) async throws { try await api.removeProduct(id: id) }
}

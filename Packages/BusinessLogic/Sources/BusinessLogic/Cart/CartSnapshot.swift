import Foundation

public struct CartItem: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let imageURL: URL?
    public let price: Int
    public let weight: Int
    public let quantity: Int
    public let isAvailable: Bool

    public var lineTotal: Decimal { Decimal(price) * Decimal(quantity) }

    public init(id: String, name: String, imageURL: URL? = nil, price: Int, weight: Int,
                quantity: Int, isAvailable: Bool = true) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.price = price
        self.weight = weight
        self.quantity = quantity
        self.isAvailable = isAvailable
    }
}

public struct CartSnapshot: Codable, Equatable, Sendable {
    public let items: [CartItem]
    public let orderPrice: Int
    public let deliveryPrice: Int
    public let totalPrice: Int
    public let totalItems: Int
    public let deliveryTime: Int

    public init(items: [CartItem], orderPrice: Int, deliveryPrice: Int, totalPrice: Int,
                totalItems: Int, deliveryTime: Int) {
        self.items = items
        self.orderPrice = orderPrice
        self.deliveryPrice = deliveryPrice
        self.totalPrice = totalPrice
        self.totalItems = totalItems
        self.deliveryTime = deliveryTime
    }

    public func quantity(for productID: String) -> Int {
        items.first { $0.id == productID }?.quantity ?? 0
    }

    func validate() throws {
        var ids = Set<String>()
        guard orderPrice >= 0, deliveryPrice >= 0, totalPrice >= 0, totalItems >= 0, deliveryTime >= 0,
              items.allSatisfy({ !$0.id.isEmpty && ids.insert($0.id).inserted && $0.quantity > 0
                  && $0.price >= 0 && $0.weight >= 0 }) else { throw CartError.invalidSnapshot }
    }
}

public enum CartError: Error, Equatable, LocalizedError {
    case requiresSynchronization
    case invalidSnapshot
    case unavailableProduct
    case emptyCart
    case missingAddress

    public var errorDescription: String? {
        switch self {
        case .requiresSynchronization: "Обнови корзину перед изменением товаров."
        case .invalidSnapshot: "Не удалось прочитать данные корзины."
        case .unavailableProduct: "Товар сейчас недоступен."
        case .emptyCart: "Добавь товар в корзину перед оформлением заказа."
        case .missingAddress: "Выбери адрес доставки."
        }
    }
}

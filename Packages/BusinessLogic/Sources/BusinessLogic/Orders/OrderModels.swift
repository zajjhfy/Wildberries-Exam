import Foundation
import NetworkPackage

public enum OrderStatus: Equatable, Sendable { case active, completed }

public struct OrderProduct: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let imageURL: URL?
    public let price: Int
    public let weight: Int
    public let quantity: Int
}

public struct CustomerOrder: Identifiable, Equatable, Sendable {
    public let id: String
    public let status: OrderStatus
    public let deliveryDateText: String?
    public let address: AddressDetails
    public let orderPrice: Int
    public let deliveryPrice: Int
    public let totalPrice: Int
    public let totalItems: Int
    public let items: [OrderProduct]

    static func map(_ dto: OrderDTO) throws -> CustomerOrder {
        let status: OrderStatus = dto.status == .active ? .active : .completed
        return try CustomerOrder(
            id: dto.id, status: status, deliveryDateText: dto.deliveryDate,
            address: AddressDetails.map(dto.address), orderPrice: dto.orderPrice,
            deliveryPrice: dto.deliveryPrice, totalPrice: dto.totalPrice, totalItems: dto.totalItems,
            items: dto.items.map { item in
                OrderProduct(id: item.id, name: item.name, imageURL: validatedImageURL(item.image),
                             price: item.price, weight: item.weight, quantity: item.quantity)
            }
        )
    }
}

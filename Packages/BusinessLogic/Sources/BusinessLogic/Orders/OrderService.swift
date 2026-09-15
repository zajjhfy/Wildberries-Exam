import Foundation
import NetworkPackage

public protocol OrderService: Sendable {
    func loadOrders() async throws -> [CustomerOrder]
    func createOrder(addressID: String, paymentMethod: String) async throws
}

public struct DefaultOrderService: OrderService {
    private let api: any OrderAPI

    public init(api: any OrderAPI) { self.api = api }

    public func loadOrders() async throws -> [CustomerOrder] {
        try await api.loadOrders().map(CustomerOrder.map)
    }

    public func createOrder(addressID: String, paymentMethod: String = "card") async throws {
        guard !addressID.isEmpty, !paymentMethod.isEmpty else { throw NetworkError.invalidRequest }
        try await api.createOrder(addressID: addressID, paymentMethod: paymentMethod)
    }
}

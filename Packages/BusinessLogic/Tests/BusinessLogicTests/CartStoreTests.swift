import Foundation
import Testing
@testable import BusinessLogic

struct CartStoreTests {
    @Test func requiresServerRefreshBeforeChangesAndUsesServerSnapshot() async throws {
        let service = CartFixture()
        let store = CartStore(service: service)
        let offline = fixtureCart(quantity: 3)
        try await store.restore(offline)
        #expect(await store.currentSnapshot() == offline)
        await #expect(throws: CartError.requiresSynchronization) {
            try await store.add(productID: "coffee")
        }

        let initial = try await store.synchronize()
        #expect(initial.quantity(for: "coffee") == 1)
        let updated = try await store.add(productID: "coffee")
        #expect(updated.quantity(for: "coffee") == 2)
        #expect(updated.totalPrice == 220)
        #expect(await service.loadCount == 2)
        #expect(await store.canCheckout())
    }

    @Test func failedRefreshBlocksAnotherMutation() async throws {
        let service = CartFixture(failSecondLoad: true)
        let store = CartStore(service: service)
        try await store.synchronize()
        await #expect(throws: FixtureFailure.self) {
            try await store.add(productID: "coffee")
        }
        await #expect(throws: CartError.requiresSynchronization) {
            try await store.remove(productID: "coffee")
        }
        #expect(await service.addCount == 1)
        #expect(await service.removeCount == 0)
        #expect(await store.canCheckout() == false)
    }

    @Test func successfulOrderIsNotReportedAsFailedWhenCartRefreshFails() async throws {
        let service = CartFixture(failSecondLoad: true)
        let orders = OrderFixture()
        let store = CartStore(service: service)
        try await store.synchronize()
        let refreshed = try await store.checkout(orderService: orders, addressID: "address")
        #expect(refreshed == nil)
        #expect(await orders.createCount == 1)
        #expect(await store.canCheckout() == false)
    }

    @Test @MainActor func checkoutViewModelDoesNotRepeatConfirmedOrder() async throws {
        let service = CartFixture()
        let ordersService = OrderFixture()
        let store = CartStore(service: service)
        let cart = CartViewModel(store: store, persistence: MemoryCartPersistence())
        let addresses = AddressesViewModel(service: AddressFixture())
        let orders = OrdersViewModel(service: ordersService)
        await cart.load()
        await addresses.load()
        addresses.selectedAddressID = "address"
        let checkout = CheckoutViewModel(cartStore: store, cartViewModel: cart,
                                        addresses: addresses, orders: orders,
                                        orderService: ordersService)
        #expect(await checkout.placeOrder())
        #expect(await checkout.placeOrder() == false)
        #expect(await ordersService.createCount == 1)
        #expect(checkout.didPlaceOrder)
    }

    @Test @MainActor func swiftDataRestoresOnlyValidatedCart() throws {
        let persistence = try SwiftDataCartPersistence(scope: "test-cart", inMemory: true)
        #expect(try persistence.load() == nil)
        let snapshot = fixtureCart(quantity: 2)
        try persistence.save(snapshot)
        #expect(try persistence.load() == snapshot)
        let invalid = CartSnapshot(items: [CartItem(id: "", name: "", price: 0, weight: 0, quantity: 0)],
                                   orderPrice: 0, deliveryPrice: 0, totalPrice: 0,
                                   totalItems: 0, deliveryTime: 0)
        #expect(throws: CartError.invalidSnapshot) { try persistence.save(invalid) }
        #expect(try persistence.load() == snapshot)
    }
}

private enum FixtureFailure: Error { case refresh }

private func fixtureCart(quantity: Int) -> CartSnapshot {
    CartSnapshot(items: [CartItem(id: "coffee", name: "Кофе", price: 100, weight: 100,
                                  quantity: quantity)], orderPrice: 100 * quantity,
                 deliveryPrice: 20, totalPrice: 100 * quantity + 20,
                 totalItems: quantity, deliveryTime: 30)
}

private actor CartFixture: CartService {
    private(set) var loadCount = 0
    private(set) var addCount = 0
    private(set) var removeCount = 0
    private var quantity = 1
    private let failSecondLoad: Bool

    init(failSecondLoad: Bool = false) { self.failSecondLoad = failSecondLoad }

    func loadCart() throws -> CartSnapshot {
        loadCount += 1
        if failSecondLoad && loadCount == 2 { throw FixtureFailure.refresh }
        return fixtureCart(quantity: quantity)
    }

    func addProduct(id: String) {
        addCount += 1
        quantity += 1
    }

    func removeProduct(id: String) {
        removeCount += 1
        quantity -= 1
    }
}

private actor OrderFixture: OrderService {
    private(set) var createCount = 0
    func loadOrders() -> [CustomerOrder] { [] }
    func createOrder(addressID: String, paymentMethod: String) { createCount += 1 }
}

@MainActor
private final class MemoryCartPersistence: CartPersistence {
    func load() -> CartSnapshot? { nil }
    func save(_ snapshot: CartSnapshot) {}
}

private struct AddressFixture: AddressService {
    func loadAddresses() -> [DeliveryAddress] {
        guard let coordinates = AddressCoordinates(longitude: 37.6, latitude: 55.7) else { return [] }
        return [DeliveryAddress(id: "address", details: AddressDetails(addressLine: "Москва",
                                                                         coordinates: coordinates))]
    }
    func createAddress(_ details: AddressDetails) {}
    func updateAddress(id: String, details: AddressDetails) {}
    func deleteAddress(id: String) {}
}

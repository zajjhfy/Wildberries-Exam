import Foundation

/// Serializes cart requests across every screen that shares this instance.
public actor CartStore {
    private let service: any CartService
    private var cached: CartSnapshot?
    private var synchronized = false
    private var busy = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    public init(service: any CartService) { self.service = service }

    public func currentSnapshot() -> CartSnapshot? { cached }
    public func canCheckout() -> Bool { synchronized && (cached?.totalItems ?? 0) > 0 }

    public func restore(_ snapshot: CartSnapshot) async throws {
        try snapshot.validate()
        await acquire()
        defer { release() }
        cached = snapshot
        synchronized = false
    }

    @discardableResult
    public func synchronize() async throws -> CartSnapshot {
        await acquire()
        defer { release() }
        try Task.checkCancellation()
        do {
            let snapshot = try await service.loadCart()
            try Task.checkCancellation()
            cached = snapshot
            synchronized = true
            return snapshot
        } catch {
            synchronized = false
            throw error
        }
    }

    @discardableResult
    public func add(productID: String) async throws -> CartSnapshot {
        try await change(productID: productID, adding: true)
    }

    @discardableResult
    public func remove(productID: String) async throws -> CartSnapshot {
        try await change(productID: productID, adding: false)
    }

    /// Returns an updated cart when it can be fetched. A nil result still means POST succeeded.
    public func checkout(orderService: any OrderService, addressID: String,
                         paymentMethod: String = "card") async throws -> CartSnapshot? {
        await acquire()
        defer { release() }
        try Task.checkCancellation()
        guard synchronized, let current = cached else { throw CartError.requiresSynchronization }
        guard current.totalItems > 0 else { throw CartError.emptyCart }
        guard !current.items.contains(where: { !$0.isAvailable }) else { throw CartError.unavailableProduct }
        guard !addressID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw CartError.missingAddress }
        do {
            try await orderService.createOrder(addressID: addressID, paymentMethod: paymentMethod)
        } catch {
            synchronized = false
            throw error
        }
        synchronized = false
        guard let updated = try? await service.loadCart() else { return nil }
        cached = updated
        synchronized = true
        return updated
    }

    private func change(productID: String, adding: Bool) async throws -> CartSnapshot {
        guard !productID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CartError.invalidSnapshot
        }
        await acquire()
        defer { release() }
        try Task.checkCancellation()
        guard synchronized, let current = cached else { throw CartError.requiresSynchronization }
        if !adding && current.quantity(for: productID) == 0 { return current }
        if adding && current.items.first(where: { $0.id == productID })?.isAvailable == false {
            throw CartError.unavailableProduct
        }
        do {
            if adding { try await service.addProduct(id: productID) }
            else { try await service.removeProduct(id: productID) }
            // A mutation may have reached the server even if its reply is lost.
            synchronized = false
            let updated = try await service.loadCart()
            try Task.checkCancellation()
            cached = updated
            synchronized = true
            return updated
        } catch {
            synchronized = false
            throw error
        }
    }

    private func acquire() async {
        if !busy { busy = true; return }
        await withCheckedContinuation { waiters.append($0) }
    }

    private func release() {
        if waiters.isEmpty { busy = false }
        else { waiters.removeFirst().resume() }
    }
}

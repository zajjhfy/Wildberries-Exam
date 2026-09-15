import Foundation
import Observation

@MainActor
@Observable
public final class OrdersViewModel {
    public enum State: Equatable { case idle, loading, loaded, failed(String) }

    public private(set) var state: State = .idle
    public private(set) var orders: [CustomerOrder] = []
    public private(set) var isSubmitting = false
    public private(set) var creationError: String?
    public private(set) var refreshError: String?

    @ObservationIgnored private let service: any OrderService

    public init(service: any OrderService) { self.service = service }

    public func load() async {
        guard state != .loading, !isSubmitting else { return }
        state = .loading
        do {
            orders = try await service.loadOrders()
            try Task.checkCancellation()
            state = .loaded
        } catch {
            state = error is CancellationError ? .idle : .failed(error.localizedDescription)
        }
    }

    /// True means POST succeeded; a later GET failure is reported separately.
    @discardableResult
    public func create(addressID: String, paymentMethod: String = "card") async -> Bool {
        guard !isSubmitting else { return false }
        isSubmitting = true
        defer { isSubmitting = false }
        creationError = nil
        refreshError = nil
        do { try await service.createOrder(addressID: addressID, paymentMethod: paymentMethod) }
        catch {
            if !(error is CancellationError) { creationError = error.localizedDescription }
            return false
        }
        do { orders = try await service.loadOrders(); state = .loaded }
        catch { if !(error is CancellationError) { refreshError = error.localizedDescription } }
        return true
    }
}

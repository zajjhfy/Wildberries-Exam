import Foundation
import Observation

@MainActor
@Observable
public final class AddressesViewModel {
    public enum State: Equatable { case idle, loading, loaded, failed(String) }

    public private(set) var state: State = .idle
    public private(set) var addresses: [DeliveryAddress] = []
    public private(set) var isUpdating = false
    public private(set) var actionError: String?
    public var selectedAddressID: String?

    @ObservationIgnored private let service: any AddressService

    public init(service: any AddressService) { self.service = service }

    public func load() async {
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }
        state = .loading
        do {
            try await refresh()
            state = .loaded
        } catch {
            state = error is CancellationError ? .idle : .failed(error.localizedDescription)
        }
    }

    public func create(_ details: AddressDetails) async { await change { try await service.createAddress(details) } }
    public func update(id: String, details: AddressDetails) async {
        await change { try await service.updateAddress(id: id, details: details) }
    }
    public func delete(id: String) async { await change { try await service.deleteAddress(id: id) } }

    private func change(_ operation: () async throws -> Void) async {
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }
        actionError = nil
        do {
            try await operation()
        } catch {
            if !(error is CancellationError) { actionError = error.localizedDescription }
            return
        }
        do { try await refresh(); state = .loaded }
        catch { if !(error is CancellationError) { actionError = "Изменение сохранено, но список адресов не обновился: \(error.localizedDescription)" } }
    }

    private func refresh() async throws {
        let updated = try await service.loadAddresses()
        try Task.checkCancellation()
        addresses = updated
        if let selectedAddressID, !updated.contains(where: { $0.id == selectedAddressID }) {
            self.selectedAddressID = nil
        }
    }
}

import Foundation
import Observation

/// Keep one instance at the app root so counters stay consistent on every screen.
@MainActor
@Observable
public final class CartViewModel {
    public enum State: Equatable { case idle, loading, loaded, failed(String) }

    public private(set) var state: State = .idle
    public private(set) var snapshot: CartSnapshot?
    public private(set) var isSynchronized = false
    public private(set) var isUpdating = false
    public private(set) var persistenceError: String?

    @ObservationIgnored private let store: CartStore
    @ObservationIgnored private let persistence: any CartPersistence
    @ObservationIgnored private var bootstrapped = false

    public init(store: CartStore, persistence: any CartPersistence) {
        self.store = store
        self.persistence = persistence
    }

    public func quantity(for productID: String) -> Int { snapshot?.quantity(for: productID) ?? 0 }

    public func load() async {
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }
        if !bootstrapped {
            bootstrapped = true
            do {
                if let local = try persistence.load() {
                    try await store.restore(local)
                    snapshot = local
                    state = .loaded
                }
            } catch { persistenceError = error.localizedDescription }
        }
        state = .loading
        do {
            let updated = try await store.synchronize()
            snapshot = updated
            isSynchronized = true
            state = .loaded
            persist(updated)
        } catch {
            isSynchronized = false
            state = error is CancellationError ? .idle : .failed(error.localizedDescription)
        }
    }

    public func add(productID: String) async { await update(productID: productID, adding: true) }
    public func remove(productID: String) async { await update(productID: productID, adding: false) }

    /// Called after a successful checkout performed by the shared CartStore.
    public func applyCheckoutResult(_ updated: CartSnapshot?) {
        isSynchronized = updated != nil
        state = updated == nil ? .idle : .loaded
        if let updated { snapshot = updated; persist(updated) }
    }

    private func update(productID: String, adding: Bool) async {
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }
        do {
            let updated = try await (adding ? store.add(productID: productID) : store.remove(productID: productID))
            snapshot = updated
            isSynchronized = true
            state = .loaded
            persist(updated)
        } catch {
            isSynchronized = false
            state = error is CancellationError ? .idle : .failed(error.localizedDescription)
        }
    }

    private func persist(_ snapshot: CartSnapshot) {
        do { try persistence.save(snapshot); persistenceError = nil }
        catch { persistenceError = error.localizedDescription }
    }
}

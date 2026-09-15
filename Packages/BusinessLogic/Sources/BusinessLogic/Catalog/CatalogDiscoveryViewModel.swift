import Foundation
import Observation

@MainActor
@Observable
public final class CatalogDiscoveryViewModel {
    public enum State: Equatable { case idle, loading, loaded, failed(String) }
    public enum Section: Equatable { case search(String), discounts, orderedBefore }

    public private(set) var state: State = .idle
    public private(set) var products: [CatalogProduct] = []
    public private(set) var selectedSection: Section = .search("")

    @ObservationIgnored private let service: CatalogDiscoveryService
    @ObservationIgnored private var requestID = UUID()

    public init(service: CatalogDiscoveryService) { self.service = service }

    public func load(_ section: Section) async {
        selectedSection = section
        let activeRequest = UUID()
        requestID = activeRequest
        state = .loading
        do {
            let results: [CatalogProduct]
            switch section {
            case .search(let query): results = try await service.search(query)
            case .discounts: results = try await service.discountedProducts()
            case .orderedBefore: results = try await service.previouslyOrderedProducts()
            }
            try Task.checkCancellation()
            guard requestID == activeRequest else { return }
            products = results
            state = .loaded
        } catch {
            guard requestID == activeRequest else { return }
            state = error is CancellationError ? .idle : .failed(error.localizedDescription)
        }
    }
}

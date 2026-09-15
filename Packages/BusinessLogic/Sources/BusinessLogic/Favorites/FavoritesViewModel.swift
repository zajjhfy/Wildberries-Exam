import Foundation
import Observation

/// Share one instance across catalog, details and favorites screens.
@MainActor
@Observable
public final class FavoritesViewModel {
    public enum State: Equatable { case idle, loading, loaded, failed(String) }

    public private(set) var state: State = .idle
    public private(set) var products: [CatalogProduct] = []
    public private(set) var isUpdating = false
    public private(set) var actionError: String?

    @ObservationIgnored private let service: any FavoriteService
    private var overrides: [String: Bool] = [:]

    public init(service: any FavoriteService) { self.service = service }

    public func isFavorite(_ product: CatalogProduct) -> Bool {
        overrides[product.id] ?? product.isFavorite
    }

    public func load() async {
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }
        state = .loading
        do {
            products = try await service.loadFavorites()
            try Task.checkCancellation()
            overrides = [:]
            state = .loaded
        } catch {
            state = error is CancellationError ? .idle : .failed(error.localizedDescription)
        }
    }

    public func toggle(_ product: CatalogProduct) async {
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }
        actionError = nil
        let next = !isFavorite(product)
        do {
            try await service.setFavorite(next, productID: product.id)
            overrides[product.id] = next
            if next {
                if !products.contains(where: { $0.id == product.id }) {
                    products.append(product.withFavorite(true))
                }
            } else {
                products.removeAll { $0.id == product.id }
            }
        } catch {
            if !(error is CancellationError) { actionError = error.localizedDescription }
        }
    }
}

private extension CatalogProduct {
    func withFavorite(_ isFavorite: Bool) -> CatalogProduct {
        CatalogProduct(id: id, name: name, imageURL: imageURL, price: price,
                       weight: weight, rating: rating, reviewCount: reviewCount,
                       isFavorite: isFavorite, discount: discount)
    }
}

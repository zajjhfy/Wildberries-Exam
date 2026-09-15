import Foundation
import NetworkPackage

public protocol FavoriteService: Sendable {
    func loadFavorites() async throws -> [CatalogProduct]
    func setFavorite(_ isFavorite: Bool, productID: String) async throws
}

public struct DefaultFavoriteService: FavoriteService {
    private let catalog: any CatalogService
    private let api: any FavoriteAPI
    private let pageSize: Int

    public init(catalog: any CatalogService, api: any FavoriteAPI, pageSize: Int = 50) {
        self.catalog = catalog
        self.api = api
        self.pageSize = max(1, pageSize)
    }

    public func loadFavorites() async throws -> [CatalogProduct] {
        var result: [CatalogProduct] = []
        var seenIDs = Set<String>()
        var page = 1
        repeat {
            try Task.checkCancellation()
            let payload = try await catalog.loadProducts(categoryID: nil, page: page, pageSize: pageSize)
            result += payload.products.filter { $0.isFavorite && seenIDs.insert($0.id).inserted }
            guard payload.hasNextPage else { break }
            page += 1
        } while true
        return result
    }

    public func setFavorite(_ isFavorite: Bool, productID: String) async throws {
        try await api.setFavorite(isFavorite, productID: productID)
    }
}

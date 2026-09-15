import Foundation

/// The current API has no search/discount endpoints, so these sections use catalog pages.
public actor CatalogDiscoveryService {
    private let catalog: any CatalogService
    private let orders: any OrderService
    private let pageSize: Int
    private var cachedProducts: [CatalogProduct]?
    private var inFlight: Task<[CatalogProduct], any Error>?

    public init(catalog: any CatalogService, orders: any OrderService, pageSize: Int = 50) {
        self.catalog = catalog
        self.orders = orders
        self.pageSize = max(1, pageSize)
    }

    public func search(_ query: String) async throws -> [CatalogProduct] {
        let products = try await allProducts()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? products : products.filter { $0.name.localizedStandardContains(trimmed) }
    }

    public func discountedProducts() async throws -> [CatalogProduct] {
        try await allProducts().filter { ($0.discount ?? 0) > 0 }
    }

    public func previouslyOrderedProducts() async throws -> [CatalogProduct] {
        async let products = allProducts()
        async let history = orders.loadOrders()
        let (catalog, orders) = try await (products, history)
        let ids = Set(orders.flatMap { $0.items.map(\.id) })
        return catalog.filter { ids.contains($0.id) }
    }

    private func allProducts() async throws -> [CatalogProduct] {
        try Task.checkCancellation()
        if let cachedProducts { return cachedProducts }
        if let inFlight { return try await inFlight.value }
        let catalog = self.catalog
        let pageSize = self.pageSize
        let task = Task<[CatalogProduct], any Error> {
            var products: [CatalogProduct] = []
            var seenIDs = Set<String>()
            var page = 1
            repeat {
                try Task.checkCancellation()
                let payload = try await catalog.loadProducts(categoryID: nil, page: page, pageSize: pageSize)
                products += payload.products.filter { seenIDs.insert($0.id).inserted }
                guard payload.hasNextPage else { break }
                page += 1
            } while true
            return products
        }
        inFlight = task
        do {
            let products = try await task.value
            cachedProducts = products
            inFlight = nil
            try Task.checkCancellation()
            return products
        } catch {
            inFlight = nil
            throw error
        }
    }
}

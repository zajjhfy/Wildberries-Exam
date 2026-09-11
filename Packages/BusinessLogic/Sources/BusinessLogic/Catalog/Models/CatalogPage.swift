public struct CatalogPage: Equatable, Sendable {
    public let products: [CatalogProduct]
    public let currentPage: Int
    public let totalPages: Int

    public var hasNextPage: Bool { currentPage < totalPages }

    public init(products: [CatalogProduct], currentPage: Int, totalPages: Int) {
        self.products = products
        self.currentPage = currentPage
        self.totalPages = totalPages
    }
}

public typealias CategoryDTO = Components.Schemas.Category
public typealias ProductPreviewDTO = Components.Schemas.ProductPreview

public struct ProductsPageDTO: Sendable {
    public let products: [ProductPreviewDTO]
    public let currentPage: Int
    public let totalPages: Int

    public init(products: [ProductPreviewDTO], currentPage: Int, totalPages: Int) {
        self.products = products
        self.currentPage = currentPage
        self.totalPages = totalPages
    }
}

public protocol CatalogAPI: Sendable {
    func loadCategories() async throws -> [CategoryDTO]
    func loadProducts(categoryID: String?, page: Int, pageSize: Int) async throws -> ProductsPageDTO
}

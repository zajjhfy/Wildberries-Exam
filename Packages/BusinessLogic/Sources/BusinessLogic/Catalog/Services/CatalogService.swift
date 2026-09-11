public protocol CatalogService: Sendable {
    func loadCategories() async throws -> [CatalogCategory]
    func loadProducts(categoryID: String?, page: Int, pageSize: Int) async throws -> CatalogPage
}

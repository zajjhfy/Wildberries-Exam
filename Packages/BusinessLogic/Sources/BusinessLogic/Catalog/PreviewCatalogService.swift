import NetworkPackage

/// Explicit sample data for previews. Never used as a fallback for an API error.
public struct PreviewCatalogService: CatalogService {
    public init() {}

    public func loadCategories() async throws -> [CatalogCategory] {
        [
            CatalogCategory(id: "bakery", name: "Выпечка"),
            CatalogCategory(id: "drinks", name: "Напитки"),
        ]
    }

    public func loadProducts(categoryID: String?, page: Int, pageSize: Int) async throws -> CatalogPage {
        guard page > 0, pageSize > 0 else { throw NetworkError.invalidRequest }
        let items: [(categoryID: String, product: CatalogProduct)] = [
            ("bakery", CatalogProduct(
                id: "croissant", name: "Круассан", price: 150, weight: 80,
                rating: 4.5, reviewCount: 12, isFavorite: false
            )),
            ("drinks", CatalogProduct(
                id: "coffee", name: "Кофе", price: 200, weight: 250,
                rating: 5, reviewCount: 8, isFavorite: true
            )),
        ]
        let products = items.filter { categoryID == nil || $0.categoryID == categoryID }.map(\.product)
        let totalPages = products.isEmpty ? 0 : (products.count - 1) / pageSize + 1
        guard page <= max(totalPages, 1) else {
            return CatalogPage(products: [], currentPage: page, totalPages: totalPages)
        }
        let start = (page - 1) * pageSize
        let end = start + min(pageSize, products.count - start)
        return CatalogPage(products: Array(products[start..<end]), currentPage: page, totalPages: totalPages)
    }
}

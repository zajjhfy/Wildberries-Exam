import Foundation
import NetworkPackage

public struct DefaultCatalogService: CatalogService {
    private let api: any CatalogAPI

    public init(api: any CatalogAPI) {
        self.api = api
    }

    public func loadCategories() async throws -> [CatalogCategory] {
        try await api.loadCategories().map {
            CatalogCategory(id: $0.id, name: $0.name, imageURL: imageURL(from: $0.image))
        }
    }

    public func loadProducts(categoryID: String?, page: Int, pageSize: Int) async throws -> CatalogPage {
        let payload = try await api.loadProducts(categoryID: categoryID, page: page, pageSize: pageSize)
        return CatalogPage(
            products: payload.products.map {
                CatalogProduct(
                    id: $0.id,
                    name: $0.name,
                    imageURL: imageURL(from: $0.image),
                    price: $0.price,
                    weight: $0.weight,
                    rating: Double($0.rating),
                    reviewCount: $0.reviewCount,
                    isFavorite: $0.isFavorite,
                    discount: $0.discount
                )
            },
            currentPage: payload.currentPage,
            totalPages: payload.totalPages
        )
    }

    private func imageURL(from value: String) -> URL? {
        guard let url = URL(string: value),
              let scheme = url.scheme?.lowercased(), ["https", "http"].contains(scheme),
              let host = url.host, !host.isEmpty,
              url.user == nil, url.password == nil else { return nil }
        return url
    }
}

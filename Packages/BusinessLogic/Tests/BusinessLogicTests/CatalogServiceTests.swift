import Foundation
import NetworkPackage
import Testing
@testable import BusinessLogic

struct CatalogServiceTests {
    @Test func mapsProductWithoutLosingFractionalWeight() async throws {
        let service = DefaultCatalogService(api: FixtureAPI(image: "https://example.com/product.png"))
        let page = try await service.loadProducts(categoryID: nil, page: 1, pageSize: 20)
        let product = try #require(page.products.first)
        #expect(product.id == "product")
        #expect(product.price == 150)
        #expect(product.weight == 80.5)
        #expect(product.rating == 4.5)
        #expect(product.reviewCount == 12)
        #expect(product.isFavorite)
        #expect(product.discount == 10)
        #expect(product.imageURL?.absoluteString == "https://example.com/product.png")
        #expect(!page.hasNextPage)
    }

    @Test(arguments: ["", "relative/image.png", "file:///private/image.png", "https://user:secret@example.com/image.png"])
    func invalidImageURLBecomesPlaceholder(_ image: String) async throws {
        let service = DefaultCatalogService(api: FixtureAPI(image: image))
        let categories = try await service.loadCategories()
        let page = try await service.loadProducts(categoryID: nil, page: 1, pageSize: 20)
        #expect(categories.count == 1)
        #expect(categories.first?.imageURL == nil)
        #expect(page.products.count == 1)
        #expect(page.products.first?.imageURL == nil)
    }

    @Test func previewFiltersAndPaginates() async throws {
        let service = PreviewCatalogService()
        let first = try await service.loadProducts(categoryID: nil, page: 1, pageSize: 1)
        let second = try await service.loadProducts(categoryID: nil, page: 2, pageSize: 1)
        let drinks = try await service.loadProducts(categoryID: "drinks", page: 1, pageSize: 20)
        #expect(first.products.map(\.id) == ["croissant"])
        #expect(first.hasNextPage)
        #expect(second.products.map(\.id) == ["coffee"])
        #expect(!second.hasNextPage)
        #expect(drinks.products.map(\.id) == ["coffee"])
    }
}

private struct FixtureAPI: CatalogAPI {
    let image: String

    func loadCategories() async throws -> [CategoryDTO] {
        [CategoryDTO(id: "bakery", name: "Выпечка", image: image)]
    }

    func loadProducts(categoryID: String?, page: Int, pageSize: Int) async throws -> ProductsPageDTO {
        ProductsPageDTO(
            products: [ProductPreviewDTO(
                id: "product", image: image, name: "Круассан", weight: 80.5,
                price: 150, rating: 4.5, reviewCount: 12, isFavorite: true, discount: 10
            )],
            currentPage: 1,
            totalPages: 1
        )
    }
}

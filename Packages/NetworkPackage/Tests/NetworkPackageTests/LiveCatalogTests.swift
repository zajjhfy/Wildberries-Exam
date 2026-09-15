import Foundation
import Testing
import NetworkPackage

struct LiveCatalogTests {
    @Test(.enabled(if: ProcessInfo.processInfo.environment["LIVE_CATALOG_API_KEY"] != nil))
    func readsCategoriesAndProductsFromCourseBackend() async throws {
        let key = try #require(ProcessInfo.processInfo.environment["LIVE_CATALOG_API_KEY"])
        let api = OpenAPICatalogAPI(configuration: try APIConfiguration(apiKey: key))
        let categories = try await api.loadCategories()
        let page = try await api.loadProducts(page: 1, pageSize: 5)
        #expect(page.currentPage == 1)
        #expect(page.products.count <= 5)
        if let category = categories.first {
            let filtered = try await api.loadProducts(categoryID: category.id, page: 1, pageSize: 5)
            #expect(filtered.currentPage == 1)
        }
    }
}

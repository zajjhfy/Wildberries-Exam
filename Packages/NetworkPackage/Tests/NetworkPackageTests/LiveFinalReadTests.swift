import Foundation
import Testing
import NetworkPackage

struct LiveFinalReadTests {
    @Test(.enabled(if: ProcessInfo.processInfo.environment["LIVE_CATALOG_API_KEY"] != nil))
    func readsExamResourcesWithoutChangingServerState() async throws {
        let key = try #require(ProcessInfo.processInfo.environment["LIVE_CATALOG_API_KEY"])
        let configuration = try APIConfiguration(apiKey: key)
        let cart = try await OpenAPICartAPI(configuration: configuration).loadCart()
        #expect(cart.totalItems >= 0)
        _ = try await OpenAPIAddressAPI(configuration: configuration).loadAddresses()
        _ = try await OpenAPIOrderAPI(configuration: configuration).loadOrders()
        _ = try await OpenAPIProfileAPI(configuration: configuration).loadProfile()
        let products = try await OpenAPICatalogAPI(configuration: configuration).loadProducts(page: 1, pageSize: 1)
        if let productID = products.products.first?.id {
            let detail = try await OpenAPIProductAPI(configuration: configuration).loadProduct(id: productID)
            #expect(detail.id == productID)
        }
    }
}

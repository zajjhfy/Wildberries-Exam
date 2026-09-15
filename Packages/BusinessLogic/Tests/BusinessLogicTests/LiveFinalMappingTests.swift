import Foundation
import NetworkPackage
import Testing
import BusinessLogic

struct LiveFinalMappingTests {
    @Test(.enabled(if: ProcessInfo.processInfo.environment["LIVE_CATALOG_API_KEY"] != nil))
    func mapsExistingServerDataWithoutWritingToBackend() async throws {
        let key = try #require(ProcessInfo.processInfo.environment["LIVE_CATALOG_API_KEY"])
        let configuration = try APIConfiguration(apiKey: key)
        let cart = try await DefaultCartService(api: OpenAPICartAPI(configuration: configuration)).loadCart()
        #expect(cart.totalItems >= 0)
        _ = try await DefaultAddressService(api: OpenAPIAddressAPI(configuration: configuration)).loadAddresses()
        _ = try await DefaultOrderService(api: OpenAPIOrderAPI(configuration: configuration)).loadOrders()
        _ = try await DefaultProfileService(api: OpenAPIProfileAPI(configuration: configuration)).loadProfile()
        let catalog = DefaultCatalogService(api: OpenAPICatalogAPI(configuration: configuration))
        let firstPage = try await catalog.loadProducts(categoryID: nil, page: 1, pageSize: 1)
        if let productID = firstPage.products.first?.id {
            let detail = try await DefaultProductService(api: OpenAPIProductAPI(configuration: configuration))
                .loadProduct(id: productID)
            #expect(detail.product.id == productID)
        }
    }
}

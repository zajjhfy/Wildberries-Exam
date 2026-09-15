import BusinessLogic
import CryptoKit
import Foundation
import NetworkPackage

/// Create once at the app composition root and inject into screen ViewModels.
struct AppDependencies {
    let catalogService: any CatalogService
    let cartStore: CartStore
    let favoriteService: any FavoriteService
    let productService: any ProductService
    let addressService: any AddressService
    let orderService: any OrderService
    let profileService: any ProfileService
    let discoveryService: CatalogDiscoveryService
    private let cartScope: String

    init() throws {
        let key = try Secrets.apiKey
        let configuration = try APIConfiguration(apiKey: key)
        let catalog = DefaultCatalogService(api: OpenAPICatalogAPI(configuration: configuration))
        catalogService = catalog
        cartStore = CartStore(service: DefaultCartService(api: OpenAPICartAPI(configuration: configuration)))
        favoriteService = DefaultFavoriteService(catalog: catalog, api: OpenAPIFavoriteAPI(configuration: configuration))
        productService = DefaultProductService(api: OpenAPIProductAPI(configuration: configuration))
        addressService = DefaultAddressService(api: OpenAPIAddressAPI(configuration: configuration))
        orderService = DefaultOrderService(api: OpenAPIOrderAPI(configuration: configuration))
        profileService = DefaultProfileService(api: OpenAPIProfileAPI(configuration: configuration))
        discoveryService = CatalogDiscoveryService(catalog: catalog, orders: orderService)
        cartScope = SHA256.hash(data: Data(key.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    @MainActor func makeCartViewModel() throws -> CartViewModel {
        CartViewModel(store: cartStore, persistence: try SwiftDataCartPersistence(scope: cartScope))
    }

    @MainActor func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(service: favoriteService)
    }

    @MainActor func makeOrdersViewModel() -> OrdersViewModel { OrdersViewModel(service: orderService) }
    @MainActor func makeAddressesViewModel() -> AddressesViewModel { AddressesViewModel(service: addressService) }
    @MainActor func makeProfileViewModel() -> ProfileViewModel { ProfileViewModel(service: profileService) }
    @MainActor func makeProductViewModel(id: String) -> ProductViewModel {
        ProductViewModel(productID: id, service: productService)
    }
    @MainActor func makeDiscoveryViewModel() -> CatalogDiscoveryViewModel {
        CatalogDiscoveryViewModel(service: discoveryService)
    }
    @MainActor func makeCheckoutViewModel(cart: CartViewModel, addresses: AddressesViewModel,
                                          orders: OrdersViewModel) -> CheckoutViewModel {
        CheckoutViewModel(cartStore: cartStore, cartViewModel: cart, addresses: addresses,
                          orders: orders, orderService: orderService)
    }
}

import BusinessLogic
import NetworkPackage

/// Create once at the app composition root and inject into screen ViewModels.
struct AppDependencies {
    let catalogService: any CatalogService

    init() throws {
        let configuration = try APIConfiguration(apiKey: Secrets.apiKey)
        catalogService = DefaultCatalogService(api: OpenAPICatalogAPI(configuration: configuration))
    }
}

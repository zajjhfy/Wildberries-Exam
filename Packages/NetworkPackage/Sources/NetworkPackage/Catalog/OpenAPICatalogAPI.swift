import OpenAPIRuntime
import OpenAPIURLSession

public struct OpenAPICatalogAPI: CatalogAPI {
    private let client: Client

    public init(configuration: APIConfiguration) {
        client = APIClientFactory.makeClient(configuration: configuration)
    }

    init(configuration: APIConfiguration, transport: any ClientTransport) {
        client = APIClientFactory.makeClient(configuration: configuration, transport: transport)
    }

    public func loadCategories() async throws -> [CategoryDTO] {
        do {
            try Task.checkCancellation()
            let response = try await client.get_sol_categories()
            try Task.checkCancellation()
            switch response {
            case .ok(let success):
                return try success.body.json
            case .unauthorized:
                throw NetworkError.unauthorized
            case .default(let statusCode, _):
                throw NetworkError.httpError(statusCode: statusCode)
            }
        } catch {
            throw NetworkError.normalized(error)
        }
    }

    public func loadProducts(
        categoryID: String? = nil,
        page: Int = 1,
        pageSize: Int = 20
    ) async throws -> ProductsPageDTO {
        guard page > 0, pageSize > 0 else { throw NetworkError.invalidRequest }
        do {
            try Task.checkCancellation()
            let response = try await client.get_sol_products(
                query: .init(category: categoryID, page: page, pageSize: pageSize)
            )
            try Task.checkCancellation()
            switch response {
            case .ok(let success):
                let payload = try success.body.json
                guard payload.currentPage == page,
                      payload.totalPages >= 0,
                      payload.currentPage <= max(payload.totalPages, 1) else {
                    throw NetworkError.invalidResponse
                }
                return ProductsPageDTO(
                    products: payload.data,
                    currentPage: payload.currentPage,
                    totalPages: payload.totalPages
                )
            case .badRequest:
                throw NetworkError.invalidRequest
            case .unauthorized:
                throw NetworkError.unauthorized
            case .default(let statusCode, _):
                throw NetworkError.httpError(statusCode: statusCode)
            }
        } catch {
            throw NetworkError.normalized(error)
        }
    }
}

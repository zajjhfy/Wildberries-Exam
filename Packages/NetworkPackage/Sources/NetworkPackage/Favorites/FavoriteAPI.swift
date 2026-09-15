import Foundation
import OpenAPIRuntime

public protocol FavoriteAPI: Sendable {
    func setFavorite(_ isFavorite: Bool, productID: String) async throws
}

public struct OpenAPIFavoriteAPI: FavoriteAPI {
    private let client: Client

    public init(configuration: APIConfiguration) {
        client = APIClientFactory.makeClient(configuration: configuration)
    }

    init(configuration: APIConfiguration, transport: any ClientTransport) {
        client = APIClientFactory.makeClient(configuration: configuration, transport: transport)
    }

    public func setFavorite(_ isFavorite: Bool, productID: String) async throws {
        guard !productID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw NetworkError.invalidRequest }
        do {
            try Task.checkCancellation()
            if isFavorite {
                let output = try await client.post_sol_products_sol__lcub_id_rcub__sol_favourite(path: .init(id: productID))
                switch output {
                case .ok: return
                case .unauthorized: throw NetworkError.unauthorized
                case .notFound: throw NetworkError.notFound
                case .default(let status, _): throw NetworkError.httpError(statusCode: status)
                }
            } else {
                let output = try await client.delete_sol_products_sol__lcub_id_rcub__sol_favourite(path: .init(id: productID))
                switch output {
                case .ok: return
                case .unauthorized: throw NetworkError.unauthorized
                case .notFound: throw NetworkError.notFound
                case .default(let status, _): throw NetworkError.httpError(statusCode: status)
                }
            }
        } catch { throw NetworkError.normalized(error) }
    }
}

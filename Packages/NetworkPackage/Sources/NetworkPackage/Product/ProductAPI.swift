import Foundation
import OpenAPIRuntime

public typealias ProductDetailsDTO = Components.Schemas.Product

public protocol ProductAPI: Sendable {
    func loadProduct(id: String) async throws -> ProductDetailsDTO
    func submitReview(productID: String, rating: Int, content: String, images: [String]) async throws
}

public struct OpenAPIProductAPI: ProductAPI {
    private let client: Client

    public init(configuration: APIConfiguration) {
        client = APIClientFactory.makeClient(configuration: configuration)
    }

    init(configuration: APIConfiguration, transport: any ClientTransport) {
        client = APIClientFactory.makeClient(configuration: configuration, transport: transport)
    }

    public func loadProduct(id: String) async throws -> ProductDetailsDTO {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw NetworkError.invalidRequest }
        do {
            try Task.checkCancellation()
            let output = try await client.get_sol_products_sol__lcub_id_rcub_(path: .init(id: id))
            try Task.checkCancellation()
            switch output {
            case .ok(let response): return try response.body.json
            case .unauthorized: throw NetworkError.unauthorized
            case .notFound: throw NetworkError.notFound
            case .default(let status, _): throw NetworkError.httpError(statusCode: status)
            }
        } catch { throw NetworkError.normalized(error) }
    }

    public func submitReview(productID: String, rating: Int, content: String, images: [String]) async throws {
        guard !productID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              (1...5).contains(rating), !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NetworkError.invalidRequest
        }
        do {
            try Task.checkCancellation()
            let output = try await client.post_sol_products_sol__lcub_id_rcub__sol_reviews(
                path: .init(id: productID),
                body: .json(.init(rating: rating, content: content.trimmingCharacters(in: .whitespacesAndNewlines), images: images))
            )
            switch output {
            case .ok: return
            case .badRequest: throw NetworkError.invalidRequest
            case .unauthorized: throw NetworkError.unauthorized
            case .default(let status, _): throw NetworkError.httpError(statusCode: status)
            }
        } catch { throw NetworkError.normalized(error) }
    }
}

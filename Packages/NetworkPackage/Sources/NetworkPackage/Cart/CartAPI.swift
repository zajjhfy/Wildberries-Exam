import OpenAPIRuntime

public typealias CartDTO = Operations.get_sol_cart.Output.Ok.Body.jsonPayload

public protocol CartAPI: Sendable {
    func loadCart() async throws -> CartDTO
    func addProduct(id: String) async throws
    func removeProduct(id: String) async throws
}

public struct OpenAPICartAPI: CartAPI {
    private let client: Client

    public init(configuration: APIConfiguration) {
        client = APIClientFactory.makeClient(configuration: configuration)
    }

    init(configuration: APIConfiguration, transport: any ClientTransport) {
        client = APIClientFactory.makeClient(configuration: configuration, transport: transport)
    }

    public func loadCart() async throws -> CartDTO {
        do {
            try Task.checkCancellation()
            let output = try await client.get_sol_cart()
            try Task.checkCancellation()
            switch output {
            case .ok(let response): return try response.body.json
            case .unauthorized: throw NetworkError.unauthorized
            case .default(let status, _): throw NetworkError.httpError(statusCode: status)
            }
        } catch { throw NetworkError.normalized(error) }
    }

    public func addProduct(id: String) async throws {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw NetworkError.invalidRequest }
        do {
            try Task.checkCancellation()
            let output = try await client.post_sol_cart_sol_items(query: .init(id: id))
            switch output {
            case .ok: return
            case .unauthorized: throw NetworkError.unauthorized
            case .notFound: throw NetworkError.notFound
            case .default(let status, _): throw NetworkError.httpError(statusCode: status)
            }
        } catch { throw NetworkError.normalized(error) }
    }

    public func removeProduct(id: String) async throws {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw NetworkError.invalidRequest }
        do {
            try Task.checkCancellation()
            let output = try await client.delete_sol_cart_sol_items_sol__lcub_id_rcub_(path: .init(id: id))
            switch output {
            case .ok: return
            case .unauthorized: throw NetworkError.unauthorized
            case .notFound: throw NetworkError.notFound
            case .default(let status, _): throw NetworkError.httpError(statusCode: status)
            }
        } catch { throw NetworkError.normalized(error) }
    }
}

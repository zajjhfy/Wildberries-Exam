import Foundation
import OpenAPIRuntime

public typealias OrderDTO = Components.Schemas.Order

public protocol OrderAPI: Sendable {
    func loadOrders() async throws -> [OrderDTO]
    func createOrder(addressID: String, paymentMethod: String) async throws
}

public struct OpenAPIOrderAPI: OrderAPI {
    private let client: Client

    public init(configuration: APIConfiguration) {
        client = APIClientFactory.makeClient(configuration: configuration)
    }

    init(configuration: APIConfiguration, transport: any ClientTransport) {
        client = APIClientFactory.makeClient(configuration: configuration, transport: transport)
    }

    public func loadOrders() async throws -> [OrderDTO] {
        do {
            try Task.checkCancellation()
            let output = try await client.get_sol_orders()
            try Task.checkCancellation()
            switch output {
            case .ok(let response): return try response.body.json
            case .unauthorized: throw NetworkError.unauthorized
            case .default(let status, _): throw NetworkError.httpError(statusCode: status)
            }
        } catch { throw NetworkError.normalized(error) }
    }

    public func createOrder(addressID: String, paymentMethod: String) async throws {
        guard !addressID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !paymentMethod.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NetworkError.invalidRequest
        }
        do {
            try Task.checkCancellation()
            let output = try await client.post_sol_orders(body: .json(.init(
                paymentMethod: paymentMethod, addressID: addressID
            )))
            switch output {
            case .ok: return
            case .badRequest: throw NetworkError.invalidRequest
            case .unauthorized: throw NetworkError.unauthorized
            case .default(let status, _): throw NetworkError.httpError(statusCode: status)
            }
        } catch { throw NetworkError.normalized(error) }
    }
}

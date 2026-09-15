import Foundation
import OpenAPIRuntime

public typealias AddressDTO = Components.Schemas.Address
public typealias SavedAddressDTO = Operations.get_sol_addresses.Output.Ok.Body.jsonPayloadPayload

public protocol AddressAPI: Sendable {
    func loadAddresses() async throws -> [SavedAddressDTO]
    func createAddress(_ draft: AddressDTO) async throws
    func updateAddress(id: String, draft: AddressDTO) async throws
    func deleteAddress(id: String) async throws
}

public struct OpenAPIAddressAPI: AddressAPI {
    private let client: Client

    public init(configuration: APIConfiguration) {
        client = APIClientFactory.makeClient(configuration: configuration)
    }

    init(configuration: APIConfiguration, transport: any ClientTransport) {
        client = APIClientFactory.makeClient(configuration: configuration, transport: transport)
    }

    public func loadAddresses() async throws -> [SavedAddressDTO] {
        do {
            try Task.checkCancellation()
            let output = try await client.get_sol_addresses()
            try Task.checkCancellation()
            switch output {
            case .ok(let response): return try response.body.json
            case .unauthorized: throw NetworkError.unauthorized
            case .default(let status, _): throw NetworkError.httpError(statusCode: status)
            }
        } catch { throw NetworkError.normalized(error) }
    }

    public func createAddress(_ draft: AddressDTO) async throws {
        do {
            try Task.checkCancellation()
            let output = try await client.post_sol_addresses(body: .json(draft))
            switch output {
            case .ok: return
            case .badRequest: throw NetworkError.invalidRequest
            case .unauthorized: throw NetworkError.unauthorized
            case .default(let status, _): throw NetworkError.httpError(statusCode: status)
            }
        } catch { throw NetworkError.normalized(error) }
    }

    public func updateAddress(id: String, draft: AddressDTO) async throws {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw NetworkError.invalidRequest }
        do {
            try Task.checkCancellation()
            let output = try await client.put_sol_addresses_sol__lcub_id_rcub_(path: .init(id: id), body: .json(draft))
            switch output {
            case .ok: return
            case .badRequest: throw NetworkError.invalidRequest
            case .unauthorized: throw NetworkError.unauthorized
            case .notFound: throw NetworkError.notFound
            case .default(let status, _): throw NetworkError.httpError(statusCode: status)
            }
        } catch { throw NetworkError.normalized(error) }
    }

    public func deleteAddress(id: String) async throws {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw NetworkError.invalidRequest }
        do {
            try Task.checkCancellation()
            let output = try await client.delete_sol_addresses_sol__lcub_id_rcub_(path: .init(id: id))
            switch output {
            case .ok: return
            case .unauthorized: throw NetworkError.unauthorized
            case .notFound: throw NetworkError.notFound
            case .default(let status, _): throw NetworkError.httpError(statusCode: status)
            }
        } catch { throw NetworkError.normalized(error) }
    }
}

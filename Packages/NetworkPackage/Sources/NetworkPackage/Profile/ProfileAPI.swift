import Foundation
import OpenAPIRuntime

public typealias UserProfileDTO = Components.Schemas.UserProfile

public protocol ProfileAPI: Sendable {
    func loadProfile() async throws -> UserProfileDTO
    func updateProfile(name: String, birthday: String, imageURI: String) async throws
}

public struct OpenAPIProfileAPI: ProfileAPI {
    private let client: Client

    public init(configuration: APIConfiguration) {
        client = APIClientFactory.makeClient(configuration: configuration)
    }

    init(configuration: APIConfiguration, transport: any ClientTransport) {
        client = APIClientFactory.makeClient(configuration: configuration, transport: transport)
    }

    public func loadProfile() async throws -> UserProfileDTO {
        do {
            try Task.checkCancellation()
            let output = try await client.get_sol_users_sol_me()
            try Task.checkCancellation()
            switch output {
            case .ok(let response): return try response.body.json
            case .unauthorized: throw NetworkError.unauthorized
            case .default(let status, _): throw NetworkError.httpError(statusCode: status)
            }
        } catch { throw NetworkError.normalized(error) }
    }

    public func updateProfile(name: String, birthday: String, imageURI: String) async throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !birthday.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !imageURI.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NetworkError.invalidRequest
        }
        do {
            try Task.checkCancellation()
            let output = try await client.put_sol_users_sol_me(body: .json(.init(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                birthday: birthday.trimmingCharacters(in: .whitespacesAndNewlines), imageUri: imageURI
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

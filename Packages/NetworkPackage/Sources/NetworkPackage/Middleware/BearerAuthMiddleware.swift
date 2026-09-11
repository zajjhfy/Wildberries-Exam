import Foundation
import HTTPTypes
import OpenAPIRuntime

struct BearerAuthMiddleware: ClientMiddleware {
    let apiKey: String

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable @concurrent (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var authorizedRequest = request
        authorizedRequest.headerFields[.authorization] = "Bearer \(apiKey)"
        return try await next(authorizedRequest, body, baseURL)
    }
}

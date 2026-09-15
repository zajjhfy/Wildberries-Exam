import Foundation
import HTTPTypes
import OpenAPIRuntime

struct HTTPStatusMiddleware: ClientMiddleware {
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable @concurrent (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let (response, responseBody) = try await next(request, body, baseURL)
        guard (200..<300).contains(response.status.code) else {
            // Error pages can be HTML or empty; the HTTP status must survive decoding failures.
            throw NetworkError.httpError(statusCode: response.status.code)
        }
        return (response, responseBody)
    }
}

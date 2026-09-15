import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing
@testable import NetworkPackage

struct CatalogAPITests {
    @Test(arguments: ["", " \n ", "$(API_KEY)", "YOUR_API_KEY", "key\nheader"])
    func rejectsMissingOrUnsafeAPIKey(_ key: String) {
        #expect(throws: NetworkError.missingAPIKey) {
            _ = try APIConfiguration(apiKey: key)
        }
    }

    @Test(arguments: ["http://example.com", "https://user:password@example.com", "https://example.com?key=value"])
    func rejectsInvalidServerURL(_ address: String) throws {
        let url = try #require(URL(string: address))
        #expect(throws: NetworkError.invalidServerURL) {
            _ = try APIConfiguration(apiKey: "test-key", baseURL: url)
        }
    }

    @Test func loadsCategoriesWithAuthorization() async throws {
        let transport = StubTransport(body: #"[{"id":"bakery","name":"Выпечка","image":"https://example.com/category.png"}]"#)
        let api = try makeAPI(transport: transport, key: "  test-key  ")
        let categories = try await api.loadCategories()
        #expect(categories.map(\.id) == ["bakery"])
        let request = try #require(await transport.requests.first)
        #expect(request.method == .get)
        #expect(request.path == "/categories")
        #expect(request.headerFields[.authorization] == "Bearer test-key")
    }

    @Test func sendsCategoryAndPaginationParameters() async throws {
        let transport = StubTransport(body: Self.productsJSON)
        let page = try await makeAPI(transport: transport).loadProducts(
            categoryID: "food & drinks", page: 2, pageSize: 5
        )
        let request = try #require(await transport.requests.first)
        let path = try #require(request.path)
        let components = try #require(URLComponents(string: "https://example.com" + path))
        let query = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value) })
        #expect(components.path == "/products")
        #expect(query["category"] == "food & drinks")
        #expect(query["page"] == "2")
        #expect(query["pageSize"] == "5")
        #expect(page.currentPage == 2)
        #expect(page.totalPages == 3)
        #expect(page.products.first?.isFavorite == true)
        #expect(page.products.first?.price == 150)
    }

    @Test func acceptsEmptyCatalog() async throws {
        let transport = StubTransport(body: #"{"currentPage":1,"totalPages":0,"data":[]}"#)
        let page = try await makeAPI(transport: transport).loadProducts()
        #expect(page.products.isEmpty)
        #expect(page.totalPages == 0)
    }

    @Test func rejectsPageMismatch() async throws {
        let transport = StubTransport(body: Self.productsJSON)
        let api = try makeAPI(transport: transport)
        await #expect(throws: NetworkError.invalidResponse) {
            _ = try await api.loadProducts(page: 1)
        }
    }

    @Test func rejectsInvalidRequestBeforeTransport() async throws {
        let transport = StubTransport(body: "[]")
        let api = try makeAPI(transport: transport)
        await #expect(throws: NetworkError.invalidRequest) {
            _ = try await api.loadProducts(page: 0)
        }
        await #expect(throws: NetworkError.invalidRequest) {
            _ = try await api.loadProducts(pageSize: 0)
        }
        #expect(await transport.requests.isEmpty)
    }

    @Test(arguments: [400, 401, 403, 404, 429, 500])
    func preservesHTTPErrorEvenWithHTMLBody(_ status: Int) async throws {
        let transport = StubTransport(status: status, contentType: "text/html", body: "<html>Error</html>")
        let api = try makeAPI(transport: transport)
        await #expect(throws: NetworkError.httpError(statusCode: status)) {
            _ = try await api.loadCategories()
        }
    }

    @Test func reportsMalformedJSON() async throws {
        let api = try makeAPI(transport: StubTransport(body: "not json"))
        await #expect(throws: NetworkError.invalidResponse) {
            _ = try await api.loadCategories()
        }
    }

    @Test func reportsMissingRequiredFields() async throws {
        let api = try makeAPI(transport: StubTransport(body: #"[{"id":"bakery"}]"#))
        await #expect(throws: NetworkError.invalidResponse) {
            _ = try await api.loadCategories()
        }
    }

    @Test func preservesTransportError() async throws {
        let api = try makeAPI(transport: StubTransport(error: URLError(.notConnectedToInternet)))
        await #expect(throws: NetworkError.transport(.notConnectedToInternet)) {
            _ = try await api.loadCategories()
        }
    }

    @Test func preservesCancellationWrappedByOpenAPI() async throws {
        let api = try makeAPI(transport: StubTransport(error: URLError(.cancelled)))
        await #expect(throws: CancellationError.self) {
            _ = try await api.loadCategories()
        }
    }

    @Test func cancelledTaskDoesNotStartRequest() async throws {
        let transport = StubTransport(body: "[]")
        let api = try makeAPI(transport: transport)
        let task = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return try await api.loadCategories()
        }
        await #expect(throws: CancellationError.self) { _ = try await task.value }
        #expect(await transport.requests.isEmpty)
    }

    private func makeAPI(transport: StubTransport, key: String = "test-key") throws -> OpenAPICatalogAPI {
        let url = try #require(URL(string: "https://example.com"))
        return OpenAPICatalogAPI(configuration: try APIConfiguration(apiKey: key, baseURL: url), transport: transport)
    }

    private static let productsJSON = #"{"currentPage":2,"totalPages":3,"data":[{"id":"croissant","name":"Круассан","image":"https://example.com/product.png","weight":80.5,"price":150,"rating":4.5,"reviewCount":12,"isFavorite":true,"discount":10}]}"#
}

private actor StubTransport: ClientTransport {
    private(set) var requests: [HTTPRequest] = []
    private let status: Int
    private let contentType: String
    private let body: String
    private let error: (any Error)?

    init(status: Int = 200, contentType: String = "application/json", body: String = "", error: (any Error)? = nil) {
        self.status = status
        self.contentType = contentType
        self.body = body
        self.error = error
    }

    func send(
        _ request: HTTPRequest, body: HTTPBody?, baseURL: URL, operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        requests.append(request)
        if let error { throw error }
        return (HTTPResponse(status: .init(code: status), headerFields: [.contentType: contentType]), HTTPBody(self.body))
    }
}

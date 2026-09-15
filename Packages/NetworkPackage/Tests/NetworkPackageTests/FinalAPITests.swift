import Foundation
import HTTPTypes
import OpenAPIRuntime
import Testing
@testable import NetworkPackage

struct FinalAPITests {
    @Test func cartRoutesMutationsAndKeepsAuthorization() async throws {
        let transport = FinalTransport()
        let configuration = try fixtureConfiguration()
        let api = OpenAPICartAPI(configuration: configuration, transport: transport)
        let cart = try await api.loadCart()
        #expect(cart.totalItems == 0)
        try await api.addProduct(id: "food & drinks")
        try await api.removeProduct(id: "food & drinks")
        let requests = await transport.requests
        #expect(requests.map(\.method) == [.get, .post, .delete])
        #expect(requests.first?.path == "/cart")
        #expect(requests[1].path?.contains("id=food%20%26%20drinks") == true)
        #expect(requests[2].path?.hasPrefix("/cart/items/food") == true)
        #expect(requests.allSatisfy { $0.headerFields[.authorization] == "Bearer test-key" })
    }

    @Test func routesFavoritesOrdersAddressesAndProfile() async throws {
        let transport = FinalTransport()
        let configuration = try fixtureConfiguration()
        let favorites = OpenAPIFavoriteAPI(configuration: configuration, transport: transport)
        let orders = OpenAPIOrderAPI(configuration: configuration, transport: transport)
        let addresses = OpenAPIAddressAPI(configuration: configuration, transport: transport)
        let profile = OpenAPIProfileAPI(configuration: configuration, transport: transport)
        try await favorites.setFavorite(true, productID: "coffee")
        try await favorites.setFavorite(false, productID: "coffee")
        #expect(try await orders.loadOrders().isEmpty)
        try await orders.createOrder(addressID: "address", paymentMethod: "card")
        #expect(try await addresses.loadAddresses().isEmpty)
        try await addresses.createAddress(.init(coordinates: [37.6, 55.7], addressLine: "Москва"))
        let user = try await profile.loadProfile()
        #expect(user.phone == "+70000000000")
        try await profile.updateProfile(name: "Тест", birthday: "01.01.1990",
                                        imageURI: "https://example.com/user.jxl")
        let requests = await transport.requests
        #expect(requests.map(\.path) == [
            "/products/coffee/favourite", "/products/coffee/favourite",
            "/orders", "/orders", "/addresses", "/addresses",
            "/users/me", "/users/me"
        ])
        #expect(requests.map(\.method) == [.post, .delete, .get, .post,
                                          .get, .post, .get, .put])
    }

    @Test func productDetailsRouteAndMissingProductAreHandled() async throws {
        let transport = FinalTransport()
        let api = OpenAPIProductAPI(configuration: try fixtureConfiguration(), transport: transport)
        let product = try await api.loadProduct(id: "coffee")
        #expect(product.id == "coffee")
        try await api.submitReview(productID: "coffee", rating: 5, content: "Хорошо", images: [])
        #expect(await transport.requests.map(\.path) == ["/products/coffee", "/products/coffee/reviews"])
        await #expect(throws: NetworkError.invalidRequest) {
            try await api.submitReview(productID: "coffee", rating: 0, content: "", images: [])
        }
        #expect(await transport.requests.count == 2)
    }

    private func fixtureConfiguration() throws -> APIConfiguration {
        let url = try #require(URL(string: "https://example.com"))
        return try APIConfiguration(apiKey: "test-key", baseURL: url)
    }
}

private actor FinalTransport: ClientTransport {
    private(set) var requests: [HTTPRequest] = []

    func send(_ request: HTTPRequest, body: HTTPBody?, baseURL: URL,
              operationID: String) async throws -> (HTTPResponse, HTTPBody?) {
        requests.append(request)
        let payload: String
        switch (request.method, request.path) {
        case (.get, "/cart"):
            payload = #"{"deliveryTime":0,"orderPrice":0,"deliveryPrice":0,"totalPrice":0,"totalItems":0,"items":[]}"#
        case (.post, let path) where path?.hasPrefix("/cart/items?") == true,
             (.delete, let path) where path?.hasPrefix("/cart/items/") == true:
            payload = #"{"total":1}"#
        case (.get, "/orders"), (.get, "/addresses"):
            payload = "[]"
        case (.get, "/users/me"):
            payload = #"{"name":"Тест","phone":"+70000000000","birthday":"01.01.1990"}"#
        case (.get, "/products/coffee"):
            payload = #"{"id":"coffee","name":"Кофе","image":"https://example.com/a.jxl","price":50,"weight":200,"rating":5,"description":"Кофе","isFavorite":false}"#
        default:
            payload = "{}"
        }
        return (HTTPResponse(status: .ok, headerFields: [.contentType: "application/json"]), HTTPBody(payload))
    }
}

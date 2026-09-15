import Foundation
import NetworkPackage
import Testing
@testable import BusinessLogic

struct FinalDomainTests {
    @Test func discoveryUsesPagedCatalogForSearchDiscountsAndOrderHistory() async throws {
        let catalog = DiscoveryCatalogFixture()
        let service = CatalogDiscoveryService(catalog: catalog, orders: DiscoveryOrdersFixture(), pageSize: 1)
        #expect(try await service.search("коф").map(\.id) == ["coffee"])
        #expect(try await service.discountedProducts().map(\.id) == ["coffee"])
        #expect(try await service.previouslyOrderedProducts().map(\.id) == ["croissant"])
        #expect(await catalog.requestedPages == [1, 2])
    }

    @Test func addressCoordinatesRejectMalformedServerData() throws {
        #expect(AddressCoordinates([37.6, 55.7]) != nil)
        #expect(AddressCoordinates([37.6]) == nil)
        #expect(AddressCoordinates([37.6, 55.7, 1]) == nil)
        #expect(AddressCoordinates([181, 55.7]) == nil)
        #expect(AddressCoordinates([37.6, .nan]) == nil)
        let invalid = AddressDTO(coordinates: [181, 55.7], addressLine: "Москва")
        #expect(throws: NetworkError.invalidResponse) { try AddressDetails.map(invalid) }
    }

    @Test(arguments: [
        ProfileDraft(name: "", birthday: "01.01.1990", imageURI: "https://example.com/a.jxl"),
        ProfileDraft(name: "Тест", birthday: "31.02.1990", imageURI: "https://example.com/a.jxl"),
        ProfileDraft(name: "Тест", birthday: "01.01.1990", imageURI: "file:///a.jxl"),
        ProfileDraft(name: "Тест", birthday: "01.01.1990", imageURI: "https://example.com/a.png")
    ])
    func profileRejectsInvalidRequiredFields(_ draft: ProfileDraft) {
        #expect(draft.isValid == false)
    }

    @Test func profileAcceptsServerDateAndImageFormat() {
        #expect(ProfileDraft(name: "Тест", birthday: "01.01.1990",
                             imageURI: "https://example.com/a.jxl").isValid)
    }
}

private actor DiscoveryCatalogFixture: CatalogService {
    private(set) var requestedPages: [Int] = []

    func loadCategories() -> [CatalogCategory] { [] }

    func loadProducts(categoryID: String?, page: Int, pageSize: Int) -> CatalogPage {
        requestedPages.append(page)
        let product = page == 1
            ? CatalogProduct(id: "croissant", name: "Круассан", price: 100, weight: 80,
                             rating: 4, reviewCount: 1, isFavorite: false)
            : CatalogProduct(id: "coffee", name: "Кофе", price: 50, weight: 200,
                             rating: 5, reviewCount: 2, isFavorite: true, discount: 15)
        return CatalogPage(products: [product], currentPage: page, totalPages: 2)
    }
}

private struct DiscoveryOrdersFixture: OrderService {
    func loadOrders() -> [CustomerOrder] {
        guard let coordinates = AddressCoordinates(longitude: 37.6, latitude: 55.7) else {
            return []
        }
        let address = AddressDetails(addressLine: "Москва", coordinates: coordinates)
        let product = OrderProduct(id: "croissant", name: "Круассан", imageURL: nil,
                                   price: 100, weight: 80, quantity: 1)
        return [CustomerOrder(id: "order", status: .completed, deliveryDateText: nil,
                              address: address, orderPrice: 100, deliveryPrice: 0,
                              totalPrice: 100, totalItems: 1, items: [product])]
    }

    func createOrder(addressID: String, paymentMethod: String) {}
}

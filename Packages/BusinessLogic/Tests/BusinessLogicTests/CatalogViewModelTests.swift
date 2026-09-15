import Foundation
import NetworkPackage
import Testing
@testable import BusinessLogic

@MainActor
struct CatalogViewModelTests {
    @Test func initialLoadFetchesBothResourcesAndDoesNotReloadOnReturn() async {
        let service = ControlledCatalogService()
        let viewModel = CatalogViewModel(service: service)
        let loading = Task { await viewModel.load() }
        let request = await service.nextRequest()
        #expect(viewModel.state == .loading)
        await viewModel.load()
        await service.complete(request, products: [product("first")], totalPages: 2)
        await loading.value
        await viewModel.load()
        #expect(viewModel.state == .loaded)
        #expect(viewModel.categories.map(\.id) == ["category"])
        #expect(viewModel.products.map(\.id) == ["first"])
        #expect(viewModel.hasNextPage)
        #expect(await service.requestCount == 1)
    }

    @Test func emptyCatalogIsSuccessfulState() async {
        let service = ControlledCatalogService()
        let viewModel = CatalogViewModel(service: service)
        let loading = Task { await viewModel.load() }
        let request = await service.nextRequest()
        await service.complete(request, products: [], totalPages: 0)
        await loading.value
        #expect(viewModel.isEmpty)
        #expect(!viewModel.hasNextPage)
    }

    @Test func loadingFailureCanBeRetried() async {
        let service = ControlledCatalogService()
        let viewModel = CatalogViewModel(service: service)
        let loading = Task { await viewModel.load() }
        let failedRequest = await service.nextRequest()
        await service.fail(failedRequest, error: NetworkError.unauthorized)
        await loading.value
        #expect(viewModel.state == .failed(NetworkError.unauthorized.localizedDescription))
        let retry = Task { await viewModel.load() }
        let retriedRequest = await service.nextRequest()
        await service.complete(retriedRequest, products: [product("retried")])
        await retry.value
        #expect(viewModel.products.map(\.id) == ["retried"])
        #expect(viewModel.state == .loaded)
    }

    @Test func lateCategoryResponseDoesNotReplaceNewSelection() async {
        let service = ControlledCatalogService()
        let viewModel = CatalogViewModel(service: service)
        let first = Task { await viewModel.selectCategory("first") }
        let firstRequest = await service.nextRequest()
        let second = Task { await viewModel.selectCategory("second") }
        let secondRequest = await service.nextRequest()
        await service.complete(secondRequest, products: [product("new")])
        await second.value
        await service.complete(firstRequest, products: [product("old")])
        await first.value
        #expect(viewModel.selectedCategoryID == "second")
        #expect(viewModel.products.map(\.id) == ["new"])
    }

    @Test func paginationDeduplicatesRequestsAndProducts() async {
        let service = ControlledCatalogService()
        let viewModel = CatalogViewModel(service: service, pageSize: 2)
        let initial = Task { await viewModel.load() }
        let initialRequest = await service.nextRequest()
        await service.complete(initialRequest, products: [product("first")], totalPages: 2)
        await initial.value

        let next = Task { await viewModel.loadNextPage() }
        let nextRequest = await service.nextRequest()
        #expect(nextRequest.page == 2)
        #expect(nextRequest.pageSize == 2)
        await viewModel.loadNextPage()
        #expect(await service.requestCount == 2)
        await service.complete(nextRequest, products: [product("first"), product("second")], totalPages: 2)
        await next.value
        #expect(viewModel.products.map(\.id) == ["first", "second"])
        #expect(!viewModel.hasNextPage)
        #expect(!viewModel.isLoadingNextPage)
        await viewModel.loadNextPage()
        #expect(await service.requestCount == 2)
    }

    @Test func paginationFailurePreservesProductsAndRetriesSamePage() async {
        let service = ControlledCatalogService()
        let viewModel = CatalogViewModel(service: service)
        let initial = Task { await viewModel.load() }
        let initialRequest = await service.nextRequest()
        await service.complete(initialRequest, products: [product("first")], totalPages: 2)
        await initial.value
        let next = Task { await viewModel.loadNextPage() }
        let failedRequest = await service.nextRequest()
        await service.fail(failedRequest, error: NetworkError.transport(.timedOut))
        await next.value
        #expect(viewModel.products.map(\.id) == ["first"])
        #expect(viewModel.nextPageError != nil)
        #expect(viewModel.state == .loaded)
        let retry = Task { await viewModel.loadNextPage() }
        let retriedRequest = await service.nextRequest()
        #expect(retriedRequest.page == failedRequest.page)
        await service.complete(retriedRequest, products: [product("second")], totalPages: 2)
        await retry.value
        #expect(viewModel.nextPageError == nil)
        #expect(viewModel.products.map(\.id) == ["first", "second"])
    }

    @Test func oldNextPageDoesNotLeakIntoNewCategory() async {
        let service = ControlledCatalogService()
        let viewModel = CatalogViewModel(service: service)
        let initial = Task { await viewModel.load() }
        let initialRequest = await service.nextRequest()
        await service.complete(initialRequest, products: [product("first")], totalPages: 2)
        await initial.value
        let next = Task { await viewModel.loadNextPage() }
        let staleRequest = await service.nextRequest()
        let selection = Task { await viewModel.selectCategory("new") }
        let newRequest = await service.nextRequest()
        await service.complete(newRequest, products: [product("new-category")])
        await selection.value
        await service.complete(staleRequest, products: [product("stale")], totalPages: 2)
        await next.value
        #expect(viewModel.products.map(\.id) == ["new-category"])
        #expect(!viewModel.isLoadingNextPage)
    }

    @Test func cancelledLoadDoesNotBecomeAnErrorOrPublishLateData() async {
        let service = ControlledCatalogService()
        let viewModel = CatalogViewModel(service: service)
        let loading = Task { await viewModel.load() }
        let request = await service.nextRequest()
        loading.cancel()
        await service.complete(request, products: [product("cancelled")])
        await loading.value
        #expect(viewModel.state == .idle)
        #expect(viewModel.products.isEmpty)
    }

    private func product(_ id: String) -> CatalogProduct {
        CatalogProduct(id: id, name: id, price: 100, weight: 80, rating: 4.5, reviewCount: 1, isFavorite: false)
    }
}

private actor ControlledCatalogService: CatalogService {
    struct Request: Sendable {
        let id: UUID
        let categoryID: String?
        let page: Int
        let pageSize: Int
    }

    private(set) var requestCount = 0
    private var continuations: [UUID: CheckedContinuation<CatalogPage, any Error>] = [:]
    private var queuedRequests: [Request] = []
    private var observers: [CheckedContinuation<Request, Never>] = []

    func loadCategories() async throws -> [CatalogCategory] {
        [CatalogCategory(id: "category", name: "Категория")]
    }

    func loadProducts(categoryID: String?, page: Int, pageSize: Int) async throws -> CatalogPage {
        let request = Request(id: UUID(), categoryID: categoryID, page: page, pageSize: pageSize)
        requestCount += 1
        return try await withCheckedThrowingContinuation { continuation in
            continuations[request.id] = continuation
            if observers.isEmpty {
                queuedRequests.append(request)
            } else {
                observers.removeFirst().resume(returning: request)
            }
        }
    }

    func nextRequest() async -> Request {
        if !queuedRequests.isEmpty { return queuedRequests.removeFirst() }
        return await withCheckedContinuation { observers.append($0) }
    }

    func complete(_ request: Request, products: [CatalogProduct], totalPages: Int = 1) {
        continuations.removeValue(forKey: request.id)?.resume(returning: CatalogPage(
            products: products, currentPage: request.page, totalPages: totalPages
        ))
    }

    func fail(_ request: Request, error: any Error) {
        continuations.removeValue(forKey: request.id)?.resume(throwing: error)
    }
}

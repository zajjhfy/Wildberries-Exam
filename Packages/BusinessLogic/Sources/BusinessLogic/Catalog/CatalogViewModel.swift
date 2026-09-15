import Foundation
import Observation

@MainActor
@Observable
public final class CatalogViewModel {
    public enum State: Equatable, Sendable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    public private(set) var state: State = .idle
    public private(set) var categories: [CatalogCategory] = []
    public private(set) var products: [CatalogProduct] = []
    public private(set) var selectedCategoryID: String?
    public private(set) var isLoadingNextPage = false
    public private(set) var nextPageError: String?
    public private(set) var hasNextPage = false

    public var isEmpty: Bool { state == .loaded && products.isEmpty }

    @ObservationIgnored private let service: any CatalogService
    @ObservationIgnored private let pageSize: Int
    @ObservationIgnored private var currentPage = 0
    @ObservationIgnored private var requestID = UUID()

    public init(service: any CatalogService, pageSize: Int = 20) {
        self.service = service
        self.pageSize = max(1, pageSize)
    }

    /// Safe to call again when returning to the screen; refresh is explicit.
    public func load() async {
        guard state != .loaded, state != .loading else { return }
        await refresh()
    }

    public func refresh() async {
        let activeRequest = beginLoading()
        let categoryID = selectedCategoryID
        do {
            async let loadedCategories = service.loadCategories()
            async let loadedPage = service.loadProducts(categoryID: categoryID, page: 1, pageSize: pageSize)
            let (categories, page) = try await (loadedCategories, loadedPage)
            try Task.checkCancellation()
            guard requestID == activeRequest else { return }
            self.categories = categories
            apply(page, replacingProducts: true)
        } catch {
            finishLoading(error: error, request: activeRequest)
        }
    }

    public func selectCategory(_ categoryID: String?) async {
        guard selectedCategoryID != categoryID || state != .loaded else { return }
        selectedCategoryID = categoryID
        products = []
        currentPage = 0
        hasNextPage = false
        let activeRequest = beginLoading()
        do {
            let page = try await service.loadProducts(categoryID: categoryID, page: 1, pageSize: pageSize)
            try Task.checkCancellation()
            guard requestID == activeRequest else { return }
            apply(page, replacingProducts: true)
        } catch {
            finishLoading(error: error, request: activeRequest)
        }
    }

    public func loadNextPage() async {
        guard state == .loaded, hasNextPage, !isLoadingNextPage else { return }
        let activeRequest = requestID
        isLoadingNextPage = true
        nextPageError = nil
        defer {
            if requestID == activeRequest { isLoadingNextPage = false }
        }
        do {
            let page = try await service.loadProducts(
                categoryID: selectedCategoryID, page: currentPage + 1, pageSize: pageSize
            )
            try Task.checkCancellation()
            guard requestID == activeRequest else { return }
            apply(page, replacingProducts: false)
        } catch {
            guard requestID == activeRequest else { return }
            if !(error is CancellationError) && !Task.isCancelled {
                nextPageError = error.localizedDescription
            }
        }
    }

    private func beginLoading() -> UUID {
        requestID = UUID()
        state = .loading
        isLoadingNextPage = false
        nextPageError = nil
        return requestID
    }

    private func apply(_ page: CatalogPage, replacingProducts: Bool) {
        var seenIDs = Set<String>()
        let combined = (replacingProducts ? [] : products) + page.products
        products = combined.filter { seenIDs.insert($0.id).inserted }
        currentPage = page.currentPage
        hasNextPage = page.hasNextPage
        state = .loaded
    }

    private func finishLoading(error: any Error, request: UUID) {
        guard requestID == request else { return }
        if error is CancellationError || Task.isCancelled {
            state = .idle
        } else {
            state = .failed(error.localizedDescription)
        }
    }
}

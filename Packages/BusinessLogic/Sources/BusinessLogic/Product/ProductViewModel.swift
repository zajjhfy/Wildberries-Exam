import Foundation
import Observation

@MainActor
@Observable
public final class ProductViewModel {
    public enum State: Equatable { case idle, loading, loaded, failed(String) }

    public private(set) var state: State = .idle
    public private(set) var details: ProductDetails?
    public private(set) var isSubmitting = false
    public private(set) var submissionError: String?
    public private(set) var refreshError: String?
    public var sorting: ReviewSorting = .newest
    public var visibleReviews: [ProductReview] { details?.sortedReviews(sorting) ?? [] }

    @ObservationIgnored private let service: any ProductService
    @ObservationIgnored private let productID: String

    public init(productID: String, service: any ProductService) {
        self.productID = productID
        self.service = service
    }

    public func load() async {
        guard state != .loading, !isSubmitting else { return }
        state = .loading
        do {
            let details = try await service.loadProduct(id: productID)
            try Task.checkCancellation()
            self.details = details
            state = .loaded
        } catch {
            state = error is CancellationError ? .idle : .failed(error.localizedDescription)
        }
    }

    /// Returns true when the review was accepted, even if the follow-up refresh fails.
    @discardableResult
    public func submit(_ draft: ReviewDraft) async -> Bool {
        guard !isSubmitting else { return false }
        isSubmitting = true
        defer { isSubmitting = false }
        submissionError = nil
        refreshError = nil
        do {
            try await service.submitReview(draft, productID: productID)
        } catch {
            if !(error is CancellationError) { submissionError = error.localizedDescription }
            return false
        }
        do {
            details = try await service.loadProduct(id: productID)
            state = .loaded
        } catch {
            if !(error is CancellationError) { refreshError = error.localizedDescription }
        }
        return true
    }
}

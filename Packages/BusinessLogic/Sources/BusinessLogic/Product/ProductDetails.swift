import Foundation

public struct ProductReview: Equatable, Sendable {
    public let rating: Int
    public let author: String
    public let createdAtText: String
    public let createdAt: Date?
    public let content: String
    public let imageURLs: [URL]
}

public struct ProductDetails: Equatable, Sendable {
    public let product: CatalogProduct
    public let description: String
    public let reviews: [ProductReview]

    public func sortedReviews(_ sorting: ReviewSorting) -> [ProductReview] {
        switch sorting {
        case .newest: reviews.sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
        case .highestRating: reviews.sorted { $0.rating > $1.rating }
        }
    }
}

public enum ReviewSorting: Equatable, Sendable { case newest, highestRating }

public struct ReviewDraft: Equatable, Sendable {
    public let rating: Int
    public let content: String
    public let imageURLs: [URL]

    public init(rating: Int, content: String, imageURLs: [URL] = []) {
        self.rating = rating
        self.content = content
        self.imageURLs = imageURLs
    }
}

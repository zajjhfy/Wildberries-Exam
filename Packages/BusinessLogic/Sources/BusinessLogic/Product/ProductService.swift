import Foundation
import NetworkPackage

public protocol ProductService: Sendable {
    func loadProduct(id: String) async throws -> ProductDetails
    func submitReview(_ draft: ReviewDraft, productID: String) async throws
}

public struct DefaultProductService: ProductService {
    private let api: any ProductAPI

    public init(api: any ProductAPI) { self.api = api }

    public func loadProduct(id: String) async throws -> ProductDetails {
        let dto = try await api.loadProduct(id: id)
        let reviews = dto.reviews ?? []
        return ProductDetails(product: CatalogProduct(
            id: dto.id, name: dto.name, imageURL: validatedImageURL(dto.image),
            price: dto.price, weight: dto.weight, rating: Double(dto.rating),
            reviewCount: reviews.count, isFavorite: dto.isFavorite, discount: dto.discount
        ), description: dto.description, reviews: reviews.map { review in
            ProductReview(rating: review.rating, author: review.author,
                          createdAtText: ISO8601DateFormatter().string(from: review.createdAt),
                          createdAt: review.createdAt,
                          content: review.content,
                          imageURLs: review.images.compactMap(validatedImageURL))
        })
    }

    public func submitReview(_ draft: ReviewDraft, productID: String) async throws {
        guard (1...5).contains(draft.rating),
              !draft.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NetworkError.invalidRequest
        }
        try await api.submitReview(productID: productID, rating: draft.rating,
                                   content: draft.content,
                                   images: draft.imageURLs.map(\.absoluteString))
    }
}

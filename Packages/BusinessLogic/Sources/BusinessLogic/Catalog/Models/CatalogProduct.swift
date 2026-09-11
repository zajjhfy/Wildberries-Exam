import Foundation

public struct CatalogProduct: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let imageURL: URL?
    public let price: Int
    public let weight: Double
    public let rating: Double
    public let reviewCount: Int
    public let isFavorite: Bool
    public let discount: Double?

    public init(
        id: String,
        name: String,
        imageURL: URL? = nil,
        price: Int,
        weight: Double,
        rating: Double,
        reviewCount: Int,
        isFavorite: Bool,
        discount: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.price = price
        self.weight = weight
        self.rating = rating
        self.reviewCount = reviewCount
        self.isFavorite = isFavorite
        self.discount = discount
    }
}

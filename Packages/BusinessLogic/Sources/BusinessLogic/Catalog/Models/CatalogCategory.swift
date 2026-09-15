import Foundation

public struct CatalogCategory: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let imageURL: URL?

    public init(id: String, name: String, imageURL: URL? = nil) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
    }
}

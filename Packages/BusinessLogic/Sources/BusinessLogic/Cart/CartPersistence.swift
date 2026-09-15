import Foundation
import SwiftData

@MainActor
public protocol CartPersistence {
    func load() throws -> CartSnapshot?
    func save(_ snapshot: CartSnapshot) throws
}

@Model
final class PersistedCart {
    @Attribute(.unique) var scope: String
    var data: Data

    init(scope: String, data: Data) {
        self.scope = scope
        self.data = data
    }
}

@MainActor
public final class SwiftDataCartPersistence: CartPersistence {
    private let context: ModelContext
    private let scope: String

    public init(scope: String, inMemory: Bool = false) throws {
        guard !scope.isEmpty else { throw CartError.invalidSnapshot }
        let configuration = ModelConfiguration("CartCache", isStoredInMemoryOnly: inMemory)
        let container = try ModelContainer(for: PersistedCart.self, configurations: configuration)
        context = ModelContext(container)
        self.scope = scope
    }

    public func load() throws -> CartSnapshot? {
        let scope = self.scope
        let descriptor = FetchDescriptor<PersistedCart>(predicate: #Predicate { $0.scope == scope })
        guard let stored = try context.fetch(descriptor).first else { return nil }
        let snapshot = try JSONDecoder().decode(CartSnapshot.self, from: stored.data)
        try snapshot.validate()
        return snapshot
    }

    public func save(_ snapshot: CartSnapshot) throws {
        try snapshot.validate()
        let scope = self.scope
        let descriptor = FetchDescriptor<PersistedCart>(predicate: #Predicate { $0.scope == scope })
        let data = try JSONEncoder().encode(snapshot)
        if let stored = try context.fetch(descriptor).first { stored.data = data }
        else { context.insert(PersistedCart(scope: scope, data: data)) }
        try context.save()
    }
}

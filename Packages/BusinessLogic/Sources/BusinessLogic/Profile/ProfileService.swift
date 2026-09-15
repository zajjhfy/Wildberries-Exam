import Foundation
import NetworkPackage

public protocol ProfileService: Sendable {
    func loadProfile() async throws -> UserProfile
    func updateProfile(_ draft: ProfileDraft) async throws
}

public struct DefaultProfileService: ProfileService {
    private let api: any ProfileAPI

    public init(api: any ProfileAPI) { self.api = api }

    public func loadProfile() async throws -> UserProfile {
        let dto = try await api.loadProfile()
        return UserProfile(name: dto.name, phone: dto.phone, birthday: dto.birthday,
                           imageURL: dto.imageUrl.flatMap(validatedImageURL))
    }

    public func updateProfile(_ draft: ProfileDraft) async throws {
        guard draft.isValid else {
            throw NetworkError.invalidRequest
        }
        try await api.updateProfile(name: draft.name, birthday: draft.birthday, imageURI: draft.imageURI)
    }
}

import Foundation
import Observation

@MainActor
@Observable
public final class ProfileViewModel {
    public enum State: Equatable { case idle, loading, loaded, failed(String) }

    public private(set) var state: State = .idle
    public private(set) var profile: UserProfile?
    public private(set) var isSaving = false
    public private(set) var saveError: String?
    public private(set) var refreshError: String?

    @ObservationIgnored private let service: any ProfileService

    public init(service: any ProfileService) { self.service = service }

    public func load() async {
        guard state != .loading, !isSaving else { return }
        state = .loading
        do { profile = try await service.loadProfile(); state = .loaded }
        catch { state = error is CancellationError ? .idle : .failed(error.localizedDescription) }
    }

    @discardableResult
    public func save(_ draft: ProfileDraft) async -> Bool {
        guard !isSaving else { return false }
        isSaving = true
        defer { isSaving = false }
        saveError = nil
        refreshError = nil
        do { try await service.updateProfile(draft) }
        catch {
            if !(error is CancellationError) { saveError = error.localizedDescription }
            return false
        }
        do { profile = try await service.loadProfile(); state = .loaded }
        catch { if !(error is CancellationError) { refreshError = error.localizedDescription } }
        return true
    }
}

import Foundation

public struct APIConfiguration: Sendable {
    public let baseURL: URL
    let apiKey: String

    public init(apiKey: String, baseURL: URL? = nil) throws {
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty,
              !trimmedKey.contains("$("),
              trimmedKey != "YOUR_API_KEY",
              trimmedKey.rangeOfCharacter(from: .whitespacesAndNewlines) == nil else {
            throw NetworkError.missingAPIKey
        }

        let resolvedURL: URL
        do {
            resolvedURL = try baseURL ?? Servers.Server1.url()
        } catch {
            throw NetworkError.invalidServerURL
        }
        guard resolvedURL.scheme?.lowercased() == "https",
              let host = resolvedURL.host, !host.isEmpty,
              resolvedURL.user == nil, resolvedURL.password == nil,
              resolvedURL.query == nil, resolvedURL.fragment == nil else {
            throw NetworkError.invalidServerURL
        }

        self.baseURL = resolvedURL
        self.apiKey = trimmedKey
    }
}

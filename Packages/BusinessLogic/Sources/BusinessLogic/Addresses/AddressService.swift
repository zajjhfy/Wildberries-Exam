import Foundation
import NetworkPackage

public protocol AddressService: Sendable {
    func loadAddresses() async throws -> [DeliveryAddress]
    func createAddress(_ details: AddressDetails) async throws
    func updateAddress(id: String, details: AddressDetails) async throws
    func deleteAddress(id: String) async throws
}

public struct DefaultAddressService: AddressService {
    private let api: any AddressAPI

    public init(api: any AddressAPI) { self.api = api }

    public func loadAddresses() async throws -> [DeliveryAddress] {
        try await api.loadAddresses().map { payload in
            guard let id = payload.value2.id, !id.isEmpty else { throw NetworkError.invalidResponse }
            return try DeliveryAddress(id: id, details: AddressDetails.map(payload.value1))
        }
    }

    public func createAddress(_ details: AddressDetails) async throws {
        guard !details.addressLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NetworkError.invalidRequest
        }
        try await api.createAddress(details.dto)
    }

    public func updateAddress(id: String, details: AddressDetails) async throws {
        guard !id.isEmpty, !details.addressLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NetworkError.invalidRequest
        }
        try await api.updateAddress(id: id, draft: details.dto)
    }

    public func deleteAddress(id: String) async throws {
        guard !id.isEmpty else { throw NetworkError.invalidRequest }
        try await api.deleteAddress(id: id)
    }
}

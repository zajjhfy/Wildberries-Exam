import Foundation
import NetworkPackage

public struct AddressCoordinates: Equatable, Sendable {
    public let longitude: Double
    public let latitude: Double

    public init?(longitude: Double, latitude: Double) {
        guard longitude.isFinite, latitude.isFinite,
              (-180...180).contains(longitude), (-90...90).contains(latitude) else { return nil }
        self.longitude = longitude
        self.latitude = latitude
    }

    init?(_ values: [Double]) {
        var iterator = values.makeIterator()
        guard let longitude = iterator.next(), let latitude = iterator.next(),
              iterator.next() == nil else { return nil }
        self.init(longitude: longitude, latitude: latitude)
    }
}

public struct AddressDetails: Equatable, Sendable {
    public let addressLine: String
    public let coordinates: AddressCoordinates
    public let floor: String?
    public let entrance: String?
    public let intercomCode: String?
    public let comment: String?

    public init(addressLine: String, coordinates: AddressCoordinates, floor: String? = nil,
                entrance: String? = nil, intercomCode: String? = nil, comment: String? = nil) {
        self.addressLine = addressLine
        self.coordinates = coordinates
        self.floor = floor
        self.entrance = entrance
        self.intercomCode = intercomCode
        self.comment = comment
    }

    var dto: AddressDTO {
        AddressDTO(coordinates: [coordinates.longitude, coordinates.latitude],
                   addressLine: addressLine.trimmingCharacters(in: .whitespacesAndNewlines),
                   floor: floor?.trimmedOrNil, entrance: entrance?.trimmedOrNil,
                   intercomCode: intercomCode?.trimmedOrNil, comment: comment?.trimmedOrNil)
    }

    static func map(_ dto: AddressDTO) throws -> AddressDetails {
        guard let coordinates = AddressCoordinates(dto.coordinates),
              !dto.addressLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NetworkError.invalidResponse
        }
        return AddressDetails(addressLine: dto.addressLine, coordinates: coordinates,
                              floor: dto.floor, entrance: dto.entrance,
                              intercomCode: dto.intercomCode, comment: dto.comment)
    }
}

public struct DeliveryAddress: Identifiable, Equatable, Sendable {
    public let id: String
    public let details: AddressDetails

    public init(id: String, details: AddressDetails) {
        self.id = id
        self.details = details
    }
}

private extension String {
    var trimmedOrNil: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

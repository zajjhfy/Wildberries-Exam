import Foundation

public struct UserProfile: Equatable, Sendable {
    public let name: String
    public let phone: String
    public let birthday: String
    public let imageURL: URL?
}

public struct ProfileDraft: Equatable, Sendable {
    public let name: String
    public let birthday: String
    public let imageURI: String

    public init(name: String, birthday: String, imageURI: String) {
        self.name = name
        self.birthday = birthday
        self.imageURI = imageURI
    }

    public var isValid: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              birthday.range(of: #"^\d{2}\.\d{2}\.\d{4}$"#, options: .regularExpression) != nil,
              let url = validatedImageURL(imageURI), url.pathExtension.lowercased() == "jxl" else {
            return false
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.isLenient = false
        return formatter.date(from: birthday) != nil
    }
}

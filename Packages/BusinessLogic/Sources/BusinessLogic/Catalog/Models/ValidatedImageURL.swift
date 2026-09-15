import Foundation

func validatedImageURL(_ value: String) -> URL? {
    guard let url = URL(string: value),
          let scheme = url.scheme?.lowercased(), ["https", "http"].contains(scheme),
          let host = url.host, !host.isEmpty,
          url.user == nil, url.password == nil else { return nil }
    return url
}

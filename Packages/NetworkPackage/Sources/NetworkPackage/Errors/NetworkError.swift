import Foundation
import OpenAPIRuntime

public enum NetworkError: Error, Equatable, Sendable, LocalizedError {
    case missingAPIKey
    case invalidServerURL
    case invalidRequest
    case unauthorized
    case forbidden
    case notFound
    case httpStatus(Int)
    case invalidResponse
    case transport(URLError.Code)
    case unexpected

    public var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            "Не настроен API-ключ. Проверь Secrets.xcconfig и пересобери приложение."
        case .invalidServerURL:
            "Некорректный адрес сервера."
        case .invalidRequest:
            "Некорректные параметры запроса."
        case .unauthorized:
            "Сервер не принял API-ключ. Проверь ключ и срок его действия."
        case .forbidden:
            "Нет доступа к запрошенным данным."
        case .notFound:
            "Запрошенные данные не найдены."
        case .httpStatus(let statusCode):
            "Сервер вернул ошибку \(statusCode). Попробуй ещё раз."
        case .invalidResponse:
            "Сервер вернул некорректные данные."
        case .transport(.notConnectedToInternet):
            "Нет подключения к интернету."
        case .transport(.timedOut):
            "Сервер не ответил вовремя. Попробуй ещё раз."
        case .transport:
            "Не удалось подключиться к серверу."
        case .unexpected:
            "Не удалось загрузить данные. Попробуй ещё раз."
        }
    }

    static func httpError(statusCode: Int) -> NetworkError {
        switch statusCode {
        case 400: .invalidRequest
        case 401: .unauthorized
        case 403: .forbidden
        case 404: .notFound
        default: .httpStatus(statusCode)
        }
    }

    // ClientError can contain request headers. Never forward it to UI or logs.
    static func normalized(_ error: any Error) -> any Error {
        if error is CancellationError || Task.isCancelled {
            return CancellationError()
        }
        if let clientError = error as? ClientError {
            return normalized(clientError.underlyingError)
        }
        if let networkError = error as? NetworkError {
            return networkError
        }
        if let urlError = error as? URLError {
            return urlError.code == .cancelled ? CancellationError() : NetworkError.transport(urlError.code)
        }
        if error is DecodingError {
            return NetworkError.invalidResponse
        }
        return NetworkError.unexpected
    }
}

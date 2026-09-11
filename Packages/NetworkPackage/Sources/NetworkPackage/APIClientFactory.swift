import OpenAPIRuntime
import OpenAPIURLSession

enum APIClientFactory {
    static func makeClient(
        configuration: APIConfiguration,
        transport: any ClientTransport = URLSessionTransport()
    ) -> Client {
        Client(
            serverURL: configuration.baseURL,
            transport: transport,
            middlewares: [
                BearerAuthMiddleware(apiKey: configuration.apiKey),
                HTTPStatusMiddleware(),
            ]
        )
    }
}

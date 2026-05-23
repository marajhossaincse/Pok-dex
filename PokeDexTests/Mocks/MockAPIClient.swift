import Foundation
@testable import PokeDex

final class MockAPIClient: APIClientProtocol {
    var responseProvider: ((APIEndpoint) throws -> Any) = { _ in
        fatalError("MockAPIClient.responseProvider not configured for this test")
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let result = try responseProvider(endpoint)
        guard let typed = result as? T else {
            throw APIError.decodingFailed(
                NSError(domain: "MockAPIClient", code: 0, userInfo: [
                    NSLocalizedDescriptionKey: "Mock returned \(type(of: result)), expected \(T.self)"
                ])
            )
        }
        return typed
    }
}

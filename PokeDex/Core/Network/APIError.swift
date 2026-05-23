import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL was invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .httpError(let code):
            return "HTTP error with status code: \(code)."
        case .decodingFailed:
            return "Failed to decode the server response."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

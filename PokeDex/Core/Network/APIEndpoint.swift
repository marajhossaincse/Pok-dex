import Foundation

enum APIEndpoint {
    case pokemonList(limit: Int, offset: Int)
    case pokemonDetail(name: String)

    private static let baseURL = "https://pokeapi.co/api/v2"

    var url: URL {
        get throws {
            switch self {
            case .pokemonList(let limit, let offset):
                var components = URLComponents(string: "\(Self.baseURL)/pokemon")!
                components.queryItems = [
                    URLQueryItem(name: "limit", value: "\(limit)"),
                    URLQueryItem(name: "offset", value: "\(offset)")
                ]
                guard let url = components.url else { throw APIError.invalidURL }
                return url
            case .pokemonDetail(let name):
                guard let url = URL(string: "\(Self.baseURL)/pokemon/\(name)") else {
                    throw APIError.invalidURL
                }
                return url
            }
        }
    }
}

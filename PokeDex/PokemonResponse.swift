
// MARK: - PokemonReponse

struct PokemonReponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Pokemon]
}

// MARK: - Pokemon

struct Pokemon: Codable, Hashable {
    let name: String
    let url: String
}


// MARK: - PokemonReponse

struct PokemonReponse: Codable {
    let count: Int
    let next: String
    let previous: String
    let results: [Result]
}

// MARK: - Result

struct Result: Codable, Hashable{
    let name: String
    let url: String
}

struct PokemonListDTO: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonDTO]
}

struct PokemonDTO: Decodable {
    let name: String
    let url: String
}

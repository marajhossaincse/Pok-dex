struct PokemonTypeDTO: Decodable {
    struct PokemonEntry: Decodable {
        struct PokemonRef: Decodable {
            let name: String
            let url: String
        }
        let pokemon: PokemonRef
        let slot: Int
    }
    let pokemon: [PokemonEntry]
}

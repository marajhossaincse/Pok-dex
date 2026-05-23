struct PokemonModel: Identifiable, Hashable {
    let id: String
    let name: String
    let url: String
}

struct PokemonListModel {
    let pokemons: [PokemonModel]
    let hasMore: Bool
}

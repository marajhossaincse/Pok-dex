struct PokemonModel: Identifiable, Hashable {
    let id: String
    let name: String
    let url: String
    let spriteURL: String
}

struct PokemonListModel {
    let pokemons: [PokemonModel]
    let hasMore: Bool
}

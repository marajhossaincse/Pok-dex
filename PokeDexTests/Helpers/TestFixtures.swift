import Foundation
@testable import PokeDex

enum TestFixtures {
    static let pokemonListPage1 = Data("""
    {
        "count": 1302,
        "next": "https://pokeapi.co/api/v2/pokemon/?offset=20&limit=20",
        "previous": null,
        "results": [
            {"name": "bulbasaur", "url": "https://pokeapi.co/api/v2/pokemon/1/"},
            {"name": "ivysaur",   "url": "https://pokeapi.co/api/v2/pokemon/2/"}
        ]
    }
    """.utf8)

    static let pokemonListLastPage = Data("""
    {
        "count": 1302,
        "next": null,
        "previous": "https://pokeapi.co/api/v2/pokemon/?offset=0&limit=20",
        "results": [
            {"name": "bulbasaur", "url": "https://pokeapi.co/api/v2/pokemon/1/"}
        ]
    }
    """.utf8)

    static func makePokemonModel(id: String = "1", name: String = "bulbasaur") -> PokemonModel {
        PokemonModel(id: id, name: name, url: "https://pokeapi.co/api/v2/pokemon/\(id)/")
    }

    static func makeListModel(
        pokemons: [PokemonModel]? = nil,
        hasMore: Bool = true
    ) -> PokemonListModel {
        PokemonListModel(
            pokemons: pokemons ?? [makePokemonModel()],
            hasMore: hasMore
        )
    }
}

@testable import PokeDex

final class MockPokemonRepository: PokemonRepositoryProtocol {
    var listResult: PokemonListModel = PokemonListModel(pokemons: [], hasMore: false)
    var detailResult: PokemonDetailModel = .stub()
    var errorToThrow: Error?
    private(set) var fetchCallCount = 0
    private(set) var lastFetchLimit: Int?
    private(set) var lastFetchOffset: Int?
    private(set) var fetchDetailCallCount = 0
    private(set) var lastFetchDetailName: String?

    func fetchPokemons(limit: Int, offset: Int) async throws -> PokemonListModel {
        fetchCallCount += 1
        lastFetchLimit = limit
        lastFetchOffset = offset
        if let error = errorToThrow { throw error }
        return listResult
    }

    func fetchPokemonDetail(name: String) async throws -> PokemonDetailModel {
        fetchDetailCallCount += 1
        lastFetchDetailName = name
        if let error = errorToThrow { throw error }
        return detailResult
    }
}

extension PokemonDetailModel {
    static func stub(
        id: Int = 1,
        name: String = "bulbasaur",
        types: [String] = ["grass", "poison"],
        stats: [PokemonStat] = [PokemonStat(name: "hp", value: 45)],
        abilities: [PokemonAbility] = [PokemonAbility(name: "overgrow", isHidden: false)]
    ) -> PokemonDetailModel {
        PokemonDetailModel(
            id: id, name: name, height: 7, weight: 69,
            types: types, stats: stats, abilities: abilities,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"
        )
    }
}

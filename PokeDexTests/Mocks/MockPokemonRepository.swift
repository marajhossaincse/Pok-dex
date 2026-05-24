@testable import PokeDex

final class MockPokemonRepository: PokemonRepositoryProtocol {
    var listResult: PokemonListModel = PokemonListModel(pokemons: [], hasMore: false)
    var detailResult: PokemonDetailModel = .stub()
    var evolutionChainResult: EvolutionChainModel = .stub()
    var typeResult: [PokemonModel] = []
    var errorToThrow: Error?
    private(set) var fetchCallCount = 0
    private(set) var lastFetchLimit: Int?
    private(set) var lastFetchOffset: Int?
    private(set) var fetchDetailCallCount = 0
    private(set) var lastFetchDetailName: String?
    private(set) var fetchEvolutionChainCallCount = 0
    private(set) var lastFetchEvolutionChainSpeciesURL: String?
    private(set) var fetchByTypeCallCount = 0
    private(set) var lastFetchByType: String?

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

    func fetchEvolutionChain(speciesURL: String) async throws -> EvolutionChainModel {
        fetchEvolutionChainCallCount += 1
        lastFetchEvolutionChainSpeciesURL = speciesURL
        if let error = errorToThrow { throw error }
        return evolutionChainResult
    }

    func fetchPokemonsByType(_ type: String) async throws -> [PokemonModel] {
        fetchByTypeCallCount += 1
        lastFetchByType = type
        if let error = errorToThrow { throw error }
        return typeResult
    }
}

extension PokemonDetailModel {
    static func stub(
        id: Int = 1,
        name: String = "bulbasaur",
        types: [String] = ["grass", "poison"],
        stats: [PokemonStat] = [PokemonStat(name: "hp", value: 45)],
        abilities: [PokemonAbility] = [PokemonAbility(name: "overgrow", isHidden: false)],
        speciesURL: String = "https://pokeapi.co/api/v2/pokemon-species/1/"
    ) -> PokemonDetailModel {
        PokemonDetailModel(
            id: id, name: name, height: 7, weight: 69,
            types: types, stats: stats, abilities: abilities,
            spriteURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png",
            speciesURL: speciesURL
        )
    }
}

extension EvolutionChainModel {
    static func stub() -> EvolutionChainModel {
        let artworkBase = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork"
        return EvolutionChainModel(stages: [
            [EvolutionStage(name: "bulbasaur", id: "1", spriteURL: "\(artworkBase)/1.png")],
            [EvolutionStage(name: "ivysaur",   id: "2", spriteURL: "\(artworkBase)/2.png")],
            [EvolutionStage(name: "venusaur",  id: "3", spriteURL: "\(artworkBase)/3.png")]
        ])
    }
}

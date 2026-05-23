@testable import PokeDex

final class MockPokemonRepository: PokemonRepositoryProtocol {
    var result: PokemonListModel = PokemonListModel(pokemons: [], hasMore: false)
    var errorToThrow: Error?
    private(set) var fetchCallCount = 0
    private(set) var lastFetchLimit: Int?
    private(set) var lastFetchOffset: Int?

    func fetchPokemons(limit: Int, offset: Int) async throws -> PokemonListModel {
        fetchCallCount += 1
        lastFetchLimit = limit
        lastFetchOffset = offset
        if let error = errorToThrow { throw error }
        return result
    }
}

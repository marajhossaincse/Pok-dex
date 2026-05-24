protocol PokemonRepositoryProtocol {
    func fetchPokemons(limit: Int, offset: Int) async throws -> PokemonListModel
    func fetchPokemonDetail(name: String) async throws -> PokemonDetailModel
    func fetchEvolutionChain(speciesURL: String) async throws -> EvolutionChainModel
    func fetchPokemonsByType(_ type: String) async throws -> [PokemonModel]
}

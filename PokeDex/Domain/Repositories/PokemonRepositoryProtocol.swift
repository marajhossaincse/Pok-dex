protocol PokemonRepositoryProtocol {
    func fetchPokemons(limit: Int, offset: Int) async throws -> PokemonListModel
    func fetchPokemonDetail(name: String) async throws -> PokemonDetailModel
}

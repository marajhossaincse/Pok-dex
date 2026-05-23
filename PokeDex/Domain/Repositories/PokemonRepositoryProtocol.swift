protocol PokemonRepositoryProtocol {
    func fetchPokemons(limit: Int, offset: Int) async throws -> PokemonListModel
}

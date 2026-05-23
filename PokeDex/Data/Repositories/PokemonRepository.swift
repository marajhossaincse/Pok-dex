final class PokemonRepository: PokemonRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchPokemons(limit: Int, offset: Int) async throws -> PokemonListModel {
        let dto: PokemonListDTO = try await apiClient.request(.pokemonList(limit: limit, offset: offset))
        return PokemonMapper.toDomain(dto)
    }
}

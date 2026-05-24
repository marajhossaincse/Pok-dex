final class PokemonRepository: PokemonRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchPokemons(limit: Int, offset: Int) async throws -> PokemonListModel {
        let dto: PokemonListDTO = try await apiClient.request(.pokemonList(limit: limit, offset: offset))
        return PokemonMapper.toDomain(dto)
    }

    func fetchPokemonDetail(name: String) async throws -> PokemonDetailModel {
        let dto: PokemonDetailDTO = try await apiClient.request(.pokemonDetail(name: name))
        return PokemonDetailMapper.toDomain(dto)
    }

    func fetchEvolutionChain(speciesURL: String) async throws -> EvolutionChainModel {
        let species: PokemonSpeciesDTO = try await apiClient.request(.pokemonSpecies(url: speciesURL))
        let chain: EvolutionChainDTO = try await apiClient.request(.evolutionChain(url: species.evolutionChain.url))
        return EvolutionChainMapper.toDomain(chain)
    }

    func fetchPokemonsByType(_ type: String) async throws -> [PokemonModel] {
        let dto: PokemonTypeDTO = try await apiClient.request(.pokemonType(name: type))
        return dto.pokemon.map { entry in
            PokemonMapper.toDomain(PokemonDTO(name: entry.pokemon.name, url: entry.pokemon.url))
        }
    }
}

import Testing
@testable import PokeDex

@Suite("PokemonRepository")
struct PokemonRepositoryTests {
    @Test("Returns correctly mapped domain model on success")
    func returnsMappedDomainModel() async throws {
        let mockClient = MockAPIClient()
        mockClient.responseProvider = { _ in
            PokemonListDTO(
                count: 2,
                next: "next-url",
                previous: nil,
                results: [
                    PokemonDTO(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
                    PokemonDTO(name: "ivysaur",   url: "https://pokeapi.co/api/v2/pokemon/2/")
                ]
            )
        }

        let repository = PokemonRepository(apiClient: mockClient)
        let result = try await repository.fetchPokemons(limit: 20, offset: 0)

        #expect(result.pokemons.count == 2)
        #expect(result.pokemons[0].name == "bulbasaur")
        #expect(result.pokemons[0].id == "1")
        #expect(result.hasMore == true)
    }

    @Test("Sets hasMore false when API returns no next URL")
    func hasMoreFalseWhenNoNextURL() async throws {
        let mockClient = MockAPIClient()
        mockClient.responseProvider = { _ in
            PokemonListDTO(count: 1, next: nil, previous: nil, results: [
                PokemonDTO(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/")
            ])
        }

        let repository = PokemonRepository(apiClient: mockClient)
        let result = try await repository.fetchPokemons(limit: 20, offset: 0)

        #expect(result.hasMore == false)
    }

    @Test("Propagates API errors without wrapping them")
    func propagatesAPIErrors() async {
        let mockClient = MockAPIClient()
        mockClient.responseProvider = { _ in throw APIError.invalidResponse }

        let repository = PokemonRepository(apiClient: mockClient)

        do {
            _ = try await repository.fetchPokemons(limit: 20, offset: 0)
            Issue.record("Expected an error to be thrown")
        } catch {
            #expect(error is APIError)
        }
    }
}

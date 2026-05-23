import Testing
@testable import PokeDex

@Suite("PokemonMapper")
struct PokemonMapperTests {
    @Test("Extracts numeric ID from the end of the pokemon URL")
    func extractsIDFromURL() {
        let dto = PokemonDTO(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/")
        let model = PokemonMapper.toDomain(dto)
        #expect(model.id == "1")
        #expect(model.name == "bulbasaur")
        #expect(model.url == "https://pokeapi.co/api/v2/pokemon/1/")
    }

    @Test("Sets hasMore true when next URL is present")
    func hasMoreTrueWhenNextPresent() {
        let dto = PokemonListDTO(count: 100, next: "some-url", previous: nil, results: [])
        let model = PokemonMapper.toDomain(dto)
        #expect(model.hasMore == true)
    }

    @Test("Sets hasMore false when next URL is nil")
    func hasMoreFalseWhenNextNil() {
        let dto = PokemonListDTO(count: 1, next: nil, previous: nil, results: [])
        let model = PokemonMapper.toDomain(dto)
        #expect(model.hasMore == false)
    }

    @Test("Maps all results preserving order")
    func mapsAllResultsInOrder() {
        let dto = PokemonListDTO(
            count: 2,
            next: nil,
            previous: nil,
            results: [
                PokemonDTO(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
                PokemonDTO(name: "ivysaur",   url: "https://pokeapi.co/api/v2/pokemon/2/")
            ]
        )
        let model = PokemonMapper.toDomain(dto)
        #expect(model.pokemons.count == 2)
        #expect(model.pokemons[0].id == "1")
        #expect(model.pokemons[1].id == "2")
    }
}

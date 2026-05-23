import Testing
@testable import PokeDex

@Suite("EvolutionChainMapper")
struct EvolutionChainMapperTests {
    private let artworkBase = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork"

    private func makeLink(name: String, id: Int, children: [ChainLinkDTO] = []) -> ChainLinkDTO {
        ChainLinkDTO(
            species: ChainSpeciesDTO(name: name, url: "https://pokeapi.co/api/v2/pokemon-species/\(id)/"),
            evolvesTo: children
        )
    }

    @Test("Linear chain produces one stage per level")
    func linearChain() {
        let dto = EvolutionChainDTO(chain:
            makeLink(name: "bulbasaur", id: 1, children: [
                makeLink(name: "ivysaur", id: 2, children: [
                    makeLink(name: "venusaur", id: 3)
                ])
            ])
        )

        let model = EvolutionChainMapper.toDomain(dto)

        #expect(model.stages.count == 3)
        #expect(model.stages[0].count == 1)
        #expect(model.stages[0][0].name == "bulbasaur")
        #expect(model.stages[1][0].name == "ivysaur")
        #expect(model.stages[2][0].name == "venusaur")
    }

    @Test("Branching chain groups all siblings into the same stage")
    func branchingChain() {
        let dto = EvolutionChainDTO(chain:
            makeLink(name: "eevee", id: 133, children: [
                makeLink(name: "vaporeon", id: 134),
                makeLink(name: "jolteon",  id: 135),
                makeLink(name: "flareon",  id: 136)
            ])
        )

        let model = EvolutionChainMapper.toDomain(dto)

        #expect(model.stages.count == 2)
        #expect(model.stages[0].count == 1)
        #expect(model.stages[0][0].name == "eevee")
        #expect(model.stages[1].count == 3)
        #expect(model.stages[1].map { $0.name } == ["vaporeon", "jolteon", "flareon"])
    }

    @Test("Single-stage pokemon produces exactly one stage")
    func singleStagePokemon() {
        let dto = EvolutionChainDTO(chain: makeLink(name: "ditto", id: 132))
        let model = EvolutionChainMapper.toDomain(dto)

        #expect(model.stages.count == 1)
        #expect(model.stages[0][0].name == "ditto")
    }

    @Test("Extracts numeric id from species URL for sprite URL")
    func buildsSpriteURLFromSpeciesURL() {
        let dto = EvolutionChainDTO(chain: makeLink(name: "pikachu", id: 25))
        let model = EvolutionChainMapper.toDomain(dto)

        #expect(model.stages[0][0].id == "25")
        #expect(model.stages[0][0].spriteURL == "\(artworkBase)/25.png")
    }
}

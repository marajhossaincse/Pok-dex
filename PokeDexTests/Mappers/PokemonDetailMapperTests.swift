import Testing
@testable import PokeDex

@Suite("PokemonDetailMapper")
struct PokemonDetailMapperTests {
    private func makeDTO(
        id: Int = 1,
        name: String = "bulbasaur",
        height: Int = 7,
        weight: Int = 69,
        types: [(slot: Int, name: String)] = [(1, "grass"), (2, "poison")],
        stats: [(name: String, value: Int)] = [("hp", 45), ("attack", 49)],
        abilities: [(name: String, hidden: Bool)] = [("overgrow", false), ("chlorophyll", true)]
    ) -> PokemonDetailDTO {
        PokemonDetailDTO(
            id: id,
            name: name,
            height: height,
            weight: weight,
            types: types.map { PokemonTypeSlotDTO(slot: $0.slot, type: PokemonTypeInfoDTO(name: $0.name)) },
            stats: stats.map { PokemonStatDTO(baseStat: $0.value, stat: PokemonStatInfoDTO(name: $0.name)) },
            abilities: abilities.map { PokemonAbilitySlotDTO(ability: PokemonAbilityInfoDTO(name: $0.name), isHidden: $0.hidden) }
        )
    }

    @Test("Maps id, name, height and weight directly from DTO")
    func mapsBasicFields() {
        let model = PokemonDetailMapper.toDomain(makeDTO())
        #expect(model.id == 1)
        #expect(model.name == "bulbasaur")
        #expect(model.height == 7)
        #expect(model.weight == 69)
    }

    @Test("Sorts types by slot so primary type is always first")
    func sortTypesBySlot() {
        let dto = makeDTO(types: [(2, "poison"), (1, "grass")])
        let model = PokemonDetailMapper.toDomain(dto)
        #expect(model.types == ["grass", "poison"])
    }

    @Test("Maps all stat names and base values")
    func mapsStats() {
        let model = PokemonDetailMapper.toDomain(makeDTO())
        #expect(model.stats.count == 2)
        #expect(model.stats[0].name == "hp")
        #expect(model.stats[0].value == 45)
        #expect(model.stats[1].name == "attack")
        #expect(model.stats[1].value == 49)
    }

    @Test("Places non-hidden abilities before hidden ones")
    func sortsAbilitiesHiddenLast() {
        let dto = makeDTO(abilities: [("chlorophyll", true), ("overgrow", false)])
        let model = PokemonDetailMapper.toDomain(dto)
        #expect(model.abilities[0].name == "overgrow")
        #expect(model.abilities[0].isHidden == false)
        #expect(model.abilities[1].name == "chlorophyll")
        #expect(model.abilities[1].isHidden == true)
    }

    @Test("Builds official artwork URL from the pokemon id")
    func buildsSpriteURL() {
        let model = PokemonDetailMapper.toDomain(makeDTO(id: 25))
        #expect(model.spriteURL == "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png")
    }
}

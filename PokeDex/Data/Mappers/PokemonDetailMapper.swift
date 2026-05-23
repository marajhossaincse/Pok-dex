enum PokemonDetailMapper {
    private static let artworkBaseURL =
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork"

    static func toDomain(_ dto: PokemonDetailDTO) -> PokemonDetailModel {
        PokemonDetailModel(
            id: dto.id,
            name: dto.name,
            height: dto.height,
            weight: dto.weight,
            types: dto.types
                .sorted { $0.slot < $1.slot }
                .map { $0.type.name },
            stats: dto.stats.map {
                PokemonStat(name: $0.stat.name, value: $0.baseStat)
            },
            abilities: dto.abilities
                .sorted { !$0.isHidden && $1.isHidden }
                .map { PokemonAbility(name: $0.ability.name, isHidden: $0.isHidden) },
            spriteURL: "\(artworkBaseURL)/\(dto.id).png"
        )
    }
}

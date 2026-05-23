enum PokemonMapper {
    private static let artworkBaseURL =
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork"

    static func toDomain(_ dto: PokemonListDTO) -> PokemonListModel {
        PokemonListModel(
            pokemons: dto.results.map(toDomain),
            hasMore: dto.next != nil
        )
    }

    static func toDomain(_ dto: PokemonDTO) -> PokemonModel {
        // Extracts the numeric ID from the URL: ".../pokemon/1/"
        let id = dto.url
            .split(separator: "/")
            .last
            .map(String.init) ?? dto.name
        return PokemonModel(
            id: id,
            name: dto.name,
            url: dto.url,
            spriteURL: "\(artworkBaseURL)/\(id).png"
        )
    }
}

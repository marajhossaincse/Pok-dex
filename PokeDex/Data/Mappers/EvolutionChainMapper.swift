enum EvolutionChainMapper {
    private static let artworkBaseURL =
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork"

    static func toDomain(_ dto: EvolutionChainDTO) -> EvolutionChainModel {
        var stages: [[EvolutionStage]] = []
        var currentLevel = [dto.chain]

        while !currentLevel.isEmpty {
            stages.append(currentLevel.map(makeStage))
            currentLevel = currentLevel.flatMap { $0.evolvesTo }
        }

        return EvolutionChainModel(stages: stages)
    }

    private static func makeStage(_ link: ChainLinkDTO) -> EvolutionStage {
        let id = link.species.url.split(separator: "/").last.map(String.init) ?? link.species.name
        return EvolutionStage(name: link.species.name, id: id, spriteURL: "\(artworkBaseURL)/\(id).png")
    }
}

struct EvolutionChainDTO: Decodable {
    let chain: ChainLinkDTO
}

struct ChainLinkDTO: Decodable {
    let species: ChainSpeciesDTO
    let evolvesTo: [ChainLinkDTO]

    enum CodingKeys: String, CodingKey {
        case species
        case evolvesTo = "evolves_to"
    }
}

struct ChainSpeciesDTO: Decodable {
    let name: String
    let url: String
}

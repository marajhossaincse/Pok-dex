struct PokemonSpeciesDTO: Decodable {
    let evolutionChain: EvolutionChainReferenceDTO

    enum CodingKeys: String, CodingKey {
        case evolutionChain = "evolution_chain"
    }
}

struct EvolutionChainReferenceDTO: Decodable {
    let url: String
}

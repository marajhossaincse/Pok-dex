struct PokemonDetailDTO: Decodable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let types: [PokemonTypeSlotDTO]
    let stats: [PokemonStatDTO]
    let abilities: [PokemonAbilitySlotDTO]
}

struct PokemonTypeSlotDTO: Decodable {
    let slot: Int
    let type: PokemonTypeInfoDTO
}

struct PokemonTypeInfoDTO: Decodable {
    let name: String
}

struct PokemonStatDTO: Decodable {
    let baseStat: Int
    let stat: PokemonStatInfoDTO

    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case stat
    }
}

struct PokemonStatInfoDTO: Decodable {
    let name: String
}

struct PokemonAbilitySlotDTO: Decodable {
    let ability: PokemonAbilityInfoDTO
    let isHidden: Bool

    enum CodingKeys: String, CodingKey {
        case ability
        case isHidden = "is_hidden"
    }
}

struct PokemonAbilityInfoDTO: Decodable {
    let name: String
}

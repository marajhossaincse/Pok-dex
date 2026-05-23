struct PokemonDetailModel {
    let id: Int
    let name: String
    let height: Int        // decimetres — divide by 10 for metres
    let weight: Int        // hectograms — divide by 10 for kg
    let types: [String]
    let stats: [PokemonStat]
    let abilities: [PokemonAbility]
    let spriteURL: String
}

struct PokemonStat {
    let name: String
    let value: Int
}

struct PokemonAbility {
    let name: String
    let isHidden: Bool
}

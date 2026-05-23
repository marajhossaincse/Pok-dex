import SwiftUI

struct PokemonDetailView: View {
    let pokemon: PokemonModel

    var body: some View {
        VStack(spacing: 16) {
            Text("#\(pokemon.id)")
                .font(.title2)
                .foregroundColor(.secondary)
            Text(pokemon.name.capitalized)
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .navigationTitle(pokemon.name.capitalized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

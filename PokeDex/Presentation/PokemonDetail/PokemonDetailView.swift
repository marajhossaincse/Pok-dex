import SwiftUI

struct PokemonDetailView: View {
    let pokemon: PokemonModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                artworkHeader
                infoSection
            }
        }
        .navigationTitle(pokemon.name.capitalized)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Artwork Header

    private var artworkHeader: some View {
        ZStack {
            Color(.systemIndigo).opacity(0.1)

            AsyncImage(url: URL(string: pokemon.spriteURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "photo.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.secondary)
                case .empty:
                    ProgressView()
                        .scaleEffect(1.5)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 240, height: 240)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(spacing: 8) {
            Text(formattedID)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(pokemon.name.capitalized)
                .font(.system(size: 34, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
        .padding(.bottom, 32)
        .padding(.horizontal, 24)
    }

    private var formattedID: String {
        guard let number = Int(pokemon.id) else { return "#\(pokemon.id)" }
        return String(format: "#%04d", number)
    }
}

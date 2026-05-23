import SwiftUI

@MainActor
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel(
        repository: PokemonRepository(apiClient: APIClient())
    )

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Pokédex")
        }
        .task {
            await viewModel.loadInitial()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading...")
        } else if let error = viewModel.errorMessage, viewModel.pokemons.isEmpty {
            errorView(message: error)
        } else {
            pokemonList
        }
    }

    private var pokemonList: some View {
        List {
            ForEach(viewModel.pokemons) { pokemon in
                NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                    PokemonRowView(pokemon: pokemon)
                }
                .onAppear {
                    if pokemon == viewModel.pokemons.last {
                        Task { await viewModel.loadMore() }
                    }
                }
            }

            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task { await viewModel.loadInitial() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct PokemonRowView: View {
    let pokemon: PokemonModel

    var body: some View {
        HStack(spacing: 16) {
            spriteImage
            VStack(alignment: .leading, spacing: 2) {
                Text(pokemon.name.capitalized)
                    .font(.headline)
                Text(formattedID)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }

    private var spriteImage: some View {
        AsyncImage(url: URL(string: pokemon.spriteURL)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .padding(4)
            case .failure:
                Image(systemName: "photo")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
            case .empty:
                ProgressView()
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 64, height: 64)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var formattedID: String {
        guard let number = Int(pokemon.id) else { return "#\(pokemon.id)" }
        return String(format: "#%04d", number)
    }
}

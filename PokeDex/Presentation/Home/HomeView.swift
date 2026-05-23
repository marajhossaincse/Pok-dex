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
            Circle()
                .fill(Color.red.opacity(0.8))
                .frame(width: 36, height: 36)
                .overlay(
                    Text("#\(pokemon.id)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            Text(pokemon.name.capitalized)
                .font(.body)
                .fontWeight(.medium)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

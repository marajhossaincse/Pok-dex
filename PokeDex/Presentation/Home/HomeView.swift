import SwiftUI

@MainActor
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel(
        repository: PokemonRepository(apiClient: APIClient())
    )

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                typeFilterChips
                content
            }
            .navigationTitle("Pokédex")
            .searchable(text: $viewModel.searchQuery, prompt: "Search Pokémon")
        }
        .task {
            await viewModel.loadInitial()
        }
    }

    private var typeFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PokemonType.allCases) { type in
                    TypeChipView(
                        type: type,
                        isSelected: viewModel.selectedType == type
                    ) {
                        viewModel.selectedType = viewModel.selectedType == type ? nil : type
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color(.systemBackground))
        return Divider()
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView("Loading...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.isLoadingFilter {
            ProgressView("Filtering...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage, viewModel.pokemons.isEmpty {
            errorView(message: error)
        } else if viewModel.pokemons.isEmpty {
            emptyView
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

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No Pokémon found")
                .font(.headline)
            Text("Try a different name or type.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

struct TypeChipView: View {
    let type: PokemonType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(type.displayName)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : type.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? type.color : type.color.opacity(0.15))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(type.color, lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
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
        CachedAsyncImage(url: URL(string: pokemon.spriteURL)) { phase in
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

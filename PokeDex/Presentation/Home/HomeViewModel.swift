import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var pokemons: [PokemonModel] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var isLoadingFilter = false
    @Published private(set) var errorMessage: String?

    @Published var searchQuery: String = "" {
        didSet { applyFilters() }
    }
    @Published var selectedType: PokemonType? = nil {
        didSet { Task { await onTypeFilterChanged() } }
    }

    private var canLoadMore = true
    private var currentOffset = 0
    private let limit = 20

    private var paginatedPokemons: [PokemonModel] = []
    private var typePokemons: [PokemonModel]? = nil

    private let repository: PokemonRepositoryProtocol

    init(repository: PokemonRepositoryProtocol) {
        self.repository = repository
    }

    func loadInitial() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        currentOffset = 0
        canLoadMore = true
        paginatedPokemons = []
        typePokemons = nil
        defer { isLoading = false }

        do {
            let result = try await repository.fetchPokemons(limit: limit, offset: 0)
            paginatedPokemons = result.pokemons
            canLoadMore = result.hasMore
            currentOffset = limit
            applyFilters()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadMore() async {
        guard canLoadMore, !isLoadingMore, !isLoading, selectedType == nil else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let result = try await repository.fetchPokemons(limit: limit, offset: currentOffset)
            paginatedPokemons.append(contentsOf: result.pokemons)
            canLoadMore = result.hasMore
            currentOffset += limit
            applyFilters()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func onTypeFilterChanged() async {
        guard let type = selectedType else {
            typePokemons = nil
            applyFilters()
            return
        }

        isLoadingFilter = true
        errorMessage = nil
        defer { isLoadingFilter = false }

        do {
            typePokemons = try await repository.fetchPokemonsByType(type.rawValue)
        } catch {
            errorMessage = error.localizedDescription
            typePokemons = nil
            selectedType = nil
        }
        applyFilters()
    }

    private func applyFilters() {
        let base = typePokemons ?? paginatedPokemons
        guard !searchQuery.isEmpty else {
            pokemons = base
            return
        }
        let query = searchQuery.lowercased()
        pokemons = base.filter { $0.name.lowercased().contains(query) }
    }
}

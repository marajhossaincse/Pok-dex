import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var pokemons: [PokemonModel] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var errorMessage: String?

    private var canLoadMore = true
    private var currentOffset = 0
    private let limit = 20

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
        pokemons = []
        defer { isLoading = false }

        do {
            let result = try await repository.fetchPokemons(limit: limit, offset: 0)
            pokemons = result.pokemons
            canLoadMore = result.hasMore
            currentOffset = limit
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadMore() async {
        guard canLoadMore, !isLoadingMore, !isLoading else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let result = try await repository.fetchPokemons(limit: limit, offset: currentOffset)
            pokemons.append(contentsOf: result.pokemons)
            canLoadMore = result.hasMore
            currentOffset += limit
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

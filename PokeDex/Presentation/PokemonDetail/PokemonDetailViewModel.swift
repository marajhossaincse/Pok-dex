import Foundation

@MainActor
final class PokemonDetailViewModel: ObservableObject {
    @Published private(set) var detail: PokemonDetailModel?
    @Published private(set) var evolutionChain: EvolutionChainModel?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let repository: PokemonRepositoryProtocol
    private let pokemonName: String

    init(pokemonName: String, repository: PokemonRepositoryProtocol) {
        self.pokemonName = pokemonName
        self.repository = repository
    }

    func loadDetail() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            detail = try await repository.fetchPokemonDetail(name: pokemonName)
            evolutionChain = try? await repository.fetchEvolutionChain(speciesURL: detail!.speciesURL)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

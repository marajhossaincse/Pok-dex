import Testing
@testable import PokeDex

@MainActor
@Suite("PokemonDetailViewModel")
struct PokemonDetailViewModelTests {
    @Test("loadDetail populates detail on success")
    func loadDetailSuccess() async {
        let mockRepo = MockPokemonRepository()
        mockRepo.detailResult = .stub(name: "bulbasaur", types: ["grass", "poison"])

        let vm = PokemonDetailViewModel(pokemonName: "bulbasaur", repository: mockRepo)
        await vm.loadDetail()

        #expect(vm.detail?.name == "bulbasaur")
        #expect(vm.detail?.types == ["grass", "poison"])
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }

    @Test("loadDetail sets errorMessage and leaves detail nil on failure")
    func loadDetailFailure() async {
        let mockRepo = MockPokemonRepository()
        mockRepo.errorToThrow = APIError.invalidResponse

        let vm = PokemonDetailViewModel(pokemonName: "bulbasaur", repository: mockRepo)
        await vm.loadDetail()

        #expect(vm.detail == nil)
        #expect(vm.errorMessage != nil)
        #expect(vm.isLoading == false)
    }

    @Test("loadDetail calls repository with the correct pokemon name")
    func passesCorrectNameToRepository() async {
        let mockRepo = MockPokemonRepository()
        let vm = PokemonDetailViewModel(pokemonName: "pikachu", repository: mockRepo)
        await vm.loadDetail()

        #expect(mockRepo.lastFetchDetailName == "pikachu")
        #expect(mockRepo.fetchDetailCallCount == 1)
    }

    @Test("Calling loadDetail while already loading does not start a second fetch")
    func doesNotFetchWhileLoading() async {
        let mockRepo = MockPokemonRepository()
        let vm = PokemonDetailViewModel(pokemonName: "bulbasaur", repository: mockRepo)

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await vm.loadDetail() }
            group.addTask { await vm.loadDetail() }
        }

        #expect(mockRepo.fetchDetailCallCount == 1)
    }

    @Test("loadDetail clears a previous errorMessage before retrying")
    func clearsErrorOnRetry() async {
        let mockRepo = MockPokemonRepository()
        mockRepo.errorToThrow = APIError.invalidResponse

        let vm = PokemonDetailViewModel(pokemonName: "bulbasaur", repository: mockRepo)
        await vm.loadDetail()
        #expect(vm.errorMessage != nil)

        mockRepo.errorToThrow = nil
        await vm.loadDetail()
        #expect(vm.errorMessage == nil)
        #expect(vm.detail != nil)
    }
}

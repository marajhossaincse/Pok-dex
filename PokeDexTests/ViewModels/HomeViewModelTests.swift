import Testing
@testable import PokeDex

@MainActor
@Suite("HomeViewModel")
struct HomeViewModelTests {
    @Test("loadInitial populates pokemons on success")
    func loadInitialSuccess() async {
        let mockRepo = MockPokemonRepository()
        mockRepo.result = TestFixtures.makeListModel()

        let vm = HomeViewModel(repository: mockRepo)
        await vm.loadInitial()

        #expect(vm.pokemons.count == 1)
        #expect(vm.pokemons[0].name == "bulbasaur")
        #expect(vm.isLoading == false)
        #expect(vm.errorMessage == nil)
    }

    @Test("loadInitial sets errorMessage and leaves list empty on failure")
    func loadInitialFailure() async {
        let mockRepo = MockPokemonRepository()
        mockRepo.errorToThrow = APIError.invalidResponse

        let vm = HomeViewModel(repository: mockRepo)
        await vm.loadInitial()

        #expect(vm.pokemons.isEmpty)
        #expect(vm.errorMessage != nil)
        #expect(vm.isLoading == false)
    }

    @Test("loadMore appends new pokemons to the existing list")
    func loadMoreAppends() async {
        let mockRepo = MockPokemonRepository()
        mockRepo.result = TestFixtures.makeListModel(hasMore: true)

        let vm = HomeViewModel(repository: mockRepo)
        await vm.loadInitial()

        mockRepo.result = PokemonListModel(
            pokemons: [TestFixtures.makePokemonModel(id: "2", name: "ivysaur")],
            hasMore: false
        )
        await vm.loadMore()

        #expect(vm.pokemons.count == 2)
        #expect(vm.pokemons[1].name == "ivysaur")
    }

    @Test("loadMore does not fetch when the last page has been reached")
    func loadMoreSkipsWhenNoMore() async {
        let mockRepo = MockPokemonRepository()
        mockRepo.result = TestFixtures.makeListModel(hasMore: false)

        let vm = HomeViewModel(repository: mockRepo)
        await vm.loadInitial()

        #expect(mockRepo.fetchCallCount == 1)
        await vm.loadMore()
        #expect(mockRepo.fetchCallCount == 1)
    }

    @Test("loadInitial sends offset=0 and the configured limit")
    func loadInitialPassesCorrectPagination() async {
        let mockRepo = MockPokemonRepository()
        mockRepo.result = TestFixtures.makeListModel()

        let vm = HomeViewModel(repository: mockRepo)
        await vm.loadInitial()

        #expect(mockRepo.lastFetchOffset == 0)
        #expect(mockRepo.lastFetchLimit == 20)
    }

    @Test("loadMore sends the next page offset after the initial fetch")
    func loadMoreIncrementsOffset() async {
        let mockRepo = MockPokemonRepository()
        mockRepo.result = TestFixtures.makeListModel(hasMore: true)

        let vm = HomeViewModel(repository: mockRepo)
        await vm.loadInitial()
        await vm.loadMore()

        #expect(mockRepo.lastFetchOffset == 20)
    }

    @Test("Calling loadInitial again resets the list to the new result")
    func loadInitialResetsExistingList() async {
        let mockRepo = MockPokemonRepository()
        mockRepo.result = TestFixtures.makeListModel()

        let vm = HomeViewModel(repository: mockRepo)
        await vm.loadInitial()
        #expect(vm.pokemons.count == 1)

        mockRepo.result = PokemonListModel(
            pokemons: [TestFixtures.makePokemonModel(id: "2", name: "ivysaur")],
            hasMore: false
        )
        await vm.loadInitial()

        #expect(vm.pokemons.count == 1)
        #expect(vm.pokemons[0].name == "ivysaur")
    }

    @Test("loadMore error does not wipe the existing pokemon list")
    func loadMoreErrorPreservesExistingList() async {
        let mockRepo = MockPokemonRepository()
        mockRepo.result = TestFixtures.makeListModel(hasMore: true)

        let vm = HomeViewModel(repository: mockRepo)
        await vm.loadInitial()

        mockRepo.errorToThrow = APIError.invalidResponse
        await vm.loadMore()

        #expect(vm.pokemons.count == 1)
        #expect(vm.isLoadingMore == false)
    }
}

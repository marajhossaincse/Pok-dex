//
//  PokemonViewModel.swift
//  PokeDex
//
//  Created by Maraj Hossain on 5/6/24.
//

import Foundation

class PokemonViewModel: ObservableObject {
    @Published var pokemons: [Pokemon] = []

    func fetchPokemonsFromMock(completion: @escaping () -> Void) {
        guard let path = Bundle.main.path(forResource: "PokemonMockData", ofType: "json") else {
            print("Failed to load mock data.")
            return
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()

            let pokemonList = try decoder.decode(PokemonReponse.self, from: data)

            self.pokemons = pokemonList.results
            completion()
        } catch {
            print("Error loading mock data: \(error.localizedDescription)")
        }
    }
}

// class PokemonViewModel {
//    var pokemons: [Pokemon] = []
//
//    func fetchPokemons(completion: @escaping () -> Void) {
//        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/") else {
//            print("Invalid URL")
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data else {
//                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            do {
//                let decoder = JSONDecoder()
//                let pokemonList = try decoder.decode(PokemonResponse.self, from: data)
//                self.pokemons = pokemonList.results
//                DispatchQueue.main.async {
//                    completion()
//                }
//            } catch {
//                print("Error decoding JSON: \(error.localizedDescription)")
//            }
//        }.resume()
//    }
// }

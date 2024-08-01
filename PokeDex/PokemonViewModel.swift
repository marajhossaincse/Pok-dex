//
//  PokemonViewModel.swift
//  PokeDex
//
//  Created by Maraj Hossain on 5/6/24.
//

import Foundation

class PokemonViewModel: ObservableObject {
    @Published var pokemons: [Pokemon] = []

    func fetchPokemons(completion: @escaping () -> Void) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let decoder = JSONDecoder()
                let pokemonList = try decoder.decode(PokemonReponse.self, from: data)
                self.pokemons = pokemonList.results
                print(self.pokemons)
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}

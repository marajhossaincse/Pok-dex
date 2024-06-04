//
//  HomeView.swift
//  PokèDex
//
//  Created by Maraj Hossain on 5/6/24.
//

import SwiftUI

struct HomeView: View {
    let pokemons: [Pokemon] = [
        Pokemon(name: "Pokemon 1", url: ""),
        Pokemon(name: "Pokemon 2", url: ""),
        Pokemon(name: "Pokemon 3", url: "")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(pokemons, id: \.self) { pokemon in
                    NavigationLink {
                        PokemonDetailsScreen()
                    } label: {
                        Text(pokemon.name)
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

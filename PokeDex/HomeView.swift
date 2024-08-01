//
//  HomeView.swift
//  PokèDex
//
//  Created by Maraj Hossain on 5/6/24.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel = PokemonViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(viewModel.pokemons, id: \.self) { pokemon in
                    NavigationLink {
                        PokemonDetailsScreen()
                    } label: {
                        HStack {
                            Text(pokemon.name.capitalized)
                            Spacer()
                                //                            Image(pokemon.url)
                                //                                .resizable()
                                //                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchPokemons(completion: {})
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}

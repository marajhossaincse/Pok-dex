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
                VStack {
                    ForEach(viewModel.pokemons, id: \.self) { pokemon in
                        NavigationLink {
                            PokemonDetailsScreen()
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(Color.gray, lineWidth: 2)
                                    )

                                Text(pokemon.name.capitalized)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationTitle("Pokèmon")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.fetchPokemons(completion: {})
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

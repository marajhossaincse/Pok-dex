//
//  HomeView.swift
//  PokèDex
//
//  Created by Maraj Hossain on 5/6/24.
//

import SwiftUI

struct HomeView: View {
    
    let pokemons: [Result] = []
    
    var body: some View {
        ScrollView{
            ForEach(pokemons, id: \.self){ pokemon in
                Text(pokemon.name)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

//
//  PokemonDetailsScreen.swift
//  PokèDex
//
//  Created by Maraj Hossain on 5/6/24.
//

import SwiftUI

struct PokemonDetailsScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(.red)
                    .frame(height: 250)
                    .overlay {
                        #warning("Replace shape with Image")
                        Circle()
                            .fill(Color.blue)
                            .frame(
                                width: 250,
                                height: 200)
                            .offset(y: 125)
                    }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("Pokemon Name")
    }
}

struct PokemonDetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PokemonDetailsScreen()
        }
    }
}

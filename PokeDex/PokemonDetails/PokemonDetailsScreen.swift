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
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(height: 200)
                        .overlay {
                            #warning("Replace shape with Image")
                            Circle()
                                .fill(Color.black.opacity(0.5))
                                .frame(
                                    width: 150,
                                    height: 150
                                )
                                .offset(y: 100)
                        }
                    Spacer()
                }
                .frame(height: 300)
                
                HStack(spacing: 0) {
                    Text("Type 1")
                        .padding()
                        .frame(width: 150, height: 45)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.gray)
                        )
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        
                    Text("Type 2")
                        .padding()
                        .frame(width: 150, height: 45)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.gray)
                        )
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Text("Fire")
                            .font(.title)
                            .foregroundColor(Color.gray)
                            
                        Text("Genre")
                            .font(.caption2)
                            .foregroundColor(Color.black.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom)
                    
                    Divider()
                        .background(Color.gray)
                    
                    VStack(spacing: 0) {
                        Text("5'9\"")
                            .font(.title)
                            .foregroundColor(Color.gray)
                            
                        Text("Height")
                            .font(.caption2)
                            .foregroundColor(Color.black.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom)
                        
                    Divider()
                        .background(Color.gray)
                    
                    VStack(spacing: 0) {
                        Text("59 lbs")
                            .font(.title)
                            .foregroundColor(Color.gray)
                            
                        Text("Weight")
                            .font(.caption2)
                            .foregroundColor(Color.black.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom)
                }
                .padding(.vertical, 16)
                
                Text("Evolution")
                    .foregroundColor(Color.gray)
                    .font(.system(.title, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    
                HStack {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 70, height: 70)
                        
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 70, height: 70)
                        
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 70, height: 70)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("Pokemon Name")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PokemonDetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PokemonDetailsScreen()
        }
    }
}

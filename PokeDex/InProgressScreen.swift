//
//  InProgressScreen.swift
//  PokeDex
//
//  Created by Maraj Hossain on 2/8/24.
//

import SwiftUI

struct InProgressScreen: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hourglass")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .padding()

            Text("In Progress")
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
    }
}

struct InProgressScreen_Previews: PreviewProvider {
    static var previews: some View {
        InProgressScreen()
    }
}

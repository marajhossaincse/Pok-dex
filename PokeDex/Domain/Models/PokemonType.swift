import SwiftUI

enum PokemonType: String, CaseIterable, Identifiable {
    case normal, fire, water, grass, electric, ice, fighting, poison,
         ground, flying, psychic, bug, rock, ghost, dragon, dark, steel, fairy

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    var color: Color {
        switch self {
        case .normal:   return Color(red: 0.66, green: 0.65, blue: 0.48)
        case .fire:     return Color(red: 0.96, green: 0.55, blue: 0.23)
        case .water:    return Color(red: 0.39, green: 0.56, blue: 0.95)
        case .grass:    return Color(red: 0.49, green: 0.74, blue: 0.31)
        case .electric: return Color(red: 0.98, green: 0.82, blue: 0.22)
        case .ice:      return Color(red: 0.60, green: 0.85, blue: 0.87)
        case .fighting: return Color(red: 0.75, green: 0.19, blue: 0.17)
        case .poison:   return Color(red: 0.63, green: 0.25, blue: 0.63)
        case .ground:   return Color(red: 0.89, green: 0.75, blue: 0.41)
        case .flying:   return Color(red: 0.67, green: 0.56, blue: 0.94)
        case .psychic:  return Color(red: 0.97, green: 0.35, blue: 0.53)
        case .bug:      return Color(red: 0.65, green: 0.72, blue: 0.11)
        case .rock:     return Color(red: 0.71, green: 0.63, blue: 0.22)
        case .ghost:    return Color(red: 0.44, green: 0.35, blue: 0.59)
        case .dragon:   return Color(red: 0.44, green: 0.22, blue: 0.96)
        case .dark:     return Color(red: 0.44, green: 0.34, blue: 0.27)
        case .steel:    return Color(red: 0.72, green: 0.72, blue: 0.82)
        case .fairy:    return Color(red: 0.99, green: 0.64, blue: 0.77)
        }
    }
}

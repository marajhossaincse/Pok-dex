import SwiftUI

@MainActor
struct PokemonDetailView: View {
    let pokemon: PokemonModel
    @StateObject private var viewModel: PokemonDetailViewModel

    init(pokemon: PokemonModel) {
        self.pokemon = pokemon
        _viewModel = StateObject(wrappedValue: PokemonDetailViewModel(
            pokemonName: pokemon.name,
            repository: PokemonRepository(apiClient: APIClient())
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                artworkHeader
                infoSection
            }
        }
        .navigationTitle(pokemon.name.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadDetail() }
    }

    // MARK: - Artwork Header

    private var artworkHeader: some View {
        ZStack {
            headerBackground
            AsyncImage(url: URL(string: pokemon.spriteURL)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFit()
                case .failure:
                    Image(systemName: "photo.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.secondary)
                case .empty:
                    ProgressView().scaleEffect(1.5)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 240, height: 240)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
    }

    private var headerBackground: some View {
        Group {
            if let firstType = viewModel.detail?.types.first {
                typeColor(firstType).opacity(0.25)
            } else {
                Color(.systemIndigo).opacity(0.1)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: viewModel.detail?.types.first)
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            nameHeader

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if let detail = viewModel.detail {
                detailContent(detail)
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 40)
    }

    private var nameHeader: some View {
        VStack(spacing: 4) {
            Text(formattedID)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(pokemon.name.capitalized)
                .font(.system(size: 34, weight: .bold))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Detail Content

    @ViewBuilder
    private func detailContent(_ detail: PokemonDetailModel) -> some View {
        typesSection(detail.types)
        measurementsSection(detail)
        abilitiesSection(detail.abilities)
        statsSection(detail.stats)
    }

    // MARK: - Types

    private func typesSection(_ types: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Type")
            HStack(spacing: 8) {
                ForEach(types, id: \.self) { typeName in
                    Text(typeName.capitalized)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16).padding(.vertical, 6)
                        .background(typeColor(typeName))
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Measurements

    private func measurementsSection(_ detail: PokemonDetailModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Size")
            HStack(spacing: 12) {
                measureCard(
                    label: "Height",
                    value: String(format: "%.1f m", Double(detail.height) / 10)
                )
                measureCard(
                    label: "Weight",
                    value: String(format: "%.1f kg", Double(detail.weight) / 10)
                )
            }
        }
    }

    private func measureCard(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption).foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Abilities

    private func abilitiesSection(_ abilities: [PokemonAbility]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Abilities")
            HStack(spacing: 8) {
                ForEach(abilities, id: \.name) { ability in
                    VStack(spacing: 2) {
                        Text(ability.name
                            .replacingOccurrences(of: "-", with: " ")
                            .capitalized)
                            .font(.subheadline).fontWeight(.medium)
                        if ability.isHidden {
                            Text("Hidden")
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    // MARK: - Stats

    private func statsSection(_ stats: [PokemonStat]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Base Stats")
            ForEach(stats, id: \.name) { stat in
                HStack(spacing: 12) {
                    Text(statLabel(stat.name))
                        .font(.subheadline).foregroundStyle(.secondary)
                        .frame(width: 72, alignment: .leading)
                    Text("\(stat.value)")
                        .font(.subheadline).fontWeight(.semibold)
                        .frame(width: 32, alignment: .trailing)
                    ProgressView(value: Double(stat.value), total: 255)
                        .tint(statColor(stat.value))
                }
            }
        }
    }

    // MARK: - Error

    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle).foregroundStyle(.orange)
            Text(message)
                .font(.caption).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") { Task { await viewModel.loadDetail() } }
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title3).fontWeight(.bold)
    }

    private var formattedID: String {
        guard let n = Int(pokemon.id) else { return "#\(pokemon.id)" }
        return String(format: "#%04d", n)
    }

    private func statLabel(_ name: String) -> String {
        switch name {
        case "hp":              return "HP"
        case "attack":          return "Atk"
        case "defense":         return "Def"
        case "special-attack":  return "Sp. Atk"
        case "special-defense": return "Sp. Def"
        case "speed":           return "Speed"
        default:                return name.capitalized
        }
    }

    private func statColor(_ value: Int) -> Color {
        switch value {
        case 0..<50:   return .red
        case 50..<80:  return .orange
        case 80..<100: return .yellow
        default:       return .green
        }
    }

    private func typeColor(_ type: String) -> Color {
        switch type.lowercased() {
        case "fire":     return .orange
        case "water":    return .blue
        case "grass":    return .green
        case "electric": return .yellow
        case "psychic":  return .pink
        case "ice":      return Color(red: 0.6, green: 0.85, blue: 0.9)
        case "dragon":   return .indigo
        case "dark":     return Color(red: 0.3, green: 0.25, blue: 0.2)
        case "fairy":    return Color(red: 0.95, green: 0.55, blue: 0.75)
        case "fighting": return Color(red: 0.75, green: 0.2, blue: 0.2)
        case "poison":   return .purple
        case "ground":   return Color(red: 0.85, green: 0.7, blue: 0.4)
        case "rock":     return Color(red: 0.7, green: 0.6, blue: 0.35)
        case "bug":      return Color(red: 0.6, green: 0.7, blue: 0.1)
        case "ghost":    return Color(red: 0.45, green: 0.35, blue: 0.6)
        case "steel":    return Color(red: 0.7, green: 0.7, blue: 0.8)
        case "flying":   return Color(red: 0.55, green: 0.65, blue: 0.95)
        case "normal":   return Color(red: 0.65, green: 0.65, blue: 0.5)
        default:         return .gray
        }
    }
}

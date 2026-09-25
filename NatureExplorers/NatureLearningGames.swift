import SwiftUI

/// Shared presentation for nature pieces; actions stay in each activity's own state machine.
struct NaturePictureButton: View {
    let title: String
    var asset: String? = nil
    var symbol: String = "leaf.fill"
    var selected = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ToddlerArt(asset: asset, symbol: symbol, size: 78)
                Text(title).font(.system(.headline, design: .rounded)).multilineTextAlignment(.center)
            }
            .foregroundStyle(Color(red: 0.13, green: 0.21, blue: 0.27))
            .frame(maxWidth: .infinity, minHeight: 128)
            .padding(10)
            .background(selected ? Color.teal.opacity(0.16) : Color.white, in: RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(selected ? Color.teal : Color.teal.opacity(0.18), lineWidth: selected ? 4 : 2))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

struct NatureGameDestination: View {
    let activity: NatureActivity
    @ViewBuilder var body: some View {
        switch activity {
        case .habitats: HabitatHelpersGame()
        case .tracks: DinosaurTrailGame()
        case .moon: MoonMissionGame()
        case .families: AnimalFamilyGame()
        case .barn: NatureBarnGame()
        case .garden: LittleGardenGame()
        case .cleanup: OceanHelpersGame()
        case .weather: WeatherWindowGame()
        case .movement: AnimalMovementGame()
        case .dayNight: DayNightGame()
        case .clues: NatureDetectiveGame()
        case .nest: CozyNestGame()
        }
    }
}

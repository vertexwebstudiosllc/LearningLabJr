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

struct NatureDetectiveGame: View {
    private let mysteries = [
        ("octopus", "Octopus", ["I live in the ocean.", "I have eight arms."], ["cow", "octopus", "rabbit"]),
        ("rabbit", "Rabbit", ["I have soft fur.", "I have long ears and hop."], ["rabbit", "dolphin", "chicken"]),
        ("chicken", "Chicken", ["I have feathers.", "I cluck and lay eggs."], ["horse", "chicken", "octopus"])
    ]
    @State private var round = 0
    @State private var clue = 0
    @State private var solved = false
    @StateObject private var narrator = GameNarrator()
    private var complete: Bool { round >= mysteries.count }

    var body: some View {
        ToddlerGameScaffold(title: "Nature Detective", prompt: complete ? "You noticed so many animal clues!" : solved ? "You found the \(mysteries[round].1.lowercased())!" : mysteries[round].2.prefix(clue + 1).joined(separator: " "), completion: complete, onReplay: { round = 0; clue = 0; solved = false }) {
            if !complete {
                if solved {
                    ToddlerArt(asset: mysteries[round].0, size: 150)
                    ToddlerActionButton(title: round == 2 ? "Finish exploring" : "Another mystery", systemImage: "arrow.right") {
                        guard solved, !complete else { return }
                        round += 1; clue = 0; solved = false
                    }
                } else {
                    ToddlerActionButton(title: clue == 0 ? "Another clue" : "Hear the clues again", systemImage: "ear.fill") {
                        guard !complete, !solved else { return }
                        if clue == 0 { clue = 1 }
                        else { narrator.speak(mysteries[round].2.joined(separator: " ")) }
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 128))], spacing: 14) {
                        ForEach(mysteries[round].3, id: \.self) { asset in
                            NaturePictureButton(title: asset.capitalized, asset: asset) {
                                guard !complete, !solved else { return }
                                if asset == mysteries[round].0 { solved = true }
                                else if clue == 0 { clue = 1 }
                                else { narrator.speak("Let’s listen to the clues again. \(mysteries[round].2.joined(separator: " "))") }
                            }
                        }
                    }
                }
            }
        }.onDisappear { narrator.stop() }
    }
}

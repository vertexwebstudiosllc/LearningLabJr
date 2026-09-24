import SwiftUI

enum AnimalHabitat: String, CaseIterable {
    case ocean, farm, garden, trees, rainforest, pond
    var title: String { rawValue.capitalized }
    var picture: String {
        switch self {
        case .ocean: "🌊"
        case .farm: "🏡"
        case .garden: "🌷"
        case .trees: "🌳"
        case .rainforest: "🌴"
        case .pond: "🪷"
        }
    }
}

struct HabitatAnimal: Identifiable {
    let id: String
    let habitat: AnimalHabitat
    let asset: String?
    let emoji: String
    var name: String { id.capitalized }
    var prompt: String { "Where can the \(id) live? Choose its home." }
    var hint: String {
        "Let's try the \(habitat.rawValue) for the \(id)."
    }
    static let bank: [Self] = [
        .init(id: "dolphin", habitat: .ocean, asset: "dolphin", emoji: "🐬"),
        .init(id: "octopus", habitat: .ocean, asset: "octopus", emoji: "🐙"),
        .init(id: "shark", habitat: .ocean, asset: "shark", emoji: "🦈"),
        .init(id: "seahorse", habitat: .ocean, asset: "seahorse", emoji: ""),
        .init(id: "cow", habitat: .farm, asset: "cow", emoji: "🐄"),
        .init(id: "sheep", habitat: .farm, asset: "sheep", emoji: "🐑"),
        .init(id: "horse", habitat: .farm, asset: "horse", emoji: "🐎"),
        .init(id: "pig", habitat: .farm, asset: "pig", emoji: "🐖"),
        .init(id: "bee", habitat: .garden, asset: nil, emoji: "🐝"),
        .init(id: "butterfly", habitat: .garden, asset: nil, emoji: "🦋"),
        .init(id: "ladybug", habitat: .garden, asset: nil, emoji: "🐞"),
        .init(id: "ant", habitat: .garden, asset: nil, emoji: "🐜"),
        .init(id: "owl", habitat: .trees, asset: nil, emoji: "🦉"),
        .init(id: "eagle", habitat: .trees, asset: nil, emoji: "🦅"),
        .init(id: "bluebird", habitat: .trees, asset: nil, emoji: "🐦"),
        .init(id: "squirrel", habitat: .trees, asset: nil, emoji: "🐿️"),
        .init(id: "gorilla", habitat: .rainforest, asset: nil, emoji: "🦍"),
        .init(id: "orangutan", habitat: .rainforest, asset: nil, emoji: "🦧"),
        .init(id: "tiger", habitat: .rainforest, asset: nil, emoji: "🐅"),
        .init(id: "sloth", habitat: .rainforest, asset: nil, emoji: "🦥"),
        .init(id: "frog", habitat: .pond, asset: nil, emoji: "🐸"),
        .init(id: "duck", habitat: .pond, asset: "duck", emoji: "🦆"),
        .init(id: "goose", habitat: .pond, asset: "goose", emoji: "🪿"),
        .init(id: "turtle", habitat: .pond, asset: nil, emoji: "🐢")
    ]
}

struct HabitatRound {
    let homes: [AnimalHabitat]
    var animals: [HabitatAnimal]
}

struct HabitatSession {
    let rounds: [HabitatRound]
    private(set) var index = 0
    private(set) var matched: Set<String> = []
    private(set) var selected: String?
    var current: HabitatRound { rounds[min(index, rounds.count - 1)] }
    var animal: HabitatAnimal? { current.animals.first { $0.id == selected } }
    var solved: Bool { matched.count == 4 }
    var complete: Bool { index == rounds.count }
    static let groupPrompt = "Four animals found their homes! Let's meet some new friends."
    static let completion = "You helped every animal find a home!"
    var prompt: String { complete ? Self.completion : solved ? Self.groupPrompt : animal?.prompt ?? "Choose an animal. Then choose its home." }

    init(previousFirst: String? = nil) {
        // Avoid misleading choices: ducks also visit farms, and tree-dwelling
        // rainforest animals should not be asked to choose between trees and jungle.
        func compatible(_ a: AnimalHabitat, _ b: AnimalHabitat) -> Bool {
            let pair: Set<AnimalHabitat> = [a, b]
            return ![Set([AnimalHabitat.trees, .rainforest]), Set([.farm, .pond]),
                     Set([.garden, .trees]), Set([.garden, .rainforest]), Set([.garden, .pond])].contains(pair)
        }
        func ring(_ path: [AnimalHabitat], remaining: [AnimalHabitat]) -> [AnimalHabitat]? {
            if remaining.isEmpty { return compatible(path.last!, path.first!) ? path : nil }
            for home in remaining.shuffled() where path.last.map({ compatible($0, home) }) ?? true {
                if let result = ring(path + [home], remaining: remaining.filter { $0 != home }) { return result }
            }
            return nil
        }
        let habitats = ring([], remaining: AnimalHabitat.allCases)!
        var pools = Dictionary(uniqueKeysWithValues: habitats.map { home in
            (home, HabitatAnimal.bank.filter { $0.habitat == home }.shuffled())
        })
        var result: [HabitatRound] = []
        // A shuffled ring visits each home twice, with a different partner each time.
        for i in habitats.indices {
            let homes = [habitats[i], habitats[(i + 1) % habitats.count]].shuffled()
            var animals: [HabitatAnimal] = []
            for home in homes {
                animals += pools[home]!.prefix(2)
                pools[home]!.removeFirst(2)
            }
            result.append(HabitatRound(homes: homes, animals: animals.shuffled()))
        }
        result.shuffle()
        if result[0].animals[0].id == previousFirst { result[0].animals.swapAt(0, 1) }
        rounds = result
        selected = result[0].animals[0].id
    }
    mutating func select(_ id: String) {
        guard !complete, !matched.contains(id), current.animals.contains(where: { $0.id == id }) else { return }
        selected = id
    }
    @discardableResult mutating func place(in home: AnimalHabitat) -> Bool {
        guard !complete, !solved, let animal, current.homes.contains(home), animal.habitat == home else { return false }
        matched.insert(animal.id)
        selected = current.animals.first { !matched.contains($0.id) }?.id
        return true
    }
    mutating func next() {
        guard !complete, solved else { return }
        index += 1
        if !complete { matched = []; selected = current.animals[0].id }
    }
}

struct HabitatHelpersGame: View {
    @AppStorage("nature.habitats.previousFirst") private var previousFirst = ""
    @State private var play = HabitatSession()
    @State private var started = false
    @State private var feedback = ""
    @StateObject private var narrator = GameNarrator()

    var body: some View {
        ToddlerGameScaffold(title: "Habitat Helpers", prompt: play.prompt, completion: play.complete, onReplay: restart) {
            if !play.complete {
                Text("Set \(play.index + 1) of \(play.rounds.count) · \(play.matched.count) of 4 at home")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .accessibilityIdentifier("habitats.progress")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(play.current.animals) { animal in
                        Button {
                            play.select(animal.id); feedback = ""
                        } label: {
                            VStack(spacing: 3) {
                                if let asset = animal.asset {
                                    ToddlerArt(asset: asset, size: 64)
                                } else {
                                    Text(animal.emoji).font(.system(size: 52)).frame(height: 64)
                                }
                                Text(animal.name).font(.system(.headline, design: .rounded))
                                if play.matched.contains(animal.id) {
                                    Label("At home", systemImage: "checkmark.circle.fill").font(.caption)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 106)
                            .background(play.selected == animal.id ? Color.teal.opacity(0.15) : .white, in: RoundedRectangle(cornerRadius: 20))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(play.selected == animal.id ? .teal : .teal.opacity(0.2), lineWidth: play.selected == animal.id ? 4 : 2))
                        }
                        .buttonStyle(.plain)
                        .disabled(play.matched.contains(animal.id))
                        .accessibilityLabel("\(animal.name)\(play.matched.contains(animal.id) ? ", at home" : "")")
                        .accessibilityValue(play.selected == animal.id ? "Selected" : "")
                        .accessibilityIdentifier("habitats.animal.\(animal.id)")
                    }
                }
                HStack(spacing: 12) {
                    ForEach(play.current.homes, id: \.self) { home in
                        Button {
                            let hint = play.animal?.hint
                            if play.place(in: home) { feedback = "" }
                            else if let hint { feedback = hint; narrator.speak(hint) }
                        } label: {
                            VStack(spacing: 4) {
                                Text(home.picture).font(.system(size: 44))
                                Text(home.title).font(.system(.headline, design: .rounded))
                            }
                            .frame(maxWidth: .infinity, minHeight: 94)
                            .background(.teal.opacity(0.12), in: RoundedRectangle(cornerRadius: 22))
                        }
                        .buttonStyle(.plain).disabled(play.solved)
                        .accessibilityLabel(home.title)
                        .accessibilityIdentifier("habitats.home.\(home.rawValue)")
                    }
                }
                if !feedback.isEmpty { Text(feedback).font(.headline).multilineTextAlignment(.center) }
                if play.solved {
                    ToddlerActionButton(title: play.index == play.rounds.count - 1 ? "Finish exploring" : "More animals", systemImage: "arrow.right") { play.next() }
                        .accessibilityIdentifier("habitats.next")
                }
            }
        }
        .onAppear { if !started { restart(); started = true } }
        .onDisappear { narrator.stop() }
    }
    private func restart() {
        narrator.stop()
        play = HabitatSession(previousFirst: previousFirst)
        previousFirst = play.rounds[0].animals[0].id
        feedback = ""
    }
}

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
        .init(id: "dolphin", habitat: .ocean, asset: "dolphinClean", emoji: "🐬"),
        .init(id: "octopus", habitat: .ocean, asset: nil, emoji: "🐙"),
        .init(id: "shark", habitat: .ocean, asset: "OceanClean/shark", emoji: "🦈"),
        .init(id: "seahorse", habitat: .ocean, asset: "OceanClean/seahorse", emoji: ""),
        .init(id: "cow", habitat: .farm, asset: "FamilyClean/cow", emoji: "🐄"),
        .init(id: "sheep", habitat: .farm, asset: "FamilyClean/sheep", emoji: "🐑"),
        .init(id: "horse", habitat: .farm, asset: "FamilyClean/horse", emoji: "🐎"),
        .init(id: "pig", habitat: .farm, asset: "BarnClean/pig", emoji: "🐖"),
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
        .init(id: "duck", habitat: .pond, asset: "BarnClean/duck", emoji: "🦆"),
        .init(id: "goose", habitat: .pond, asset: nil, emoji: "🪿"),
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
    var current: HabitatRound { rounds[min(index, rounds.count - 1)] }
    var animal: HabitatAnimal? { complete ? nil : current.animals.first { !matched.contains($0.id) } }
    var solved: Bool { matched.count == current.animals.count }
    var complete: Bool { index == rounds.count }
    static let groupPrompt = "Four animals found their homes! Let's meet some new friends."
    static let completion = "You helped every animal find a home!"
    var prompt: String { complete ? Self.completion : animal?.prompt ?? Self.groupPrompt }

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
    }
    @discardableResult mutating func place(_ animalID: String, in home: AnimalHabitat) -> Bool {
        // Bind answers to the animal shown when the button was rendered. A stale
        // tap must never place the next animal, even when it shares the same home.
        guard !complete, !solved, let animal, animal.id == animalID,
              current.homes.contains(home), animal.habitat == home else { return false }
        matched.insert(animal.id)
        return true
    }
    mutating func next() {
        guard !complete, solved else { return }
        index += 1
        if !complete { matched = [] }
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
            HabitatPlayArea(play: play, feedback: feedback, onPlace: place) {
                narrator.stop(); feedback = ""; play.next()
            }
        }
        .onAppear { if !started { restart(); started = true } }
        .onDisappear { narrator.stop() }
    }

    private func place(_ animal: HabitatAnimal, in home: AnimalHabitat) {
        guard play.animal?.id == animal.id else { return }
        if play.place(animal.id, in: home) { narrator.stop(); feedback = "" }
        else { feedback = animal.hint; narrator.speak(animal.hint) }
    }

    private func restart() {
        narrator.stop()
        play = HabitatSession(previousFirst: previousFirst)
        previousFirst = play.rounds[0].animals[0].id
        feedback = ""
    }
}

/// The landscape row keeps the one animal and both answers inside the right-hand viewport.
private struct HabitatPlayArea: View {
    let play: HabitatSession
    let feedback: String
    let onPlace: (HabitatAnimal, AnimalHabitat) -> Void
    let onNext: () -> Void
    @Environment(\.gameViewportSize) private var viewport
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var compact: Bool { viewport != nil }
    private var animalSize: CGFloat {
        guard let viewport else { return verticalSizeClass == .compact ? 92 : 128 }
        // Progress, feedback, text labels and padding always retain their own space.
        let cardWidth = min(180, viewport.width * 0.36)
        return min(128, max(44, viewport.height - 134), max(44, cardWidth - 16))
    }

    var body: some View {
        if !play.complete {
            VStack(spacing: compact ? 6 : 18) {
                Text("Set \(play.index + 1) of \(play.rounds.count) · \(play.matched.count) of 4 at home")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .accessibilityIdentifier("habitats.progress")
                    .frame(height: compact ? 22 : nil)
                if let animal = play.animal {
                    if let viewport {
                        HStack(spacing: 12) {
                            animalCard(animal)
                                .frame(width: min(180, viewport.width * 0.36))
                            homeChoices(for: animal)
                        }
                    } else {
                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: 16) {
                                animalCard(animal).frame(minWidth: 160)
                                homeChoices(for: animal).frame(minWidth: 236)
                            }
                            VStack(spacing: 16) {
                                animalCard(animal)
                                homeChoices(for: animal)
                            }
                        }
                    }
                    if compact {
                        Group {
                            if feedback.isEmpty { Color.clear }
                            else { feedbackText }
                        }
                        .frame(height: 36)
                    } else if !feedback.isEmpty { feedbackText }
                }
                if play.solved {
                    Label("Four happy animals at home!", systemImage: "checkmark.circle.fill")
                        .font(.system(compact ? .headline : .title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.teal)
                        .multilineTextAlignment(.center)
                    nextButton
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var feedbackText: some View {
        Text(feedback)
            .font(compact ? .subheadline : .headline)
            .multilineTextAlignment(.center)
            .lineLimit(compact ? 2 : nil)
            .minimumScaleFactor(0.85)
            .accessibilityIdentifier("habitats.feedback")
    }

    private var nextButton: some View {
        Button(action: onNext) {
            Label(play.index == play.rounds.count - 1 ? "Finish exploring" : "More animals", systemImage: "arrow.right")
                .font(.system(compact ? .headline : .title3, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity, minHeight: compact ? 44 : 64)
                .padding(.horizontal, 10)
                .background(.teal.opacity(0.19), in: RoundedRectangle(cornerRadius: 18))
                .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("habitats.next")
    }

    private func animalCard(_ animal: HabitatAnimal) -> some View {
        VStack(spacing: compact ? 4 : 8) {
            Text("Animal \(play.matched.count + 1) of \(play.current.animals.count)")
                .font(.system(compact ? .caption : .subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.secondary)
            if let asset = animal.asset {
                ToddlerArt(asset: asset, size: animalSize)
            } else {
                Text(animal.emoji)
                    .font(.system(size: animalSize * 0.82))
                    .frame(height: animalSize)
            }
            Text(animal.name)
                .font(.system(compact ? .headline : .title2, design: .rounded, weight: .bold))
                .lineLimit(1).minimumScaleFactor(0.8)
        }
        .padding(compact ? 8 : 14)
        .frame(maxWidth: .infinity)
        .background(.white, in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.teal.opacity(0.35), lineWidth: 3))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(animal.name)
        .accessibilityValue("Animal \(play.matched.count + 1) of \(play.current.animals.count)")
        .accessibilityAddTraits(.isImage)
        .accessibilityIdentifier("habitats.animal.\(animal.id)")
    }

    private func homeChoices(for animal: HabitatAnimal) -> some View {
        HStack(spacing: compact ? 8 : 12) {
            ForEach(play.current.homes, id: \.self) { home in
                Button { onPlace(animal, home) } label: {
                    VStack(spacing: 6) {
                        Text(home.picture).font(.system(size: compact ? 40 : 48))
                        Text(home.title)
                            .font(.system(compact ? .subheadline : .headline, design: .rounded, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .lineLimit(compact ? 1 : nil).minimumScaleFactor(0.8)
                    }
                    .padding(compact ? 8 : 10)
                    .frame(maxWidth: .infinity, minHeight: compact ? 96 : 112)
                    .background(.teal.opacity(0.12), in: RoundedRectangle(cornerRadius: 22))
                    .contentShape(RoundedRectangle(cornerRadius: 22))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(home.title)
                .accessibilityHint("Choose this home for the \(animal.id)")
                .accessibilityIdentifier("habitats.home.\(home.rawValue)")
            }
        }
    }
}

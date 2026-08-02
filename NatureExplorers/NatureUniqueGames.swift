import SpriteKit
import SwiftUI

struct NatureGameDestination: View {
    let game: NatureExplorerGame

    @ViewBuilder var body: some View {
        switch game.kind {
        case .habitat: HabitatHelpersGame(game: game)
        case .dino: DinoExcavationGame(game: game)
        case .space: SpaceLaunchGame(game: game)
        case .families: AnimalFamilyBoardGame(game: game)
        case .size: SizeSafariGame(game: game)
        case .pattern, .memory, .clues: NatureLearningGameView(game: game)
        case .peekaboo: NatureBarnyardGameView()
        case .fossil: FossilClueGame(game: game)
        case .scene: WorldSortingGame(game: game)
        case .counting: TouchCreatureCountGame(game: game)
        case .oddOne: NatureLearningGameView(game: game)
        }
    }
}

private struct NatureBarnyardGameView: View {
    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: makeScene(size: proxy.size)).ignoresSafeArea()
        }
    }

    private func makeScene(size: CGSize) -> SKScene {
        let scene = BarnyardPeekabooScene(size: size)
        scene.scaleMode = .aspectFill
        return scene
    }
}

private struct ExplorerShell<Content: View>: View {
    let game: NatureExplorerGame
    let score: Int
    let round: Int
    @ViewBuilder let content: Content
    @Environment(\.dismiss) private var dismiss

    init(game: NatureExplorerGame, score: Int, round: Int, @ViewBuilder content: () -> Content) {
        self.game = game
        self.score = score
        self.round = round
        self.content = content()
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: game.colors, startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            Circle().fill(.white.opacity(0.08)).frame(width: 430).offset(x: 200, y: -300)
            Circle().fill(.white.opacity(0.08)).frame(width: 340).offset(x: -220, y: 360)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left").font(.headline.bold())
                                .frame(width: 44, height: 44).background(.white.opacity(0.22), in: Circle())
                        }
                        Spacer()
                        Label("\(score)", systemImage: "star.fill")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .padding(.horizontal, 15).frame(height: 44)
                            .background(.white.opacity(0.22), in: Capsule())
                    }
                    Text(game.title).font(.system(size: 31, weight: .heavy, design: .rounded)).multilineTextAlignment(.center)
                    Text("Adventure \(round) • Keep exploring!")
                        .font(.system(size: 15, weight: .bold, design: .rounded)).opacity(0.9)
                    content
                        .padding(18).frame(maxWidth: 680)
                        .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 28))
                        .overlay(RoundedRectangle(cornerRadius: 28).stroke(.white.opacity(0.25), lineWidth: 2))
                }
                .foregroundStyle(.white).padding(20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }
}

private struct ExplorerFeedback: View {
    let result: Bool?
    var success = "Great exploring!"
    var retry = "Good try—choose again!"

    var body: some View {
        Group {
            if let result {
                Label(result ? success : retry, systemImage: result ? "star.fill" : "arrow.counterclockwise")
                    .foregroundStyle(result ? Color.yellow : Color.white)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Text("Take your time. You can keep trying!").opacity(0.78)
            }
        }
        .font(.system(size: 18, weight: .heavy, design: .rounded)).multilineTextAlignment(.center)
    }
}

private struct ExplorerImageCard: View {
    let asset: NatureAsset
    var height: CGFloat = 112
    var label = true

    var body: some View {
        VStack(spacing: 4) {
            Image(asset.image).resizable().scaledToFit().frame(maxHeight: label ? height - 25 : height)
            if label { Text(asset.name).font(.system(size: 13, weight: .bold, design: .rounded)).lineLimit(1).minimumScaleFactor(0.65) }
        }
        .padding(7).frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
        .foregroundStyle(.indigo).background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.15), radius: 5, y: 3)
    }
}

private func pickAsset(from pool: [NatureAsset], excluding history: [String]) -> NatureAsset {
    pool.filter { !history.contains($0.image) }.randomElement()
        ?? pool.filter { $0.image != history.last }.randomElement()
        ?? pool.randomElement()!
}

private func appendHistory(_ image: String, to history: inout [String]) {
    history.append(image)
    if history.count > 10 { history.removeFirst(history.count - 10) }
}

// MARK: - 1. Sort one moving creature between two habitat zones

private struct HabitatHelpersGame: View {
    let game: NatureExplorerGame
    @State private var animal = NatureLibrary.farm[0]
    @State private var history: [String] = []
    @State private var result: Bool?
    @State private var score = 0
    @State private var round = 1
    @State private var hint = false

    var body: some View {
        ExplorerShell(game: game, score: score, round: round) {
            VStack(spacing: 18) {
                Text("Help \(animal.name) get home!").font(.system(size: 24, weight: .heavy, design: .rounded))
                Text("Look at the creature, then tap its habitat.").font(.headline).opacity(0.9)
                Image(animal.image).resizable().scaledToFit().frame(height: 150)
                    .padding(10).background(.white.opacity(0.9), in: Circle())

                HStack(spacing: 14) {
                    habitatButton(title: "Barnyard", icon: "house.and.flag.fill", group: "farm", colors: [.orange, .brown])
                    habitatButton(title: "Ocean", icon: "water.waves", group: "ocean", colors: [.cyan, .blue])
                }
                ExplorerFeedback(result: result, success: "You found its home!")
            }
            .task(id: animal.image) {
                hint = false
                try? await Task.sleep(for: .seconds(4))
                guard result == nil else { return }
                withAnimation(.bouncy) { hint = true }
            }
        }
        .task { newRound(initial: true) }
    }

    private func habitatButton(title: String, icon: String, group: String, colors: [Color]) -> some View {
        Button { choose(group) } label: {
            VStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 38, weight: .bold))
                Text(title).font(.system(size: 18, weight: .heavy, design: .rounded))
            }
            .frame(maxWidth: .infinity, minHeight: 105)
            .background(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom), in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white, lineWidth: hint && animal.group == group ? 5 : 0))
            .scaleEffect(hint && animal.group == group ? 1.05 : 1)
        }.buttonStyle(.plain)
    }

    private func choose(_ group: String) {
        let correct = group == animal.group
        withAnimation(.bouncy) { result = correct }
        if correct {
            score += 1
            Task { try? await Task.sleep(for: .seconds(1.15)); await MainActor.run { newRound() } }
        } else {
            Task { try? await Task.sleep(for: .seconds(0.8)); await MainActor.run { result = nil } }
        }
    }

    private func newRound(initial: Bool = false) {
        animal = pickAsset(from: NatureLibrary.farm + NatureLibrary.ocean, excluding: history)
        appendHistory(animal.image, to: &history)
        result = nil; hint = false
        if !initial { round += 1 }
    }
}

// MARK: - 2. Tap excavation tiles to uncover and learn a dinosaur

private struct DinoExcavationGame: View {
    let game: NatureExplorerGame
    @State private var dinosaur = NatureLibrary.prehistoric[0]
    @State private var cleared: Set<Int> = []
    @State private var history: [String] = []
    @State private var score = 0
    @State private var round = 1
    private let facts = [
        "Brontosaurus": "Its long neck helped it reach leafy treetops.", "T-Rex": "Its powerful jaws were filled with sharp teeth.",
        "Triceratops": "It had three horns and a wide neck frill.", "Stegosaurus": "Large plates lined its back.",
        "Velociraptor": "It was quick and had curved claws.", "Pterodactyl": "This flying reptile traveled on wide wings.",
        "Spinosaurus": "A tall sail rose from its back.", "Plesiosaurus": "It paddled through ancient oceans.",
        "WoollyMammoth": "Thick fur kept it warm in the cold.", "Smilodon": "Its long canine teeth looked like sabers.",
        "Megalodon": "This enormous shark lived in ancient seas."
    ]

    var body: some View {
        ExplorerShell(game: game, score: score, round: round) {
            VStack(spacing: 16) {
                Text(cleared.count == 6 ? "Discovery complete!" : "Tap the rocks to excavate!")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                ZStack {
                    ExplorerImageCard(asset: dinosaur, height: 250, label: cleared.count == 6)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 3), spacing: 3) {
                        ForEach(0..<6) { index in
                            if !cleared.contains(index) {
                                Button { withAnimation(.bouncy) { _ = cleared.insert(index) } } label: {
                                    RoundedRectangle(cornerRadius: 13).fill(Color.brown)
                                        .overlay(Image(systemName: "circle.hexagongrid.fill").font(.largeTitle).opacity(0.35))
                                        .frame(height: 119)
                                }.buttonStyle(.plain).transition(.scale.combined(with: .opacity))
                            } else { Color.clear.frame(height: 119) }
                        }
                    }.padding(3)
                }.frame(maxWidth: 420)
                if cleared.count == 6 {
                    Text(facts[dinosaur.image] ?? "A wonderful prehistoric discovery!")
                        .font(.system(size: 17, weight: .bold, design: .rounded)).multilineTextAlignment(.center)
                    Button("Dig Again") { next() }
                        .font(.headline.bold()).padding(.horizontal, 28).frame(height: 54)
                        .background(.white, in: Capsule()).foregroundStyle(game.colors.last ?? .orange)
                } else {
                    Text("Cleared \(cleared.count) of 6 rocks").font(.headline)
                }
            }
        }.task { prepare(initial: true) }
    }

    private func next() { score += 1; round += 1; prepare() }
    private func prepare(initial: Bool = false) {
        dinosaur = pickAsset(from: NatureLibrary.prehistoric, excluding: history)
        appendHistory(dinosaur.image, to: &history); cleared = []
    }
}

// MARK: - 3. Perform a countdown and guide a rocket through checkpoints

private struct SpaceLaunchGame: View {
    let game: NatureExplorerGame
    @State private var destination = NatureLibrary.space[0]
    @State private var countdown = 3
    @State private var checkpoint = 0
    @State private var launched = false
    @State private var history: [String] = []
    @State private var score = 0
    @State private var round = 1

    var body: some View {
        ExplorerShell(game: game, score: score, round: round) {
            VStack(spacing: 18) {
                Text(launched ? "Mission to \(destination.name)!" : "Prepare for launch")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                if !launched {
                    Image("Rocket").resizable().scaledToFit().frame(height: 170)
                    Text("Tap the countdown in order").font(.headline)
                    Button("\(countdown)") {
                        if countdown > 1 { countdown -= 1 } else { withAnimation(.bouncy) { launched = true } }
                    }
                    .font(.system(size: 42, weight: .heavy, design: .rounded)).frame(width: 88, height: 88)
                    .background(.white, in: Circle()).foregroundStyle(.indigo)
                } else {
                    HStack(spacing: 8) {
                        Image("Rocket").resizable().scaledToFit().frame(width: 70).offset(x: CGFloat(checkpoint) * 18)
                        ForEach(0..<3) { index in
                            Button { guard index == checkpoint else { return }; withAnimation(.bouncy) { checkpoint += 1 } } label: {
                                Image(systemName: index < checkpoint ? "star.fill" : "star")
                                    .font(.system(size: 35, weight: .bold)).foregroundStyle(.yellow)
                            }.buttonStyle(.plain).disabled(index != checkpoint)
                        }
                        Image(destination.image).resizable().scaledToFit().frame(width: 90, height: 90)
                    }.frame(maxWidth: .infinity, minHeight: 130)
                    Text(checkpoint < 3 ? "Tap the next star to guide the rocket." : "You reached \(destination.name)!")
                        .font(.headline).multilineTextAlignment(.center)
                    if checkpoint == 3 {
                        Button("New Mission") { score += 1; round += 1; prepare() }
                            .font(.headline.bold()).padding(.horizontal, 26).frame(height: 54)
                            .background(.white, in: Capsule()).foregroundStyle(.indigo)
                    }
                }
            }
        }.task { prepare() }
    }

    private func prepare() {
        let destinations = NatureLibrary.space.filter { !["Rocket", "Telescope", "Satellite", "Spaceship"].contains($0.image) }
        destination = pickAsset(from: destinations, excluding: history)
        appendHistory(destination.image, to: &history)
        countdown = 3; checkpoint = 0; launched = false
    }
}

// MARK: - 4. Complete three family connections on one board

private struct AnimalFamilyBoardGame: View {
    let game: NatureExplorerGame
    @State private var pairs: [(adult: NatureAsset, baby: NatureAsset)] = []
    @State private var babyOrder: [NatureAsset] = []
    @State private var selectedAdult: String?
    @State private var matched: Set<String> = []
    @State private var result: Bool?
    @State private var score = 0
    @State private var round = 1
    @State private var previousBabies: Set<String> = []

    var body: some View {
        ExplorerShell(game: game, score: score, round: round) {
            VStack(spacing: 14) {
                Text("Connect each grown-up to its baby")
                    .font(.system(size: 23, weight: .heavy, design: .rounded)).multilineTextAlignment(.center)
                Text(selectedAdult == nil ? "Choose a grown-up first." : "Now choose the matching baby.").font(.headline)
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 9) {
                        ForEach(pairs, id: \.adult.image) { pair in
                            familyButton(pair.adult, selected: selectedAdult == pair.adult.image, complete: matched.contains(pair.baby.image)) {
                                guard !matched.contains(pair.baby.image) else { return }; selectedAdult = pair.adult.image; result = nil
                            }
                        }
                    }
                    Image(systemName: "arrow.left.and.right").font(.title.bold()).padding(.top, 85)
                    VStack(spacing: 9) {
                        ForEach(babyOrder, id: \.image) { baby in
                            familyButton(baby, selected: false, complete: matched.contains(baby.image)) { chooseBaby(baby) }
                        }
                    }
                }
                ExplorerFeedback(result: result, success: matched.count == 3 ? "Every family is together!" : "That's a family match!")
            }
        }.task { prepare() }
    }

    private func familyButton(_ asset: NatureAsset, selected: Bool, complete: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ExplorerImageCard(asset: asset, height: 90)
                .opacity(complete ? 0.45 : 1).overlay(RoundedRectangle(cornerRadius: 18).stroke(.yellow, lineWidth: selected ? 5 : 0))
        }.buttonStyle(.plain).disabled(complete)
    }

    private func chooseBaby(_ baby: NatureAsset) {
        guard let selectedAdult else { result = false; return }
        let correct = pairs.contains { $0.adult.image == selectedAdult && $0.baby.image == baby.image }
        result = correct
        if correct {
            matched.insert(baby.image); self.selectedAdult = nil
            if matched.count == 3 {
                score += 1
                Task { try? await Task.sleep(for: .seconds(1.35)); await MainActor.run { round += 1; prepare() } }
            } else { Task { try? await Task.sleep(for: .seconds(0.7)); await MainActor.run { result = nil } } }
        } else { Task { try? await Task.sleep(for: .seconds(0.7)); await MainActor.run { result = nil } } }
    }

    private func prepare() {
        let unused = NatureLibrary.babies.filter { !previousBabies.contains($0.baby.image) }
        let source = (unused.shuffled() + NatureLibrary.babies.shuffled())
        var nextPairs: [(adult: NatureAsset, baby: NatureAsset)] = []
        for pair in source where !nextPairs.contains(where: { $0.adult.image == pair.adult.image }) {
            nextPairs.append(pair)
            if nextPairs.count == 3 { break }
        }
        pairs = nextPairs
        babyOrder = pairs.map(\.baby).shuffled()
        previousBabies = Set(pairs.map(\.baby.image)); selectedAdult = nil; matched = []; result = nil
    }
}

// MARK: - 5. Build an ordered size line by selecting smallest to biggest

private struct SizeSafariGame: View {
    let game: NatureExplorerGame
    @State private var animals: [NatureAsset] = []
    @State private var placed: [NatureAsset] = []
    @State private var result: Bool?
    @State private var score = 0
    @State private var round = 1
    @State private var history: [String] = []

    var body: some View {
        ExplorerShell(game: game, score: score, round: round) {
            VStack(spacing: 15) {
                Text("Build a size line").font(.system(size: 24, weight: .heavy, design: .rounded))
                Text("Tap from smallest to biggest.").font(.headline)
                HStack(spacing: 8) {
                    ForEach(animals.filter { asset in !placed.contains(asset) }) { asset in
                        Button { choose(asset) } label: { ExplorerImageCard(asset: asset, height: 108) }.buttonStyle(.plain)
                    }
                }
                HStack(spacing: 7) {
                    ForEach(0..<3) { index in
                        if placed.indices.contains(index) {
                            ExplorerImageCard(asset: placed[index], height: 88)
                        } else {
                            RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.6), style: StrokeStyle(lineWidth: 3, dash: [8]))
                                .frame(height: 88)
                                .overlay(Text(index == 0 ? "Small" : index == 2 ? "Big" : "Next").font(.caption.bold()))
                        }
                    }
                }
                ExplorerFeedback(result: result, success: "Perfect size order!")
            }
        }.task { prepare() }
    }

    private func choose(_ asset: NatureAsset) {
        let remaining = animals.filter { !placed.contains($0) }
        let expected = remaining.min(by: { $0.sizeRank < $1.sizeRank })!
        guard asset.image == expected.image else {
            result = false; Task { try? await Task.sleep(for: .seconds(0.7)); await MainActor.run { result = nil } }; return
        }
        withAnimation(.bouncy) { placed.append(asset) }
        if placed.count == 3 {
            result = true; score += 1
            Task { try? await Task.sleep(for: .seconds(1.25)); await MainActor.run { round += 1; prepare() } }
        }
    }

    private func prepare() {
        let pool = NatureLibrary.farm + NatureLibrary.ocean + NatureLibrary.prehistoric
        let anchor = pickAsset(from: pool, excluding: history)
        appendHistory(anchor.image, to: &history)
        var chosen = [anchor]
        for candidate in pool.shuffled() where !chosen.contains(candidate) && !chosen.contains(where: { $0.sizeRank == candidate.sizeRank }) {
            chosen.append(candidate); if chosen.count == 3 { break }
        }
        animals = chosen.shuffled(); placed = []; result = nil
    }
}

// MARK: - 9. Reveal progressive fossil clues before identifying the animal

private struct FossilClueGame: View {
    let game: NatureExplorerGame
    private let puzzles: [(image: String, clues: [String])] = [
        ("Triceratops", ["I walked on four legs.", "I had a wide neck frill.", "I had three horns."]),
        ("Stegosaurus", ["I ate plants.", "My tail had spikes.", "Tall plates lined my back."]),
        ("Brontosaurus", ["I was a giant plant eater.", "I walked on four strong legs.", "My neck was extremely long."]),
        ("Pterodactyl", ["I was a reptile.", "I traveled above the ground.", "I had wide wings."]),
        ("T-Rex", ["I walked on two legs.", "My arms were tiny.", "My jaws had huge teeth."]),
        ("Spinosaurus", ["I was a meat eater.", "I could hunt near water.", "A tall sail rose from my back."])
    ]
    @State private var puzzleIndex = 0
    @State private var cluesShown = 1
    @State private var choices: [NatureAsset] = []
    @State private var result: Bool?
    @State private var score = 0
    @State private var round = 1
    @State private var previous = ""

    private var puzzle: (image: String, clues: [String]) { puzzles[puzzleIndex] }

    var body: some View {
        ExplorerShell(game: game, score: score, round: round) {
            VStack(spacing: 14) {
                Image("DinoBone").resizable().scaledToFit().frame(height: 95)
                Text("Study the fossil clues").font(.system(size: 24, weight: .heavy, design: .rounded))
                VStack(spacing: 8) {
                    ForEach(0..<cluesShown, id: \.self) { index in
                        Label(puzzle.clues[index], systemImage: "magnifyingglass")
                            .font(.system(size: 16, weight: .bold, design: .rounded)).padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 14))
                    }
                }
                if cluesShown < 3 {
                    Button("Brush Off Another Clue") { withAnimation(.bouncy) { cluesShown += 1 } }
                        .font(.headline.bold()).padding(.horizontal, 20).frame(height: 50).background(.brown.opacity(0.8), in: Capsule())
                }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(choices) { asset in
                        Button { choose(asset) } label: { ExplorerImageCard(asset: asset, height: 100) }.buttonStyle(.plain)
                    }
                }
                ExplorerFeedback(result: result, success: "Mystery solved!")
            }
        }.task { prepare() }
    }

    private func choose(_ asset: NatureAsset) {
        let correct = asset.image == puzzle.image; result = correct
        if correct { score += 1; Task { try? await Task.sleep(for: .seconds(1.2)); await MainActor.run { round += 1; prepare() } } }
        else { Task { try? await Task.sleep(for: .seconds(0.7)); await MainActor.run { result = nil; cluesShown = min(3, cluesShown + 1) } } }
    }

    private func prepare() {
        let indexes = puzzles.indices.filter { puzzles[$0].image != previous }
        puzzleIndex = indexes.randomElement() ?? 0; previous = puzzle.image; cluesShown = 1; result = nil
        let answer = NatureLibrary.prehistoric.first { $0.image == puzzle.image }!
        choices = ([answer] + NatureLibrary.prehistoric.filter { $0.image != answer.image }.shuffled().prefix(3)).shuffled()
    }
}

// MARK: - 10. Sort a queue of objects across four world bins

private struct WorldSortingGame: View {
    let game: NatureExplorerGame
    @State private var queue: [NatureAsset] = []
    @State private var index = 0
    @State private var result: Bool?
    @State private var score = 0
    @State private var round = 1
    @State private var lastImages: Set<String> = []
    private let bins = [("Farm", "farm", "house.fill"), ("Ocean", "ocean", "water.waves"), ("Dino", "prehistoric", "fossil.shell.fill"), ("Space", "space", "sparkles")]

    var body: some View {
        ExplorerShell(game: game, score: score, round: round) {
            VStack(spacing: 16) {
                Text("Sort every discovery").font(.system(size: 24, weight: .heavy, design: .rounded))
                Text("Item \(min(index + 1, queue.count)) of \(queue.count)").font(.headline)
                if queue.indices.contains(index) { ExplorerImageCard(asset: queue[index], height: 155).frame(maxWidth: 250) }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(bins, id: \.1) { bin in
                        Button { choose(bin.1) } label: {
                            Label(bin.0, systemImage: bin.2).font(.system(size: 17, weight: .heavy, design: .rounded))
                                .frame(maxWidth: .infinity, minHeight: 62).background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 17))
                        }.buttonStyle(.plain)
                    }
                }
                ExplorerFeedback(result: result, success: index == queue.count - 1 ? "Everything is sorted!" : "Right world!")
            }
        }.task { prepare() }
    }

    private func choose(_ group: String) {
        guard queue.indices.contains(index) else { return }
        let correct = queue[index].group == group; result = correct
        if correct {
            if index + 1 == queue.count {
                score += 1; Task { try? await Task.sleep(for: .seconds(1.1)); await MainActor.run { round += 1; prepare() } }
            } else { Task { try? await Task.sleep(for: .seconds(0.55)); await MainActor.run { index += 1; result = nil } } }
        } else { Task { try? await Task.sleep(for: .seconds(0.65)); await MainActor.run { result = nil } } }
    }

    private func prepare() {
        let pools = [NatureLibrary.farm, NatureLibrary.ocean, NatureLibrary.prehistoric, NatureLibrary.space]
        var items: [NatureAsset] = []
        for pool in pools { items.append(contentsOf: pool.filter { !lastImages.contains($0.image) }.shuffled().prefix(2)) }
        if items.count < 8 { items = pools.flatMap { Array($0.shuffled().prefix(2)) } }
        queue = items.shuffled(); lastImages = Set(queue.map(\.image)); index = 0; result = nil
    }
}

// MARK: - 11. Require touch-counting before number choices unlock

private struct TouchCreatureCountGame: View {
    let game: NatureExplorerGame
    @State private var creature = NatureLibrary.farm[0]
    @State private var count = 3
    @State private var touched: Set<Int> = []
    @State private var touchOrder: [Int] = []
    @State private var result: Bool?
    @State private var score = 0
    @State private var round = 1
    @State private var history: [String] = []

    var body: some View {
        ExplorerShell(game: game, score: score, round: round) {
            VStack(spacing: 15) {
                Text(touched.count < count ? "Touch each \(creature.name)" : "How many did you count?")
                    .font(.system(size: 24, weight: .heavy, design: .rounded)).multilineTextAlignment(.center)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(4, count)), spacing: 9) {
                    ForEach(0..<count, id: \.self) { index in
                        Button {
                            withAnimation(.bouncy) {
                                _ = touched.insert(index)
                                touchOrder.append(index)
                            }
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(creature.image).resizable().scaledToFit().frame(height: 76)
                                    .opacity(touched.contains(index) ? 0.55 : 1).scaleEffect(touched.contains(index) ? 0.9 : 1)
                                if touched.contains(index) {
                                    Text("\(touchedOrder(for: index))").font(.caption.bold()).frame(width: 25, height: 25)
                                        .background(.yellow, in: Circle()).foregroundStyle(.indigo)
                                }
                            }
                        }.buttonStyle(.plain).disabled(touched.contains(index))
                    }
                }
                if touched.count == count {
                    HStack(spacing: 12) {
                        ForEach(answerChoices, id: \.self) { value in
                            Button("\(value)") { choose(value) }
                                .font(.system(size: 28, weight: .heavy, design: .rounded)).frame(minWidth: 64, minHeight: 58)
                                .background(.white, in: RoundedRectangle(cornerRadius: 16)).foregroundStyle(.indigo)
                        }
                    }.transition(.scale.combined(with: .opacity))
                } else { Text("Counted \(touched.count) of \(count)").font(.headline) }
                ExplorerFeedback(result: result, success: "You touch-counted \(count)!")
            }
        }.task { prepare() }
    }

    private var answerChoices: [Int] { Array(Set([count, max(1, count - 1), min(9, count + 1)])).sorted() }
    private func touchedOrder(for index: Int) -> Int { touchOrder.firstIndex(of: index).map { $0 + 1 } ?? 0 }
    private func choose(_ value: Int) {
        result = value == count
        if value == count { score += 1; Task { try? await Task.sleep(for: .seconds(1.15)); await MainActor.run { round += 1; prepare() } } }
        else { Task { try? await Task.sleep(for: .seconds(0.7)); await MainActor.run { result = nil } } }
    }
    private func prepare() {
        creature = pickAsset(from: NatureLibrary.farm + NatureLibrary.ocean + NatureLibrary.prehistoric, excluding: history)
        appendHistory(creature.image, to: &history); count = Int.random(in: 2...8); touched = []; touchOrder = []; result = nil
    }
}

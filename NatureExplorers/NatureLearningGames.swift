import SwiftUI

private struct NatureAsset: Hashable, Identifiable {
    let image: String
    let name: String
    let group: String
    let sizeRank: Int
    var id: String { image }
}

private struct NatureRound: Equatable {
    enum Layout: Equatable { case choices, pattern, oddOne, counting, memory }

    let id = UUID()
    let prompt: String
    let instruction: String
    let hero: NatureAsset?
    let choices: [NatureAsset]
    let answer: String
    let layout: Layout
    let sequence: [NatureAsset]
    let count: Int

    /// The picture protected by the rolling no-repeat history. Counting rounds
    /// answer with a numeral, so their featured creature is the repeat key.
    var historyKey: String {
        layout == .counting ? (hero?.image ?? answer) : answer
    }
}

private enum NatureLibrary {
    static let farm: [NatureAsset] = [
        .init(image: "cow", name: "Cow", group: "farm", sizeRank: 7),
        .init(image: "pig", name: "Pig", group: "farm", sizeRank: 5),
        .init(image: "horse", name: "Horse", group: "farm", sizeRank: 8),
        .init(image: "sheep", name: "Sheep", group: "farm", sizeRank: 5),
        .init(image: "goat", name: "Goat", group: "farm", sizeRank: 4),
        .init(image: "duck", name: "Duck", group: "farm", sizeRank: 2),
        .init(image: "chicken", name: "Chicken", group: "farm", sizeRank: 2),
        .init(image: "turkey", name: "Turkey", group: "farm", sizeRank: 3),
        .init(image: "rabbit", name: "Rabbit", group: "farm", sizeRank: 1),
        .init(image: "donkey", name: "Donkey", group: "farm", sizeRank: 6),
        .init(image: "llama", name: "Llama", group: "farm", sizeRank: 7),
        .init(image: "alpaca", name: "Alpaca", group: "farm", sizeRank: 6)
    ]

    static let ocean: [NatureAsset] = [
        .init(image: "blue whale", name: "Blue Whale", group: "ocean", sizeRank: 10),
        .init(image: "dolphin", name: "Dolphin", group: "ocean", sizeRank: 6),
        .init(image: "octopus", name: "Octopus", group: "ocean", sizeRank: 4),
        .init(image: "seahorse", name: "Seahorse", group: "ocean", sizeRank: 1),
        .init(image: "starfish", name: "Sea Star", group: "ocean", sizeRank: 1),
        .init(image: "turtle", name: "Sea Turtle", group: "ocean", sizeRank: 5),
        .init(image: "shark", name: "Shark", group: "ocean", sizeRank: 8),
        .init(image: "penguin", name: "Penguin", group: "ocean", sizeRank: 3),
        .init(image: "seal", name: "Seal", group: "ocean", sizeRank: 5),
        .init(image: "jellyfish", name: "Jellyfish", group: "ocean", sizeRank: 2),
        .init(image: "crab", name: "Crab", group: "ocean", sizeRank: 1),
        .init(image: "orca", name: "Orca", group: "ocean", sizeRank: 9)
    ]

    static let prehistoric: [NatureAsset] = [
        .init(image: "Brontosaurus", name: "Brontosaurus", group: "prehistoric", sizeRank: 10),
        .init(image: "T-Rex", name: "T. rex", group: "prehistoric", sizeRank: 9),
        .init(image: "Triceratops", name: "Triceratops", group: "prehistoric", sizeRank: 7),
        .init(image: "Stegosaurus", name: "Stegosaurus", group: "prehistoric", sizeRank: 8),
        .init(image: "Velociraptor", name: "Velociraptor", group: "prehistoric", sizeRank: 4),
        .init(image: "Pterodactyl", name: "Pterodactyl", group: "prehistoric", sizeRank: 5),
        .init(image: "Spinosaurus", name: "Spinosaurus", group: "prehistoric", sizeRank: 9),
        .init(image: "Plesiosaurus", name: "Plesiosaurus", group: "prehistoric", sizeRank: 8),
        .init(image: "WoollyMammoth", name: "Woolly Mammoth", group: "prehistoric", sizeRank: 8),
        .init(image: "Smilodon", name: "Smilodon", group: "prehistoric", sizeRank: 5),
        .init(image: "Megalodon", name: "Megalodon", group: "prehistoric", sizeRank: 10)
    ]

    static let space: [NatureAsset] = [
        .init(image: "Earth", name: "Earth", group: "space", sizeRank: 5),
        .init(image: "Moon", name: "Moon", group: "space", sizeRank: 2),
        .init(image: "Sun", name: "Sun", group: "space", sizeRank: 10),
        .init(image: "Saturn", name: "Saturn", group: "space", sizeRank: 8),
        .init(image: "Jupiter", name: "Jupiter", group: "space", sizeRank: 9),
        .init(image: "Mars", name: "Mars", group: "space", sizeRank: 4),
        .init(image: "Rocket", name: "Rocket", group: "space", sizeRank: 3),
        .init(image: "Comet", name: "Comet", group: "space", sizeRank: 2),
        .init(image: "Telescope", name: "Telescope", group: "space", sizeRank: 2),
        .init(image: "Satellite", name: "Satellite", group: "space", sizeRank: 2),
        .init(image: "Spaceship", name: "Spaceship", group: "space", sizeRank: 4)
    ]

    static let babies: [(adult: NatureAsset, baby: NatureAsset)] = [
        (asset("cow", in: farm), .init(image: "calf", name: "Calf", group: "baby", sizeRank: 2)),
        (asset("horse", in: farm), .init(image: "foal", name: "Foal", group: "baby", sizeRank: 2)),
        (asset("pig", in: farm), .init(image: "piglet", name: "Piglet", group: "baby", sizeRank: 1)),
        (asset("sheep", in: farm), .init(image: "lamb", name: "Lamb", group: "baby", sizeRank: 1)),
        (asset("chicken", in: farm), .init(image: "chick", name: "Chick", group: "baby", sizeRank: 1)),
        (asset("horse", in: farm), .init(image: "pony", name: "Pony", group: "baby", sizeRank: 2))
    ]

    static let all = farm + ocean + prehistoric + space

    static func asset(_ image: String, in list: [NatureAsset]) -> NatureAsset {
        list.first { $0.image == image }!
    }
}

struct NatureLearningGameView: View {
    let game: NatureExplorerGame
    @Environment(\.dismiss) private var dismiss
    @State private var round: NatureRound?
    @State private var recentAnswers: [String] = []
    @State private var feedback: Bool?
    @State private var selected = ""
    @State private var score = 0
    @State private var roundNumber = 0
    @State private var hintAnswer = ""
    @State private var memoryCovered = false

    var body: some View {
        ZStack {
            LinearGradient(colors: game.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            Circle().fill(.white.opacity(0.08)).frame(width: 420).offset(x: 190, y: -290)
            Circle().fill(.white.opacity(0.08)).frame(width: 330).offset(x: -210, y: 350)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    header
                    if let round { roundContent(round) }
                }
                .padding(20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .task { if round == nil { nextRound() } }
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline.bold()).frame(width: 44, height: 44)
                        .background(.white.opacity(0.22), in: Circle())
                }
                Spacer()
                Label("\(score)", systemImage: "star.fill")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .padding(.horizontal, 15).frame(height: 44)
                    .background(.white.opacity(0.22), in: Capsule())
            }
            Text(game.title)
                .font(.system(size: 31, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
            Text("Adventure \(roundNumber + 1) • Keep exploring!")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .opacity(0.9)
        }
        .foregroundStyle(.white)
    }

    @ViewBuilder
    private func roundContent(_ item: NatureRound) -> some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text(item.prompt)
                    .font(.system(size: 25, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
                Text(item.instruction)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .opacity(0.88)
            }

            switch item.layout {
            case .choices: standardChoices(item)
            case .pattern: patternChoices(item)
            case .oddOne: oddOneChoices(item)
            case .counting: countingChoices(item)
            case .memory: memoryChoices(item)
            }

            feedbackView
        }
        .foregroundStyle(.white)
        .padding(18)
        .frame(maxWidth: 680)
        .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(.white.opacity(0.24), lineWidth: 2))
        .task(id: item.id) {
            hintAnswer = ""
            if item.layout == .memory {
                memoryCovered = false
                try? await Task.sleep(for: .seconds(2.2))
                withAnimation(.easeInOut) { memoryCovered = true }
            }
            try? await Task.sleep(for: .seconds(3.8))
            guard feedback == nil, selected.isEmpty else { return }
            withAnimation(.bouncy) { hintAnswer = item.answer }
        }
    }

    @ViewBuilder
    private func standardChoices(_ item: NatureRound) -> some View {
        if let hero = item.hero {
            assetCard(hero, height: 132, showsName: game.kind != .size)
                .frame(maxWidth: 250)
                .accessibilityLabel("Clue picture: \(hero.name)")
        }
        choiceGrid(item.choices, answer: item.answer)
    }

    private func patternChoices(_ item: NatureRound) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 7) {
                ForEach(Array(item.sequence.enumerated()), id: \.offset) { _, asset in
                    assetCard(asset, height: 62, showsName: false)
                }
                Text("?")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .frame(width: 62, height: 62)
                    .background(.white.opacity(0.22), in: RoundedRectangle(cornerRadius: 14))
            }
            .minimumScaleFactor(0.6)
            choiceGrid(item.choices, answer: item.answer)
        }
    }

    private func oddOneChoices(_ item: NatureRound) -> some View {
        let common = item.hero ?? item.choices[0]
        let cards = [common, common, item.choices[0], common].shuffled()
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(Array(cards.enumerated()), id: \.offset) { index, asset in
                Button { choose(asset.image == item.answer ? item.answer : "wrong-\(index)") } label: {
                    assetCard(asset, height: 112, showsName: false)
                }
                .buttonStyle(.plain)
                .modifier(NatureHintShake(active: hintAnswer == item.answer && asset.image == item.answer))
            }
        }
    }

    private func countingChoices(_ item: NatureRound) -> some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(4, max(2, item.count))), spacing: 8) {
                ForEach(0..<item.count, id: \.self) { _ in
                    Image(item.hero?.image ?? "penguin")
                        .resizable().scaledToFit().frame(height: 68)
                        .transition(.scale)
                }
            }
            HStack(spacing: 12) {
                ForEach(item.choices, id: \.image) { choice in
                    Button { choose(choice.image) } label: {
                        Text(choice.name)
                            .font(.system(size: 27, weight: .heavy, design: .rounded))
                            .foregroundStyle(game.colors.last ?? .blue)
                            .frame(minWidth: 64, minHeight: 58)
                            .background(.white, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    .modifier(NatureHintShake(active: hintAnswer == choice.image))
                }
            }
        }
    }

    private func memoryChoices(_ item: NatureRound) -> some View {
        VStack(spacing: 16) {
            ZStack {
                if let hero = item.hero { assetCard(hero, height: 128, showsName: true) }
                if memoryCovered {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(0.24))
                        .frame(height: 128)
                        .overlay(Image(systemName: "questionmark").font(.system(size: 48, weight: .heavy)))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: 240)
            choiceGrid(item.choices, answer: item.answer)
                .opacity(memoryCovered ? 1 : 0.35)
                .allowsHitTesting(memoryCovered)
        }
    }

    private func choiceGrid(_ choices: [NatureAsset], answer: String) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(choices) { choice in
                Button { choose(choice.image) } label: {
                    assetCard(choice, height: 108, showsName: true)
                        .overlay {
                            if selected == choice.image && feedback == false {
                                RoundedRectangle(cornerRadius: 18).stroke(.white, lineWidth: 4)
                            }
                        }
                }
                .buttonStyle(.plain)
                .modifier(NatureHintShake(active: hintAnswer == choice.image))
                .accessibilityLabel(choice.name)
            }
        }
    }

    private func assetCard(_ asset: NatureAsset, height: CGFloat, showsName: Bool) -> some View {
        VStack(spacing: 3) {
            Image(asset.image).resizable().scaledToFit().frame(maxHeight: showsName ? height - 24 : height)
            if showsName {
                Text(asset.name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .lineLimit(1).minimumScaleFactor(0.65)
            }
        }
        .padding(7)
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
        .background(.white.opacity(0.94), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .foregroundStyle(Color.indigo)
        .shadow(color: .black.opacity(0.16), radius: 5, y: 3)
    }

    @ViewBuilder private var feedbackView: some View {
        if let feedback {
            Label(
                feedback ? "Wonderful exploring!" : "Good try—look again!",
                systemImage: feedback ? "star.fill" : "arrow.counterclockwise"
            )
            .font(.system(size: 19, weight: .heavy, design: .rounded))
            .foregroundStyle(feedback ? Color.yellow : Color.white)
            .transition(.scale.combined(with: .opacity))
            .accessibilityLabel(feedback ? "Correct. Wonderful exploring!" : "Not quite. Try again.")
        } else {
            Text("Take your time. You can try every answer!")
                .font(.system(size: 14, weight: .semibold, design: .rounded)).opacity(0.8)
        }
    }

    private func choose(_ answer: String) {
        guard feedback != true, let round else { return }
        hintAnswer = ""
        selected = answer
        let correct = answer == round.answer
        withAnimation(.bouncy) { feedback = correct }
        if correct {
            score += 1
            UIAccessibility.post(notification: .announcement, argument: "Correct! Wonderful exploring!")
            Task {
                try? await Task.sleep(for: .seconds(1.25))
                guard !Task.isCancelled else { return }
                await MainActor.run { nextRound() }
            }
        } else {
            UIAccessibility.post(notification: .announcement, argument: "Good try. Look again.")
            Task {
                try? await Task.sleep(for: .seconds(0.85))
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    withAnimation { feedback = nil; selected = "" }
                }
            }
        }
    }

    private func nextRound() {
        let newRound = makeRound(kind: game.kind, excluding: recentAnswers)
        recentAnswers.append(newRound.historyKey)
        if recentAnswers.count > 10 { recentAnswers.removeFirst(recentAnswers.count - 10) }
        feedback = nil
        selected = ""
        hintAnswer = ""
        memoryCovered = false
        roundNumber += round == nil ? 0 : 1
        withAnimation(.easeInOut(duration: 0.25)) { round = newRound }
    }
}

private struct NatureHintShake: ViewModifier {
    let active: Bool
    @State private var phase = false

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(active ? (phase ? 3 : -3) : 0))
            .offset(x: active ? (phase ? 5 : -5) : 0)
            .scaleEffect(active ? 1.04 : 1)
            .onChange(of: active) { _, isActive in
                guard isActive else { phase = false; return }
                withAnimation(.easeInOut(duration: 0.18).repeatForever(autoreverses: true)) { phase = true }
            }
    }
}

private func makeRound(kind: NatureExplorerGame.Kind, excluding history: [String]) -> NatureRound {
    func primary(from pool: [NatureAsset]) -> NatureAsset {
        let unused = pool.filter { !history.contains($0.image) }
        let noImmediate = pool.filter { $0.image != history.last }
        return (unused.randomElement() ?? noImmediate.randomElement() ?? pool.randomElement())!
    }
    func options(answer: NatureAsset, pool: [NatureAsset], count: Int = 4) -> [NatureAsset] {
        var result = [answer]
        for candidate in pool.shuffled() where candidate.image != answer.image && !result.contains(candidate) {
            result.append(candidate)
            if result.count == count { break }
        }
        return result.shuffled()
    }
    func numberAsset(_ value: Int) -> NatureAsset {
        .init(image: String(value), name: String(value), group: "number", sizeRank: value)
    }

    switch kind {
    case .peekaboo:
        // Routed to the dedicated SpriteKit barn experience by the menu.
        let answer = primary(from: NatureLibrary.farm)
        return .init(prompt: "Who is in the barn?", instruction: "Open the doors to meet an animal.", hero: nil, choices: options(answer: answer, pool: NatureLibrary.farm), answer: answer.image, layout: .choices, sequence: [], count: 0)

    case .habitat:
        let answer = primary(from: NatureLibrary.farm + NatureLibrary.ocean)
        let habitat = answer.group == "farm" ? "the farm" : "the ocean"
        let wrongPool = answer.group == "farm" ? NatureLibrary.ocean : NatureLibrary.farm
        return .init(prompt: "Who belongs in \(habitat)?", instruction: "Tap the animal that lives there.", hero: nil, choices: options(answer: answer, pool: wrongPool, count: 4), answer: answer.image, layout: .choices, sequence: [], count: 0)

    case .dino:
        let answer = primary(from: NatureLibrary.prehistoric)
        return .init(prompt: "Can you find the \(answer.name)?", instruction: "Look closely at each prehistoric friend.", hero: nil, choices: options(answer: answer, pool: NatureLibrary.prehistoric), answer: answer.image, layout: .choices, sequence: [], count: 0)

    case .space:
        let answer = primary(from: NatureLibrary.space)
        return .init(prompt: "Space scouts, find \(answer.name)!", instruction: "Choose the matching space picture.", hero: nil, choices: options(answer: answer, pool: NatureLibrary.space), answer: answer.image, layout: .choices, sequence: [], count: 0)

    case .families:
        let available = NatureLibrary.babies.filter { !history.contains($0.baby.image) }
        let pair = available.randomElement() ?? NatureLibrary.babies.filter { $0.baby.image != history.last }.randomElement() ?? NatureLibrary.babies[0]
        let babyPool = NatureLibrary.babies.map(\.baby)
        return .init(prompt: "Find this grown-up's little one!", instruction: "Which baby belongs with the \(pair.adult.name)?", hero: pair.adult, choices: options(answer: pair.baby, pool: babyPool), answer: pair.baby.image, layout: .choices, sequence: [], count: 0)

    case .size:
        let asksBiggest = Bool.random()
        let pool = NatureLibrary.farm + NatureLibrary.ocean + NatureLibrary.prehistoric
        let eligibleAnswers = pool.filter { asset in
            !history.contains(asset.image) && (asksBiggest ? asset.sizeRank >= 5 : asset.sizeRank <= 5)
        }
        let answer = eligibleAnswers.randomElement() ?? primary(from: pool)
        let eligibleOthers = pool.filter {
            $0.image != answer.image && (asksBiggest ? $0.sizeRank < answer.sizeRank : $0.sizeRank > answer.sizeRank)
        }
        let group = ([answer] + eligibleOthers.shuffled().prefix(3)).shuffled()
        return .init(prompt: asksBiggest ? "Which is biggest?" : "Which is smallest?", instruction: "Think about their real-life sizes.", hero: nil, choices: group, answer: answer.image, layout: .choices, sequence: [], count: 0)

    case .pattern:
        let answer = primary(from: NatureLibrary.all)
        let other = NatureLibrary.all.filter { $0.image != answer.image }.randomElement()!
        let abb = Bool.random()
        let sequence = abb ? [other, answer, answer, other, answer] : [other, answer, other, answer, other]
        return .init(prompt: "What comes next?", instruction: "Say the pattern, then finish it.", hero: nil, choices: options(answer: answer, pool: NatureLibrary.all, count: 3), answer: answer.image, layout: .pattern, sequence: sequence, count: 0)

    case .oddOne:
        let odd = primary(from: NatureLibrary.all)
        let common = NatureLibrary.all.filter { $0.image != odd.image }.randomElement()!
        return .init(prompt: "Which picture is different?", instruction: "Three match. One does not.", hero: common, choices: [odd], answer: odd.image, layout: .oddOne, sequence: [], count: 0)

    case .memory:
        let answer = primary(from: NatureLibrary.all)
        return .init(prompt: "Remember this picture!", instruction: "It will hide, then you can find it.", hero: answer, choices: options(answer: answer, pool: NatureLibrary.all), answer: answer.image, layout: .memory, sequence: [], count: 0)

    case .fossil:
        let clues: [(String, String)] = [
            ("Triceratops", "I have three horns and a big frill."),
            ("Stegosaurus", "I have tall plates along my back."),
            ("Brontosaurus", "I have a very long neck."),
            ("Pterodactyl", "I use wings to fly."),
            ("Spinosaurus", "I have a giant sail on my back."),
            ("Velociraptor", "I am a speedy dinosaur with sharp claws."),
            ("T-Rex", "I have tiny arms and powerful jaws.")
        ]
        let usable = clues.filter { !history.contains($0.0) }
        let clue = usable.randomElement() ?? clues.filter { $0.0 != history.last }.randomElement() ?? clues[0]
        let answer = NatureLibrary.prehistoric.first { $0.image == clue.0 }!
        return .init(prompt: "Fossil clue: \(clue.1)", instruction: "Which prehistoric animal am I?", hero: .init(image: "DinoBone", name: "Fossil clue", group: "prehistoric", sizeRank: 1), choices: options(answer: answer, pool: NatureLibrary.prehistoric), answer: answer.image, layout: .choices, sequence: [], count: 0)

    case .scene:
        let groups = [("a barnyard", NatureLibrary.farm), ("the ocean", NatureLibrary.ocean), ("prehistoric times", NatureLibrary.prehistoric), ("outer space", NatureLibrary.space)]
        let selectedGroup = groups.randomElement()!
        let answer = primary(from: selectedGroup.1)
        let other = groups.filter { $0.0 != selectedGroup.0 }.flatMap(\.1)
        return .init(prompt: "What belongs in \(selectedGroup.0)?", instruction: "Sort the pictures into the right world.", hero: nil, choices: options(answer: answer, pool: other), answer: answer.image, layout: .choices, sequence: [], count: 0)

    case .counting:
        let creature = primary(from: NatureLibrary.farm + NatureLibrary.ocean + NatureLibrary.prehistoric)
        let count = Int.random(in: 2...8)
        let values = Set([count, max(1, count - 1), min(9, count + 1), count == 8 ? 6 : count + 2])
        let choices = values.sorted().map(numberAsset)
        return .init(prompt: "How many \(creature.name)s?", instruction: "Touch-count each picture, then choose the number.", hero: creature, choices: choices, answer: String(count), layout: .counting, sequence: [], count: count)

    case .clues:
        let clues: [(String, String)] = [
            ("blue whale", "I am the biggest animal and I swim in the ocean."),
            ("octopus", "I have eight arms and live underwater."),
            ("penguin", "I am a bird that waddles and swims."),
            ("rabbit", "I have long ears and I hop."),
            ("cow", "I live on a farm and say moo."),
            ("dolphin", "I am a smart ocean animal that leaps."),
            ("WoollyMammoth", "I am furry, enormous, and have curved tusks."),
            ("Smilodon", "I am a cat with very long front teeth."),
            ("Saturn", "I am a planet with beautiful rings."),
            ("Moon", "I shine in the night sky and orbit Earth."),
            ("turtle", "I carry a hard shell on my back.")
        ]
        let usable = clues.filter { !history.contains($0.0) }
        let clue = usable.randomElement() ?? clues.filter { $0.0 != history.last }.randomElement() ?? clues[0]
        let answer = NatureLibrary.all.first { $0.image == clue.0 }!
        return .init(prompt: "Who am I? \(clue.1)", instruction: "Use every part of the clue.", hero: nil, choices: options(answer: answer, pool: NatureLibrary.all), answer: answer.image, layout: .choices, sequence: [], count: 0)
    }
}

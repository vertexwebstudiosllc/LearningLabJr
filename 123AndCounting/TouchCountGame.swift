import SwiftUI

struct TouchCountAnimal: Identifiable {
    let id: String
    let plural: String
    static let bank: [Self] = [
        .init(id: "duck", plural: "ducks"),
        .init(id: "sheep", plural: "sheep"),
        .init(id: "rabbit", plural: "rabbits"),
        .init(id: "cat", plural: "cats"),
        .init(id: "dog", plural: "dogs"),
        .init(id: "cow", plural: "cows"),
        .init(id: "horse", plural: "horses"),
        .init(id: "goat", plural: "goats"),
        .init(id: "pig", plural: "pigs"),
        .init(id: "chick", plural: "chicks"),
        .init(id: "turtle", plural: "turtles"),
        .init(id: "penguin", plural: "penguins")
    ]
    var prompt: String { "Find the \(plural). Touch each \(id) once. Let's count together." }
}

struct TouchCountRound {
    let count: Int
    let animal: TouchCountAnimal
    let columns: Int
    let animals: [TouchCountAnimal]
    var success: String { "\(count). You counted every \(animal.id)!" }
    var retry: String { "Look for the \(animal.plural). Leave the other animals for now." }
    static let completion = "You found and counted all the animals! What careful looking and counting!"

    init(count: Int, animal: TouchCountAnimal, columns: Int) {
        precondition((3...5).contains(columns) && (1...columns * columns).contains(count))
        self.count = count; self.animal = animal; self.columns = columns
        let others = TouchCountAnimal.bank.filter { $0.id != animal.id }.shuffled().prefix(3)
        let distractors = (0..<(columns * columns - count)).map { Array(others)[$0 % others.count] }
        animals = (Array(repeating: animal, count: count) + distractors).shuffled()
    }

    static func session() -> [Self] {
        var result: [Self] = []
        for (columns, turns) in [(3, 4), (4, 6), (5, 10)] {
            var counts = Array(1...columns * columns).shuffled()
            var targets = TouchCountAnimal.bank.shuffled()
            // No repeats within a stage, or immediately across stage boundaries.
            if counts.first == result.last?.count { counts.swapAt(0, 1) }
            if targets.first?.id == result.last?.animal.id { targets.swapAt(0, 1) }
            result += (0..<turns).map { Self(count: counts[$0], animal: targets[$0], columns: columns) }
        }
        return result
    }
}

struct TouchCountSession {
    let rounds = TouchCountRound.session()
    private(set) var index = 0
    private(set) var counted: [Int: Int] = [:]
    var current: TouchCountRound { rounds[min(index, rounds.count - 1)] }
    var solved: Bool { counted.count == current.count }
    var finished: Bool { index == rounds.count }
    @discardableResult mutating func count(_ id: Int) -> Bool {
        guard !finished, !solved, current.animals.indices.contains(id),
              current.animals[id].id == current.animal.id, counted[id] == nil else { return false }
        counted[id] = counted.count + 1
        return true
    }
    mutating func next() {
        guard !finished, solved else { return }
        index += 1
        if !finished { counted = [:] }
    }
}

struct TouchCountGame: View {
    @State private var session = TouchCountSession()
    @State private var hint = ""
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Touch & Count", prompt: session.finished ? TouchCountRound.completion : session.current.animal.prompt, accent: .indigo, completion: session.finished, onReplay: {
            narrator.stop(); hint = ""; session = TouchCountSession()
        }) {
            Text("Level \(min(session.index + 1, session.rounds.count)) of \(session.rounds.count)")
                .font(.system(.headline, design: .rounded)).accessibilityIdentifier("counting.touch.level")
            HStack(spacing: 12) {
                ToddlerArt(asset: session.current.animal.id, size: 44).accessibilityHidden(true)
                Text("Find \(session.current.animal.plural)").font(.headline)
                    .accessibilityLabel(session.current.animal.id).accessibilityIdentifier("counting.touch.target")
                Spacer()
                Text("\(session.counted.count)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .accessibilityLabel("\(session.counted.count) \(session.counted.count == 1 ? "animal" : "animals") counted")
                    .accessibilityIdentifier("counting.touch.total")
            }.frame(maxWidth: 460)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: session.current.columns), spacing: 8) {
                ForEach(session.current.animals.indices, id: \.self) { id in
                    Button {
                        if session.count(id) {
                            hint = ""
                            narrator.speak(session.solved ? session.current.success : "\(session.counted.count)")
                        } else if !session.solved && session.current.animals[id].id != session.current.animal.id {
                            hint = session.current.retry
                            narrator.speak(hint)
                        }
                    } label: {
                        VStack(spacing: 4) {
                            ToddlerArt(asset: session.current.animals[id].id, size: session.current.columns == 3 ? 52 : 36)
                            if let number = session.counted[id] {
                                Label("\(number)", systemImage: "checkmark.circle.fill")
                                    .font(.system(.caption, design: .rounded, weight: .bold))
                            } else {
                                Image(systemName: "circle").font(.caption)
                            }
                        }.frame(maxWidth: .infinity, minHeight: session.current.columns == 3 ? 88 : 64)
                            .background(session.counted[id] == nil ? Color.white : Color.indigo.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                    }.buttonStyle(.plain).foregroundStyle(.indigo)
                        .accessibilityLabel("\(session.current.animals[id].id.capitalized) \(id + 1), \(session.counted[id].map { "counted as \($0)" } ?? "touch to count")")
                        .accessibilityIdentifier("counting.touch.animal.\(id)")
                        .disabled(session.counted[id] != nil || session.solved || session.finished)
                }
            }.frame(maxWidth: 460)
            if !hint.isEmpty {
                Text(hint).font(.headline).multilineTextAlignment(.center).accessibilityIdentifier("counting.touch.hint")
            }
            if session.solved && !session.finished {
                Text(session.current.success).font(.system(.title3, design: .rounded, weight: .medium)).multilineTextAlignment(.center)
                ToddlerActionButton(title: session.index == session.rounds.count - 1 ? "Finish our counting" : "Count another group", systemImage: "arrow.right.circle.fill", color: .indigo) {
                    narrator.stop(); hint = ""; session.next()
                }.accessibilityIdentifier("counting.touch.next")
            }
        }.id(min(session.index, session.rounds.count - 1))
            .onDisappear { narrator.stop() }
    }
}

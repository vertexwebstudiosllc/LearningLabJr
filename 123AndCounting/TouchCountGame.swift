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
    var prompt: String { "Touch each \(id) once. Let's count together." }
}

struct TouchCountRound {
    let count: Int
    let animal: TouchCountAnimal
    var key: String { "\(count):\(animal.id)" }
    var columns: Int { count <= 6 ? 3 : 4 }
    var success: String { "\(count). You counted every \(animal.id)!" }
    static let completion = "You counted groups from two to ten! Every animal got counted once!"
    static func session() -> [Self] {
        countingPictureCycle(TouchCountAnimal.bank, count: 27).enumerated().map { index, animal in
            Self(count: 2 + index / 3, animal: animal)
        }
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
        guard !finished, !solved, (0..<current.count).contains(id), counted[id] == nil else { return false }
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
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Touch & Count", prompt: session.finished ? TouchCountRound.completion : session.current.animal.prompt, accent: .indigo, completion: session.finished, onReplay: {
            session = TouchCountSession()
        }) {
            Text("Level \(min(session.index + 1, session.rounds.count)) of \(session.rounds.count)")
                .font(.system(.headline, design: .rounded)).accessibilityIdentifier("counting.touch.level")
            Text("\(session.counted.count)")
                .font(.system(size: 54, weight: .bold, design: .rounded))
                .accessibilityLabel("\(session.counted.count) \(session.counted.count == 1 ? "animal" : "animals") counted")
                .accessibilityIdentifier("counting.touch.total")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: session.current.columns), spacing: 10) {
                ForEach(0..<session.current.count, id: \.self) { id in
                    Button {
                        if session.count(id) {
                            narrator.speak(session.solved ? session.current.success : "\(session.counted.count)")
                        }
                    } label: {
                        VStack(spacing: 6) {
                            ToddlerArt(asset: session.current.animal.id, size: session.current.columns == 3 ? 60 : 42)
                            if let number = session.counted[id] {
                                Label("\(number)", systemImage: "checkmark.circle.fill")
                                    .font(.system(.caption, design: .rounded, weight: .bold))
                            } else {
                                Image(systemName: "circle").font(.caption)
                            }
                        }.frame(maxWidth: .infinity, minHeight: session.current.columns == 3 ? 104 : 86)
                            .background(session.counted[id] == nil ? Color.white : Color.indigo.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
                    }.buttonStyle(.plain).foregroundStyle(.indigo)
                        .accessibilityLabel("\(session.current.animal.id.capitalized) \(id + 1), \(session.counted[id].map { "counted as \($0)" } ?? "touch to count")")
                        .accessibilityIdentifier("counting.touch.animal.\(id)")
                        .disabled(session.counted[id] != nil || session.finished)
                }
            }.frame(maxWidth: 460)
            if session.solved && !session.finished {
                Text(session.current.success).font(.system(.title3, design: .rounded, weight: .medium)).multilineTextAlignment(.center)
                ToddlerActionButton(title: session.index == session.rounds.count - 1 ? "Finish our counting" : "Count another group", systemImage: "arrow.right.circle.fill", color: .indigo) {
                    session.next()
                }.accessibilityIdentifier("counting.touch.next")
            }
        }
    }
}

import SwiftUI

struct DotPuzzle {
    let size: Int
    let patchSize: Int
    let row: Int
    let column: Int
    let missing: Set<Int>
    let choices: [Set<Int>]
    var signature: String { "\(size):\(row):\(column):" + missing.sorted().map(String.init).joined(separator: ",") }
    var answer: Int { choices.firstIndex(of: missing)! }
    func missingAt(row: Int, column: Int) -> Bool {
        guard (self.row..<(self.row + patchSize)).contains(row),
              (self.column..<(self.column + patchSize)).contains(column) else { return false }
        return missing.contains((row - self.row) * patchSize + column - self.column)
    }
    static func session(previousFirst: String? = nil) -> [Self] {
        var rounds: [Self] = []
        var used: Set<String> = []
        for size in 3...10 {
            let patch = size < 5 ? 2 : (size < 8 ? 3 : 4)
            for turn in 0..<3 {
                let count = min(patch * patch - 1, patch + turn)
                var puzzle: Self
                repeat {
                    let missing = Set((0..<(patch * patch)).shuffled().prefix(count))
                    var choices = [missing]
                    while choices.count < 3 {
                        let candidate = Set((0..<(patch * patch)).shuffled().prefix(count))
                        if !choices.contains(candidate) { choices.append(candidate) }
                    }
                    puzzle = Self(size: size, patchSize: patch, row: Int.random(in: 0...(size - patch)),
                                  column: Int.random(in: 0...(size - patch)), missing: missing, choices: choices.shuffled())
                } while used.contains(puzzle.signature) || (rounds.isEmpty && puzzle.signature == previousFirst)
                used.insert(puzzle.signature); rounds.append(puzzle)
            }
        }
        return rounds
    }
    static let prompt = "Some dots are missing! Pick the card that fits the empty rings in the golden window."
    static let retry = "Look at the empty rings in the golden window. Find dots in those same spots."
    static let success = "You found the missing pattern! Our dot grid is complete!"
    static let completion = "You solved every dot puzzle! What careful looking, dot detective!"
}

struct DotPuzzleSession {
    let rounds: [DotPuzzle]
    private(set) var index = 0
    private(set) var solved = false
    var current: DotPuzzle { rounds[min(index, rounds.count - 1)] }
    var finished: Bool { index == rounds.count }
    init(previousFirst: String? = nil) { rounds = DotPuzzle.session(previousFirst: previousFirst) }
    @discardableResult mutating func choose(_ index: Int) -> Bool {
        guard !finished, !solved, current.choices.indices.contains(index), index == current.answer else { return false }
        solved = true; return true
    }
    mutating func next() {
        guard solved, !finished else { return }
        index += 1
        if !finished { solved = false }
    }
}

private struct DotPatternCard: View {
    let size: Int
    let dots: Set<Int>
    var body: some View {
        GeometryReader { geometry in
            let cell = min(geometry.size.width, geometry.size.height) / CGFloat(size)
            ZStack(alignment: .topLeading) {
                ForEach(0..<(size * size), id: \.self) { index in
                    Circle().fill(dots.contains(index) ? Color.indigo : Color.indigo.opacity(0.07))
                        .frame(width: cell * 0.52, height: cell * 0.52)
                        .position(x: (CGFloat(index % size) + 0.5) * cell, y: (CGFloat(index / size) + 0.5) * cell)
                }
            }
        }.aspectRatio(1, contentMode: .fit)
    }
}

struct DotDetectiveGame: View {
    private static let previousKey = "dotDetective.previousFirstPuzzle"
    @State private var session = DotPuzzleSession(previousFirst: UserDefaults.standard.string(forKey: Self.previousKey))
    @State private var feedback = ""
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Dot Detective", prompt: session.finished ? DotPuzzle.completion : DotPuzzle.prompt,
                            accent: .indigo, completion: session.finished, onReplay: replay) {
            Text("Puzzle \(min(session.index + 1, 24)) of 24 · \(session.current.size) × \(session.current.size)")
                .font(.headline).accessibilityIdentifier("counting.dots.level")
            grid
            Text(session.solved ? "Pattern found!" : "Which pattern fills the rings?")
                .font(.headline).accessibilityIdentifier("counting.dots.progress")
            HStack(spacing: 12) {
                ForEach(session.current.choices.indices, id: \.self) { index in
                    Button { choose(index) } label: {
                        VStack(spacing: 6) {
                            DotPatternCard(size: session.current.patchSize, dots: session.current.choices[index])
                                .frame(height: 80)
                            Text("\(index + 1)").font(.headline)
                        }.padding(6).background(.white, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(session.solved && index == session.current.answer ? Color.green : Color.indigo.opacity(0.2), lineWidth: 3))
                    }.buttonStyle(.plain).disabled(session.solved || session.finished)
                        .accessibilityLabel("Pattern \(index + 1). " + positions(session.current.choices[index]))
                        .accessibilityIdentifier("counting.dots.choice.\(index)")
                }
            }.frame(maxWidth: 480)
            if !feedback.isEmpty { Text(feedback).font(.headline).multilineTextAlignment(.center) }
            if session.solved && !session.finished {
                ToddlerActionButton(title: session.index == 23 ? "Finish detecting" : "Next puzzle", systemImage: "magnifyingglass", color: .indigo) {
                    narrator.stop(); session.next(); feedback = ""
                }.accessibilityIdentifier("counting.dots.next")
            }
        }.id(min(session.index, 23))
            .onAppear { rememberFirst() }
            .onDisappear { narrator.stop() }
    }
    private var grid: some View {
        GeometryReader { geometry in
            let puzzle = session.current
            let cell = geometry.size.width / CGFloat(puzzle.size)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 14).fill(Color.yellow.opacity(0.25))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.orange, lineWidth: 3))
                    .frame(width: cell * CGFloat(puzzle.patchSize), height: cell * CGFloat(puzzle.patchSize))
                    .offset(x: cell * CGFloat(puzzle.column), y: cell * CGFloat(puzzle.row))
                ForEach(0..<(puzzle.size * puzzle.size), id: \.self) { index in
                    let missing = puzzle.missingAt(row: index / puzzle.size, column: index % puzzle.size)
                    Circle().fill(missing && !session.solved ? Color.white : (missing ? Color.green : Color.indigo))
                        .overlay(Circle().stroke(missing && !session.solved ? Color.orange : Color.clear, lineWidth: 2))
                        .frame(width: cell * 0.48, height: cell * 0.48)
                        .position(x: (CGFloat(index % puzzle.size) + 0.5) * cell, y: (CGFloat(index / puzzle.size) + 0.5) * cell)
                }
            }
        }.aspectRatio(1, contentMode: .fit).frame(maxWidth: 260)
            .padding(12).background(.white, in: RoundedRectangle(cornerRadius: 22))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(session.current.size) by \(session.current.size) dot grid. Golden window is \(session.current.patchSize) by \(session.current.patchSize), starting at row \(session.current.row + 1) column \(session.current.column + 1). " + (session.solved ? "All dots filled." : "Missing " + positions(session.current.missing)))
            .accessibilityIdentifier("counting.dots.grid")
    }
    private func positions(_ dots: Set<Int>) -> String {
        dots.sorted().map { "row \($0 / session.current.patchSize + 1) column \($0 % session.current.patchSize + 1)" }.joined(separator: ", ")
    }
    private func choose(_ index: Int) {
        guard !session.solved, !session.finished else { return }
        feedback = session.choose(index) ? DotPuzzle.success : DotPuzzle.retry
        narrator.speak(feedback)
    }
    private func rememberFirst() { UserDefaults.standard.set(session.rounds[0].signature, forKey: Self.previousKey) }
    private func replay() {
        narrator.stop(); session = DotPuzzleSession(previousFirst: session.rounds[0].signature)
        feedback = ""; rememberFirst()
    }
}

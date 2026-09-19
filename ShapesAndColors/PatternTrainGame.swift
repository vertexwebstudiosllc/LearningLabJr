import SwiftUI

enum TrainShape: String, CaseIterable, Identifiable {
    case circle, square, triangle, star
    var id: String { rawValue }
    var name: String { rawValue.capitalized }
    var color: Color {
        switch self {
        case .circle: return .pink
        case .square: return .blue
        case .triangle: return .green
        case .star: return .orange
        }
    }
    var success: String { "\(name) continues the pattern. Choo choo!" }
}

struct TrainPattern {
    let stage: Int
    let unit: [TrainShape]
    let count: Int
    let choices: [TrainShape]
    var key: String { unit.map(\.rawValue).joined(separator: ",") }
    var shapes: [TrainShape] { (0..<count).map { unit[$0 % unit.count] } }
    var answer: TrainShape { shapes[count - 1] }
    var hint: String { "Listen to the repeating group: " + unit.map { $0.rawValue }.joined(separator: ", ") + ". Then it starts again!" }
    var prompt: String { Self.prompts[stage] }
    static let prompts = [
        "Follow the numbered train cars. Which shape comes next?",
        "Some shapes come in pairs. Which shape comes next?",
        "Look for three shapes that repeat. Which shape comes next?",
        "Look for the repeating group of four. Which shape comes next?",
        "Let's try a longer repeating group. Which shape comes next?"
    ]
    static let completion = "Sixty different pattern trains! Choo choo!"
    static let lengths = [5...6, 7...8, 9...10, 11...12, 13...15]
    static let templates = [
        [[0, 1]],
        [[0, 0, 1], [0, 1, 1]],
        [[0, 1, 2]],
        [[0, 0, 1, 1], [0, 1, 0, 2]],
        [[0, 0, 1, 1, 2], [0, 1, 0, 2, 1]]
    ]
    static func units(stage: Int) -> [[TrainShape]] {
        var output: [[TrainShape]] = []
        for template in templates[stage] {
            for a in TrainShape.allCases {
                for b in TrainShape.allCases where b != a {
                    if template.contains(2) {
                        for c in TrainShape.allCases where c != a && c != b {
                            output.append(template.map { [a, b, c][$0] })
                        }
                    } else { output.append(template.map { [a, b][$0] }) }
                }
            }
        }
        return output
    }
    static func session() -> [Self] {
        (0..<templates.count).flatMap { stage in
            units(stage: stage).shuffled().prefix(12).enumerated().map { index, unit in
                // Increase train length within each stage; show at least two full groups before the blank.
                let span = lengths[stage]
                let count = span.lowerBound + index * (span.upperBound - span.lowerBound + 1) / 12
                let answer = unit[(count - 1) % unit.count]
                let choices = ([answer] + TrainShape.allCases.filter { $0 != answer }.shuffled().prefix(2)).shuffled()
                return Self(stage: stage, unit: unit, count: count, choices: choices)
            }
        }
    }
}

struct TrainSession {
    private(set) var rounds = TrainPattern.session()
    private(set) var index = 0
    private(set) var solved = false
    var finished: Bool { index == rounds.count }
    var current: TrainPattern { rounds[min(index, rounds.count - 1)] }
    @discardableResult
    mutating func choose(_ shape: TrainShape) -> Bool {
        guard !finished, !solved, shape == current.answer else { return false }
        solved = true
        return true
    }
    mutating func next() {
        guard !finished, solved else { return }
        index += 1
        solved = false
    }
}

struct PatternTrainGame: View {
    let onReplay: () -> Void
    @State private var train = TrainSession()
    @State private var note = "Read left to right, then start the next row."
    @State private var showGroup = false
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Pattern Train", prompt: train.finished ? TrainPattern.completion : train.current.prompt, accent: .orange, completion: train.finished, onReplay: onReplay) {
            Text("Train \(min(train.index + 1, train.rounds.count)) of \(train.rounds.count) · Stage \(train.current.stage + 1) of 5")
                .font(.system(.headline, design: .rounded))
                .accessibilityIdentifier("shapes.train.progress")
            Image(systemName: "tram.fill").font(.system(size: 45)).foregroundStyle(.orange).accessibilityHidden(true)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 5), spacing: 8) {
                ForEach(0..<train.current.count, id: \.self) { index in
                    car(index)
                }
            }.accessibilityIdentifier("shapes.train.board")
            if !train.finished {
                HStack(spacing: 10) {
                    ForEach(train.current.choices) { shape in
                        Button {
                            guard !train.solved else { return }
                            if train.choose(shape) {
                                note = shape.success
                                narrator.speak(note)
                            } else {
                                showGroup = true
                                note = "Find the group that repeats. Let's try again."
                                narrator.speak(train.current.hint)
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: shape.rawValue + ".fill").font(.system(size: 30)).foregroundStyle(shape.color)
                                Text(shape.name).font(.system(.caption, design: .rounded, weight: .bold))
                            }.frame(maxWidth: .infinity, minHeight: 85)
                                .background(.white, in: RoundedRectangle(cornerRadius: 20))
                        }.buttonStyle(.plain).disabled(train.solved)
                            .accessibilityIdentifier("shapes.train.choice.\(shape.rawValue)")
                    }
                }
                Button {
                    showGroup = true
                    narrator.speak(train.current.hint)
                } label: {
                    Label("Hear the repeating group", systemImage: "speaker.wave.2.fill")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .frame(maxWidth: .infinity, minHeight: 64)
                }.accessibilityIdentifier("shapes.train.hint")
            }
            if showGroup {
                Text(train.current.unit.map(\.name).joined(separator: " → "))
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .multilineTextAlignment(.center)
            }
            SCNote(text: note)
            if train.solved && !train.finished {
                ToddlerActionButton(title: train.index == train.rounds.count - 1 ? "Finish our trains" : "Next train", systemImage: "arrow.right", color: .orange) {
                    let stage = train.current.stage
                    train.next()
                    note = "Read left to right, then start the next row."
                    showGroup = false
                    if !train.finished && stage == train.current.stage { narrator.speak(train.current.prompt) }
                }.accessibilityIdentifier("shapes.train.next")
            }
        }
    }
    private func car(_ index: Int) -> some View {
        let isAnswer = index == train.current.count - 1
        let revealed = !isAnswer || train.solved || train.finished
        let shape = train.current.shapes[index]
        return VStack(spacing: 4) {
            Text("\(index + 1)").font(.system(.caption2, design: .rounded)).foregroundStyle(.secondary)
            Image(systemName: revealed ? shape.rawValue + ".fill" : "questionmark")
                .font(.system(size: 27, weight: .bold))
                .foregroundStyle(revealed ? shape.color : Color.primary)
        }.frame(maxWidth: .infinity, minHeight: 64)
            .background(isAnswer ? Color.orange.opacity(0.16) : .white, in: RoundedRectangle(cornerRadius: 14))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Car \(index + 1): \(revealed ? shape.name : "which shape comes next?")")
            .accessibilityIdentifier("shapes.train.car.\(index)")
            .accessibilityValue(revealed ? shape.rawValue : "missing")
    }
}

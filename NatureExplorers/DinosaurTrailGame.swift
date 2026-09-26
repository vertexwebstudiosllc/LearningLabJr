import SwiftUI

struct TrailDinosaur: Identifiable, Equatable {
    let id: String
    let name: String
    var asset: String { "DinosaurClean/" + id }
    static let bank: [Self] = [
        .init(id: "Triceratops", name: "Triceratops"),
        .init(id: "Stegosaurus", name: "Stegosaurus"),
        .init(id: "Brontosaurus", name: "Brontosaurus"),
        .init(id: "T-Rex", name: "Tyrannosaurus rex"),
        .init(id: "Velociraptor", name: "Velociraptor"),
        .init(id: "Spinosaurus", name: "Spinosaurus")
    ]
}

struct DinosaurTrailRound {
    let dinosaurs: [TrailDinosaur]
    let target: Int
    /// Horizontal coordinates inside each trail's own lane, from start to dinosaur.
    let bends: [[Double]]
    var steps: Int { bends[0].count }
    var pairID: String { dinosaurs.map(\.id).sorted().joined(separator: ":") }
    var prompt: String { "Can you find the \(dinosaurs[target].name)? Follow the footprints to that dinosaur." }
    var success: String { "You found the \(dinosaurs[target].name)! What a great explorer!" }
    var retry: String { "That trail found the \(dinosaurs[1 - target].name). Let's try the other trail." }
}

struct DinosaurTrailSession {
    let rounds: [DinosaurTrailRound]
    private(set) var index = 0
    private(set) var progress = [0, 0]
    var current: DinosaurTrailRound { rounds[min(index, rounds.count - 1)] }
    var complete: Bool { index == rounds.count }
    var solved: Bool { progress[current.target] == current.steps }
    static let stepHint = "Start at the bottom. Tap the next footprint on the same colored trail."
    static let completion = "You followed every dinosaur trail! What an adventure!"
    var prompt: String { complete ? Self.completion : solved ? current.success : current.prompt }

    init(recentPairs: [String] = []) {
        let bank = TrailDinosaur.bank
        var remaining = bank.indices.flatMap { a in ((a + 1)..<bank.count).map { b in [bank[a], bank[b]] } }
        var recent = Array(recentPairs.suffix(5))
        var result: [DinosaurTrailRound] = []
        for index in 0..<15 {
            let allowed = remaining.indices.filter { !recent.contains(remaining[$0].map(\.id).sorted().joined(separator: ":")) }
            let lastAnimals = Set(recent.last?.components(separatedBy: ":") ?? [])
            let fresh = allowed.filter { Set(remaining[$0].map(\.id)).isDisjoint(with: lastAnimals) }
            let choice = (fresh.isEmpty ? allowed : fresh).randomElement()!
            let pair = remaining.remove(at: choice).shuffled()
            let stage = index / 5
            let steps = 4 + stage * 2
            let bends = (0..<2).map { _ -> [Double] in
                let startsLeft = Bool.random()
                return (0..<steps).map { step in
                    if step == 0 || step == steps - 1 { return 0.5 }
                    let left = step.isMultiple(of: 2) == startsLeft
                    let reach = [0.14, 0.25, 0.34][stage]
                    return 0.5 + (left ? -reach : reach) + Double.random(in: -0.035...0.035)
                }
            }
            let round = DinosaurTrailRound(dinosaurs: pair, target: Int.random(in: 0...1), bends: bends)
            result.append(round)
            recent.append(round.pairID); recent = Array(recent.suffix(5))
        }
        rounds = result
    }

    @discardableResult mutating func step(trail: Int, footprint: Int) -> Bool {
        guard !complete, !solved, (0...1).contains(trail), progress[trail] < current.steps,
              footprint == progress[trail] else { return false }
        progress[trail] += 1
        return true
    }
    mutating func next() {
        guard !complete, solved else { return }
        index += 1
        if !complete { progress = [0, 0] }
    }
}

struct DinosaurTrailGame: View {
    @AppStorage("nature.dinosaurTrails.recentPairs") private var recentPairs = ""
    @State private var play = DinosaurTrailSession()
    @State private var started = false
    @State private var feedback = ""
    @StateObject private var narrator = GameNarrator()

    var body: some View {
        ToddlerGameScaffold(title: "Dinosaur Trail", prompt: play.prompt, completion: play.complete, onReplay: restart) {
            if !play.complete {
                Text("Adventure \(play.index + 1) of 15 · \(play.current.steps) footprints")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .accessibilityIdentifier("dinosaur.level")
                board
                Text(feedback.isEmpty ? "Start at the bottom. Tap along one trail." : feedback)
                    .font(.system(.subheadline, design: .rounded)).multilineTextAlignment(.center)
                    .accessibilityIdentifier("dinosaur.feedback")
                if play.solved {
                    ToddlerActionButton(title: play.index == 14 ? "Finish exploring" : "Another adventure", systemImage: "arrow.right") {
                        play.next(); feedback = ""
                        if !play.complete { rememberPair() }
                    }.accessibilityIdentifier("dinosaur.next")
                }
            }
        }
        .id(play.index)
        .onAppear { if !started { restart(); started = true } }
        .onDisappear { narrator.stop() }
    }

    private var board: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 26).fill(Color.green.opacity(0.07))
                ForEach(0..<2, id: \.self) { trail in
                    DinosaurTrailLane(round: play.current, trail: trail, progress: play.progress[trail],
                                      width: geometry.size.width, height: geometry.size.height,
                                      onFootprint: { follow(trail: trail, step: $0) },
                                      onDinosaur: { narrator.speak(play.current.dinosaurs[trail].name) })
                }
            }
        }
        .frame(height: CGFloat(284 + (play.current.steps - 4) * 16))
    }

    private func follow(trail: Int, step: Int) {
        guard !play.solved, !play.complete else { return }
        if play.step(trail: trail, footprint: step) {
            feedback = ""
            if !play.solved && play.progress[trail] == play.current.steps {
                feedback = play.current.retry
                narrator.speak(feedback)
            }
        } else {
            feedback = DinosaurTrailSession.stepHint
            narrator.speak(feedback)
        }
    }
    private func rememberPair() {
        var recent = recentPairs.split(separator: "|").map(String.init)
        recent.append(play.current.pairID)
        recentPairs = recent.suffix(5).joined(separator: "|")
    }
    private func restart() {
        narrator.stop()
        play = DinosaurTrailSession(recentPairs: recentPairs.split(separator: "|").map(String.init))
        rememberPair()
        feedback = ""
    }
}

private struct DinosaurTrailLane: View {
    let round: DinosaurTrailRound
    let trail: Int
    let progress: Int
    let width: CGFloat
    let height: CGFloat
    let onFootprint: (Int) -> Void
    let onDinosaur: () -> Void
    private var color: Color { trail == 0 ? .blue : .orange }
    private var name: String { trail == 0 ? "Blue" : "Orange" }
    private var lane: CGFloat { width / 2 }
    private var points: [CGPoint] {
        (0..<round.steps).map { step in
            CGPoint(x: lane * (CGFloat(trail) + CGFloat(round.bends[trail][step])),
                    y: height - 30 - CGFloat(step) * (height - 150) / CGFloat(round.steps - 1))
        }
    }
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: points[0])
                for point in points.dropFirst() { path.addLine(to: point) }
                path.addLine(to: CGPoint(x: lane * (CGFloat(trail) + 0.5), y: 84))
            }
            .stroke(color.opacity(0.55), style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round, dash: trail == 0 ? [] : [10, 6]))
            .accessibilityHidden(true)
            Button(action: onDinosaur) {
                VStack(spacing: 0) {
                    ToddlerArt(asset: round.dinosaurs[trail].asset, size: 68)
                    Text(round.dinosaurs[trail].name)
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
                }.frame(width: lane - 8)
            }
            .buttonStyle(.plain)
            .position(x: lane * (CGFloat(trail) + 0.5), y: 42)
            .accessibilityLabel(round.dinosaurs[trail].name)
            .accessibilityIdentifier("dinosaur.destination.\(trail)")
            ForEach(0..<round.steps, id: \.self) { step in
                footprint(step).position(points[step])
            }
        }
    }
    private func footprint(_ step: Int) -> some View {
        let visited = step < progress
        let next = step == progress
        return Button { onFootprint(step) } label: {
            Image(systemName: visited ? "checkmark" : "pawprint.fill")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(visited ? .white : color)
                .frame(width: 44, height: 44)
                .background(visited ? color : .white, in: Circle())
                .overlay(Circle().stroke(color, lineWidth: next ? 4 : 2))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(name) trail, footprint \(step + 1)\(visited ? ", followed" : next ? ", next" : "")")
        .accessibilityIdentifier("dinosaur.step.\(trail).\(step)")
    }
}

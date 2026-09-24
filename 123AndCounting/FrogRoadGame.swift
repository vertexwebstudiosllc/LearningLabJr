import SwiftUI

struct FrogCrossing {
    let size: Int
    let path: [Int] // Column for each row, from the starting grass to the pond.
    let vehicles: [String]
    var signature: String { "\(size):" + path.map(String.init).joined(separator: ",") }
    static let vehicleAssets = ["carBlue", "copCar", "truckYellow", "foodTruckGrey", "firetruck", "trashTruck"]
    static func session(previousFirst: String? = nil) -> [Self] {
        var rounds: [Self] = []
        var used: Set<String> = []
        for size in 4...6 {
            for _ in 0..<6 {
                var route: [Int]
                var signature: String
                repeat {
                    route = [Int.random(in: 0..<size)]
                    for _ in 1..<size {
                        let last = route.last!
                        route.append(Int.random(in: max(0, last - 1)...min(size - 1, last + 1)))
                    }
                    signature = "\(size):" + route.map(String.init).joined(separator: ",")
                } while used.contains(signature) || (rounds.isEmpty && signature == previousFirst)
                used.insert(signature)
                rounds.append(Self(size: size, path: route, vehicles: (0..<(size * size)).map { _ in vehicleAssets.randomElement()! }))
            }
        }
        return rounds
    }
    static let prompt = "Help our frog reach the pond! Tap the empty spot just ahead, straight or diagonally."
    static let retry = "Find the empty spot in the very next row. Hop forward, or diagonally forward."
    static let blocked = "That spot has a vehicle. Find the open spot for our frog."
    static let success = "Splash! Our frog reached the pond!"
    static let completion = "You helped our frog cross every road and reach the pond!"
}

struct FrogRoadSession {
    let rounds: [FrogCrossing]
    private(set) var index = 0
    private(set) var row = 0
    var current: FrogCrossing { rounds[min(index, rounds.count - 1)] }
    var column: Int { current.path[row] }
    var solved: Bool { row == current.size - 1 }
    var finished: Bool { index == rounds.count }
    init(previousFirst: String? = nil) { rounds = FrogCrossing.session(previousFirst: previousFirst) }
    @discardableResult mutating func hop(row: Int, column: Int) -> Bool {
        guard !finished, !solved, row == self.row + 1, (0..<current.size).contains(column),
              abs(column - self.column) <= 1, current.path[row] == column else { return false }
        self.row = row; return true
    }
    mutating func next() {
        guard !finished, solved else { return }
        index += 1
        if !finished { row = 0 }
    }
}

private struct FriendlyRoadFrog: View {
    var body: some View {
        ZStack {
            Ellipse().fill(Color.green.opacity(0.8)).frame(width: 38, height: 19).offset(y: 13)
            Ellipse().fill(Color.green).frame(width: 32, height: 28).offset(y: 3)
            ForEach([-1.0, 1.0], id: \.self) { side in
                Circle().fill(Color.green).frame(width: 16, height: 16).offset(x: side * 10, y: -10)
                Circle().fill(.white).frame(width: 11, height: 11).offset(x: side * 10, y: -11)
                Circle().fill(Color.black).frame(width: 5, height: 5).offset(x: side * 10, y: -11)
            }
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(to: CGPoint(x: 14, y: 0), control: CGPoint(x: 7, y: 8))
            }.stroke(Color(red: 0.08, green: 0.3, blue: 0.1), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: 14, height: 7).offset(y: 8)
        }.frame(width: 44, height: 44)
    }
}

struct FrogHopsGame: View {
    private static let previousKey = "frogRoad.previousFirstRoute"
    @State private var session = FrogRoadSession(previousFirst: UserDefaults.standard.string(forKey: Self.previousKey))
    @State private var feedback = ""
    @StateObject private var narrator = GameNarrator()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        ToddlerGameScaffold(title: "Frog Hops", prompt: session.finished ? FrogCrossing.completion : FrogCrossing.prompt,
                            accent: .green, completion: session.finished, onReplay: replay) {
            Text("Crossing \(min(session.index + 1, 18)) of 18 · \(session.current.size) × \(session.current.size)")
                .font(.headline).accessibilityIdentifier("counting.frog.level")
            board
            Text(session.solved ? "At the pond!" : "\(session.row) of \(session.current.size - 1) hops")
                .font(.headline).accessibilityIdentifier("counting.frog.progress")
            if !feedback.isEmpty { Text(feedback).font(.headline).multilineTextAlignment(.center) }
            if session.solved && !session.finished {
                ToddlerActionButton(title: session.index == 17 ? "Finish hopping" : "Next crossing", systemImage: "arrow.up.circle.fill", color: .green) {
                    narrator.stop(); session.next(); feedback = ""
                }.accessibilityIdentifier("counting.frog.next")
            }
        }.id(min(session.index, 17))
            .onAppear { rememberFirst() }
            .onDisappear { narrator.stop() }
    }
    private var board: some View {
        GeometryReader { geometry in
            let size = session.current.size
            let cell = geometry.size.width / CGFloat(size)
            ZStack(alignment: .topLeading) {
                ForEach(0..<(size * size), id: \.self) { index in
                    let row = index / size
                    let col = index % size
                    let road = row > 0 && row < size - 1
                    let open = session.current.path[row] == col
                    Button { hop(row: row, column: col) } label: {
                        ZStack {
                            Rectangle().fill(road ? Color(white: 0.27) : (row == 0 ? Color.green.opacity(0.25) : Color.cyan.opacity(0.25)))
                            if road {
                                VStack { Rectangle().fill(Color.white.opacity(0.65)).frame(width: cell * 0.4, height: 2); Spacer() }.padding(.top, 2)
                                if !open { Image(session.current.vehicles[index]).resizable().scaledToFit().padding(5) }
                            } else if row == size - 1 {
                                VStack { Spacer(); Rectangle().fill(Color.green.opacity(0.45)).frame(height: cell * 0.22) }
                                Image(systemName: open ? "leaf.fill" : "water.waves")
                                    .font(.system(size: cell * 0.35)).foregroundStyle(open ? Color.green : Color.blue.opacity(0.6))
                            } else {
                                Image(systemName: "leaf.fill").font(.system(size: 15)).foregroundStyle(Color.green.opacity(0.3))
                            }
                            if open && row > 0 && row < size - 1 {
                                RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, style: StrokeStyle(lineWidth: 2, dash: [4, 3])).padding(6)
                            }
                            Rectangle().stroke(Color.white.opacity(0.4), lineWidth: 1)
                        }.frame(width: cell, height: cell).contentShape(Rectangle())
                    }.buttonStyle(.plain).disabled(session.solved || session.finished)
                        .position(x: (CGFloat(col) + 0.5) * cell, y: (CGFloat(size - 1 - row) + 0.5) * cell)
                        .accessibilityLabel("Row \(row + 1), column \(col + 1), " + (row == session.row && col == session.column ? "frog" : (row == 0 ? "starting grass" : (row == size - 1 ? (open ? "pond landing" : "pond water") : (open ? "open road" : "vehicle")))))
                        .accessibilityIdentifier("counting.frog.cell.\(row).\(col)")
                }
                FriendlyRoadFrog()
                    .keyframeAnimator(initialValue: CGFloat.zero, trigger: session.row) { content, lift in
                        content.offset(y: reduceMotion ? 0 : -lift)
                    } keyframes: { _ in
                        LinearKeyframe(16, duration: 0.14)
                        CubicKeyframe(0, duration: 0.2)
                    }
                    .position(x: (CGFloat(session.column) + 0.5) * cell, y: (CGFloat(size - 1 - session.row) + 0.5) * cell)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.34), value: session.row)
                    .allowsHitTesting(false).accessibilityHidden(true)
            }.clipShape(RoundedRectangle(cornerRadius: 18))
        }.aspectRatio(1, contentMode: .fit).frame(maxWidth: 320)
    }
    private func hop(row: Int, column: Int) {
        guard !session.solved, !session.finished else { return }
        if session.hop(row: row, column: column) {
            feedback = session.solved ? FrogCrossing.success : String(session.row)
        } else {
            feedback = row > 0 && row < session.current.size - 1 && session.current.path[row] != column ? FrogCrossing.blocked : FrogCrossing.retry
        }
        narrator.speak(feedback)
    }
    private func rememberFirst() { UserDefaults.standard.set(session.rounds[0].signature, forKey: Self.previousKey) }
    private func replay() {
        narrator.stop(); session = FrogRoadSession(previousFirst: session.rounds[0].signature)
        feedback = ""; rememberFirst()
    }
}

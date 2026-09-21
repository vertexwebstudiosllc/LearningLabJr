import SwiftUI

struct RoadJourney {
    let size: Int
    let route: [Int]
    var key: String { "\(size):" + route.map(String.init).joined(separator: ",") }
    static let arrival = "You followed the winding road all the way home!"
    static let completion = "Twenty-four road trips! You followed little roads and big roads all the way home!"
    static let directions = ["above", "below", "to the left of", "to the right of"]
    static func instruction(_ direction: String) -> String { "Follow the road. Tap the glowing square \(direction) the car." }
    static func retry(_ direction: String) -> String { "The next road square is glowing \(direction) the car." }
    static func neighbors(of cell: Int, size: Int) -> [Int] {
        let row = cell / size, column = cell % size
        return [(row - 1, column), (row + 1, column), (row, column - 1), (row, column + 1)]
            .filter { (0..<size).contains($0.0) && (0..<size).contains($0.1) }
            .map { $0.0 * size + $0.1 }
    }
    // Bounded backtracking builds a connected path without revisiting any square.
    // A transformed winding road supplies a guaranteed fallback for every size/length.
    static func make(size: Int, length: Int, variant: Int) -> Self {
        var budget = 2000
        func extend(_ path: [Int]) -> [Int]? {
            budget -= 1
            guard budget > 0 else { return nil }
            if path.count == length { return path }
            for next in neighbors(of: path.last!, size: size).shuffled() where !path.contains(next) {
                if let result = extend(path + [next]) { return result }
            }
            return nil
        }
        if let path = extend([Int.random(in: 0..<(size * size))]) { return Self(size: size, route: path) }
        let snake = (0..<size).flatMap { row in
            (0..<size).map { column in row * size + (row.isMultiple(of: 2) ? column : size - 1 - column) }
        }
        return Self(size: size, route: Array(snake.prefix(length)).map { cell in
            variant.isMultiple(of: 2) ? cell : size * size - 1 - cell
        })
    }
    static func session() -> [Self] {
        var result: [Self] = []
        for size in 3...6 {
            for trip in 0..<6 {
                let length = (size - 3) * 3 + 5 + trip / 2
                var candidate = make(size: size, length: length, variant: trip)
                // At most one earlier trip has this size and length. Reversing a duplicate
                // always gives a different ordered journey with a different starting square.
                if result.contains(where: { $0.key == candidate.key }) {
                    candidate = Self(size: size, route: candidate.route.reversed())
                }
                result.append(candidate)
            }
        }
        return result
    }
    func direction(after step: Int) -> String {
        guard step < route.count - 1 else { return "home" }
        let difference = route[step + 1] - route[step]
        if difference == -size { return "above" }
        if difference == size { return "below" }
        return difference == -1 ? "to the left of" : "to the right of"
    }
    func road(in cell: Int, rect: CGRect) -> Path {
        guard let index = route.firstIndex(of: cell) else { return Path() }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        return Path { path in
            for neighborIndex in [index - 1, index + 1] where route.indices.contains(neighborIndex) {
                let other = route[neighborIndex]
                let dx = other % size - cell % size, dy = other / size - cell / size
                path.move(to: center)
                path.addLine(to: CGPoint(x: center.x + CGFloat(dx) * rect.width / 2, y: center.y + CGFloat(dy) * rect.height / 2))
            }
        }
    }
}

struct RoadTripSession {
    let journeys = RoadJourney.session()
    private(set) var index = 0
    private(set) var step = 0
    var current: RoadJourney { journeys[min(index, journeys.count - 1)] }
    var car: Int { current.route[step] }
    var arrived: Bool { step == current.route.count - 1 }
    var finished: Bool { index == journeys.count }
    var nextCell: Int? { !arrived && !finished ? current.route[step + 1] : nil }
    var prompt: String {
        finished ? RoadJourney.completion : arrived ? RoadJourney.arrival : RoadJourney.instruction(current.direction(after: step))
    }
    @discardableResult mutating func move(to cell: Int) -> Bool {
        guard nextCell == cell else { return false }
        step += 1
        return true
    }
    mutating func next() {
        guard !finished, arrived else { return }
        index += 1
        if !finished { step = 0 }
    }
}

struct LittleRoadTripGame: View {
    let onReplay: () -> Void
    @State private var session = RoadTripSession()
    @StateObject private var narrator = GameNarrator()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        ToddlerGameScaffold(title: "Little Road Trip", prompt: session.prompt, accent: .blue, completion: session.finished, onReplay: onReplay) {
            Text("Trip \(min(session.index + 1, session.journeys.count)) of \(session.journeys.count) · \(session.current.size) × \(session.current.size) grid")
                .font(.system(.headline, design: .rounded)).accessibilityIdentifier("shapes.roads.trip")
            Text("\(session.step) of \(session.current.route.count - 1) road steps")
                .font(.subheadline).accessibilityIdentifier("shapes.roads.progress")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: session.current.size), spacing: 3) {
                ForEach(0..<(session.current.size * session.current.size), id: \.self) { cell in
                    roadCell(cell)
                }
            }.frame(maxWidth: 420)
            if session.arrived && !session.finished {
                ToddlerActionButton(title: session.index == session.journeys.count - 1 ? "Finish our road trips" : "Take another trip", systemImage: "car.fill", color: .blue) {
                    session.next()
                }.accessibilityIdentifier("shapes.roads.next")
            }
            SCNote(text: "Follow the glowing square. Say up, down, left, and right together. There is no rush.")
        }.id(session.index)
    }
    private func roadCell(_ cell: Int) -> some View {
        let onRoad = session.current.route.contains(cell)
        let next = cell == session.nextCell
        let visited = session.current.route.prefix(session.step + 1).contains(cell)
        return Button {
            if !session.move(to: cell), !session.arrived && !session.finished {
                narrator.speak(RoadJourney.retry(session.current.direction(after: session.step)))
            }
        } label: {
            GeometryReader { geometry in
                let rect = CGRect(origin: .zero, size: geometry.size)
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(next ? Color.blue.opacity(0.2) : onRoad ? .white : .green.opacity(0.13))
                    session.current.road(in: cell, rect: rect)
                        .stroke(visited ? Color.blue.opacity(0.35) : Color.gray.opacity(0.28), style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                    if cell == session.car {
                        Image(systemName: "car.fill").foregroundStyle(.blue)
                    } else if cell == session.current.route.last {
                        Image(systemName: "house.fill").foregroundStyle(.orange)
                    } else if !onRoad {
                        Image(systemName: "tree.fill").foregroundStyle(.green.opacity(0.65))
                    } else if next {
                        Image(systemName: "arrow.down.circle.fill").foregroundStyle(.blue)
                            .rotationEffect(.degrees(arrowRotation))
                    }
                    RoundedRectangle(cornerRadius: 8).strokeBorder(next ? .blue : .clear, lineWidth: 3)
                }.font(.system(size: min(38, geometry.size.width * 0.58)))
            }.aspectRatio(1, contentMode: .fit)
                .contentShape(Rectangle())
        }.buttonStyle(.plain)
            .accessibilityLabel("\(cell == session.car ? "Car" : cell == session.current.route.last ? "Home" : onRoad ? "Road" : "Tree"), row \(cell / session.current.size + 1), column \(cell % session.current.size + 1)")
            .accessibilityHint(next ? "Next road square, \(session.current.direction(after: session.step)) the car" : "")
            .accessibilityIdentifier(next ? "shapes.roads.step" : "shapes.roads.cell.\(cell)")
            .disabled(!onRoad || session.arrived || session.finished)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: visited)
    }
    private var arrowRotation: Double {
        switch session.current.direction(after: session.step) {
        case "above": return 180
        case "to the left of": return 90
        case "to the right of": return -90
        default: return 0
        }
    }
}

import SwiftUI

struct ShapeTrail: Identifiable {
    let id: String
    let name: String
    let points: [CGPoint]
    let checkpoints: [Int]
    var prompt: String { "Follow the glowing dot around the \(name.lowercased()). Slide a finger or tap each dot." }
    var success: String { "You went all around the \(name.lowercased())!" }
    static let completion = "You traced twenty-five different shapes. What a shape adventure!"

    static func polygon(_ id: String, _ name: String, _ vertices: [CGPoint]) -> Self {
        var points: [CGPoint] = [vertices[0]]
        for index in vertices.indices {
            let a = vertices[index], b = vertices[(index + 1) % vertices.count]
            let steps = max(1, Int(ceil(hypot(b.x - a.x, b.y - a.y) / 0.18)))
            for step in 1...steps {
                let t = CGFloat(step) / CGFloat(steps)
                points.append(step == steps ? b : CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t))
            }
        }
        return Self(id: id, name: name, points: points, checkpoints: Array(points.indices))
    }
    static func curved(_ id: String, _ name: String, _ points: [CGPoint], stride: Int = 4) -> Self {
        var closed = points
        if closed.last != closed.first { closed.append(closed[0]) }
        var stops = Array(Swift.stride(from: 0, to: closed.count - 1, by: stride))
        stops.append(closed.count - 1)
        return Self(id: id, name: name, points: closed, checkpoints: stops)
    }
    static func ellipse(_ id: String, _ name: String, rx: CGFloat, ry: CGFloat) -> Self {
        curved(id, name, (0..<64).map { index in
            let angle = CGFloat(index) * .pi / 32 - .pi / 2
            return CGPoint(x: 0.5 + rx * cos(angle), y: 0.5 + ry * sin(angle))
        })
    }
    static func regular(_ sides: Int, _ name: String) -> Self {
        polygon(name.lowercased(), name, (0..<sides).map { index in
            let angle = CGFloat(index) * 2 * .pi / CGFloat(sides) - .pi / 2
            return CGPoint(x: 0.5 + 0.35 * cos(angle), y: 0.5 + 0.35 * sin(angle))
        })
    }
    static func bezier(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint, _ d: CGPoint) -> [CGPoint] {
        (0..<24).map { index in
            let t = CGFloat(index) / 24, u = 1 - t
            return CGPoint(x: u*u*u*a.x + 3*u*u*t*b.x + 3*u*t*t*c.x + t*t*t*d.x,
                           y: u*u*u*a.y + 3*u*u*t*b.y + 3*u*t*t*c.y + t*t*t*d.y)
        }
    }
    static func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }
    static let bank: [Self] = [
        ellipse("circle", "Circle", rx: 0.34, ry: 0.34),
        polygon("square", "Square", [p(0.18,0.18),p(0.82,0.18),p(0.82,0.82),p(0.18,0.82)]),
        polygon("triangle", "Triangle", [p(0.5,0.15),p(0.85,0.82),p(0.15,0.82)]),
        polygon("rectangle", "Rectangle", [p(0.13,0.27),p(0.87,0.27),p(0.87,0.73),p(0.13,0.73)]),
        ellipse("oval", "Oval", rx: 0.38, ry: 0.25),
        polygon("diamond", "Diamond", [p(0.5,0.12),p(0.78,0.5),p(0.5,0.88),p(0.22,0.5)]),
        regular(5,"Pentagon"), regular(6,"Hexagon"),
        polygon("star", "Star", (0..<10).map { index in
            let angle = CGFloat(index) * .pi / 5 - .pi / 2
            let radius: CGFloat = index.isMultiple(of: 2) ? 0.38 : 0.18
            return p(0.5 + radius * cos(angle), 0.5 + radius * sin(angle))
        }),
        curved("heart", "Heart",
            bezier(p(0.5,0.3),p(0.3,0.04),p(0.02,0.34),p(0.5,0.86)) +
            bezier(p(0.5,0.86),p(0.98,0.34),p(0.7,0.04),p(0.5,0.3))),
        polygon("trapezoid", "Trapezoid", [p(0.32,0.23),p(0.68,0.23),p(0.87,0.78),p(0.13,0.78)]),
        polygon("parallelogram", "Parallelogram", [p(0.32,0.23),p(0.88,0.23),p(0.68,0.77),p(0.12,0.77)]),
        polygon("kite", "Kite", [p(0.5,0.12),p(0.8,0.38),p(0.5,0.88),p(0.2,0.38)]),
        regular(7,"Heptagon"), regular(8,"Octagon"), regular(9,"Nonagon"), regular(10,"Decagon"),
        curved("semicircle", "Semicircle",
            (0...32).map { index in
                let angle = .pi + CGFloat(index) * .pi / 32
                return p(0.5 + 0.36 * cos(angle), 0.65 + 0.36 * sin(angle))
            } + (1...7).map { p(0.86 - CGFloat($0) * 0.09,0.65) }, stride: 2),
        curved("quarter-circle", "Quarter circle",
            (0...24).map { index in
                let angle = -.pi / 2 + CGFloat(index) * .pi / 48
                return p(0.22 + 0.6 * cos(angle), 0.78 + 0.6 * sin(angle))
            } + [p(0.67,0.78),p(0.52,0.78),p(0.37,0.78),p(0.22,0.78),p(0.22,0.63),p(0.22,0.48),p(0.22,0.33)], stride: 2),
        curved("crescent", "Crescent",
            bezier(p(0.7,0.14),p(0.02,0.09),p(0.02,0.91),p(0.7,0.86)) +
            bezier(p(0.7,0.86),p(0.32,0.7),p(0.32,0.3),p(0.7,0.14))),
        polygon("cross", "Cross", [p(0.38,0.14),p(0.62,0.14),p(0.62,0.38),p(0.86,0.38),p(0.86,0.62),p(0.62,0.62),p(0.62,0.86),p(0.38,0.86),p(0.38,0.62),p(0.14,0.62),p(0.14,0.38),p(0.38,0.38)]),
        polygon("arrow", "Arrow", [p(0.14,0.38),p(0.58,0.38),p(0.58,0.18),p(0.88,0.5),p(0.58,0.82),p(0.58,0.62),p(0.14,0.62)]),
        curved("teardrop", "Teardrop",
            bezier(p(0.5,0.12),p(0.96,0.59),p(0.84,0.87),p(0.5,0.87)) +
            bezier(p(0.5,0.87),p(0.16,0.87),p(0.04,0.59),p(0.5,0.12))),
        curved("arch", "Arch",
            bezier(p(0.18,0.5),p(0.18,0.06),p(0.82,0.06),p(0.82,0.5)) +
            [p(0.82,0.61),p(0.82,0.72),p(0.82,0.83),p(0.66,0.83),p(0.5,0.83),p(0.34,0.83),p(0.18,0.83),p(0.18,0.72),p(0.18,0.61)], stride: 2),
        curved("capsule", "Capsule",
            (0...24).map { index in
                let a = -.pi / 2 + CGFloat(index) * .pi / 24
                return p(0.67 + 0.2*cos(a), 0.5 + 0.2*sin(a))
            } + [p(0.5,0.7)] + (0...24).map { index in
                let a = .pi / 2 + CGFloat(index) * .pi / 24
                return p(0.33 + 0.2*cos(a),0.5 + 0.2*sin(a))
            } + [p(0.5,0.3)], stride: 3)
    ]
    func location(_ point: CGPoint, in size: CGSize) -> CGPoint {
        let span = min(size.width, size.height)
        return CGPoint(x: size.width / 2 + (point.x - 0.5) * span, y: size.height / 2 + (point.y - 0.5) * span)
    }
    func path(in size: CGSize, visited: Int? = nil) -> Path {
        let end = visited.map { $0 == 0 ? 0 : checkpoints[min($0 - 1, checkpoints.count - 1)] } ?? (points.count - 1)
        return Path { path in
            path.move(to: location(points[0], in: size))
            for point in points.prefix(end + 1).dropFirst() { path.addLine(to: location(point, in: size)) }
        }
    }
}

struct TrailSession {
    private(set) var index = 0
    private(set) var visited = 0
    var current: ShapeTrail { ShapeTrail.bank[min(index, ShapeTrail.bank.count - 1)] }
    var finished: Bool { index == ShapeTrail.bank.count }
    var solved: Bool { visited == current.checkpoints.count }
    @discardableResult
    mutating func advance(expected: Int) -> Bool {
        guard !finished, !solved, expected == visited else { return false }
        visited += 1
        return true
    }
    mutating func touch(_ point: CGPoint, in size: CGSize) -> Bool {
        guard !finished, !solved else { return false }
        let target = current.location(current.points[current.checkpoints[visited]], in: size)
        guard hypot(point.x - target.x, point.y - target.y) <= 34 else { return false }
        return advance(expected: visited)
    }
    mutating func next() {
        guard !finished, solved else { return }
        index += 1
        if !finished { visited = 0 }
    }
}

struct ShapeTrailsGame: View {
    let onReplay: () -> Void
    @State private var trail = TrailSession()
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Shape Trails", prompt: trail.finished ? ShapeTrail.completion : trail.current.prompt, accent: .teal, completion: trail.finished, onReplay: onReplay) {
            Text("Shape \(min(trail.index + 1, 25)) of 25 · \(trail.current.name)")
                .font(.system(.headline, design: .rounded)).accessibilityIdentifier("shapes.trail.name")
            GeometryReader { geometry in
                let expected = trail.visited
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 24).fill(.white)
                    trail.current.path(in: geometry.size)
                        .stroke(.teal.opacity(0.18), style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                    trail.current.path(in: geometry.size, visited: trail.visited)
                        .stroke(.teal, style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                    if !trail.solved && !trail.finished {
                        let location = trail.current.location(trail.current.points[trail.current.checkpoints[trail.visited]], in: geometry.size)
                        Button { advance(expected) } label: {
                            Image(systemName: "hand.point.up.left.fill").font(.system(size: 27)).foregroundStyle(.white)
                                .frame(width: 68, height: 68).background(.teal, in: Circle())
                        }.buttonStyle(.plain)
                            .frame(width: 68, height: 68)
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Next point on the \(trail.current.name.lowercased()) trail")
                            .accessibilityIdentifier("shapes.trail.point")
                            .accessibilityAddTraits(.isButton)
                            .accessibilityAction { advance(expected) }
                            .highPriorityGesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("shape-trail-board")).onChanged { value in
                                if trail.touch(value.location, in: geometry.size), trail.solved { narrator.speak(trail.current.success) }
                            })
                            .offset(x: location.x - 34, y: location.y - 34)
                    }
                }
                    .coordinateSpace(name: "shape-trail-board")

            }.frame(height: 280)
            Text("\(trail.visited) of \(trail.current.checkpoints.count) trail points")
                .font(.subheadline).accessibilityIdentifier("shapes.trail.progress")
            if trail.solved && !trail.finished {
                ToddlerActionButton(title: trail.index == 24 ? "Finish our trails" : "Trace the next shape", systemImage: "arrow.right", color: .teal) {
                    trail.next()
                }.accessibilityIdentifier("shapes.trail.next")
            }
            SCNote(text: "Say curved, straight, and corner as you explore. There is no need to stay exactly on the line.")
        }
    }
    private func advance(_ expected: Int) {
        if trail.advance(expected: expected), trail.solved { narrator.speak(trail.current.success) }
    }
}

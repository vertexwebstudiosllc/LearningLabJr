import SwiftUI

private enum SCPaint: Int, CaseIterable, Identifiable {
    case red, yellow, blue, orange, green, purple
    var id: Int { rawValue }
    var name: String { ["Red", "Yellow", "Blue", "Orange", "Green", "Purple"][rawValue] }
    var color: Color { [.red, .yellow, .blue, .orange, .green, .purple][rawValue] }
    var symbol: String { ["heart.fill", "sun.max.fill", "drop.fill", "carrot.fill", "leaf.fill", "moon.fill"][rawValue] }
}

private enum SCShape: Int, CaseIterable, Identifiable {
    case circle, square, triangle
    var id: Int { rawValue }
    var name: String { ["Circle", "Square", "Triangle"][rawValue] }
    var symbol: String { ["circle.fill", "square.fill", "triangle.fill"][rawValue] }
    var outline: String { ["circle", "square", "triangle"][rawValue] }
    var color: Color { [.pink, .blue, .green][rawValue] }
}

struct SCNote: View {
    let text: String
    var body: some View {
        Text(text).font(.system(.body, design: .rounded, weight: .medium))
            .foregroundStyle(.primary).multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 52).padding(14)
            .background(.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 20))
            .accessibilityAddTraits(.updatesFrequently)
    }
}

private struct SCPaintPicker: View {
    @Binding var selection: SCPaint
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
            ForEach(SCPaint.allCases) { paint in
                Button { selection = paint; narrator.speak("\(paint.name) paint selected.") } label: {
                    VStack(spacing: 6) {
                        Image(systemName: paint.symbol).font(.system(size: 27, weight: .bold))
                        Text(paint.name).font(.system(.caption, design: .rounded, weight: .bold))
                    }.foregroundStyle(paint == .yellow ? Color.black : .white)
                        .frame(maxWidth: .infinity, minHeight: 80)
                        .background(paint.color, in: RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(selection == paint ? Color.primary : .clear, lineWidth: 4))
                }.buttonStyle(.plain).accessibilityLabel("\(paint.name) paint")
                    .accessibilityAddTraits(selection == paint ? .isSelected : [])
            }
        }
    }
}

enum PostShape: String, CaseIterable, Identifiable {
    case circle, square, triangle, rectangle, oval, diamond, star, heart, pentagon, hexagon
    var id: String { rawValue }
    var name: String { rawValue.capitalized }
    var symbol: String { rawValue }
    var prompt: String { "Drag the \(rawValue) to its matching opening." }
    var success: String { "The \(rawValue) fits! You posted it!" }
    var retry: String { "Let's try again. Drag the \(rawValue) to the matching opening." }
}

struct ShapePostRound {
    let target: PostShape
    let openings: [PostShape]
    static let completion = "All ten shapes are posted! Nice matching!"
    static func session() -> [Self] {
        PostShape.allCases.shuffled().map { target in
            Self(target: target, openings: ([target] + PostShape.allCases.filter { $0 != target }.shuffled().prefix(2)).shuffled())
        }
    }
    // Generous rectangular drop zones include the outline and its label.
    static func holeFrame(index: Int, width: CGFloat) -> CGRect {
        let cellWidth = (width - 24) / 3
        return CGRect(x: CGFloat(index) * (cellWidth + 12), y: 136, width: cellWidth, height: 116)
    }
    func accepts(_ point: CGPoint, width: CGFloat) -> Bool {
        guard let index = openings.firstIndex(of: target) else { return false }
        return Self.holeFrame(index: index, width: width).contains(point)
    }
}

struct ShapePostGame: View {
    let onReplay: () -> Void
    @State private var rounds = ShapePostRound.session()
    @State private var posted = 0
    @State private var solved = false
    @State private var offset = CGSize.zero
    @State private var hover: PostShape?
    @State private var note = "Slide the shape with your finger."
    @StateObject private var narrator = GameNarrator()
    private var finished: Bool { posted == rounds.count }
    private var round: ShapePostRound { rounds[min(posted, rounds.count - 1)] }

    var body: some View {
        ToddlerGameScaffold(title: "Shape Post", prompt: finished ? ShapePostRound.completion : round.target.prompt, accent: .blue, completion: finished, onReplay: onReplay) {
            Text("\(posted + (solved ? 1 : 0)) of 10 shapes posted")
                .font(.headline).accessibilityIdentifier("shapes.post.progress")
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    ForEach(Array(round.openings.enumerated()), id: \.element.id) { index, shape in
                        opening(shape, index: index, width: geometry.size.width)
                    }
                    stamp(width: geometry.size.width)
                }.coordinateSpace(name: "shape-post-board")
            }.frame(height: 260)
            SCNote(text: note)
            if solved && !finished {
                ToddlerActionButton(title: posted == rounds.count - 1 ? "Finish posting" : "Next shape", systemImage: "arrow.right", color: .blue) {
                    guard solved, !finished else { return }
                    posted += 1
                    solved = false
                    note = "Slide the shape with your finger."
                }.accessibilityIdentifier("shapes.post.next")
            }
        }
    }

    private func opening(_ shape: PostShape, index: Int, width: CGFloat) -> some View {
        let frame = ShapePostRound.holeFrame(index: index, width: width)
        let filled = solved && shape == round.target
        return VStack(spacing: 8) {
            Image(systemName: shape.symbol + (filled ? ".fill" : ""))
                .resizable().scaledToFit().frame(width: 62, height: 62)
            Text(shape.name).font(.system(.caption, design: .rounded, weight: .bold))
        }
        .foregroundStyle(filled ? Color.green : Color.primary)
        .frame(width: frame.width, height: frame.height)
        .background(.white, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(hover == shape ? Color.blue : Color.blue.opacity(0.2), lineWidth: 3))
        .position(x: frame.midX, y: frame.midY)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(shape.name) opening")
        .accessibilityIdentifier("shapes.post.opening.\(shape.rawValue)")
        .accessibilityAction(named: "Post shape here") { post(matches: shape == round.target) }
    }

    private func stamp(width: CGFloat) -> some View {
        Image(systemName: solved || finished ? "checkmark.circle.fill" : round.target.symbol + ".fill")
            .resizable().scaledToFit().foregroundStyle(solved ? Color.green : Color.blue)
            .frame(width: 86, height: 86).padding(10)
            .contentShape(Rectangle())
            .highPriorityGesture(stampDrag(width: width), including: solved || finished ? .none : .all)
            .offset(offset)
            .position(x: width / 2, y: 57)
            .accessibilityLabel("\(round.target.name) stamp")
            .accessibilityValue(round.target.rawValue)
            .accessibilityHint("Drag to the matching opening, or use an opening's Post shape here action.")
            .accessibilityIdentifier("shapes.post.stamp")
    }

    private func stampDrag(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .named("shape-post-board"))
            .onChanged { value in
                guard !solved, !finished else { return }
                offset = value.translation
                hover = round.openings.enumerated().first {
                    ShapePostRound.holeFrame(index: $0.offset, width: width).contains(value.location)
                }?.element
            }
            .onEnded { value in
                offset = .zero
                hover = nil
                post(matches: round.accepts(value.location, width: width))
            }
    }

    private func post(matches: Bool) {
        guard !solved, !finished else { return }
        solved = matches
        note = matches ? round.target.success : round.target.retry
        narrator.speak(note)
    }
}

enum LaundryColor: String, CaseIterable, Identifiable {
    case red, orange, yellow, green, blue, purple, pink, brown, black, white, gray
    var id: String { rawValue }
    var name: String { rawValue.capitalized }
    var color: Color {
        switch self {
        case .red: return .red
        case .orange: return .orange
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        case .purple: return .purple
        case .pink: return Color(red: 1, green: 0.42, blue: 0.72)
        case .brown: return .brown
        case .black: return .black
        case .white: return .white
        case .gray: return .gray
        }
    }
    var prompt: String { "Put the \(rawValue) shirt in the \(rawValue) basket." }
    var success: String { "In the \(rawValue) basket! Nice sorting!" }
    var retry: String { "This shirt is \(rawValue). Let's find its basket." }
}

struct LaundryRound {
    let target: LaundryColor
    let baskets: [LaundryColor]
    static func basketFrame(index: Int, width: CGFloat) -> CGRect {
        let cellWidth = (width - 24) / 3
        return CGRect(x: CGFloat(index) * (cellWidth + 12), y: 160, width: cellWidth, height: 144)
    }
    func basket(at point: CGPoint, width: CGFloat) -> LaundryColor? {
        baskets.enumerated().first {
            Self.basketFrame(index: $0.offset, width: width).contains(point)
        }?.element
    }

    static func cycle(after previous: LaundryColor? = nil) -> [Self] {
        var colors = LaundryColor.allCases.shuffled()
        if colors.first == previous { colors.swapAt(0, Int.random(in: 1..<colors.count)) }
        return colors.map { target in
            Self(target: target, baskets: ([target] + LaundryColor.allCases.filter { $0 != target }.shuffled().prefix(2)).shuffled())
        }
    }
}

struct LaundrySession {
    private(set) var rounds = LaundryRound.cycle()
    private(set) var index = 0
    private(set) var counts: [LaundryColor: Int] = [:]
    private(set) var solved = false
    var current: LaundryRound { rounds[index] }
    var total: Int { counts.values.reduce(0, +) }

    @discardableResult
    mutating func sort(into basket: LaundryColor) -> Bool {
        guard !solved, basket == current.target else { return false }
        counts[basket, default: 0] += 1
        solved = true
        return true
    }

    mutating func next() {
        guard solved else { return }
        if index == rounds.count - 1 {
            rounds = LaundryRound.cycle(after: current.target)
            index = 0
        } else {
            index += 1
        }
        solved = false
    }
}

struct ColorLaundryGame: View {
    let onReplay: () -> Void
    @State private var laundry = LaundrySession()
    @State private var offset = CGSize.zero
    @State private var hover: LaundryColor?
    @State private var note = "Slide the shirt with your finger."
    @StateObject private var narrator = GameNarrator()
    private let boardColor = Color(red: 0.84, green: 0.89, blue: 0.94)

    var body: some View {
        ToddlerGameScaffold(title: "Color Laundry", prompt: laundry.current.target.prompt, accent: .blue) {
            Text("\(laundry.total) shirts sorted").font(.headline)
                .accessibilityIdentifier("shapes.laundry.progress")
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 24).fill(boardColor)
                        .frame(height: 140).accessibilityHidden(true)
                    ForEach(Array(laundry.current.baskets.enumerated()), id: \.element.id) { index, color in
                        basket(color, index: index, width: geometry.size.width)
                    }
                    shirt(width: geometry.size.width)
                }.coordinateSpace(name: "laundry-board")
            }.frame(height: 312)
            SCNote(text: note)
            if laundry.solved {
                ToddlerActionButton(title: "Next shirt", systemImage: "arrow.right", color: .blue) {
                    laundry.next()
                    note = "Slide the shirt with your finger."
                }.accessibilityIdentifier("shapes.laundry.next")
            }
        }
    }

    private func basket(_ color: LaundryColor, index: Int, width: CGFloat) -> some View {
        let frame = LaundryRound.basketFrame(index: index, width: width)
        return VStack(spacing: 8) {
            Image(systemName: "basket.fill").font(.system(size: 44)).foregroundStyle(color.color)
                .shadow(color: .black.opacity(0.65), radius: 1)
            Text(color.name).font(.system(.subheadline, design: .rounded, weight: .bold))
            Text("\(laundry.counts[color, default: 0]) shirts").font(.caption)
            if laundry.solved && color == laundry.current.target {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
            }
        }.foregroundStyle(.primary).frame(width: frame.width, height: frame.height)
            .background(boardColor, in: RoundedRectangle(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(hover == color ? Color.blue : .clear, lineWidth: 3))
            .position(x: frame.midX, y: frame.midY)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(color.name) basket, \(laundry.counts[color, default: 0]) shirts")
            .accessibilityIdentifier("shapes.laundry.basket.\(color.rawValue)")
            .accessibilityAction(named: "Put shirt here") { sort(into: color) }
    }

    private func shirt(width: CGFloat) -> some View {
        Image(systemName: laundry.solved ? "checkmark.circle.fill" : "tshirt.fill")
            .resizable().scaledToFit()
            .foregroundStyle(laundry.solved ? Color.green : laundry.current.target.color)
            .shadow(color: .black.opacity(0.65), radius: 1)
            .frame(width: 112, height: 106).padding(10)
            .contentShape(Rectangle())
            .highPriorityGesture(shirtDrag(width: width), including: laundry.solved ? .none : .all)
            .offset(offset)
            .position(x: width / 2, y: 70)
            .accessibilityLabel("\(laundry.current.target.name) shirt")
            .accessibilityValue(laundry.current.target.rawValue)
            .accessibilityHint("Drag to the matching basket, or use a basket's Put shirt here action.")
            .accessibilityIdentifier("shapes.laundry.shirt")
    }

    private func shirtDrag(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .named("laundry-board"))
            .onChanged { value in
                guard !laundry.solved else { return }
                offset = value.translation
                hover = laundry.current.basket(at: value.location, width: width)
            }
            .onEnded { value in
                offset = .zero
                hover = nil
                sort(into: laundry.current.basket(at: value.location, width: width))
            }
    }

    private func sort(into basket: LaundryColor?) {
        guard !laundry.solved else { return }
        let target = laundry.current.target
        let matched = basket.map { laundry.sort(into: $0) } ?? false
        note = matched ? target.success : target.retry
        narrator.speak(note)
    }
}

struct NestingShapesGame: View {
    let onReplay: () -> Void
    @State private var round = 0
    @State private var layers = 0
    @State private var note = "Show big and small with your hands."
    @StateObject private var narrator = GameNarrator()
    private let sizes: [CGFloat] = [156, 106, 58]
    private let names = ["Large", "Medium", "Small"]
    private var shape: SCShape { SCShape.allCases[min(round, 2)] }
    var body: some View {
        ToddlerGameScaffold(title: "Nesting Shapes", prompt: round == 3 ? "Three shape nests, from large to small!" : "Build a shape nest. Start with the largest, then medium, then small.", accent: .indigo, completion: round == 3, onReplay: onReplay) {
            ZStack {
                Image(systemName: shape.outline).font(.system(size: 170)).foregroundStyle(.gray.opacity(0.2))
                ForEach(0..<layers, id: \.self) { index in
                    Image(systemName: shape.symbol).resizable().scaledToFit().frame(width: sizes[index], height: sizes[index])
                        .foregroundStyle([Color.indigo, .cyan, .yellow][index])
                }
            }.frame(height: 195).accessibilityLabel("\(layers) nested \(shape.name.lowercased()) shapes")
            HStack(spacing: 10) {
                ForEach([2, 0, 1], id: \.self) { index in
                    Button {
                        guard layers < 3, round < 3 else { return }
                        if index == layers { layers += 1; note = "\(names[index]) fits in the nest." }
                        else { note = "Let's choose the \(names[layers].lowercased()) one next." }
                        narrator.speak(note)
                    } label: {
                        VStack {
                            Image(systemName: shape.symbol).resizable().scaledToFit().frame(width: sizes[index] * 0.4, height: 65)
                            Text(names[index]).font(.system(.caption, design: .rounded, weight: .bold))
                        }.foregroundStyle(.indigo).frame(maxWidth: .infinity, minHeight: 105)
                            .background(.white, in: RoundedRectangle(cornerRadius: 18)).opacity(index < layers ? 0.3 : 1)
                    }.buttonStyle(.plain).disabled(index < layers)
                }
            }
            if layers == 3 && round < 3 {
                ToddlerActionButton(title: round == 2 ? "All cozy!" : "Try another shape", systemImage: "arrow.right", color: .indigo) {
                    guard round < 3, layers == 3 else { return }
                    round += 1
                    if round < 3 { layers = 0 }
                }
            }
            SCNote(text: note)
        }
    }
}

struct ShapeTrailsGame: View {
    let onReplay: () -> Void
    @State private var round = 0
    @State private var visited = 0
    @StateObject private var narrator = GameNarrator()
    private var points: [CGPoint] {
        switch min(round, 2) {
        case 0: return (0...8).map { index in
            let angle = Double(index) * .pi / 4 - .pi / 2
            return CGPoint(x: 0.5 + cos(angle) * 0.32, y: 0.5 + sin(angle) * 0.32)
        }
        case 1: return [CGPoint(x: 0.2, y: 0.2), CGPoint(x: 0.8, y: 0.2), CGPoint(x: 0.8, y: 0.8), CGPoint(x: 0.2, y: 0.8), CGPoint(x: 0.2, y: 0.2)]
        default: return [CGPoint(x: 0.5, y: 0.14), CGPoint(x: 0.82, y: 0.8), CGPoint(x: 0.18, y: 0.8), CGPoint(x: 0.5, y: 0.14)]
        }
    }
    private var shape: SCShape { SCShape.allCases[min(round, 2)] }
    var body: some View {
        ToddlerGameScaffold(title: "Shape Trails", prompt: round == 3 ? "You followed a circle, a square, and a triangle all the way around!" : "Follow the glowing dot around the \(shape.name.lowercased()). Slide a finger or tap each dot.", accent: .teal, completion: round == 3, onReplay: onReplay) {
            GeometryReader { geometry in
                let span = min(geometry.size.width, geometry.size.height)
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let locations = points.map { CGPoint(x: center.x + ($0.x - 0.5) * span, y: center.y + ($0.y - 0.5) * span) }
                let nextIndex = visited
                ZStack {
                    RoundedRectangle(cornerRadius: 24).fill(.white)
                    tracePath(locations, center: center, radius: span * 0.32, progress: locations.count)
                        .stroke(.teal.opacity(0.15), style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                    tracePath(locations, center: center, radius: span * 0.32, progress: visited)
                        .stroke(.teal, style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                    if visited < locations.count && round < 3 {
                        Button { advance(expected: nextIndex) } label: {
                            Image(systemName: "hand.point.up.left.fill").font(.system(size: 27)).foregroundStyle(.white)
                                .frame(width: 68, height: 68).background(.teal, in: Circle())
                        }.buttonStyle(.plain).position(locations[visited])
                            .accessibilityLabel("Next point on the \(shape.name.lowercased()) trail")
                    }
                }.contentShape(Rectangle())
                    .highPriorityGesture(DragGesture(minimumDistance: 0).onChanged { value in
                        guard visited < locations.count else { return }
                        let point = locations[visited]
                        if hypot(value.location.x - point.x, value.location.y - point.y) < 39 { advance(expected: visited) }
                    })
            }.frame(height: 280)
            if visited == points.count && round < 3 {
                ToddlerActionButton(title: round == 2 ? "Finish our trails" : "Trace the next shape", systemImage: "arrow.right") {
                    guard round < 3, visited == points.count else { return }
                    round += 1
                    visited = round == 3 ? points.count : 0
                }
            }
            SCNote(text: "Say curved, straight, and corner as you explore. There is no need to stay exactly on the line.")
        }
    }
    private func tracePath(_ locations: [CGPoint], center: CGPoint, radius: CGFloat, progress: Int) -> Path {
        Path { path in
            guard let first = locations.first, progress > 1 else { return }
            path.move(to: first)
            if min(round, 2) == 0 {
                path.addArc(center: center, radius: radius, startAngle: .degrees(-90), endAngle: .degrees(-90 + Double(progress - 1) * 45), clockwise: false)
            } else {
                for point in locations.dropFirst().prefix(progress - 1) { path.addLine(to: point) }
            }
        }
    }
    private func advance(expected: Int) {
        guard expected == visited, visited < points.count, round < 3 else { return }
        visited += 1
        if visited == points.count { narrator.speak("You went all around the \(shape.name.lowercased())!") }
    }
}

struct MosaicGardenGame: View {
    let onReplay: () -> Void
    @State private var paint = SCPaint.red
    @State private var petals: [SCPaint?] = Array(repeating: nil, count: 6)
    @State private var finished = false
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Mosaic Garden", prompt: finished ? "Your colorful flower is ready to share!" : "Choose a paint, then tap the flower petals. Every garden can be different.", accent: .pink, completion: finished, onReplay: onReplay) {
            GeometryReader { geometry in
                ZStack {
                    ForEach(0..<6, id: \.self) { index in
                        let angle = Double(index) * .pi / 3 - .pi / 2
                        Button {
                            petals[index] = paint
                            narrator.speak("\(paint.name) petal.")
                        } label: {
                            Circle().fill(petals[index]?.color ?? .white)
                                .overlay(Circle().stroke(.pink.opacity(0.25), lineWidth: 3))
                                .overlay { if petals[index] == nil { Image(systemName: "paintbrush.pointed.fill").foregroundStyle(.pink.opacity(0.4)) } }
                                .frame(width: 74, height: 74)
                        }.buttonStyle(.plain)
                            .position(x: geometry.size.width / 2 + cos(angle) * 80, y: 132 + sin(angle) * 80)
                            .accessibilityLabel("Petal \(index + 1), \(petals[index]?.name ?? "unpainted")")
                    }
                    Image(systemName: "face.smiling.fill").font(.system(size: 63)).foregroundStyle(.yellow)
                        .position(x: geometry.size.width / 2, y: 132).accessibilityHidden(true)
                }
            }.frame(height: 260)
            SCPaintPicker(selection: $paint)
            if petals.allSatisfy({ $0 != nil }) && !finished {
                ToddlerActionButton(title: "My garden is ready", systemImage: "checkmark", color: .pink) { finished = true }
            }
            SCNote(text: "Describe a color your child chose. Invite them to tell you about their flower.")
        }
    }
}

struct MirrorWingsGame: View {
    let onReplay: () -> Void
    @State private var paint = SCPaint.blue
    @State private var spots: [SCPaint?] = Array(repeating: nil, count: 3)
    @State private var finished = false
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Mirror Wings", prompt: finished ? "Your butterfly has matching colors on both wings!" : "Paint a wing spot. Watch its matching spot appear on the other side!", accent: .purple, completion: finished, onReplay: onReplay) {
            GeometryReader { geometry in
                ZStack {
                    HStack(spacing: 5) {
                        Ellipse().fill(.purple.opacity(0.14))
                        Ellipse().fill(.purple.opacity(0.14))
                    }.padding(.horizontal, 12)
                    Capsule().fill(.indigo).frame(width: 20, height: 225)
                    ForEach(0..<3, id: \.self) { index in
                        ForEach(0..<2, id: \.self) { side in
                            Button {
                                spots[index] = paint
                                narrator.speak("\(paint.name) on both sides. They match!")
                            } label: {
                                Circle().fill(spots[index]?.color ?? .white)
                                    .overlay(Circle().stroke(.purple.opacity(0.3), lineWidth: 3))
                                    .overlay { if spots[index] == nil { Image(systemName: "plus").font(.title2).foregroundStyle(.purple) } }
                                    .frame(width: 66, height: 66)
                            }.buttonStyle(.plain)
                                .position(x: geometry.size.width * (side == 0 ? 0.27 : 0.73), y: CGFloat(index) * 77 + 48)
                                .accessibilityLabel("\(side == 0 ? "Left" : "Right") wing, spot \(index + 1), \(spots[index]?.name ?? "unpainted")")
                        }
                    }
                }
            }.frame(height: 260)
            SCPaintPicker(selection: $paint)
            if spots.allSatisfy({ $0 != nil }) && !finished {
                ToddlerActionButton(title: "Let my butterfly fly", systemImage: "butterfly.fill", color: .purple) { finished = true }
            }
            SCNote(text: "Point to the matching spots. Your child's hands also make a matching pair.")
        }
    }
}

private struct SCSafariObject: Identifiable {
    let id: Int
    let name: String
    let symbol: String
    let shape: SCShape
    let color: Color
}

struct ShapeSafariGame: View {
    let onReplay: () -> Void
    @State private var round = 0
    @State private var found: Set<Int> = []
    @State private var note = "Find another shape like this in the room."
    @StateObject private var narrator = GameNarrator()
    private let objects: [SCSafariObject] = [
        .init(id: 0, name: "Clock face", symbol: "clock.fill", shape: .circle, color: .blue),
        .init(id: 1, name: "Gift box", symbol: "gift.fill", shape: .square, color: .pink),
        .init(id: 2, name: "Mountain peak", symbol: "mountain.2.fill", shape: .triangle, color: .green),
        .init(id: 3, name: "Ball", symbol: "basketball.fill", shape: .circle, color: .orange),
        .init(id: 4, name: "Window", symbol: "square.split.2x2.fill", shape: .square, color: .cyan),
        .init(id: 5, name: "Tent", symbol: "tent.fill", shape: .triangle, color: .purple)
    ]
    private var target: SCShape { SCShape.allCases[min(round, 2)] }
    var body: some View {
        ToddlerGameScaffold(title: "Shape Safari", prompt: round == 3 ? "You found shapes in six everyday things!" : "Find two things with a \(target.name.lowercased()) shape.", accent: .green, completion: round == 3, onReplay: onReplay) {
            Image(systemName: target.outline).font(.system(size: 75)).foregroundStyle(target.color)
                .accessibilityLabel("Look for a \(target.name.lowercased())")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 118))], spacing: 12) {
                ForEach(objects) { object in
                    Button {
                        guard round < 3 else { return }
                        if object.shape == target { found.insert(object.id); note = "The \(object.name.lowercased()) has a \(target.name.lowercased()) shape." }
                        else { note = "Look at the \(object.name.lowercased()). We are looking for a \(target.name.lowercased()) shape." }
                        narrator.speak(note)
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: object.symbol).font(.system(size: 46)).foregroundStyle(object.color)
                            Text(object.name).font(.system(.caption, design: .rounded, weight: .bold))
                            if found.contains(object.id) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
                        }.foregroundStyle(.primary).frame(maxWidth: .infinity, minHeight: 125)
                            .background(.white, in: RoundedRectangle(cornerRadius: 20))
                    }.buttonStyle(.plain).disabled(found.contains(object.id))
                }
            }
            if found.count == 2 && round < 3 {
                ToddlerActionButton(title: round == 2 ? "Finish our safari" : "Find another shape", systemImage: "magnifyingglass", color: .green) {
                    guard round < 3, found.count == 2 else { return }
                    round += 1
                    if round < 3 { found = [] }
                }
            }
            SCNote(text: note)
        }
    }
}

struct RainbowWindowsGame: View {
    let onReplay: () -> Void
    @State private var opened: Set<SCPaint> = []
    @State private var note = "Choose a color to explore."
    @StateObject private var narrator = GameNarrator()
    private let objects = ["a red heart", "a yellow sun", "a blue raindrop", "an orange carrot", "a green leaf", "a purple moon"]
    var body: some View {
        ToddlerGameScaffold(title: "Rainbow Windows", prompt: opened.count == 6 ? "All six rainbow windows are open!" : "Tap a colored window. What is hiding behind it?", accent: .orange, completion: opened.count == 6, onReplay: onReplay) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 14) {
                ForEach(SCPaint.allCases) { paint in
                    Button {
                        opened.insert(paint)
                        note = "You found \(objects[paint.rawValue])!"
                        narrator.speak(note)
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: opened.contains(paint) ? paint.symbol : "door.left.hand.closed").font(.system(size: 50))
                            Text(paint.name).font(.system(.headline, design: .rounded))
                        }.foregroundStyle(paint == .yellow ? Color.black : .white)
                            .frame(maxWidth: .infinity, minHeight: 150)
                            .background(paint.color.gradient, in: RoundedRectangle(cornerRadius: 26))
                    }.buttonStyle(.plain)
                        .accessibilityLabel(opened.contains(paint) ? objects[paint.rawValue] : "Open the \(paint.name.lowercased()) window")
                }
            }
            SCNote(text: note)
        }
    }
}

struct LittleRoadTripGame: View {
    let onReplay: () -> Void
    @State private var step = 0
    @State private var note = "Say across, up, and down as the car moves."
    @StateObject private var narrator = GameNarrator()
    private let route = [6, 7, 4, 1, 2, 5, 8]
    private var current: Int { route[step] }
    private var finished: Bool { step == route.count - 1 }
    private var direction: String {
        guard !finished else { return "home" }
        switch route[step + 1] - current {
        case -3: return "above"
        case 3: return "below"
        default: return "to the right of"
        }
    }
    var body: some View {
        ToddlerGameScaffold(title: "Little Road Trip", prompt: finished ? "You followed the winding road all the way home!" : "Follow the road. Tap the glowing square \(direction) the car.", accent: .blue, completion: finished, onReplay: onReplay) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(0..<9, id: \.self) { cell in
                    Button {
                        guard !finished else { return }
                        if cell == route[step + 1] {
                            let difference = cell - current
                            note = difference == -3 ? "Up the road!" : difference == 3 ? "Down the road!" : "Across the road!"
                            step += 1
                            if finished { note = "We followed the road all the way home." }
                        } else { note = "The next road square is glowing \(direction) the car." }
                        narrator.speak(note)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(!finished && cell == route[step + 1] ? Color.blue.opacity(0.16) : route.contains(cell) ? Color.white : Color.green.opacity(0.15))
                                .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(!finished && cell == route[step + 1] ? Color.blue : .clear, lineWidth: 4))
                            if cell == current { Image(systemName: "car.fill").font(.system(size: 41)).foregroundStyle(.blue) }
                            else if cell == 8 { Image(systemName: "house.fill").font(.system(size: 42)).foregroundStyle(.orange) }
                            else if route.contains(cell) { Image(systemName: "circle.dashed").font(.system(size: 32)).foregroundStyle(.blue.opacity(0.35)) }
                            else { Image(systemName: "tree.fill").font(.system(size: 38)).foregroundStyle(.green) }
                        }.frame(minHeight: 96)
                    }.buttonStyle(.plain).disabled(!route.contains(cell))
                        .accessibilityLabel(cell == current ? "Car" : cell == 8 ? "Home, bottom right" : "Road row \(cell / 3 + 1), column \(cell % 3 + 1)")
                        .accessibilityHint(!finished && cell == route[step + 1] ? "Next road square, \(direction) the car" : "")
                }
            }
            SCNote(text: note)
        }
    }
}

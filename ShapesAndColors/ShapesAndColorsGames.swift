import SwiftUI

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
            PostShapeSilhouette(kind: shape)
                .fill(filled ? Color.green : Color(red: 0.16, green: 0.23, blue: 0.32))
                .overlay(PostShapeSilhouette(kind: shape).stroke(.black.opacity(0.3), lineWidth: 2))
                .frame(width: 62, height: 62)
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
        PostShapeSilhouette(kind: round.target)
            .fill(solved ? Color.green : Color.blue)
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

import SwiftUI

enum TowerBlock: String, CaseIterable {
    case small, medium, large, square, rectangle, trapezoid, hexagon
    var label: String {
        switch self {
        case .small: return "small block"
        case .medium: return "medium block"
        case .large: return "large block"
        default: return rawValue
        }
    }
    var width: CGFloat {
        switch self {
        case .small: return 42
        case .medium: return 62
        case .square: return 24
        case .large: return 104
        case .rectangle: return 68
        case .trapezoid: return 56
        case .hexagon: return 48
        }
    }
    var height: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 21
        default: return 24
        }
    }
}

struct TowerRound {
    enum Stage: Int, CaseIterable {
        case counting, sizes, shapes
        var title: String {
            switch self {
            case .counting: return "Count the blocks"
            case .sizes: return "Match the sizes"
            case .shapes: return "Match the shapes"
            }
        }
        var choices: [TowerBlock] {
            switch self {
            case .counting: return [.medium]
            case .sizes: return [.small, .medium, .large]
            case .shapes: return [.square, .rectangle, .trapezoid, .hexagon]
            }
        }
    }
    let stage: Stage
    let blocks: [TowerBlock] // Bottom to top.
    let choices: [TowerBlock]
    var prompt: String {
        switch stage {
        case .counting: return "Let's build a tower with \(blocks.count) blocks. Drag blocks onto your building mat."
        case .sizes: return "Build with \(blocks.count) blocks. Copy the sizes in my tower, from bottom to top."
        case .shapes: return "Build with \(blocks.count) blocks. Copy the shapes in my tower, from bottom to top."
        }
    }
    static let completion = "You built every tower! You counted blocks and matched their sizes and shapes."
    static let retry = "Look at the next block in my tower. Try a block that matches."
    static let outside = "Drag your block onto your building mat."
    static func success(_ count: Int) -> String { "\(count) blocks! Your tower matches mine!" }
    static func counted(_ count: Int) -> String { "\(count) \(count == 1 ? "block" : "blocks")" }
    static func session() -> [Self] {
        Stage.allCases.flatMap { stage in
            (3...10).map { count in
                var blocks: [TowerBlock] = []
                for _ in 0..<count {
                    let candidates = stage.choices.filter { stage == .counting || $0 != blocks.last }
                    blocks.append(candidates.randomElement()!)
                }
                return Self(stage: stage, blocks: blocks, choices: stage.choices.shuffled())
            }
        }
    }
}

struct TowerSession {
    let rounds = TowerRound.session()
    private(set) var index = 0
    private(set) var count = 0
    var current: TowerRound { rounds[min(index, rounds.count - 1)] }
    var solved: Bool { count == current.blocks.count }
    var finished: Bool { index == rounds.count }
    @discardableResult mutating func place(_ block: TowerBlock, onMat: Bool) -> Bool {
        guard !finished, !solved, onMat, current.choices.contains(block), current.blocks[count] == block else { return false }
        count += 1
        return true
    }
    mutating func next() {
        guard !finished, solved else { return }
        index += 1
        if !finished { count = 0 }
    }
}

private struct TowerBlockShape: Shape {
    let block: TowerBlock
    func path(in rect: CGRect) -> Path {
        let points: [CGPoint]
        switch block {
        case .trapezoid:
            points = [CGPoint(x: rect.width * 0.2, y: 0), CGPoint(x: rect.width * 0.8, y: 0), CGPoint(x: rect.width, y: rect.height), CGPoint(x: 0, y: rect.height)]
        case .hexagon:
            points = [CGPoint(x: rect.width * 0.2, y: 0), CGPoint(x: rect.width * 0.8, y: 0), CGPoint(x: rect.width, y: rect.midY), CGPoint(x: rect.width * 0.8, y: rect.height), CGPoint(x: rect.width * 0.2, y: rect.height), CGPoint(x: 0, y: rect.midY)]
        default: return Path(roundedRect: rect, cornerRadius: 3)
        }
        var path = Path(); path.addLines(points); path.closeSubpath(); return path
    }
}

private struct TowerBlockArt: View {
    let block: TowerBlock
    var outline = false
    var body: some View {
        TowerBlockShape(block: block).fill(outline ? Color.orange.opacity(0.12) : Color.orange)
            .overlay(TowerBlockShape(block: block).stroke(outline ? Color.orange : Color.brown.opacity(0.65), style: StrokeStyle(lineWidth: 2, dash: outline ? [4, 3] : [])))
            .frame(width: block.width, height: block.height)
    }
}

struct BuildATowerGame: View {
    @State private var session = TowerSession()
    @State private var dragged: TowerBlock?
    @State private var offset = CGSize.zero
    @State private var hovering = false
    @State private var feedback = ""
    @StateObject private var narrator = GameNarrator()

    var body: some View {
        ToddlerGameScaffold(title: "Build-A-Tower", prompt: session.finished ? TowerRound.completion : session.current.prompt,
                            accent: .orange, completion: session.finished, onReplay: {
            narrator.stop(); session = TowerSession(); resetDrag(); feedback = ""
        }) {
            Text("Tower \(min(session.index + 1, 24)) of 24 · \(session.current.stage.title)")
                .font(.headline).accessibilityIdentifier("counting.tower.level")
            Text("\(session.count) of \(session.current.blocks.count) blocks")
                .font(.headline).accessibilityIdentifier("counting.tower.progress")
            GeometryReader { geometry in
                let width = geometry.size.width
                let mat = CGRect(x: width / 2 + 4, y: 0, width: width / 2 - 8, height: 340)
                ZStack(alignment: .topLeading) {
                    tower(model: true).frame(width: width / 2 - 8, height: 340)
                        .position(x: width / 4, y: 170)
                    tower(model: false).frame(width: mat.width, height: mat.height)
                        .background(hovering ? Color.yellow.opacity(0.25) : Color.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                        .position(x: mat.midX, y: mat.midY)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Your building mat, \(session.count) blocks")
                        .accessibilityIdentifier("counting.tower.mat")
                    ForEach(Array(session.current.choices.enumerated()), id: \.element) { index, block in
                        VStack(spacing: 8) {
                            TowerBlockArt(block: block).scaleEffect(session.current.stage == .sizes ? 0.8 : 1).frame(width: 66, height: 30)
                            Text(block.label).font(.caption).multilineTextAlignment(.center)
                        }.frame(width: width / CGFloat(session.current.choices.count) - 6, height: 80)
                            .background(.white, in: RoundedRectangle(cornerRadius: 12))
                            .contentShape(Rectangle())
                            .highPriorityGesture(DragGesture(minimumDistance: 4, coordinateSpace: .named("tower-builder"))
                                .onChanged { value in
                                    guard !session.solved, !session.finished else { return }
                                    dragged = block; offset = value.translation; hovering = mat.contains(value.location)
                                }
                                .onEnded { value in resetDrag(); place(block, onMat: mat.contains(value.location)) },
                                including: session.solved || session.finished ? .none : .all)
                            .offset(dragged == block ? offset : .zero)
                            .position(x: (CGFloat(index) + 0.5) * width / CGFloat(session.current.choices.count), y: 393)
                            .zIndex(dragged == block ? 1 : 0)
                            .accessibilityElement(children: .ignore).accessibilityLabel(block.label)
                            .accessibilityIdentifier("counting.tower.block.\(block.rawValue)")
                            .accessibilityAction(named: "Add to tower") { place(block, onMat: true) }
                    }
                }.coordinateSpace(name: "tower-builder")
            }.frame(height: 437)
            if !feedback.isEmpty { Text(feedback).font(.headline).multilineTextAlignment(.center) }
            if session.solved && !session.finished {
                ToddlerActionButton(title: session.index == 23 ? "Finish building" : "Next tower", systemImage: "building.2.fill", color: .orange) {
                    narrator.stop(); session.next(); resetDrag(); feedback = ""
                }.accessibilityIdentifier("counting.tower.next")
            }
        }.id(min(session.index, 23))
            .onDisappear { narrator.stop() }
    }
    private func tower(model: Bool) -> some View {
        VStack(spacing: 4) {
            Text(model ? "Copy my tower" : "Your tower").font(.subheadline.bold())
            Spacer(minLength: 0)
            VStack(spacing: 2) {
                ForEach(Array(session.current.blocks.indices.reversed()), id: \.self) { index in
                    let block = session.current.blocks[index]
                    if model || index < session.count || (index == session.count && !session.solved) {
                        TowerBlockArt(block: block, outline: !model && index == session.count)
                            .overlay {
                                if model && index == session.count && !session.solved {
                                    RoundedRectangle(cornerRadius: 4).stroke(Color.blue, lineWidth: 3).padding(-3)
                                }
                            }
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Block \(index + 1), \(block.label)")
                            .accessibilityIdentifier(model ? "counting.tower.model.\(index)" : "counting.tower.built.\(index)")
                    }
                }
            }
            RoundedRectangle(cornerRadius: 3).fill(Color.brown).frame(height: 8)
            Text(model ? "Bottom → top" : "Building mat").font(.caption)
        }.padding(8)
    }
    private func resetDrag() { dragged = nil; offset = .zero; hovering = false }
    private func place(_ block: TowerBlock, onMat: Bool) {
        guard !session.solved, !session.finished else { return }
        if session.place(block, onMat: onMat) {
            feedback = session.solved ? TowerRound.success(session.count) : TowerRound.counted(session.count)
        } else { feedback = onMat ? TowerRound.retry : TowerRound.outside }
        narrator.speak(feedback)
    }
}

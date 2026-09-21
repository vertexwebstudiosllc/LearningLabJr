import SwiftUI

enum BubbleRule: String { case color, shape, both }

struct ShapeBubble: Identifiable {
    let id: Int
    let shape: PostShape
    let paint: String
    var color: Color { LabPaint.named(paint).color }
    var label: String { "\(paint.capitalized) \(shape.rawValue)" }
}

struct BubbleRound {
    let rule: BubbleRule
    let shape: PostShape
    let paint: String
    let bubbles: [ShapeBubble]
    var key: String { "\(rule.rawValue):\(rule == .color ? "" : shape.rawValue):\(rule == .shape ? "" : paint)" }
    var instruction: String {
        switch rule {
        case .color: return "Pop three \(paint) bubbles. Look for the color \(paint)!"
        case .shape: return "Pop three bubbles with a \(shape.rawValue) inside. They can be any color!"
        case .both: return "Pop three bubbles with a \(paint) \(shape.rawValue) inside. Look for the color and the shape together!"
        }
    }
    var title: String {
        switch rule {
        case .color: return "Find \(paint)"
        case .shape: return "Find the \(shape.rawValue) shapes"
        case .both: return "Find the \(paint) \(shape.rawValue) shapes"
        }
    }
    var stage: String { rule == .color ? "Color explorer" : rule == .shape ? "Shape explorer" : "Colors and shapes together" }
    func matches(_ bubble: ShapeBubble) -> Bool {
        (rule == .color || bubble.shape == shape) && (rule == .shape || bubble.paint == paint)
    }
    static let paints = ["red", "yellow", "blue", "orange", "green", "purple", "pink"]
    static let success = "Pop, pop, pop! You found all three!"
    static let retry = "Let's look again. Find a bubble that matches our clue."
    static let completion = "What a colorful bubble adventure! You found colors and shapes together!"
    static func make(rule: BubbleRule, shape: PostShape, paint: String) -> Self {
        let otherShapes = PostShape.allCases.filter { $0 != shape }.shuffled()
        let otherPaints = paints.filter { $0 != paint }.shuffled()
        var choices: [(PostShape, String)] = (0..<3).map { index in
            (rule == .color ? otherShapes[index] : shape, rule == .shape ? otherPaints[index] : paint)
        }
        switch rule {
        case .color:
            choices += (0..<3).map { (otherShapes[$0 + 3], otherPaints[$0]) }
        case .shape:
            choices += (0..<3).map { (otherShapes[$0], otherPaints[$0 + 3]) }
        case .both:
            choices += [(shape, otherPaints[0]), (otherShapes[0], paint), (otherShapes[1], otherPaints[1])]
        }
        return Self(rule: rule, shape: shape, paint: paint, bubbles: choices.shuffled().enumerated().map {
            ShapeBubble(id: $0.offset, shape: $0.element.0, paint: $0.element.1)
        })
    }
    static func session() -> [Self] {
        let colors = paints.shuffled().map { make(rule: .color, shape: .circle, paint: $0) }
        let shapes = PostShape.allCases.shuffled().map { make(rule: .shape, shape: $0, paint: "blue") }
        let pairs = PostShape.allCases.flatMap { shape in paints.map { (shape, $0) } }.shuffled().prefix(13)
        return colors + shapes + pairs.map { make(rule: .both, shape: $0.0, paint: $0.1) }
    }
    static var narration: [String] {
        let colors = paints.map { make(rule: .color, shape: .circle, paint: $0).instruction }
        let shapes = PostShape.allCases.map { make(rule: .shape, shape: $0, paint: "blue").instruction }
        let pairs = PostShape.allCases.flatMap { shape in paints.map { make(rule: .both, shape: shape, paint: $0).instruction } }
        return colors + shapes + pairs + [success, retry, completion]
    }
}

struct BubbleSession {
    let rounds = BubbleRound.session()
    private(set) var index = 0
    private(set) var popped: Set<Int> = []
    var current: BubbleRound { rounds[min(index, rounds.count - 1)] }
    var solved: Bool { popped.count == 3 }
    var finished: Bool { index == rounds.count }
    @discardableResult mutating func pop(_ id: Int) -> Bool {
        guard !finished, !solved, !popped.contains(id),
              let bubble = current.bubbles.first(where: { $0.id == id }), current.matches(bubble) else { return false }
        popped.insert(id)
        return true
    }
    mutating func next() {
        guard !finished, solved else { return }
        index += 1
        if !finished { popped = [] }
    }
}

struct ShapeBubblePopGame: View {
    let onReplay: () -> Void
    @State private var session = BubbleSession()
    @State private var note = "Tap a matching bubble. Take all the time you need."
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        ToddlerGameScaffold(title: "Shape Bubble Pop", prompt: session.finished ? BubbleRound.completion : session.current.instruction,
                            accent: .cyan, completion: session.finished, onReplay: onReplay) {
            VStack(spacing: 8) {
                Text("Round \(min(session.index + 1, session.rounds.count)) of \(session.rounds.count) · \(session.current.stage)")
                    .font(.system(.subheadline, design: .rounded)).accessibilityIdentifier("shapes.bubbles.round")
                HStack(spacing: 12) {
                    if session.current.rule != .color {
                        Image(systemName: session.current.shape.symbol + ".fill")
                            .resizable().scaledToFit().frame(width: 36, height: 36)
                            .foregroundStyle(session.current.rule == .shape ? Color.primary : LabPaint.named(session.current.paint).color)
                    } else {
                        Circle().fill(LabPaint.named(session.current.paint).color).frame(width: 36, height: 36)
                    }
                    Text(session.current.title).font(.system(.title3, design: .rounded, weight: .bold))
                }.accessibilityElement(children: .ignore)
                    .accessibilityLabel(session.current.title).accessibilityIdentifier("shapes.bubbles.clue")
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 20) {
                ForEach(session.current.bubbles) { bubble in
                    BubblePopButton(bubble: bubble, popped: session.popped.contains(bubble.id), disabled: session.solved || session.finished) {
                        if session.pop(bubble.id) {
                            if session.solved { note = BubbleRound.success; narrator.speak(note) }
                            else { note = "\(session.popped.count) of 3 bubbles found!" }
                        } else { note = BubbleRound.retry; narrator.speak(note) }
                    }
                }
            }.padding(14)
                .background(LinearGradient(colors: [.cyan.opacity(0.14), .white], startPoint: .top, endPoint: .bottom), in: RoundedRectangle(cornerRadius: 26))
                .id(session.index)
            HStack(spacing: 20) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < session.popped.count ? "sparkles" : "circle.dotted")
                        .font(.system(size: 32)).foregroundStyle(index < session.popped.count ? .orange : .gray.opacity(0.4))
                }
            }.accessibilityElement(children: .ignore).accessibilityLabel("\(session.popped.count) of 3 bubbles found")
                .accessibilityIdentifier("shapes.bubbles.progress")
            SCNote(text: note)
            if session.solved && !session.finished {
                ToddlerActionButton(title: session.index == session.rounds.count - 1 ? "Finish our adventure" : "More bubbles", systemImage: "bubbles.and.sparkles", color: .cyan) {
                    session.next()
                    note = "Tap a matching bubble. Take all the time you need."
                }.accessibilityIdentifier("shapes.bubbles.next")
            }
        }
    }
}

private struct BubblePopButton: View {
    let bubble: ShapeBubble
    let popped: Bool
    let disabled: Bool
    let action: () -> Void
    @State private var floating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().fill(.white.opacity(0.9))
                    .overlay(Circle().stroke(bubble.color.opacity(0.45), lineWidth: 3))
                Image(systemName: bubble.shape.symbol + ".fill")
                    .resizable().scaledToFit().padding(22).foregroundStyle(bubble.color)
                Circle().fill(.white.opacity(0.85)).frame(width: 12, height: 12).offset(x: -22, y: -23)
            }
            .aspectRatio(1, contentMode: .fit)
            .scaleEffect(popped ? 0.35 : 1).opacity(popped ? 0.15 : 1)
            .offset(y: reduceMotion ? 0 : floating ? -3 : 3)
            .animation(reduceMotion ? nil : .easeInOut(duration: 1.5 + Double(bubble.id) * 0.1).repeatForever(autoreverses: true), value: floating)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.22), value: popped)
            .overlay { if popped { Image(systemName: "sparkles").font(.title).foregroundStyle(.orange) } }
            .contentShape(Circle())
        }.buttonStyle(.plain)
            .accessibilityLabel(bubble.label + (popped ? ", popped" : " bubble"))
            .accessibilityIdentifier("shapes.bubbles.choice.\(bubble.id)")
            .disabled(disabled || popped)
            .onAppear { floating = true }
    }
}

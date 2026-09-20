import SwiftUI

struct NestMemory: Codable {
    var lastShape: String?
    var palettes: [String: [String]] = [:]
    static let key = "nestingShapes.colorMemory"
    static func load() -> Self {
        guard let data = UserDefaults.standard.data(forKey: key),
              let memory = try? JSONDecoder().decode(Self.self, from: data) else { return Self() }
        return memory
    }
    func save() {
        if let data = try? JSONEncoder().encode(self) { UserDefaults.standard.set(data, forKey: Self.key) }
    }
}

struct NestRound {
    let shape: PostShape
    let colors: [String]
    let choices: [String]
    static let palette = ["red", "yellow", "blue", "orange", "green", "purple", "pink"]
    func prompt(layer: Int) -> String {
        layer < 3 ? "Find the \(colors[layer]) \(shape.rawValue)." : "Your \(shape.rawValue) nest is ready!"
    }
    static func make(shape: PostShape, previous: [String]?) -> Self {
        var colors = Array(palette.shuffled().prefix(3))
        if colors == previous { colors = Array(colors.dropFirst()) + [colors[0]] }
        return Self(shape: shape, colors: colors, choices: colors.shuffled())
    }
}

struct NestSession {
    private(set) var memory: NestMemory
    private(set) var remaining: [PostShape]
    private(set) var current: NestRound
    private(set) var layer = 0
    private(set) var completed = 0
    var solved: Bool { layer == 3 }
    var prompt: String { current.prompt(layer: layer) }
    init(memory: NestMemory = NestMemory()) {
        var shapes = Self.deck(after: memory.lastShape)
        let shape = shapes.removeFirst()
        let round = NestRound.make(shape: shape, previous: memory.palettes[shape.rawValue])
        self.memory = memory
        self.remaining = shapes
        self.current = round
        remember()
    }
    private static func deck(after previous: String?) -> [PostShape] {
        var shapes = PostShape.allCases.shuffled()
        if shapes.first?.rawValue == previous { shapes.swapAt(0, Int.random(in: 1..<shapes.count)) }
        return shapes
    }
    private mutating func remember() {
        memory.lastShape = current.shape.rawValue
        memory.palettes[current.shape.rawValue] = current.colors
    }
    @discardableResult
    mutating func choose(_ color: String, expectedLayer: Int) -> Bool {
        guard !solved, layer == expectedLayer, color == current.colors[layer] else { return false }
        layer += 1
        if solved { completed += 1 }
        return true
    }
    mutating func next() {
        guard solved else { return }
        if remaining.isEmpty { remaining = Self.deck(after: current.shape.rawValue) }
        let shape = remaining.removeFirst()
        current = NestRound.make(shape: shape, previous: memory.palettes[shape.rawValue])
        layer = 0
        remember()
    }
}

struct NestingShapesGame: View {
    let onReplay: () -> Void
    @State private var nest: NestSession
    @StateObject private var narrator = GameNarrator()
    private let sizes: [CGFloat] = [190, 130, 70]
    init(onReplay: @escaping () -> Void) {
        self.onReplay = onReplay
        _nest = State(initialValue: NestSession(memory: .load()))
    }
    var body: some View {
        ToddlerGameScaffold(title: "Nesting Shapes", prompt: nest.prompt, accent: .indigo) {
            Text("\(nest.current.shape.name) nest").font(.system(.headline, design: .rounded))
                .accessibilityIdentifier("shapes.nest.shape")
                .accessibilityValue(nest.current.shape.rawValue)
            ZStack {
                RoundedRectangle(cornerRadius: 24).fill(Color(red: 0.87, green: 0.91, blue: 0.97))
                Image(systemName: nest.current.shape.symbol)
                    .resizable().scaledToFit().frame(width: sizes[0], height: sizes[0])
                    .foregroundStyle(.gray.opacity(0.3))
                ForEach(0..<nest.layer, id: \.self) { index in
                    Image(systemName: nest.current.shape.symbol + ".fill")
                        .resizable().scaledToFit().frame(width: sizes[index], height: sizes[index])
                        .foregroundStyle(LabPaint.named(nest.current.colors[index]).color)
                }
            }.frame(height: 215)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(nest.layer) nested \(nest.current.shape.name.lowercased()) layers")
                .accessibilityValue(nest.current.colors.prefix(nest.layer).joined(separator: ","))
                .accessibilityIdentifier("shapes.nest.picture")
            Text("\(nest.layer) of 3 colors nested · \(nest.completed) \(nest.completed == 1 ? "nest" : "nests") made")
                .font(.subheadline).accessibilityIdentifier("shapes.nest.progress")
            if !nest.solved {
                let target = LabPaint.named(nest.current.colors[nest.layer])
                Label {
                    Text("Next color: \(target.name)")
                } icon: {
                    Circle().fill(target.color).frame(width: 24, height: 24)
                }.font(.headline).accessibilityElement(children: .ignore)
                    .accessibilityLabel("Next color: \(target.name)")
                    .accessibilityIdentifier("shapes.nest.target")
                    .accessibilityValue(target.id)
            }
            HStack(spacing: 12) {
                ForEach(nest.current.choices, id: \.self) { color in
                    choice(color)
                }
            }
            if nest.solved {
                ToddlerActionButton(title: "Build another nest", systemImage: "arrow.right", color: .indigo) {
                    nest.next()
                    nest.memory.save()
                }.accessibilityIdentifier("shapes.nest.next")
            }
            SCNote(text: "Choose the color together. Watch each shape fit inside the last one.")
        }.onAppear { nest.memory.save() }
    }
    private func choice(_ color: String) -> some View {
        let paint = LabPaint.named(color)
        let expected = nest.layer
        let placed = nest.current.colors.prefix(nest.layer).contains(color)
        return Button {
            guard !nest.solved, !placed else { return }
            if !nest.choose(color, expectedLayer: expected) { narrator.speak(nest.prompt) }
            // The scaffold narrates the next color or completion when its prompt changes.
        } label: {
            VStack(spacing: 8) {
                Image(systemName: nest.current.shape.symbol + ".fill")
                    .resizable().scaledToFit().frame(width: 56, height: 56).foregroundStyle(paint.color)
                Text(paint.name).font(.system(.caption, design: .rounded, weight: .bold))
                Image(systemName: placed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(placed ? Color.green : Color.clear)
            }.frame(maxWidth: .infinity, minHeight: 115)
                .background(.white, in: RoundedRectangle(cornerRadius: 20))
        }.buttonStyle(.plain).disabled(placed || nest.solved)
            .accessibilityLabel("\(paint.name) \(nest.current.shape.rawValue)\(placed ? ", nested" : "")")
            .accessibilityIdentifier("shapes.nest.choice.\(color)")
    }
}

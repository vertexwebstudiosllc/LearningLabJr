import SwiftUI

enum WindowPaint: String, CaseIterable, Identifiable {
    case red, yellow, blue, orange, green, purple
    var id: String { rawValue }
    var color: Color { LabPaint.named(rawValue).color }
    var ink: Color { LabPaint.named(rawValue).ink }
}

struct RainbowWindowRound {
    let shape: PostShape?
    let colors: [WindowPaint]
    let surprises: [String]
    static let objects = ["cat", "dog", "cow", "duck", "hen", "crab", "seal", "fish", "flower", "tree", "leaf", "butterfly", "moon", "star", "earth", "rocket", "book", "cup", "bowl", "spoon", "bell", "clock", "lamp"]
    static func session() -> [Self] {
        // Two discovery rounds, then a different shape in each of ten listening rounds.
        let shapes: [PostShape?] = [nil, nil] + PostShape.allCases.shuffled().map { Optional($0) }
        var previous: Set<String> = []
        return shapes.map { shape in
            let objects = Array(Self.objects.filter { !previous.contains($0) }.shuffled().prefix(6))
            previous = Set(objects)
            return Self(shape: shape, colors: WindowPaint.allCases.shuffled(), surprises: objects)
        }
    }
}

struct RainbowWindowSession {
    let rounds = RainbowWindowRound.session()
    private(set) var index = 0
    private(set) var opened: Set<WindowPaint> = []
    private(set) var targets = WindowPaint.allCases.shuffled()
    var round: RainbowWindowRound { rounds[min(index, rounds.count - 1)] }
    var complete: Bool { opened.count == 6 }
    var finished: Bool { index == rounds.count }
    var target: WindowPaint? { targets.first { !opened.contains($0) } }
    var prompt: String {
        if complete || finished { return "All six rainbow windows are open!" }
        if let shape = round.shape, let target { return "Find the \(target.rawValue) \(shape.rawValue)." }
        return "Tap a colored window. What is hiding behind it?"
    }
    mutating func open(_ paint: WindowPaint) -> Bool {
        guard !finished, !opened.contains(paint), round.shape == nil || paint == target else { return false }
        opened.insert(paint)
        return true
    }
    mutating func next() {
        guard complete, !finished else { return }
        index += 1
        if !finished { opened = []; targets.shuffle() }
    }
}

struct RainbowWindowsGame: View {
    let onReplay: () -> Void
    @State private var game = RainbowWindowSession()
    @State private var note = "Choose a color to explore."
    @StateObject private var narrator = GameNarrator()
    var body: some View {
        // Narration is sequenced below so opening a window never interrupts its object name.
        ToddlerGameScaffold(title: "Rainbow Windows", prompt: game.prompt, accent: .orange, completion: game.finished, onReplay: onReplay, autoNarratePrompt: false) {
            Text("Level \(min(game.index + 1, game.rounds.count)) of \(game.rounds.count)")
                .font(.headline).accessibilityIdentifier("rainbow.level")
            if let shape = game.round.shape, let target = game.target, !game.complete {
                HStack {
                    PostShapeSilhouette(kind: shape).fill(target.color).frame(width: 44, height: 44)
                    Text("\(target.rawValue.capitalized) \(shape.name.lowercased())")
                }.accessibilityElement(children: .ignore).accessibilityLabel(game.prompt)
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(Array(game.round.colors.enumerated()), id: \.element.id) { index, paint in
                    Button { reveal(paint, object: game.round.surprises[index]) } label: {
                        VStack(spacing: 8) {
                            if game.opened.contains(paint) {
                                LiteracyVocabularyArt(word: game.round.surprises[index]).frame(height: 76)
                                    .padding(6).background(.white.opacity(0.93), in: RoundedRectangle(cornerRadius: 12))
                            } else if let shape = game.round.shape {
                                PostShapeSilhouette(kind: shape).fill(paint.ink).frame(width: 65, height: 65).padding(12)
                            } else {
                                Image(systemName: "door.left.hand.closed").font(.system(size: 55)).frame(height: 89)
                            }
                            Text(paint.rawValue.capitalized).font(.headline)
                        }.foregroundStyle(paint.ink).frame(maxWidth: .infinity, minHeight: 135).padding(8)
                            .background(paint.color.gradient, in: RoundedRectangle(cornerRadius: 22))
                    }.buttonStyle(.plain)
                        .accessibilityLabel("\(paint.rawValue) window")
                        .accessibilityValue(game.opened.contains(paint) ? "Open: \(game.round.surprises[index])" : "Closed")
                        .accessibilityIdentifier("rainbow.window.\(paint.rawValue)")
                        .disabled(game.finished)
                }
            }
            SCNote(text: note)
            if game.complete && !game.finished {
                ToddlerActionButton(title: game.index == game.rounds.count - 1 ? "Finish our rainbow" : "Next windows", systemImage: "arrow.right", color: .orange) {
                    game.next(); note = "Choose a color to explore."; narrator.speak(game.prompt)
                }.accessibilityIdentifier("rainbow.next")
            }
        }.onAppear { narrator.speak(game.prompt) }.onDisappear { narrator.stop() }
    }
    private func reveal(_ paint: WindowPaint, object: String) {
        guard !game.finished else { return }
        if game.opened.contains(paint) { narrator.speak(object.capitalized); return }
        guard game.open(paint) else {
            note = "Look for the matching color. You can try again."
            narrator.speak(game.prompt); return
        }
        note = "\(paint.rawValue.capitalized) window: \(object)!"
        narrator.speakSequence([object.capitalized, game.prompt], onLine: { _ in }, onFinish: {})
    }
}
